# WASM Viewer Usage Guide

## Overview

This directory contains a WebAssembly viewer that automatically detects your operating system and loads the appropriate WASM binary.

## Directory Structure

```
viewer/
├── index.html                      # Main viewer page
├── README.md                       # Quick start guide
├── docs/
│   └── USAGE.md                    # This file
└── pkg/
    ├── wasm_agent.js               # Generated JavaScript bindings
    └── wasm_agent_bg.wasm          # WebAssembly binary
```

## Quick Start

1. Open `viewer/index.html` in a web browser
2. Configure your LLM provider settings (API URL, model, etc.)
3. Click "Execute Agent" to run tasks

## Platform Support

The WASM binary works in all modern web browsers across all platforms.
    './linux-wasm_agent.wasm';
```

Supported platforms:

- **Windows x64**: `windows-x64-wasm_agent.wasm`
- **Linux x64**: `linux-wasm_agent.wasm`
- **macOS (Intel/Apple Silicon)**: `macos-wasm_agent.wasm`

## Building WASM Binaries

### Automatic Build

Run the appropriate build script for your platform:

```bash
# For Windows (PowerShell)
.\build_and_copy_viewer.ps1

# For Linux/macOS (Bash)
chmod +x build_and_copy_viewer.sh
./build_and_copy_viewer.sh
```

### Manual Build

1. **Install WASM target**:
   ```bash
   rustup target add wasm32-unknown-unknown
   ```

2. **Build for each platform**:
   ```bash
   # Linux
   cargo build --target x86_64-unknown-linux-gnu --release --out-dir target/x86_64-unknown-linux-gnu/release
   
   # Windows x64
   cargo build --target x86_64-pc-windows-msvc --release --out-dir target/x86_64-pc-windows-msvc/release
   
   # macOS
   cargo build --target x86_64-apple-darwin --release --out-dir target/x86_64-apple-darwin/release
   ```

3. **Copy binaries to viewer**:
   ```bash
   mkdir -p viewer/pkg
   cp target/x86_64-unknown-linux-gnu/release/*.wasm viewer/pkg/linux-wasm_agent.wasm
   cp target/x86_64-pc-windows-msvc/release/*.wasm viewer/pkg/windows-x64-wasm_agent.wasm
   cp target/x86_64-apple-darwin/release/*.wasm viewer/pkg/macos-wasm_agent.wasm
   ```

## Features

- **Platform-specific binaries**: Each OS gets its own optimized WASM binary
- **Automatic detection**: No need to manually select your platform
- **Modular design**: Easy to add or remove platform support
- **CI/CD support**: GitHub Actions workflows automate the build process

## Troubleshooting

### WASM binary not loading

1. Check that the WASM file exists in `viewer/pkg/`
2. Verify the file is a valid WASM file (should start with U+0000 or U+007F)
3. Ensure your browser supports WebAssembly

### Platform detection fails

1. Check browser's `navigator.platform` value in browser console (F12)
2. Ensure the correct WASM file exists for your platform

## CI/CD Workflow

For automated builds, see `.github/workflows/build-viewer.yml` for GitHub Actions configuration.
