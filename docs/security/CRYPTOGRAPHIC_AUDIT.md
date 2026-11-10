## 🛡️ Cryptographic Bill of Materials (CBOM) & PQC Migration Assessment

**Format**: CycloneDX (v1.6) | **First-Party Code Crypto Assets**: 0 | **Total Tracked Crypto Assets**: 0

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
| **First-Party Code (`src/`, `scripts/`)** | **100% Audited** (0 Custom Primitives) | 🟢 **HIGH** (Direct AST & SAST verified) |
| **Third-Party Supply Chain** | **35.6%** (26 of 73 dependencies cataloged) | 🔴 LOW (Known profiles assimilated) |
| **Overall Audit Confidence Score** | **36.5%** | 🔴 LOW (47 unassimilated supply chain dependencies) |

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
| `Swatinem/rust-cache` | v2.7.7 | `pkg:github/Swatinem/rust-cache@v2.7.7` | 🟡 Unassimilated (No upstream CBOM) |
| `Swatinem/rust-cache` | v2.7.7 | `pkg:github/Swatinem/rust-cache@v2.7.7` | 🟡 Unassimilated (No upstream CBOM) |
| `Swatinem/rust-cache` | v2.7.7 | `pkg:github/Swatinem/rust-cache@v2.7.7` | 🟡 Unassimilated (No upstream CBOM) |
| `Swatinem/rust-cache` | v2.7.7 | `pkg:github/Swatinem/rust-cache@v2.7.7` | 🟡 Unassimilated (No upstream CBOM) |
| `Swatinem/rust-cache` | v2.7.7 | `pkg:github/Swatinem/rust-cache@v2.7.7` | 🟡 Unassimilated (No upstream CBOM) |
| `Swatinem/rust-cache` | v2.7.7 | `pkg:github/Swatinem/rust-cache@v2.7.7` | 🟡 Unassimilated (No upstream CBOM) |
| `bumpalo` | 3.20.2 | `pkg:cargo/bumpalo@3.20.2` | 🟡 Unassimilated (No upstream CBOM) |
| `cfg-if` | 1.0.4 | `pkg:cargo/cfg-if@1.0.4` | 🟡 Unassimilated (No upstream CBOM) |
| `console_error_panic_hook` | 0.1.7 | `pkg:cargo/console_error_panic_hook@0.1.7` | 🟡 Unassimilated (No upstream CBOM) |
| `dtolnay/rust-toolchain` | 02cb101ec7c40f2c49e1d9714d64511d8e1b74de | `pkg:github/dtolnay/rust-toolchain@02cb101ec7c40f2c49e1d9714d64511d8e1b74de` | 🟡 Unassimilated (No upstream CBOM) |
| `dtolnay/rust-toolchain` | 02cb101ec7c40f2c49e1d9714d64511d8e1b74de | `pkg:github/dtolnay/rust-toolchain@02cb101ec7c40f2c49e1d9714d64511d8e1b74de` | 🟡 Unassimilated (No upstream CBOM) |
| `dtolnay/rust-toolchain` | 02cb101ec7c40f2c49e1d9714d64511d8e1b74de | `pkg:github/dtolnay/rust-toolchain@02cb101ec7c40f2c49e1d9714d64511d8e1b74de` | 🟡 Unassimilated (No upstream CBOM) |
| `dtolnay/rust-toolchain` | 02cb101ec7c40f2c49e1d9714d64511d8e1b74de | `pkg:github/dtolnay/rust-toolchain@02cb101ec7c40f2c49e1d9714d64511d8e1b74de` | 🟡 Unassimilated (No upstream CBOM) |
| `dtolnay/rust-toolchain` | 02cb101ec7c40f2c49e1d9714d64511d8e1b74de | `pkg:github/dtolnay/rust-toolchain@02cb101ec7c40f2c49e1d9714d64511d8e1b74de` | 🟡 Unassimilated (No upstream CBOM) |
| `dtolnay/rust-toolchain` | 02cb101ec7c40f2c49e1d9714d64511d8e1b74de | `pkg:github/dtolnay/rust-toolchain@02cb101ec7c40f2c49e1d9714d64511d8e1b74de` | 🟡 Unassimilated (No upstream CBOM) |
| *... and 32 more unassimilated dependencies* | | | |
