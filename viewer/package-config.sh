# WASM Agent Viewer Packaging Configuration

# Package metadata
PACKAGE_NAME="wasm-agent-viewer"
PACKAGE_VERSION="0.1.0"
PACKAGE_DESCRIPTION="WebAssembly LLM Agent Desktop Viewer"

# Distribution settings
DIST_DIR="dist"
ARCHIVE_PREFIX="wasm-agent-viewer"

# Electron app settings
ELECTRON_APP_NAME="WASM Agent Viewer"
ELECTRON_APP_ID="com.wasm-agent.viewer"

# Installation paths
LINUX_INSTALL_DIR="/opt/wasm-agent-viewer"
WINDOWS_INSTALL_DIR="C:\\Program Files\\WASM Agent Viewer"

# Build settings
WASM_TARGET="web"
WASM_OUT_NAME="wasm_agent"

# Server settings
DEFAULT_PORT=8000

# Files to include in distribution
DIST_FILES=(
    "index.html"
    "pkg/"
    "README.md"
    "package.json"
    "start-server.sh"
    "start-server.bat"
)

# Files to exclude from distribution
DIST_EXCLUDE=(
    ".git"
    "node_modules"
    "*.log"
    ".DS_Store"
)