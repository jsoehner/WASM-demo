# Build and Deployment Guide

## Overview

This project demonstrates WASM compilation and deployment separation. The build process generates platform-specific WASM binaries that are then deployed to the viewer directory.

## Directory Structure

```
wasm-agent/
├── src/
│   └── lib.rs              # WASM source code
├── Cargo.toml

.build/
└── artifacts/              # Temporary build directory

viewer/
├── index.html              # Viewer HTML
├── package.json
└── pkg/
    ├── linux-wasm_agent.wasm
    ├── macos-wasm_agent.wasm
    ├── windows-x64-wasm_agent.wasm
    └── *.js                # Platform-specific JS glue code

build.sh                    # Build script for Linux
build_and_copy_viewer.sh    # Build script for Mac/Unix
build_and_run_agent.sh
build_and_run_agent.ps1     # Build script for Windows

.github/workflows/
├── build-and-deploy.yml    # Unified build + deploy workflow
├── build-wasm.yml         # WASM-only builds
└── build-windows-x64.yml
```

## Build Process

## Prerequisites
- Rust toolchain: https://rustup.rs/
- wasm-pack: `cargo install wasm-pack`
- WASM target: `rustup target add wasm32-unknown-unknown`

### Manual Build

```bash
chmod +x build.sh
./build.sh
```

This will:
1. Use `wasm-pack build --target web` to generate WASM and JS bindings
2. Output files to `viewer/pkg/`
3. Generate `wasm_agent.js` and `wasm_agent_bg.wasm`

### Alternative Build

```bash
cd wasm-agent
wasm-pack build --target web --out-dir ../viewer/pkg --out-name wasm_agent
```
```

### Workflow Automation

The GitHub Actions workflow in `.github/workflows/build-and-deploy.yml` handles:
- WASM compilation for Linux/Mac
- Windows x64 compilation
- Artifact upload and deployment to viewer
- Verification

## Deployment

The `viewer/pkg/` directory contains:
- `wasm_agent.js` - Generated JavaScript bindings
- `wasm_agent_bg.wasm` - WebAssembly binary

The viewer automatically loads these files for all platforms.

## Testing

```bash
# Build and serve the viewer
npm install --prefix viewer
npm install --save-dev serve
npm link serve
npx serve viewer
```

## Architecture Notes

- WASM binary is universal for web browsers
- No platform-specific compilation needed
- Uses wasm-bindgen for seamless JS/WASM interop

## Platform Detection

The WASM code detects the platform via:
- `navigator.userAgent` for Windows/macOS
- `process.platform` for Node.js environments
- Browser headers for web environments
