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
