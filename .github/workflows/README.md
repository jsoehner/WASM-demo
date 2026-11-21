# CI/CD Setup for WASM Agent Viewer

This document describes the active GitHub Actions workflows for building,
verifying, securing, and releasing the universal browser package.

## Active Workflows

### 1. `build-and-release-viewer.yml` (Primary Build & Release)

Purpose:
- Build the WASM package (`./build.sh --package`)
- Create universal browser distribution archive(s) (`.zip` / `.tar.gz`)
- Test distribution contents and local server startup
- Publish GitHub Releases on pushes to `main`
- Support on-demand manual builds and nightly releases via `workflow_dispatch`

Triggers:
- Push to `main`
- Pull requests to `main`
- Manual dispatch with `release_type` (`beta`, `stable`, `nightly`)

### 2. `verify.yml` (JSI Build & Functional Verification)

Purpose:
- Invokes the reusable `jsoehner/jsi-build-verify` workflow (Pi Coding Agent) for end-to-end build and functional verification
- Posts a verdict and token usage summary comment on pull requests

Triggers:
- Pull requests
- Manual dispatch

### 3. `security-governance.yml` (Security & ADR Gates)

Purpose:
- Secret leak detection (Gitleaks)
- SAST scanning (Semgrep)
- Dependency & supply chain scanning (Trivy)
- ADR security gatekeeper on pull requests

### 4. `sbom-cbom.yml` (SBOM, CBOM & PQC Governance)

Purpose:
- Generates and verifies multi-language SBOM/CBOM artifacts via `jsoehner/jsi-bom-actions`

### 5. `commit-lint.yml` (Commit Hygiene)

Purpose:
- Enforces Conventional Commits on pushes and pull requests targeting `main`

## Local Build

Build and package locally:

```bash
./build.sh --package
```

Generated archives (`wasm-agent-viewer-*.zip`, `wasm-agent-viewer-*.tar.gz`) are ignored via root `.gitignore`.
