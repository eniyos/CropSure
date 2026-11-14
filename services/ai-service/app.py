#!/usr/bin/env python3
"""
CropSure Microservice: AI Foliar Disease Diagnosis Service
Runs on port 8002.
Provides endpoint: POST /api/v1/ai/diagnose
"""

import os
import sys
from pathlib import Path

# Add project root to sys.path
PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from flask import Flask, request, jsonify
from flask_cors import CORS
from backend.app.services.ai_service import AIService
from backend.app.utils.image_utils import validate_image, load_image

app = Flask(__name__)
CORS(app)


def _extract_image():
    if "image" in request.files:
        file = request.files["image"]
        if file.filename != "":
            is_valid, err, _ = validate_image(file)
            if not is_valid:
                return None, f"Image validation failed: {err}"
            return file, None

    if request.is_json:
        data = request.get_json(silent=True) or {}
        if "image" in data and data["image"]:
            try:
                return load_image(data["image"]), None
            except Exception as e:
                return None, f"Failed to decode base64 image: {e}"

    if "image_base64" in request.form:
        try:
            return load_image(request.form["image_base64"]), None
        except Exception as e:
            return None, f"Failed to decode image_base64: {e}"

    return None, "No image supplied. Send multipart form 'image' or base64 JSON."


@app.route("/health", methods=["GET"])
@app.route("/api/v1/ai/health", methods=["GET"])
def health():
    return jsonify({
        "status": "healthy",
        "service": "CropSure AI Diagnosis Service",
        "port": 8002,
        "version": "1.0.0"
    }), 200


@app.route("/api/v1/ai/diagnose", methods=["POST"])
@app.route("/diagnose", methods=["POST"])
def diagnose():
    img, err = _extract_image()
    if err:
        return jsonify({"success": False, "error": err}), 400

    metadata = {}
    if request.is_json:
        metadata = (request.get_json() or {}).get("metadata", {})

    ai_service = AIService.get_instance()
    result = ai_service.analyze_leaf(
        image=img,
        metadata=metadata,
        include_gradcam=True,
        include_forecast=True,
        include_yield=True,
        include_trust=True
    )
    return jsonify(result), 200


if __name__ == "__main__":
    port = int(os.environ.get("AI_SERVICE_PORT", 8002))
    print(f"[CROPSURE AI-SERVICE] Starting standalone AI service on http://0.0.0.0:{port}...")
    app.run(host="0.0.0.0", port=port, debug=False)
