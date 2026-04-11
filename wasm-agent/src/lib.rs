use wasm_bindgen::prelude::*;
use wasm_bindgen_futures::JsFuture;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use web_sys::{
    Window, Request, RequestInit, RequestMode, Response, Headers, XMLHttpRequest,
    HtmlInputElement, HtmlSelectElement, Document, Element
};
use js_sys::{Promise, Uint8Array, Blob, Map, Error as JsError};
use console_error_panic_hook;

// ============ Error Types ============
#[derive(Serialize)]
#[serde(tag = "error")]
pub struct ApiError {
    pub code: String,
    pub message: String,
    pub status: Option<i32>,
}

#[derive(Debug, Serialize)]
pub struct LlmMessage {
    pub role: String,
    pub content: String,
}

#[derive(Debug, Serialize)]
pub struct ToolResponse {
    pub tool: String,
    pub arguments: String,
    pub result: String,
}

#[derive(Serialize)]
pub struct TaskResult {
    pub output: String,
    pub usage: Option<Value>,
    pub success: bool,
}

#[wasm_bindgen(start)]
pub fn init() {
    console_error_panic_hook::set_once();
}

// ============ Agent Structure ============
#[wasm_bindgen]
pub struct Agent {
    api_url: String,
    api_key: Option<String>,
    provider: String,
}

#[wasm_bindgen]
impl Agent {
    /// Create a new agent instance
    pub fn new(api_url: String, api_key: String, provider: String) -> Agent {
        Agent {
            api_url,
            api_key: if api_key.is_empty() { None } else { Some(api_key) },
            provider,
        }
    }

    /// Run a task with the LLM
    #[wasm_bindgen]
    pub async fn run_task(&self, model: String, prompt: String) -> Result<JsValue, JsValue> {
        // Validate inputs
        let prompt = Self::sanitize_input(&prompt);
        let model = Self::sanitize_input(&model);
        
        // Validate API URL
        if !Self::validate_url(&self.api_url) {
            return Err(JsValue::from_str("Invalid API URL. Must include http:// or https://"));
        }

        // Prepare messages
        let system_prompt = format!(
            "You are a WASM agent. Tools available: [TOOL: calculate_length: <text>] - Returns the length of a string.\n\nRules:\n- Use tools only when necessary\n- Respond clearly and concisely\n- If unsure, ask for clarification"
        );
        
        let messages: Vec<LlmMessage> = vec![
            LlmMessage { role: "system".to_string(), content: system_prompt.clone() },
            LlmMessage { role: "user".to_string(), content: prompt.clone() }
        ];

        // Make API request
        let response = match self.call_llm(&model, &messages).await {
            Ok(text) => text,
            Err(e) => return Err(JsValue::from_str(&format!("Request failed: {}", e))),
        };

        // Check for tool usage
        if response.contains("[TOOL: calculate_length:") {
            let (target, result) = Self::parse_tool_call(&response);
            let length = target.len();
            let result_str = format!(format_args!("{}", length));
            return Ok(JsValue::from_str(&result_str));
        }

        // Return LLM response
        Ok(JsValue::from_str(&response))
    }

    /// Validate URL format
    fn validate_url(url: &str) -> bool {
        url.starts_with("http://") || url.starts_with("https://")
    }

    /// Sanitize user input
    fn sanitize_input(input: &str) -> String {
        input
            .chars()
            .filter(|c| !matches!(c, '<' | '>' | '&' | '\0'))
            .take(50000) // Limit input size
            .collect()
    }

    /// Parse tool response and execute
    fn parse_tool_call(response: &str) -> (String, String) {
        let start = response.find("[TOOL: calculate_length:").unwrap_or(0) + 25;
        let end = response.find("]").unwrap_or(response.len());
        let target = &response[start..end];
        (target.to_string(), format_args!("{}: {}", target, target.len()))
    }

