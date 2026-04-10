@echo off
echo 🚀 Starting WASM Viewer Server
echo 📱 Open your browser to: http://localhost:8000
echo 🛑 Press Ctrl+C to stop the server
echo.

REM Check if Python is available
python -m http.server 8000 2>nul
if %errorlevel% neq 0 (
    echo ❌ Python not found. Please install Python or serve the files manually.
    pause
    exit /b 1
)
