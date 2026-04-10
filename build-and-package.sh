#!/bin/bash
set -e

echo "🔨 Quick Build & Package Script"
echo "==============================="

# Build the WASM module
echo "📦 Building WASM module..."
cd wasm-agent
wasm-pack build --target web --out-dir ../viewer/pkg --out-name wasm_agent
cd ..

# Run the packaging script
echo "📦 Creating distribution package..."
./package-viewer.sh

echo ""
echo "✅ Build and packaging complete!"
echo "📁 Check the 'dist/' directory and archive files for the distribution."