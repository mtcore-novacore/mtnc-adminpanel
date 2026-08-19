-- ============================================================
-- MTNC UNIVERSAL BOSS & SOCIETY BANKING SYSTEM v3.0.2
-- Supports: qb-banking, Renewed-Banking, okokBanking, qb-management,
--           fd_banking, pefcl, esx_addonaccount & Direct SQL Fallbacks
-- ============================================================
Boss = Boss or {}

function Boss.IsPlayerBoss(src)
    local primary = FrameworkAdapter.GetPrimaryJob(src)
    return (primary and primary.isBoss == true) or false
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

    -- 5. esx_addonaccount
    if not handled and GetResourceState('esx_addonaccount') == 'started' then
        pcall(function()
            local row = DB.Query('SELECT money FROM addon_account_data WHERE account_name = ?', { 'society_' .. jobName })
            if row and row[1] and row[1].money then
                balance = tonumber(row[1].money) or 0
                handled = true
            end
        end)
    end

    -- 6. fd_banking
    if not handled and GetResourceState('fd_banking') == 'started' then
        pcall(function()
            local b = exports['fd_banking']:getAccount(jobName)
            if b then balance = tonumber(b) or 0; handled = true end
        end)
    end

    -- 7. Direct Database Fallbacks
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

    -- 5. esx_addonaccount
    if not success and GetResourceState('esx_addonaccount') == 'started' then
        pcall(function()
            DB.Query('UPDATE addon_account_data SET money = money + ? WHERE account_name = ?', { amount, 'society_' .. jobName })
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

    -- 5. esx_addonaccount
    if not success and GetResourceState('esx_addonaccount') == 'started' then
        pcall(function()
            DB.Query('UPDATE addon_account_data SET money = GREATEST(0, money - ?) WHERE account_name = ?', { amount, 'society_' .. jobName })
            success = true
        end)
    end

    -- 6. Direct Database Fallback
    if not success then
        pcall(function()
            DB.Query('UPDATE management_funds SET amount = GREATEST(0, amount - ?) WHERE job_name = ?', { amount, jobName })
            success = true
        end)
    end

    return success
end

RegisterNetEvent('mtnc:server:getBossData', function()
    local src = source
    local primary = FrameworkAdapter.GetPrimaryJob(src)
    if not primary or not primary.name then return end

    local jobName = primary.name
    local isBoss = Boss.IsPlayerBoss(src)
    local societyBalance = Boss.GetSocietyBalance(jobName)
    local employees = {}
    local fType = FrameworkAdapter.GetFrameworkType()

    if fType == 'esx' then
        local rows = DB.Query([[
            SELECT identifier, firstname, lastname, job_grade
            FROM users
            WHERE job = ?
        ]], { jobName }) or {}

        for _, r in ipairs(rows) do
            local empName = ((r.firstname or '') .. ' ' .. (r.lastname or '')):gsub('^%s*(.-)%s*$', '%1')
            local gradeLvl = tonumber(r.job_grade) or 0
            table.insert(employees, {
                citizenid = r.identifier,
                name = empName ~= '' and empName or 'Ansat',
                grade = gradeLvl,
                gradeName = 'Grad ' .. gradeLvl,
                salary = 0,
                onDuty = true,
                isBoss = (gradeLvl >= 3)
            })
        end
    else
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
    end

    TriggerClientEvent('mtnc:client:receiveBossData', src, {
        isBoss = isBoss,
        job = {
            name = jobName,
            label = primary.label or jobName,
            grade = primary.gradeLabel or 'Boss'
        },
        balance = societyBalance,
        employees = employees
    })
end)

RegisterNetEvent('mtnc:server:bossDeposit', function(amount)
    local src = source
    local amountNum = tonumber(amount) or 0
    if amountNum <= 0 then return end

    local primary = FrameworkAdapter.GetPrimaryJob(src)
    if not primary or not primary.name then return end

    local jobName = primary.name
    if not Boss.IsPlayerBoss(src) then
        TriggerClientEvent('mtnc:client:notify', src, '❌ Kun ledelsen har adgang til firmakontoen.', 'error')
        return
    end

    local deducted = FrameworkAdapter.RemoveMoney(src, 'cash', amountNum, 'Boss Indbetaling')
    if not deducted then
        deducted = FrameworkAdapter.RemoveMoney(src, 'bank', amountNum, 'Boss Indbetaling')
    end

    if deducted then
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

    local primary = FrameworkAdapter.GetPrimaryJob(src)
    if not primary or not primary.name then return end

    local jobName = primary.name
    if not Boss.IsPlayerBoss(src) then
        TriggerClientEvent('mtnc:client:notify', src, '❌ Kun ledelsen har adgang til firmakontoen.', 'error')
        return
    end

    local curBalance = Boss.GetSocietyBalance(jobName)
    if curBalance >= amountNum then
        Boss.RemoveSocietyMoney(src, jobName, amountNum)
        FrameworkAdapter.AddMoney(src, 'cash', amountNum, 'Boss Udbetaling')
        TriggerClientEvent('mtnc:client:notify', src, '💵 Hævede ' .. amountNum .. ' DKK fra ' .. jobName .. ' kontoen.', 'success')
        TriggerEvent('mtnc:server:getBossData')
    else
        TriggerClientEvent('mtnc:client:notify', src, '❌ Firmakontoen har ikke tilstrækkeligt indestående.', 'error')
    end
end)
