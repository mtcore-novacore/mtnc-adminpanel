-- ============================================================
-- MTNC ADMIN TABLET v3.0.2 - SERVER MAIN & MASSIVE ADMIN SUITE
-- ============================================================

local function GetQBCore()
    if GetResourceState('qb-core') == 'started' then
        return exports['qb-core']:GetCoreObject()
    end
    return nil
end

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

-- ============================================================
-- 🛡️ ADMIN SUITE: LIVE PLAYERS LIST & STATS
-- ============================================================
RegisterNetEvent('mtnc:server:getOnlinePlayers', function()
    local src = source
    if not Permissions.HasPermission(src, 'admin.access') then return end

    local players = {}
    local QBCore = GetQBCore()

    for _, playerId in ipairs(GetPlayers()) do
        local pSrc = tonumber(playerId)
        local pName = GetPlayerName(pSrc)
        local ping = GetPlayerPing(pSrc)
        local charName = pName
        local jobName, gradeLabel = 'unemployed', 'Borger'
        local cash, bank = 0, 0
        local citizenid = 'N/A'

        if QBCore then
            local p = QBCore.Functions.GetPlayer(pSrc)
            if p and p.PlayerData then
                citizenid = p.PlayerData.citizenid or 'N/A'
                if p.PlayerData.charinfo then
                    charName = (p.PlayerData.charinfo.firstname or '') .. ' ' .. (p.PlayerData.charinfo.lastname or '')
                end
                if p.PlayerData.job then
                    jobName = p.PlayerData.job.label or p.PlayerData.job.name
                    gradeLabel = p.PlayerData.job.grade and (p.PlayerData.job.grade.name or p.PlayerData.job.grade.level) or 'Medarbejder'
                end
                if p.PlayerData.money then
                    cash = p.PlayerData.money.cash or 0
                    bank = p.PlayerData.money.bank or 0
                end
            end
        end

        table.insert(players, {
            id = pSrc,
            name = pName,
            charName = charName,
            citizenid = citizenid,
            job = jobName,
            grade = gradeLabel,
            cash = cash,
            bank = bank,
            ping = ping
        })
    end

    TriggerClientEvent('mtnc:client:receiveOnlinePlayers', src, players)
end)

