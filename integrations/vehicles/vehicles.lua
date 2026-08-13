-- ============================================================
-- MTNC ADAPTER - VEHICLES & LIVE DATABASE OWNERSHIP
-- ============================================================
VehicleAdapter = VehicleAdapter or {}

function VehicleAdapter.GetOwnedVehicles(src)
    local list = {}
    
    -- QBCore Lookup
    if FrameworkAdapter.IsQBCore() then
        local p = FrameworkAdapter.GetPlayer(src)
        if p and p.PlayerData and p.PlayerData.citizenid then
            local cid = p.PlayerData.citizenid
            local rows = MySQL.query.await('SELECT plate, vehicle, garage, state, fuel, engine, body FROM player_vehicles WHERE citizenid = ?', { cid }) or {}
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
    elseif FrameworkAdapter.IsESX() then
        local p = FrameworkAdapter.GetESXPlayer(src)
        if p and p.identifier then
            local rows = MySQL.query.await('SELECT plate, vehicle, stored FROM owned_vehicles WHERE owner = ?', { p.identifier }) or {}
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
    local results = {}

    if FrameworkAdapter.IsQBCore() then
        local rows = MySQL.query.await([[
            SELECT pv.plate, pv.vehicle, pv.citizenid, pv.garage, pv.state,
                   CONCAT(JSON_UNQUOTE(JSON_EXTRACT(p.charinfo, '$.firstname')), ' ', JSON_UNQUOTE(JSON_EXTRACT(p.charinfo, '$.lastname'))) as owner_name
            FROM player_vehicles pv
            LEFT JOIN players p ON pv.citizenid = p.citizenid
            WHERE pv.plate LIKE ? LIMIT 10
        ]], { query }) or {}
        return rows
    end

    return results
end
