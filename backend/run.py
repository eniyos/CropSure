import os
import sys
from pathlib import Path

# Add project root and backend directory to sys.path
PROJECT_ROOT = Path(__file__).resolve().parent.parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

# Prevent OpenMP runtime library collision on Windows between PyTorch and OpenCV
os.environ["KMP_DUPLICATE_LIB_OK"] = "TRUE"
try:
    import torch
except Exception:
    pass

from backend.app import create_app

app = create_app(os.environ.get("FLASK_ENV", "development"))

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5005))
    host = os.environ.get("HOST", "0.0.0.0")
    debug = os.environ.get("FLASK_DEBUG", "True").lower() in ("true", "1", "t")

    print("=" * 60)
    print("  Starting CropSure Agricultural AI Backend Server")
    print(f"  Host: {host}:{port}")
    print(f"  Debug Mode: {debug}")
    print("=" * 60)

    app.run(host=host, port=port, debug=debug)
