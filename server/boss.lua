-- ============================================================
-- MTNC UNIVERSAL BOSS & SOCIETY BANKING SYSTEM v3.0.2
-- Supports: qb-banking, Renewed-Banking, okokBanking, qb-management,
--           fd_banking, pefcl, esx_addonaccount & Direct SQL Fallbacks
-- ============================================================
Boss = Boss or {}

local function GetQBCore()
    if GetResourceState('qb-core') == 'started' then
        return exports['qb-core']:GetCoreObject()
    end
    return nil
end

function Boss.IsPlayerBoss(src)
    local QBCore = GetQBCore()
    if not QBCore then return false end
    local p = QBCore.Functions.GetPlayer(src)
    if not p or not p.PlayerData or not p.PlayerData.job then return false end
    
    local j = p.PlayerData.job
    return j.isboss == true or (j.grade and j.grade.name and (string.lower(j.grade.name) == 'boss' or string.lower(j.grade.name) == 'ledelse' or string.lower(j.grade.name) == 'direktør' or string.lower(j.grade.name) == 'chef'))
end

-- ============================================================
-- 🏦 UNIVERSAL BANKING / SOCIETY BALANCE RESOLVER
-- ============================================================
function Boss.GetSocietyBalance(jobName)
    local balance = 0
    local handled = false

    -- 1. Renewed-Banking
    if GetResourceState('Renewed-Banking') == 'started' then
        pcall(function()
            local b = exports['Renewed-Banking']:getAccountMoney(jobName)
            if b then balance = tonumber(b) or 0; handled = true end
        end)
    end

    -- 2. qb-banking
    if not handled and GetResourceState('qb-banking') == 'started' then
        pcall(function()
            local b = exports['qb-banking']:GetAccountBalance(jobName)
            if b then balance = tonumber(b) or 0; handled = true end
        end)
    end

    -- 3. okokBanking
    if not handled and GetResourceState('okokBanking') == 'started' then
        pcall(function()
            local b = exports['okokBanking']:GetAccount(jobName)
            if b then balance = tonumber(b) or 0; handled = true end
        end)
    end

    -- 4. qb-management
    if not handled and GetResourceState('qb-management') == 'started' then
        pcall(function()
            local b = exports['qb-management']:GetAccount(jobName)
            if b then balance = tonumber(b) or 0; handled = true end
        end)
        if not handled then
            pcall(function()
                local b = exports['qb-management']:GetGangAccount(jobName)
                if b then balance = tonumber(b) or 0; handled = true end
            end)
        end
    end

    -- 5. fd_banking
    if not handled and GetResourceState('fd_banking') == 'started' then
        pcall(function()
            local b = exports['fd_banking']:getAccount(jobName)
            if b then balance = tonumber(b) or 0; handled = true end
        end)
    end

    -- 6. Direct Database Fallbacks
    if not handled then
        pcall(function()
            local row = DB.Query('SELECT amount FROM management_funds WHERE job_name = ?', { jobName })
            if row and row[1] and row[1].amount then
                balance = tonumber(row[1].amount) or 0
                handled = true
            end
        end)
    end

    if not handled then
        pcall(function()
            local row = DB.Query('SELECT amount FROM bank_accounts WHERE account_name = ? OR account_id = ?', { jobName, jobName })
            if row and row[1] and row[1].amount then
                balance = tonumber(row[1].amount) or 0
                handled = true
            end
        end)
    end

    if not handled then
        pcall(function()
            local row = DB.Query('SELECT value FROM okokbanking_societies WHERE society = ?', { jobName })
            if row and row[1] and row[1].value then
                balance = tonumber(row[1].value) or 0
                handled = true
            end
        end)
    end

    return balance
end

