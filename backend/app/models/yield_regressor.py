import logging
from pathlib import Path
import joblib
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor

from backend.app.config import Config
from backend.app.utils.metrics import (
    calculate_mae,
    calculate_rmse,
    calculate_r2,
    calculate_mape
)

logger = logging.getLogger(__name__)


class YieldLossRegressor:
    """
    Random Forest Agronomic Yield-Loss Regressor.
    Predicts percentage harvest reduction from AUDPC, phenological growth stage,
    remediation delay, microclimate VPD, and disease severity.
    """

    PHENOLOGY_MAP = {
        "vegetative": 0,
        "flowering": 1,
        "fruit_development": 2,
        "ripening": 3
    }

    FEATURE_NAMES = [
        "audpc",
        "phenology_stage",
        "remediation_latency_days",
        "vpd",
        "disease_severity",
        "temp_avg",
        "humidity_avg"
    ]

    def __init__(self, model_path=None, n_estimators=200, max_depth=12):
        self.model_path = Path(model_path) if model_path else Config.YIELD_MODEL_PATH
        self.n_estimators = n_estimators
        self.max_depth = max_depth
        self.model = RandomForestRegressor(
            n_estimators=self.n_estimators,
            max_depth=self.max_depth,
            min_samples_split=4,
            random_state=42,
            n_jobs=-1
        )
        self.is_trained = False

        # Attempt to load model or train initial baseline
        if self.model_path.exists():
            self.load_model(self.model_path)
        else:
            self._fit_baseline_synthetic()

    def _fit_baseline_synthetic(self):
        """Fit initial model weights using synthetic agronomic dataset."""
        logger.info("Initializing YieldLossRegressor with synthetic agronomic training baseline...")
        X, y = self.generate_synthetic_training_data(n=2500)
        self.train(X, y)
        try:
            self.save_model(self.model_path)
        except Exception as exc:
            logger.warning(f"Could not persist initial yield model checkpoint: {exc}")

    def generate_synthetic_training_data(self, n=2000, random_state=42):
        """
        Generate realistic agronomic training data based on established plant pathology principles.

        Args:
            n (int): Sample count.
            random_state (int): Seed for reproducibility.

        Returns:
            tuple (pd.DataFrame, np.ndarray): X features and y yield_loss_pct.
        """
        rng = np.random.RandomState(random_state)

        audpc = rng.uniform(0.0, 75.0, n)
        phenology = rng.choice([0, 1, 2, 3], size=n, p=[0.20, 0.35, 0.35, 0.10])
        latency = rng.exponential(scale=5.0, size=n)
        latency = np.clip(latency, 0.0, 30.0)
        vpd = rng.uniform(0.6, 3.8, n)
        severity = rng.beta(a=1.5, b=3.5, size=n)  # Skewed toward realistic early/mid severity
        temp_avg = rng.uniform(16.0, 34.0, n)
        humidity_avg = rng.uniform(40.0, 95.0, n)

        # Agronomic yield loss formula:
        # Base loss driven by AUDPC and current severity
        base_loss = 35.0 * (audpc / 75.0) + 25.0 * severity

        # Phenological vulnerability weights:
        # Flowering (1.3x) and Fruit Dev (1.4x) are critically vulnerable compared to vegetative (0.75x)
        stage_multipliers = np.array([0.75, 1.30, 1.40, 0.60])
        pheno_factor = stage_multipliers[phenology]

        # Latency penalty: delayed treatment compounds damage
        latency_penalty = 1.15 * latency * (1.0 + severity)

        # Vapor Pressure Deficit (VPD) stress factor
        # Ideal VPD is 0.8 - 1.2 kPa; high VPD (>2.0) exacerbates water stress on damaged vascular tissue
        vpd_stress = np.where(vpd > 2.0, (vpd - 2.0) * 4.0, 0.0)

        # Extreme temperature stress (>30°C)
        heat_stress = np.maximum(0.0, (temp_avg - 28.0) * 1.2)

        # Combined loss with stochastic environmental noise
        noise = rng.normal(0.0, 2.0, n)
        total_loss = (base_loss * pheno_factor) + latency_penalty + vpd_stress + heat_stress + noise

        # Clamp strictly between 0% and 100%
        yield_loss_pct = np.clip(total_loss, 0.0, 100.0)

        X = pd.DataFrame({
            "audpc": np.round(audpc, 2),
            "phenology_stage": phenology,
            "remediation_latency_days": np.round(latency, 1),
            "vpd": np.round(vpd, 2),
            "disease_severity": np.round(severity, 4),
            "temp_avg": np.round(temp_avg, 1),
            "humidity_avg": np.round(humidity_avg, 1)
        })

        return X, yield_loss_pct

    def _normalize_features(self, features):
        """Standardize feature input into proper pandas DataFrame format."""
        if isinstance(features, dict):
            data = dict(features)
            # Map string phenology stage to integer if provided as text
            if "phenology_stage" in data and isinstance(data["phenology_stage"], str):
                p_key = data["phenology_stage"].strip().lower()
                data["phenology_stage"] = self.PHENOLOGY_MAP.get(p_key, 1)

            # Ensure all required columns are present with sensible defaults
            defaults = {
                "audpc": 15.0,
                "phenology_stage": 1,
                "remediation_latency_days": 3.0,
                "vpd": 1.2,
                "disease_severity": 0.15,
                "temp_avg": 24.0,
                "humidity_avg": 75.0
            }
            row = {}
            for col in self.FEATURE_NAMES:
                row[col] = float(data.get(col, defaults[col]))
            return pd.DataFrame([row])

        elif isinstance(features, pd.DataFrame):
            df = features.copy()
            if "phenology_stage" in df.columns and df["phenology_stage"].dtype == object:
                df["phenology_stage"] = df["phenology_stage"].str.lower().map(self.PHENOLOGY_MAP).fillna(1)
            return df[self.FEATURE_NAMES]

        elif isinstance(features, (np.ndarray, list)):
            arr = np.asarray(features)
            if arr.ndim == 1:
                arr = arr.reshape(1, -1)
            return pd.DataFrame(arr, columns=self.FEATURE_NAMES[:arr.shape[1]])

        raise ValueError(f"Unsupported features type: {type(features)}")

    def train(self, X, y):
        """
        Fit RandomForestRegressor on training dataset.

        Args:
            X (pd.DataFrame or np.ndarray): Feature matrix.
            y (np.ndarray or list): Target yield loss percentages.

        Returns:
            dict: Model evaluation summary on training set.
        """
        X_df = self._normalize_features(X)
        y_arr = np.clip(np.asarray(y, dtype=np.float64), 0.0, 100.0)

        self.model.fit(X_df, y_arr)
        self.is_trained = True

        train_preds = self.model.predict(X_df)
        train_preds = np.clip(train_preds, 0.0, 100.0)

        metrics = {
            "mae": round(calculate_mae(y_arr, train_preds), 3),
            "rmse": round(calculate_rmse(y_arr, train_preds), 3),
            "r2": round(calculate_r2(y_arr, train_preds), 3),
            "samples_count": len(y_arr)
        }
        logger.info(f"YieldLossRegressor fitted successfully: R^2={metrics['r2']}, MAE={metrics['mae']}")
        return metrics

    def predict(self, features, expected_yield_tons_ha=65.0, tomato_price_per_ton=450.0):
        """
        Predict yield loss percentage and economic loss estimation.

        Args:
            features: Feature dictionary, DataFrame, or array.
            expected_yield_tons_ha (float): Baseline healthy yield (metric tons/ha).
            tomato_price_per_ton (float): Market value per metric ton in USD.

        Returns:
            dict: Predicted yield loss %, salvageable yield, economic loss, and impact tier.
        """
        if not self.is_trained:
            self._fit_baseline_synthetic()

        X_df = self._normalize_features(features)
        raw_pred = self.model.predict(X_df)
        loss_pct = float(np.clip(raw_pred[0], 0.0, 100.0))

        # Calculate loss in biomass and revenue
        salvageable_ratio = (100.0 - loss_pct) / 100.0
        salvageable_tons_ha = expected_yield_tons_ha * salvageable_ratio
        lost_tons_ha = expected_yield_tons_ha * (loss_pct / 100.0)
        economic_loss_usd_ha = lost_tons_ha * tomato_price_per_ton

        # Impact tier classification
        if loss_pct < 8.0:
            tier = "Negligible"
            advice = "Routine foliar maintenance sufficient; normal harvest expected."
        elif loss_pct < 22.0:
            tier = "Moderate"
            advice = "Targeted remediation recommended within 48 hours to preserve marketable grade."
        elif loss_pct < 45.0:
            tier = "Severe"
            advice = "High economic risk. Aggressive therapeutic action required immediately."
        else:
            tier = "Catastrophic"
            advice = "Substantial harvest loss unavoidable. Focus on containment to adjacent plots."

        return {
            "success": True,
            "yield_loss_pct": round(loss_pct, 2),
            "loss_severity_tier": tier,
            "salvageable_yield_pct": round(100.0 - loss_pct, 2),
            "salvageable_yield_tons_ha": round(salvageable_tons_ha, 2),
            "lost_yield_tons_ha": round(lost_tons_ha, 2),
            "economic_loss_usd_ha": round(economic_loss_usd_ha, 2),
            "recommendation": advice,
            "features_used": X_df.iloc[0].to_dict(),
            "feature_importance": self.feature_importance()
        }

    def feature_importance(self):
        """
        Calculate sorted feature importances.

        Returns:
            list: List of dicts with feature names, importance scores, and percentages.
        """
        if not self.is_trained or not hasattr(self.model, "feature_importances_"):
            return []

        importances = self.model.feature_importances_
        records = []
        for feat, imp in zip(self.FEATURE_NAMES, importances):
            records.append({
                "feature": feat,
                "importance": round(float(imp), 4),
                "contribution_pct": round(float(imp) * 100.0, 2)
            })

        records.sort(key=lambda x: x["importance"], reverse=True)
        for rank, rec in enumerate(records, start=1):
            rec["rank"] = rank

        return records

    def evaluate(self, X_test, y_test):
        """
        Evaluate model against an independent test set.

        Returns:
            dict: Evaluation metrics (MAE, RMSE, R2, MAPE).
        """
        X_df = self._normalize_features(X_test)
        y_true = np.asarray(y_test, dtype=np.float64)
        y_pred = np.clip(self.model.predict(X_df), 0.0, 100.0)

        return {
            "mae": round(calculate_mae(y_true, y_pred), 3),
            "rmse": round(calculate_rmse(y_true, y_pred), 3),
            "r2": round(calculate_r2(y_true, y_pred), 3),
            "mape": round(calculate_mape(y_true, y_pred), 2),
            "test_samples": len(y_true)
        }

    def save_model(self, path=None):
        """Serialize model to disk via joblib."""
        target_path = Path(path) if path else self.model_path
        target_path.parent.mkdir(parents=True, exist_ok=True)
        joblib.dump(self.model, str(target_path))
        logger.info(f"YieldLossRegressor saved to {target_path}")
        return str(target_path)

    def load_model(self, path=None):
        """Deserialize model from disk via joblib."""
        target_path = Path(path) if path else self.model_path
        if not target_path.exists():
            logger.warning(f"Model path {target_path} does not exist.")
            return False

        try:
            self.model = joblib.load(str(target_path))
            self.is_trained = True
            logger.info(f"YieldLossRegressor successfully loaded from {target_path}")
            return True
        except Exception as exc:
            logger.error(f"Error loading YieldLossRegressor: {exc}")
            return False
