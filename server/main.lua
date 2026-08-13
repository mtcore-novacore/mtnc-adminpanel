-- ============================================================
-- MTNC ADMIN TABLET v3.0.2 - SERVER MAIN ENTRYPOINT
-- ============================================================

RegisterNetEvent('mtnc:server:openTablet', function()
    local src = source
    if not Security.RateLimit(src) then return end

    local role = Permissions.GetPlayerRole(src)
    local isStaff = Permissions.HasPermission(src, 'admin.access')

    local charName = FrameworkAdapter.GetCharacterName(src)
    local primaryJob = FrameworkAdapter.GetPrimaryJob(src)
    local phone = PhoneAdapter.GetPhoneNumber(src) or '+45 XXXXXXXX'

    TriggerClientEvent('mtnc:client:initTablet', src, {
        session = {
            id = src,
            name = charName,
            role = role,
            isStaff = isStaff,
            serverName = GetConvar("sv_hostname", "FiveM Server"),
            uptime = os.time()
        },
        profile = {
            name = charName,
            serverId = src,
            primaryJob = primaryJob,
            phone = phone
        },
        licenseStatus = License.Status
    })
end)

-- Live Database Vehicle Fetching for Tablet
RegisterNetEvent('mtnc:server:getVehicles', function()
    local src = source
    if not Security.RateLimit(src) then return end

    local vehicles = VehicleAdapter.GetOwnedVehicles(src)
    TriggerClientEvent('mtnc:client:receiveVehicles', src, vehicles)
end)

-- Staff Search Vehicle Plate Owner in Database
RegisterNetEvent('mtnc:server:searchVehicle', function(plate)
    local src = source
    if not Permissions.HasPermission(src, 'admin.access') then return end

    local matches = VehicleAdapter.LookupPlate(plate)
    TriggerClientEvent('mtnc:client:receiveVehicleSearch', src, matches)
end)

-- Admin Player Actions
RegisterNetEvent('mtnc:server:adminAction', function(targetSrc, action, reason)
    local src = source
    if not Permissions.HasPermission(src, 'admin.players.' .. action) then
        print("^1[MTNC Security]^7 Uautoriseret admin handling fra " .. tostring(src))
        return
    end

    if action == 'kick' then
        DropPlayer(targetSrc, '[MTNC Admin] ' .. (reason or 'Du er blevet kicket af en administrator.'))
        Audit.Log('PLAYER_KICK', src, targetSrc, { reason = reason })
    elseif action == 'freeze' then
        TriggerClientEvent('mtnc:client:freezePlayer', targetSrc)
        Audit.Log('PLAYER_FREEZE', src, targetSrc, {})
    elseif action == 'teleport' then
        local ped = GetPlayerPed(targetSrc)
        local coords = GetEntityCoords(ped)
        SetEntityCoords(GetPlayerPed(src), coords.x, coords.y, coords.z)
        Audit.Log('PLAYER_TELEPORT', src, targetSrc, {})
    elseif action == 'bring' then
        local ped = GetPlayerPed(src)
        local coords = GetEntityCoords(ped)
        SetEntityCoords(GetPlayerPed(targetSrc), coords.x, coords.y, coords.z)
        Audit.Log('PLAYER_BRING', src, targetSrc, {})
    end
end)
