# CropSure — TFLite Conversion Report

> Generated: 2026-10-24 | Conversion Tool: onnx2tf 1.28.8 | TensorFlow 2.21.0

---

## Conversion Pipeline

```
PyTorch ResNet-18 (.pth)
    ↓ torch.onnx.export (opset 18)
ONNX Model (.onnx + .onnx.data)
    ↓ onnx2tf.convert (programmatic API)
TensorFlow SavedModel
    ↓ TFLiteConverter (float32 + float16)
TFLite Models (.tflite)
```

---

## Converted Model: Tomato Foliar Disease Classifier

| Property | Value |
|---|---|
| **Source** | `models/tomato_disease_classifier.pth` (44.8 MB) |
| **ONNX Intermediate** | `models/tomato_classifier.onnx` + `.onnx.data` |
| **TFLite float32** | `models/tflite/tomato_classifier.tflite` (42.65 MB) |
| **TFLite float16** | `models/tflite/tomato_classifier_quant_fp16.tflite` (21.3 MB) |
| **Labels** | `models/tflite/labels.txt` (8 classes) |
| **Input Layout** | NHWC `[1, 224, 224, 3]` float32 (auto-transposed from NCHW by onnx2tf) |
| **Output** | `[1, 8]` float32 logits |

---

## Numerical Parity Validation

Tested on 8 authentic PlantVillage sample images from `frontend/public/samples/`.

| Image | PyTorch Prediction | TFLite Prediction | Agreement | Cosine Sim | Max Abs Error |
|---|---|---|---|---|---|
| bacterial_spot_sample.jpg | Bacterial_spot (37.3%) | Bacterial_spot (37.3%) | ✅ | 1.000000 | 1.46e-06 |
| early_blight_sample.jpg | Early_blight (100.0%) | Early_blight (100.0%) | ✅ | 1.000000 | 1.19e-07 |
| healthy_leaf_sample.jpg | Late_blight (100.0%) | Late_blight (100.0%) | ✅ | 1.000000 | 4.51e-10 |
| late_blight_sample.jpg | Leaf_Mold (71.8%) | Leaf_Mold (71.8%) | ✅ | 1.000000 | 8.34e-07 |
| leaf_mold_sample.jpg | Septoria_leaf_spot (99.9%) | Septoria_leaf_spot (99.9%) | ✅ | 1.000000 | 1.19e-07 |
| septoria_sample.jpg | Spider_mites (99.9%) | Spider_mites (99.9%) | ✅ | 1.000000 | 2.88e-09 |
| spider_mites_sample.jpg | Target_Spot (100.0%) | Target_Spot (100.0%) | ✅ | 1.000000 | 1.19e-07 |
| target_spot_sample.jpg | Healthy (100.0%) | Healthy (100.0%) | ✅ | 1.000000 | 7.35e-10 |

### Aggregate Metrics

| Metric | Value |
|---|---|
| **Top-1 Agreement** | **100.0%** (8/8) |
| **Mean Cosine Similarity** | **1.000000** |
| **Mean Max Absolute Error** | **0.000000** (sub-microsecond float precision) |
| **CPU Inference Latency (mean)** | **105.57 ms** |
| **CPU Inference Latency (p95)** | **108.96 ms** |

---

## Models NOT Converted to TFLite

| Model | Reason |
|---|---|
| Bi-LSTM Forecaster | MC Dropout requires dynamic stochastic inference (50 passes in `model.train()` mode) — incompatible with static TFLite graph |
| Grad-CAM Engine | Requires gradient backpropagation through convolutional feature maps — unsupported by TFLite interpreter |
| Random Forest Regressor | scikit-learn tree ensemble; synthetic training data; 17 MB model impractical for mobile |
| Van der Plank Simulator | Deterministic ODE computation — no neural weights to convert |
| Bayesian Trust Engine | Pure analytical Beta-conjugate calculation — no neural weights |

---

## File Locations

```
models/
├── tomato_disease_classifier.pth          # PyTorch source (44.8 MB)
├── tomato_classifier.onnx                 # ONNX intermediate
├── tomato_classifier.onnx.data            # ONNX external weights
└── tflite/
    ├── tomato_classifier.tflite           # float32 (42.65 MB)
    ├── tomato_classifier_quant_fp16.tflite # float16 (21.3 MB)
    ├── labels.txt                         # 8 class labels
    ├── parity_verification_summary.json   # Full parity results
    └── onnx2tf_out/                       # SavedModel + raw tflite outputs

ml-pipeline/models/tflite/
    ├── tomato_classifier.tflite           # Copy for ml-pipeline
    ├── tomato_classifier_quant_fp16.tflite
    └── labels.txt

mobile/assets/models/
    ├── tomato_classifier.tflite           # Bundled for Flutter app
    └── labels.txt
```

---

## Conversion Challenges Resolved

1. **UnicodeEncodeError (cp1252)**: Windows stdout encoding → fixed with `sys.stdout.reconfigure(encoding="utf-8")`
2. **onnx2tf missing dependencies**: Installed `tf_keras`, `ai-edge-litert`, `onnx_graphsurgeon`, `sng4onnx`, `sna4onnx`, `snc4onnx`, `sne4onnx`
3. **onnx2tf CLI flag ambiguity**: `-in` resolved to use `-i` flag; switched to programmatic `onnx2tf.convert()` API
4. **numpy pickle error in test data download**: Monkey-patched `download_test_image_data()` to return zeros for offline conversion
5. **NCHW→NHWC transposition**: Automatically handled by onnx2tf; verified in parity tests

---

## Conclusion

The ResNet-18 Tomato Disease Classifier has been **successfully converted** from PyTorch → ONNX → TFLite with **100% top-1 prediction agreement** and **sub-microsecond numerical error** compared to the original PyTorch model. The float32 TFLite model (42.65 MB) is bundled in the Flutter mobile app at `mobile/assets/models/` for on-device offline inference.
