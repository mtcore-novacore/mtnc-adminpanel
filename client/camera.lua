-- ============================================================
-- MTNC CAMERA APPLICATION
-- ============================================================
local inCameraMode = false
local cameraHandle = nil

RegisterNUICallback('startCamera', function(data, cb)
    inCameraMode = true
    SetNuiFocus(true, true)

    CreateThread(function()
        while inCameraMode do
            Wait(0)
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 1, true)  -- Look Left/Right
            DisableControlAction(0, 2, true)  -- Look Up/Down
        end
    end)

    cb({ success = true })
end)

RegisterNUICallback('stopCamera', function(data, cb)
    inCameraMode = false
    if cameraHandle then
        DestroyCam(cameraHandle, false)
        RenderScriptCams(false, false, 0, 1, 0)
        cameraHandle = nil
    end
    cb({ success = true })
end)

RegisterNUICallback('capturePhoto', function(data, cb)
    -- In-game screenshot capture or placeholder payload
    local coords = GetEntityCoords(PlayerPedId())
    local zone = GetNameOfZone(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))

    TriggerServerEvent('mtnc:server:savePhoto', {
        image = data.image or 'https://images.unsplash.com/photo-1511447333015-45b65e60f6d5?w=800&auto=format&fit=crop&q=60',
        location = streetName .. ' (' .. zone .. ')'
    })

    cb({ success = true })
end)
