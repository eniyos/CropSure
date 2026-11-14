import datetime
import numpy as np
import pandas as pd
import pytest
import torch

from backend.app.config import Config
from backend.app.models.yolov8_detector import TomatoDiseaseDetector
from backend.app.models.vanderplank_simulator import VanDerPlankSimulator
from backend.app.models.lstm_forecaster import DiseaseForecaster, DiseaseLSTM
from backend.app.models.gradcam_engine import GradCAMEngine
from backend.app.models.yield_regressor import YieldLossRegressor
from backend.app.models.bayesian_trust import BayesianTrustEngine
from backend.app.services.ai_service import AIService


# =========================================================================
# 1. Van der Plank Epidemic Simulator Tests
# =========================================================================

def test_vanderplank_simulator_valid_trajectory():
    """Verify simulator generates valid daily trajectory bounded within [0, 1]."""
    sim = VanDerPlankSimulator(
        initial_inoculum=0.01,
        infection_rate=0.28,
        latent_period=4,
        sporulation_period=12,
        temp=24.0,
        humidity=85.0,
        precipitation=8.0
    )
    res = sim.simulate(days=60)

    assert res is not None
    assert len(res["days"]) == 61
    assert len(res["severity_trajectory"]) == 61

    # Severity values must remain strictly in [0.0, 1.0]
    for s in res["severity_trajectory"]:
        assert 0.0 <= s <= 1.0

    # Epidemic trajectory should generally be non-decreasing
    assert res["severity_trajectory"][-1] >= res["severity_trajectory"][0]
    assert res["audpc"] > 0.0
    assert 0 <= res["peak_day"] <= 60
    assert 0 <= res["inflection_day"] <= 60


def test_vanderplank_generate_trajectories():
    """Verify batch trajectory generation produces properly structured DataFrame."""
    sim = VanDerPlankSimulator()
    df = sim.generate_trajectories(n=25, days=30, random_state=42)

    assert isinstance(df, pd.DataFrame)
    assert len(df) == 25
    assert "trajectory_id" in df.columns
    assert "audpc" in df.columns
    assert "day_7_severity" in df.columns
    assert "day_30_severity" in df.columns

    # Check value bounds
    assert (df["final_severity"] >= 0.0).all() and (df["final_severity"] <= 1.0).all()


def test_vanderplank_compare_scenarios():
    """Verify scenario comparison reports realistic differential disease progression."""
    sim = VanDerPlankSimulator()
    comparison = sim.compare_scenarios(days=60)

    assert "baseline" in comparison
    assert "favorable" in comparison
    assert "unfavorable" in comparison
    assert "treated" in comparison
    assert "audpc_comparison" in comparison

    audpc = comparison["audpc_comparison"]
    # Favorable weather should produce higher AUDPC than unfavorable dry weather
    assert audpc["favorable"] > audpc["unfavorable"]
    # Treated intervention must achieve lower AUDPC than untreated baseline or favorable
    assert audpc["treated"] < audpc["favorable"]
    assert comparison["loss_reduction_pct"] >= 0.0


# =========================================================================
# 2. BiLSTM Forecaster Tests
# =========================================================================

def test_lstm_model_architecture():
    """Verify PyTorch DiseaseLSTM tensor input/output forward shape and range."""
    batch_size = 4
    seq_len = 14
    input_size = 7
    output_size = 3

    model = DiseaseLSTM(
        input_size=input_size,
        hidden_size=64,
        num_layers=2,
        dropout=0.3,
        output_size=output_size
    )
    dummy_input = torch.randn(batch_size, seq_len, input_size)
    output = model(dummy_input)

    assert output.shape == (batch_size, output_size)
    # Output must be bounded in [0, 1] due to Sigmoid
    assert torch.all(output >= 0.0) and torch.all(output <= 1.0)


def test_lstm_sequence_creation():
    forecaster = DiseaseForecaster(input_size=7)
    # 60 time steps with 7 features (exceeds seq_len=14 + max_horizon=30 = 44)
    raw_data = np.random.uniform(0.0, 1.0, (60, 7)).astype(np.float32)
    X, y = forecaster.create_sequences(raw_data, seq_len=14)

    assert X.shape[1] == 14
    assert X.shape[2] == 7
    assert y.shape[1] == 3  # 3 horizons (7, 14, 30)


