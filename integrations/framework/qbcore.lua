-- ============================================================
-- MTNC ADAPTER - QBCORE & MASTER FRAMEWORK DISPATCHER
-- ============================================================
FrameworkAdapter = FrameworkAdapter or {}

local function GetQBCore()
    if GetResourceState('qb-core') == 'started' then
        return exports['qb-core']:GetCoreObject()
    end
    return nil
end

local QBCore = GetQBCore()

function FrameworkAdapter.GetFrameworkType()
    if Config and Config.Integrations and Config.Integrations.Framework and Config.Integrations.Framework ~= 'auto' then
        return Config.Integrations.Framework
    end
    if GetResourceState('qb-core') == 'started' then return 'qbcore' end
    if GetResourceState('qbx_core') == 'started' then return 'qbox' end
    if GetResourceState('es_extended') == 'started' then return 'esx' end
    if GetResourceState('vrp') == 'started' then return 'vrp' end
    return 'standalone'
end

function FrameworkAdapter.IsQBCore()
    QBCore = QBCore or GetQBCore()
    return QBCore ~= nil
end

function FrameworkAdapter.GetPlayer(src)
    local fType = FrameworkAdapter.GetFrameworkType()
    if fType == 'qbcore' or fType == 'qbox' then
        QBCore = QBCore or GetQBCore()
        if not QBCore then return nil end
        return QBCore.Functions.GetPlayer(src)
    elseif fType == 'esx' then
        return FrameworkAdapter.GetESXPlayer(src)
    end
    return nil
end

function FrameworkAdapter.GetCitizenId(src)
    local fType = FrameworkAdapter.GetFrameworkType()
    if fType == 'qbcore' or fType == 'qbox' then
        local p = FrameworkAdapter.GetPlayer(src)
        return (p and p.PlayerData and p.PlayerData.citizenid) or 'N/A'
    elseif fType == 'esx' then
        local p = FrameworkAdapter.GetESXPlayer(src)
        return (p and p.identifier) or 'N/A'
    elseif fType == 'vrp' then
        local uid = FrameworkAdapter.GetVRPUserId(src)
        return uid and tostring(uid) or 'N/A'
    end
    return tostring(src)
end

function FrameworkAdapter.GetCharacterName(src)
    local fType = FrameworkAdapter.GetFrameworkType()
    if fType == 'qbcore' or fType == 'qbox' then
        QBCore = QBCore or GetQBCore()
        if not QBCore then return GetPlayerName(src) end
        local p = QBCore.Functions.GetPlayer(src)
        if not p or not p.PlayerData or not p.PlayerData.charinfo then return GetPlayerName(src) end
        return (p.PlayerData.charinfo.firstname or '') .. ' ' .. (p.PlayerData.charinfo.lastname or '')
    elseif fType == 'esx' then
        return FrameworkAdapter.GetESXCharacterName(src)
    elseif fType == 'vrp' then
        return FrameworkAdapter.GetVRPCharacterName(src)
    end
    return GetPlayerName(src)
end

function FrameworkAdapter.GetJobSalary(jobName, gradeLevel)
    local fType = FrameworkAdapter.GetFrameworkType()
    if fType == 'qbcore' or fType == 'qbox' then
        QBCore = QBCore or GetQBCore()
        if not QBCore or not QBCore.Shared or not QBCore.Shared.Jobs then return 0 end
        local jobData = QBCore.Shared.Jobs[jobName]
        if not jobData or not jobData.grades then return 0 end

        local gKeyStr = tostring(gradeLevel or 0)
        local gKeyNum = tonumber(gradeLevel or 0)

        local gradeData = jobData.grades[gKeyStr] or (gKeyNum and jobData.grades[gKeyNum]) or jobData.grades[0] or jobData.grades['0']
        if gradeData and gradeData.payment then
            return tonumber(gradeData.payment) or 0
        end
    end
    return 0
end

