import io
import numpy as np
import pytest
from PIL import Image, ImageDraw

from backend.app import create_app
from backend.app.config import Config


@pytest.fixture(scope="session")
def app():
    """Create and configure a Flask application instance for testing."""
    test_app = create_app("testing")
    test_app.config.update({
        "TESTING": True,
        "SECRET_KEY": "test-key-cropsure",
        "DEVICE": "cpu"
    })
    yield test_app


@pytest.fixture(scope="session")
def client(app):
    """A test client for the application."""
    return app.test_client()


@pytest.fixture
def sample_image():
    """
    Generate a synthetic foliar RGB image.
    Features green leaf tissue with an irregular brown necrotic lesion in the center.
    """
    width, height = 256, 256
    # Foliage green base
    img = Image.new("RGB", (width, height), color=(45, 130, 45))
    draw = ImageDraw.Draw(img)

    # Draw irregular brown/yellow necrotic lesion spot in the center
    draw.ellipse([80, 80, 160, 160], fill=(120, 60, 20), outline=(190, 170, 40), width=4)
    # Secondary spot
    draw.ellipse([170, 150, 210, 190], fill=(100, 50, 15), outline=(180, 160, 30), width=2)

    return img


@pytest.fixture
def sample_image_bytes(sample_image):
    """Return in-memory JPEG bytes of the sample synthetic leaf."""
    buf = io.BytesIO()
    sample_image.save(buf, format="JPEG", quality=90)
    buf.seek(0)
    return buf


@pytest.fixture
def sample_features():
    """Valid agronomic features dictionary for yield loss prediction."""
    return {
        "audpc": 28.5,
        "phenology_stage": "flowering",
        "remediation_latency_days": 4.5,
        "vpd": 1.45,
        "disease_severity": 0.18,
        "temp_avg": 25.2,
        "humidity_avg": 82.0,
        "expected_yield_tons_ha": 65.0,
        "tomato_price_per_ton": 450.0
    }


@pytest.fixture
def sample_evidence():
    """Comprehensive dictionary containing all 12 Bayesian trust signals."""
    return {
        "image_quality": 0.88,
        "gps_consistency": 0.95,
        "temporal_consistency": 0.90,
        "disease_severity_plausibility": 0.85,
        "weather_correlation": 0.92,
        "historical_pattern": 0.84,
        "device_fingerprint": 0.89,
        "submission_frequency": 0.94,
        "metadata_completeness": 0.96,
        "expert_agreement": 0.91,
        "cross_validation": 0.87,
        "community_consensus": 0.86
    }


@pytest.fixture
def sample_history():
    """14-day progressive disease severity time series for forecasting."""
    # Gradual progression from 1% to 12%
    return [0.010, 0.012, 0.015, 0.019, 0.024, 0.030, 0.038,
            0.048, 0.059, 0.071, 0.084, 0.098, 0.112, 0.125]
