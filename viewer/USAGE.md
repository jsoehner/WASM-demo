# WASM LLM Agent Viewer - User Guide

## Quick Start

1. **Install** (one-time)
   ```bash
   ./build-and-package.sh
   cd dist && ./start-server.sh
   ```
   Open `http://localhost:8000` in your browser.

2. **Use**
   - Select provider (OpenAI/Ollama)
   - Enter model ID and API URL
   - Enter optional API key
   - Enter your prompt
   - Click "Execute Agent"

## Features

- 🤖 Runs entirely in your browser
- 🔄 Multi-provider support (OpenAI, Ollama)
- 🔧 Built-in tool calling (string length calculation)
- 💾 Auto-saves your configuration

## Configuration

### API Configuration

- **Provider**: OpenAI or Ollama
- **Model ID**: Your model name (e.g., `llama3`, `mistral`)
- **API URL**: 
  - Ollama: `http://localhost:11434/api`
  - OpenAI: `https://api.openai.com/v1`
- **API Key**: Leave blank for no key, or enter your OpenAI key

### Saving Configuration

The viewer will **prompt you** before saving your configuration to `localStorage`. This allows you to:

- Keep your settings across browser sessions
- Quickly reuse the same configuration
- Reset anytime by clearing localStorage

**Security Note**: Your API key is **only stored in your browser's localStorage**. It's never sent to any server except the LLM provider itself.

To clear saved config:
1. Open browser DevTools (F12)
2. Go to Application/Storage → Local Storage
3. Delete `wasm-agent-config`

## Tips

- **Ollama**: Run Ollama first: `ollama serve`
- **OpenAI**: Get an API key from [platform.openai.com](https://platform.openai.com)
- **Streaming**: This demo uses non-streaming mode for simplicity. For better UX, consider adding streaming support.
- **Rate Limits**: If you hit rate limits, wait before retrying.

## Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| "Invalid API URL" | URL missing http/https | Add protocol prefix |
| "Prompt too long" | Input > 4096 chars | Shorten your prompt |
| "429 Too Many Requests" | Rate limit exceeded | Wait and retry |
| "401 Unauthorized" | Invalid API key | Check your API key |
| "503 Service Unavailable" | LLM server overloaded | Wait and retry |
| "404 Not Found" | Model not found | Check model name |

## Architecture

```
┌─────────────┐     ┌─────────────┐
│   Browser   │ ──▶ │  WASM Agent  │
│             │     │   (Rust)     │
└─────────────┘     └─────────────┘
                         │
           ┌────────────┼────────────┐
           │            │            │
      ┌────▼────┐  ┌────▼────┐  ┌────▼────┐
      │  OpenAI │  │ Ollama  │  │  Tools  │
      │  API    │  │  API    │  │ Calling │
      └─────────┘  └─────────┘  └─────────┘
```

## Security

- ✅ Runs entirely in-browser (no server)
- ✅ API keys never sent to this app
- ✅ XSS protection via CSP headers
- ⚠️ Don't share your API keys
- ⚠️ Clear browser data if you switch computers

## Contributing

See [BUILD.md](../BUILD.md) for development instructions.

## License

See LICENSE file.