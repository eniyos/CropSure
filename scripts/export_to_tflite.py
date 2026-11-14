#!/usr/bin/env python3
"""
CropSure - Model Export, TFLite Conversion, and Numerical Parity Verification
Exports PyTorch ResNet-18 Tomato Pathology Classifier to ONNX and TensorFlow Lite.
Evaluates numerical parity (PyTorch vs TFLite) across real leaf samples and measures latency.
"""

import os
import sys
import time
import json
import subprocess
from pathlib import Path

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

import numpy as np
import torch
import torch.nn as nn
from torchvision import transforms
from torchvision.models import resnet18
from PIL import Image

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from backend.app.config import Config

MODELS_DIR = PROJECT_ROOT / "models"
TFLITE_DIR = MODELS_DIR / "tflite"
TFLITE_DIR.mkdir(parents=True, exist_ok=True)

# Also ensure ml-pipeline/models/tflite exists as requested
ML_PIPELINE_TFLITE = PROJECT_ROOT / "ml-pipeline" / "models" / "tflite"
ML_PIPELINE_TFLITE.mkdir(parents=True, exist_ok=True)

PYTORCH_MODEL_PATH = MODELS_DIR / "tomato_disease_classifier.pth"
ONNX_MODEL_PATH = MODELS_DIR / "tomato_classifier.onnx"
TFLITE_MODEL_PATH = TFLITE_DIR / "tomato_classifier.tflite"
LABELS_PATH = TFLITE_DIR / "labels.txt"

CLASSES = Config.DISEASE_CLASSES


def build_pytorch_model():
    """Rebuild PyTorch ResNet-18 model architecture and load weights."""
    print(f"[1/5] Loading PyTorch model from {PYTORCH_MODEL_PATH}...", flush=True)
    model = resnet18(weights=None)
    num_features = model.fc.in_features
    model.fc = nn.Sequential(
        nn.Dropout(0.3),
        nn.Linear(num_features, len(CLASSES))
    )
    checkpoint = torch.load(str(PYTORCH_MODEL_PATH), map_location="cpu")
    if "model_state_dict" in checkpoint:
        model.load_state_dict(checkpoint["model_state_dict"])
    else:
        model.load_state_dict(checkpoint)
    model.eval()
    return model


def export_to_onnx(model):
    """Export PyTorch model to ONNX format with fixed input shape [1, 3, 224, 224]."""
    print(f"[2/5] Exporting PyTorch model to ONNX: {ONNX_MODEL_PATH}...", flush=True)
    dummy_input = torch.randn(1, 3, 224, 224, dtype=torch.float32)
    torch.onnx.export(
        model,
        dummy_input,
        str(ONNX_MODEL_PATH),
        export_params=True,
        opset_version=18,
        do_constant_folding=True,
        input_names=["input"],
        output_names=["output"],
        dynamic_axes=None  # Fixed batch size 1 for optimal mobile TFLite conversion
    )
    print(f"      ONNX export successful: {ONNX_MODEL_PATH.stat().st_size / (1024*1024):.2f} MB", flush=True)


