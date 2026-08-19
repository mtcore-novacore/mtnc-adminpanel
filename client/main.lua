-- ============================================================
-- MTNC ADMIN TABLET v3.0.1 — CLIENT MAIN ENTRYPOINT
-- ============================================================
local isTabletOpen = false
local tabletProp = nil

function ToggleTablet(state)
    if state == nil then
        isTabletOpen = not isTabletOpen
    else
        isTabletOpen = state
    end

    SetNuiFocus(isTabletOpen, isTabletOpen)
    SendNUIMessage({
        action = 'toggleTablet',
        open = isTabletOpen
    })

    local ped = PlayerPedId()

    if isTabletOpen then
        -- Tablet Prop & Holding Animation
        if Config.UseAnimation then
            local dict = "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a"
            RequestAnimDict(dict)
            while not HasAnimDictLoaded(dict) do Wait(10) end
            TaskPlayAnim(ped, dict, "idle_a", 3.0, 3.0, -1, 49, 0, false, false, false)

            local model = GetHashKey(Config.TabletProp or 'prop_cs_tablet')
            RequestModel(model)
            while not HasModelLoaded(model) do Wait(10) end
            tabletProp = CreateObject(model, 0.0, 0.0, 0.0, true, true, false)
            AttachEntityToEntity(tabletProp, ped, GetPedBoneIndex(ped, 60309), 0.03, 0.002, -0.0, 10.0, 160.0, 0.0, true, false, false, false, 2, true)
        end

        TriggerServerEvent('mtnc:server:openTablet')
    else
        if tabletProp then
            DeleteEntity(tabletProp)
            tabletProp = nil
        end
        ClearPedTasks(ped)
    end
end

RegisterNetEvent('mtnc:client:initTablet', function(data)
    SendNUIMessage({
        action = 'initTablet',
        data = data
    })
end)

RegisterNetEvent('mtnc:client:freezePlayer', function()
    local ped = PlayerPedId()
    local isFrozen = IsEntityPositionFrozen(ped)
    FreezeEntityPosition(ped, not isFrozen)
end)

-- Keybinding F10 & Command /tablet
RegisterCommand(Config.OpenCommand or 'tablet', function()
    ToggleTablet()
end, false)

RegisterCommand(Config.AdminCommand or 'admin', function()
    ToggleTablet(true)
    SendNUIMessage({ action = 'openAdminApp' })
end, false)

RegisterKeyMapping(Config.OpenCommand or 'tablet', 'Åbn MTNC Tablet OS', 'keyboard', Config.OpenKey or 'F10')

-- ============================================================
-- 🔄 CLIENT FRAMEWORK EVENT LISTENERS
-- ============================================================
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('mtnc:server:openTablet')
end)

RegisterNetEvent('esx:playerLoaded', function()
    TriggerServerEvent('mtnc:server:openTablet')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    if isTabletOpen then
        ToggleTablet(false)
    end
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    if isTabletOpen then
        ToggleTablet(false)
    end
end)
