-- ──────────────────────────────────────────────────────
--  MTNC Admin Panel — Client Staff Tools
--  Håndterer: noclip, godmode, invisible, spectate, freecam
-- ──────────────────────────────────────────────────────

local isNoclip    = false
local isGodmode   = false
local isInvisible = false
local isSpectating = false
local spectateTarget = nil

-- ── STAFF ACTIONS DISPATCHER ──────────────────────────
AddEventHandler("mtnc:client:staffAction", function(data)
    local action = data and data.action or ""

    if action == "noclip" then
        toggleNoclip()
    elseif action == "godmode" then
        toggleGodmode()
    elseif action == "invisible" then
        toggleInvisible()
    elseif action == "spectate" then
        if data.targetNetId then
            startSpectate(data.targetNetId)
        else
            stopSpectate()
        end
    elseif action == "stopSpectate" then
        stopSpectate()
    elseif action == "teleportToPlayer" then
        if data.targetNetId then
            teleportToPlayer(data.targetNetId)
        end
    elseif action == "bringPlayer" then
        -- Server-side handled
    end
end)

-- ── NOCLIP ────────────────────────────────────────────
local noclipSpeed = 1.0

function toggleNoclip()
    isNoclip = not isNoclip
    local ped = PlayerPedId()

    if isNoclip then
        SetEntityCollision(ped, false, false)
        SetEntityInvincible(ped, true)
        SetPedCanRagdoll(ped, false)
        TriggerEvent("mtnc:notify", "✈️ Noclip: AKTIV", "success")

        Citizen.CreateThread(function()
            while isNoclip do
                Citizen.Wait(0)
                ped = PlayerPedId()

                DisableAllControlActions(0)
                EnableControlAction(0, 1, true)
                EnableControlAction(0, 2, true)

                local speed = noclipSpeed
                if IsControlPressed(0, 21) then speed = speed * 3.0 end -- Sprint boost
                if IsControlPressed(0, 36) then speed = speed * 0.25 end -- Slow

                local camDir  = GetGameplayCamForward()
                local rightDir = GetGameplayCamRight()

                local moveX = GetControlNormal(0, 218)  -- D
                local moveY = GetControlNormal(0, 219)  -- W

                local vel = {
                    x = (camDir.x * moveY + rightDir.x * moveX) * speed,
                    y = (camDir.y * moveY + rightDir.y * moveX) * speed,
                    z = 0.0
                }

                -- Up/down
                if IsControlPressed(0, 22) then vel.z = speed end   -- Space
                if IsControlPressed(0, 44) then vel.z = -speed end  -- Q/C

                SetEntityVelocity(ped, vel.x, vel.y, vel.z)
                FreezeEntityPosition(ped, math.abs(vel.x) < 0.01 and math.abs(vel.y) < 0.01 and math.abs(vel.z) < 0.01)
            end

            -- Restore
            SetEntityCollision(ped, true, true)
            SetEntityInvincible(ped, false)
            SetPedCanRagdoll(ped, true)
            FreezeEntityPosition(ped, false)
            TriggerEvent("mtnc:notify", "✈️ Noclip: DEAKTIV", "info")
        end)
    end
end

-- ── GODMODE ───────────────────────────────────────────
function toggleGodmode()
    isGodmode = not isGodmode
    local ped = PlayerPedId()
    SetEntityInvincible(ped, isGodmode)
    SetPlayerInvincible(PlayerId(), isGodmode)
    local status = isGodmode and "AKTIV" or "DEAKTIV"
    TriggerEvent("mtnc:notify", "🛡️ Godmode: " .. status, isGodmode and "success" or "info")
end

-- ── INVISIBLE ─────────────────────────────────────────
function toggleInvisible()
    isInvisible = not isInvisible
    local ped = PlayerPedId()
    SetEntityVisible(ped, not isInvisible, false)
    SetEntityAlpha(ped, isInvisible and 0 or 255, false)
    local status = isInvisible and "AKTIV" or "DEAKTIV"
    TriggerEvent("mtnc:notify", "👻 Invisible: " .. status, isInvisible and "success" or "info")
end

-- ── SPECTATE ──────────────────────────────────────────
function startSpectate(targetNetId)
    local targetPed = GetPlayerPed(GetPlayerFromNetworkId(targetNetId))
    if not DoesEntityExist(targetPed) then
        TriggerEvent("mtnc:notify", "❌ Spiller ikke fundet", "error")
        return
    end

    isSpectating   = true
    spectateTarget = targetNetId

    NetworkSetInSpectatorMode(true, targetPed)
    TriggerEvent("mtnc:notify", "👁️ Spectater spiller...", "info")
end

function stopSpectate()
    if isSpectating then
        isSpectating   = false
        spectateTarget = nil
        NetworkSetInSpectatorMode(false, PlayerPedId())
        TriggerEvent("mtnc:notify", "👁️ Spectate stoppet", "info")
    end
end

-- ── TELEPORT TO PLAYER ────────────────────────────────
function teleportToPlayer(targetNetId)
    local targetPed = GetPlayerPed(GetPlayerFromNetworkId(targetNetId))
    if not DoesEntityExist(targetPed) then
        TriggerEvent("mtnc:notify", "❌ Spiller ikke fundet", "error")
        return
    end

    local coords = GetEntityCoords(targetPed)
    local myPed  = PlayerPedId()

    -- Tjek om vi er i bil
    local myVeh = GetVehiclePedIsIn(myPed, false)
    if myVeh ~= 0 then
        SetEntityCoords(myVeh, coords.x + 3.0, coords.y + 3.0, coords.z, false, false, false, true)
    else
        SetEntityCoords(myPed, coords.x + 2.0, coords.y + 2.0, coords.z, false, false, false, true)
    end

    TriggerEvent("mtnc:notify", "📍 Teleporteret til spiller", "success")
end

AddEventHandler("mtnc:client:teleportToPlayer", function(targetNetId)
    teleportToPlayer(targetNetId)
end)
