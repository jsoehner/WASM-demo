# WASM LLM Agent Demo

A WebAssembly-based LLM agent that runs in the browser and can interact with various LLM providers.

## Features

- 🤖 Runs entirely in the browser using WebAssembly
- 🔄 Supports multiple LLM providers (OpenAI API, Ollama)
- 🛠️ Built-in tool calling (string length calculation)
- 🌐 Universal WASM binary for all platforms

## Quick Start

1. **Install prerequisites:**
   ```bash
   # Install Rust
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   source ~/.cargo/env

   # Add WASM target
   rustup target add wasm32-unknown-unknown

   # Install wasm-pack
   cargo install wasm-pack
   ```

2. **Build and package for distribution:**
   ```bash
   ./build-and-package.sh
   ```

3. **Open the viewer:**
   ```bash
   # Serve the packaged distribution
   cd dist && ./start-server.sh
   # Then open http://localhost:8000 in your browser
   ```

## Distribution

The project includes a complete packaging system for creating downloadable distributions:

### Creating a Distribution Package

```bash
# Quick build and package
./build-and-package.sh

# Or just package (assumes WASM is already built)
./package-viewer.sh
```

This creates:
- **`dist/`** - Complete distribution directory
- **`wasm-agent-viewer-YYYYMMDD.zip`** - ZIP archive for download
- **`wasm-agent-viewer-YYYYMMDD.tar.gz`** - TAR.GZ archive for download

### Distribution Contents

The distribution package includes:
- **Web viewer** - Complete HTML/CSS/JavaScript interface
- **WASM binaries** - Optimized WebAssembly modules
- **Server scripts** - Easy startup scripts for Linux/macOS/Windows
- **Desktop app** - Electron wrapper for native desktop experience
- **Installation scripts** - Automated installers for different platforms
- **Documentation** - Complete usage guides and troubleshooting

### Running the Distribution

**Web Server Mode (Recommended):**
```bash
cd dist
./start-server.sh  # Linux/macOS
# or
start-server.bat   # Windows
```

**Desktop App Mode:**
```bash
cd dist/electron-app
npm install
npm start
```

**Manual Serving:**
```bash
cd dist
python3 -m http.server 8000
# Then open http://localhost:8000
```

## Architecture

- `wasm-agent/` - Rust crate compiled to WebAssembly
- `viewer/` - Web interface that loads and runs the WASM agent
- `build.sh` - Build script using wasm-pack

## Supported Providers

- **OpenAI API**: Compatible with OpenAI, Open WebUI, and similar services
- **Ollama**: Native Ollama API support

## Distribution Options

### Web Distribution
- **Universal compatibility** - Works in any modern web browser
- **Zero installation** - Just download and serve
- **Cross-platform** - Same package works on Windows, macOS, Linux

### Desktop App Distribution
- **Electron wrapper** - Native desktop application experience
- **Offline capable** - Can work without constant web server
- **System integration** - Desktop shortcuts, start menu entries

### Archive Downloads
- **ZIP format** - `wasm-agent-viewer-YYYYMMDD.zip`
- **TAR.GZ format** - `wasm-agent-viewer-YYYYMMDD.tar.gz`
- **Complete packages** - Include all necessary files and documentation

## Development

See [BUILD.md](BUILD.md) for detailed build instructions and architecture notes.