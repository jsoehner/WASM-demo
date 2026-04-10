Write-Host "🚀 Setting up Multi-Platform WASM Agent (Windows)..." -ForegroundColor Cyan

# --- 1. TOOLCHAIN SETUP ---
$CARGO_BIN = "$HOME\.cargo\bin"
if (-not (Test-Path "$CARGO_BIN\cargo.exe")) {
    Write-Host "🛠️ Rustup not found. Installing..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri https://win.rustup.rs/x86_64 -OutFile rustup-init.exe
    .\rustup-init.exe -y --no-modify-path
    Remove-Item rustup-init.exe
}

$env:Path += ";$CARGO_BIN"

& "$CARGO_BIN\rustup.exe" target add wasm32-unknown-unknown

if (-not (Get-Command wasm-pack -ErrorAction SilentlyContinue)) {
    Write-Host "📦 Installing wasm-pack..." -ForegroundColor Yellow
    & "$CARGO_BIN\cargo.exe" install wasm-pack
}

# --- 2. PROJECT GENERATION ---
if (-not (Test-Path "wasm-agent")) { New-Item -ItemType Directory -Path "wasm-agent" }
Set-Location "wasm-agent"

# Cargo.toml
$CargoToml = @"
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
"@
$CargoToml | Set-Content -Path "Cargo.toml" -Encoding UTF8

# src/lib.rs
if (-not (Test-Path "src")) { New-Item -ItemType Directory -Path "src" }
$RustCode = @"
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
        let mut messages = vec![
            LlmMessage { role: "system".to_string(), content: "You are a WASM agent. Tool: [TOOL: calculate_length: <text>]".to_string() },
            LlmMessage { role: "user".to_string(), content: prompt }
        ];
        let mut response_text = self.call_llm(&model, &messages).await?;
        if response_text.contains("[TOOL: calculate_length:") {
            let start = response_text.find("[TOOL: calculate_length: ").unwrap() + 25;
            let end = response_text.find("]").unwrap();
            let target = &response_text[start..end];
            let tool_res = format!("The length of '{}' is {} characters.", target, target.len());
            messages.push(LlmMessage { role: "assistant".to_string(), content: response_text });
            messages.push(LlmMessage { role: "user".to_string(), content: tool_res });
            response_text = self.call_llm(&model, &messages).await?;
        }
        Ok(JsValue::from_str(&response_text))
    }

    async fn call_llm(&self, model: &str, messages: &Vec<LlmMessage>) -> Result<String, JsValue> {
        let mut opts = RequestInit::new();
        opts.method("POST");
        opts.mode(RequestMode::Cors);
        let (full_url, body_str) = if (self.provider -eq "ollama") {
            (format!("{}/chat", self.api_url.trim_end_matches('/')), 
             serde_json::to_string(&OllamaRequest { model: model.to_string(), messages: messages.clone(), stream: false }).unwrap())
        } else {
            (format!("{}/chat/completions", self.api_url.trim_end_matches('/')), 
             serde_json::to_string(&OpenAiRequest { model: model.to_string(), messages: messages.clone(), stream: false }).unwrap())
        };
        opts.body(Some(&JsValue::from_str(&body_str)));
        let req = Request::new_with_str_and_init(&full_url, &opts)?;
        req.headers().set("Content-Type", "application/json")?;
        if (!self.api_key.is_empty()) { req.headers().set("Authorization", &format!("Bearer {}", self.api_key))?; }
        let win = window().unwrap();
        let resp_val = JsFuture::from(win.fetch_with_request(&req)).await?;
        let resp: Response = resp_val.dyn_into().unwrap();
        if (!resp.ok()) { return Err(JsFuture::from(resp.text()?).await?); }
        let json = JsFuture::from(resp.json()?).await?;
        if (self.provider -eq "ollama") {
            let r: OllamaResponse = serde_wasm_bindgen::from_value(json)?; Ok(r.message.content)
        } else {
            let r: OpenAiResponse = serde_wasm_bindgen::from_value(json)?; Ok(r.choices[0].message.content.clone())
        }
    }
}
"@
$RustCode | Set-Content -Path "src/lib.rs" -Encoding UTF8

# index.html
$Html = @"
<!DOCTYPE html>
<html>
<head><title>Multi-Platform WASM Agent</title><style>body{font-family:sans-serif;max-width:800px;margin:2rem auto;padding:1rem;background:#f8f9fa;}.card{background:white;padding:20px;border-radius:12px;}input,select,button{padding:10px;margin-bottom:10px;width:100%;}button{background:#007bff;color:white;border:none;cursor:pointer;}#log{background:#212529;color:#39ff14;padding:1rem;white-space:pre-wrap;min-height:80px;}</style></head>
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
                const log = document.getElementById('log'); log.textContent = "Processing...";
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
"@
$Html | Set-Content -Path "index.html" -Encoding UTF8

# --- 3. BUILD & RUN ---
Write-Host "⚙️ Compiling..." -ForegroundColor Cyan
& "$CARGO_BIN\wasm-pack.exe" build --target web

Write-Host "🚀 Starting server..." -ForegroundColor Green
python -m http.server 8080
