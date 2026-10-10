# CI/CD Setup for WASM Agent Viewer

This document describes the current GitHub Actions workflows for building,
validating, and releasing the universal browser package.

## Canonical Workflows

### 1. `build-and-release-viewer.yml` (primary release workflow)

Purpose:
- Build the WASM package
- Create release archive(s)
- Test distribution contents
- Publish GitHub Releases for `v*` tags
- Support optional nightly release via manual dispatch

Triggers:
- Push to `main`
- Pull requests to `main`
- Tag push `v*`
- Manual dispatch with `release_type`

### 2. `manual-build-viewer.yml` (manual package build)

Purpose:
- On-demand package build for testing or pre-release checks

Trigger:
- Manual dispatch only

### 3. `build-viewer.yml` (validation workflow)

Purpose:
- Build one canonical package on Linux
- Run extraction smoke tests on Linux, macOS, and Windows
- Verify that one package works across OS consumers

Triggers:
- Push to `main`
- Pull requests
- Manual dispatch

## Legacy Manual Workflows

These are retained for compatibility and manual troubleshooting only:

- `release-viewer.yml`
- `build-wasm.yml`
- `build-windows-x64.yml`
- `build-and-deploy.yml`

They no longer run automatically on push/PR/tag.

## Local Equivalents

Build and package locally:

```bash
./package.sh
```

Quick wrapper:

```bash
./build-and-package.sh
```

Manual compatibility wrapper:

```bash
./package-viewer.sh
```

## Notes

- Canonical package contract is validated in packaging scripts (`package.sh` and
  `package.ps1`).
- Build scripts now fail fast with actionable guidance if `cargo` is missing from
  `PATH`.
- Generated archives like `wasm-agent-viewer-*.zip` are ignored via root `.gitignore`.
