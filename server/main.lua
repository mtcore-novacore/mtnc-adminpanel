-- ============================================================
-- MTNC ADMIN TABLET v3.0.2 - MASTER PS-ADMIN & QB-ADMIN SUITE
-- ============================================================

CreateThread(function()
    local fType = FrameworkAdapter.GetFrameworkType()
    print('^2[MTNC Admin Panel]^7 Initialiseret succesfuldt (Aktivt Framework: ^3' .. string.upper(fType) .. '^7)!')
end)

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
            isBoss = (primaryJob and primaryJob.isBoss == true) or false,
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
-- 🛡️ LIVE PLAYERS LIST & STATS (PS-ADMINMENU COMPATIBLE)
-- ============================================================
RegisterNetEvent('mtnc:server:getOnlinePlayers', function()
    local src = source
    if not Permissions.HasPermission(src, 'admin.access') then return end

    local players = {}
    local fType = FrameworkAdapter.GetFrameworkType()

    for _, playerId in ipairs(GetPlayers()) do
        local pSrc = tonumber(playerId)
        local pName = GetPlayerName(pSrc)
        local ping = GetPlayerPing(pSrc)
        local charName = FrameworkAdapter.GetCharacterName(pSrc)
        local citizenid = FrameworkAdapter.GetCitizenId(pSrc)
        local primaryJob = FrameworkAdapter.GetPrimaryJob(pSrc)
        local jobName = primaryJob.label or primaryJob.name or 'unemployed'
        local gradeLabel = primaryJob.gradeLabel or 'Borger'
        local gangName, gangGrade = 'none', 'Ingen'
        local cash, bank, crypto = 0, 0, 0

        if fType == 'qbcore' or fType == 'qbox' then
            local p = FrameworkAdapter.GetPlayer(pSrc)
            if p and p.PlayerData then
                if p.PlayerData.gang then
                    gangName = p.PlayerData.gang.label or p.PlayerData.gang.name or 'Ingen'
                    gangGrade = p.PlayerData.gang.grade and (p.PlayerData.gang.grade.name or p.PlayerData.gang.grade.level) or 'Medlem'
                end
                if p.PlayerData.money then
                    cash = p.PlayerData.money.cash or 0
                    bank = p.PlayerData.money.bank or 0
                    crypto = p.PlayerData.money.crypto or 0
                end
            end
        elseif fType == 'esx' then
            local xPlayer = FrameworkAdapter.GetESXPlayer(pSrc)
            if xPlayer then
                cash = xPlayer.getMoney and xPlayer.getMoney() or 0
                local bAcc = xPlayer.getAccount and xPlayer.getAccount('bank')
                bank = bAcc and bAcc.money or 0
            end
        elseif fType == 'vrp' then
            local vRP = exports and exports['vrp'] and exports['vrp']:getInterface("vRP")
            local userId = FrameworkAdapter.GetVRPUserId(pSrc)
            if userId and vRP then
                cash = vRP.getMoney({userId}) or 0
                bank = vRP.getBankMoney({userId}) or 0
            end
        end

        table.insert(players, {
            id = pSrc,
            name = pName,
            charName = charName,
            citizenid = citizenid,
            job = jobName,
            grade = gradeLabel,
            gang = gangName,
            gangGrade = gangGrade,
            cash = cash,
            bank = bank,
            crypto = crypto,
            ping = ping
        })
    end

    TriggerClientEvent('mtnc:client:receiveOnlinePlayers', src, players)
end)

-- Fetch player coords for Blips ESP
RegisterNetEvent('mtnc:server:getPlayersCoords', function()
    local src = source
    if not Permissions.HasPermission(src, 'admin.access') then return end

    local playerList = {}
    for _, playerId in ipairs(GetPlayers()) do
        local pSrc = tonumber(playerId)
        if pSrc and pSrc > 0 then
            local ped = GetPlayerPed(tostring(pSrc))
            if ped and ped ~= 0 and DoesEntityExist(ped) then
                local coords = GetEntityCoords(ped)
                if coords then
                    table.insert(playerList, {
                        id = pSrc,
                        name = GetPlayerName(pSrc) or ('Spiller #' .. pSrc),
                        coords = coords
                    })
                end
            end
        end
    end
    TriggerClientEvent('mtnc:client:receivePlayersCoords', src, playerList)
end)

