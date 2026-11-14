import os
from pathlib import Path


class Config:
    """Base application configuration."""

    # Project directories
    APP_DIR = Path(__file__).resolve().parent
    BACKEND_DIR = APP_DIR.parent
    PROJECT_ROOT = BACKEND_DIR.parent

    # File storage paths
    MODELS_DIR = PROJECT_ROOT / "models"
    DATA_DIR = PROJECT_ROOT / "data"
    UPLOAD_DIR = BACKEND_DIR / "uploads"
    STATIC_DIR = BACKEND_DIR / "static"

    # Ensure directories exist
    MODELS_DIR.mkdir(parents=True, exist_ok=True)
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

    # Flask application settings
    SECRET_KEY = os.environ.get("SECRET_KEY", "cropsure-production-in-memory-key-2026")
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16 MB max image upload
    ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "webp", "bmp"}

    # Compute device settings ('cuda' or 'cpu')
    DEVICE = "cpu"

    # Tomato Disease Classes (8 classes specified)
    DISEASE_CLASSES = [
        "Bacterial_spot",
        "Early_blight",
        "Late_blight",
        "Leaf_Mold",
        "Septoria_leaf_spot",
        "Spider_mites",
        "Target_Spot",
        "Healthy"
    ]

    DISEASE_METADATA = {
        "Bacterial_spot": {
            "pathogen": "Xanthomonas perforans / euvesicatoria",
            "type": "Bacterial",
            "optimal_temp_c": (24, 30),
            "humidity_threshold": 85,
            "recommended_treatment": "Copper-based bactericides, streptomycin, and certified clean seeds."
        },
        "Early_blight": {
            "pathogen": "Alternaria solani",
            "type": "Fungal",
            "optimal_temp_c": (24, 29),
            "humidity_threshold": 80,
            "recommended_treatment": "Chlorothalonil, mancozeb, or bio-fungicide Bacillus subtilis."
        },
        "Late_blight": {
            "pathogen": "Phytophthora infestans",
            "type": "Oomycete",
            "optimal_temp_c": (15, 22),
            "humidity_threshold": 90,
            "recommended_treatment": "Metalaxyl, cymoxanil, copper sulfate; eliminate cull piles immediately."
        },
        "Leaf_Mold": {
            "pathogen": "Passalora fulva (Cladosporium fulvum)",
            "type": "Fungal",
            "optimal_temp_c": (21, 24),
            "humidity_threshold": 85,
            "recommended_treatment": "Increase greenhouse ventilation, apply copper hydroxide or azoxystrobin."
        },
        "Septoria_leaf_spot": {
            "pathogen": "Septoria lycopersici",
            "type": "Fungal",
            "optimal_temp_c": (20, 25),
            "humidity_threshold": 80,
            "recommended_treatment": "Remove lower infected foliage, apply chlorothalonil, practice crop rotation."
        },
        "Spider_mites": {
            "pathogen": "Tetranychus urticae (Two-spotted spider mite)",
            "type": "Pest",
            "optimal_temp_c": (27, 35),
            "humidity_threshold": 40,
            "recommended_treatment": "Abamectin, insecticidal soaps, predatory mites (Phytoseiulus persimilis)."
        },
        "Target_Spot": {
            "pathogen": "Corynespora cassiicola",
            "type": "Fungal",
            "optimal_temp_c": (25, 32),
            "humidity_threshold": 85,
            "recommended_treatment": "Azoxystrobin, difenoconazole, avoid overhead irrigation."
        },
        "Healthy": {
            "pathogen": "None",
            "type": "Healthy Plant",
            "optimal_temp_c": (18, 28),
            "humidity_threshold": 60,
            "recommended_treatment": "Maintain balanced N-P-K fertilization and preventive scouting."
        }
    }

    # Model file locations
    YOLO_MODEL_PATH = MODELS_DIR / "yolov8s.pt"
    YOLO_ONNX_PATH = MODELS_DIR / "yolov8s.onnx"
    LSTM_MODEL_PATH = MODELS_DIR / "bilstm_forecaster.pt"
    YIELD_MODEL_PATH = MODELS_DIR / "yield_rf_regressor.joblib"
    TRUST_STATE_PATH = MODELS_DIR / "bayesian_trust_state.json"

    # LSTM Forecaster Hyperparameters
    LSTM_INPUT_SIZE = 7  # [severity, temp, humidity, rainfall, solar_rad, leaf_wetness, treatment_flag]
    LSTM_HIDDEN_SIZE = 128
    LSTM_NUM_LAYERS = 2
    LSTM_DROPOUT = 0.3
    LSTM_SEQ_LEN = 14
    LSTM_HORIZONS = [7, 14, 30]

    # Yield Regressor Hyperparameters
    YIELD_RF_ESTIMATORS = 200
    YIELD_RF_MAX_DEPTH = 12
    YIELD_FEATURES = [
        "audpc",
        "phenology_stage",
        "remediation_latency_days",
        "vpd",
        "disease_severity",
        "temp_avg",
        "humidity_avg"
    ]

    # Bayesian Trust Engine Parameters
    TRUST_SIGNALS = [
        "image_quality",
        "gps_consistency",
        "temporal_consistency",
        "disease_severity_plausibility",
        "weather_correlation",
        "historical_pattern",
        "device_fingerprint",
        "submission_frequency",
        "metadata_completeness",
        "expert_agreement",
        "cross_validation",
        "community_consensus"
    ]

    # Anomaly Detection Thresholds
    MAX_SPEED_KMH = 100.0             # > 100 km in < 1 hr
    MAX_SCANS_PER_HOUR = 20           # > 20 scans per hour
    MAX_SEVERITY_DROP_PER_DAY = 0.30  # > 30% drop in 24h without remediation


class DevelopmentConfig(Config):
    """Development environment configuration."""
    DEBUG = True
    TESTING = False


class TestingConfig(Config):
    """Testing environment configuration."""
    DEBUG = False
    TESTING = True
    UPLOAD_DIR = Config.BACKEND_DIR / "tests" / "test_uploads"


class ProductionConfig(Config):
    """Production environment configuration."""
    DEBUG = False
    TESTING = False


config_by_name = {
    "development": DevelopmentConfig,
    "testing": TestingConfig,
    "production": ProductionConfig,
    "default": DevelopmentConfig
}
