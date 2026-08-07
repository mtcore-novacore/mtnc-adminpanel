-- ──────────────────────────────────────────────────────
--  MTNC Admin Panel — Server Players
--  Håndterer: kick, ban, freeze, revive, heal, teleport
--             bring, godmode, warn
-- ──────────────────────────────────────────────────────

local bannedPlayers = {}  -- In-memory ban list (overvej database til persistent bans)

RegisterNetEvent("mtnc:playerAction")
AddEventHandler("mtnc:playerAction", function(data)
    local src    = source
    if not _G.MTNCHasAccess(src) then
        TriggerClientEvent("mtnc:notify", src, Config.messages.actionDenied, "error")
        return
    end

    local action   = data.action
    local targetId = tonumber(data.targetId)
    local extra    = data.extra or {}

    if not targetId or not GetPlayerName(targetId) then
        TriggerClientEvent("mtnc:notify", src, Config.messages.playerGone, "error")
        return
    end

    local adminName  = GetPlayerName(src)
    local targetName = GetPlayerName(targetId)

    -- ── KICK ──────────────────────────────────────────
    if action == "kick" then
        local reason = extra.reason or "Kicked af admin"
        DropPlayer(targetId, "Du er blevet kicked: " .. reason)
        TriggerClientEvent("mtnc:notify", src, "✅ Kickede: " .. targetName, "success")
        TriggerEvent("mtnc:apiLog", "WARN", "KICK",
            string.format("%s kickede %s. Årsag: %s", adminName, targetName, reason))

    -- ── BAN ───────────────────────────────────────────
    elseif action == "ban" then
        local reason   = extra.reason or "Banned af admin"
        local duration = extra.duration or "permanent"

        -- Gem identifiers
        local identifiers = GetPlayerIdentifiers(targetId)
        bannedPlayers[targetId] = {
            name        = targetName,
            reason      = reason,
            bannedBy    = adminName,
            bannedAt    = os.time(),
            duration    = duration,
            identifiers = identifiers,
        }

        DropPlayer(targetId, "Du er blevet banned: " .. reason)
        TriggerClientEvent("mtnc:notify", src, "✅ Bannede: " .. targetName, "success")
        TriggerEvent("mtnc:apiLog", "ERROR", "BAN",
            string.format("%s bannede %s. Årsag: %s | Varighed: %s", adminName, targetName, reason, duration))

    -- ── WARN ──────────────────────────────────────────
    elseif action == "warn" then
        local reason = extra.reason or "Advarsel fra admin"
        TriggerClientEvent("mtnc:notify", targetId,
            string.format("⚠️ ADVARSEL fra %s: %s", adminName, reason), "warn")
        TriggerClientEvent("mtnc:notify", src, "✅ Advarsel sendt til: " .. targetName, "success")
        TriggerEvent("mtnc:apiLog", "WARN", "WARN",
            string.format("%s advarede %s: %s", adminName, targetName, reason))

    -- ── FREEZE ────────────────────────────────────────
    elseif action == "freeze" then
        local state = extra.state  -- true = fryser, false = unfreezer
        TriggerClientEvent("mtnc:client:freezePlayer", targetId, state)
        local stateText = state and "fryst" or "unfryser"
        TriggerClientEvent("mtnc:notify", src, "✅ " .. targetName .. " er nu " .. stateText, "success")
        TriggerEvent("mtnc:apiLog", "INFO", "FREEZE",
            string.format("%s %s %s", adminName, stateText, targetName))

    -- ── REVIVE ────────────────────────────────────────
    elseif action == "revive" then
        TriggerClientEvent("mtnc:client:revivePlayer", targetId)
        TriggerClientEvent("mtnc:notify", src, "✅ Revivede: " .. targetName, "success")
        TriggerEvent("mtnc:apiLog", "INFO", "REVIVE",
            string.format("%s revivede %s", adminName, targetName))

    -- ── HEAL ──────────────────────────────────────────
    elseif action == "heal" then
        TriggerClientEvent("mtnc:client:healPlayer", targetId)
        TriggerClientEvent("mtnc:notify", src, "✅ Healede: " .. targetName, "success")
        TriggerEvent("mtnc:apiLog", "INFO", "HEAL",
            string.format("%s healede %s", adminName, targetName))

    -- ── TELEPORT TO ────────────────────────────────────
    elseif action == "teleportTo" then
        local targetNetId = NetworkGetNetworkIdFromEntity(GetPlayerPed(targetId))
        TriggerClientEvent("mtnc:client:staffAction", src, {
            action       = "teleportToPlayer",
            targetNetId  = targetNetId
        })
        TriggerClientEvent("mtnc:notify", src, "📍 Teleporterer til: " .. targetName, "success")

    -- ── BRING ─────────────────────────────────────────
    elseif action == "bring" then
        local adminPed  = GetPlayerPed(src)
        local adminCoords = GetEntityCoords(adminPed)
        TriggerClientEvent("mtnc:client:setPosition", targetId, {
            x = adminCoords.x + 2.0,
            y = adminCoords.y + 2.0,
            z = adminCoords.z,
        })
        TriggerClientEvent("mtnc:notify", src, "✅ Bragte: " .. targetName, "success")
        TriggerClientEvent("mtnc:notify", targetId,
            string.format("📍 Du er blevet bragt til admin: %s", adminName), "info")
        TriggerEvent("mtnc:apiLog", "INFO", "BRING",
            string.format("%s bragte %s", adminName, targetName))

    -- ── GODMODE ───────────────────────────────────────
    elseif action == "godmode" then
        local state = extra.state
        TriggerClientEvent("mtnc:client:setGodmode", targetId, state)
        local stateText = state and "godmode ON" or "godmode OFF"
        TriggerClientEvent("mtnc:notify", src, "✅ " .. targetName .. ": " .. stateText, "success")
        TriggerEvent("mtnc:apiLog", "INFO", "GODMODE",
            string.format("%s satte %s på %s", adminName, stateText, targetName))
    end
end)

-- ── CLIENT: Freeze handler ────────────────────────────
RegisterNetEvent("mtnc:client:freezePlayer")
AddEventHandler("mtnc:client:freezePlayer", function(state)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, state)
    if state then
        ClearPedTasksImmediately(ped)
    end
end)

-- ── CLIENT: Revive handler ────────────────────────────
RegisterNetEvent("mtnc:client:revivePlayer")
AddEventHandler("mtnc:client:revivePlayer", function()
    local ped = PlayerPedId()
    if IsEntityDead(ped) then
        NetworkResurrectLocalPlayer(
            GetEntityCoords(ped), 0.0, true, true)
    end
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedBloodDamage(ped)
end)

-- ── CLIENT: Heal handler ─────────────────────────────
RegisterNetEvent("mtnc:client:healPlayer")
AddEventHandler("mtnc:client:healPlayer", function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    RestorePlayerStamina(PlayerId(), 100.0)
    ClearPedBloodDamage(ped)
end)

-- ── CLIENT: Set position handler ─────────────────────
RegisterNetEvent("mtnc:client:setPosition")
AddEventHandler("mtnc:client:setPosition", function(coords)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, true)
end)

-- ── CLIENT: Set godmode handler ───────────────────────
RegisterNetEvent("mtnc:client:setGodmode")
AddEventHandler("mtnc:client:setGodmode", function(state)
    SetEntityInvincible(PlayerPedId(), state)
    SetPlayerInvincible(PlayerId(), state)
end)