-- ============================================================
-- 🛡️ PLAYER ACTIONS (PS-ADMINMENU & QB-ADMINMENU SUITE)
-- ============================================================
RegisterNetEvent('mtnc:server:adminAction', function(targetSrc, action, val1, val2)
    local src = source
    targetSrc = (targetSrc and tonumber(targetSrc) and tonumber(targetSrc) > 0) and tonumber(targetSrc) or src
    if not Permissions.HasPermission(src, 'admin.access') then
        print("^1[MTNC Security]^7 Uautoriseret admin handling fra " .. tostring(src))
        return
    end

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
    elseif action == 'intovehicle' then
        local adminPed = GetPlayerPed(src)
        local veh = GetVehiclePedIsIn(targetPed, false)
        if veh ~= 0 then
            local seat = -1
            for i = 0, 8 do
                if GetPedInVehicleSeat(veh, i) == 0 then
                    seat = i
                    break
                end
            end
            if seat ~= -1 then
                SetPedIntoVehicle(adminPed, veh, seat)
                TriggerClientEvent('mtnc:client:notify', src, '🚗 Sat ind i spillerens koeretoey!', 'success')
            else
                TriggerClientEvent('mtnc:client:notify', src, '❌ Ingen ledige saeder i koeretoejet.', 'error')
            end
        else
            TriggerClientEvent('mtnc:client:notify', src, '❌ Spilleren sidder ikke i et koeretoey.', 'error')
        end
        Audit.Log('PLAYER_INTO_VEHICLE', src, targetSrc, {})
    elseif action == 'revive' then
        FrameworkAdapter.RevivePlayer(targetSrc)
        TriggerClientEvent('mtnc:client:notify', targetSrc, '💉 Du blev genoplivet af Staff.', 'success')
        Audit.Log('PLAYER_REVIVE', src, targetSrc, {})
    elseif action == 'kill' then
        FrameworkAdapter.KillPlayer(targetSrc)
        TriggerClientEvent('mtnc:client:notify', targetSrc, '💀 Du blev draebt af Staff.', 'error')
        Audit.Log('PLAYER_KILL', src, targetSrc, {})
    elseif action == 'heal' then
        FrameworkAdapter.HealPlayer(targetSrc)
        TriggerClientEvent('mtnc:client:notify', targetSrc, '🩹 Dit helbred og status blev genopfyldt.', 'success')
        Audit.Log('PLAYER_HEAL', src, targetSrc, {})
    elseif action == 'openInventory' then
        if GetResourceState('qb-inventory') == 'started' then
            exports['qb-inventory']:OpenInventoryById(src, targetSrc)
        elseif GetResourceState('ps-inventory') == 'started' then
            exports['ps-inventory']:OpenInventoryById(src, targetSrc)
        elseif GetResourceState('ox_inventory') == 'started' then
            exports.ox_inventory:openInventory(src, 'player', targetSrc)
        else
            TriggerClientEvent('mtnc:client:notify', src, '❌ Inventory ressource ikke aktiv på serveren.', 'error')
        end
        Audit.Log('PLAYER_OPEN_INVENTORY', src, targetSrc, {})
    elseif action == 'clearInventory' then
        FrameworkAdapter.ClearInventory(targetSrc)
        TriggerClientEvent('mtnc:client:notify', targetSrc, '🧹 Dit inventory blev toemt af Staff.', 'info')
        TriggerClientEvent('mtnc:client:notify', src, '🧹 Spillerens inventory blev toemt.', 'success')
        Audit.Log('PLAYER_CLEAR_INVENTORY', src, targetSrc, {})
    elseif action == 'openClothing' then
        if GetResourceState('qb-clothing') == 'started' then
            TriggerClientEvent('qb-clothing:client:openMenu', targetSrc)
        elseif GetResourceState('illenium-appearance') == 'started' then
            TriggerClientEvent('illenium-appearance:client:openClothingShopMenu', targetSrc)
        elseif GetResourceState('fivem-appearance') == 'started' then
            TriggerClientEvent('fivem-appearance:client:openClothingShopMenu', targetSrc)
        elseif GetResourceState('esx_skin') == 'started' then
            TriggerClientEvent('esx_skin:openSaveableMenu', targetSrc)
        end
        TriggerClientEvent('mtnc:client:notify', src, '👕 Aabnede toejmenu for spilleren.', 'success')
        Audit.Log('PLAYER_OPEN_CLOTHING', src, targetSrc, {})
    elseif action == 'spectate' then
        TriggerClientEvent('mtnc:client:spectateTarget', src, targetSrc)
        Audit.Log('PLAYER_SPECTATE', src, targetSrc, {})
    elseif action == 'giveMoney' then
        local amount = tonumber(val1) or tonumber(val2) or 0
        local mType = 'cash'
        if type(val1) == 'string' and tonumber(val1) == nil then
            mType = val1
            amount = tonumber(val2) or 0
        end
        if amount > 0 then
            FrameworkAdapter.AddMoney(targetSrc, mType, amount, 'MTNC Staff Grant')
            TriggerClientEvent('mtnc:client:notify', targetSrc, '💰 Modtog ' .. amount .. ' DKK fra Staff.', 'success')
            TriggerClientEvent('mtnc:client:notify', src, '💰 Gav ' .. amount .. ' DKK til spilleren.', 'success')
            Audit.Log('GIVE_MONEY', src, targetSrc, { type = mType, amount = amount })
        end
    elseif action == 'giveItem' then
        local item = val1 or 'water_bottle'
        local amount = tonumber(val2) or 1
        if item then
            FrameworkAdapter.AddItem(targetSrc, item, amount)
            TriggerClientEvent('mtnc:client:notify', targetSrc, '🎁 Modtog ' .. amount .. 'x ' .. item .. ' fra Staff.', 'success')
            TriggerClientEvent('mtnc:client:notify', src, '🎁 Gav ' .. amount .. 'x ' .. item .. ' til spilleren.', 'success')
            Audit.Log('GIVE_ITEM', src, targetSrc, { item = item, amount = amount })
        end
    elseif action == 'setJob' then
        local jobName = val1 or 'police'
        local grade = tonumber(val2) or 0
        FrameworkAdapter.SetJob(targetSrc, jobName, grade)
        TriggerClientEvent('mtnc:client:notify', targetSrc, '👔 Dit job blev aendret til: ' .. jobName .. ' (Grad: ' .. grade .. ')', 'info')
        TriggerClientEvent('mtnc:client:notify', src, '👔 Sattes job til: ' .. jobName .. ' (Grad: ' .. grade .. ')', 'success')
        Audit.Log('SET_JOB', src, targetSrc, { job = jobName, grade = grade })
    elseif action == 'setGang' then
        local gangName = val1 or 'ballas'
        local grade = tonumber(val2) or 0
        FrameworkAdapter.SetGang(targetSrc, gangName, grade)
        TriggerClientEvent('mtnc:client:notify', targetSrc, '🔫 Din bande blev aendret til: ' .. gangName .. ' (Grad: ' .. grade .. ')', 'info')
        TriggerClientEvent('mtnc:client:notify', src, '🔫 Sattes bande til: ' .. gangName .. ' (Grad: ' .. grade .. ')', 'success')
        Audit.Log('SET_GANG', src, targetSrc, { gang = gangName, grade = grade })
    -- PS-ADMINMENU TROLL TOOLS
    elseif action == 'setFire' then
        TriggerClientEvent('mtnc:client:setTargetFire', targetSrc)
        TriggerClientEvent('mtnc:client:notify', src, '🔥 Satte ild til spilleren!', 'info')
        Audit.Log('PLAYER_FIRE', src, targetSrc, {})
    elseif action == 'explode' then
        TriggerClientEvent('mtnc:client:explodeTarget', targetSrc)
        TriggerClientEvent('mtnc:client:notify', src, '💥 Sprang spilleren i luften!', 'info')
        Audit.Log('PLAYER_EXPLODE', src, targetSrc, {})
    elseif action == 'cuff' then
        TriggerClientEvent('mtnc:client:cuffTarget', targetSrc)
        TriggerClientEvent('mtnc:client:notify', src, '🔗 Togglede haandjern paa spiller!', 'info')
        Audit.Log('PLAYER_CUFF', src, targetSrc, {})
    elseif action == 'drunk' then
        TriggerClientEvent('mtnc:client:drunkTarget', targetSrc)
        TriggerClientEvent('mtnc:client:notify', src, '🥴 Satte fuld gangart paa spiller!', 'info')
        Audit.Log('PLAYER_DRUNK', src, targetSrc, {})
    elseif action == 'flashbang' then
        TriggerClientEvent('mtnc:client:flashbangTarget', targetSrc)
        TriggerClientEvent('mtnc:client:notify', src, '⚡ Flashbangede spilleren!', 'info')
        Audit.Log('PLAYER_FLASHBANG', src, targetSrc, {})
    elseif action == 'slap' then
        TriggerClientEvent('mtnc:client:slapPlayer', targetSrc)
        Audit.Log('PLAYER_SLAP', src, targetSrc, {})
    elseif action == 'ragdoll' then
        TriggerClientEvent('mtnc:client:ragdollPlayer', targetSrc)
        Audit.Log('PLAYER_RAGDOLL', src, targetSrc, {})
    elseif action == 'giveArmor' then
        TriggerClientEvent('mtnc:client:giveArmorLocal', targetSrc)
        Audit.Log('PLAYER_ARMOR', src, targetSrc, {})
    elseif action == 'clearWeapons' then
        TriggerClientEvent('mtnc:client:clearWeaponsLocal', targetSrc)
        Audit.Log('PLAYER_CLEAR_WEAPONS', src, targetSrc, {})
    elseif action == 'giveWeapon' then
        local weaponName = tostring(val1 or 'weapon_combatpistol'):lower()
        local ammoCount = tonumber(val2) or 250
        FrameworkAdapter.GiveWeapon(targetSrc, weaponName, ammoCount)
        TriggerClientEvent('mtnc:client:notify', targetSrc, '🔫 Modtog ' .. string.upper(weaponName) .. ' med ' .. ammoCount .. ' skud fra Staff.', 'success')
        TriggerClientEvent('mtnc:client:notify', src, '🔫 Gav ' .. string.upper(weaponName) .. ' (' .. ammoCount .. ' skud) til ID: ' .. targetSrc, 'success')
        Audit.Log('PLAYER_GIVE_WEAPON', src, targetSrc, { weapon = weaponName, ammo = ammoCount })
    elseif action == 'setBucket' then
        local bucket = tonumber(val1) or 0
        SetPlayerRoutingBucket(targetSrc, bucket)
        TriggerClientEvent('mtnc:client:notify', targetSrc, '🌐 Flyttet til virtuel dimension: ' .. bucket, 'info')
        Audit.Log('PLAYER_BUCKET', src, targetSrc, { bucket = bucket })
    elseif action == 'warn' then
        local reason = val1 or 'Advarsel fra server administration.'
        TriggerClientEvent('mtnc:client:notify', targetSrc, '⚠️ STAFF ADVARSEL: ' .. reason, 'error')
        Audit.Log('PLAYER_WARN', src, targetSrc, { reason = reason })
    elseif action == 'ban' then
        local reason = val1 or 'Permanent udelukket af administrator.'
        local license = GetPlayerIdentifierByType(targetSrc, 'license') or 'N/A'
        local discord = GetPlayerIdentifierByType(targetSrc, 'discord') or 'N/A'
        local pName = GetPlayerName(targetSrc)
        local banner = FrameworkAdapter.GetCharacterName(src)

        DB.Query([[
            INSERT INTO mtnc_bans (license, discord, name, reason, banned_by, permanent)
            VALUES (?, ?, ?, ?, ?, 1)
        ]], { license, discord, pName, reason, banner })

        DropPlayer(targetSrc, '[MTNC BAN] ' .. reason)
        Audit.Log('PLAYER_BAN', src, targetSrc, { reason = reason })
    end
end)

