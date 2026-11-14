import json
import pytest


def test_api_health(client):
    """Test GET /api/health returns 200 and healthy status."""
    response = client.get("/api/health")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "healthy"
    assert "service" in data
    assert "version" in data


def test_api_models_status(client):
    """Test GET /api/models/status returns status for all 6 models."""
    response = client.get("/api/models/status")
    assert response.status_code == 200
    data = response.get_json()
    assert "models" in data
    assert "yolov8_detector" in data["models"]
    assert "vanderplank_simulator" in data["models"]
    assert "lstm_forecaster" in data["models"]
    assert "gradcam_engine" in data["models"]
    assert "yield_regressor" in data["models"]
    assert "bayesian_trust" in data["models"]
    assert "artifacts_inventory" in data


def test_api_epidemic_simulate(client):
    """Test GET /api/epidemic/simulate returns valid simulation trajectory."""
    response = client.get("/api/epidemic/simulate?days=45&initial_inoculum=0.02&infection_rate=0.30")
    assert response.status_code == 200
    data = response.get_json()
    assert data["success"] is True
    sim = data["simulation"]
    assert len(sim["days"]) == 46
    assert len(sim["severity_trajectory"]) == 46
    assert sim["audpc"] > 0.0


def test_api_epidemic_scenarios(client):
    """Test GET /api/epidemic/scenarios returns multi-scenario comparison data."""
    response = client.get("/api/epidemic/scenarios?days=60")
    assert response.status_code == 200
    data = response.get_json()
    assert data["success"] is True
    comp = data["comparison"]
    assert "baseline" in comp
    assert "favorable" in comp
    assert "unfavorable" in comp
    assert "treated" in comp
    assert "loss_reduction_pct" in comp


def test_api_forecast_endpoint(client, sample_history):
    """Test POST /api/forecast returns multi-horizon forecasts."""
    payload = {
        "history": sample_history,
        "horizons": [7, 14, 30],
        "mc_samples": 10
    }
    response = client.post(
        "/api/forecast",
        data=json.dumps(payload),
        content_type="application/json"
    )
    assert response.status_code == 200
    data = response.get_json()
    assert data["success"] is True
    assert "horizons" in data
    assert "day_7" in data["horizons"]


def test_api_yield_loss_endpoint(client, sample_features):
    """Test POST /api/yield-loss returns predicted yield reduction percentage."""
    response = client.post(
        "/api/yield-loss",
        data=json.dumps(sample_features),
        content_type="application/json"
    )
    assert response.status_code == 200
    data = response.get_json()
    assert data["success"] is True
    assert 0.0 <= data["yield_loss_pct"] <= 100.0
    assert "feature_importance" in data


def test_api_trust_endpoint(client, sample_evidence):
    """Test POST /api/trust evaluates Bayesian signals."""
    payload = {
        "evidence": sample_evidence,
        "observation": {
            "device_id": "api_test_sensor",
            "latitude": 37.7749,
            "longitude": -122.4194,
            "disease_severity": 0.15
        }
    }
    response = client.post(
        "/api/trust",
        data=json.dumps(payload),
        content_type="application/json"
    )
    assert response.status_code == 200
    data = response.get_json()
    assert 0.0 <= data["score"] <= 1.0
    assert "evidence_breakdown" in data


def test_api_detect_endpoint(client, sample_image_bytes):
    """Test POST /api/detect with multipart image upload."""
    data = {
        "image": (sample_image_bytes, "test_leaf.jpg")
    }
    response = client.post(
        "/api/detect",
        data=data,
        content_type="multipart/form-data"
    )
    assert response.status_code == 200
    res = response.get_json()
    assert res["success"] is True
    assert "detections" in res
    assert "severity" in res


def test_api_explain_endpoint(client, sample_image_bytes):
    """Test POST /api/explain returns Grad-CAM visual heatmap."""
    data = {
        "image": (sample_image_bytes, "test_leaf.jpg")
    }
    response = client.post(
        "/api/explain",
        data=data,
        content_type="multipart/form-data"
    )
    assert response.status_code == 200
    res = response.get_json()
    assert res["success"] is True
    assert res["overlay_base64"].startswith("data:image/")


def test_api_analyze_endpoint(client, sample_image_bytes):
    """Test POST /api/analyze runs unified multi-model pipeline."""
    data = {
        "image": (sample_image_bytes, "test_leaf.jpg"),
        "phenology_stage": "flowering",
        "latitude": "36.7783",
        "longitude": "-119.4179"
    }
    response = client.post(
        "/api/analyze",
        data=data,
        content_type="multipart/form-data"
    )
    assert response.status_code == 200
    res = response.get_json()
    assert res["success"] is True
    assert "detection" in res
    assert "explainability" in res
    assert "forecast" in res
    assert "yield_loss" in res
    assert "trust" in res
    assert "summary" in res


def test_error_handling_missing_image(client):
    """Test POST /api/detect returns 400 when image is omitted."""
    response = client.post("/api/detect", data={})
    assert response.status_code == 400
    data = response.get_json()
    assert data["success"] is False
    assert "error" in data


def test_error_handling_missing_forecast_history(client):
    """Test POST /api/forecast returns 400 when history is missing."""
    response = client.post(
        "/api/forecast",
        data=json.dumps({}),
        content_type="application/json"
    )
    assert response.status_code == 400
    data = response.get_json()
    assert data["success"] is False


def test_api_v1_compatibility_endpoints(client, sample_image_bytes):
    """Test compatibility endpoints /api/v1/ai/diagnose and /api/v1/trust/calculate."""
    # 1. Diagnose alias
    data = {
        "image": (sample_image_bytes, "test_leaf.jpg"),
        "latitude": "36.7783",
        "longitude": "-119.4179"
    }
    resp = client.post("/api/v1/ai/diagnose", data=data, content_type="multipart/form-data")
    assert resp.status_code == 200
    res = resp.get_json()
    assert res["success"] is True
    assert "detection" in res

    # 2. Trust calculate alias
    trust_payload = {
        "evidence": {
            "image_saliency_score": 0.92,
            "gps_geofence_valid": 1.0,
            "temporal_continuity": 0.88,
            "weather_correlation": 0.90
        }
    }
    resp_trust = client.post(
        "/api/v1/trust/calculate",
        data=json.dumps(trust_payload),
        content_type="application/json"
    )
    assert resp_trust.status_code == 200
    trust_data = resp_trust.get_json()
    score = trust_data.get("score") if "score" in trust_data else trust_data.get("trust_score")
    assert score is not None
    assert 0.0 <= score <= 1.0


def test_error_handling_not_found(client):
    """Test invalid route returns standard 404 JSON."""
    response = client.get("/api/non_existent_route")
    assert response.status_code == 404
    data = response.get_json()
    assert data["success"] is False
    assert data["status_code"] == 404
