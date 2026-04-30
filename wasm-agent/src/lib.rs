use wasm_bindgen::prelude::*;
use wasm_bindgen_futures::JsFuture;
use web_sys::{Headers, Request, RequestInit, RequestMode, Response};
use serde::{Deserialize, Serialize};

// ============ Message / Response Types ============

#[derive(Serialize, Deserialize, Clone)]
struct LlmMessage {
    role: String,
    content: String,
}

#[derive(Deserialize)]
struct OpenAiResponse {
    choices: Vec<OpenAiChoice>,
}

#[derive(Deserialize)]
struct OpenAiChoice {
    message: LlmMessage,
}

#[derive(Deserialize)]
struct OllamaResponse {
    message: LlmMessage,
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

        if self.provider != "openai" && self.provider != "ollama" && self.provider != "openrouter" {
            return Err(JsValue::from_str(
                "Invalid provider: must be openai, ollama, or openrouter",
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

        let messages = vec![
            LlmMessage { role: "system".to_string(), content: system_prompt },
            LlmMessage { role: "user".to_string(), content: prompt },
        ];

        self.call_llm(&model, &messages, temperature).await
    }

    async fn call_llm(
        &self,
        model: &str,
        messages: &[LlmMessage],
        temperature: f32,
    ) -> Result<String, JsValue> {
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
                            "description": "Get information about the WASM environment",
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
            let safe_err_msg = if err_msg.len() > 200 {
                format!("{}...", &err_msg[..200])
            } else {
                err_msg
            };
            return Err(JsValue::from_str(&format!(
                "HTTP {}: {}",
                status,
                safe_err_msg
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
                .map(|r| r.message.content)
                .map_err(|e| {
                    JsValue::from_str(&format!(
                        "Ollama parse error: {}. The response format was unexpected.",
                        e
                    ))
                })
        } else {
            serde_json::from_str::<OpenAiResponse>(&raw)
                .map_err(|e| {
                    JsValue::from_str(&format!(
                        "OpenAI parse error: {}. The response format was unexpected.",
                        e
                    ))
                })
                .and_then(|r| {
                    r.choices
                        .into_iter()
                        .next()
                        .map(|c| c.message.content)
                        .ok_or_else(|| JsValue::from_str("No choices in OpenAI response"))
                })
        }
    }
}
