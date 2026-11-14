import datetime
import hashlib
import logging
import os
import time
from pathlib import Path
from PIL import Image

from backend.app.config import Config
from backend.app.utils.image_utils import validate_image, load_image

logger = logging.getLogger(__name__)


class DataService:
    """
    Data management and artifact caching service.
    Handles dataset loading, temporary upload lifecycles, and model asset verification.
    """

    def __init__(self, upload_dir=None, cache_dir=None):
        self.upload_dir = Path(upload_dir) if upload_dir else Config.UPLOAD_DIR
        self.data_dir = Config.DATA_DIR
        self.models_dir = Config.MODELS_DIR
        self.trajectory_cache = {}

        self.upload_dir.mkdir(parents=True, exist_ok=True)
        self.data_dir.mkdir(parents=True, exist_ok=True)

    def save_uploaded_image(self, file_storage, subfolder=None):
        """
        Validate and persist an incoming image upload with hash-based deduplication.

        Args:
            file_storage: Werkzeug FileStorage or file-like object.
            subfolder (str): Optional subfolder within upload directory.

        Returns:
            dict: File metadata including saved path, size, dimensions, and MD5 hash.
        """
        is_valid, err_msg, meta = validate_image(file_storage)
        if not is_valid:
            raise ValueError(f"Image validation failed: {err_msg}")

        dest_folder = self.upload_dir / subfolder if subfolder else self.upload_dir
        dest_folder.mkdir(parents=True, exist_ok=True)

        content = file_storage.read()
        file_hash = hashlib.md5(content).hexdigest()
        ext = meta.get("format", "jpg").lower()
        if ext == "jpeg":
            ext = "jpg"

        timestamp = int(time.time())
        filename = f"{timestamp}_{file_hash[:10]}.{ext}"
        target_path = dest_folder / filename

        with open(target_path, "wb") as f:
            f.write(content)

        file_storage.seek(0)

        return {
            "filename": filename,
            "path": str(target_path),
            "relative_path": str(target_path.relative_to(Config.BACKEND_DIR)),
            "hash": file_hash,
            "width": meta.get("width"),
            "height": meta.get("height"),
            "format": ext,
            "size_bytes": len(content)
        }

    def clean_old_uploads(self, max_age_hours=24):
        """
        Prune uploaded files older than max_age_hours to prevent disk saturation.

        Returns:
            int: Number of deleted files.
        """
        deleted_count = 0
        now = time.time()
        max_age_seconds = max_age_hours * 3600

        try:
            for file_path in self.upload_dir.glob("*.*"):
                if file_path.is_file():
                    age = now - file_path.stat().st_mtime
                    if age > max_age_seconds:
                        file_path.unlink()
                        deleted_count += 1
            logger.info(f"Cleaned {deleted_count} stale upload files.")
        except Exception as exc:
            logger.error(f"Error during upload cleaning: {exc}")

        return deleted_count

    def get_model_artifacts_status(self):
        """
        Inspect physical existence and sizes of all model artifacts on disk.

        Returns:
            dict: Artifact inventory with file sizes and presence flags.
        """
        artifacts = {
            "yolov8_weights": {
                "path": str(Config.YOLO_MODEL_PATH),
                "exists": Config.YOLO_MODEL_PATH.exists(),
                "size_mb": round(Config.YOLO_MODEL_PATH.stat().st_size / (1024 * 1024), 2)
                if Config.YOLO_MODEL_PATH.exists() else 0.0
            },
            "yolov8_onnx": {
                "path": str(Config.YOLO_ONNX_PATH),
                "exists": Config.YOLO_ONNX_PATH.exists(),
                "size_mb": round(Config.YOLO_ONNX_PATH.stat().st_size / (1024 * 1024), 2)
                if Config.YOLO_ONNX_PATH.exists() else 0.0
            },
            "lstm_weights": {
                "path": str(Config.LSTM_MODEL_PATH),
                "exists": Config.LSTM_MODEL_PATH.exists(),
                "size_mb": round(Config.LSTM_MODEL_PATH.stat().st_size / (1024 * 1024), 2)
                if Config.LSTM_MODEL_PATH.exists() else 0.0
            },
            "yield_rf_model": {
                "path": str(Config.YIELD_MODEL_PATH),
                "exists": Config.YIELD_MODEL_PATH.exists(),
                "size_mb": round(Config.YIELD_MODEL_PATH.stat().st_size / (1024 * 1024), 2)
                if Config.YIELD_MODEL_PATH.exists() else 0.0
            },
            "bayesian_trust_state": {
                "path": str(Config.TRUST_STATE_PATH),
                "exists": Config.TRUST_STATE_PATH.exists(),
                "size_kb": round(Config.TRUST_STATE_PATH.stat().st_size / 1024, 2)
                if Config.TRUST_STATE_PATH.exists() else 0.0
            }
        }
        return artifacts

    def cache_trajectory(self, trajectory_id, trajectory_data):
        """Cache epidemic trajectory in memory with LRU eviction."""
        if len(self.trajectory_cache) > 200:
            # Evict first key
            first_key = next(iter(self.trajectory_cache))
            del self.trajectory_cache[first_key]
        self.trajectory_cache[trajectory_id] = trajectory_data

    def get_cached_trajectory(self, trajectory_id):
        """Retrieve cached trajectory."""
        return self.trajectory_cache.get(trajectory_id)

    def get_reference_dataset_info(self):
        """
        Return reference metadata for supported crops, diseases, and epidemiology constants.
        """
        return {
            "crop": "Tomato (Solanum lycopersicum)",
            "supported_diseases_count": len(Config.DISEASE_CLASSES),
            "classes": Config.DISEASE_CLASSES,
            "disease_profiles": Config.DISEASE_METADATA,
            "climate_bounds": {
                "temp_c": {"min": 10.0, "opt": 24.0, "max": 36.0},
                "humidity_pct": {"min": 30.0, "opt": 85.0, "max": 100.0},
                "vpd_kpa": {"min": 0.4, "opt": 1.1, "max": 3.5}
            }
        }