function FrameworkAdapter.GetPrimaryJob(src)
    local fType = FrameworkAdapter.GetFrameworkType()
    if fType == 'esx' then
        return FrameworkAdapter.GetESXPrimaryJob(src)
    elseif fType == 'vrp' then
        return FrameworkAdapter.GetVRPPrimaryJob(src)
    end

    -- Default: QBCore / Qbox
    QBCore = QBCore or GetQBCore()
    if not QBCore then return { name = 'unemployed', label = 'Arbejdsloes', grade = 0, gradeLabel = 'Borger', duty = false, salary = 0, isBoss = false } end
    local p = QBCore.Functions.GetPlayer(src)
    if not p or not p.PlayerData or not p.PlayerData.job then
        return { name = 'unemployed', label = 'Arbejdsloes', grade = 0, gradeLabel = 'Borger', duty = false, salary = 0, isBoss = false }
    end
    local j = p.PlayerData.job
    local jobName = j.name or 'unemployed'
    local gradeLevel = j.grade and (j.grade.level or j.grade) or 0
    
    local salary = tonumber(j.payment) or 0
    if salary == 0 then
        salary = FrameworkAdapter.GetJobSalary(jobName, gradeLevel)
    end

    local isBoss = (j.isboss == true)
    if not isBoss and j.grade then
        if type(j.grade) == 'table' and j.grade.isboss then
            isBoss = true
        elseif type(j.grade) == 'table' and j.grade.name and (string.lower(j.grade.name) == 'boss' or string.lower(j.grade.name) == 'ledelse' or string.lower(j.grade.name) == 'direktør' or string.lower(j.grade.name) == 'chef') then
            isBoss = true
        end
    end

    return {
        name = jobName,
        label = j.label or jobName,
        grade = gradeLevel,
        gradeLabel = j.grade and (j.grade.name or j.gradeLabel) or 'Borger',
        duty = j.onduty or false,
        salary = salary,
        isBoss = isBoss
    }
end

function FrameworkAdapter.GetJobs(src)
    local primary = FrameworkAdapter.GetPrimaryJob(src)
    local list = { primary }

    local fType = FrameworkAdapter.GetFrameworkType()
    if fType == 'qbcore' or fType == 'qbox' then
        QBCore = QBCore or GetQBCore()
        if not QBCore then return list end
        local p = QBCore.Functions.GetPlayer(src)
        if not p or not p.PlayerData then return list end

        if p.PlayerData.metadata and p.PlayerData.metadata['multijob'] and type(p.PlayerData.metadata['multijob']) == 'table' then
            for jobName, jobData in pairs(p.PlayerData.metadata['multijob']) do
                if jobName ~= primary.name then
                    local gradeLvl = jobData.grade or (jobData.grade and jobData.grade.level) or 0
                    local salary = tonumber(jobData.salary or jobData.payment) or 0
                    if salary == 0 then
                        salary = FrameworkAdapter.GetJobSalary(jobName, gradeLvl)
                    end

                    table.insert(list, {
                        name = jobName,
                        label = jobData.label or jobName,
                        grade = gradeLvl,
                        gradeLabel = jobData.gradeLabel or (jobData.grade and jobData.grade.name) or 'Medarbejder',
                        duty = false,
                        salary = salary
                    })
                end
            end
        end
    end

    return list
end

function FrameworkAdapter.SetDuty(src, state)
    local fType = FrameworkAdapter.GetFrameworkType()
    if fType == 'qbcore' or fType == 'qbox' then
        QBCore = QBCore or GetQBCore()
        if not QBCore then return false end
        local p = QBCore.Functions.GetPlayer(src)
        if not p then return false end
        p.Functions.SetJobDuty(state)
        return true
    end
    return true
end

function FrameworkAdapter.SetJob(src, jobName, grade)
    local fType = FrameworkAdapter.GetFrameworkType()
    grade = tonumber(grade) or 0

    if fType == 'esx' then
        return FrameworkAdapter.SetESXJob(src, jobName, grade)
    elseif fType == 'vrp' then
        return FrameworkAdapter.SetVRPJob(src, jobName, grade)
    else
        QBCore = QBCore or GetQBCore()
        if not QBCore then return false end
        local p = QBCore.Functions.GetPlayer(src)
        if not p then return false end
        p.Functions.SetJob(jobName, grade)
        return true
    end
end

function FrameworkAdapter.SetGang(src, gangName, grade)
    local fType = FrameworkAdapter.GetFrameworkType()
    grade = tonumber(grade) or 0

    if fType == 'qbcore' or fType == 'qbox' then
        QBCore = QBCore or GetQBCore()
        if not QBCore then return false end
        local p = QBCore.Functions.GetPlayer(src)
        if not p then return false end
        p.Functions.SetGang(gangName, grade)
        return true
    end
    return false
end

