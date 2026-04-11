# Distribution Usage Guide

## Overview

This package runs one browser-targeted WASM build across Windows, macOS, and Linux.
No OS-specific WASM file selection is required.

## Quick Start

1. Start a local server from the package root.

Linux/macOS:

```bash
./start-server.sh
```

Windows cmd:

```cmd
start-server.bat
```

Windows PowerShell:

```powershell
./start-server.ps1
```

2. Open `http://localhost:8000`.

## Required Files

- `index.html`
- `pkg/wasm_agent.js`
- `pkg/wasm_agent_bg.wasm`

## Troubleshooting

### Module/WASM loading issues

- Ensure you are using HTTP and not `file://`.
- Verify all required files are present.

### API request failures

- Validate provider URL, model ID, and API credentials.
- Check network and CORS behavior of upstream API endpoints.
