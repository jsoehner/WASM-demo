# ADR 0001: WASM Agent Memory Safety, SSE Buffer Handling, and CI Workflow Resilience

* **Status:** Accepted
* **Deciders:** WASM Demo Architecture & Core Engineering
* **Date:** 2026-09-19

---

## 1. Context & Problem Statement

Recent updates to the `wasm-agent` crate introduced compilation failures in Rust CI workflows (`Build and Release Viewer Packages` and `Validate Universal Viewer Package`):
1. **Move Out of Borrowed Reference**: In `execute_tool_calls`, `tool.id` was moved out of a borrowed slice reference (`&tool_calls`), violating Rust's ownership model since `String` does not implement `Copy`.
2. **Borrow Invalidation During Buffer Reallocation**: In the Server-Sent Events (SSE) streaming loop, `let line = buffer[..idx].trim()` held an immutable borrow into `buffer`, while `buffer = buffer[idx + 1..].to_string()` attempted to reassign `buffer`, causing rustc compiler error `E0506: cannot assign to buffer because it is borrowed`.
3. **Redundant Governance CI Failures**: Automated governance additions introduced broken commit-lint and changelog workflows that caused false-positive pipeline failures on `main`.

---

## 2. Decision Drivers

1. **Deterministic WebAssembly Compilation**: Rust source must compile cleanly under standard `wasm32-unknown-unknown` toolchains without ownership or lifetime violations.
2. **Streaming Efficiency & Safe Memory Handling**: SSE chunk processing must properly decouple line extraction from buffer truncation to ensure memory safety without unbounded heap churn.
3. **CI/CD Reliability**: Pipelines must only test and deploy valid assets without failing on invalid or unconfigured workflows.

---

## 3. Decision Outcome

Chosen Strategy: **Enforce explicit value cloning for tool identifiers, isolate owned SSE line strings prior to buffer reassignment, and prune redundant/malformed CI workflows.**

### Key Architectural Actions

1. **Tool Identifier Ownership (`wasm-agent/src/lib.rs`)**:
   - Cloned `tool.id` (`tool.id.clone()`) when pushing into `tool_results` to maintain ownership safety across iterations.
2. **SSE Buffer Management (`wasm-agent/src/lib.rs`)**:
   - Converted the trimmed slice `buffer[..idx].trim()` into an owned `String` (`.to_string()`) before truncating the underlying `buffer`, releasing the borrow before mutation.
3. **Compiler Cleanliness**:
   - Removed unnecessary `mut` declaration on `messages` vector in non-streaming invocations.
4. **CI Workflow Sanitization**:
   - Standardized `.github/workflows/security-testing.yml` to conditionally execute container scans only when a Dockerfile is present.

---

## 4. Consequences & Trade-Offs

### Positive Consequences
* WebAssembly package packaging and release workflows pass cleanly in CI.
* Eliminated Rust borrow checker errors and compilation failures.
* Streamlined GitHub Actions execution without false-positive failures.

### Considerations
* Additional string allocation per SSE line in WebAssembly runtime is negligible given typical token stream sizes.

---

## 5. Validation

- [x] Rust borrow checker errors resolved in `wasm-agent/src/lib.rs`.
- [x] Tested and verified clean code changes.
- [x] Updated documentation and architectural decision logs.
