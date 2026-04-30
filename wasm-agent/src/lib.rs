use wasm_bindgen::prelude::*;
use wasm_bindgen_futures::JsFuture;
use web_sys::{Headers, Request, RequestInit, RequestMode, Response, ReadableStreamDefaultReader};
use serde::{Deserialize, Serialize};
use js_sys::Uint8Array;

// ============ Message / Response Types ============

#[derive(Serialize, Deserialize, Clone, Debug)]
struct LlmMessage {
    role: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    content: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    tool_calls: Option<Vec<ToolCall>>,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
struct ToolCall {
    id: String,
    #[serde(rename = "type")]
    call_type: String,
    function: ToolFunction,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
struct ToolFunction {
    name: String,
    arguments: String,
}

#[derive(Deserialize, Debug)]
struct OpenAiResponse {
    choices: Vec<OpenAiChoice>,
}

#[derive(Deserialize, Debug)]
struct OpenAiChoice {
    message: LlmMessage,
}

#[derive(Deserialize, Debug)]
struct OllamaResponse {
    message: LlmMessage,
}

#[derive(Deserialize, Debug)]
struct StreamDelta {
    choices: Vec<StreamChoice>,
}

#[derive(Deserialize, Debug)]
struct StreamChoice {
    delta: StreamDeltaContent,
}

#[derive(Deserialize, Debug)]
struct StreamDeltaContent {
    content: Option<String>,
}

// ============ Init ============

#[wasm_bindgen(start)]
pub fn start() {
    console_error_panic_hook::set_once();
}

// ============ Agent ============

#[wasm_bindgen]
pub struct Agent {
    api_url: String,
    api_key: String,
    provider: String,
}

#[wasm_bindgen]
impl Agent {
    #[wasm_bindgen(constructor)]
    pub fn new(api_url: String, api_key: String, provider: String) -> Agent {
        Agent { api_url, api_key, provider }
    }

    /// Run a task against the configured LLM provider.
    pub async fn run_task(
        &self,
        model: String,
        prompt: String,
        system_prompt: String,
        temperature: f32,
    ) -> Result<String, JsValue> {
        if !self.api_url.starts_with("http://") && !self.api_url.starts_with("https://") {
            return Err(JsValue::from_str(
                "Invalid API URL: must start with http:// or https://",
            ));
        }

        let providers = ["openai", "ollama", "openrouter"];
        if !providers.contains(&self.provider.as_str()) {
            return Err(JsValue::from_str(
                &format!("Invalid provider: must be one of {:?}", providers),
            ));
        }

        // Sanitize inputs
        let prompt: String = prompt.chars().filter(|&c| c != '\0').take(50_000).collect();
        let model: String = model.chars().filter(|&c| c != '\0').take(200).collect();
        let system_prompt = if system_prompt.is_empty() {
            "You are a WASM agent. Answer the user directly and clearly.".to_string()
        } else {
            system_prompt.chars().filter(|&c| c != '\0').take(5_000).collect()
        };

        let mut messages = vec![
            LlmMessage { role: "system".to_string(), content: Some(system_prompt), tool_calls: None },
            LlmMessage { role: "user".to_string(), content: Some(prompt), tool_calls: None },
        ];

        let response = self.call_llm(&model, &messages, temperature).await?;
        
        // Handle tool calls if any (for non-streaming)
        if let Some(tool_calls) = response.tool_calls {
            let mut tool_results = Vec::new();
            for tool in tool_calls {
                if tool.function.name == "get_wasm_info" {
                    let result = self.execute_get_wasm_info();
                    tool_results.push((tool.id, result));
                }
            }

            if !tool_results.is_empty() {
                messages.push(response); // Push the assistant's message with tool calls
                for (id, result) in tool_results {
                    messages.push(LlmMessage {
                        role: "tool".to_string(),
                        content: Some(result),
                        tool_calls: None,
                        // Note: Some APIs require tool_call_id here
                    });
                }
                // Call again with tool results
                // This is a simplified recursive call (limit to 1 level for safety in demo)
                let second_resp = self.call_llm(&model, &messages, temperature).await?;
                return second_resp.content.ok_or_else(|| JsValue::from_str("No content after tool call"));
            }
        }

        response.content.ok_or_else(|| JsValue::from_str("No content in response"))
    }

