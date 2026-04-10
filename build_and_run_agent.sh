#!/bin/bash
set -e

echo "🚀 Setting up Multi-Platform WASM Agent (Bash)..."

# --- 1. TOOLCHAIN SETUP ---
# Standard Rust path on macOS
export PATH="$HOME/.rustup/toolchains/stable-aarch64-apple-darwin/bin:$PATH"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

if ! command_exists rustup; then
    echo "🛠️  Rustup not found. Installing via official installer..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    source "$HOME/.cargo/env"
fi

# Use the global command rather than a hardcoded sub-path
rustup target add wasm32-unknown-unknown

if ! command_exists wasm-pack; then
    echo "📦 Installing wasm-pack..."
    cargo install wasm-pack
fi

# --- 2. PROJECT GENERATION ---
mkdir -p wasm-agent
cd wasm-agent

# Cargo.toml
cat << 'EOF' > Cargo.toml
[package]
name = "wasm-agent"
version = "0.1.0"
edition = "2021"

[lib]
crate-type = ["cdylib"]

[dependencies]
wasm-bindgen = "0.2"
wasm-bindgen-futures = "0.4"
js-sys = "0.3"
web-sys = { version = "0.3", features = ["Window", "Request", "RequestInit", "RequestMode", "Response", "Headers", "console"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
serde-wasm-bindgen = "0.6"
EOF

# src/lib.rs (Dual Provider Logic)
mkdir -p src
cat << 'EOF' > src/lib.rs
use wasm_bindgen::prelude::*;
use wasm_bindgen_futures::JsFuture;
use web_sys::{Request, RequestInit, RequestMode, Response, window};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone)]
struct LlmMessage { role: String, content: String }
#[derive(Serialize, Deserialize)]
struct OpenAiRequest { model: String, messages: Vec<LlmMessage>, stream: bool }
#[derive(Serialize, Deserialize)]
struct OllamaRequest { model: String, messages: Vec<LlmMessage>, stream: bool }
#[derive(Serialize, Deserialize)]
struct OpenAiResponse { choices: Vec<OpenAiChoice> }
#[derive(Serialize, Deserialize)]
struct OpenAiChoice { message: LlmMessage }
#[derive(Serialize, Deserialize)]
struct OllamaResponse { message: LlmMessage }

#[wasm_bindgen]
pub struct Agent { api_url: String, api_key: String, provider: String }

#[wasm_bindgen]
impl Agent {
    #[wasm_bindgen(constructor)]
    pub fn new(api_url: String, api_key: String, provider: String) -> Agent {
        Agent { api_url, api_key, provider }
    }

    #[wasm_bindgen]
    pub async fn run_task(&self, model: String, prompt: String) -> Result<JsValue, JsValue> {
        let system_prompt = "You are a WASM agent. Tool: [TOOL: calculate_length: <text>]";
        let mut messages = vec![
            LlmMessage { role: "system".to_string(), content: system_prompt.to_string() },
            LlmMessage { role: "user".to_string(), content: prompt }
        ];

        let mut response_text = self.call_llm(&model, &messages).await?;

        if response_text.contains("[TOOL: calculate_length:") {
            let start = response_text.find("[TOOL: calculate_length: ").unwrap() + 25;
            let end = response_text.find("]").unwrap();
            let target_text = &response_text[start..end];
            let tool_result = format!("The length of '{}' is {} characters.", target_text, target_text.len());
            messages.push(LlmMessage { role: "assistant".to_string(), content: response_text });
            messages.push(LlmMessage { role: "user".to_string(), content: format!("Tool result: {}", tool_result) });
            response_text = self.call_llm(&model, &messages).await?;
        }
        Ok(JsValue::from_str(&response_text))
    }

    async fn call_llm(&self, model: &str, messages: &Vec<LlmMessage>) -> Result<String, JsValue> {
        let mut opts = RequestInit::new();
        opts.method("POST");
        opts.mode(RequestMode::Cors);

        let (full_url, body_str) = if self.provider == "ollama" {
            (format!("{}/chat", self.api_url.trim_end_matches('/')), 
             serde_json::to_string(&OllamaRequest { model: model.to_string(), messages: messages.clone(), stream: false }).unwrap())
        } else {
            (format!("{}/chat/completions", self.api_url.trim_end_matches('/')), 
             serde_json::to_string(&OpenAiRequest { model: model.to_string(), messages: messages.clone(), stream: false }).unwrap())
        };

        opts.body(Some(&JsValue::from_str(&body_str)));
        let request = Request::new_with_str_and_init(&full_url, &opts)?;
        request.headers().set("Content-Type", "application/json")?;
        if !self.api_key.is_empty() { request.headers().set("Authorization", &format!("Bearer {}", self.api_key))?; }

        let window = window().unwrap();
        let resp_value = JsFuture::from(window.fetch_with_request(&request)).await?;
        let resp: Response = resp_value.dyn_into().unwrap();
        if !resp.ok() { return Err(JsFuture::from(resp.text()?).await?); }

        let json_value = JsFuture::from(resp.json()?).await?;
        if self.provider == "ollama" {
            let res: OllamaResponse = serde_wasm_bindgen::from_value(json_value)?;
            Ok(res.message.content)
        } else {
            let res: OpenAiResponse = serde_wasm_bindgen::from_value(json_value)?;
            Ok(res.choices[0].message.content.clone())
        }
    }
}
EOF

# index.html
cat << 'EOF' > index.html
<!DOCTYPE html>
<html>
<head><title>Multi-Platform WASM Agent</title><style>body{font-family:sans-serif;max-width:800px;margin:2rem auto;padding:1rem;background:#f8f9fa;}.card{background:white;padding:20px;border-radius:12px;box-shadow:0 4px 15px rgba(0,0,0,0.1);}input,select,button{padding:10px;margin-bottom:10px;width:100%;box-sizing:border-box;}button{background:#007bff;color:white;border:none;cursor:pointer;}#log{background:#212529;color:#39ff14;padding:1rem;white-space:pre-wrap;margin-top:10px;min-height:80px;}</style></head>
<body>
    <div class="card">
        <h2>🤖 Multi-Provider Agent</h2>
        <select id="provider"><option value="openai">OpenAI / Open WebUI</option><option value="ollama">Ollama (Native)</option></select>
        <input type="text" id="model-id" value="llama3" placeholder="Model ID">
        <input type="text" id="api-url" value="http://localhost:11434/api" placeholder="API URL">
        <input type="password" id="api-key" placeholder="API Key (Optional)">
        <input type="text" id="prompt" value="Calculate the length of 'WebAssembly'.">
        <button id="run-btn">Execute Agent</button>
        <div id="log">Ready.</div>
    </div>
    <script type="module">
        import init, { Agent } from './pkg/wasm_agent.js';
        async function run() {
            await init();
            document.getElementById('run-btn').addEventListener('click', async () => {
                const log = document.getElementById('log');
                log.textContent = "Processing...";
                try {
                    const agent = new Agent(document.getElementById('api-url').value, document.getElementById('api-key').value, document.getElementById('provider').value);
                    log.textContent = await agent.run_task(document.getElementById('model-id').value, document.getElementById('prompt').value);
                } catch (e) { log.textContent = "Error: " + e; }
            });
        }
        run();
    </script>
</body>
</html>
EOF

echo "⚙️  Compiling..."
wasm-pack build --target web
echo "🚀 Starting server..."
python3 -m http.server 8080
