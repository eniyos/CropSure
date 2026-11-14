# CropSure — Flutter Mobile Integration Report

> Generated: 2026-10-24 | Dart SDK: 3.11.4 | Flutter Mobile App: `mobile/`

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                   Flutter Mobile App                         │
│                     (mobile/)                                │
│                                                              │
│  ┌──────────┐  ┌───────────┐  ┌──────────┐  ┌──────────┐  │
│  │  Screens  │  │ Providers │  │ Services │  │  Models  │   │
│  │  (UI)     │  │  (State)  │  │ (Logic)  │  │  (Data)  │   │
│  └──────────┘  └───────────┘  └──────────┘  └──────────┘   │
│        │              │              │             │         │
│        └──────────────┴──────────────┘             │         │
│                       │                            │         │
│              ┌────────┴────────┐                   │         │
│              │                 │                   │         │
│    ┌─────────▼──────┐ ┌───────▼────────┐          │         │
│    │ TFLite Runtime  │ │ HTTP REST API  │          │         │
│    │ (On-Device)     │ │ (Cloud Backend)│          │         │
│    │ tomato_classifier│ │ Flask:5000    │          │         │
│    │ .tflite         │ │ /api/v1/ai/   │          │         │
│    └────────────────┘ └────────────────┘          │         │
└─────────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
mobile/
├── pubspec.yaml                          # Dependencies and asset declarations
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml           # Permissions: CAMERA, INTERNET
├── assets/
│   ├── models/
│   │   ├── tomato_classifier.tflite      # On-device model (42.65 MB)
│   │   └── labels.txt                    # 8 disease class labels
│   └── samples/                          # 8 sample leaf images
├── lib/
│   ├── main.dart                         # App entry point + Provider setup
│   ├── models/
│   │   ├── diagnosis_result.dart         # Disease detection data model
│   │   ├── forecast_result.dart          # Forecast horizons data model
│   │   ├── yield_impact.dart             # Yield loss & economics data model
│   │   └── trust_result.dart             # Bayesian trust data model
│   ├── providers/
│   │   └── diagnosis_provider.dart       # Central state management (ChangeNotifier)
│   ├── services/
│   │   ├── api_client.dart               # HTTP client for backend communication
│   │   ├── disease_detection_service.dart # TFLite on-device + API fallback
│   │   ├── disease_forecast_service.dart  # Bi-LSTM forecast via API + offline ODE
│   │   ├── explainability_service.dart    # Grad-CAM heatmap via API
│   │   ├── yield_loss_service.dart        # Random Forest yield via API + offline formula
│   │   └── crop_trust_service.dart        # Bayesian trust via API + local Beta calc
│   ├── screens/
│   │   ├── home_screen.dart              # Dashboard with model cards & status
│   │   ├── scan_screen.dart              # Camera/gallery capture + analysis trigger
│   │   ├── results_screen.dart           # 5-card diagnosis results display
│   │   └── settings_screen.dart          # API URL config, offline toggle, engine status
│   └── widgets/
│       └── custom_widgets.dart           # ModelOriginBadge, SeverityBadge, StatTile
```

---

## Service Layer — Deployment Map

| Service | On-Device (Offline) | Backend API | Endpoint |
|---|---|---|---|
| **DiseaseDetectionService** | ✅ TFLite float32 | ✅ Fallback | `POST /api/v1/ai/diagnose` |
| **DiseaseForecastService** | ✅ Van der Plank ODE | ✅ Primary | `POST /api/forecast` |
| **ExplainabilityService** | ❌ Not possible | ✅ Required | `POST /api/explain` |
| **YieldLossService** | ✅ Empirical formula | ✅ Primary | `POST /api/yield-loss` |
| **CropTrustService** | ✅ Local Beta-conjugate | ✅ Enriched | `POST /api/v1/trust/calculate` |

---

## On-Device TFLite Inference Details

### Preprocessing (Dart)

```dart
// 1. Resize to 224×224
// 2. Normalize each channel: (pixel / 255.0 - mean) / std
//    mean = [0.485, 0.456, 0.406]
//    std  = [0.229, 0.224, 0.225]
// 3. Layout: NHWC [1, 224, 224, 3] float32
```

### Inference Configuration

- **Interpreter threads**: 4
- **Input tensor**: `[1, 224, 224, 3]` float32
- **Output tensor**: `[1, 8]` float32 (raw logits → softmax in Dart)
- **Expected latency**: ~50–150 ms on mid-range Android device

---

## Screens & User Flow

```
HomeScreen (Dashboard)
    │
    ├── [Start Leaf Scan] → ScanScreen
    │                          │
    │                    Camera / Gallery
    │                          │
    │                    [Analyze Leaf]
    │                          │
    │                    ResultsScreen
    │                    ├── Detection Card (disease name, confidence, severity)
    │                    ├── Grad-CAM Card (original vs heatmap side-by-side)
    │                    ├── Forecast Card (7/14/30-day chart with CI bands)
    │                    ├── Yield Loss Card (circular gauge, drivers, remediation)
    │                    └── Trust Score Card (gauge, 12 signals, blockchain hash)
    │
    └── [Settings] → SettingsScreen
                      ├── Backend URL configuration
                      ├── Offline-only toggle
                      └── Engine readiness status (6 models)
