# Build the WASM module on Windows.
# Prerequisites:
#   rustup target add wasm32-unknown-unknown
#   cargo install wasm-pack
#
# Usage: .\build.ps1
$ErrorActionPreference = "Stop"

if (-not (Get-Command wasm-pack -ErrorAction SilentlyContinue)) {
    Write-Error "wasm-pack not found.`nInstall with: cargo install wasm-pack`nAlso run:     rustup target add wasm32-unknown-unknown"
    exit 1
}

Push-Location "$PSScriptRoot\wasm-agent"
try {
    Write-Host "Building WASM module..."
    wasm-pack build --target web --out-dir ..\viewer\pkg --out-name wasm_agent
    Write-Host "Build complete. Files written to viewer\pkg\"
} finally {
    Pop-Location
}
