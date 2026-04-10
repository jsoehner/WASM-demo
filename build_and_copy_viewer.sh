#!/bin/bash

# Build and copy WASM binaries for each platform to viewer directory

# Create viewer directory if it doesn't exist
mkdir -p viewer/pkg

# Build for each platform
echo "Building WASM for Windows x64..."
cargo build --target x86_64-pc-windows-msvc --release --out-dir target/x86_64-pc-windows-msvc/release 2>/dev/null || true

echo "Building WASM for Linux..."
cargo build --target x86_64-unknown-linux-gnu --release --out-dir target/x86_64-unknown-linux-gnu/release 2>/dev/null || true

echo "Building WASM for macOS..."
cargo build --target x86_64-apple-darwin --release --out-dir target/x86_64-apple-darwin/release 2>/dev/null || true

# Copy platform-specific binaries to viewer
echo "Copying WASM binaries to viewer..."

# Linux binary
if [ -f "target/x86_64-unknown-linux-gnu/release/*.wasm" ]; then
    cp target/x86_64-unknown-linux-gnu/release/*.wasm viewer/pkg/linux-wasm_agent.wasm
fi

# Windows binary
if [ -f "target/x86_64-pc-windows-msvc/release/*.wasm" ]; then
    cp target/x86_64-pc-windows-msvc/release/*.wasm viewer/pkg/windows-x64-wasm_agent.wasm
fi

# macOS binary
if [ -f "target/x86_64-apple-darwin/release/*.wasm" ]; then
    cp target/x86_64-apple-darwin/release/*.wasm viewer/pkg/macos-wasm_agent.wasm
fi

echo "Done! WASM binaries copied to viewer/pkg/"

# Update the HTML to use the correct paths
echo "Updating viewer HTML for platform detection..."

platform="linux"
if [ "$OSTYPE" == "msys" ] || [ "$OSTYPE" == "win32" ]; then
    platform="windows"
elif [ -f "/usr/bin/osascript" ]; then
    platform="macos"
fi

cat << EOF > viewer/index.html
<!DOCTYPE html>
<html>
<head>
    <title>WASM Viewer</title>
    <style>
        body { font-family: sans-serif; max-width: 800px; margin: 2rem auto; padding: 1rem; background: #f8f9fa; }
        .card { background: white; padding: 20px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        input, select, button { padding: 10px; margin-bottom: 10px; width: 100%; box-sizing: border-box; }
        button { background: #007bff; color: white; border: none; cursor: pointer; }
        #log { background: #212529; color: #39ff14; padding: 1rem; white-space: pre-wrap; margin-top: 10px; min-height: 80px; }
    </style>
</head>
<body>
    <div class="card">
        <h2>🤖 Multi-Provider WASM Agent</h2>
        <select id="provider">
            <option value="openai">OpenAI / Open WebUI</option>
            <option value="ollama">Ollama (Native)</option>
        </select>
        <input type="text" id="model-id" value="llama3" placeholder="Model ID">
        <input type="text" id="api-url" value="http://localhost:11434/api" placeholder="API URL">
        <input type="password" id="api-key" placeholder="API Key (Optional)">
        <input type="text" id="prompt" value="Calculate the length of 'WebAssembly'.">
        <button id="run-btn">Execute Agent</button>
        <div id="log">Ready.</div>
    </div>
    <script type="module">
        // Detect platform and load corresponding WASM binary
        const platform = '${platform}';
        const wasmPath = platform === 'windows' ? './windows-x64-wasm_agent.wasm' :
                         platform === 'linux' ? './linux-wasm_agent.wasm' :
                         './macos-wasm_agent.wasm';

        async function loadWasm() {
            try {
                const response = await fetch(wasmPath);
                const arrayBuffer = await response.arrayBuffer();
                const wasmData = new Uint8Array(arrayBuffer);
                const wasmModule = await WebAssembly.instantiateStreaming(response, {
                    'wasm_agent': {'instance': {}}
                });
                
                // Export from the WASM module
                const { init, Agent } = wasmModule.instance.exports;
                init();
                
                // Use the agent
                document.getElementById('run-btn').addEventListener('click', async () => {
                    const log = document.getElementById('log');
                    log.textContent = "Processing...";
                    try {
                        const agent = new Agent(
                            document.getElementById('api-url').value,
                            document.getElementById('api-key').value,
                            document.getElementById('provider').value
                        );
                        log.textContent = await agent.run_task(
                            document.getElementById('model-id').value,
                            document.getElementById('prompt').value
                        );
                    } catch (e) {
                        log.textContent = "Error: " + e;
                    }
                });
            } catch (e) {
                console.error('Error loading WASM:', e);
                document.getElementById('log').textContent = "Error loading WASM: " + e;
            }
        }
        
        loadWasm();
    </script>
</body>
</html>
EOF

echo "HTML updated for platform: $platform"
echo "Viewer is ready at: viewer/index.html"
"