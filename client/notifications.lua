-- ============================================================
-- MTNC NOTIFICATIONS & BROADCAST ANNOUNCEMENTS
-- ============================================================
RegisterNetEvent('mtnc:client:toast', function(msg, toastType)
    SendNUIMessage({
        action = 'toast',
        msg = msg,
        toastType = toastType or 'info'
    })
end)

RegisterNetEvent('mtnc:client:broadcastAnnouncement', function(msg, author)
    -- Play high-priority frontend sound
    PlaySoundFrontend(-1, "Event_Message_Purple", "GTAO_FM_Events_Soundset", true)

    -- Display on-screen announcement popup
    SendNUIMessage({
        action = 'showAnnouncementBanner',
        data = {
            message = msg,
            author = author or 'ADMINISTRATION'
        }
    })

    -- Trigger framework notify fallback if present
    if GetResourceState('qb-core') == 'started' then
        local QBCore = exports['qb-core']:GetCoreObject()
        if QBCore then
            QBCore.Functions.Notify(msg, 'error', 9000)
        end
    end
end)
