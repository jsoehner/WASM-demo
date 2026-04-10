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
