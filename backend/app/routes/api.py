import datetime
import json
import logging
from flask import Blueprint, request, jsonify

from backend.app.services.ai_service import AIService
from backend.app.services.data_service import DataService
from backend.app.utils.image_utils import validate_image, load_image

logger = logging.getLogger(__name__)

api_bp = Blueprint("api", __name__)


def _extract_image_from_request():
    """
    Helper to extract image from either multipart form upload or JSON base64.
    Returns (PIL.Image or bytes, error_message)
    """
    # 1. Check multipart/form-data upload
    if "image" in request.files:
        file = request.files["image"]
        if file.filename == "":
            return None, "Empty filename provided in file upload."
        is_valid, err, meta = validate_image(file)
        if not is_valid:
            return None, f"Image file validation failed: {err}"
        return file, None

    # 2. Check JSON payload with base64 image
    if request.is_json:
        data = request.get_json(silent=True) or {}
        if "image" in data and data["image"]:
            try:
                img = load_image(data["image"])
                return img, None
            except Exception as exc:
                return None, f"Failed to decode base64 image: {str(exc)}"

    # 3. Check raw data in form fields
    if "image_base64" in request.form:
        try:
            img = load_image(request.form["image_base64"])
            return img, None
        except Exception as exc:
            return None, f"Failed to decode image_base64 from form: {str(exc)}"

    return None, "No image provided. Send as 'image' in multipart form or JSON body."


# =========================================================================
# 1. System Health & Model Status
# =========================================================================

@api_bp.route("/health", methods=["GET"])
def health():
    """Health check endpoint."""
    return jsonify({
        "status": "healthy",
        "service": "CropSure Agricultural AI Intelligence Platform",
        "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "version": "1.0.0"
    }), 200


@api_bp.route("/models/status", methods=["GET"])
def models_status():
    """Check loading and operational readiness of all 6 models."""
    ai_service = AIService.get_instance()
    data_service = DataService()

    status = ai_service.get_models_status()
    status["artifacts_inventory"] = data_service.get_model_artifacts_status()
    return jsonify(status), 200


# =========================================================================
# 2. Comprehensive Multi-Model Analysis Pipeline
# =========================================================================

@api_bp.route("/analyze", methods=["POST"])
@api_bp.route("/v1/ai/diagnose", methods=["POST"])
def analyze():
    """
    Unified multimodal leaf pathology diagnosis.
    Executes detection, Grad-CAM, forecasting, yield loss, and trust scoring.
    """
    image_input, err = _extract_image_from_request()
    if err:
        return jsonify({"success": False, "error": err}), 400

    # Extract optional metadata
    metadata = {}
    if request.is_json:
        body = request.get_json() or {}
        metadata = body.get("metadata", {})
        for key in ["device_id", "latitude", "longitude", "timestamp", "history", "audpc",
                    "phenology_stage", "remediation_latency_days", "vpd", "temp_avg", "humidity_avg"]:
            if key in body and key not in metadata:
                metadata[key] = body[key]
    else:
        # Check form data
        if "metadata" in request.form:
            try:
                metadata = json.loads(request.form["metadata"])
            except Exception:
                pass
        for key in ["device_id", "latitude", "longitude", "timestamp", "phenology_stage"]:
            if key in request.form and key not in metadata:
                val = request.form[key]
                if key in ["latitude", "longitude"]:
                    try:
                        val = float(val)
                    except ValueError:
                        pass
                metadata[key] = val

    # Feature toggles
    include_gradcam = request.args.get("gradcam", "true").lower() in ("true", "1", "yes")
    include_forecast = request.args.get("forecast", "true").lower() in ("true", "1", "yes")
    include_yield = request.args.get("yield", "true").lower() in ("true", "1", "yes")
    include_trust = request.args.get("trust", "true").lower() in ("true", "1", "yes")

    ai_service = AIService.get_instance()
    result = ai_service.analyze_leaf(
        image=image_input,
        metadata=metadata,
        include_gradcam=include_gradcam,
        include_forecast=include_forecast,
        include_yield=include_yield,
        include_trust=include_trust
    )

    return jsonify(result), 200


# =========================================================================
# 3. Dedicated Model Endpoints
# =========================================================================

