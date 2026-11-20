# Build & Functional Verification Report

- **Verification Date:** `2026-11-20`
- **Verified By:** **Jeffs' Automated build and deploy agent**
- **Repository:** `jsoehner/WASM-demo` (`main`)
- **Result:** ✅ **VERIFIED FUNCTIONAL**

---

## 1. Trusted OSS Split-Horizon Configuration

Configured via `setup_trusted_oss_repo.py` in `virtual` mode:

| Scope | Endpoint / Setting |
| :--- | :--- |
| Local LAN Cache (`.env`, git-excluded) | `http://oss.jsigroup.local:8080` (`/healthz` → HTTP `200`) |
| GitHub Actions Variable (`TRUSTED_OSS_CACHE_URL`) | `https://jsigroup-oss.duckdns.org` |
| GitHub Actions Variable (`TRUSTED_OSS_MODE`) | `virtual` |
| GitHub Actions Variable (`TRUSTED_OSS_GPG_EMAIL`) | `oss-signing@the-techy.com` |
| GitHub Actions Secrets | `OSS_MTLS_CLIENT_CERT`, `OSS_MTLS_CLIENT_KEY` |

> **Ecosystem Note:** Trusted OSS Harbor does not currently expose a Cargo/crates.io proxy (`/cargo/virtual/` and `/crates/virtual/` return `404`). Rust dependencies for `wasm-agent` were resolved deterministically via `wasm-agent/Cargo.lock` and local Cargo cache.

---

## 2. Build, Package & Test Commands

```bash
export PATH="$HOME/.cargo/bin:$PATH"

# Build WASM module (wasm32-unknown-unknown) and create distribution archive
./build.sh --package

# Compile & run Rust test harness
cargo test --manifest-path wasm-agent/Cargo.toml

# Validate Python governance/BOM helper scripts syntax
python3 -m py_compile scripts/*.py
```

### Build & Test Outcomes
- **Toolchain:** `rustc 1.94.1`, `cargo 1.94.1`, `wasm-pack 0.14.0`, target `wasm32-unknown-unknown`
- **WASM Build:** ✅ `wasm-agent v0.2.0` compiled with release optimization (`wasm-opt`) in `19.51s`
  - `pkg/wasm_agent_bg.wasm`: `136,962 bytes`
  - `pkg/wasm_agent.js`: `22,181 bytes`
  - TypeScript definitions: `pkg/wasm_agent.d.ts`, `pkg/wasm_agent_bg.wasm.d.ts`
- **Distribution Archive:** ✅ `wasm-agent-viewer-20261120.zip` (`78 KB`) packaged with `index.html`, `pkg/*`, `start-server.sh`, `start-server.bat`, and `start-server.ps1`
- **Cargo Test:** ✅ Compiled and executed (`0 passed; 0 failed` — no unit tests currently defined in `wasm-agent/src/lib.rs`)
- **Python Scripts (`scripts/*.py`):** ✅ `py_compile` passed with zero syntax errors

---

## 3. Functional Verification

Extracted `wasm-agent-viewer-20261120.zip` to an isolated temporary directory and launched `./start-server.sh 18084 127.0.0.1`.

### HTTP / Asset Probes (`api_verify.py` & `curl`)

| Endpoint | Expected | Actual | Content-Type | Size | Result |
| :--- | :---: | :---: | :--- | ---: | :---: |
| `GET http://127.0.0.1:18084/` | `2xx` | `200` | `text/html` | `25,440 B` | ✅ PASS |
| `GET http://127.0.0.1:18084/pkg/wasm_agent.js` | `2xx` | `200` | `text/javascript` | `22,181 B` | ✅ PASS |
| `GET http://127.0.0.1:18084/pkg/wasm_agent_bg.wasm` | `2xx` | `200` | `application/wasm` | `136,962 B` | ✅ PASS |
| `GET http://127.0.0.1:18084/nonexistent` | `404` | `404` | `text/html;charset=utf-8` | `460 B` | ✅ PASS |

### Guided Headless Chrome Verification (`browser_verify.py`)

| Check | Result | Details |
| :--- | :---: | :--- |
| Initial Load (`http://127.0.0.1:18084/`) | ✅ PASS | HTTP `200`, Title: `WASM LLM Agent \| Premium Edition`, Expected text `WASM Agent` found |
| Console Errors / Uncaught Exceptions | ✅ PASS | `0` console errors, `0` JS exceptions |
| Interactive Click (`.advanced-toggle`) | ✅ PASS | Revealed `System Instructions` and `Temperature 0.7` controls |
| Interactive Validation (`#run-btn`) | ✅ PASS | Empty message submission cleanly displayed `Error: Please enter a message.` with `0` uncaught exceptions |
