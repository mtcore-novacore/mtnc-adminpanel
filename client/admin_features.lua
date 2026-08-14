-- ============================================================
-- MTNC ADMIN SUITE - CLIENT TOOLS & PS-ADMINMODE v3.0.2
-- ============================================================
local isNoclip = false
local isGodmode = false
local isInvisible = false
local isSuperRun = false
local isSuperJump = false
local isInfiniteAmmo = false
local isVehGodmode = false
local isShowNames = false
local isShowBlips = false
local isShowCoords = false
local spectatingTarget = nil
local isCuffed = false
local playerBlips = {}

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

-- 2. Godmode, Invisibility, Super Run, Super Jump & Infinite Ammo (PS-Adminmenu Suite)
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

RegisterNetEvent('mtnc:client:toggleSuperJump', function()
    isSuperJump = not isSuperJump
    TriggerEvent('mtnc:client:notify', isSuperJump and '🚀 Super Jump AKTIVERET' or '⚪ Super Jump Deaktiveret', isSuperJump and 'success' or 'info')
    if isSuperJump then
        CreateThread(function()
            while isSuperJump do
                Wait(0)
                SetSuperJumpThisFrame(PlayerId())
            end
        end)
    end
end)

RegisterNetEvent('mtnc:client:toggleInfiniteAmmo', function()
    isInfiniteAmmo = not isInfiniteAmmo
    SetPedInfiniteAmmoClip(PlayerPedId(), isInfiniteAmmo)
    TriggerEvent('mtnc:client:notify', isInfiniteAmmo and '♾️ Uendelig Ammo AKTIVERET' or '⚪ Uendelig Ammo Deaktiveret', isInfiniteAmmo and 'success' or 'info')
end)

