local isPanelOpen = false

local function setPanelVisible(visible)
    isPanelOpen = visible
    SetNuiFocus(visible, visible)
    SendNUIMessage({
        type = "setVisible",
        visible = visible
    })
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
    TriggerServerEvent("mtnc:adminAction", data and data.action or "unknown")
    if cb then cb("ok") end
end)

Citizen.CreateThread(function()
    RegisterCommand(Config.openCMD or "admin", function()
        TriggerServerEvent("mtnc:requestAdminPanel")
    end, false)

    while true do
        Citizen.Wait(0)
        if isPanelOpen and IsControlJustReleased(0, 322) then
            setPanelVisible(false)
        end
    end
end)