```

---

## Backend API Compatibility

The following route aliases were added to `backend/app/routes/api.py` to support Flutter client contracts:

| New Route | Points To | Method |
|---|---|---|
| `POST /api/v1/ai/diagnose` | `analyze()` | Multipart image upload |
| `POST /api/v1/trust/calculate` | `trust()` | JSON evidence payload |

Original endpoints (`/api/analyze`, `/api/trust`, etc.) remain fully functional.

### Standalone Microservices

| Service | File | Port | Endpoint |
|---|---|---|---|
| AI Diagnosis | `services/ai-service/app.py` | 8002 | `POST /api/v1/ai/diagnose` |
| Trust Engine | `services/trust-engine/app.py` | 8003 | `POST /api/v1/trust/calculate` |

---

## Dependencies (pubspec.yaml)

| Package | Purpose |
|---|---|
| `tflite_flutter` | On-device TFLite inference runtime |
| `image_picker` | Camera and gallery access |
| `image` | Image decode/resize for preprocessing |
| `http` | REST API communication |
| `provider` | State management (ChangeNotifier) |
| `fl_chart` | Line charts for forecast visualization |
| `path_provider` | Local file system access |
| `shared_preferences` | Persistent API URL storage |

---

## Key Design Decisions

1. **TFLite-first, API-fallback**: `DiseaseDetectionService` tries on-device inference before network calls. If TFLite model fails to load, it transparently falls back to the backend.

2. **Offline mode toggle**: User can force offline-only mode from ScanScreen or SettingsScreen. In this mode, Grad-CAM is unavailable (requires backend gradients), and Forecast/Yield services use local deterministic algorithms.

3. **Transparent source labeling**: Every diagnosis result displays a `ModelOriginBadge` showing whether inference ran on-device (`TFLite On-Device`) or via cloud (`Cloud AI API`), along with latency.

4. **No faking**: The app never claims on-device execution for models that require backend infrastructure (Grad-CAM, MC Dropout BiLSTM, Random Forest). When offline, these cards either show "Not Available" or use explicitly labeled offline approximations.

5. **Existing backend preserved**: All original `/api/*` routes in `backend/app/routes/api.py` are untouched. New aliases are additive only.

---

## Backend Test Verification

```
30 passed, 4 warnings in 16.91s
```

All existing backend unit and integration tests (30/30) pass after adding the route aliases.

---

## Next Steps for Full Android Deployment

1. **Flutter SDK setup**: Run `flutter create .` inside `mobile/` to generate Android/iOS build scaffolding, then replace `lib/` and `assets/` with the provided code.
2. **Build APK**: `flutter build apk --release` from `mobile/` directory.
3. **Physical device testing**: Configure `ApiClient.baseUrl` to point to the host machine's LAN IP (e.g., `http://192.168.x.x:5000`).
4. **Production hardening**: Add proper error boundaries, loading skeletons, and retry logic for intermittent network conditions.
