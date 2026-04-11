#!/bin/bash
set -e

echo "Quick Build and Package Script"
echo "=============================="

echo "Creating universal browser release package..."
./package.sh

echo ""
echo "Build and packaging complete."
echo "Archives were created in the repository root (wasm-agent-viewer-*.zip/.tar.gz)."