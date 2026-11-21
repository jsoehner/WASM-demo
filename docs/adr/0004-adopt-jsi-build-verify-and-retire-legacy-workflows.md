# ADR 0004: Adopt `jsi-build-verify` Reusable Workflow and Retire Legacy CI Workflows

* **Status:** Accepted
* **Deciders:** WASM Demo Security & Architecture
* **Date:** 2026-11-21

---

## 1. Context & Problem Statement

The repository accumulated five overlapping legacy manual GitHub Actions workflows (`build-and-deploy.yml`, `build-wasm.yml`, `build-windows-x64.yml`, `manual-build-viewer.yml`, and `release-viewer.yml`) that duplicated the canonical `build-and-release-viewer.yml` pipeline, referenced removed scripts (`./package.sh`), and increased maintenance and supply-chain surface area.

At the same time, automated functional verification (building the WASM package, serving `index.html`, and verifying live browser rendering with headless Chrome) was not running as an automated PR gate.

---

## 2. Decision Drivers

1. **Automated Functional PR Verification**: Adopt the reusable `jsoehner/jsi-build-verify` workflow in PR test-harness mode (`commit_mode: report-only`, `fail_on_error: true`, `comment_on_pr: true`) with zero-config auto-detection and Trusted OSS mTLS support.
2. **Supply-Chain Integrity (ADR 0002)**: Pin the reusable workflow `uses:` reference and `workflow_ref` input to an immutable 40-character commit SHA (`87d28a2c228e88f106e1021676f6cdb8a6c6a292`) rather than a mutable `@main` branch ref.
3. **Minimal Workflow Surface Area**: Remove the five redundant legacy manual workflows and keep only the five active canonical workflows (`build-and-release-viewer.yml`, `verify.yml`, `security-governance.yml`, `sbom-cbom.yml`, `commit-lint.yml`).

---

## 3. Decision Outcome

1. Added `.github/workflows/verify.yml` invoking `jsoehner/jsi-build-verify/.github/workflows/jsi-build-verify.yml` (SHA-pinned to `87d28a2c228e88f106e1021676f6cdb8a6c6a292`) on `pull_request` and `workflow_dispatch`.
2. Configured `GEMINI_API_KEY` in repository Actions secrets alongside existing Trusted OSS mTLS credentials (`OSS_MTLS_CLIENT_CERT`, `OSS_MTLS_CLIENT_KEY`, and `TRUSTED_OSS_*` variables).
3. Removed `build-and-deploy.yml`, `build-wasm.yml`, `build-windows-x64.yml`, `manual-build-viewer.yml`, and `release-viewer.yml`, and updated `.github/workflows/README.md` and `README.md`.

---

## 4. Consequences & Verification

- **Positive**: Pull requests now receive automated end-to-end WASM build and headless Chrome browser verification with structured verdicts, screenshots, and token/cost accounting.
- **Positive**: Reduced active CI workflows from 10 to 5, eliminating dead legacy pipelines and keeping all external workflow references SHA-pinned.
- **Verification**: Verified end-to-end on PR #24 (run `44908420156`, `pass` verdict in 3m 44s: `wasm-pack` build + headless Chrome verification with zero console errors).
