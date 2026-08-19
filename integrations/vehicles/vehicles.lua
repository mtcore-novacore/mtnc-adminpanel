-- ============================================================
-- MTNC ADAPTER - VEHICLES & LIVE DATABASE OWNERSHIP
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

VehicleAdapter = VehicleAdapter or {}

function VehicleAdapter.GetOwnedVehicles(src)
    local list = {}
    
    -- QBCore Lookup
    if FrameworkAdapter and FrameworkAdapter.IsQBCore and FrameworkAdapter.IsQBCore() then
        local p = FrameworkAdapter.GetPlayer(src)
        if p and p.PlayerData and p.PlayerData.citizenid then
            local cid = p.PlayerData.citizenid
            local rows = DB.Query('SELECT plate, vehicle, garage, state, fuel, engine, body FROM player_vehicles WHERE citizenid = ?', { cid }) or {}
            for _, r in ipairs(rows) do
                local stateLabel = 'Ude paa gaden'
                if r.state == 1 or r.state == 'garaged' or r.state == 'in' then
                    stateLabel = 'I Garage'
                elseif r.state == 2 or r.state == 'impounded' then
                    stateLabel = 'Beslaglagt'
                end

                local engPct = math.floor(((r.engine or 1000) / 1000) * 100)
                local fuelPct = math.floor(r.fuel or 100)

                table.insert(list, {
                    plate = r.plate,
                    model = string.upper(r.vehicle or 'Koeretoey'),
                    garage = r.garage or 'Offentlig Garage',
                    state = stateLabel,
                    fuel = fuelPct,
                    engine = engPct,
                    body = math.floor(((r.body or 1000) / 1000) * 100)
                })
            end
        end
    -- ESX Lookup
    elseif FrameworkAdapter and FrameworkAdapter.IsESX and FrameworkAdapter.IsESX() then
        local p = FrameworkAdapter.GetESXPlayer(src)
        if p and p.identifier then
            local rows = DB.Query('SELECT plate, vehicle, stored FROM owned_vehicles WHERE owner = ?', { p.identifier }) or {}
            for _, r in ipairs(rows) do
                local vehData = json.decode(r.vehicle or '{}')
                local modelName = vehData.model and tostring(vehData.model) or 'Koeretoey'
                table.insert(list, {
                    plate = r.plate,
                    model = string.upper(modelName),
                    garage = 'Standard Garage',
                    state = (r.stored == 1 or r.stored == true) and 'I Garage' or 'Ude paa gaden',
                    fuel = 100,
                    engine = 100,
                    body = 100
                })
            end
        end
    end

    return list
end

function VehicleAdapter.LookupPlate(plateQuery)
    if not plateQuery or plateQuery == '' then return {} end
    local query = '%' .. string.upper(plateQuery) .. '%'
    local fType = FrameworkAdapter and FrameworkAdapter.GetFrameworkType and FrameworkAdapter.GetFrameworkType() or 'qbcore'

    if fType == 'esx' then
        local rows = DB.Query([[
            SELECT ov.plate, ov.vehicle, ov.owner as citizenid, 'Standard Garage' as garage,
                   IF(ov.stored = 1, 'I Garage', 'Ude paa gaden') as state,
                   CONCAT(IFNULL(u.firstname, ''), ' ', IFNULL(u.lastname, '')) as owner_name
            FROM owned_vehicles ov
            LEFT JOIN users u ON ov.owner = u.identifier
            WHERE ov.plate LIKE ? LIMIT 10
        ]], { query }) or {}
        return rows
    elseif fType == 'vrp' then
        local rows = DB.Query([[
            SELECT uv.veh_type as vehicle, uv.user_id as citizenid, 'vRP Garage' as garage, 'I Garage' as state,
                   CONCAT(IFNULL(ui.firstname, ''), ' ', IFNULL(ui.name, '')) as owner_name,
                   ? as plate
            FROM vrp_user_vehicles uv
            LEFT JOIN vrp_user_identities ui ON uv.user_id = ui.user_id
            LIMIT 10
        ]], { plateQuery }) or {}
        return rows
    else
        local rows = DB.Query([[
            SELECT pv.plate, pv.vehicle, pv.citizenid, pv.garage, pv.state,
                   CONCAT(JSON_UNQUOTE(JSON_EXTRACT(p.charinfo, '$.firstname')), ' ', JSON_UNQUOTE(JSON_EXTRACT(p.charinfo, '$.lastname'))) as owner_name
            FROM player_vehicles pv
            LEFT JOIN players p ON pv.citizenid = p.citizenid
            WHERE pv.plate LIKE ? LIMIT 10
        ]], { query }) or {}
        return rows
    end
end
