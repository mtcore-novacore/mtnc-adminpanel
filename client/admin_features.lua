-- ============================================================
-- MTNC ADMIN SUITE - CLIENT TOOLS & SELF CAPABILITIES
-- ============================================================
local isNoclip = false
local isGodmode = false
local isInvisible = false
local isSuperRun = false
local spectatingTarget = nil
local noclipCam = nil

-- 1. Noclip Controller
local noclipSpeed = 1.0
RegisterNetEvent('mtnc:client:toggleNoclip', function()
    isNoclip = not isNoclip
    local ped = PlayerPedId()
    SetEntityInvincible(ped, isNoclip)
    SetEntityVisible(ped, not isNoclip, false)
    SetEntityCollision(ped, not isNoclip, not isNoclip)

    if isNoclip then
        TriggerEvent('mtnc:client:notify', '👻 Noclip AKTIVERET (W/A/S/D/Shift/Space/Ctrl)', 'success')
        CreateThread(function()
            while isNoclip do
                Wait(0)
                local p = PlayerPedId()
                local coords = GetEntityCoords(p)
                local heading = GetGameplayCamRot(2)
                SetEntityHeading(p, heading.z)

                local speed = noclipSpeed
                if IsControlPressed(0, 21) then speed = speed * 3.0 end -- Shift
                if IsControlPressed(0, 19) then speed = speed * 0.3 end -- Alt / Slow

                local moveForward = 0.0
                local moveRight = 0.0
                local moveUp = 0.0

                if IsControlPressed(0, 32) then moveForward = 1.0 end -- W
                if IsControlPressed(0, 33) then moveForward = -1.0 end -- S
                if IsControlPressed(0, 34) then moveRight = -1.0 end -- A
                if IsControlPressed(0, 35) then moveRight = 1.0 end -- D
                if IsControlPressed(0, 22) then moveUp = 1.0 end -- Space
                if IsControlPressed(0, 36) then moveUp = -1.0 end -- Ctrl

                local radZ = math.rad(heading.z)
                local radX = math.rad(heading.x)

                local dx = -math.sin(radZ) * moveForward + math.cos(radZ) * moveRight
                local dy = math.cos(radZ) * moveForward + math.sin(radZ) * moveRight
                local dz = math.sin(radX) * moveForward + moveUp

                SetEntityCoordsNoOffset(p, coords.x + (dx * speed), coords.y + (dy * speed), coords.z + (dz * speed), true, true, true)
            end
        end)
    else
        TriggerEvent('mtnc:client:notify', '⚪ Noclip Deaktiveret', 'info')
    end
end)

-- 2. Godmode & Invisibility
RegisterNetEvent('mtnc:client:toggleGodmode', function()
    isGodmode = not isGodmode
    SetPlayerInvincible(PlayerId(), isGodmode)
    SetEntityInvincible(PlayerPedId(), isGodmode)
    TriggerEvent('mtnc:client:notify', isGodmode and '🛡️ Godmode AKTIVERET' or '⚪ Godmode Deaktiveret', isGodmode and 'success' or 'info')
end)

RegisterNetEvent('mtnc:client:toggleInvisible', function()
    isInvisible = not isInvisible
    SetEntityVisible(PlayerPedId(), not isInvisible, false)
    TriggerEvent('mtnc:client:notify', isInvisible and '👻 Usynlighed AKTIVERET' or '⚪ Usynlighed Deaktiveret', isInvisible and 'success' or 'info')
end)

RegisterNetEvent('mtnc:client:toggleSuperRun', function()
    isSuperRun = not isSuperRun
    SetRunSprintMultiplierForPlayer(PlayerId(), isSuperRun and 1.49 or 1.0)
    TriggerEvent('mtnc:client:notify', isSuperRun and '🏃 Super Speed AKTIVERET' or '⚪ Super Speed Deaktiveret', isSuperRun and 'success' or 'info')
end)

-- 3. Teleport to Waypoint / Marker
RegisterNetEvent('mtnc:client:tpToWaypoint', function()
    local blip = GetFirstBlipInfoId(8) -- Waypoint blip
    if DoesBlipExist(blip) then
        local coords = GetBlipInfoIdCoord(blip)
        local ped = PlayerPedId()
        local foundGround, zPos = false, 0.0
        
        for z = 0.0, 800.0, 25.0 do
            SetEntityCoordsNoOffset(ped, coords.x, coords.y, z, false, false, false)
            Wait(10)
            foundGround, zPos = GetGroundZFor_3dCoord(coords.x, coords.y, z, false)
            if foundGround then
                SetEntityCoordsNoOffset(ped, coords.x, coords.y, zPos + 1.0, false, false, false)
                break
            end
        end
        TriggerEvent('mtnc:client:notify', '📍 Teleporteret til GPS Waypoint!', 'success')
    else
        TriggerEvent('mtnc:client:notify', '❌ Intet waypoint fundet paa kortet!', 'error')
    end
end)

