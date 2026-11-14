@echo off
setlocal
echo ========================================================
echo   Launching CropSure Mobile App (Chrome Web Mode)
echo   Connecting to CropSure AI Backend: http://127.0.0.1:5000
echo ========================================================

:: 1. Clear any stuck dart instances or locked assets from prior sessions
powershell -Command "Get-Process -Name dart -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue" 2>nul
if exist "build\flutter_assets" (
    attrib -r -s "build\flutter_assets\*" /s /d 2>nul
    rd /s /q "build\flutter_assets" 2>nul
)

:: 2. Use short 8.3 path without spaces to prevent Dart subprocess path bugs
set "PATH=C:\Users\HARINA~1\OneDrive\Documents\flutter\bin;%PATH%"
set "PUB_CACHE=C:\Users\HARINA~1\AppData\Local\Pub\Cache"

cd /d "C:\Users\HARINA~1\OneDrive\Desktop\agriculture\cropsure_mobile"

call flutter run -d chrome --no-web-resources-cdn --dart-define=CROPSURE_API_BASE_URL=http://127.0.0.1:5000

endlocal