    fn execute_get_wasm_info(&self) -> String {
        serde_json::json!({
            "environment": "WebAssembly (WASM)",
            "runtime": "Browser",
            "memory_limit": "4GB (browser standard)",
            "capabilities": ["Compute", "Web-Fetch", "Tool-Calling"],
            "version": "0.2.1-premium"
        }).to_string()
    }

    async fn call_llm(
        &self,
        model: &str,
        messages: &[LlmMessage],
        temperature: f32,
    ) -> Result<LlmMessage, JsValue> {
        let (url, body) = if self.provider == "ollama" {
            let url = format!("{}/chat", self.api_url.trim_end_matches('/'));
            let body = serde_json::json!({
                "model": model,
                "messages": messages,
                "stream": false,
                "options": {
                    "temperature": temperature
                }
            });
            (url, body.to_string())
        } else {
            // OpenAI-compatible
            let url = format!("{}/chat/completions", self.api_url.trim_end_matches('/'));
            let body = serde_json::json!({
                "model": model,
                "messages": messages,
                "stream": false,
                "temperature": temperature,
                "tools": [
                    {
                        "type": "function",
                        "function": {
                            "name": "get_wasm_info",
                            "description": "Get information about the WASM environment, capabilities, and version.",
                            "parameters": {
                                "type": "object",
                                "properties": {},
                                "required": []
                            }
                        }
                    }
                ]
            });
            (url, body.to_string())
        };

        let headers = Headers::new()
            .map_err(|_| JsValue::from_str("Failed to create request headers"))?;
        headers
            .set("Content-Type", "application/json")
            .map_err(|_| JsValue::from_str("Failed to set Content-Type header"))?;
        if !self.api_key.is_empty() {
            headers
                .set("Authorization", &format!("Bearer {}", self.api_key))
                .map_err(|_| JsValue::from_str("Failed to set Authorization header"))?;
        }
        if self.provider == "openrouter" {
            headers
                .set("X-Title", "WASM Agent")
                .map_err(|_| JsValue::from_str("Failed to set X-Title header"))?;
            headers
                .set("HTTP-Referer", "https://github.com/jsoehner/wasm-demo")
                .map_err(|_| JsValue::from_str("Failed to set HTTP-Referer header"))?;
        }

        let opts = RequestInit::new();
        opts.set_method("POST");
        opts.set_mode(RequestMode::Cors);
        opts.set_headers(&headers);
        opts.set_body(&JsValue::from_str(&body));

        let request = Request::new_with_str_and_init(&url, &opts)
            .map_err(|_| JsValue::from_str("Failed to create HTTP request"))?;

        let window =
            web_sys::window().ok_or_else(|| JsValue::from_str("No window object available"))?;

        let resp_val = JsFuture::from(window.fetch_with_request(&request)).await?;
        let resp: Response = resp_val
            .dyn_into()
            .map_err(|_| JsValue::from_str("Failed to interpret fetch response"))?;

        if !resp.ok() {
            let status = resp.status();
            let err_text = JsFuture::from(
                resp.text()
                    .map_err(|_| JsValue::from_str("Failed to read error body"))?,
            )
            .await?;
            let err_msg = err_text.as_string().unwrap_or_default();
            return Err(JsValue::from_str(&format!(
                "HTTP {}: {}",
                status,
                if err_msg.len() > 300 { format!("{}...", &err_msg[..300]) } else { err_msg }
            )));
        }

        let text_val = JsFuture::from(
            resp.text()
                .map_err(|_| JsValue::from_str("Failed to read response body"))?,
        )
        .await?;
        let raw = text_val
            .as_string()
            .ok_or_else(|| JsValue::from_str("Response body is not a string"))?;

        if self.provider == "ollama" {
            serde_json::from_str::<OllamaResponse>(&raw)
                .map(|r| r.message)
                .map_err(|e| JsValue::from_str(&format!("Ollama parse error: {}. Raw: {}", e, raw)))
        } else {
            serde_json::from_str::<OpenAiResponse>(&raw)
                .map_err(|e| JsValue::from_str(&format!("OpenAI parse error: {}. Raw: {}", e, raw)))
                .and_then(|r| {
                    r.choices
                        .into_iter()
                        .next()
                        .map(|c| c.message)
                        .ok_or_else(|| JsValue::from_str("No choices in OpenAI response"))
                })
        }
    }

