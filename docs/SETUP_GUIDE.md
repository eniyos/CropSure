# CropSure — Platform Setup and Execution Guide

This guide describes how to run and verify the **CropSure** platform across development, test, and production environments.

---

## 1. Prerequisites

- **Python:** 3.10 or higher
- **Node.js:** v18 or higher (v24.x tested)
- **Package Managers:** `pip`, `npm`
- **Optional GPU:** NVIDIA CUDA 11.8+ / 12.x for accelerated inference on YOLOv8 & BiLSTM (CPU execution is fully supported out of the box).

---

## 2. Environment Setup

### A. Python Backend Setup

From the repository root (`c:\Users\HARINATH S\OneDrive\Desktop\agriculture`):

```bash
# 1. Install required Python packages
pip install -r requirements.txt

# Or install manually:
pip install flask flask-cors numpy pandas scikit-learn scipy matplotlib Pillow pytest joblib ultralytics onnx onnxscript
```

### B. Frontend Setup

From the `frontend` directory:

```bash
cd frontend
npm install
npm run build
```

---

## 3. Launching the CropSure Platform

### Launch Backend Server
In Terminal 1 (from repository root):
```bash
python backend/run.py
```
The Flask REST API will boot at `http://localhost:5000`.  
Health check endpoint: `http://localhost:5000/api/health`  
Model status inspection: `http://localhost:5000/api/models/status`

### Launch Frontend Dashboard
In Terminal 2 (from repository root):
```bash
cd frontend
npm run dev
```
The React 19 application will launch at `http://localhost:3000` with automated reverse-proxying of `/api` requests to `http://localhost:5000`.

---

## 4. Running the Automated Test Suite

To run all 30 automated integration and unit tests:

```bash
# Run pytest with concise tracebacks
python -m pytest backend/tests/ -v --tb=short
```

Expected result:
```text
30 passed in ~20-30s
```

---

## 5. Running the Jupyter Training Notebooks

All 6 training and research notebooks are in the `notebooks/` directory and can be executed via JupyterLab, VS Code, or uploaded to Google Colab:

| Notebook | Focus | Primary Output |
| :--- | :--- | :--- |
| `01_yolov8_training.ipynb` | YOLOv8s foliar pathology detection & ONNX export | `models/yolov8s.pt`, `models/yolov8s.onnx` |
| `02_van_der_plank_ode.ipynb` | Van der Plank delay-differential ODE simulation | `data/processed/vanderplank_synthetic_5k.csv` |
| `03_lstm_disease_progression.ipynb` | BiLSTM forecaster + Monte Carlo dropout uncertainty | `models/lstm_progression_model.pth` |
| `04_gradcam_explainability.ipynb` | Grad-CAM saliency extraction & ROI bounding | Saliency overlays & Base64 REST payloads |
| `05_random_forest_yield_regressor.ipynb` | Harvest yield-loss regression & feature rankings | `models/yield_regressor_rf.joblib` |
| `06_bayesian_trust_engine.ipynb` | Beta-conjugate updating & multi-modal fraud detection | `models/bayesian_trust_state.json` |

To start a Jupyter session locally:
```bash
pip install jupyterlab
jupyter lab notebooks/
```

---

## 6. Regenerating Model Artifacts Programmatically

To re-run the entire artifact pipeline and regenerate all models, datasets, and manifests:

```bash
python scripts/generate_all_artifacts.py
```
