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

    # Copy files
    cp index.html "${PACKAGE_NAME}/"
    cp pkg/wasm_agent.js pkg/wasm_agent_bg.wasm pkg/wasm_agent.d.ts pkg/wasm_agent_bg.wasm.d.ts pkg/package.json "${PACKAGE_NAME}/pkg/"

    # Generate start scripts
    cat > "${PACKAGE_NAME}/start-server.sh" << 'EOF'
#!/usr/bin/env bash
PORT="${1:-8000}"
echo "Starting server at http://localhost:${PORT}"
cd "$(dirname "$0")"
if command -v python3 &>/dev/null; then python3 -m http.server "${PORT}"
elif command -v python &>/dev/null; then python -m http.server "${PORT}"
else echo "Python not found. Serve with any HTTP server."; exit 1; fi
EOF
    chmod +x "${PACKAGE_NAME}/start-server.sh"

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