def test_lstm_forecaster_predict(sample_history):
    """Verify forecast predictions return mean, std dev, 95% CI, and daily trajectory."""
    forecaster = DiseaseForecaster()
    res = forecaster.predict(sample_history, horizons=[7, 14, 30], mc_samples=15)

    assert res["success"] is True
    assert "horizons" in res
    assert "day_7" in res["horizons"]
    assert "day_14" in res["horizons"]
    assert "day_30" in res["horizons"]

    for h_key in ["day_7", "day_14", "day_30"]:
        h_data = res["horizons"][h_key]
        pred_sev = h_data["predicted_severity"]
        assert 0.0 <= pred_sev <= 1.0
        ci = h_data["confidence_interval_95"]
        assert 0.0 <= ci[0] <= ci[1] <= 1.0
        assert h_data["risk_level"] in ["Low", "Moderate", "High", "Severe"]

    assert len(res["daily_trajectory"]) == 31  # Day 0 to 30


# =========================================================================
# 3. Grad-CAM Explainability Engine Tests
# =========================================================================

def test_gradcam_engine_output(sample_image):
    """Verify Grad-CAM produces base64 heatmaps, overlays, and detected regions of interest."""
    engine = GradCAMEngine()
    result = engine.explain(sample_image)

    assert result["success"] is True
    assert "class_label" in result
    assert result["class_label"] in Config.DISEASE_CLASSES
    assert 0.0 <= result["confidence"] <= 1.0
    assert result["overlay_base64"].startswith("data:image/")
    assert result["heatmap_base64"].startswith("data:image/")
    assert isinstance(result["regions_of_interest"], list)


# =========================================================================
# 4. Yield Loss Regressor Tests
# =========================================================================

def test_yield_regressor_predictions(sample_features):
    """Verify yield loss regressor returns bounded predictions and economic metrics."""
    regressor = YieldLossRegressor()
    pred = regressor.predict(sample_features)

    assert pred["success"] is True
    assert 0.0 <= pred["yield_loss_pct"] <= 100.0
    assert 0.0 <= pred["salvageable_yield_pct"] <= 100.0
    assert np.isclose(pred["yield_loss_pct"] + pred["salvageable_yield_pct"], 100.0, atol=0.01)
    assert pred["loss_severity_tier"] in ["Negligible", "Moderate", "Severe", "Catastrophic"]
    assert pred["economic_loss_usd_ha"] >= 0.0


def test_yield_regressor_feature_importance():
    """Verify feature importances are non-empty, sum close to 1, and ranked."""
    regressor = YieldLossRegressor()
    importances = regressor.feature_importance()

    assert len(importances) == 7
    total_pct = sum(item["contribution_pct"] for item in importances)
    assert np.isclose(total_pct, 100.0, atol=2.0)
    # Ranked descending
    for i in range(len(importances) - 1):
        assert importances[i]["importance"] >= importances[i + 1]["importance"]


def test_yield_regressor_synthetic_data_evaluation():
    """Verify synthetic dataset generation and model evaluation metrics."""
    regressor = YieldLossRegressor()
    X_test, y_test = regressor.generate_synthetic_training_data(n=200, random_state=99)
    eval_res = regressor.evaluate(X_test, y_test)

    assert eval_res["mae"] >= 0.0
    assert eval_res["rmse"] >= 0.0
    assert eval_res["r2"] <= 1.0
    assert eval_res["test_samples"] == 200


# =========================================================================
# 5. Bayesian Trust Engine & Anomaly Detection Tests
# =========================================================================

def test_bayesian_trust_score_bounds(sample_evidence):
    """Verify trust score and confidence stay within [0, 1] across all 12 signals."""
    engine = BayesianTrustEngine()
    res = engine.calculate_trust(evidence_dict=sample_evidence)

    assert 0.0 <= res["score"] <= 1.0
    assert 0.0 <= res["confidence"] <= 1.0
    assert res["trust_level"] in [
        "Verified High Trust", "Moderate Trust", "Low Trust", "Flagged Anomalous"
    ]
    # Check all 12 signals present in breakdown
    for sig in Config.TRUST_SIGNALS:
        assert sig in res["evidence_breakdown"]
        sig_data = res["evidence_breakdown"][sig]
        assert 0.0 <= sig_data["posterior_mean"] <= 1.0