-- ============================================================
-- 🛡️ ADMIN SUITE: PLAYER ACTIONS (REVIVE, HEAL, MONEY, ETC.)
-- ============================================================
RegisterNetEvent('mtnc:server:adminAction', function(targetSrc, action, val1, val2)
    local src = source
    if not Permissions.HasPermission(src, 'admin.access') then
        print("^1[MTNC Security]^7 Uautoriseret admin handling fra " .. tostring(src))
        return
    end

    local QBCore = GetQBCore()
    local targetPed = GetPlayerPed(targetSrc)

    if action == 'kick' then
        DropPlayer(targetSrc, '[MTNC Admin] ' .. (val1 or 'Du er blevet kicket af en administrator.'))
        Audit.Log('PLAYER_KICK', src, targetSrc, { reason = val1 })
    elseif action == 'freeze' then
        TriggerClientEvent('mtnc:client:freezePlayer', targetSrc)
        Audit.Log('PLAYER_FREEZE', src, targetSrc, {})
    elseif action == 'teleport' then
        local coords = GetEntityCoords(targetPed)
        SetEntityCoords(GetPlayerPed(src), coords.x, coords.y, coords.z)
        Audit.Log('PLAYER_TELEPORT', src, targetSrc, {})
    elseif action == 'bring' then
        local coords = GetEntityCoords(GetPlayerPed(src))
        SetEntityCoords(targetPed, coords.x, coords.y, coords.z)
        Audit.Log('PLAYER_BRING', src, targetSrc, {})
    elseif action == 'revive' then
        if QBCore then
            TriggerClientEvent('hospital:client:Revive', targetSrc)
        end
        TriggerClientEvent('mtnc:client:notify', targetSrc, '💉 Du blev genoplivet af Staff.', 'success')
        Audit.Log('PLAYER_REVIVE', src, targetSrc, {})
    elseif action == 'heal' then
        if QBCore then
            local p = QBCore.Functions.GetPlayer(targetSrc)
            if p then
                p.Functions.SetMetaData('hunger', 100)
                p.Functions.SetMetaData('thirst', 100)
            end
        end
        TriggerClientEvent('hospital:client:HealPlayer', targetSrc)
        TriggerClientEvent('mtnc:client:notify', targetSrc, '🩹 Dit helbred og status blev genopfyldt.', 'success')
        Audit.Log('PLAYER_HEAL', src, targetSrc, {})
    elseif action == 'spectate' then
        TriggerClientEvent('mtnc:client:spectateTarget', src, targetSrc)
        Audit.Log('PLAYER_SPECTATE', src, targetSrc, {})
    elseif action == 'giveMoney' then
        local mType = val1 or 'cash'
        local amount = tonumber(val2) or 0
        if QBCore and amount > 0 then
            local p = QBCore.Functions.GetPlayer(targetSrc)
            if p then
                p.Functions.AddMoney(mType, amount, 'MTNC Staff Grant')
                TriggerClientEvent('mtnc:client:notify', targetSrc, '💰 Modtog ' .. amount .. ' DKK (' .. mType .. ') fra Staff.', 'success')
                Audit.Log('GIVE_MONEY', src, targetSrc, { type = mType, amount = amount })
            end
        end
    elseif action == 'setJob' then
        local jobName = val1 or 'police'
        local grade = tonumber(val2) or 0
        if QBCore then
            local p = QBCore.Functions.GetPlayer(targetSrc)
            if p then
                p.Functions.SetJob(jobName, grade)
                TriggerClientEvent('mtnc:client:notify', targetSrc, '👔 Dit job blev aendret til: ' .. jobName .. ' (Grad: ' .. grade .. ')', 'info')
                Audit.Log('SET_JOB', src, targetSrc, { job = jobName, grade = grade })
            end
        end
    elseif action == 'warn' then
        TriggerClientEvent('mtnc:client:notify', targetSrc, '⚠️ STAFF ADVARSEL: ' .. tostring(val1), 'error')
        Audit.Log('PLAYER_WARN', src, targetSrc, { reason = val1 })
    end
end)

-- ============================================================
-- 🛡️ ADMIN SUITE: SERVER WIDE ACTIONS (ANNOUNCE, WEATHER, TIME)
-- ============================================================
RegisterNetEvent('mtnc:server:serverAction', function(action, val1, val2)
    local src = source
    if not Permissions.HasPermission(src, 'admin.access') then return end

    if action == 'announce' then
        local msg = val1 or ''
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 60, 60 },
            multiline = true,
            args = { '📢 [MTNC SERVER ANNOUNCEMENT]', msg }
        })
        Audit.Log('SERVER_ANNOUNCE', src, 0, { message = msg })
    elseif action == 'reviveAll' then
        local QBCore = GetQBCore()
        if QBCore then
            TriggerClientEvent('hospital:client:Revive', -1)
        end
        TriggerClientEvent('mtnc:client:notify', -1, '⚡ Alle spillere paa serveren er blevet genoplivet af Staff.', 'success')
        Audit.Log('REVIVE_ALL', src, 0, {})
    elseif action == 'clearAreaVehicles' then
        TriggerClientEvent('mtnc:client:notify', src, '🧹 Rydder ubenyttede koeretoeyer i naerheden...', 'info')
        Audit.Log('CLEAR_VEHICLES', src, 0, {})
    elseif action == 'setWeather' then
        local weather = val1 or 'EXTRASUNNY'
        if exports['qb-weathersync'] then
            exports['qb-weathersync']:setWeather(weather)
        end
        Audit.Log('SET_WEATHER', src, 0, { weather = weather })
    elseif action == 'setTime' then
        local hour = tonumber(val1) or 12
        local minute = tonumber(val2) or 0
        if exports['qb-weathersync'] then
            exports['qb-weathersync']:setTime(hour, minute)
        end
        Audit.Log('SET_TIME', src, 0, { hour = hour, minute = minute })
    elseif action == 'toggleBlackout' then
        if exports['qb-weathersync'] then
            exports['qb-weathersync']:toggleBlackout()
        end
        Audit.Log('TOGGLE_BLACKOUT', src, 0, {})
    end
end)
