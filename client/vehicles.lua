-- ──────────────────────────────────────────────────────
--  MTNC Admin Panel — Client Vehicles
--  Håndterer: vehicle spawn, repair, delete, fuel
-- ──────────────────────────────────────────────────────

-- ── SPAWN VEHICLE ─────────────────────────────────────
AddEventHandler("mtnc:client:spawnVehicle", function(modelName)
    if not modelName or modelName == "" then return end

    local model = GetHashKey(modelName)
    if not IsModelValid(model) then
        TriggerEvent("mtnc:notify", "❌ Ugyldigt køretøj: " .. modelName, "error")
        return
    end

    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 100 do
        Citizen.Wait(50)
        timeout = timeout + 1
    end

    if not HasModelLoaded(model) then
        TriggerEvent("mtnc:notify", "❌ Kunne ikke indlæse model: " .. modelName, "error")
        return
    end

    local ped    = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    -- Spawn lidt foran spilleren
    local spawnX = coords.x + math.sin(-math.rad(heading)) * 5.0
    local spawnY = coords.y + math.cos(-math.rad(heading)) * 5.0
    local spawnZ = coords.z

    local veh = CreateVehicle(model, spawnX, spawnY, spawnZ, heading, true, false)
    SetVehicleOnGroundProperly(veh)
    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleEngineOn(veh, true, true)
    SetVehicleFuelLevel(veh, 100.0)
    SetModelAsNoLongerNeeded(model)

    -- Sæt spilleren i køretøjet
    Citizen.Wait(300)
    SetPedIntoVehicle(ped, veh, -1)

    TriggerServerEvent("mtnc:log", string.format(
        "Spawned vehicle: %s", modelName
    ))
    TriggerEvent("mtnc:notify", "🚗 Spawnet: " .. modelName, "success")
end)

-- ── REPAIR VEHICLE ─────────────────────────────────────
AddEventHandler("mtnc:client:repairVehicle", function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    if veh == 0 then
        -- Find nærmeste køretøj
        local coords = GetEntityCoords(ped)
        local nearVeh = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 70)
        if nearVeh ~= 0 then
            veh = nearVeh
        else
            TriggerEvent("mtnc:notify", "❌ Ingen bil i nærheden", "error")
            return
        end
    end

    SetVehicleFixed(veh)
    SetVehicleDeformationFixed(veh)
    SetVehicleDirtLevel(veh, 0.0)
    SetVehicleEngineHealth(veh, 1000.0)
    SetVehicleFuelLevel(veh, 100.0)

    TriggerEvent("mtnc:notify", "🔧 Køretøj repareret og tanket op", "success")
end)

-- ── DELETE NEAREST VEHICLE ────────────────────────────
AddEventHandler("mtnc:client:deleteVehicle", function()
    local ped    = PlayerPedId()
    local coords = GetEntityCoords(ped)

    -- Check om spilleren er i en bil
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then
        DeleteVehicle(veh)
        TriggerEvent("mtnc:notify", "🗑️ Køretøj slettet", "success")
        return
    end

    -- Find nærmeste køretøj inden for 10m
    local nearVeh = GetClosestVehicle(coords.x, coords.y, coords.z, 10.0, 0, 70)
    if nearVeh ~= 0 then
        DeleteVehicle(nearVeh)
        TriggerEvent("mtnc:notify", "🗑️ Nærmeste køretøj slettet", "success")
    else
        TriggerEvent("mtnc:notify", "❌ Ingen køretøjer i nærheden (10m)", "error")
    end
end)
