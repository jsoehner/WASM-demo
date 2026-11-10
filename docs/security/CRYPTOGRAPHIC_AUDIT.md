## 🛡️ Cryptographic Bill of Materials (CBOM) & PQC Migration Assessment

**Format**: CycloneDX (v1.7) | **First-Party Code Crypto Assets**: 37 | **Total Tracked Crypto Assets**: 0

### 📊 Post-Quantum Migration Scorecard

| Metric | Count | Migration Status |
|---|---|---|
| **Post-Quantum Ready (PQC)** | **0** | 🟢 Quantum-Resistant (NIST FIPS 203/204/205) |
| **Quantum-Vulnerable (Backlog)** | **0** | 🔴 At Risk of 'Harvest Now, Decrypt Later' |
| **Classical Symmetric / Digest** | **0** | 🟡 Classical Security (Requires AES-256 / SHA-256+) |
| **Asymmetric PQC Migration Progress** | **N/A (0 detected)** | (No asymmetric primitives detected in current scope) |

### 🎯 Cryptographic Supply Chain Coverage & Confidence

| Evaluation Layer | Coverage / Status | Audit Confidence Assessment |
|---|---|---|
| **First-Party Code (`src/`, `scripts/`)** | **100% Audited** (37 Crypto Primitive(s) Inventoried) | 🟢 **HIGH** (Direct AST & SAST verified) |
| **Third-Party Supply Chain** | **0.0%** (0 of 29 dependencies cataloged) | 🔴 LOW (Known profiles assimilated) |
| **Overall Audit Confidence Score** | **3.3%** | 🔴 LOW (29 unassimilated supply chain dependencies) |

| **System OS Inventory** | **Pending Update** | 🟡 **Warning** (Local OS crypto components not yet inventoried) |

### ✅ Post-Quantum Ready Assets

> ⚠️ **No Post-Quantum Ready assets detected.** Immediate migration planning recommended for asymmetric key exchanges and digital signatures.

### ⚠️ Quantum-Vulnerable Assets & Remediation Plan

> ℹ️ **No quantum-vulnerable asymmetric assets found.** Asymmetric cryptographic primitives were not detected in current scope.

### 🔒 Classical Symmetric & Digest Assets

> ℹ️ **No classical symmetric assets detected.**

### ⚠️ Unassimilated Third-Party Binaries & Cryptographic Blind Spots

> ℹ️ *The following third-party dependencies do not have verified upstream CBOM attestations in the catalog. They lower the audit confidence score until explicit CBOMs or attestations are published.* 

| Dependency Name | Version | Package URL (purl) | Status |
|---|---|---|---|
| `bumpalo` | 3.20.2 | `cpe:2.3:a:bumpalo:bumpalo:3.20.2:*:*:*:*:*:*:*` | 🟡 Unassimilated (No upstream CBOM) |
| `cfg-if` | 1.0.4 | `cpe:2.3:a:cfg-if:cfg-if:1.0.4:*:*:*:*:*:*:*` | 🟡 Unassimilated (No upstream CBOM) |
| `futures-core` | 0.3.32 | `cpe:2.3:a:futures-core:futures-core:0.3.32:*:*:*:*:*:*:*` | 🟡 Unassimilated (No upstream CBOM) |
| `futures-task` | 0.3.32 | `cpe:2.3:a:futures-task:futures-task:0.3.32:*:*:*:*:*:*:*` | 🟡 Unassimilated (No upstream CBOM) |
| `futures-util` | 0.3.32 | `cpe:2.3:a:futures-util:futures-util:0.3.32:*:*:*:*:*:*:*` | 🟡 Unassimilated (No upstream CBOM) |
| `itoa` | 1.0.18 | `cpe:2.3:a:itoa:itoa:1.0.18:*:*:*:*:*:*:*` | 🟡 Unassimilated (No upstream CBOM) |
| `js-sys` | 0.3.94 | `cpe:2.3:a:js-sys:js-sys:0.3.94:*:*:*:*:*:*:*` | 🟡 Unassimilated (No upstream CBOM) |
| `memchr` | 2.8.0 | `cpe:2.3:a:memchr:memchr:2.8.0:*:*:*:*:*:*:*` | 🟡 Unassimilated (No upstream CBOM) |
| `once_cell` | 1.21.4 | `cpe:2.3:a:once-cell:once-cell:1.21.4:*:*:*:*:*:*:*` | 🟡 Unassimilated (No upstream CBOM) |
| `pin-project-lite` | 0.2.17 | `cpe:2.3:a:pin-project-lite:pin-project-lite:0.2.17:*:*:*:*:*:*:*` | 🟡 Unassimilated (No upstream CBOM) |
| `proc-macro2` | 1.0.106 | `cpe:2.3:a:proc-macro2:proc-macro2:1.0.106:*:*:*:*:*:*:*` | 🟡 Unassimilated (No upstream CBOM) |
| `quote` | 1.0.45 | `cpe:2.3:a:quote:quote:1.0.45:*:*:*:*:*:*:*` | 🟡 Unassimilated (No upstream CBOM) |
| `rustversion` | 1.0.22 | `cpe:2.3:a:rustversion:rustversion:1.0.22:*:*:*:*:*:*:*` | 🟡 Unassimilated (No upstream CBOM) |
| `serde` | 1.0.228 | `cpe:2.3:a:serde:serde:1.0.228:*:*:*:*:*:*:*` | 🟡 Unassimilated (No upstream CBOM) |
| `serde-wasm-bindgen` | 0.6.5 | `cpe:2.3:a:serde-wasm-bindgen:serde-wasm-bindgen:0.6.5:*:*:*:*:*:*:*` | 🟡 Unassimilated (No upstream CBOM) |
| *... and 14 more unassimilated dependencies* | | | |
