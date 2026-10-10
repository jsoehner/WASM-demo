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
