#!/usr/bin/env bash
# Build the WASM module on Linux or macOS.
# Prerequisites:
#   rustup target add wasm32-unknown-unknown
#   cargo install wasm-pack
set -euo pipefail

if ! command -v wasm-pack &>/dev/null; then
    echo "Error: wasm-pack not found."
    echo "Install with: cargo install wasm-pack"
    echo "Also run:     rustup target add wasm32-unknown-unknown"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/wasm-agent"

echo "Building WASM module..."
wasm-pack build --target web --out-dir ../viewer/pkg --out-name wasm_agent

echo "Build complete. Files written to viewer/pkg/"