def convert_onnx_to_tflite():
    """Convert ONNX model to TensorFlow Lite using onnx2tf."""
    print(f"[3/5] Converting ONNX model to TensorFlow Lite using onnx2tf...", flush=True)
    output_dir = TFLITE_DIR / "onnx2tf_out"
    output_dir.mkdir(parents=True, exist_ok=True)

    import shutil
    import onnx2tf.onnx2tf as o2t
    import onnx2tf.utils.common_functions as cf

    mock = lambda: np.zeros((1, 3, 224, 224), dtype=np.float32)
    o2t.download_test_image_data = mock
    cf.download_test_image_data = mock

    float32_src = output_dir / "tomato_classifier_float32.tflite"
    float16_src = output_dir / "tomato_classifier_float16.tflite"

    if not float32_src.exists():
        o2t.convert(
            input_onnx_file_path=str(ONNX_MODEL_PATH),
            output_folder_path=str(output_dir),
            not_use_onnxsim=True,
            check_onnx_tf_outputs_elementwise_close=False
        )
    
    if float32_src.exists():
        shutil.copy2(str(float32_src), str(TFLITE_MODEL_PATH))
        shutil.copy2(str(float32_src), str(ML_PIPELINE_TFLITE / "tomato_classifier.tflite"))
        if float16_src.exists():
            shutil.copy2(str(float16_src), str(TFLITE_DIR / "tomato_classifier_quant_fp16.tflite"))
            shutil.copy2(str(float16_src), str(ML_PIPELINE_TFLITE / "tomato_classifier_quant_fp16.tflite"))
        print(f"      TFLite saved to {TFLITE_MODEL_PATH} ({TFLITE_MODEL_PATH.stat().st_size / (1024*1024):.2f} MB)", flush=True)
        return True
    else:
        print("[ERROR] float32 TFLite output not found.", flush=True)
        return False


def save_labels():
    """Save label dictionary to labels.txt."""
    print(f"[4/5] Saving labels to {LABELS_PATH}...", flush=True)
    with open(LABELS_PATH, "w", encoding="utf-8") as f:
        for c in CLASSES:
            f.write(f"{c}\n")
    # Also copy to ml-pipeline
    with open(ML_PIPELINE_TFLITE / "labels.txt", "w", encoding="utf-8") as f:
        for c in CLASSES:
            f.write(f"{c}\n")


