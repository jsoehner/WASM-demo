export async function init() {
    await loadAsync('./linux-wasm_agent.wasm');
}
export * from './linux-wasm_agent.js';
