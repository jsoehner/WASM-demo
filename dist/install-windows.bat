@echo off
echo 📦 Installing WASM Agent Viewer for Windows

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    set "INSTALL_DIR=C:\Program Files\WASM Agent Viewer"
) else (
    set "INSTALL_DIR=%APPDATA%\WASM Agent Viewer"
)

echo 📁 Installing to: %INSTALL_DIR%
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
xcopy /E /I /Y . "%INSTALL_DIR%"

echo ✅ Installation complete!
echo 🎯 Run: %INSTALL_DIR%\start-server.bat
echo 📱 Or create a desktop shortcut to start-server.bat
pause