-- ============================================================
-- 🏦 UNIVERSAL BANKING / SOCIETY DEPOSIT RESOLVER
-- ============================================================
function Boss.AddSocietyMoney(src, jobName, amount)
    local success = false

    -- 1. Renewed-Banking
    if GetResourceState('Renewed-Banking') == 'started' then
        pcall(function()
            exports['Renewed-Banking']:addAccountMoney(jobName, amount)
            success = true
        end)
    end

    -- 2. qb-banking
    if not success and GetResourceState('qb-banking') == 'started' then
        pcall(function()
            exports['qb-banking']:AddMoney(jobName, amount, 'MTNC Tablet Indbetaling')
            success = true
        end)
    end

    -- 3. okokBanking
    if not success and GetResourceState('okokBanking') == 'started' then
        pcall(function()
            exports['okokBanking']:AddMoney(jobName, amount)
            success = true
        end)
    end

    -- 4. qb-management
    if not success and GetResourceState('qb-management') == 'started' then
        pcall(function()
            exports['qb-management']:AddMoney(jobName, amount)
            success = true
        end)
    end

    -- 5. fd_banking
    if not success and GetResourceState('fd_banking') == 'started' then
        pcall(function()
            exports['fd_banking']:addMoney(jobName, amount)
            success = true
        end)
    end

    -- 6. Direct Database Fallback
    if not success then
        pcall(function()
            DB.Query('UPDATE management_funds SET amount = amount + ? WHERE job_name = ?', { amount, jobName })
            success = true
        end)
    end

    return success
end

-- ============================================================
-- 🏦 UNIVERSAL BANKING / SOCIETY WITHDRAW RESOLVER
-- ============================================================
function Boss.RemoveSocietyMoney(src, jobName, amount)
    local success = false

    -- 1. Renewed-Banking
    if GetResourceState('Renewed-Banking') == 'started' then
        pcall(function()
            exports['Renewed-Banking']:removeAccountMoney(jobName, amount)
            success = true
        end)
    end

    -- 2. qb-banking
    if not success and GetResourceState('qb-banking') == 'started' then
        pcall(function()
            exports['qb-banking']:RemoveMoney(jobName, amount, 'MTNC Tablet Udbetaling')
            success = true
        end)
    end

    -- 3. okokBanking
    if not success and GetResourceState('okokBanking') == 'started' then
        pcall(function()
            exports['okokBanking']:RemoveMoney(jobName, amount)
            success = true
        end)
    end

    -- 4. qb-management
    if not success and GetResourceState('qb-management') == 'started' then
        pcall(function()
            exports['qb-management']:RemoveMoney(jobName, amount)
            success = true
        end)
    end

    -- 5. fd_banking
    if not success and GetResourceState('fd_banking') == 'started' then
        pcall(function()
            exports['fd_banking']:removeMoney(jobName, amount)
            success = true
        end)
    end

    -- 6. Direct Database Fallback
    if not success then
        pcall(function()
            DB.Query('UPDATE management_funds SET amount = amount - ? WHERE job_name = ?', { amount, jobName })
            success = true
        end)
    end

    return success
end

RegisterNetEvent('mtnc:server:getBossData', function()
    local src = source
    local QBCore = GetQBCore()
    if not QBCore then return end

    local p = QBCore.Functions.GetPlayer(src)
    if not p or not p.PlayerData or not p.PlayerData.job then return end

    local job = p.PlayerData.job
    local jobName = job.name
    local isBoss = Boss.IsPlayerBoss(src)

    local societyBalance = Boss.GetSocietyBalance(jobName)
    local employees = {}

    local rows = DB.Query([[
        SELECT citizenid, charinfo, job
        FROM players
        WHERE job LIKE ?
    ]], { '%"name":"' .. jobName .. '"%' }) or {}

    for _, r in ipairs(rows) do
        local cInfo = json.decode(r.charinfo or '{}')
        local jInfo = json.decode(r.job or '{}')
        local empName = (cInfo.firstname or '') .. ' ' .. (cInfo.lastname or '')
        local gradeName = jInfo.grade and (jInfo.grade.name or jInfo.grade.level) or 'Medarbejder'
        local gradeLevel = jInfo.grade and (jInfo.grade.level or jInfo.grade) or 0
        local salary = jInfo.payment or 0
        local isDuty = jInfo.onduty or false

        table.insert(employees, {
            citizenid = r.citizenid,
            name = empName ~= ' ' and empName or 'Ansat',
            grade = gradeLevel,
            gradeName = gradeName,
            salary = salary,
            onDuty = isDuty,
            isBoss = (jInfo.isboss == true)
        })
    end

    TriggerClientEvent('mtnc:client:receiveBossData', src, {
        isBoss = isBoss,
        job = {
            name = jobName,
            label = job.label or jobName,
            grade = job.grade and (job.grade.name or job.grade.level) or 'Boss'
        },
        balance = societyBalance,
        employees = employees
    })
end)

