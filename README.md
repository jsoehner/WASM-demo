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

2. **Build the project:**
   ```bash
   ./build.sh
   ```

3. **Open the viewer:**
   ```bash
   # Serve the viewer directory (requires a web server due to CORS)
   cd viewer && python3 -m http.server 8000
   # Then open http://localhost:8000 in your browser
   ```

## Architecture

- `wasm-agent/` - Rust crate compiled to WebAssembly
- `viewer/` - Web interface that loads and runs the WASM agent
- `build.sh` - Build script using wasm-pack

## Supported Providers

- **OpenAI API**: Compatible with OpenAI, Open WebUI, and similar services
- **Ollama**: Native Ollama API support

## Development

See [BUILD.md](BUILD.md) for detailed build instructions and architecture notes.