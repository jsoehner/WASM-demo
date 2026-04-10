<!DOCTYPE html>
<html>
<head>
    <title>WASM Viewer</title>
    <meta http-equiv="Content-Security-Policy" content="default-src 'self' https:; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';">
    <style>
        body { font-family: sans-serif; max-width: 800px; margin: 2rem auto; padding: 1rem; background: #f8f9fa; }
        .card { background: white; padding: 20px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        input, select, button { padding: 10px; margin-bottom: 10px; width: 100%; box-sizing: border-box; }
        button { background: #007bff; color: white; border: none; cursor: pointer; }
        button:disabled { background: #ccc; cursor: not-allowed; }
        button:active { transform: scale(0.98); }
        #log { background: #212529; color: #39ff14; padding: 1rem; white-space: pre-wrap; margin-top: 10px; min-height: 80px; border-radius: 8px; }
        .spinner { display: inline-block; width: 20px; height: 20px; border: 3px solid rgba(255,255,255,.3); border-radius: 50%; border-top-color: #fff; animation: spin 1s ease-in-out infinite; margin-right: 8px; }
        @keyframes spin { to { transform: rotate(360deg); } }
        .error { color: #ff6b6b; }
        .info { color: #ffd32a; }
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
        <input type="text" id="prompt" value="Calculate the length of 'WebAssembly'." placeholder="Enter your prompt">
        <button id="run-btn">Execute Agent</button>
        <div id="log">Ready.</div>
    </div>
    <script type="module">
        import init, { Agent } from './pkg/wasm_agent.js';

        // Initialize WASM
        await init();
        
        const log = document.getElementById('log');
        const runBtn = document.getElementById('run-btn');
        const providerSelect = document.getElementById('provider');
        const modelIdInput = document.getElementById('model-id');
        const apiUrlInput = document.getElementById('api-url');
        const apiKeyInput = document.getElementById('api-key');
        const promptInput = document.getElementById('prompt');

        // Helper function to update log with loading state
        function setLoading(isLoading) {
            if (isLoading) {
                runBtn.disabled = true;
                runBtn.innerHTML = '<span class="spinner"></span>Processing...';
            } else {
                runBtn.disabled = false;
                runBtn.innerHTML = 'Execute Agent';
            }
        }

        // Helper function to display log messages
        function updateLog(message, isError = false) {
            log.textContent = message;
            log.classList.toggle('error', isError);
        }

        // Save API config to localStorage (optional)
        function saveConfig() {
            if (confirm('Would you like to save your API configuration? This will persist on this browser.')) {
                const config = {
                    provider: providerSelect.value,
                    modelId: modelIdInput.value,
                    apiUrl: apiUrlInput.value,
                    apiKey: apiKeyInput.value,
                    prompt: promptInput.value
                };
                localStorage.setItem('wasm-agent-config', JSON.stringify(config));
                alert('Configuration saved!');
            }
        }

        // Load config from localStorage if exists
        function loadConfig() {
            try {
                const saved = localStorage.getItem('wasm-agent-config');
                if (saved) {
                    const config = JSON.parse(saved);
                    providerSelect.value = config.provider;
                    modelIdInput.value = config.modelId;
                    apiUrlInput.value = config.apiUrl;
                    apiKeyInput.value = config.apiKey;
                    promptInput.value = config.prompt;
                }
            } catch (e) {
                console.error('Failed to load saved config:', e);
            }
        }

        // Load config on page load
        window.addEventListener('load', loadConfig);

        // Auto-save on form changes
        [providerSelect, modelIdInput, apiUrlInput, promptInput].forEach(input => {
            input.addEventListener('change', saveConfig);
        });

        // Use the agent
        runBtn.addEventListener('click', async () => {
            const log = document.getElementById('log');
            log.textContent = "Processing...";
            try {
                setLoading(true);
                const agent = new Agent(
                    document.getElementById('api-url').value,
                    document.getElementById('api-key').value,
                    document.getElementById('provider').value
                );
                const result = await agent.run_task(
                    document.getElementById('model-id').value,
                    document.getElementById('prompt').value
                );
                setLoading(false);
                log.textContent = result;
                log.classList.remove('error');
            } catch (e) {
                setLoading(false);
                console.error('Error:', e);
                let errorMessage = "Error: " + e;
                if (e.toString().includes('429') || e.toString().includes('rate limit')) {
                    errorMessage += '\n\n⚠️ Rate limit exceeded. Please wait a moment and try again.';
                } else if (e.toString().includes('401') || e.toString().includes('unauthorized')) {
                    errorMessage += '\n\n⚠️ Invalid API key. Please check your API key.';
                } else if (e.toString().includes('503') || e.toString().includes('unavailable')) {
                    errorMessage += '\n\n⚠️ Service unavailable. The LLM server may be overloaded.';
                }
                log.textContent = errorMessage;
                log.classList.add('error');
            }
        });
    </script>
</body>
</html>
