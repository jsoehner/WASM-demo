#!/bin/bash
set -e

echo "🚀 Building WASM Viewer Distribution Package"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "wasm-agent/Cargo.toml" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Create dist directory
DIST_DIR="dist"
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

print_status "Building WASM module..."
cd wasm-agent
wasm-pack build --target web --out-dir ../viewer/pkg --out-name wasm_agent
cd ..

print_status "Creating viewer distribution..."

# Copy viewer files
cp -r viewer/* "$DIST_DIR/"

# Create a simple web server script
cat > "$DIST_DIR/start-server.sh" << 'EOF'
#!/bin/bash
echo "🚀 Starting WASM Viewer Server"
echo "📱 Open your browser to: http://localhost:8000"
echo "🛑 Press Ctrl+C to stop the server"
echo ""

# Check if python3 is available
if command -v python3 &> /dev/null; then
    python3 -m http.server 8000
elif command -v python &> /dev/null; then
    python -m http.server 8000
else
    echo "❌ Python not found. Please install Python or serve the files manually."
    exit 1
fi
EOF

chmod +x "$DIST_DIR/start-server.sh"

# Create a Windows batch file for the server
cat > "$DIST_DIR/start-server.bat" << 'EOF'
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
EOF

# Create README for the distribution
cat > "$DIST_DIR/README.md" << 'EOF'
# WASM LLM Agent Viewer

A WebAssembly-based LLM agent that runs entirely in your browser.

## Quick Start

### Option 1: Run the Server (Recommended)

**Linux/macOS:**
```bash
./start-server.sh
```

**Windows:**
```cmd
start-server.bat
```

Then open http://localhost:8000 in your browser.

### Option 2: Manual Serving

Serve the contents of this directory with any web server:

```bash
# Using Python
python3 -m http.server 8000

# Using Node.js (if installed)
npx serve .

# Using PHP
php -S localhost:8000
```

## Features

- 🤖 Runs entirely in the browser using WebAssembly
- 🔄 Supports multiple LLM providers (OpenAI API, Ollama)
- 🛠️ Built-in tool calling capabilities
- 🌐 Universal WASM binary for all platforms

## Usage

1. Open the viewer in your browser
2. Select your LLM provider (OpenAI/Ollama)
3. Configure your API settings
4. Enter a prompt and click "Execute Agent"

## Supported Providers

- **OpenAI API**: Compatible with OpenAI, Open WebUI, and similar services
- **Ollama**: Native Ollama API support

## Requirements

- Modern web browser with WebAssembly support
- Internet connection for LLM API access

## Troubleshooting

### CORS Issues
If you encounter CORS errors, make sure you're accessing the viewer through a web server (not opening index.html directly).

### WASM Loading Errors
Ensure your browser supports WebAssembly. Modern versions of Chrome, Firefox, Safari, and Edge all support WASM.
EOF

# Create package.json for npm-based serving
cat > "$DIST_DIR/package.json" << 'EOF'
{
  "name": "wasm-agent-viewer",
  "version": "0.1.0",
  "description": "WebAssembly LLM Agent Viewer",
  "main": "index.html",
  "scripts": {
    "start": "npx serve .",
    "serve": "python3 -m http.server 8000 || python -m http.server 8000"
  },
  "keywords": ["wasm", "webassembly", "llm", "agent", "ai"],
  "author": "",
  "license": "MIT"
}
EOF

print_status "Creating desktop app wrapper..."

# Create Electron app structure
ELECTRON_DIR="$DIST_DIR/electron-app"
mkdir -p "$ELECTRON_DIR"

# Electron package.json
cat > "$ELECTRON_DIR/package.json" << 'EOF'
{
  "name": "wasm-agent-viewer",
  "version": "0.1.0",
  "description": "WebAssembly LLM Agent Desktop Viewer",
  "main": "main.js",
  "scripts": {
    "start": "electron .",
    "build": "electron-builder",
    "dist": "electron-builder --publish=never"
  },
  "keywords": ["wasm", "webassembly", "llm", "agent", "ai", "electron"],
  "author": "",
  "license": "MIT",
  "devDependencies": {
    "electron": "^25.0.0",
    "electron-builder": "^24.0.0"
  },
  "build": {
    "appId": "com.wasm-agent.viewer",
    "productName": "WASM Agent Viewer",
    "directories": {
      "output": "dist"
    },
    "files": [
      "**/*",
      "!dist/**/*"
    ],
    "mac": {
      "target": "dmg"
    },
    "win": {
      "target": "nsis"
    },
    "linux": {
      "target": "AppImage"
    }
  }
}
EOF

