import datetime
import json
import logging
import math
from pathlib import Path
import numpy as np

from backend.app.config import Config

logger = logging.getLogger(__name__)


class BayesianTrustEngine:
    """
    Bayesian Conjugate Trust & Data Integrity Engine.
    Employs Beta-Binomial conjugate updating with exponential time decay across 12
    multimodal telemetry signals to quantify verification confidence and identify anomalies.
    """

    SIGNALS = Config.TRUST_SIGNALS

    SIGNAL_WEIGHTS = {
        "image_quality": 0.12,
        "gps_consistency": 0.10,
        "temporal_consistency": 0.08,
        "disease_severity_plausibility": 0.12,
        "weather_correlation": 0.10,
        "historical_pattern": 0.08,
        "device_fingerprint": 0.07,
        "submission_frequency": 0.07,
        "metadata_completeness": 0.06,
        "expert_agreement": 0.10,
        "cross_validation": 0.05,
        "community_consensus": 0.05
    }

    def __init__(self, state_path=None, decay_lambda=0.01):
        """
        Initialize Bayesian Trust Engine.

        Args:
            state_path (Path or str): File path to persist Beta priors.
            decay_lambda (float): Daily exponential time-decay parameter.
        """
        self.state_path = Path(state_path) if state_path else Config.TRUST_STATE_PATH
        self.decay_lambda = decay_lambda

        # Initialize Beta distribution priors: (alpha, beta) for each of the 12 signals
        # Prior parameters initialized to Beta(5, 1) reflecting positive initial presumption
        self.priors = {s: {"alpha": 5.0, "beta": 1.2} for s in self.SIGNALS}

        # Submission history log for anomaly detection (keyed by device_id or user_id)
        self.history = {}

        if self.state_path.exists():
            self.load_state(self.state_path)

    def _haversine_distance_km(self, lat1, lon1, lat2, lon2):
        """Calculate great-circle distance between two GPS coordinates in kilometers."""
        r = 6371.0  # Earth's mean radius in km
        phi1 = math.radians(lat1)
        phi2 = math.radians(lat2)
        delta_phi = math.radians(lat2 - lat1)
        delta_lambda = math.radians(lon2 - lon1)

        a = (
            math.sin(delta_phi / 2.0) ** 2
            + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2.0) ** 2
        )
        c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
        return r * c

    def detect_anomalies(self, observation):
        """
        Detect geospatial, behavioral, and biological anomalies.

        Checks:
        1. Geospatial teleportation (>100 km in <1 hr)
        2. Excessive scan frequency (>20 scans/hr from same entity)
        3. Biological impossibility (>30% severity drop in 24 hr without treatment)
        4. Coordinate boundaries out of realistic terrestrial range

        Args:
            observation (dict): Observation metadata payload.

        Returns:
            list: Detected anomaly flags with diagnostic details.
        """
        anomaly_flags = []
        entity_id = observation.get("device_id") or observation.get("user_id") or "default_client"
        now_ts = observation.get("timestamp")

        if isinstance(now_ts, str):
            try:
                now_dt = datetime.datetime.fromisoformat(now_ts.replace("Z", "+00:00"))
            except Exception:
                now_dt = datetime.datetime.now(datetime.timezone.utc)
        elif isinstance(now_ts, datetime.datetime):
            now_dt = now_ts
        else:
            now_dt = datetime.datetime.now(datetime.timezone.utc)

        if now_dt.tzinfo is None:
            now_dt = now_dt.replace(tzinfo=datetime.timezone.utc)

        curr_lat = observation.get("latitude")
        curr_lon = observation.get("longitude")
        curr_severity = observation.get("disease_severity")
        treatment_applied = bool(observation.get("treatment_applied", False))

        # Check coordinate validity
        if curr_lat is not None and curr_lon is not None:
            if not (-90.0 <= curr_lat <= 90.0 and -180.0 <= curr_lon <= 180.0):
                anomaly_flags.append({
                    "type": "INVALID_GPS_COORDINATES",
                    "severity": "CRITICAL",
                    "penalty": 0.40,
                    "details": f"Coordinates ({curr_lat}, {curr_lon}) outside valid global range."
                })

        entity_history = self.history.get(entity_id, [])

        if entity_history:
            last_obs = entity_history[-1]
            last_dt = last_obs.get("dt", now_dt)
            if last_dt.tzinfo is None:
                last_dt = last_dt.replace(tzinfo=datetime.timezone.utc)
            delta_hours = max(1e-5, (now_dt - last_dt).total_seconds() / 3600.0)

            # Anomaly 1: Geospatial jump (>100 km in < 1 hour)
            if (
                curr_lat is not None and curr_lon is not None and
                last_obs.get("lat") is not None and last_obs.get("lon") is not None
            ):
                dist_km = self._haversine_distance_km(
                    last_obs["lat"], last_obs["lon"], curr_lat, curr_lon
                )
                speed_kmh = dist_km / delta_hours
                if dist_km > Config.MAX_SPEED_KMH and delta_hours < 1.0:
                    anomaly_flags.append({
                        "type": "GEOSPATIAL_TELEPORTATION",
                        "severity": "CRITICAL",
                        "penalty": 0.35,
                        "details": (
                            f"Location shifted {dist_km:.1f} km in {delta_hours*60:.1f} minutes "
                            f"(effective speed: {speed_kmh:.1f} km/h > threshold {Config.MAX_SPEED_KMH} km/h)."
                        )
                    })

            # Anomaly 2: Excessive scan frequency (>20 scans/hr)
            recent_hour_scans = sum(
                1 for obs in entity_history
                if (now_dt - obs["dt"]).total_seconds() <= 3600.0
            ) + 1  # Include current scan
            if recent_hour_scans > Config.MAX_SCANS_PER_HOUR:
                anomaly_flags.append({
                    "type": "EXCESSIVE_SCAN_FREQUENCY",
                    "severity": "HIGH",
                    "penalty": 0.25,
                    "details": (
                        f"Detected {recent_hour_scans} submissions within the last 60 minutes "
                        f"(exceeds rate limit of {Config.MAX_SCANS_PER_HOUR}/hr)."
                    )
                })

            # Anomaly 3: Unexplained severity drops (>30% drop in <24 hr without treatment)
            if curr_severity is not None and last_obs.get("severity") is not None:
                last_sev = last_obs["severity"]
                severity_drop = last_sev - curr_severity
                if severity_drop > Config.MAX_SEVERITY_DROP_PER_DAY and delta_hours <= 24.0:
                    if not treatment_applied:
                        anomaly_flags.append({
                            "type": "UNEXPLAINED_SEVERITY_DROP",
                            "severity": "HIGH",
                            "penalty": 0.30,
                            "details": (
                                f"Disease severity dropped by {severity_drop*100:.1f}% within {delta_hours:.1f} hours "
                                "without documented remedial chemical or biological intervention."
                            )
                        })

        # Record this observation into entity history
        if entity_id not in self.history:
            self.history[entity_id] = []
        self.history[entity_id].append({
            "dt": now_dt,
            "lat": curr_lat,
            "lon": curr_lon,
            "severity": curr_severity,
            "treatment": treatment_applied
        })

        # Keep history buffer bounded (last 50 events per entity)
        if len(self.history[entity_id]) > 50:
            self.history[entity_id] = self.history[entity_id][-50:]

        return anomaly_flags

    def update_prior(self, signal, outcome, days_elapsed=0.0):
        """
        Update Beta conjugate prior for a given signal with exponential time decay.

        Args:
            signal (str): One of the 12 trust signal names.
            outcome (float): Observed compliance score in [0.0, 1.0].
            days_elapsed (float): Time since last update for discounting past belief.
        """
        if signal not in self.priors:
            raise ValueError(f"Unknown trust signal: {signal}")

        outcome = float(np.clip(outcome, 0.0, 1.0))
        prior = self.priors[signal]

        # Apply exponential decay to past accumulated evidence
        if days_elapsed > 0:
            decay_factor = math.exp(-self.decay_lambda * days_elapsed)
            # Decay evidence towards uninformative base Beta(1, 1)
            alpha_decayed = 1.0 + (prior["alpha"] - 1.0) * decay_factor
            beta_decayed = 1.0 + (prior["beta"] - 1.0) * decay_factor
        else:
            alpha_decayed = prior["alpha"]
            beta_decayed = prior["beta"]

        # Conjugate Beta updating: alpha += outcome, beta += (1 - outcome)
        new_alpha = alpha_decayed + outcome
        new_beta = beta_decayed + (1.0 - outcome)

        self.priors[signal]["alpha"] = round(new_alpha, 4)
        self.priors[signal]["beta"] = round(new_beta, 4)

    def calculate_trust(self, evidence_dict=None, observation_meta=None):
        """
        Compute aggregate trust score, confidence, breakdown, and anomaly flags.

        Args:
            evidence_dict (dict): Dictionary mapping signal names to score in [0.0, 1.0].
            observation_meta (dict): Optional observation context for anomaly checks.

        Returns:
            dict: Comprehensive Bayesian trust assessment.
        """
        evidence = evidence_dict or {}
        obs_meta = observation_meta or {}

        # 1. Run anomaly checks
        anomaly_flags = self.detect_anomalies(obs_meta)

        # 2. Compute posterior expectation and variance for each signal
        breakdown = {}
        weighted_score_sum = 0.0
        total_weight = 0.0
        confidence_accum = 0.0

        for sig in self.SIGNALS:
            weight = self.SIGNAL_WEIGHTS.get(sig, 1.0 / len(self.SIGNALS))
            prior = self.priors[sig]
            a = prior["alpha"]
            b = prior["beta"]

            # Expected value of Beta distribution: E[X] = alpha / (alpha + beta)
            prior_expected = a / (a + b)
            # Variance: Var[X] = (alpha * beta) / ((alpha + beta)^2 * (alpha + beta + 1))
            variance = (a * b) / (((a + b) ** 2) * (a + b + 1.0))
            # Normalized confidence: lower variance -> higher certainty
            sig_confidence = float(np.clip(1.0 - math.sqrt(12.0 * variance), 0.20, 0.98))

            # If current observation provides direct evidence, blend with prior
            if sig in evidence and evidence[sig] is not None:
                obs_val = float(np.clip(evidence[sig], 0.0, 1.0))
                # Posterior Bayesian estimate
                posterior_estimate = (a + obs_val) / (a + b + 1.0)
            else:
                posterior_estimate = prior_expected
                obs_val = prior_expected

            breakdown[sig] = {
                "observed_score": round(obs_val, 3),
                "posterior_mean": round(posterior_estimate, 3),
                "confidence": round(sig_confidence, 3),
                "weight": weight,
                "weighted_contribution": round(posterior_estimate * weight, 4),
                "alpha": a,
                "beta": b
            }

            weighted_score_sum += posterior_estimate * weight
            total_weight += weight
            confidence_accum += sig_confidence * weight

        base_score = weighted_score_sum / max(1e-6, total_weight)
        overall_confidence = confidence_accum / max(1e-6, total_weight)

        # 3. Apply cumulative penalties for detected anomalies
        total_penalty = sum(f.get("penalty", 0.0) for f in anomaly_flags)
        final_score = float(np.clip(base_score - total_penalty, 0.0, 1.0))

        # 4. Determine operational recommendation and trust level
        if anomaly_flags and any(f.get("severity") == "CRITICAL" for f in anomaly_flags):
            level = "Flagged Anomalous"
            recommendation = "Reject automated telemetry. Critical anomalies detected; mandatory agronomist review required."
        elif final_score >= 0.82:
            level = "Verified High Trust"
            recommendation = "All verification signals passed Bayesian validation. Telemetry accepted with high confidence."
        elif final_score >= 0.60:
            level = "Moderate Trust"
            recommendation = "Telemetry acceptable for advisory guidance. Minor signal variance detected."
        else:
            level = "Low Trust"
            recommendation = "Low integrity score. Request re-capture of foliar image under calibrated lighting."

        return {
            "score": round(final_score, 4),
            "raw_score": round(base_score, 4),
            "confidence": round(overall_confidence, 4),
            "trust_level": level,
            "penalties_applied": round(total_penalty, 4),
            "anomaly_flags": anomaly_flags,
            "anomalies_detected": len(anomaly_flags) > 0,
            "recommendation": recommendation,
            "evidence_breakdown": breakdown
        }

    def get_evidence_summary(self):
        """Return a transparent summary of current Beta parameters for all 12 signals."""
        summary = {}
        for sig in self.SIGNALS:
            p = self.priors[sig]
            a, b = p["alpha"], p["beta"]
            expected = a / (a + b)
            summary[sig] = {
                "alpha": a,
                "beta": b,
                "expected_mean": round(expected, 4),
                "weight": self.SIGNAL_WEIGHTS.get(sig, 0.0)
            }
        return summary

    def save_state(self, path=None):
        """Persist Beta priors to JSON file."""
        target_path = Path(path) if path else self.state_path
        target_path.parent.mkdir(parents=True, exist_ok=True)
        with open(target_path, "w", encoding="utf-8") as f:
            json.dump(self.priors, f, indent=2)
        logger.info(f"Bayesian trust priors persisted to {target_path}")
        return str(target_path)

    def load_state(self, path=None):
        """Load Beta priors from JSON file."""
        target_path = Path(path) if path else self.state_path
        if not target_path.exists():
            return False
        try:
            with open(target_path, "r", encoding="utf-8") as f:
                loaded = json.load(f)
            for k, v in loaded.items():
                if k in self.priors:
                    self.priors[k] = v
            logger.info(f"Loaded Bayesian trust priors from {target_path}")
            return True
        except Exception as exc:
            logger.error(f"Error loading Bayesian trust state: {exc}")
            return False