-- 4. Vehicle Tools (Repair, Tune, Refuel, Delete, Spawn)
RegisterNetEvent('mtnc:client:repairVehicle', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then
        SetVehicleFixed(veh)
        SetVehicleDirtLevel(veh, 0.0)
        SetVehicleEngineHealth(veh, 1000.0)
        SetVehicleBodyHealth(veh, 1000.0)
        SetVehiclePetrolTankHealth(veh, 1000.0)
        TriggerEvent('mtnc:client:notify', '🔧 Koeretoey fuldt repareret & rengjort!', 'success')
    else
        TriggerEvent('mtnc:client:notify', '❌ Du skal sidde i et koeretoey!', 'error')
    end
end)

RegisterNetEvent('mtnc:client:maxTuneVehicle', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then
        SetVehicleModKit(veh, 0)
        ToggleVehicleMod(veh, 18, true) -- Turbo
        ToggleVehicleMod(veh, 22, true) -- Xenon
        SetVehicleMod(veh, 11, GetNumVehicleMods(veh, 11) - 1, false) -- Engine
        SetVehicleMod(veh, 12, GetNumVehicleMods(veh, 12) - 1, false) -- Brakes
        SetVehicleMod(veh, 13, GetNumVehicleMods(veh, 13) - 1, false) -- Transmission
        SetVehicleMod(veh, 15, GetNumVehicleMods(veh, 15) - 1, false) -- Suspension
        SetVehicleMod(veh, 16, GetNumVehicleMods(veh, 16) - 1, false) -- Armor
        TriggerEvent('mtnc:client:notify', '⚡ Koeretoey Tunet til MAX Performance!', 'success')
    else
        TriggerEvent('mtnc:client:notify', '❌ Du skal sidde i et koeretoey!', 'error')
    end
end)

RegisterNetEvent('mtnc:client:refuelVehicle', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then
        if exports['qb-fuel'] then
            exports['qb-fuel']:SetFuel(veh, 100.0)
        else
            SetVehicleFuelLevel(veh, 100.0)
        end
        TriggerEvent('mtnc:client:notify', '⛽ Tank fyldt til 100%!', 'success')
    else
        TriggerEvent('mtnc:client:notify', '❌ Du skal sidde i et koeretoey!', 'error')
    end
end)

RegisterNetEvent('mtnc:client:deleteCurrentVehicle', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then
        local coords = GetEntityCoords(ped)
        veh = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
    end
    if veh ~= 0 then
        SetEntityAsMissionEntity(veh, true, true)
        DeleteVehicle(veh)
        TriggerEvent('mtnc:client:notify', '🗑️ Koeretoey slettet!', 'info')
    else
        TriggerEvent('mtnc:client:notify', '❌ Intet koeretoey fundet i naerheden!', 'error')
    end
end)

RegisterNetEvent('mtnc:client:spawnVehicleLocal', function(modelName)
    local ped = PlayerPedId()
    local hash = GetHashKey(modelName)
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then
        TriggerEvent('mtnc:client:notify', '❌ Ugyldigt koeretoey modelnavn: ' .. tostring(modelName), 'error')
        return
    end

    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end

    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local veh = CreateVehicle(hash, coords.x, coords.y, coords.z, heading, true, false)
    TaskWarpPedIntoVehicle(ped, veh, -1)
    SetVehicleEngineOn(veh, true, true, false)
    SetVehicleDirtLevel(veh, 0.0)
    
    if exports['qb-vehiclekeys'] then
        TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(veh))
    end
    
    SetModelAsNoLongerNeeded(hash)
    TriggerEvent('mtnc:client:notify', '🚗 Spawnede ' .. string.upper(modelName) .. ' med noegler!', 'success')
end)

-- 5. Freeze / Spectate Player
local isFrozen = false
RegisterNetEvent('mtnc:client:freezePlayer', function()
    isFrozen = not isFrozen
    FreezeEntityPosition(PlayerPedId(), isFrozen)
    TriggerEvent('mtnc:client:notify', isFrozen and '❄️ Du er blevet frosset af Staff.' or '☀️ Du er blevet optoeet.', isFrozen and 'error' or 'success')
end)

RegisterNetEvent('mtnc:client:spectateTarget', function(targetId)
    local ped = PlayerPedId()
    if spectatingTarget then
        NetworkSetInSpectatorMode(false, ped)
        spectatingTarget = nil
        TriggerEvent('mtnc:client:notify', '👁️ Spectate Afsluttet', 'info')
    else
        local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))
        if DoesEntityExist(targetPed) then
            NetworkSetInSpectatorMode(true, targetPed)
            spectatingTarget = targetId
            TriggerEvent('mtnc:client:notify', '👁️ Spectater nu Spiller ID: ' .. tostring(targetId), 'success')
        else
            TriggerEvent('mtnc:client:notify', '❌ Spiller ikke fundet i din streaming rækkevidde!', 'error')
        end
    end
end)