def test_anomaly_geospatial_teleportation():
    """Detect geospatial anomaly when client moves >100 km in <1 hr."""
    engine = BayesianTrustEngine()
    device = "test_sensor_geo"

    # Observation 1: Baseline location (e.g., Sacramento, CA: 38.5816, -121.4944)
    t0 = datetime.datetime.now(datetime.timezone.utc)
    obs1 = {
        "device_id": device,
        "latitude": 38.5816,
        "longitude": -121.4944,
        "timestamp": t0.isoformat()
    }
    flags1 = engine.detect_anomalies(obs1)
    assert len(flags1) == 0

    # Observation 2: 30 minutes later in Los Angeles (~550 km away)
    t1 = t0 + datetime.timedelta(minutes=30)
    obs2 = {
        "device_id": device,
        "latitude": 34.0522,
        "longitude": -118.2437,
        "timestamp": t1.isoformat()
    }
    flags2 = engine.detect_anomalies(obs2)
    assert any(f["type"] == "GEOSPATIAL_TELEPORTATION" for f in flags2)


def test_anomaly_excessive_scan_frequency():
    """Detect frequency flooding anomaly when submissions exceed 20 scans/hr."""
    engine = BayesianTrustEngine()
    device = "test_sensor_flood"
    base_time = datetime.datetime.now(datetime.timezone.utc)

    # Submit 22 scans within a 20-minute window
    detected = False
    for i in range(22):
        t = base_time + datetime.timedelta(minutes=i * 0.8)
        obs = {
            "device_id": device,
            "latitude": 40.0,
            "longitude": -75.0,
            "timestamp": t.isoformat()
        }
        flags = engine.detect_anomalies(obs)
        if any(f["type"] == "EXCESSIVE_SCAN_FREQUENCY" for f in flags):
            detected = True
            break

    assert detected is True


def test_anomaly_unexplained_severity_drop():
    """Detect biological anomaly when severity drops >30% in <24 hr without treatment."""
    engine = BayesianTrustEngine()
    device = "test_sensor_bio"
    t0 = datetime.datetime.now(datetime.timezone.utc)

    # Observation 1: Severe disease (55%)
    obs1 = {
        "device_id": device,
        "disease_severity": 0.55,
        "timestamp": t0.isoformat()
    }
    engine.detect_anomalies(obs1)

    # Observation 2: 12 hours later, drops to 10% without treatment
    t1 = t0 + datetime.timedelta(hours=12)
    obs2 = {
        "device_id": device,
        "disease_severity": 0.10,
        "treatment_applied": False,
        "timestamp": t1.isoformat()
    }
    flags = engine.detect_anomalies(obs2)
    assert any(f["type"] == "UNEXPLAINED_SEVERITY_DROP" for f in flags)


def test_bayesian_prior_updating():
    """Verify conjugate Beta updating increases alpha on positive outcome."""
    engine = BayesianTrustEngine()
    initial_alpha = engine.priors["image_quality"]["alpha"]
    engine.update_prior("image_quality", outcome=1.0)
    updated_alpha = engine.priors["image_quality"]["alpha"]

    assert updated_alpha > initial_alpha


# =========================================================================
# 6. Graceful Degradation & Fallback Tests
# =========================================================================

def test_detector_fallback_mode(sample_image):
    """Verify detector gracefully executes heuristic CV analysis when weights are missing."""
    detector = TomatoDiseaseDetector(weights_path="non_existent_weights.pt")
    assert detector.is_loaded is False

    res = detector.predict(sample_image)
    assert res["success"] is True
    assert "severity" in res
    assert 0.0 <= res["severity"]["score"] <= 1.0
    assert res["primary_condition"] in Config.DISEASE_CLASSES


def test_ai_service_unified_execution(sample_image, sample_features, sample_evidence):
    """Verify unified AI service pipeline runs all models and returns structured diagnosis."""
    ai = AIService.get_instance()
    res = ai.analyze_leaf(
        image=sample_image,
        metadata={
            "evidence": sample_evidence,
            "phenology_stage": "flowering",
            "audpc": 20.0
        }
    )

    assert res["success"] is True
    assert "detection" in res
    assert "explainability" in res
    assert "forecast" in res
    assert "yield_loss" in res
    assert "trust" in res
    assert "summary" in res
