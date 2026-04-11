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
   # Extract and run the packaged distribution
   unzip wasm-agent-viewer-*.zip
   cd wasm-agent-viewer-* && ./start-server.sh
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

Note: `package-viewer.sh` is a compatibility wrapper and delegates to `./package.sh`.

This creates:
- **`wasm-agent-viewer-YYYYMMDD.zip`** - Cross-platform browser package
- **`wasm-agent-viewer-YYYYMMDD.tar.gz`** - Cross-platform browser package (if `zip` is unavailable, `tar.gz` is produced)

### Distribution Contents

The distribution package includes:
- **Web viewer** - `index.html`
- **WASM package** - `pkg/wasm_agent.js`, `pkg/wasm_agent_bg.wasm`, and `.d.ts` files
- **Server scripts** - `start-server.sh`, `start-server.bat`, `start-server.ps1`

### Running the Distribution

**Web Server Mode (Recommended):**
```bash
unzip wasm-agent-viewer-*.zip
cd wasm-agent-viewer-*
./start-server.sh  # Linux/macOS
# or
start-server.bat   # Windows
```

**Manual Serving:**
```bash
python3 -m http.server 8000
# Then open http://localhost:8000
```

## Architecture

- `wasm-agent/` - Rust crate compiled to WebAssembly
- `viewer/` - Web interface that loads and runs the WASM agent
- `build.sh` - Build script using wasm-pack

## Script Status

- Canonical build scripts: `build.sh`, `build.ps1`
- Canonical package scripts: `package.sh`, `package.ps1`
- Convenience wrapper: `build-and-package.sh`
- Compatibility wrapper: `package-viewer.sh` (delegates to `package.sh`)
- Deprecated legacy bootstrap scripts:
   - `build_and_copy_viewer.sh`
   - `build_and_run_agent.sh`
   - `build_and_run_agent.ps1`

## Supported Providers

- **OpenAI API**: Compatible with OpenAI, Open WebUI, and similar services
- **Ollama**: Native Ollama API support

## Distribution Options

### Universal Browser Distribution
- **Universal compatibility** - Works in any modern web browser
- **Zero install runtime** - Just extract and serve over HTTP
- **Cross-platform** - Same package works on Windows, macOS, Linux

### Archive Downloads
- **ZIP format** - `wasm-agent-viewer-YYYYMMDD.zip`
- **TAR.GZ format** - `wasm-agent-viewer-YYYYMMDD.tar.gz`
- **Complete packages** - Include all necessary files and documentation

## Development

See [BUILD.md](BUILD.md) for detailed build instructions and architecture notes.

## CI/CD Workflows

The project includes GitHub Actions workflows for automated building and packaging:

### Automated Release Workflow (`build-and-release-viewer.yml`)

**Triggers:**
- Push to `main` branch (builds and tests)
- Tag push with `v*` pattern (creates GitHub release)
- Manual trigger with release type options

**Features:**
- ✅ Builds WASM module
- ✅ Creates complete distribution packages
- ✅ Tests the distribution (server startup, file verification)
- ✅ Creates GitHub releases with downloadable packages
- ✅ Supports nightly builds

### Manual Build Workflow (`manual-build-viewer.yml`)

**Triggers:**
- Manual workflow dispatch only

**Features:**
- ✅ Builds WASM module
- ✅ Creates distribution packages
- ✅ Optional artifact upload
- ✅ Quick testing without releases

### Cross-OS Validation Workflow (`build-viewer.yml`)

**Purpose:**
- Builds one canonical archive package
- Validates extraction and package structure on Linux/macOS/Windows
- Confirms one package is consumable across OS environments

### Using the Workflows

**Manual Build:**
1. Go to GitHub Actions tab
2. Select "Manual Build Viewer Packages"
3. Click "Run workflow"
4. Optionally enable artifact upload
5. Download artifacts from the workflow run

**Creating Releases:**
1. Use the release script: `./release.sh patch` (or `minor`/`major`)
2. Or manually: `git tag v1.0.0 && git push origin v1.0.0`
3. The workflow will automatically build, test, and create a GitHub release
4. Users can download the browser package archive from the release

**Nightly Builds:**
1. Go to Actions → "Build and Release Viewer Packages"
2. Click "Run workflow" and select `nightly` release type
3. Creates or updates a `nightly` release with latest code

## Build Environment Notes

- `wasm-pack` requires `cargo` to be available in `PATH`.
- If Rust is installed but `cargo` is missing, add:

```bash
export PATH="$HOME/.cargo/bin:$PATH"
```

## Git Ignore

- Root `.gitignore` now ignores generated release archives:
   - `wasm-agent-viewer-*.zip`