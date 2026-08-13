-- ============================================================
-- MTNC TABLET NUI CALLBACKS & COMMUNICATION
-- ============================================================

RegisterNUICallback('closeTablet', function(data, cb)
    ToggleTablet(false)
    cb('ok')
end)

RegisterNUICallback('getJobs', function(data, cb)
    TriggerServerEvent('mtnc:server:getJobs')
    cb('ok')
end)

RegisterNUICallback('toggleDuty', function(data, cb)
    TriggerServerEvent('mtnc:server:toggleDuty')
    cb('ok')
end)

RegisterNUICallback('switchJob', function(data, cb)
    TriggerServerEvent('mtnc:server:switchJob', data.jobName, data.grade)
    cb('ok')
end)

RegisterNUICallback('requestPhonePinReset', function(data, cb)
    TriggerServerEvent('mtnc:server:requestPinReset', data.reason)
    cb('ok')
end)

RegisterNUICallback('getReports', function(data, cb)
    TriggerServerEvent('mtnc:server:getReports')
    cb('ok')
end)

RegisterNUICallback('createReport', function(data, cb)
    TriggerServerEvent('mtnc:server:createReport', data)
    cb('ok')
end)

RegisterNUICallback('actionReport', function(data, cb)
    TriggerServerEvent('mtnc:server:actionReport', data.id, data.action)
    cb('ok')
end)

RegisterNUICallback('getPinRequests', function(data, cb)
    TriggerServerEvent('mtnc:server:getPinRequests')
    cb('ok')
end)

RegisterNUICallback('handlePinRequest', function(data, cb)
    TriggerServerEvent('mtnc:server:handlePinRequest', data.id, data.approve)
    cb('ok')
end)

RegisterNUICallback('getPhotos', function(data, cb)
    TriggerServerEvent('mtnc:server:getPhotos')
    cb('ok')
end)

RegisterNUICallback('getUpdates', function(data, cb)
    TriggerServerEvent('mtnc:server:getUpdates')
    cb('ok')
end)

RegisterNUICallback('adminAction', function(data, cb)
    TriggerServerEvent('mtnc:server:adminAction', data.targetSrc, data.action, data.reason)
    cb('ok')
end)

-- Receive Events from Server
RegisterNetEvent('mtnc:client:receiveJobs', function(data)
    SendNUIMessage({ action = 'setJobs', data = data })
end)

RegisterNetEvent('mtnc:client:receivePhotos', function(data)
    SendNUIMessage({ action = 'setPhotos', data = data })
end)

RegisterNetEvent('mtnc:client:photoSaved', function(item)
    SendNUIMessage({ action = 'addPhoto', data = item })
end)

RegisterNetEvent('mtnc:client:receiveReports', function(data)
    SendNUIMessage({ action = 'setReports', data = data })
end)

RegisterNetEvent('mtnc:client:receivePinRequests', function(data)
    SendNUIMessage({ action = 'setPinRequests', data = data })
end)

RegisterNetEvent('mtnc:client:receiveUpdates', function(data)
    SendNUIMessage({ action = 'setUpdates', data = data })
end)
