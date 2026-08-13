-- ============================================================
-- MTNC ADAPTER — VRP
-- ============================================================
function FrameworkAdapter.IsVRP()
    return GetResourceState('vrp') == 'started'
end
