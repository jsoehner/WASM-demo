# WASM LLM Agent Viewer

A WebAssembly-based LLM agent that runs entirely in your browser.

## Quick Start

### Option 1: Run the Server (Recommended)

**Linux/macOS:**
```bash
./start-server.sh
```

**Windows:**
```cmd
start-server.bat
```

Then open http://localhost:8000 in your browser.

### Option 2: Manual Serving

Serve the contents of this directory with any web server:

```bash
# Using Python
python3 -m http.server 8000

# Using Node.js (if installed)
npx serve .

# Using PHP
php -S localhost:8000
```

## Features

- 🤖 Runs entirely in the browser using WebAssembly
- 🔄 Supports multiple LLM providers (OpenAI API, Ollama)
- 🛠️ Built-in tool calling capabilities
- 🌐 Universal WASM binary for all platforms

## Usage

1. Open the viewer in your browser
2. Select your LLM provider (OpenAI/Ollama)
3. Configure your API settings
4. Enter a prompt and click "Execute Agent"

## Supported Providers

- **OpenAI API**: Compatible with OpenAI, Open WebUI, and similar services
- **Ollama**: Native Ollama API support

## Requirements

- Modern web browser with WebAssembly support
- Internet connection for LLM API access

## Troubleshooting

### CORS Issues
If you encounter CORS errors, make sure you're accessing the viewer through a web server (not opening index.html directly).

### WASM Loading Errors
Ensure your browser supports WebAssembly. Modern versions of Chrome, Firefox, Safari, and Edge all support WASM.
