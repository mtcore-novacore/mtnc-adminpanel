-- ============================================================
-- MTNC ADAPTER - QBOX (FULL MULTI-FRAMEWORK SUPPORT)
-- ============================================================
FrameworkAdapter = FrameworkAdapter or {}

function FrameworkAdapter.IsQBox()
    return GetResourceState('qbx_core') == 'started'
end

function FrameworkAdapter.GetQBoxPlayer(src)
    if not FrameworkAdapter.IsQBox() then return nil end
    if exports.qbx_core and exports.qbx_core.GetPlayer then
        return exports.qbx_core:GetPlayer(src)
    end
    return nil
end
