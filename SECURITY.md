# Security Best Practices

## Running This Demo

### API Keys
- ✅ **Never share API keys** - They provide access to paid LLM services
- ✅ **API keys are stored only in your browser's localStorage**
- ✅ **Clear browser data** before switching computers
- ✅ **Use browser DevTools** to inspect/modify localStorage

### Local Storage Management

#### View Saved Configuration
1. Open browser DevTools (F12)
2. Go to **Application/Storage** → **Local Storage**
3. Click on your domain (e.g., `localhost:8000`)
4. You'll see `wasm-agent-config`

#### Clear Configuration
1. Open browser DevTools (F12)
2. Go to **Application/Storage** → **Local Storage**
3. Click **⋮** (more options) → **Clear site data**
4. Or remove the `wasm-agent-config` key specifically

#### Modify Configuration
1. Open browser DevTools (F12)
2. Go to **Console** tab
3. Type: `localStorage.getItem('wasm-agent-config')`
4. This shows your current config

### Input Validation

The WASM agent now validates:
- ✅ API URLs must start with `http://` or `https://`
- ✅ Provider must be `openai` or `ollama`
- ✅ Prompts are limited to 4096 characters
- ✅ API keys are trimmed and validated

### Request Safety

- ✅ **30-second timeout** on all API requests
- ✅ **Rate limiting** handled with retry advice
- ✅ **CORS protection** via CSP headers

## Building and Distributing

### Code Review

Before releasing a new version:

```bash
# Check for security issues
cargo audit

# Review changes
git diff
```

### Distribution Packages

When creating distribution packages:

1. **Never commit secrets** to git
2. **Use environment variables** for API keys in production
3. **Run `cargo audit`** to check dependencies
4. **Test on multiple platforms** before release

## Reporting Vulnerabilities

If you discover a security issue:

1. **Do not share** exploit details publicly
2. **Email the maintainer** directly
3. **Provide reproduction steps**
4. **Wait for fix** before releasing information

## Disclaimer

This demo is for **educational purposes only**:

- ❌ **Not for production use** without modifications
- ❌ **Not a substitute** for a proper backend service
- ❌ **Not production-ready** security-wise
- ✅ **Safe to use** with your own API keys and proper configuration

## License

See LICENSE file for project license.