@api_bp.route("/detect", methods=["POST"])
def detect():
    """Run YOLOv8 tomato foliar disease detection only."""
    image_input, err = _extract_image_from_request()
    if err:
        return jsonify({"success": False, "error": err}), 400

    ai_service = AIService.get_instance()
    if not ai_service.detector:
        return jsonify({"success": False, "error": "Detector service not initialized."}), 503

    conf_thresh = request.args.get("conf", default=None, type=float)
    iou_thresh = request.args.get("iou", default=None, type=float)

    try:
        detection_res = ai_service.detector.predict(
            image=image_input,
            conf_threshold=conf_thresh,
            iou_threshold=iou_thresh
        )
        return jsonify(detection_res), 200
    except Exception as exc:
        logger.error(f"Error in /detect: {exc}")
        return jsonify({"success": False, "error": str(exc)}), 500


@api_bp.route("/explain", methods=["POST"])
def explain():
    """Generate Grad-CAM visual heatmap explainability."""
    image_input, err = _extract_image_from_request()
    if err:
        return jsonify({"success": False, "error": err}), 400

    target_class = request.args.get("target_class", default=None, type=int)
    if target_class is None and request.is_json:
        target_class = (request.get_json() or {}).get("target_class")

    ai_service = AIService.get_instance()
    if not ai_service.gradcam:
        return jsonify({"success": False, "error": "Grad-CAM service not initialized."}), 503

    try:
        explanation_res = ai_service.gradcam.explain(image=image_input, target_class=target_class)
        return jsonify(explanation_res), 200
    except Exception as exc:
        logger.error(f"Error in /explain: {exc}")
        return jsonify({"success": False, "error": str(exc)}), 500


@api_bp.route("/forecast", methods=["POST"])
def forecast():
    """Generate BiLSTM disease progression forecast for 7, 14, and 30 day horizons."""
    payload = request.get_json(silent=True) or {}
    history = payload.get("history")

    if not history or not isinstance(history, list) or len(history) == 0:
        return jsonify({
            "success": False,
            "error": "Missing 'history' parameter. Provide list of historical severity readings or feature rows."
        }), 400

    horizons = payload.get("horizons", [7, 14, 30])
    mc_samples = int(payload.get("mc_samples", 30))

    ai_service = AIService.get_instance()
    if not ai_service.forecaster:
        return jsonify({"success": False, "error": "Forecasting service not initialized."}), 503

    try:
        forecast_res = ai_service.forecaster.predict(
            history=history,
            horizons=horizons,
            mc_samples=mc_samples
        )
        return jsonify(forecast_res), 200
    except Exception as exc:
        logger.error(f"Error in /forecast: {exc}")
        return jsonify({"success": False, "error": str(exc)}), 500


@api_bp.route("/yield-loss", methods=["POST"])
def yield_loss():
    """Predict crop yield loss percentage and economic impact."""
    payload = request.get_json(silent=True)
    if not payload or not isinstance(payload, dict):
        return jsonify({
            "success": False,
            "error": "Expected JSON payload containing agronomic features."
        }), 400

    features = payload.get("features", payload)
    expected_yield = float(payload.get("expected_yield_tons_ha", 65.0))
    market_price = float(payload.get("tomato_price_per_ton", 450.0))

    ai_service = AIService.get_instance()
    if not ai_service.yield_regressor:
        return jsonify({"success": False, "error": "Yield regressor service not initialized."}), 503

    try:
        yield_res = ai_service.yield_regressor.predict(
            features=features,
            expected_yield_tons_ha=expected_yield,
            tomato_price_per_ton=market_price
        )
        return jsonify(yield_res), 200
    except Exception as exc:
        logger.error(f"Error in /yield-loss: {exc}")
        return jsonify({"success": False, "error": str(exc)}), 500


@api_bp.route("/trust", methods=["POST"])
@api_bp.route("/v1/trust/calculate", methods=["POST"])
def trust():
    """Evaluate Bayesian trust across 12 signals and check for telemetry anomalies."""
    payload = request.get_json(silent=True) or {}
    evidence = payload.get("evidence", {})
    observation = payload.get("observation", {})

    # Flatten if top-level contains signals
    if not evidence:
        evidence = {k: v for k, v in payload.items() if k in ai_service_signals()}

    ai_service = AIService.get_instance()
    if not ai_service.trust_engine:
        return jsonify({"success": False, "error": "Bayesian trust service not initialized."}), 503

    try:
        trust_res = ai_service.trust_engine.calculate_trust(
            evidence_dict=evidence,
            observation_meta=observation
        )
        return jsonify(trust_res), 200
    except Exception as exc:
        logger.error(f"Error in /trust: {exc}")
        return jsonify({"success": False, "error": str(exc)}), 500


def ai_service_signals():
    from backend.app.config import Config
    return Config.TRUST_SIGNALS


# =========================================================================
# 4. Van der Plank Epidemic Simulation Endpoints
# =========================================================================

