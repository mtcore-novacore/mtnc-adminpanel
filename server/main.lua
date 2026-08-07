local function getPlayerIdentifiers(src)
    local ids = {}
    for _, id in ipairs(GetPlayerIdentifiers(src) or {}) do
        ids[id] = true
    end
    return ids
end

local function safeDecodeJson(body)
    if not body or body == "" then
        return nil
    end

    local success, decoded = pcall(function()
        return json.decode(body)
    end)

    if success then
        return decoded
    end

    return nil
end

local function syncServerWithApi()
    if not Config.api or not Config.api.enabled then
        return
    end

    local payload = {
        id = "fivem-server-local",
        name = Config.api.serverName or "NovaCore FiveM Server",
        ip = "127.0.0.1",
        port = tonumber(GetConvar("sv_port", "30120")) or 30120,
        region = "local",
        status = "ONLINE",
        role = "MASTER",
        licenseKey = GetConvar("sv_licenseKey", "MTNC-LOCAL-LICENSE"),
        latencyMs = 3,
        version = GetResourceMetadata(GetCurrentResourceName(), "version") or "unknown",
        syncState = {
            inSync = true,
            lastSyncedAt = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            versionHash = "fivem-local-sync"
        }
    }

    PerformHttpRequest(Config.api.baseUrl .. (Config.api.registerEndpoint or "/api/servers/register"), function(statusCode, body)
        if statusCode == 200 then
            print("[mtnc-adminpanel] Server synced with API successfully.")
            return
        end

        print(string.format("[mtnc-adminpanel] API sync failed with status %s", tostring(statusCode)))
    end, "POST", json.encode(payload), { ["Content-Type"] = "application/json" })
end

local function heartbeatToApi()
    if not Config.api or not Config.api.enabled then
        return
    end

    local payload = {
        id = "fivem-server-local",
        latencyMs = 3
    }

    PerformHttpRequest(Config.api.baseUrl .. (Config.api.heartbeatEndpoint or "/api/servers/heartbeat"), function(statusCode, body)
        if statusCode ~= 200 then
            print(string.format("[mtnc-adminpanel] API heartbeat failed with status %s", tostring(statusCode)))
        end
    end, "POST", json.encode(payload), { ["Content-Type"] = "application/json" })
end

local function getDatabaseAdminRole(src)
    if not Config.permissions or not Config.permissions.useDatabaseUsers then
        return nil
    end

    local ids = getPlayerIdentifiers(src)
    local steam = nil
    for _, id in ipairs(ids) do
        if string.sub(id or "", 1, 6) == "steam:" then
            steam = id
            break
        end
    end

    if not steam then
        return nil
    end

    local result = MySQL.Sync.fetchAll('SELECT role, is_active FROM mtnc_admin_users WHERE steam = @steam LIMIT 1', {
        ['@steam'] = steam
    })

    if result and result[1] then
        if result[1].is_active ~= 1 then
            return nil
        end
        return result[1].role
    end

    return nil
end

local function hasAccess(src)
    if Config.permissions and Config.permissions.allowAll then
        return true
    end

    if Config.general and Config.general.allowAll then
        return true
    end

    local ids = getPlayerIdentifiers(src)
    for _, steamId in ipairs(Config.permissions and Config.permissions.allowedSteamIds or Config.allowedSteamIds or {}) do
        if ids[steamId] then
            return true
        end
    end

    local dbRole = getDatabaseAdminRole(src)
    if dbRole then
        return true
    end

    if Config.permissions and Config.permissions.enableFrameworkCheck then
        if Config.framework == "esx" and GetResourceState("es_extended") == "started" then
            local xPlayer = exports["es_extended"]:getPlayerFromId(src)
            if xPlayer then
                local group = xPlayer.getGroup and xPlayer.getGroup() or nil
                for _, allowedGroup in ipairs(Config.permissions.esxGroups or {}) do
                    if group == allowedGroup then
                        return true
                    end
                end
            end
        end

        if Config.framework == "qbcore" and GetResourceState("qb-core") == "started" then
            local player = exports["qb-core"]:GetPlayer(src)
            if player then
                local job = player.PlayerData and player.PlayerData.job and player.PlayerData.job.name or nil
                for _, allowedRole in ipairs(Config.permissions.qbRoles or {}) do
                    if job == allowedRole then
                        return true
                    end
                end
            end
        end
    end

    return false
end

Citizen.CreateThread(function()
    Citizen.Wait(2000)
    syncServerWithApi()

    while true do
        Citizen.Wait((Config.api and Config.api.timeout or 5000) + 25000)
        heartbeatToApi()
    end
end)

RegisterNetEvent("mtnc:requestAdminPanel")
AddEventHandler("mtnc:requestAdminPanel", function()
    local src = source
    if not hasAccess(src) then
        TriggerClientEvent("mtnc:notify", src, "Du har ikke adgang til admin-panelet.")
        return
    end

    TriggerClientEvent("mtnc:openAdminPanel", src)
end)

RegisterNetEvent("mtnc:adminAction")
AddEventHandler("mtnc:adminAction", function(action)
    local src = source
    if not hasAccess(src) then
        return
    end

    print(('[mtnc-adminpanel] %s (%s) triggered action: %s'):format(GetPlayerName(src), src, tostring(action)))
    TriggerClientEvent("mtnc:notify", src, string.format("Handling udført: %s", tostring(action)))
end)
