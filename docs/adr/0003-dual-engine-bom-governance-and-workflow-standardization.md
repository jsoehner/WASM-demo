# ADR 0003: Dual-Engine BOM Governance and Workflow Standardization

* **Status:** Accepted
* **Deciders:** WASM Demo Security & Architecture
* **Date:** 2026-09-27

---

## 1. Context & Problem Statement

To prevent workflow duplication and enforce cryptographic and software supply chain security, CI/CD pipelines must avoid running overlapping security jobs while providing comprehensive Software Bill of Materials (SBOM) and Cryptographic Bill of Materials (CBOM) capabilities.

Previously, the repository lacked standardized dual-engine BOM generation, automated BOM schema verification in CI, and unified commit linting standards.

---

## 2. Decision Drivers

1. **Standardized Dual-Engine BOM Suite**: Deploy `.github/workflows/sbom.yml` to generate Syft SPDX/CycloneDX SBOMs and CycloneDX 1.6/1.7 CBOMs via `@cyclonedx/cdxgen --include-crypto`.
2. **Semantic AST Cryptographic Discovery**: Incorporate `scripts/scan_crypto_ast.py` to reconcile cryptographic call sites directly into `oss/cbom.json`.
3. **Automated Verification Gate**: Enforce automated pre-flight testing using `scripts/test_boms.sh` in CI.
4. **PQC Readiness Analysis**: Automate Post-Quantum Cryptography migration assessment via `scripts/analyze_cbom.py`.
5. **Commit Hygiene Standard**: Deploy `.github/workflows/commit-lint.yml` using `wagoid/commitlint-github-action@v6.2.1` and `changelog.yml` for release automation.

---

## 3. Decision Outcome

1. Deployed `.github/workflows/sbom.yml`, `commit-lint.yml`, and `changelog.yml`.
2. Installed local audit scripts (`generate_boms.sh`, `scan_crypto_ast.py`, `analyze_cbom.py`, `test_boms.sh`) in `scripts/`.
3. Updated `scripts/adr_security_gatekeeper.py` to support `--actor` parameter passed by `security-governance.yml`.

---

## 4. Consequences & Verification

- **Positive**: Every release and pull request generates cryptographically validated SBOMs and CBOMs.
- **Positive**: ADR Security Gatekeeper successfully validates pull requests against security-sensitive path changes.
- **Verification**: Executed `bash scripts/test_boms.sh oss` locally; all 4/4 verification gates passed.
