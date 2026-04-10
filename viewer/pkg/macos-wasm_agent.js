export async function init() {
    await loadAsync('./macos-wasm_agent.wasm');
}
export * from './macos-wasm_agent.js';
