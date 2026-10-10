# ADR 0002: Consolidate Security Governance, Pin Action SHAs, and Enforce Supply-Chain Integrity

* **Status:** Accepted
* **Deciders:** WASM Demo Security & Architecture
* **Date:** 2026-09-25

---

## 1. Context & Problem Statement

A security and static analysis audit across the repository identified multiple supply-chain, script injection, and integrity risks:
1. **Redundant & Conflicting Workflows**: An unhardened `.github/workflows/security-testing.yml` from a previous template install conflicted with centralized security governance standards.
2. **Mutable GitHub Actions Tags**: Multiple CI workflows (`build-and-deploy.yml`, `build-and-release-viewer.yml`, `build-viewer.yml`, `build-wasm.yml`, `build-windows-x64.yml`, `manual-build-viewer.yml`, `release-viewer.yml`) used mutable major version tags (e.g., `@v4`, `@stable`, `@v2`, `@v7`), exposing pipelines to tag-mutation and supply-chain compromises.
3. **CWE-78 Shell Script Injection**: `.github/workflows/release-viewer.yml` interpolated untrusted input `${{ github.event.inputs.version }}` directly within an inline `run:` bash script block.
4. **Subresource Integrity (SRI) Missing**: `index.html` fetched CDN-hosted stylesheets and scripts (`highlight.js`, `marked`) without cryptographic `integrity` hashes and `crossorigin` attributes.
5. **Dependabot Cooldown Missing**: `.github/dependabot.yml` lacked a package cooldown period, which could cause immediate pulling of newly released and potentially malicious package versions.

---

## 2. Decision Drivers

1. **Supply-Chain Immutability**: All third-party GitHub Actions must be pinned to full 40-character commit SHAs.
2. **Defensive Pipeline Scripting**: Script parameters and context values must be passed via runner environment variables (`env:`) rather than inline string interpolation.
3. **Single Authoritative Security Workflow**: Standardize on `security-governance.yml` incorporating Gitleaks secret detection, Semgrep SAST, Trivy dependency scanning, and automated ADR Gatekeeper validation, removing legacy/redundant testing workflows.
4. **Browser Subresource Integrity (SRI)**: External CDN resources must be cryptographically hashed to protect client-side execution from third-party CDN tampering.
5. **Zero Semgrep Findings**: All SAST and configuration scans must pass with zero blocking findings.

---

## 3. Decision Outcome

Chosen Strategy: **Deploy unified `security-governance.yml` and Python ADR gatekeeper, remove legacy `security-testing.yml`, pin all workflow action tags to full commit SHAs, isolate bash script variables in runner environment, add SRI hashes to `index.html`, and configure Dependabot cooldown.**

### Key Architectural Actions

1. **Security Workflow Consolidation**:
   - Removed `.github/workflows/security-testing.yml`.
   - Added `.github/workflows/security-governance.yml` as the authoritative scanning pipeline.
   - Deployed `scripts/adr_security_gatekeeper.py` to enforce ADR creation for security-sensitive PRs.
2. **Action SHA Pinning**:
   - Pinned `actions/checkout` to `11d5960a326750d5838078e36cf38b85af677262` (`v4.2.2`).
   - Pinned `dtolnay/rust-toolchain` to `02cb101ec7c40f2c49e1d9714d64511d8e1b74de`.
   - Pinned `Swatinem/rust-cache` to `49a0bdc70d2e1b713ca9e2869b211fcce03d3c1c` (`v2.7.7`).
   - Pinned `jetli/wasm-pack-action` to `0d096b08b4e5a7de8c28de67e11e945404e9eefa` (`v0.4.0`).
   - Pinned `actions/upload-artifact` to `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a` (`v7.0.1`).
   - Pinned `actions/download-artifact` to `d3f86a106a0bac45b974a628896c90dbdf5c8093` (`v4.1.9`).
   - Pinned `softprops/action-gh-release` to `3bb12739c298aeb8a4eeaf626c5b8d85266b0e65` (`v2.2.1`).
3. **Remediate Script Injection**:
   - Refactored `release-viewer.yml` to define `INPUT_VERSION: ${{ github.event.inputs.version }}` in step `env:` and access `"$INPUT_VERSION"` safely.
4. **Subresource Integrity (SRI)**:
   - Added SHA-384 cryptographic integrity hashes and `crossorigin="anonymous"` to CDN assets in `index.html`.
5. **Dependabot Cooldown**:
   - Configured `cooldown: default-days: 7` in `.github/dependabot.yml`.

---

## 4. Consequences & Trade-Offs

### Positive Consequences
* Eliminated 50 Semgrep blocking findings down to 0 findings.
* Immune to tag-hijacking and upstream tampering on GitHub Actions.
* Single source of truth for repository security policies and automated checks.
* Protection against client-side CDN compromise via Subresource Integrity.

### Considerations
* Third-party action upgrades require intentional SHA updates (automated via Dependabot with 7-day cooldown).

---

## 5. Validation

- [x] Semgrep scan completed with 0 findings across all 992 files (`docker run ... semgrep scan --config auto`).
- [x] Automated ADR Gatekeeper script verified.
- [x] All workflows verified syntactically valid YAML.
