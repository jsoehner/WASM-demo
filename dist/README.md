# WASM LLM Agent Viewer Distribution

This directory represents an extracted runtime package for the browser demo.

## What This Package Contains

- `index.html` - viewer UI
- `pkg/wasm_agent.js` - WASM JS bindings
- `pkg/wasm_agent_bg.wasm` - universal browser WASM module
- `start-server.sh`, `start-server.bat`, `start-server.ps1` - local server helpers

## Run

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

Then open `http://localhost:8000`.

## Notes

- Serve over HTTP. Opening `index.html` with `file://` will fail for module/WASM loading.
- This package is OS-agnostic at runtime in modern browsers.
- Canonical build and packaging scripts are located at repository root:
  - `build.sh`, `build.ps1`
  - `package.sh`, `package.ps1`
