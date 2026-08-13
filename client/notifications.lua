-- ============================================================
-- MTNC NOTIFICATIONS & SOUNDS
-- ============================================================
RegisterNetEvent('mtnc:client:toast', function(msg, toastType)
    SendNUIMessage({
        action = 'toast',
        msg = msg,
        toastType = toastType or 'info'
    })
end)
