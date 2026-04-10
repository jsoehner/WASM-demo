export async function init() {
    await loadAsync('./windows-x64-wasm_agent.wasm');
}
export * from './windows-x64-wasm_agent.js';
