local function getPlayerIdentifiers(src)
    local ids = {}
    for _, id in ipairs(GetPlayerIdentifiers(src) or {}) do
        ids[id] = true
    end
    return ids
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
