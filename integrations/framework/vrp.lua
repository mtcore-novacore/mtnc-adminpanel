-- ============================================================
-- MTNC ADAPTER - VRP
-- ============================================================
FrameworkAdapter = FrameworkAdapter or {}

function FrameworkAdapter.IsVRP()
    return GetResourceState('vrp') == 'started'
end