def verify_numerical_parity(pytorch_model):
    """
    Execute parity test comparing PyTorch output against TFLite output on real sample images.
    Measures Mean Absolute Error, Cosine Similarity, and Top-1 Prediction Agreement.
    """
    print(f"[5/5] Running numerical parity and latency validation...", flush=True)
    import tensorflow as tf

    # Load TFLite interpreter
    interpreter = tf.lite.Interpreter(model_path=str(TFLITE_MODEL_PATH))
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    input_shape = input_details[0]['shape']
    print(f"      TFLite Input Details: shape={input_shape}, dtype={input_details[0]['dtype']}", flush=True)
    print(f"      TFLite Output Details: shape={output_details[0]['shape']}, dtype={output_details[0]['dtype']}", flush=True)

    # Standard PyTorch normalization
    preprocess = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])

    samples_dir = PROJECT_ROOT / "frontend" / "public" / "samples"
    sample_files = list(samples_dir.glob("*.jpg")) + list(samples_dir.glob("*.png"))

    parity_results = []
    latencies_ms = []

    for img_path in sample_files:
        img = Image.open(img_path).convert("RGB")
        tensor_input = preprocess(img).unsqueeze(0)  # [1, 3, 224, 224]

        # 1. PyTorch inference
        with torch.no_grad():
            pytorch_logits = pytorch_model(tensor_input).numpy()[0]
            pytorch_probs = torch.softmax(torch.tensor(pytorch_logits), dim=-1).numpy()
            pytorch_top1_idx = int(np.argmax(pytorch_probs))
            pytorch_top1_class = CLASSES[pytorch_top1_idx]

        # 2. TFLite inference
        # Check input tensor layout: NCHW or NHWC
        if input_shape[1] == 3:  # NCHW
            tflite_in = tensor_input.numpy()
        else:  # NHWC
            tflite_in = np.transpose(tensor_input.numpy(), (0, 2, 3, 1))

        t0 = time.perf_counter()
        interpreter.set_tensor(input_details[0]['index'], tflite_in)
        interpreter.invoke()
        t1 = time.perf_counter()
        latencies_ms.append((t1 - t0) * 1000.0)

        tflite_raw = interpreter.get_tensor(output_details[0]['index'])[0]
        # If output is raw logits, compute softmax
        if np.max(tflite_raw) > 1.0 or np.min(tflite_raw) < 0.0 or not np.isclose(np.sum(tflite_raw), 1.0, atol=1e-2):
            tflite_probs = np.exp(tflite_raw - np.max(tflite_raw))
            tflite_probs /= np.sum(tflite_probs)
        else:
            tflite_probs = tflite_raw

        tflite_top1_idx = int(np.argmax(tflite_probs))
        tflite_top1_class = CLASSES[tflite_top1_idx]

        # Metrics
        abs_diff = np.abs(pytorch_probs - tflite_probs)
        max_abs_err = float(np.max(abs_diff))
        mean_abs_err = float(np.mean(abs_diff))
        cos_sim = float(np.dot(pytorch_probs, tflite_probs) / (np.linalg.norm(pytorch_probs) * np.linalg.norm(tflite_probs)))
        agreement = (pytorch_top1_idx == tflite_top1_idx)

        parity_results.append({
            "image": img_path.name,
            "pytorch_pred": pytorch_top1_class,
            "pytorch_conf": float(pytorch_probs[pytorch_top1_idx]),
            "tflite_pred": tflite_top1_class,
            "tflite_conf": float(tflite_probs[tflite_top1_idx]),
            "agreement": bool(agreement),
            "max_abs_err": max_abs_err,
            "mean_abs_err": mean_abs_err,
            "cosine_similarity": cos_sim
        })

        print(f"      [{img_path.name}] Agreement={agreement} | PyTorch: {pytorch_top1_class} ({pytorch_probs[pytorch_top1_idx]:.3f}) | TFLite: {tflite_top1_class} ({tflite_probs[tflite_top1_idx]:.3f}) | CosSim={cos_sim:.5f}", flush=True)

    # Summary
    avg_latency = float(np.mean(latencies_ms))
    p95_latency = float(np.percentile(latencies_ms, 95))
    agreements = [r["agreement"] for r in parity_results]
    agreement_rate = float(np.mean(agreements)) * 100.0
    avg_cos_sim = float(np.mean([r["cosine_similarity"] for r in parity_results]))
    avg_max_err = float(np.mean([r["max_abs_err"] for r in parity_results]))

    summary = {
        "model": "ResNet-18 Tomato Foliar Pathology Classifier",
        "tflite_file": str(TFLITE_MODEL_PATH.relative_to(PROJECT_ROOT)),
        "file_size_mb": round(TFLITE_MODEL_PATH.stat().st_size / (1024 * 1024), 2),
        "total_test_samples": len(parity_results),
        "top1_agreement_pct": round(agreement_rate, 2),
        "average_cosine_similarity": round(avg_cos_sim, 6),
        "average_max_absolute_error": round(avg_max_err, 6),
        "cpu_latency_mean_ms": round(avg_latency, 2),
        "cpu_latency_p95_ms": round(p95_latency, 2),
        "detailed_results": parity_results
    }

    summary_file = TFLITE_DIR / "parity_verification_summary.json"
    with open(summary_file, "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2)

    print("\n" + "=" * 72, flush=True)
    print(" PARITY & CONVERSION VALIDATION SUMMARY", flush=True)
    print("=" * 72, flush=True)
    print(f"Top-1 Prediction Agreement: {agreement_rate:.1f}%", flush=True)
    print(f"Mean Cosine Similarity    : {avg_cos_sim:.6f}", flush=True)
    print(f"Mean Max Absolute Error   : {avg_max_err:.6f}", flush=True)
    print(f"Mean CPU Inference Latency: {avg_latency:.2f} ms (p95: {p95_latency:.2f} ms)", flush=True)
    print(f"Model File Size           : {summary['file_size_mb']} MB", flush=True)
    print("=" * 72, flush=True)
    return summary


def main():
    model = build_pytorch_model()
    export_to_onnx(model)
    success = convert_onnx_to_tflite()
    if not success:
        print("[ERROR] TFLite conversion could not be completed.")
        sys.exit(1)
    save_labels()
    verify_numerical_parity(model)
    print("\n[SUCCESS] Model successfully exported and validated for Flutter mobile on-device inference!")


if __name__ == "__main__":
    main()
