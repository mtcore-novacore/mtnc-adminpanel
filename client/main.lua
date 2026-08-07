-- ──────────────────────────────────────────────────────
--  MTNC Admin Panel — Client Main
--  Håndterer: NUI toggle, keybind, callbacks fra UI
-- ──────────────────────────────────────────────────────

local isPanelOpen = false
local adminData   = nil  -- Gemmer admin info fra server

-- ── HELPER: Åbn/luk NUI panel ─────────────────────────
local function setPanelVisible(visible, data)
    isPanelOpen = visible
    SetNuiFocus(visible, visible)
    SendNUIMessage({
        type    = "setVisible",
        visible = visible,
        data    = data or {}
    })
end

-- ── EVENTS FRA SERVER ─────────────────────────────────
RegisterNetEvent("mtnc:openPanel")
AddEventHandler("mtnc:openPanel", function(data)
    adminData = data
    setPanelVisible(true, data)
end)

RegisterNetEvent("mtnc:closePanel")
AddEventHandler("mtnc:closePanel", function()
    setPanelVisible(false)
end)

RegisterNetEvent("mtnc:updatePlayerList")
AddEventHandler("mtnc:updatePlayerList", function(players)
    SendNUIMessage({
        type    = "updatePlayers",
        players = players
    })
end)

RegisterNetEvent("mtnc:notify")
AddEventHandler("mtnc:notify", function(message, ntype)
    SendNUIMessage({
        type    = "notify",
        message = message,
        ntype   = ntype or "info"
    })
end)

RegisterNetEvent("mtnc:actionResult")
AddEventHandler("mtnc:actionResult", function(success, message)
    SendNUIMessage({
        type    = "actionResult",
        success = success,
        message = message
    })
end)

RegisterNetEvent("mtnc:logsResult")
AddEventHandler("mtnc:logsResult", function(logs)
    SendNUIMessage({
        type = "updateLogs",
        logs = logs
    })
end)

-- ── NUI CALLBACKS ─────────────────────────────────────

-- Luk panel
RegisterNUICallback("closePanel", function(_, cb)
    setPanelVisible(false)
    if cb then cb("ok") end
end)

-- Anmod om opdateret spillerliste
RegisterNUICallback("getPlayers", function(_, cb)
    TriggerServerEvent("mtnc:requestPlayers")
    if cb then cb("ok") end
end)

-- Anmod om logs fra backend
RegisterNUICallback("getLogs", function(data, cb)
    TriggerServerEvent("mtnc:requestLogs", data)
    if cb then cb("ok") end
end)

-- Spiller handlinger (kick, ban, freeze, teleport etc.)
RegisterNUICallback("playerAction", function(data, cb)
    TriggerServerEvent("mtnc:playerAction", data)
    if cb then cb("ok") end
end)

-- Verden handlinger (vejr, tid, restart, announcement)
RegisterNUICallback("worldAction", function(data, cb)
    TriggerServerEvent("mtnc:worldAction", data)
    if cb then cb("ok") end
end)

-- Økonomi handlinger (give/remove penge)
RegisterNUICallback("economyAction", function(data, cb)
    TriggerServerEvent("mtnc:economyAction", data)
    if cb then cb("ok") end
end)

-- Vehicle spawn (client-side)
RegisterNUICallback("spawnVehicle", function(data, cb)
    TriggerEvent("mtnc:client:spawnVehicle", data.model)
    if cb then cb("ok") end
end)

-- Delete nearest vehicle (client-side)
RegisterNUICallback("deleteVehicle", function(_, cb)
    TriggerEvent("mtnc:client:deleteVehicle")
    if cb then cb("ok") end
end)

-- Repair vehicle (client-side)
RegisterNUICallback("repairVehicle", function(_, cb)
    TriggerEvent("mtnc:client:repairVehicle")
    if cb then cb("ok") end
end)

-- Staff tools (noclip, godmode, invisible, spectate)
RegisterNUICallback("staffAction", function(data, cb)
    TriggerEvent("mtnc:client:staffAction", data)
    if cb then cb("ok") end
end)

-- ── KEYBIND & KOMMANDO ────────────────────────────────
Citizen.CreateThread(function()
    -- /admin kommando
    RegisterCommand(Config.general.openCommand or "admin", function()
        if isPanelOpen then
            setPanelVisible(false)
        else
            TriggerServerEvent("mtnc:requestPanel")
        end
    end, false)

    -- Numpad 8 (eller konfigureret hotkey) toggle
    RegisterKeyMapping(
        Config.general.openCommand or "admin",
        "Åbn MTNC Admin Panel",
        "keyboard",
        "NUMPAD8"
    )

    -- Esc / close key mens panel er åbent
    while true do
        Citizen.Wait(0)
        if isPanelOpen then
            if IsControlJustReleased(0, Config.general.closeKey or 322) then
                setPanelVisible(false)
            end
        end
    end
end)