-- ============================================================
-- 🔨 BAN MANAGEMENT (PS-ADMINMENU FEATURE)
-- ============================================================
RegisterNetEvent('mtnc:server:getBansList', function()
    local src = source
    if not Permissions.HasPermission(src, 'admin.access') then return end

    DB.Query("SELECT * FROM mtnc_bans ORDER BY id DESC LIMIT 50", {}, function(bans)
        TriggerClientEvent('mtnc:client:receiveBansList', src, bans or {})
    end)
end)

RegisterNetEvent('mtnc:server:unbanPlayer', function(banId)
    local src = source
    if not Permissions.HasPermission(src, 'admin.access') then return end

    DB.Query("DELETE FROM mtnc_bans WHERE id = ?", { banId }, function()
        TriggerClientEvent('mtnc:client:notify', src, '✅ Ban #' .. tostring(banId) .. ' ophævet!', 'success')
        TriggerEvent('mtnc:server:getBansList')
    end)
    Audit.Log('UNBAN_PLAYER', src, 0, { banId = banId })
end)

-- ============================================================
-- 🚗 ADMIN CAR: SAVE CAR TO PLAYER GARAGE (PS-ADMINMENU FEATURE)
-- ============================================================
RegisterNetEvent('mtnc:server:saveCarToGarage', function(mods, modelName, hash, plate)
    local src = source
    if not Permissions.HasPermission(src, 'admin.access') then return end

    FrameworkAdapter.SaveCarToGarage(src, mods, modelName, hash, plate)
    Audit.Log('SAVE_ADMIN_CAR', src, 0, { plate = plate, model = modelName })
end)

