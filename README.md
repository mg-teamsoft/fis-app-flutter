# FIS App (Flutter)

FIS App is a Flutter client for capturing receipt images, uploading them to the backend, reviewing the OCR output, and writing approved results to Excel files stored in S3. The app also offers authentication, Excel file browsing/downloading, and a token-aware API client that keeps sessions fresh.

## Highlights
- Email/password authentication with secure token storage and auto logout on 401s.
- Multi-image receipt capture from gallery or camera with JPEG conversion, checksum calculation, and S3 uploads.
- Background job polling that surfaces OCR progress and editable JSON results before pushing to Excel.
- Excel file list with presigned download/open flows and local caching utilities.
- Centralized API/Dio configuration with environment-driven base URLs and timeouts.

## Project Structure
- `lib/main.dart` – App entry point, global error handling, route table.
- `lib/pages/` – UI flows for login, registration, receipt upload, job results, and Excel browsing.
- `lib/services/` – API client, auth, S3 upload, job polling, Excel integration, and helpers.
- `lib/models/` – Data objects used across the receipt flow and Excel features.
- `lib/utils/` – Checksum and MIME helpers for uploads.
- `lib/config/` – Build-time configuration (API base URL, environment labels, feature flags).

## Prerequisites
- Flutter SDK 3.24+ (Dart 3.6 is required by `sdk: ^3.6.2`).
- Xcode / Android Studio command-line tools for iOS & Android builds.
- A running backend that exposes the `/auth`, `/file`, `/upload`, `/job`, and `/excel` routes referenced in `lib/services/`.

Verify your Flutter installation:

```bash
flutter --version
```

## Setup
1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Provide the backend endpoint and other build-time settings via `--dart-define` flags (see below).
3. Launch the desired platform:
   ```bash
   flutter run -d <Deviced ID> \
     --dart-define=API_BASE_URL=https://your-api.example.com \
     --dart-define=ENV=dev
   ```

To target a specific device/emulator append `-d <device_id>`.

## Build-Time Configuration (`--dart-define`)
| Key | Default | Purpose |
| --- | --- | --- |
| `API_BASE_URL` | `http://localhost:3000` | REST endpoint used by `ApiClient`.
| `CONNECT_TIMEOUT_MS` | `15000` | Dio connect timeout in milliseconds.
| `RECEIVE_TIMEOUT_MS` | `20000` | Dio receive timeout in milliseconds.
| `ENV` | `dev` | Used for secure-storage key namespacing (`AuthConfig`).
| `MOCK_OCR` | `false` | Optional flag for toggling mock OCR flows (checked in `AppConfig`).

Example release build with custom environment:

```bash
flutter build apk \
  --dart-define=API_BASE_URL=https://api.prod.example.com \
  --dart-define=ENV=prod \
  --dart-define=CONNECT_TIMEOUT_MS=20000 \
  --dart-define=RECEIVE_TIMEOUT_MS=30000
```

## Authentication Flow
- `LoginPage` and `RegisterPage` call `AuthService` which posts to `/auth/login` and `/auth/register`.
- Successful login persists the bearer token in `FlutterSecureStorage`; `ApiClient` attaches it to future requests.
- 401 responses trigger `AuthNavigation.redirectToLogin` and clear cached credentials.

## Receipt Processing Pipeline
1. `ReceiptPage` lets users pick multiple images or capture via camera (`image_picker` & `camera`).
2. `ReceiptProcessPage` converts files to JPEG, calculates CRC32/sha256, initializes a presigned upload, PUTs to S3, confirms, and then starts an OCR job.
3. `ReceiptResultsPage` polls job status, displays previews, renders editable JSON, and pushes approved receipts to Excel via `ExcelService`.

Supporting utilities:
- `S3UploadService` handles init/PUT/confirm steps.
- `JobService` and `JobPollingService` encapsulate status checks and timers.
- `FileDownloadService` plus `open_filex` download and open Excel exports.

## Excel Management
- `ExcelFilesPage` fetches available Excel files, offers in-app open/download actions, and reuses presigned URLs.
- Successful receipt approval enables one-click navigation to the Excel list for quick QA.

## Running Tests
Execute all Dart/Flutter unit tests:

```bash
flutter test
```

Add integration/widget tests under `test/` to cover new features before shipping.

## Troubleshooting
- Ensure the API base URL is reachable from your device/emulator; emulators may require 10.0.2.2 (Android) or host networking options.
- If secure storage reads fail on desktop, run with a platform that supports `flutter_secure_storage` or guard platform access.
- Unexpected 401s usually indicate expired tokens; log back in to refresh credentials.

## Useful Commands
- `flutter analyze` – static analysis with `flutter_lints`.
- `flutter test --coverage` – generate coverage data.
- `flutter pub outdated` – view newer package versions.

## Contributing
1. Create a feature branch.
2. Format and analyze:
   ```bash
   flutter format lib test
   flutter analyze
   ```
3. Add/extend tests.
4. Open a PR describing the change and any backend dependencies.

---
For IDE integration hints or scripted launch configs, consider adding dedicated `.vscode/` or `melos` tooling if the project grows beyond the current scope.
