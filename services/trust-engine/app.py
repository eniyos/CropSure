#!/usr/bin/env python3
"""
CropSure Microservice: Bayesian Crop Trust Engine Service
Runs on port 8003.
Provides endpoint: POST /api/v1/trust/calculate
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
from backend.app.config import Config

app = Flask(__name__)
CORS(app)


@app.route("/health", methods=["GET"])
@app.route("/api/v1/trust/health", methods=["GET"])
def health():
    return jsonify({
        "status": "healthy",
        "service": "CropSure Bayesian Trust Engine Service",
        "port": 8003,
        "version": "1.0.0"
    }), 200


@app.route("/api/v1/trust/calculate", methods=["POST"])
@app.route("/calculate", methods=["POST"])
def calculate_trust():
    payload = request.get_json(silent=True) or {}
    evidence = payload.get("evidence", {})
    observation = payload.get("observation", {})

    if not evidence:
        evidence = {k: v for k, v in payload.items() if k in Config.TRUST_SIGNALS}

    ai_service = AIService.get_instance()
    if not ai_service.trust_engine:
        return jsonify({"success": False, "error": "Trust engine not loaded"}), 503

    try:
        trust_res = ai_service.trust_engine.calculate_trust(
            evidence_dict=evidence,
            observation_meta=observation
        )
        return jsonify(trust_res), 200
    except Exception as exc:
        return jsonify({"success": False, "error": str(exc)}), 500


if __name__ == "__main__":
    port = int(os.environ.get("TRUST_SERVICE_PORT", 8003))
    print(f"[CROPSURE TRUST-ENGINE] Starting standalone Trust service on http://0.0.0.0:{port}...")
    app.run(host="0.0.0.0", port=port, debug=False)