# Electron main.js
cat > "$ELECTRON_DIR/main.js" << 'EOF'
const { app, BrowserWindow, Menu } = require('electron');
const path = require('path');

function createWindow() {
  // Create the browser window
  const mainWindow = new BrowserWindow({
    width: 1000,
    height: 800,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      enableRemoteModule: false
    },
    icon: path.join(__dirname, 'icon.png'), // Add an icon if available
    title: 'WASM Agent Viewer'
  });

  // Load the viewer
  mainWindow.loadFile(path.join(__dirname, 'index.html'));

  // Remove menu bar in production
  if (process.env.NODE_ENV === 'production') {
    Menu.setApplicationMenu(null);
  }
}

// This method will be called when Electron has finished initialization
app.whenReady().then(() => {
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

// Quit when all windows are closed, except on macOS
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
EOF

# Copy viewer files to electron app
cp -r "$DIST_DIR"/index.html "$DIST_DIR"/pkg "$DIST_DIR"/README.md "$ELECTRON_DIR"/ 2>/dev/null || true

print_status "Creating installation scripts..."

# Create installation script for Linux
cat > "$DIST_DIR/install-linux.sh" << 'EOF'
#!/bin/bash
set -e

echo "🐧 Installing WASM Agent Viewer for Linux"

# Check if we're running as root
if [ "$EUID" -eq 0 ]; then
    INSTALL_DIR="/opt/wasm-agent-viewer"
    DESKTOP_FILE="/usr/share/applications/wasm-agent-viewer.desktop"
else
    INSTALL_DIR="$HOME/.local/share/wasm-agent-viewer"
    DESKTOP_FILE="$HOME/.local/share/applications/wasm-agent-viewer.desktop"
    mkdir -p "$(dirname "$DESKTOP_FILE")"
fi

echo "📁 Installing to: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
cp -r . "$INSTALL_DIR/"

# Create desktop entry
cat > "$DESKTOP_FILE" << DESKTOP_EOF
[Desktop Entry]
Name=WASM Agent Viewer
Comment=WebAssembly LLM Agent
Exec=$INSTALL_DIR/start-server.sh
Icon=$INSTALL_DIR/icon.png
Terminal=true
Type=Application
Categories=Development;Utility;
DESKTOP_EOF

chmod +x "$DESKTOP_FILE"
chmod +x "$INSTALL_DIR/start-server.sh"

echo "✅ Installation complete!"
echo "🎯 Run: $INSTALL_DIR/start-server.sh"
echo "📱 Or find 'WASM Agent Viewer' in your applications menu"
EOF

chmod +x "$DIST_DIR/install-linux.sh"

# Create installation script for Windows
cat > "$DIST_DIR/install-windows.bat" << 'EOF'
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
EOF

print_status "Creating distribution archives..."

# Create ZIP archive
cd "$DIST_DIR"
zip -r "../wasm-agent-viewer-$(date +%Y%m%d).zip" .
cd ..

# Create TAR.GZ archive
tar -czf "wasm-agent-viewer-$(date +%Y%m%d).tar.gz" -C "$DIST_DIR" .

print_status "Distribution package created successfully!"
echo ""
echo "📦 Available downloads:"
echo "  • ZIP: wasm-agent-viewer-$(date +%Y%m%d).zip"
echo "  • TAR.GZ: wasm-agent-viewer-$(date +%Y%m%d).tar.gz"
echo ""
echo "📁 Distribution contents:"
echo "  • Web server scripts (start-server.sh, start-server.bat)"
echo "  • Electron desktop app wrapper"
echo "  • Installation scripts for Linux/Windows"
echo "  • Complete documentation"
echo ""
echo "🚀 To test the distribution:"
echo "  cd dist && ./start-server.sh"
echo "  Then open http://localhost:8000"