-- ============================================================
-- 🛡️ SERVER WIDE ACTIONS (ANNOUNCE, WEATHER, TIME, CLEAR)
-- ============================================================
RegisterNetEvent('mtnc:server:serverAction', function(action, val1, val2)
    local src = source
    if not Permissions.HasPermission(src, 'admin.access') then return end

    if action == 'announce' then
        local msg = val1 or ''
        local sender = FrameworkAdapter.GetCharacterName(src) or 'Server Administration'
        TriggerClientEvent('mtnc:client:broadcastAnnouncement', -1, msg, sender)
        Audit.Log('SERVER_ANNOUNCE', src, 0, { message = msg, author = sender })
    elseif action == 'reviveAll' then
        for _, playerId in ipairs(GetPlayers()) do
            local pSrc = tonumber(playerId)
            if pSrc and pSrc > 0 then
                FrameworkAdapter.RevivePlayer(pSrc)
            end
        end
        TriggerClientEvent('mtnc:client:notify', -1, '⚡ Alle spillere paa serveren er blevet genoplivet af Staff.', 'success')
        Audit.Log('REVIVE_ALL', src, 0, {})
    elseif action == 'clearAreaVehicles' then
        TriggerClientEvent('mtnc:client:clearAreaEntity', src, 'vehicles', tonumber(val1) or 100.0)
        Audit.Log('CLEAR_VEHICLES', src, 0, {})
    elseif action == 'clearAreaPeds' then
        TriggerClientEvent('mtnc:client:clearAreaEntity', src, 'peds', tonumber(val1) or 100.0)
        Audit.Log('CLEAR_PEDS', src, 0, {})
    elseif action == 'clearAreaObjects' then
        TriggerClientEvent('mtnc:client:clearAreaEntity', src, 'objects', tonumber(val1) or 100.0)
        Audit.Log('CLEAR_OBJECTS', src, 0, {})
    elseif action == 'setWeather' then
        local weather = tostring(val1 or 'EXTRASUNNY'):upper()
        if GetResourceState('qb-weathersync') == 'started' then
            pcall(function()
                exports['qb-weathersync']:setWeather(weather)
            end)
            TriggerEvent('qb-weathersync:server:setWeather', weather)
        end
        TriggerClientEvent('qb-weathersync:client:SyncWeather', -1, weather, false)
        TriggerClientEvent('mtnc:client:notify', src, '☀️ Vejret er skiftet til: ' .. weather, 'success')
        Audit.Log('SET_WEATHER', src, 0, { weather = weather })
    elseif action == 'setTime' then
        local hour = tonumber(val1) or 12
        local minute = tonumber(val2) or 0
        if GetResourceState('qb-weathersync') == 'started' then
            pcall(function()
                exports['qb-weathersync']:setTime(hour, minute)
            end)
            TriggerEvent('qb-weathersync:server:setTime', hour, minute)
        end
        TriggerClientEvent('mtnc:client:notify', src, string.format('🕒 Tiden er sat til: %02d:%02d', hour, minute), 'success')
        Audit.Log('SET_TIME', src, 0, { hour = hour, minute = minute })
    elseif action == 'toggleBlackout' then
        local isBlackout = false
        if GetResourceState('qb-weathersync') == 'started' then
            pcall(function()
                isBlackout = exports['qb-weathersync']:setBlackout()
            end)
        end
        TriggerClientEvent('mtnc:client:notify', src, '💡 Blackout: ' .. (isBlackout and 'Aktiveret (Mørklægning)' or 'Deaktiveret'), 'info')
        Audit.Log('TOGGLE_BLACKOUT', src, 0, { blackout = isBlackout })
    elseif action == 'freezeTime' then
        local isFrozen = false
        if GetResourceState('qb-weathersync') == 'started' then
            pcall(function()
                isFrozen = exports['qb-weathersync']:setTimeFreeze()
            end)
        end
        TriggerClientEvent('mtnc:client:notify', src, '⏱️ Tidsfrys: ' .. (isFrozen and 'Frosset' or 'Normal hastighed'), 'info')
        Audit.Log('FREEZE_TIME', src, 0, { frozen = isFrozen })
    end
end)
