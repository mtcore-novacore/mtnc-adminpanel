-- ============================================================
-- MTNC ADAPTER — QBOX
-- ============================================================
if GetResourceState('qbx_core') == 'started' then
    function FrameworkAdapter.IsQbox() return true end
end
