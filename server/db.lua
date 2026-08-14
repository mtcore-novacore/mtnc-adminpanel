-- ============================================================
-- MTNC DATABASE BRIDGE (OXMYSQL BULLETPROOF WRAPPER)
-- ============================================================
DB = DB or {}

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

function DB.Update(queryStr, params)
    if MySQL and MySQL.update and MySQL.update.await then
        local ok, res = pcall(function() return MySQL.update.await(queryStr, params or {}) end)
        if ok and res then return res end
    end
    if exports and exports['oxmysql'] then
        local p = promise.new()
        exports['oxmysql']:update(queryStr, params or {}, function(affected)
            p:resolve(affected or 0)
        end)
        return Citizen.Await(p)
    end
    return 0
end
