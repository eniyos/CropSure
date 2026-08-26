# CropSure

AI-powered smart agriculture Flutter app for crop disease insight, dynamic trust scoring, and digital crop passports.

## Run

```bash
flutter pub get
flutter run -d chrome
```

Demo login (mock auth):

- Email: `farmer@cropsure.app`
- Password: `password123`

## Quality checks

```bash
flutter analyze
flutter test
```

## Architecture

Feature-based Flutter layout:

- `lib/core` — theme, routing, network, offline, DI
- `lib/models` — domain models
- `lib/services` — repositories (mock + remote stubs)
- `lib/features` — screens + controllers
- `lib/widgets` — shared UI

Mock repositories are the default (`ApiConfig.useMockApis = true`). Remote farm/crop repos are wired behind the same interfaces for later FastAPI integration.

## Phases delivered

1. Foundation + auth
2. Farms, crops, farmer dashboard
3. Disease analysis (mock AI)
4. Trust score + treatments
5. Weather, market, notifications
6. Digital crop passport + QR verify
7. Offline cache, sync queue, API factory
8. Responsive polish, accessibility, performance, tests

## Offline demo

Dashboard → **Offline / Sync** → enable **Simulate offline**, edit a farm/crop, then go back online to process the sync queue.