@api_bp.route("/epidemic/simulate", methods=["GET"])
def simulate_epidemic():
    """Run Van der Plank delay-differential epidemic simulation."""
    ai_service = AIService.get_instance()
    if not ai_service.simulator:
        return jsonify({"success": False, "error": "Epidemic simulator not initialized."}), 503

    try:
        days = request.args.get("days", default=90, type=int)
        y0 = request.args.get("initial_inoculum", default=0.01, type=float)
        rate = request.args.get("infection_rate", default=0.25, type=float)
        latent = request.args.get("latent_period", default=5, type=int)
        sporu = request.args.get("sporulation_period", default=14, type=int)
        temp = request.args.get("temp", default=24.0, type=float)
        humidity = request.args.get("humidity", default=85.0, type=float)
        precip = request.args.get("precipitation", default=5.0, type=float)

        sim_params = {
            "initial_inoculum": y0,
            "infection_rate": rate,
            "latent_period": latent,
            "sporulation_period": sporu,
            "temp": temp,
            "humidity": humidity,
            "precipitation": precip
        }

        result = ai_service.simulator.simulate(days=days, custom_params=sim_params)
        return jsonify({"success": True, "simulation": result}), 200
    except Exception as exc:
        logger.error(f"Error in /epidemic/simulate: {exc}")
        return jsonify({"success": False, "error": str(exc)}), 500


@api_bp.route("/epidemic/scenarios", methods=["GET"])
def compare_scenarios():
    """Compare Favorable, Unfavorable, Treated, and Untreated epidemiological scenarios."""
    ai_service = AIService.get_instance()
    if not ai_service.simulator:
        return jsonify({"success": False, "error": "Epidemic simulator not initialized."}), 503

    try:
        days = request.args.get("days", default=90, type=int)
        comparison = ai_service.simulator.compare_scenarios(days=days)
        return jsonify({"success": True, "comparison": comparison}), 200
    except Exception as exc:
        logger.error(f"Error in /epidemic/scenarios: {exc}")
        return jsonify({"success": False, "error": str(exc)}), 500


# =========================================================================
# 5. Farm, Crop & Auth Management Endpoints (CRUD)
# =========================================================================

import uuid
from pathlib import Path

DATA_STORE_DIR = Path(__file__).resolve().parent.parent.parent / "data"
DATA_STORE_DIR.mkdir(parents=True, exist_ok=True)
FARMS_FILE = DATA_STORE_DIR / "farms.json"
CROPS_FILE = DATA_STORE_DIR / "crops.json"


def _load_json_data(file_path, default_data):
    if file_path.exists():
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    return list(default_data)


def _save_json_data(file_path, data):
    try:
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
    except Exception as exc:
        logger.error(f"Failed to persist {file_path}: {exc}")


DEFAULT_FARMS = [
    {
        "id": "farm-001",
        "name": "Green Valley Estate",
        "location": "Nashik, Maharashtra",
        "area_hectares": 4.5,
        "notes": "Primary tomato and crop plots.",
        "created_at": "2026-10-01T10:00:00Z",
        "updated_at": "2026-11-01T10:00:00Z"
    }
]

DEFAULT_CROPS = [
    {
        "id": "crop-001",
        "farm_id": "farm-001",
        "farm_name": "Green Valley Estate",
        "crop_type": "Tomato",
        "variety": "Roma VF",
        "planting_date": "2026-09-15T00:00:00Z",
        "growth_stage": "fruiting",
        "health_status": "healthy",
        "area_hectares": 2.0,
        "trust_score": 88.0,
        "created_at": "2026-09-15T00:00:00Z"
    }
]


@api_bp.route("/v1/farms", methods=["GET", "POST"])
def manage_farms():
    farms = _load_json_data(FARMS_FILE, DEFAULT_FARMS)
    if request.method == "GET":
        return jsonify(farms), 200

    payload = request.get_json(silent=True) or request.form.to_dict() or {}
    farm_id = f"farm-{uuid.uuid4().hex[:8]}"
    new_farm = {
        "id": farm_id,
        "name": payload.get("name", "New Farm"),
        "location": payload.get("location", "Field Location"),
        "area_hectares": float(payload.get("area_hectares", 1.0)),
        "notes": payload.get("notes"),
        "created_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "updated_at": datetime.datetime.now(datetime.timezone.utc).isoformat()
    }
    farms.insert(0, new_farm)
    _save_json_data(FARMS_FILE, farms)
    return jsonify(new_farm), 201


