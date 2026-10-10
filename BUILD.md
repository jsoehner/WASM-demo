# Build and Deployment Guide

## Overview

This project builds a browser-targeted WebAssembly module once and packages it as a
single cross-platform browser distribution. The same release archive runs on
Windows, macOS, and Linux in modern browsers.

## Canonical Build Target

- Rust target: `wasm32-unknown-unknown`
- Build tool: `wasm-pack`
- Output location: `pkg/`

The generated artifacts are browser portable:

- `pkg/wasm_agent.js`
- `pkg/wasm_agent_bg.wasm`
- `pkg/wasm_agent.d.ts`
- `pkg/wasm_agent_bg.wasm.d.ts`

## Local Build Commands

### Build only

```bash
./build.sh
```

### Build and package

```bash
./build.sh --package
```

## Distribution Package Contract

A release package must contain:

- `index.html`
- `pkg/wasm_agent.js`
- `pkg/wasm_agent_bg.wasm`
- `pkg/wasm_agent.d.ts`
- `pkg/wasm_agent_bg.wasm.d.ts`
- `pkg/package.json`
- `start-server.sh`
- `start-server.bat`
- `start-server.ps1`

## Runtime

Extract the archive and run one startup script:

- Linux/macOS: `./start-server.sh`
- Windows cmd: `start-server.bat`
- Windows PowerShell: `./start-server.ps1`

Then open `http://localhost:8000`.

## CI/CD Intent

The release pipeline should publish one universal browser package artifact.
Optional multi-OS checks can validate extraction and startup behavior of that same
archive, but do not need per-OS WASM compilation outputs.

## Architecture Notes

- Browser portability comes from the WASM target, not host OS-specific binaries.
- Build wrappers can differ by shell (bash/PowerShell) while producing the same
  package manifest.
- Platform-specific native binary naming is intentionally out of scope for this demo.
