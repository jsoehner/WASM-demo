#!/usr/bin/env bash
# Canonical build and package script for the WASM LLM Agent.
# 
# Usage:
#   ./build.sh           # Build WASM module only
#   ./build.sh --package # Build and create a distribution archive
#
# Prerequisites:
#   rustup target add wasm32-unknown-unknown
#   cargo install wasm-pack

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DO_PACKAGE=false

if [[ "${1:-}" == "--package" ]]; then
    DO_PACKAGE=true
fi

# --- Stage 1: Build WASM ---
echo "==> Stage 1: Building WASM module"

if ! command -v wasm-pack &>/dev/null; then
    echo "Error: wasm-pack not found."
    echo "Install with: cargo install wasm-pack"
    exit 1
fi

cd "$SCRIPT_DIR/wasm-agent"
wasm-pack build --target web --out-dir ../pkg --out-name wasm_agent
cd "$SCRIPT_DIR"

echo "Build complete. Files written to pkg/"

# --- Stage 2: Package (Optional) ---
if [ "$DO_PACKAGE" = true ]; then
    VERSION="$(date +%Y%m%d)"
    PACKAGE_NAME="wasm-agent-viewer-${VERSION}"
    echo "==> Stage 2: Packaging ${PACKAGE_NAME}"

    rm -rf "${PACKAGE_NAME}"
    mkdir -p "${PACKAGE_NAME}/pkg"

    # Copy files (Flat structure: index.html is in root)
    cp index.html "${PACKAGE_NAME}/"
    cp pkg/wasm_agent.js pkg/wasm_agent_bg.wasm pkg/wasm_agent.d.ts pkg/wasm_agent_bg.wasm.d.ts pkg/package.json "${PACKAGE_NAME}/pkg/"

    # --- start-server.sh (Linux / macOS) ---
    cat > "${PACKAGE_NAME}/start-server.sh" << 'EOF'
#!/usr/bin/env bash
PORT="${1:-8000}"
BIND="${2:-127.0.0.1}"
cd "$(dirname "$0")"

# Determine LAN IP for device testing guidance
LAN_IP=""
if [ "$BIND" = "0.0.0.0" ]; then
    LAN_IP="$(python3 -c "import socket; s=socket.socket(); s.connect(('8.8.8.8',80)); print(s.getsockname()[0]); s.close()" 2>/dev/null || \
              hostname -I 2>/dev/null | awk '{print $1}' || echo "")"
fi

echo "Starting server at http://${BIND}:${PORT}"
if [ -n "$LAN_IP" ]; then
    echo "LAN access (Android/iOS): http://${LAN_IP}:${PORT}"
fi
echo "Open the URL in any modern browser (Chrome, Firefox, Safari, Edge)."
echo "Press Ctrl+C to stop."

SERVE_SCRIPT='
import sys, os
from http.server import HTTPServer, SimpleHTTPRequestHandler
class WasmHandler(SimpleHTTPRequestHandler):
    extensions_map = {**SimpleHTTPRequestHandler.extensions_map, ".wasm": "application/wasm"}
    def log_message(self, fmt, *args): pass
HTTPServer((sys.argv[1], int(sys.argv[2])), WasmHandler).serve_forever()
'

if command -v python3 &>/dev/null; then
    python3 -c "$SERVE_SCRIPT" "${BIND}" "${PORT}"
elif command -v python &>/dev/null; then
    python -c "$SERVE_SCRIPT" "${BIND}" "${PORT}"
else
    echo "Python not found. Serve this directory with any HTTP server (e.g. npx serve .)"; exit 1
fi
EOF
    chmod +x "${PACKAGE_NAME}/start-server.sh"

    # --- start-server.bat (Windows) ---
    cat > "${PACKAGE_NAME}/start-server.bat" << 'EOF'
@echo off
set PORT=8000
set BIND=127.0.0.1
if not "%~1"=="" set PORT=%~1
if not "%~2"=="" set BIND=%~2
echo Starting server at http://%BIND%:%PORT%
if "%BIND%"=="0.0.0.0" echo For Android/iOS testing, use your machine's LAN IP on port %PORT%
echo Press Ctrl+C to stop.
cd /d "%~dp0"
python -c "from http.server import HTTPServer,SimpleHTTPRequestHandler; m={**SimpleHTTPRequestHandler.extensions_map,'.wasm':'application/wasm'}; SimpleHTTPRequestHandler.extensions_map=m; HTTPServer(('%BIND%',%PORT%),SimpleHTTPRequestHandler).serve_forever()"
EOF

    # Create archive
    if command -v zip &>/dev/null; then
        zip -qr "${PACKAGE_NAME}.zip" "${PACKAGE_NAME}"
        echo "Created ${PACKAGE_NAME}.zip"
    else
        tar czf "${PACKAGE_NAME}.tar.gz" "${PACKAGE_NAME}"
        echo "Created ${PACKAGE_NAME}.tar.gz"
    fi

    rm -rf "${PACKAGE_NAME}"
    echo "Packaging complete."
fi