@api_bp.route("/v1/farms/<farm_id>", methods=["GET", "PUT", "DELETE"])
def farm_detail(farm_id):
    farms = _load_json_data(FARMS_FILE, DEFAULT_FARMS)
    if request.method == "DELETE":
        farms = [f for f in farms if f["id"] != farm_id]
        _save_json_data(FARMS_FILE, farms)
        return jsonify({"success": True}), 200

    match = next((f for f in farms if f["id"] == farm_id), None)
    if not match:
        return jsonify({"error": "Farm not found"}), 404

    if request.method == "GET":
        return jsonify(match), 200

    payload = request.get_json(silent=True) or request.form.to_dict() or {}
    for k in ["name", "location", "notes"]:
        if k in payload:
            match[k] = payload[k]
    if "area_hectares" in payload:
        try:
            match["area_hectares"] = float(payload["area_hectares"])
        except ValueError:
            pass
    match["updated_at"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    _save_json_data(FARMS_FILE, farms)
    return jsonify(match), 200


@api_bp.route("/v1/crops", methods=["GET", "POST"])
def manage_crops():
    crops = _load_json_data(CROPS_FILE, DEFAULT_CROPS)
    if request.method == "GET":
        farm_id = request.args.get("farm_id")
        if farm_id:
            crops = [c for c in crops if c.get("farm_id") == farm_id]
        return jsonify(crops), 200

    payload = request.get_json(silent=True) or request.form.to_dict() or {}
    crop_id = f"crop-{uuid.uuid4().hex[:8]}"
    farms = _load_json_data(FARMS_FILE, DEFAULT_FARMS)
    farm_id = payload.get("farm_id", "farm-001")
    farm_match = next((f for f in farms if f["id"] == farm_id), None)
    farm_name = farm_match["name"] if farm_match else "Primary Farm"

    new_crop = {
        "id": crop_id,
        "farm_id": farm_id,
        "farm_name": farm_name,
        "crop_type": payload.get("crop_type", "Tomato"),
        "variety": payload.get("variety", "Roma VF"),
        "planting_date": payload.get("planting_date", datetime.datetime.now(datetime.timezone.utc).isoformat()),
        "growth_stage": payload.get("growth_stage", "vegetative"),
        "health_status": "healthy",
        "area_hectares": float(payload.get("area_hectares", 1.0)),
        "notes": payload.get("notes"),
        "trust_score": 85.0,
        "created_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "updated_at": datetime.datetime.now(datetime.timezone.utc).isoformat()
    }
    crops.insert(0, new_crop)
    _save_json_data(CROPS_FILE, crops)
    return jsonify(new_crop), 201


@api_bp.route("/v1/crops/<crop_id>", methods=["GET", "PUT", "DELETE"])
def crop_detail(crop_id):
    crops = _load_json_data(CROPS_FILE, DEFAULT_CROPS)
    if request.method == "DELETE":
        crops = [c for c in crops if c["id"] != crop_id]
        _save_json_data(CROPS_FILE, crops)
        return jsonify({"success": True}), 200

    match = next((c for c in crops if c["id"] == crop_id), None)
    if not match:
        return jsonify({"error": "Crop not found"}), 404

    if request.method == "GET":
        return jsonify(match), 200

    payload = request.get_json(silent=True) or request.form.to_dict() or {}
    for k in ["crop_type", "variety", "growth_stage", "health_status", "notes"]:
        if k in payload:
            match[k] = payload[k]
    match["updated_at"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    _save_json_data(CROPS_FILE, crops)
    return jsonify(match), 200


@api_bp.route("/v1/auth/login", methods=["POST"])
def auth_login():
    payload = request.get_json(silent=True) or request.form.to_dict() or {}
    return jsonify({
        "success": True,
        "token": "cropsure-jwt-demo-token-xyz",
        "user": {
            "id": "farmer-01",
            "full_name": "Ritesh Farmer",
            "email": payload.get("email", "farmer@cropsure.ai"),
            "role": "farmer"
        }
    }), 200


@api_bp.route("/v1/auth/register", methods=["POST"])
def auth_register():
    payload = request.get_json(silent=True) or request.form.to_dict() or {}
    return jsonify({
        "success": True,
        "token": "cropsure-jwt-demo-token-xyz",
        "user": {
            "id": f"farmer-{uuid.uuid4().hex[:6]}",
            "full_name": payload.get("full_name", "Farmer"),
            "email": payload.get("email", "farmer@cropsure.ai"),
            "role": "farmer"
        }
    }), 201


@api_bp.route("/v1/auth/logout", methods=["POST"])
def auth_logout():
    return jsonify({"success": True}), 200