function FrameworkAdapter.AddMoney(src, accountType, amount, reason)
    local fType = FrameworkAdapter.GetFrameworkType()
    amount = tonumber(amount) or 0
    if amount <= 0 then return false end

    if fType == 'esx' then
        return FrameworkAdapter.AddESXMoney(src, accountType, amount, reason)
    elseif fType == 'vrp' then
        return FrameworkAdapter.AddVRPMoney(src, accountType, amount, reason)
    else
        QBCore = QBCore or GetQBCore()
        if not QBCore then return false end
        local p = QBCore.Functions.GetPlayer(src)
        if not p then return false end
        p.Functions.AddMoney(accountType or 'cash', amount, reason or 'MTNC Admin')
        return true
    end
end

function FrameworkAdapter.RemoveMoney(src, accountType, amount, reason)
    local fType = FrameworkAdapter.GetFrameworkType()
    amount = tonumber(amount) or 0
    if amount <= 0 then return false end

    if fType == 'esx' then
        return FrameworkAdapter.RemoveESXMoney(src, accountType, amount, reason)
    elseif fType == 'vrp' then
        return FrameworkAdapter.RemoveVRPMoney(src, accountType, amount, reason)
    else
        QBCore = QBCore or GetQBCore()
        if not QBCore then return false end
        local p = QBCore.Functions.GetPlayer(src)
        if not p then return false end
        return p.Functions.RemoveMoney(accountType or 'cash', amount, reason or 'MTNC Admin')
    end
end

function FrameworkAdapter.AddItem(src, item, amount)
    local fType = FrameworkAdapter.GetFrameworkType()
    amount = tonumber(amount) or 1

    if fType == 'esx' then
        return FrameworkAdapter.AddESXItem(src, item, amount)
    elseif fType == 'vrp' then
        local vRP = exports and exports['vrp'] and exports['vrp']:getInterface("vRP")
        local userId = FrameworkAdapter.GetVRPUserId(src)
        if userId and vRP then
            vRP.giveInventoryItem({userId, item, amount, true})
            return true
        end
    else
        QBCore = QBCore or GetQBCore()
        if not QBCore then return false end
        local p = QBCore.Functions.GetPlayer(src)
        if not p then return false end
        p.Functions.AddItem(item, amount)
        if QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items[item] then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add')
        end
        return true
    end
    return false
end

function FrameworkAdapter.ClearInventory(src)
    local fType = FrameworkAdapter.GetFrameworkType()
    if fType == 'esx' then
        return FrameworkAdapter.ClearESXInventory(src)
    elseif fType == 'vrp' then
        local vRP = exports and exports['vrp'] and exports['vrp']:getInterface("vRP")
        local userId = FrameworkAdapter.GetVRPUserId(src)
        if userId and vRP then
            vRP.clearInventory({userId})
            return true
        end
    else
        QBCore = QBCore or GetQBCore()
        if not QBCore then return false end
        local p = QBCore.Functions.GetPlayer(src)
        if not p then return false end
        p.Functions.ClearInventory()
        return true
    end
    return false
end

function FrameworkAdapter.RevivePlayer(src)
    local fType = FrameworkAdapter.GetFrameworkType()
    if fType == 'esx' then
        TriggerClientEvent('esx_ambulancejob:revive', src)
    elseif fType == 'vrp' then
        TriggerClientEvent('vRP:revive', src)
    else
        TriggerClientEvent('hospital:client:Revive', src)
    end
    return true
end

function FrameworkAdapter.HealPlayer(src)
    local fType = FrameworkAdapter.GetFrameworkType()
    if fType == 'qbcore' or fType == 'qbox' then
        QBCore = QBCore or GetQBCore()
        if QBCore then
            local p = QBCore.Functions.GetPlayer(src)
            if p then
                p.Functions.SetMetaData('hunger', 100)
                p.Functions.SetMetaData('thirst', 100)
            end
        end
        TriggerClientEvent('hospital:client:HealPlayer', src)
    elseif fType == 'esx' then
        TriggerClientEvent('esx_status:healPlayer', src)
    elseif fType == 'vrp' then
        local vRP = exports and exports['vrp'] and exports['vrp']:getInterface("vRP")
        local userId = FrameworkAdapter.GetVRPUserId(src)
        if userId and vRP then
            vRP.varyThirst({userId, -100})
            vRP.varyHunger({userId, -100})
        end
    end
    return true
end

function FrameworkAdapter.KillPlayer(src)
    local fType = FrameworkAdapter.GetFrameworkType()
    if fType == 'qbcore' or fType == 'qbox' then
        TriggerClientEvent('hospital:client:KillPlayer', src)
    else
        local ped = GetPlayerPed(src)
        if ped and ped ~= 0 then
            SetEntityHealth(ped, 0)
        end
    end
    return true
