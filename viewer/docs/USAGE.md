# WASM Viewer Usage Guide

## Overview

The viewer loads a single browser-portable WASM package from `viewer/pkg/`.
No platform-specific WASM selection is required.

## Quick Start

1. Build the WASM package:

```bash
./build.sh
```

2. Serve the viewer directory:

```bash
cd viewer
python3 -m http.server 8000
```

3. Open `http://localhost:8000`.

## Runtime Requirements

- Modern browser with WebAssembly support
- HTTP serving (not `file://`)

## Key Files

- `viewer/index.html`
- `viewer/pkg/wasm_agent.js`
- `viewer/pkg/wasm_agent_bg.wasm`

## Troubleshooting

### WASM file fails to load

- Verify `viewer/pkg/wasm_agent_bg.wasm` exists.
- Confirm browser console does not show 404 for `pkg/wasm_agent.js`.
- Ensure files are served by HTTP.

### API request failures

- Check provider URL and model values.
- Validate API key if required.
- Confirm CORS policy on upstream API.
