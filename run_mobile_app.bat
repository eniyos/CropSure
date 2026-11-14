@echo off
setlocal
echo ========================================================
echo   CropSure - Unified Launch Script
echo ========================================================

:: 1. Clean up any hanging dart or flutter locks from previous runs
powershell -Command "Get-Process -Name dart -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue" 2>nul
if exist "cropsure_mobile\build\flutter_assets" (
    attrib -r -s "cropsure_mobile\build\flutter_assets\*" /s /d 2>nul
    rd /s /q "cropsure_mobile\build\flutter_assets" 2>nul
)

:: 2. Set Flutter environment using 8.3 path to eliminate space-in-path issues
set "PATH=C:\Users\HARINA~1\OneDrive\Documents\flutter\bin;%PATH%"
set "PUB_CACHE=C:\Users\HARINA~1\AppData\Local\Pub\Cache"

:: 3. Navigate to Flutter mobile app directory
cd /d "C:\Users\HARINA~1\OneDrive\Desktop\agriculture\cropsure_mobile"

echo [1/2] Resolving Flutter dependencies...
call flutter pub get

echo [2/2] Launching CropSure Flutter App on Chrome (Local Offline CanvasKit Engine)...
call flutter run -d chrome --no-web-resources-cdn --dart-define=CROPSURE_API_BASE_URL=http://127.0.0.1:5000

endlocal
