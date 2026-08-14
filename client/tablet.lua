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

RegisterNUICallback('getVehicles', function(data, cb)
    TriggerServerEvent('mtnc:server:getVehicles')
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

RegisterNetEvent('mtnc:client:receiveVehicles', function(data)
    SendNUIMessage({ action = 'setVehicles', data = data })
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


-- ============================================================
-- 🛡️ ADMIN SUITE: NUI CALLBACKS & SERVER SYNC
-- ============================================================
RegisterNUICallback('adminGetPlayers', function(data, cb)
    TriggerServerEvent('mtnc:server:getOnlinePlayers')
    cb('ok')
end)

RegisterNUICallback('adminPlayerAction', function(data, cb)
    TriggerServerEvent('mtnc:server:adminAction', data.targetSrc, data.action, data.val1, data.val2)
    cb('ok')
end)

RegisterNUICallback('adminServerAction', function(data, cb)
    TriggerServerEvent('mtnc:server:serverAction', data.action, data.val1, data.val2)
    cb('ok')
end)

RegisterNUICallback('adminSelfAction', function(data, cb)
    local action = data.action
    if action == 'noclip' then
        TriggerEvent('mtnc:client:toggleNoclip')
    elseif action == 'godmode' then
        TriggerEvent('mtnc:client:toggleGodmode')
    elseif action == 'invisible' then
        TriggerEvent('mtnc:client:toggleInvisible')
    elseif action == 'superRun' then
        TriggerEvent('mtnc:client:toggleSuperRun')
    elseif action == 'superJump' then
        TriggerEvent('mtnc:client:toggleSuperJump')
    elseif action == 'infiniteAmmo' then
        TriggerEvent('mtnc:client:toggleInfiniteAmmo')
    elseif action == 'tpWaypoint' then
        TriggerEvent('mtnc:client:tpToWaypoint')
    elseif action == 'names' then
        TriggerEvent('mtnc:client:toggleNames')
    elseif action == 'blips' then
        TriggerEvent('mtnc:client:toggleBlips')
    elseif action == 'coords' then
        TriggerEvent('mtnc:client:toggleCoords')
    elseif action == 'reviveSelf' then
        TriggerServerEvent('mtnc:server:adminAction', GetPlayerServerId(PlayerId()), 'revive')
    elseif action == 'healSelf' then
        TriggerServerEvent('mtnc:server:adminAction', GetPlayerServerId(PlayerId()), 'heal')
    end
    cb('ok')
end)

RegisterNUICallback('adminVehicleAction', function(data, cb)
    local action = data.action
    if action == 'repair' then
        TriggerEvent('mtnc:client:repairVehicle')
    elseif action == 'tune' then
        TriggerEvent('mtnc:client:maxTuneVehicle')
    elseif action == 'refuel' then
        TriggerEvent('mtnc:client:refuelVehicle')
    elseif action == 'delete' then
        TriggerEvent('mtnc:client:deleteCurrentVehicle')
    elseif action == 'spawn' then
        TriggerEvent('mtnc:client:spawnVehicleLocal', data.model or 'adder')
    end
    cb('ok')
end)

RegisterNUICallback('adminSearchPlate', function(data, cb)
    TriggerServerEvent('mtnc:server:searchVehicle', data.plate)
    cb('ok')
end)

-- Receive Server Admin Events
RegisterNetEvent('mtnc:client:receiveOnlinePlayers', function(players)
    SendNUIMessage({ action = 'setAdminPlayers', data = players })
end)

RegisterNetEvent('mtnc:client:receiveVehicleSearch', function(matches)
    SendNUIMessage({ action = 'setAdminVehicleSearch', data = matches })
end)


RegisterNUICallback('adminGetStaffList', function(data, cb)
    TriggerServerEvent('mtnc:server:getStaffList')
    cb('ok')
end)

RegisterNUICallback('adminAddStaff', function(data, cb)
    TriggerServerEvent('mtnc:server:addStaffMember', data.identifier, data.name, data.rank)
    cb('ok')
end)

RegisterNUICallback('adminRemoveStaff', function(data, cb)
    TriggerServerEvent('mtnc:server:removeStaffMember', data.id)
    cb('ok')
end)

RegisterNUICallback('adminUpdateStaffRank', function(data, cb)
    TriggerServerEvent('mtnc:server:updateStaffRank', data.id, data.rank)
    cb('ok')
end)

RegisterNetEvent('mtnc:client:receiveStaffList', function(staff)
    SendNUIMessage({ action = 'setAdminStaffList', data = staff })
end)


RegisterNUICallback('adminTpHub', function(data, cb)
    TriggerEvent('mtnc:client:tpToHub', data.hubKey)
    cb('ok')
end)

RegisterNUICallback('adminGiveWeapon', function(data, cb)
    TriggerEvent('mtnc:client:giveWeaponLocal', data.weapon, data.ammo)
    cb('ok')
end)

RegisterNUICallback('adminClearWeapons', function(data, cb)
    TriggerEvent('mtnc:client:clearWeaponsLocal')
    cb('ok')
end)

RegisterNUICallback('adminGiveArmor', function(data, cb)
    TriggerEvent('mtnc:client:giveArmorLocal')
    cb('ok')
end)

RegisterNUICallback('adminVehExtra', function(data, cb)
    local action = data.action
    if action == 'flip' then
        TriggerEvent('mtnc:client:flipVehicle')
    elseif action == 'godmode' then
        TriggerEvent('mtnc:client:toggleVehGodmode')
    elseif action == 'plate' then
        TriggerEvent('mtnc:client:changePlateText', data.plate or 'ADMIN')
    elseif action == 'saveCar' then
        TriggerEvent('mtnc:client:saveCurrentCar')
    elseif action == 'lock' then
        TriggerEvent('mtnc:client:toggleDoorLocks')
    elseif action == 'color' then
        TriggerEvent('mtnc:client:changeVehColorPreset', data.color or 'black')
    end
    cb('ok')
end)


-- ============================================================
-- 🏢 BOSS & FIRMA CALLBACKS
-- ============================================================
RegisterNUICallback('getBossData', function(data, cb)
    TriggerServerEvent('mtnc:server:getBossData')
    cb('ok')
end)

RegisterNUICallback('bossDeposit', function(data, cb)
    TriggerServerEvent('mtnc:server:bossDeposit', data.amount)
    cb('ok')
end)

RegisterNUICallback('bossWithdraw', function(data, cb)
    TriggerServerEvent('mtnc:server:bossWithdraw', data.amount)
    cb('ok')
end)

RegisterNUICallback('bossHire', function(data, cb)
    TriggerServerEvent('mtnc:server:bossHire', data.targetId, data.grade)
    cb('ok')
end)

RegisterNUICallback('bossFire', function(data, cb)
    TriggerServerEvent('mtnc:server:bossFire', data.citizenid)
    cb('ok')
end)

RegisterNUICallback('bossSetGrade', function(data, cb)
    TriggerServerEvent('mtnc:server:bossSetGrade', data.citizenid, data.grade)
    cb('ok')
end)

RegisterNetEvent('mtnc:client:receiveBossData', function(data)
    SendNUIMessage({ action = 'setBossData', data = data })
end)


RegisterNUICallback('adminGetAuditLogs', function(data, cb)
    TriggerServerEvent('mtnc:server:getAuditLogs')
    cb('ok')
end)

RegisterNUICallback('adminClearAuditLogs', function(data, cb)
    TriggerServerEvent('mtnc:server:clearAuditLogs')
    cb('ok')
end)

RegisterNetEvent('mtnc:client:receiveAuditLogs', function(logs)
    SendNUIMessage({ action = 'setAdminAuditLogs', data = logs })
end)

RegisterNUICallback('adminGetBans', function(data, cb)
    TriggerServerEvent('mtnc:server:getBansList')
    cb('ok')
end)

RegisterNUICallback('adminUnban', function(data, cb)
    TriggerServerEvent('mtnc:server:unbanPlayer', data.id)
    cb('ok')
end)

RegisterNetEvent('mtnc:client:receiveBansList', function(bans)
    SendNUIMessage({ action = 'setAdminBansList', data = bans })
end)
