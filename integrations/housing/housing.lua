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
    local fType = FrameworkAdapter and FrameworkAdapter.GetFrameworkType and FrameworkAdapter.GetFrameworkType() or 'qbcore'

    if fType == 'esx' then
        local p = FrameworkAdapter.GetESXPlayer(src)
        if p and p.identifier then
            local results = DB.Query('SELECT * FROM owned_properties WHERE owner = ?', { p.identifier }) or {}
            for _, r in ipairs(results) do
                table.insert(list, {
                    id = r.id or r.name or 'Ejendom',
                    label = r.name or r.label or 'Ejendom',
                    address = r.name or 'Bygning',
                    tier = 1,
                    hasKeys = true
                })
            end
        end
    else
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