    /// Run a task with streaming support.
    pub async fn run_task_stream(
        &self,
        model: String,
        prompt: String,
        system_prompt: String,
        temperature: f32,
        on_chunk: js_sys::Function,
        signal: Option<web_sys::AbortSignal>,
    ) -> Result<(), JsValue> {
        let providers = ["openai", "ollama", "openrouter"];
        if !providers.contains(&self.provider.as_str()) {
            return Err(JsValue::from_str(&format!("Invalid provider: {:?}", providers)));
        }

        let mut messages = vec![
            LlmMessage { role: "system".to_string(), content: Some(system_prompt), tool_calls: None },
            LlmMessage { role: "user".to_string(), content: Some(prompt), tool_calls: None },
        ];

        let (url, body) = if self.provider == "ollama" {
            let url = format!("{}/chat", self.api_url.trim_end_matches('/'));
            let body = serde_json::json!({
                "model": model,
                "messages": messages,
                "stream": true,
                "options": { "temperature": temperature }
            });
            (url, body.to_string())
        } else {
            let url = format!("{}/chat/completions", self.api_url.trim_end_matches('/'));
            let body = serde_json::json!({
                "model": model,
                "messages": messages,
                "stream": true,
                "temperature": temperature,
            });
            (url, body.to_string())
        };

        let headers = Headers::new()?;
        headers.set("Content-Type", "application/json")?;
        if !self.api_key.is_empty() {
            headers.set("Authorization", &format!("Bearer {}", self.api_key))?;
        }

        let opts = RequestInit::new();
        opts.set_method("POST");
        opts.set_mode(RequestMode::Cors);
        opts.set_headers(&headers);
        opts.set_body(&JsValue::from_str(&body));
        if let Some(ref s) = signal {
            opts.set_signal(Some(s));
        }

        let request = Request::new_with_str_and_init(&url, &opts)?;
        let window = web_sys::window().ok_or_else(|| JsValue::from_str("No window"))?;
        let resp_val = JsFuture::from(window.fetch_with_request(&request)).await?;
        let resp: Response = resp_val.dyn_into()?;

        if !resp.ok() {
            return Err(JsValue::from_str(&format!("HTTP error: {}", resp.status())));
        }

        let body = resp.body().ok_or_else(|| JsValue::from_str("No body"))?;
        let reader = body.get_reader().dyn_into::<ReadableStreamDefaultReader>()?;
        
        let decoder = web_sys::TextDecoder::new()?;
        let mut buffer = String::new();

        loop {
            let read_val = JsFuture::from(reader.read()).await?;
            let result: js_sys::Object = read_val.dyn_into()?;
            let done = js_sys::Reflect::get(&result, &JsValue::from_str("done"))?
                .as_bool()
                .unwrap_or(true);
            
            if done { break; }

            let chunk_val = js_sys::Reflect::get(&result, &JsValue::from_str("value"))?;
            let chunk_uint8: Uint8Array = chunk_val.dyn_into()?;
            let chunk_text = decoder.decode_with_u8_array(&chunk_uint8)?;
            
            buffer.push_str(&chunk_text);

            // Process lines (SSE format)
            while let Some(idx) = buffer.find('\n') {
                let line = buffer[..idx].trim();
                buffer = buffer[idx + 1..].to_string();

                if line.is_empty() { continue; }

                if self.provider == "ollama" {
                    if let Ok(res) = serde_json::from_str::<OllamaResponse>(line) {
                        if let Some(content) = res.message.content {
                            on_chunk.call1(&JsValue::NULL, &JsValue::from_str(&content))?;
                        }
                    }
                } else {
                    // OpenAI / OpenRouter
                    if line.starts_with("data: ") {
                        let data = &line[6..];
                        if data == "[DONE]" { break; }
                        
                        if let Ok(res) = serde_json::from_str::<StreamDelta>(data) {
                            if let Some(choice) = res.choices.get(0) {
                                if let Some(content) = &choice.delta.content {
                                    on_chunk.call1(&JsValue::NULL, &JsValue::from_str(content))?;
                                }
                            }
                        }
                    }
                }
            }
        }

        Ok(())
    }
}
