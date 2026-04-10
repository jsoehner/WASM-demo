#!/bin/bash
set -e

# Check prerequisites
if ! command -v wasm-pack &> /dev/null; then
    echo "Error: wasm-pack is not installed."
    echo "Install with: cargo install wasm-pack"
    echo "Also ensure wasm32 target is installed: rustup target add wasm32-unknown-unknown"
    exit 1
fi

echo "=== Building WASM Module ==="

# Build WASM using wasm-pack
cd wasm-agent
wasm-pack build --target web --out-dir ../viewer/pkg --out-name wasm_agent

echo "=== Build Complete ==="
echo "WASM files generated in viewer/pkg/"
echo "Open viewer/index.html in a web browser to test."