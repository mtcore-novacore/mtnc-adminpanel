-- ============================================================
-- MTNC PERMISSION & STAFF MANAGEMENT SYSTEM
-- AUTOMATIC ACE & QBCORE GROUP DETECTION + DATABASE REGISTRY
-- ============================================================
Permissions = Permissions or {}

local staffCache = {}

local function GetQBCore()
    if GetResourceState('qb-core') == 'started' then
        return exports['qb-core']:GetCoreObject()
    end
    return nil
end

-- Auto-install tables if missing and clean duplicate demo seeds
CreateThread(function()
    Wait(1500)
    DB.Query([[
        CREATE TABLE IF NOT EXISTS `mtnc_staff_members` (
          `id` INT(11) NOT NULL AUTO_INCREMENT,
          `identifier` VARCHAR(100) NOT NULL,
          `name` VARCHAR(100) NOT NULL DEFAULT 'Staff Medlem',
          `rank` VARCHAR(50) NOT NULL DEFAULT 'moderator',
          `added_by` VARCHAR(100) DEFAULT 'System',
          `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (`id`),
          UNIQUE KEY `uniq_identifier` (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    -- Clean duplicate demo seeds
    DB.Query("DELETE FROM mtnc_staff_members WHERE added_by = 'System Master'")
    
    Permissions.RefreshStaffCache()
end)

function Permissions.RefreshStaffCache()
    local rows = DB.Query('SELECT * FROM mtnc_staff_members') or {}
    staffCache = {}
    for _, r in ipairs(rows) do
        if r.identifier then
            staffCache[string.lower(r.identifier)] = r.rank
        end
    end
end

function Permissions.GetPlayerRole(src)
    if src == 0 then return 'superadmin' end

    -- 1. Automatic FiveM Ace & Group Permissions Detection
    if IsPlayerAceAllowed(src, 'group.god') or IsPlayerAceAllowed(src, 'command') then
        return 'superadmin'
    elseif IsPlayerAceAllowed(src, 'group.admin') or IsPlayerAceAllowed(src, 'admin') then
        return 'superadmin'
    elseif IsPlayerAceAllowed(src, 'group.mod') then
        return 'moderator'
    end

    -- 2. Automatic QBCore Permissions & Groups Detection
    local QBCore = GetQBCore()
    if QBCore then
        if QBCore.Functions.HasPermission(src, 'god') then
            return 'superadmin'
        elseif QBCore.Functions.HasPermission(src, 'admin') then
            return 'superadmin'
        elseif QBCore.Functions.HasPermission(src, 'mod') then
            return 'moderator'
        end

        local p = QBCore.Functions.GetPlayer(src)
        if p and p.PlayerData then
            if p.PlayerData.permissions then
                if p.PlayerData.permissions['god'] or p.PlayerData.permissions['admin'] then
                    return 'superadmin'
                elseif p.PlayerData.permissions['mod'] then
                    return 'moderator'
                end
            end
        end
    end

    -- 3. Database Staff Registry (Manual Staff Assignments)
    for _, idType in ipairs({ 'fivem', 'discord', 'license' }) do
        local idVal = GetPlayerIdentifierByType(src, idType)
        if idVal and staffCache[string.lower(idVal)] then
            return staffCache[string.lower(idVal)]
        end
    end

    return 'user'
end

function Permissions.HasPermission(src, perm)
    if src == 0 then return true end
    local role = Permissions.GetPlayerRole(src)
    if role == 'superadmin' then return true end
    
    local roleConfig = Config.StaffRoles[role]
    if not roleConfig then return false end

    for _, p in ipairs(roleConfig.permissions) do
        if p == perm or p == 'admin.access' and perm == 'admin.access' then
            return true
        end
    end
    return false
end

-- ============================================================
-- 🛡️ STAFF MANAGEMENT NET EVENTS
-- ============================================================
RegisterNetEvent('mtnc:server:getStaffList', function()
    local src = source
    if not Permissions.HasPermission(src, 'admin.access') then return end

    local staff = DB.Query('SELECT * FROM mtnc_staff_members ORDER BY id DESC') or {}
    TriggerClientEvent('mtnc:client:receiveStaffList', src, staff)
end)

RegisterNetEvent('mtnc:server:addStaffMember', function(identifier, name, rank)
    local src = source
    if Permissions.GetPlayerRole(src) ~= 'superadmin' then
        TriggerClientEvent('mtnc:client:notify', src, '❌ Kun Høj Staff (Superadmin) kan tilføje staff!', 'error')
        return
    end

    local adderName = FrameworkAdapter.GetCharacterName(src)
    DB.Query([[
        INSERT INTO mtnc_staff_members (identifier, name, rank, added_by)
        VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE rank = VALUES(rank), name = VALUES(name)
    ]], { identifier, name or 'Staff Medlem', rank or 'moderator', adderName })

    Permissions.RefreshStaffCache()
    TriggerClientEvent('mtnc:client:notify', src, '✅ ' .. name .. ' er tildelt staff rang ' .. rank .. '!', 'success')
    
    local staff = DB.Query('SELECT * FROM mtnc_staff_members ORDER BY id DESC') or {}
    TriggerClientEvent('mtnc:client:receiveStaffList', src, staff)
    Audit.Log('STAFF_ADD', src, 0, { identifier = identifier, name = name, rank = rank })
end)

RegisterNetEvent('mtnc:server:removeStaffMember', function(id)
    local src = source
    if Permissions.GetPlayerRole(src) ~= 'superadmin' then
        TriggerClientEvent('mtnc:client:notify', src, '❌ Kun Høj Staff (Superadmin) kan fjerne staff!', 'error')
        return
    end

    DB.Query('DELETE FROM mtnc_staff_members WHERE id = ?', { id })
    Permissions.RefreshStaffCache()
    TriggerClientEvent('mtnc:client:notify', src, '🗑️ Staff rettighed frataget.', 'info')

    local staff = DB.Query('SELECT * FROM mtnc_staff_members ORDER BY id DESC') or {}
    TriggerClientEvent('mtnc:client:receiveStaffList', src, staff)
    Audit.Log('STAFF_REMOVE', src, 0, { staff_db_id = id })
end)

RegisterNetEvent('mtnc:server:updateStaffRank', function(id, newRank)
    local src = source
    if Permissions.GetPlayerRole(src) ~= 'superadmin' then
        TriggerClientEvent('mtnc:client:notify', src, '❌ Kun Høj Staff (Superadmin) kan ændre rang!', 'error')
        return
    end

    DB.Query('UPDATE mtnc_staff_members SET rank = ? WHERE id = ?', { newRank, id })
    Permissions.RefreshStaffCache()
    TriggerClientEvent('mtnc:client:notify', src, '👔 Staff rang ændret til ' .. newRank, 'success')

    local staff = DB.Query('SELECT * FROM mtnc_staff_members ORDER BY id DESC') or {}
    TriggerClientEvent('mtnc:client:receiveStaffList', src, staff)
    Audit.Log('STAFF_UPDATE_RANK', src, 0, { staff_db_id = id, rank = newRank })
end)
