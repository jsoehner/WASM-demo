# WASM Viewer Directory

This directory contains the browser UI and the generated WASM package used at runtime.

## Directory Structure

```text
viewer/
├── index.html
├── pkg/
│   ├── wasm_agent.js
│   ├── wasm_agent_bg.wasm
│   ├── wasm_agent.d.ts
│   └── wasm_agent_bg.wasm.d.ts
└── README.md
```

## Build Flow

Generate `pkg/` from the Rust crate:

Linux/macOS:

```bash
./build.sh
```

Windows:

```powershell
.\build.ps1
```

This project uses one browser-targeted WASM output (`wasm32-unknown-unknown`) and does
not require OS-specific WASM binaries.

## Local Run

Serve files over HTTP (do not open `index.html` directly with `file://`):

```bash
cd viewer
python3 -m http.server 8000
```

Then open `http://localhost:8000`.

## CI/CD

The release flow packages this viewer into a single archive that runs on all major OS
platforms in modern browsers.