RegisterNetEvent('mtnc:server:bossDeposit', function(amount)
    local src = source
    local amountNum = tonumber(amount) or 0
    if amountNum <= 0 then return end

    local QBCore = GetQBCore()
    if not QBCore then return end
    local p = QBCore.Functions.GetPlayer(src)
    if not p or not p.PlayerData or not p.PlayerData.job then return end

    local jobName = p.PlayerData.job.name
    if not Boss.IsPlayerBoss(src) then
        TriggerClientEvent('mtnc:client:notify', src, '❌ Kun ledelsen har adgang til firmakontoen.', 'error')
        return
    end

    if (p.PlayerData.money.cash or 0) >= amountNum then
        p.Functions.RemoveMoney('cash', amountNum, 'Boss Indbetaling')
        Boss.AddSocietyMoney(src, jobName, amountNum)
        TriggerClientEvent('mtnc:client:notify', src, '💰 Indsatte ' .. amountNum .. ' DKK på ' .. jobName .. ' kontoen.', 'success')
        TriggerEvent('mtnc:server:getBossData')
    elseif (p.PlayerData.money.bank or 0) >= amountNum then
        p.Functions.RemoveMoney('bank', amountNum, 'Boss Indbetaling')
        Boss.AddSocietyMoney(src, jobName, amountNum)
        TriggerClientEvent('mtnc:client:notify', src, '💰 Indsatte ' .. amountNum .. ' DKK på ' .. jobName .. ' kontoen.', 'success')
        TriggerEvent('mtnc:server:getBossData')
    else
        TriggerClientEvent('mtnc:client:notify', src, '❌ Du har ikke nok penge på lommen eller i banken.', 'error')
    end
end)

RegisterNetEvent('mtnc:server:bossWithdraw', function(amount)
    local src = source
    local amountNum = tonumber(amount) or 0
    if amountNum <= 0 then return end

    local QBCore = GetQBCore()
    if not QBCore then return end
    local p = QBCore.Functions.GetPlayer(src)
    if not p or not p.PlayerData or not p.PlayerData.job then return end

    local jobName = p.PlayerData.job.name
    if not Boss.IsPlayerBoss(src) then
        TriggerClientEvent('mtnc:client:notify', src, '❌ Kun ledelsen har adgang til firmakontoen.', 'error')
        return
    end

    local curBalance = Boss.GetSocietyBalance(jobName)
    if curBalance >= amountNum then
        Boss.RemoveSocietyMoney(src, jobName, amountNum)
        p.Functions.AddMoney('cash', amountNum, 'Boss Udbetaling')
        TriggerClientEvent('mtnc:client:notify', src, '💵 Hævede ' .. amountNum .. ' DKK fra ' .. jobName .. ' kontoen.', 'success')
        TriggerEvent('mtnc:server:getBossData')
    else
        TriggerClientEvent('mtnc:client:notify', src, '❌ Firmakontoen har ikke tilstrækkeligt indestående.', 'error')
    end
end)
