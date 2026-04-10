# WASM Viewer Package

This directory contains platform-specific WASM binaries for each operating system.

## Platform-Specific Binaries

- `windows-x64-wasm_agent.wasm` - For Windows x64
- `linux-wasm_agent.wasm` - For Linux
- `macos-wasm_agent.wasm` - For macOS (Intel/Apple Silicon)

## Usage

The viewer (`index.html`) will automatically select the appropriate WASM binary based on the user's platform.

