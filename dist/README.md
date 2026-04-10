# WASM Viewer Directory

This directory contains the WebAssembly viewer with platform-specific WASM binaries.

## Directory Structure

```
viewer/
├── index.html          # Main viewer HTML page
├── pkg/
│   ├── wasm_agent.js       # Generated JavaScript bindings
│   └── wasm_agent_bg.wasm  # WebAssembly binary
└── README.md           # This file
```

## Platform Detection

The viewer uses a universal WASM binary that works in all modern web browsers.

## Building the WASM Binaries

### Using the build scripts

**For Windows (PowerShell):**
```powershell
.\build_and_copy_viewer.ps1
```

**For Linux/macOS (Bash):**
```bash
chmod +x build_and_copy_viewer.sh
./build_and_copy_viewer.sh
```

### Manual Build Process

1. **Build for each platform:**
   ```bash
   # Linux
   cargo build --target x86_64-unknown-linux-gnu --release --out-dir target/x86_64-unknown-linux-gnu/release
   
   # Windows x64
   cargo build --target x86_64-pc-windows-msvc --release --out-dir target/x86_64-pc-windows-msvc/release
   
   # macOS
   cargo build --target x86_64-apple-darwin --release --out-dir target/x86_64-apple-darwin/release
   ```

2. **Copy WASM binaries to viewer:**
   ```bash
   mkdir -p viewer/pkg
   cp target/x86_64-unknown-linux-gnu/release/*.wasm viewer/pkg/linux-wasm_agent.wasm
   cp target/x86_64-pc-windows-msvc/release/*.wasm viewer/pkg/windows-x64-wasm_agent.wasm
   cp target/x86_64-apple-darwin/release/*.wasm viewer/pkg/macos-wasm_agent.wasm
   ```

3. **Update HTML for your platform:**
   ```bash
   ./build_and_copy_viewer.sh
   ```

## Using the Viewer

1. Open `viewer/index.html` in a web browser
2. Configure your LLM provider settings
3. Click "Execute Agent" to run tasks

## CI/CD Setup

For automated builds, use the GitHub Actions workflow in `.github/workflows/build-viewer.yml`
