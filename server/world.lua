-- ── TXADMIN EVENT LISTENERS ────────────────────────────
AddEventHandler("txAdmin:events:announcement", function(eventData)
    local author  = eventData.author or "txAdmin"
    local message = eventData.message or ""
    TriggerClientEvent("mtnc:notify", -1, string.format("📢 txAdmin [%s]: %s", author, message), "warn")
    TriggerEvent("mtnc:apiLog", "WARN", "TXADMIN_ANNOUNCEMENT", string.format("txAdmin Announcement af %s: %s", author, message))
end)

AddEventHandler("txAdmin:events:serverShuttingDown", function(eventData)
    local author = eventData.author or "txAdmin"
    local reason = eventData.message or "Planlagt genstart"
    TriggerClientEvent("mtnc:notify", -1, string.format("🚨 SERVER GENSTARTER [%s]: %s", author, reason), "error")
    TriggerEvent("mtnc:apiLog", "ERROR", "TXADMIN_RESTART", string.format("Server genstarter via txAdmin (%s): %s", author, reason))
end)

RegisterNetEvent("mtnc:worldAction")
AddEventHandler("mtnc:worldAction", function(data)
    local src = source
    if not _G.MTNCHasAccess(src) then
        TriggerClientEvent("mtnc:notify", src, Config.messages.actionDenied, "error")
        return
    end

    local action    = data.action
    local adminName = GetPlayerName(src)

    -- ── SKIFT VEJR ────────────────────────────────────────
    if action == "setWeather" then
        local weatherType = data.weather or "CLEAR"
        if GetResourceState("vSync") == "started" then
            ExecuteCommand("weather " .. weatherType)
        else
            SetWeatherTypePersist(weatherType)
            SetWeatherTypeNowPersist(weatherType)
            SetWeatherTypeNow(weatherType)
            SetOverrideWeather(weatherType)
        end
        TriggerClientEvent("mtnc:notify", -1, string.format("🌤️ Vejret er ændret til %s af admin", weatherType), "info")
        TriggerClientEvent("mtnc:notify", src, "✅ Vejr ændret til: " .. weatherType, "success")
        TriggerEvent("mtnc:apiLog", "INFO", "WORLD_WEATHER", string.format("%s ændrede vejret til %s", adminName, weatherType))

    -- ── SKIFT TID ─────────────────────────────────────────
    elseif action == "setTime" then
        local hour   = tonumber(data.hour) or 12
        local minute = tonumber(data.minute) or 0
        if GetResourceState("vSync") == "started" then
            ExecuteCommand(string.format("time %d %d", hour, minute))
        else
            NetworkOverrideClockTime(hour, minute, 0)
        end
        TriggerClientEvent("mtnc:notify", -1, string.format("⏰ Tiden er sat til %02d:%02d", hour, minute), "info")
        TriggerClientEvent("mtnc:notify", src, string.format("✅ Tid sat til %02d:%02d", hour, minute), "success")
        TriggerEvent("mtnc:apiLog", "INFO", "WORLD_TIME", string.format("%s ændrede tiden til %02d:%02d", adminName, hour, minute))

    -- ── BROADCAST ANNOUNCEMENT ───────────────────────────
    elseif action == "announcement" then
        local message = data.message or ""
        if message == "" then return end

        TriggerClientEvent("mtnc:notify", -1, string.format("📢 ADMIN ANNOUNCEMENT:\n%s", message), "warn")
        -- Call txAdmin export if txAdmin (monitor) is running
        if GetResourceState("monitor") == "started" then
            pcall(function() exports['monitor']:announce(message, adminName) end)
        end
        TriggerClientEvent("mtnc:notify", src, "✅ Announcement sendt til alle spillere", "success")
        TriggerEvent("mtnc:apiLog", "WARN", "ANNOUNCEMENT", string.format("%s sendte announcement: %s", adminName, message))

    -- ── RESOURCE RESTART / START / STOP ───────────────────
    elseif action == "restartResource" or action == "startResource" or action == "stopResource" then
        local resName = data.resourceName or ""
        if resName == "" then return end

        local cmdMap = { restartResource = "restart", startResource = "start", stopResource = "stop" }
        local cmd = cmdMap[action] or "restart"

        if action == "restartResource" and GetResourceState(resName) == "missing" then
            TriggerClientEvent("mtnc:notify", src, "❌ Ressourcen '" .. resName .. "' findes ikke!", "error")
            return
        end

        ExecuteCommand(cmd .. " " .. resName)
        TriggerClientEvent("mtnc:notify", src, string.format("🔄 Executed '%s %s'", cmd, resName), "success")
        TriggerEvent("mtnc:apiLog", "WARN", "RESOURCE_ACTION", string.format("%s kørte '%s %s'", adminName, cmd, resName))

    -- ── GENSTART SERVER (txAdmin & Native fallback) ──────
    elseif action == "restartServer" then
        local reason = data.reason or "Server genstartet af admin"
        TriggerClientEvent("mtnc:notify", -1, string.format("🚨 SERVER GENSTARTER OM 10 SEKUNDER: %s", reason), "error")
        TriggerEvent("mtnc:apiLog", "WARN", "SERVER_RESTART", string.format("%s igangsatte server genstart: %s", adminName, reason))

        -- Trigger txAdmin restart if available
        if GetResourceState("monitor") == "started" then
            pcall(function()
                ExecuteCommand("txAdmin:scheduledRestart " .. reason)
            end)
        end

        Citizen.SetTimeout(10000, function()
            ExecuteCommand("quit \"" .. reason .. "\"")
        end)
    end
end)