-- 3. Teleport Hubs & Waypoint
RegisterNetEvent('mtnc:client:tpToWaypoint', function()
    local blip = GetFirstBlipInfoId(8)
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

local teleportHubs = {
    ['legion'] = vector3(215.76, -810.12, 30.73),
    ['pillbox'] = vector3(298.60, -584.52, 43.26),
    ['mrpd'] = vector3(428.23, -984.28, 30.71),
    ['lsc'] = vector3(-338.25, -136.85, 39.01),
    ['lsia'] = vector3(-1037.66, -2737.89, 13.76),
    ['sandy'] = vector3(1853.18, 3687.52, 34.27),
    ['paleto'] = vector3(-112.56, 6467.43, 31.63),
    ['chiliad'] = vector3(501.52, 5604.28, 797.91)
}

RegisterNetEvent('mtnc:client:tpToHub', function(hubKey)
    local coords = teleportHubs[hubKey]
    if coords then
        local ped = PlayerPedId()
        SetEntityCoords(ped, coords.x, coords.y, coords.z)
        TriggerEvent('mtnc:client:notify', '📍 Teleporteret til ' .. string.upper(hubKey) .. '!', 'success')
    end
end)

-- 4. Overhead Player Names ESP
local function DrawText3D(x, y, z, text, r, g, b)
    SetDrawOrigin(x, y, z, 0)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(0.32, 0.32)
    SetTextColour(r or 255, g or 255, b or 255, 230)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

RegisterNetEvent('mtnc:client:toggleNames', function()
    isShowNames = not isShowNames
    TriggerEvent('mtnc:client:notify', isShowNames and '👥 Spiller-Navne ESP AKTIVERET' or '⚪ Spiller-Navne ESP Deaktiveret', isShowNames and 'success' or 'info')

    if isShowNames then
        CreateThread(function()
            while isShowNames do
                Wait(0)
                local myPed = PlayerPedId()
                local myCoords = GetEntityCoords(myPed)

                for _, pId in ipairs(GetActivePlayers()) do
                    local targetPed = GetPlayerPed(pId)
                    if targetPed ~= myPed and DoesEntityExist(targetPed) then
                        local targetCoords = GetEntityCoords(targetPed)
                        local dist = #(myCoords - targetCoords)
                        if dist < 120.0 then
                            local sId = GetPlayerServerId(pId)
                            local pName = GetPlayerName(pId)
                            local hp = GetEntityHealth(targetPed)
                            local armor = GetPedArmour(targetPed)
                            local tag = string.format("[%d] %s | HP: %d | AP: %d (%dm)", sId, pName, hp, armor, math.floor(dist))
                            DrawText3D(targetCoords.x, targetCoords.y, targetCoords.z + 1.15, tag, 96, 165, 250)
                        end
                    end
                end
            end
        end)
    end
end)

-- 5. Map Blips ESP
RegisterNetEvent('mtnc:client:toggleBlips', function()
    isShowBlips = not isShowBlips
    TriggerEvent('mtnc:client:notify', isShowBlips and '🗺️ Spiller-Kort Blips AKTIVERET' or '⚪ Spiller-Kort Blips Deaktiveret', isShowBlips and 'success' or 'info')

    if isShowBlips then
        CreateThread(function()
            while isShowBlips do
                TriggerServerEvent('mtnc:server:getPlayersCoords')
                Wait(4000)
            end
            for _, blip in pairs(playerBlips) do
                if DoesBlipExist(blip) then RemoveBlip(blip) end
            end
            playerBlips = {}
        end)
    else
        for _, blip in pairs(playerBlips) do
            if DoesBlipExist(blip) then RemoveBlip(blip) end
        end
        playerBlips = {}
    end
end)

RegisterNetEvent('mtnc:client:receivePlayersCoords', function(players)
    if not isShowBlips then return end
    local mySrc = GetPlayerServerId(PlayerId())

    for _, p in ipairs(players) do
        if p.id ~= mySrc then
            local blip = playerBlips[p.id]
            if not blip or not DoesBlipExist(blip) then
                blip = AddBlipForCoord(p.coords.x, p.coords.y, p.coords.z)
                SetBlipSprite(blip, 1)
                SetBlipScale(blip, 0.8)
                SetBlipColour(blip, 3)
                SetBlipAsShortRange(blip, false)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("[" .. p.id .. "] " .. p.name)
                EndTextCommandSetBlipName(blip)
                playerBlips[p.id] = blip
            else
                SetBlipCoords(blip, p.coords.x, p.coords.y, p.coords.z)
            end
        end
    end
end)

-- 6. Developer Coords Display HUD
RegisterNetEvent('mtnc:client:toggleCoords', function()
    isShowCoords = not isShowCoords
    TriggerEvent('mtnc:client:notify', isShowCoords and '🧭 Udvikler Koordinater HUD AKTIVERET' or '⚪ Koordinater HUD Deaktiveret', isShowCoords and 'success' or 'info')

    if isShowCoords then
        CreateThread(function()
            while isShowCoords do
                Wait(0)
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                local heading = GetEntityHeading(ped)
                local text = string.format("~g~Vector3:~w~ vector3(%.2f, %.2f, %.2f) | ~b~Heading:~w~ %.2f\n~p~Vector4:~w~ vector4(%.2f, %.2f, %.2f, %.2f)", coords.x, coords.y, coords.z, heading, coords.x, coords.y, coords.z, heading)
                
                SetTextFont(0)
                SetTextScale(0.35, 0.35)
                SetTextColour(255, 255, 255, 240)
                SetTextDropshadow(0, 0, 0, 0, 255)
                SetTextEdge(1, 0, 0, 0, 205)
                SetTextOutline()
                SetTextEntry("STRING")
                AddTextComponentString(text)
                DrawText(0.18, 0.92)
            end
        end)
    end
end)

-- 7. PS-Adminmenu Troll & Special Effects Handlers
RegisterNetEvent('mtnc:client:setTargetFire', function()
    StartEntityFire(PlayerPedId())
    TriggerEvent('mtnc:client:notify', '🔥 DU BRÆNDER!', 'error')
end)

RegisterNetEvent('mtnc:client:explodeTarget', function()
    local coords = GetEntityCoords(PlayerPedId())
    AddExplosion(coords.x, coords.y, coords.z, 9, 0.0, true, false, 1.0)
end)

RegisterNetEvent('mtnc:client:cuffTarget', function()
    isCuffed = not isCuffed
    local ped = PlayerPedId()
    if isCuffed then
        RequestAnimDict("mp_arresting")
        while not HasAnimDictLoaded("mp_arresting") do Wait(10) end
        TaskPlayAnim(ped, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
        SetEnableHandcuffs(ped, true)
        TriggerEvent('mtnc:client:notify', '🔗 Du er blevet lagt i haandjern!', 'error')
    else
        ClearPedTasks(ped)
        SetEnableHandcuffs(ped, false)
        TriggerEvent('mtnc:client:notify', '🔓 Haandjern fjernet!', 'success')
    end
end)

RegisterNetEvent('mtnc:client:drunkTarget', function()
    RequestAnimSet("move_m@drunk@verydrunk")
    while not HasAnimSetLoaded("move_m@drunk@verydrunk") do Wait(10) end
    SetPedMovementClipset(PlayerPedId(), "move_m@drunk@verydrunk", 1.0)
    TriggerEvent('mtnc:client:notify', '🥴 Du foeler dig ekstremt fuld!', 'warning')
end)

RegisterNetEvent('mtnc:client:flashbangTarget', function()
    SetTimecycleModifier("hud_def_blur")
    SetTimecycleModifierStrength(1.0)
    Wait(3500)
    ClearTimecycleModifier()
end)

-- 8. Vehicle Tools (Repair, Tune, Refuel, Delete, Spawn, Flip, VehGod, Plate, SaveCar, Lock, Color)
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
        ToggleVehicleMod(veh, 18, true)
        ToggleVehicleMod(veh, 22, true)
        SetVehicleMod(veh, 11, GetNumVehicleMods(veh, 11) - 1, false)
        SetVehicleMod(veh, 12, GetNumVehicleMods(veh, 12) - 1, false)
        SetVehicleMod(veh, 13, GetNumVehicleMods(veh, 13) - 1, false)
        SetVehicleMod(veh, 15, GetNumVehicleMods(veh, 15) - 1, false)
        SetVehicleMod(veh, 16, GetNumVehicleMods(veh, 16) - 1, false)
        TriggerEvent('mtnc:client:notify', '⚡ Koeretoey Tunet til MAX Performance!', 'success')
    else
        TriggerEvent('mtnc:client:notify', '❌ Du skal sidde i et koeretoey!', 'error')
    end
end)

RegisterNetEvent('mtnc:client:toggleDoorLocks', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then
        local lockStatus = GetVehicleDoorLockStatus(veh)
        if lockStatus == 1 or lockStatus == 0 then
            SetVehicleDoorsLocked(veh, 2)
            TriggerEvent('mtnc:client:notify', '🔒 Koeretoeyets doere er LAAST!', 'info')
        else
            SetVehicleDoorsLocked(veh, 1)
            TriggerEvent('mtnc:client:notify', '🔓 Koeretoeyets doere er LAST OP!', 'success')
        end
    else
        TriggerEvent('mtnc:client:notify', '❌ Du skal sidde i et koeretoey!', 'error')
    end
end)

RegisterNetEvent('mtnc:client:changeVehColorPreset', function(colorName)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then
        local colors = {
            ['black'] = {0, 0},
            ['white'] = {111, 111},
            ['red'] = {27, 27},
            ['blue'] = {64, 64},
            ['gold'] = {37, 37},
            ['purple'] = {145, 145},
            ['green'] = {50, 50}
        }
        local c = colors[colorName] or {0, 0}
        SetVehicleColours(veh, c[1], c[2])
        TriggerEvent('mtnc:client:notify', '🎨 Bilens farve er aendret til ' .. string.upper(colorName), 'success')
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

RegisterNetEvent('mtnc:client:flipVehicle', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then
        local coords = GetEntityCoords(ped)
        veh = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
    end
    if veh ~= 0 then
        local coords = GetEntityCoords(veh)
        SetEntityCoords(veh, coords.x, coords.y, coords.z + 1.0)
        SetVehicleOnGroundProperly(veh)
        TriggerEvent('mtnc:client:notify', '🔄 Koeretoey vendt rundt paa hjulene!', 'success')
    else
        TriggerEvent('mtnc:client:notify', '❌ Intet koeretoey fundet!', 'error')
    end
end)

RegisterNetEvent('mtnc:client:toggleVehGodmode', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then
        isVehGodmode = not isVehGodmode
        SetEntityInvincible(veh, isVehGodmode)
        SetVehicleTyresCanBurst(veh, not isVehGodmode)
        TriggerEvent('mtnc:client:notify', isVehGodmode and '🛡️ Bil Godmode AKTIVERET' or '⚪ Bil Godmode Deaktiveret', isVehGodmode and 'success' or 'info')
    else
        TriggerEvent('mtnc:client:notify', '❌ Du skal sidde i et koeretoey!', 'error')
    end
end)

RegisterNetEvent('mtnc:client:saveCurrentCar', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then
        local plate = GetVehicleNumberPlateText(veh)
        local hash = GetEntityModel(veh)
        local modelName = GetDisplayNameFromVehicleModel(hash):lower()
        
        local mods = {}
        if exports['qb-core'] then
            local QBCore = exports['qb-core']:GetCoreObject()
            mods = QBCore.Functions.GetVehicleProperties(veh)
        end
        TriggerServerEvent('mtnc:server:saveCarToGarage', mods, modelName, hash, plate)
    else
        TriggerEvent('mtnc:client:notify', '❌ Du skal sidde i det koeretoey du vil gemme!', 'error')
    end
end)

RegisterNetEvent('mtnc:client:clearAreaEntity', function(entityType, radius)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local rad = radius or 100.0

    if entityType == 'vehicles' then
        local vehicles = GetGamePool('CVehicle')
        local count = 0
        for _, veh in ipairs(vehicles) do
            if #(coords - GetEntityCoords(veh)) <= rad and GetPedInVehicleSeat(veh, -1) == 0 then
                SetEntityAsMissionEntity(veh, true, true)
                DeleteVehicle(veh)
                count = count + 1
            end
        end
        TriggerEvent('mtnc:client:notify', '🧹 Slettede ' .. count .. ' tomme koeretoeyer inden for ' .. math.floor(rad) .. 'm!', 'info')
    elseif entityType == 'peds' then
        local peds = GetGamePool('CPed')
        local count = 0
        for _, p in ipairs(peds) do
            if p ~= ped and not IsPedAPlayer(p) and #(coords - GetEntityCoords(p)) <= rad then
                SetEntityAsMissionEntity(p, true, true)
                DeletePed(p)
                count = count + 1
            end
        end
        TriggerEvent('mtnc:client:notify', '🧹 Slettede ' .. count .. ' NPC peds inden for ' .. math.floor(rad) .. 'm!', 'info')
    elseif entityType == 'objects' then
        local objects = GetGamePool('CObject')
        local count = 0
        for _, obj in ipairs(objects) do
            if #(coords - GetEntityCoords(obj)) <= rad then
                SetEntityAsMissionEntity(obj, true, true)
                DeleteObject(obj)
                count = count + 1
            end
        end
        TriggerEvent('mtnc:client:notify', '🧹 Slettede ' .. count .. ' props/objekter inden for ' .. math.floor(rad) .. 'm!', 'info')
    end
end)

RegisterNetEvent('mtnc:client:changePlateText', function(newPlate)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then
        SetVehicleNumberPlateText(veh, string.upper(newPlate))
        if exports['qb-vehiclekeys'] then
            TriggerEvent('vehiclekeys:client:SetOwner', string.upper(newPlate))
        end
        TriggerEvent('mtnc:client:notify', '🏷️ Nummerplade aendret til: ' .. string.upper(newPlate), 'success')
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

-- 9. Weapon Spawner & Actions
RegisterNetEvent('mtnc:client:giveWeaponLocal', function(weaponName, ammo)
    local ped = PlayerPedId()
    local hash = GetHashKey(weaponName)
    GiveWeaponToPed(ped, hash, ammo or 250, false, true)
    SetPedAmmo(ped, hash, ammo or 250)
    TriggerEvent('mtnc:client:notify', '🔫 Modtog ' .. string.upper(weaponName) .. ' (' .. tostring(ammo or 250) .. ' skud)!', 'success')
end)

RegisterNetEvent('mtnc:client:clearWeaponsLocal', function()
    RemoveAllPedWeapons(PlayerPedId(), true)
    TriggerEvent('mtnc:client:notify', '🚫 Alle vaaben fjernet!', 'info')
end)

RegisterNetEvent('mtnc:client:giveArmorLocal', function()
    SetPedArmour(PlayerPedId(), 100)
    TriggerEvent('mtnc:client:notify', '🛡️ 100% Panser tilfojet!', 'success')
end)

-- 10. Player Slap & Ragdoll
RegisterNetEvent('mtnc:client:slapPlayer', function()
    local ped = PlayerPedId()
    ApplyForceToEntity(ped, 1, 0.0, 0.0, 8.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
    SetPedToRagdoll(ped, 2000, 2000, 0, false, false, false)
    TriggerEvent('mtnc:client:notify', '💥 Du blev slappet af Staff!', 'error')
end)

RegisterNetEvent('mtnc:client:ragdollPlayer', function()
    SetPedToRagdoll(PlayerPedId(), 5000, 5000, 0, false, false, false)
end)

-- 11. Spectate & Freeze
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

-- 12. In-game Commands
RegisterCommand('noclip', function()
    TriggerEvent('mtnc:client:toggleNoclip')
end, false)

RegisterCommand('names', function()
    TriggerEvent('mtnc:client:toggleNames')
end, false)

RegisterCommand('blips', function()
    TriggerEvent('mtnc:client:toggleBlips')
end, false)

RegisterCommand('coords', function()
    TriggerEvent('mtnc:client:toggleCoords')
end, false)

RegisterCommand('maxmods', function()
    TriggerEvent('mtnc:client:maxTuneVehicle')
end, false)

RegisterCommand('admincar', function()
    TriggerEvent('mtnc:client:saveCurrentCar')
end, false)
