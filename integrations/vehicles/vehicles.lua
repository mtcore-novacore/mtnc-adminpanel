-- ============================================================
-- MTNC ADAPTER — VEHICLES
-- ============================================================
VehicleAdapter = VehicleAdapter or {}

function VehicleAdapter.GetOwnedVehicles(src)
    local list = {}
    local p = FrameworkAdapter.GetPlayer(src)
    if p and p.PlayerData and p.PlayerData.citizenid then
        local rows = MySQL.query.await('SELECT plate, vehicle, garage, state, fuel, engine, body FROM player_vehicles WHERE citizenid = ?', { p.PlayerData.citizenid }) or {}
        for _, r in ipairs(rows) do
            table.insert(list, {
                plate = r.plate,
                model = r.vehicle,
                garage = r.garage or 'Offentlig Garage',
                state = (r.state == 1 or r.state == 'garaged') and 'I Garage' or 'Ude på gaden',
                fuel = r.fuel or 100,
                engine = r.engine or 1000,
                body = r.body or 1000
            })
        end
    end
    return list
end
