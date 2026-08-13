-- ============================================================
-- MTNC ADAPTER — HOUSING
-- ============================================================
HousingAdapter = HousingAdapter or {}

function HousingAdapter.GetProperties(src)
    local list = {}
    -- Auto-detect qb-housing, loaf_housing, or esx_property
    if GetResourceState('qb-houses') == 'started' or GetResourceState('qb-housing') == 'started' then
        local p = FrameworkAdapter.GetPlayer(src)
        if p and p.PlayerData and p.PlayerData.citizenid then
            local results = DB.Query('SELECT * FROM player_houses WHERE citizenid = ?', { p.PlayerData.citizenid }) or {}
            for _, r in ipairs(results) do
                table.insert(list, {
                    id = r.house or r.id,
                    label = r.house or 'Ejendom',
                    address = r.house,
                    tier = r.tier or 1,
                    hasKeys = true
                })
            end
        end
    end
    return list
end
