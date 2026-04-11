# WASM LLM Agent Viewer

A WebAssembly-based LLM agent that runs entirely in your browser.

## Features

- **Runs entirely in the browser** using WebAssembly (no server needed)
- **Multiple LLM providers**: OpenAI API, Ollama (native)
- **Built-in tool calling**: Text analysis and more
- **Modern UI** with status indicators and error handling
- **Universal WASM** — works on any platform

## Directory Structure

```
dist/
├── index.html              # Main viewer HTML page
├── pkg/
│   ├── wasm_agent.js       # Generated JavaScript bindings
│   ├── wasm_agent_bg.wasm  # WebAssembly binary
│   ├── wasm_agent.d.ts     # TypeScript definitions
│   └── package.json
└── README.md               # This file
```

## Quick Start

### Option 1: Run the Server (Recommended)

WASM ES-module imports require HTTP — opening `index.html` directly with
`file://` will not work.

**Linux/macOS:**
```bash
./start-server.sh
```

**Windows (cmd):**
```cmd
start-server.bat
```

**Windows (PowerShell):**
```powershell
.\start-server.ps1
```

Then open http://localhost:8000 in your browser.

### Option 2: Manual Serving

Serve the contents of this directory with any web server:

```bash
# Python (any platform)
python3 -m http.server 8000

# Node.js
npx serve .

# PHP
php -S localhost:8000
```

## Configuration

### Provider Settings

| Field | Description | Example |
|-------|-------------|---------|
| Provider | Select LLM provider | OpenAI / Ollama |
| Model ID | Your LLM model | llama3, mistral |
| API URL | API endpoint | http://localhost:11434/api |
| API Key | Your API key (optional) | sk-*** |

### Tool Usage

The agent supports built-in tools using this syntax:

```
[TOOL: calculate_length:<text>]
```

## Available Tools

- **calculate_length** — returns the character count of the given text

## Supported Providers

### OpenAI-compatible
- OpenAI API, Open WebUI, LM Studio, Azure OpenAI Service, and any
   other OpenAI-API-compatible endpoint.

### Ollama (Native)
- Run directly with a local Ollama instance. No API key required.

## Requirements

### Browser
- Chrome, Firefox, Safari, or Edge (any current version)
- WebAssembly + ES Modules support (ES2020+)

### API
- Access to an LLM API endpoint
- Valid API credentials (if required by the provider)

## Troubleshooting

### WASM Loading Errors

**Symptom:** `Failed to load WASM module`

- Make sure you are serving over HTTP, not `file://`
- Verify the `pkg/` directory contains `wasm_agent.js` and
   `wasm_agent_bg.wasm`
- Rebuild if needed (see **Building from Source** below)

### CORS Errors

**Symptom:** `CORS policy blocked request`

- Serve via `http://localhost`, not `file://`
- Check the CORS settings on your API server

### API Connection Failed

**Symptom:** `HTTP 401 Unauthorized`

- Verify the API key is correct
- Confirm the API URL is reachable
- Ensure the LLM service is running

### Model Not Found

**Symptom:** `Model 'xxxx' not found`

- List available models on your API server
- For Ollama: `ollama pull <model-name>`

### Slow Performance

- Close unused browser tabs
- Try a lighter/smaller model
- Check your network connection

## Building from Source

The WASM binary in `pkg/` is universal — the same file works in Chrome,
Firefox, Safari, and Edge on Windows, macOS, and Linux.

**Prerequisites (one-time):**
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup target add wasm32-unknown-unknown
cargo install wasm-pack
```

**Build:**

Linux / macOS:
```bash
./build.sh
```

Windows:
```powershell
.\build.ps1
```

**Build + package into a distributable zip:**

Linux / macOS:
```bash
./package.sh
```

Windows:
```powershell
.\package.ps1
```

## CI/CD

Automated build and release workflows are in `.github/workflows/`:

| File | Trigger |
|------|---------|
| `build-and-deploy.yml` | Push to main |
| `build-and-release-viewer.yml` | Tag push (`v*`) or manual |
| `manual-build-viewer.yml` | Manual dispatch |

## Security Notes

- API keys are never sent outside your chosen LLM provider
- The viewer runs entirely in your browser — no backend server
- Clear browser storage (DevTools → Application → Local Storage) to
   remove any saved configuration

## License

MIT License
