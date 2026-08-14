-- ============================================================
-- MTNC ADAPTER - QBOX
-- ============================================================
FrameworkAdapter = FrameworkAdapter or {}

function FrameworkAdapter.IsQBox()
    return GetResourceState('qbx_core') == 'started'
end
