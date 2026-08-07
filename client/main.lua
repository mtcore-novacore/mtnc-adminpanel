local isPanelOpen = false
local panelCooldown = false

local function setPanelVisible(visible)
    isPanelOpen = visible
    SetNuiFocus(visible, visible)
    SendNUIMessage({
        type = "setVisible",
        visible = visible
    })
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

local function syncClientWithApi()
    if not Config.api or not Config.api.enabled then
        return
    end

    local apiUrl = Config.api.baseUrl .. (Config.api.configEndpoint or "/api/config")
    PerformHttpRequest(apiUrl, function(statusCode, body)
        if statusCode == 200 then
            local decoded = safeDecodeJson(body)
            if decoded then
                print("[mtnc-adminpanel] Client synced with API successfully.")
                SendNUIMessage({
                    type = "notify",
                    message = "API-forbindelse aktiv"
                })
            end
            return
        end

        print(string.format("[mtnc-adminpanel] Client API sync failed with status %s", tostring(statusCode)))
    end, "GET", "", { ["Content-Type"] = "application/json" })
end

local function togglePanel()
    if panelCooldown then
        return
    end

    panelCooldown = true
    Citizen.SetTimeout(250, function()
        panelCooldown = false
    end)

    if isPanelOpen then
        setPanelVisible(false)
    else
        TriggerServerEvent("mtnc:requestAdminPanel")
    end
end

RegisterNetEvent("mtnc:openAdminPanel")
AddEventHandler("mtnc:openAdminPanel", function()
    setPanelVisible(true)
end)

RegisterNetEvent("mtnc:closeAdminPanel")
AddEventHandler("mtnc:closeAdminPanel", function()
    setPanelVisible(false)
end)

RegisterNetEvent("mtnc:notify")
AddEventHandler("mtnc:notify", function(message)
    SendNUIMessage({
        type = "notify",
        message = message
    })
end)

RegisterNUICallback("closePanel", function(_, cb)
    setPanelVisible(false)
    if cb then cb("ok") end
end)

RegisterNUICallback("performAction", function(data, cb)
    local action = data and data.action or "unknown"
    TriggerServerEvent("mtnc:adminAction", action)
    SendNUIMessage({
        type = "notify",
        message = "Sender handling: " .. action
    })
    if cb then cb("ok") end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1500)
    syncClientWithApi()
end)

Citizen.CreateThread(function()
    RegisterCommand(Config.openCMD or "admin", function()
        togglePanel()
    end, false)

    while true do
        Citizen.Wait(0)
        if isPanelOpen and IsControlJustReleased(0, 322) then
            setPanelVisible(false)
        end

        if IsControlJustReleased(0, tonumber(Config.hotkey or 104) or 104) then
            togglePanel()
        end
    end
end)
