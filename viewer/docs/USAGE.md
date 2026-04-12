# WASM Viewer Usage Guide

## Overview

The viewer loads a single browser-portable WASM package from `viewer/pkg/`.
No platform-specific WASM selection is required. The same binary runs on desktop
(macOS, Linux, Windows) and mobile (Android Chrome, iOS Safari) browsers.

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

## Testing on Android and iOS

To test on a physical mobile device over your local network:

1. Find your machine's LAN IP address (e.g. `192.168.1.42`).
2. Start the server bound to all interfaces:

```bash
cd viewer
python3 -c "
from http.server import HTTPServer, SimpleHTTPRequestHandler
class H(SimpleHTTPRequestHandler):
    extensions_map = {**SimpleHTTPRequestHandler.extensions_map, '.wasm': 'application/wasm'}
    def log_message(self, fmt, *args): pass
HTTPServer(('0.0.0.0', 8000), H).serve_forever()
"
```

3. On your device (connected to the same Wi-Fi), open `http://192.168.1.42:8000`.

**Browser requirements:**
- Android: Chrome 57+ or Firefox for Android 52+
- iOS: Safari 11+ (iOS 11+)

No special server headers (COOP/COEP) are needed because this WASM module does
not use threads or SharedArrayBuffer.

## Runtime Requirements

- Modern browser with WebAssembly support
- HTTP serving (not `file://`)
- If the browser does not support WebAssembly, the viewer displays a clear error
  message listing supported browser versions.

## Key Files

- `viewer/index.html`
- `viewer/pkg/wasm_agent.js`
- `viewer/pkg/wasm_agent_bg.wasm`

## Troubleshooting

### WASM file fails to load

- Verify `viewer/pkg/wasm_agent_bg.wasm` exists.
- Confirm browser console does not show 404 for `pkg/wasm_agent.js`.
- Ensure files are served by HTTP.
- Ensure the server sets `Content-Type: application/wasm` for `.wasm` files (the
  included `start-server.*` scripts handle this automatically).

### App does not render correctly on mobile

- Ensure the device is running a browser that supports WebAssembly (see above).
- Rotate to landscape if the form feels cramped — the layout is responsive.
- iOS: if the page is blank, check that JavaScript is enabled in Safari Settings.

### API request failures

- Check provider URL and model values.
- Validate API key if required.
- Confirm CORS policy on upstream API.