    /// Make HTTP request to LLM API
    async fn call_llm(&self, model: &str, messages: &[LlmMessage]) -> Result<String, String> {
        // Build request body
        let body = if self.provider == "openai" {
            serde_json::json!({
                "model": model,
                "messages": messages,
                "temperature": 0.7,
                "stream": false
            })
        } else if self.provider == "ollama" {
            serde_json::json!({
                "model": model,
                "messages": messages,
                "stream": false
            })
        } else {
            return Err(format!("Unsupported provider: {}", self.provider));
        };

        // Create headers
        let mut headers = Headers::new();
        headers.set("Content-Type", "application/json")?;
        headers.set("Authorization", format!("Bearer {}", self.api_key.unwrap_or_default()).as_str())?;

        // Create request
        let method = "POST";
        let url = self.api_url.as_str();
        let body_str = body.to_string();

        let xhr = XMLHttpRequest::new()?;
        xhr.open(method, url)?;
        xhr.setWithCredentials(true);
        xhr.setHeaders(headers)?;
        
        // Send request
        xhr.send(body_str.as_str())?;
        
        // Check response status
        let status = xhr.status();
        if status >= 400 {
            let error_body = xhr.response_as_string()?;
            match serde_json::from_str::<ApiError>(&error_body) {
                Ok(err) => Err(err.message.clone()),
                Err(_) => Err(error_body),
            }
        } else {
            let response_text = xhr.response_as_string()?;
            Ok(response_text)
        }
    }

    /// Calculate string length using tool
    pub async fn calculate_length(&self, text: String) -> Result<String, String> {
        Ok(format_args!("{}", text.len()))
    }
}

// ============ Additional Functions ============

/// Get supported models for a provider
#[wasm_bindgen]
pub async fn get_supported_models(provider: &str, api_url: &str, api_key: Option<&str>) -> Result<String, JsValue> {
    match provider {
        "ollama" => {
            let url = format!("{}/api/tags", api_url);
            // Fetch models directly
            let response = match JsFuture::from(window.fetch(&url).await).await {
                Ok(resp) => {
                    match JsFuture::from(resp.text().await).await {
                        Ok(text) => text,
                        Err(_) => "Unknown models available".to_string(),
                    }
                }
                Err(_) => {
                    // Return hardcoded list as fallback
                    "llama2,mistral,gemma,command,rwkv,nano".to_string()
                }
            };
            Ok(response)
        }
        "openai" => {
            let models = vec![
                "gpt-4o", "gpt-4-turbo", "gpt-4", "gpt-3.5-turbo",
                "llama3", "mixtral", "qwen"
            ];
            Ok(models.join(", "))
        }
        _ => Err("Unknown provider".into())
    }
}

/// Store API key in localStorage for persistence
#[wasm_bindgen]
pub fn store_api_key(key: String) {
    let window = Window::new().unwrap();
    let storage = window.localStorage();
    // Clear storage first for security
    storage.clear().unwrap();
    // Store API key
    storage.setItem_str("apiKey", &key).unwrap();
}

/// Get API key from localStorage
#[wasm_bindgen]
pub fn get_api_key() -> Option<String> {
    let window = Window::new().unwrap();
    let storage = window.localStorage();
    match storage.get_item_str("apiKey") {
        Ok(Some(key)) => Some(key),
        _ => None,
    }
}

/// Clear conversation history
#[wasm_bindgen]
pub fn clear_history() {
    let window = Window::new().unwrap();
    let storage = window.localStorage();
    storage.clear().unwrap();
    println!("History cleared");
}

/// Get conversation history
#[wasm_bindgen]
pub fn get_history() -> String {
    let window = Window::new().unwrap();
    let storage = window.localStorage();
    storage.get_item_str("history").unwrap_or_default()
}

/// Export conversation to JSON file
#[wasm_bindgen]
pub fn export_conversation(filename: String) -> Result<(), JsValue> {
    let window = Window::new()?;
    let data = get_history();
    let blob = Blob::new(&data)?;
    let url = window.URL();
    let url = url.createObjectURL(&blob)?;
    
    let link = document::create_element::<web_sys::HtmlAnchorElement>("a")?;
    link.set_href(&url)?;
    link.set_rel("noopener")?;
    link.set_target("_blank")?;
    link.set_download(&filename)?;
    
    document::default().body()?.append(&link)?;
    link.remove()?;
    
    println!("Conversation exported: {}", filename);
    Ok(())
}