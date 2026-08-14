-- ============================================================
-- MTNC ADAPTER — HOUSING
-- ============================================================
DB = DB or {}
if not DB.Query then
    function DB.Query(queryStr, params)
        if MySQL and MySQL.query and MySQL.query.await then
            local ok, res = pcall(function() return MySQL.query.await(queryStr, params or {}) end)
            if ok and res then return res end
        end
        if exports and exports['oxmysql'] then
            local p = promise.new()
            exports['oxmysql']:query(queryStr, params or {}, function(result)
                p:resolve(result or {})
            end)
            return Citizen.Await(p)
        end
        return {}
    end
end

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
