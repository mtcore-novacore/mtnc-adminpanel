// ============================================================
// MTNC TABLET OS v3.0.1 — NUI BRIDGE & API CALLS
// ============================================================
const API = {
  isFiveM: typeof window.invokeNative !== 'undefined' || typeof window.GetParentResourceName !== 'undefined',
  resourceName: typeof window.GetParentResourceName === 'function' ? window.GetParentResourceName() : 'mtnc-adminpanel',

  async post(event, data = {}) {
    if (!this.isFiveM) {
      console.log(`[DEV MOCK NUI] POST '${event}':`, data);
      return { success: true };
    }
    try {
      const resp = await fetch(`https://${this.resourceName}/${event}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data)
      });
      return await resp.json();
    } catch (e) {
      return { error: e.message };
    }
  }
};