end

function FrameworkAdapter.GiveWeapon(src, weaponName, ammoCount)
    local fType = FrameworkAdapter.GetFrameworkType()
    weaponName = tostring(weaponName or 'weapon_combatpistol'):lower()
    ammoCount = tonumber(ammoCount) or 250

    if fType == 'esx' then
        local xPlayer = FrameworkAdapter.GetESXPlayer(src)
        if xPlayer and xPlayer.addWeapon then
            xPlayer.addWeapon(weaponName, ammoCount)
        end
    elseif fType == 'vrp' then
        local vRP = exports and exports['vrp'] and exports['vrp']:getInterface("vRP")
        local userId = FrameworkAdapter.GetVRPUserId(src)
        if userId and vRP then
            vRP.giveWeapons({userId, { [weaponName] = { ammo = ammoCount } }})
        end
    else
        QBCore = QBCore or GetQBCore()
        if QBCore then
            local p = QBCore.Functions.GetPlayer(src)
            if p then
                local serie = tostring((QBCore.Shared and QBCore.Shared.RandomInt and QBCore.Shared.RandomInt(2)) or 11) .. tostring((QBCore.Shared and QBCore.Shared.RandomStr and QBCore.Shared.RandomStr(3)) or 'ABC')
                local info = {
                    serie = serie,
                    ammo = ammoCount,
                    quality = 100
                }
                p.Functions.AddItem(weaponName, 1, false, info)
                if QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items[weaponName] then
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[weaponName], 'add')
                end
            end
        end
    end
    TriggerClientEvent('mtnc:client:giveWeaponLocal', src, weaponName, ammoCount)
    return true
end

function FrameworkAdapter.SaveCarToGarage(src, mods, modelName, hash, plate)
    local fType = FrameworkAdapter.GetFrameworkType()
    local cleanPlate = string.upper(plate or 'ADMIN')

    if fType == 'esx' then
        local xPlayer = FrameworkAdapter.GetESXPlayer(src)
        if xPlayer and xPlayer.identifier then
            local res = DB.Query("SELECT plate FROM owned_vehicles WHERE plate = ?", { cleanPlate }) or {}
            if not res or #res == 0 then
                DB.Query([[
                    INSERT INTO owned_vehicles (owner, plate, vehicle, stored)
                    VALUES (?, ?, ?, 1)
                ]], { xPlayer.identifier, cleanPlate, json.encode({ model = modelName, plate = cleanPlate, mods = mods or {} }) })
                TriggerClientEvent('mtnc:client:notify', src, '🚗 Køretøj med plade ' .. cleanPlate .. ' er gemt i din garage!', 'success')
            else
                TriggerClientEvent('mtnc:client:notify', src, '⚠️ Nummerplade ' .. cleanPlate .. ' eksisterer allerede.', 'error')
            end
        end
    elseif fType == 'vrp' then
        local userId = FrameworkAdapter.GetVRPUserId(src)
        if userId then
            DB.Query("INSERT INTO vrp_user_vehicles (user_id, veh_type, vehicle_plate) VALUES (?, ?, ?)", { userId, modelName, cleanPlate })
            TriggerClientEvent('mtnc:client:notify', src, '🚗 Køretøj med plade ' .. cleanPlate .. ' er gemt i din vRP garage!', 'success')
        end
    else
        QBCore = QBCore or GetQBCore()
        if QBCore then
            local Player = QBCore.Functions.GetPlayer(src)
            if Player then
                local res = DB.Query("SELECT plate FROM player_vehicles WHERE plate = ?", { cleanPlate }) or {}
                if not res or #res == 0 then
                    DB.Query([[
                        INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state)
                        VALUES (?, ?, ?, ?, ?, ?, 0)
                    ]], {
                        Player.PlayerData.license,
                        Player.PlayerData.citizenid,
                        modelName,
                        hash,
                        json.encode(mods or {}),
                        cleanPlate
                    })
                    TriggerClientEvent('mtnc:client:notify', src, '🚗 Køretøj med plade ' .. cleanPlate .. ' er gemt i din garage!', 'success')
                else
                    TriggerClientEvent('mtnc:client:notify', src, '⚠️ Nummerplade ' .. cleanPlate .. ' eksisterer allerede i databasen.', 'error')
                end
            end
        end
    end
    return true
end
