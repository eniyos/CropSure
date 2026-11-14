import logging
import os
import sys

# Prevent OpenMP runtime library collision on Windows between PyTorch and OpenCV
os.environ["KMP_DUPLICATE_LIB_OK"] = "TRUE"
try:
    import torch
except Exception:
    pass

from flask import Flask, jsonify
from flask_cors import CORS
from backend.app.config import Config, config_by_name


def create_app(config_name=None):
    """
    Application factory for CropSure Flask backend.
    
    Args:
        config_name (str or class): Configuration environment name ('development', 'testing', 'production')
                                    or a direct Config class.
    
    Returns:
        Flask: Initialized Flask application.
    """
    app = Flask(__name__)

    # Determine configuration class
    if config_name is None:
        config_name = os.environ.get("FLASK_ENV", "development")

    if isinstance(config_name, str):
        config_class = config_by_name.get(config_name, Config)
    else:
        config_class = config_name

    app.config.from_object(config_class)

    # Configure logging
    log_level = logging.DEBUG if app.config.get("DEBUG") else logging.INFO
    logging.basicConfig(
        level=log_level,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
    )
    app.logger.setLevel(log_level)

    # Ensure critical directory structures exist
    for dir_path in [
        app.config.get("MODELS_DIR"),
        app.config.get("DATA_DIR"),
        app.config.get("UPLOAD_DIR")
    ]:
        if dir_path:
            dir_path.mkdir(parents=True, exist_ok=True)

    # Enable Cross-Origin Resource Sharing (CORS)
    CORS(
        app,
        resources={r"/api/*": {"origins": "*"}},
        supports_credentials=True,
        allow_headers=["Content-Type", "Authorization", "X-Requested-With"],
        methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    )

    # Register Blueprints
    from backend.app.routes.api import api_bp
    app.register_blueprint(api_bp, url_prefix="/api")

    # Global Error Handlers returning structured JSON
    @app.errorhandler(400)
    def bad_request(error):
        return jsonify({
            "success": False,
            "error": "Bad Request",
            "message": getattr(error, "description", str(error)),
            "status_code": 400
        }), 400

    @app.errorhandler(404)
    def not_found(error):
        return jsonify({
            "success": False,
            "error": "Not Found",
            "message": "The requested API route was not found on this server.",
            "status_code": 404
        }), 404

    @app.errorhandler(413)
    def request_entity_too_large(error):
        max_mb = app.config.get("MAX_CONTENT_LENGTH", 16 * 1024 * 1024) / (1024 * 1024)
        return jsonify({
            "success": False,
            "error": "Payload Too Large",
            "message": f"Image file exceeds maximum allowable size limit of {max_mb:.0f} MB.",
            "status_code": 413
        }), 413

    @app.errorhandler(500)
    def internal_server_error(error):
        app.logger.error(f"Internal Server Error: {error}")
        return jsonify({
            "success": False,
            "error": "Internal Server Error",
            "message": "An unexpected error occurred during analysis processing.",
            "status_code": 500
        }), 500

    @app.errorhandler(Exception)
    def unhandled_exception(error):
        app.logger.exception(f"Unhandled Exception encountered: {error}")
        return jsonify({
            "success": False,
            "error": "Internal Server Error",
            "message": str(error),
            "status_code": 500
        }), 500

    return app
