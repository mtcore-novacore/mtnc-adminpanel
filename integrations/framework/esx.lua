-- ============================================================
-- MTNC ADAPTER - ESX (FULL MULTI-FRAMEWORK SUPPORT)
-- ============================================================
FrameworkAdapter = FrameworkAdapter or {}

local ESX = nil

local function GetESX()
    if ESX then return ESX end
    if GetResourceState('es_extended') == 'started' then
        pcall(function()
            ESX = exports['es_extended']:getSharedObject()
        end)
    end
    return ESX
end

function FrameworkAdapter.IsESX()
    return GetESX() ~= nil
end

function FrameworkAdapter.GetESXPlayer(src)
    local x = GetESX()
    if not x then return nil end
    return x.GetPlayerFromId(src)
end

function FrameworkAdapter.GetESXCharacterName(src)
    local xPlayer = FrameworkAdapter.GetESXPlayer(src)
    if not xPlayer then return GetPlayerName(src) end
    if xPlayer.getName then
        local n = xPlayer.getName()
        if n and n ~= '' then return n end
    end
    local fn = xPlayer.get and xPlayer.get('firstName') or ''
    local ln = xPlayer.get and xPlayer.get('lastName') or ''
    local full = (fn .. ' ' .. ln):gsub('^%s*(.-)%s*$', '%1')
    return (full ~= '') and full or GetPlayerName(src)
end

function FrameworkAdapter.GetESXPrimaryJob(src)
    local xPlayer = FrameworkAdapter.GetESXPlayer(src)
    if not xPlayer or not xPlayer.job then
        return { name = 'unemployed', label = 'Arbejdsloes', grade = 0, gradeLabel = 'Borger', duty = false, salary = 0, isBoss = false }
    end
    local j = xPlayer.job
    local isBoss = (j.grade_name == 'boss' or j.grade_name == 'chef' or j.grade_name == 'leader' or (j.grade and j.grade >= 3))
    return {
        name = j.name or 'unemployed',
        label = j.label or j.name or 'Arbejdsloes',
        grade = j.grade or 0,
        gradeLabel = j.grade_label or j.grade_name or 'Medarbejder',
        duty = true,
        salary = tonumber(j.grade_salary) or 0,
        isBoss = isBoss
    }
end

function FrameworkAdapter.SetESXJob(src, jobName, grade)
    local xPlayer = FrameworkAdapter.GetESXPlayer(src)
    if not xPlayer then return false end
    grade = tonumber(grade) or 0
    xPlayer.setJob(jobName, grade)
    return true
end

function FrameworkAdapter.AddESXMoney(src, accountType, amount, reason)
    local xPlayer = FrameworkAdapter.GetESXPlayer(src)
    if not xPlayer then return false end
    amount = tonumber(amount) or 0
    if amount <= 0 then return false end
    if accountType == 'cash' or accountType == 'money' then
        xPlayer.addMoney(amount)
    else
        xPlayer.addAccountMoney(accountType or 'bank', amount)
    end
    return true
end

function FrameworkAdapter.RemoveESXMoney(src, accountType, amount, reason)
    local xPlayer = FrameworkAdapter.GetESXPlayer(src)
    if not xPlayer then return false end
    amount = tonumber(amount) or 0
    if amount <= 0 then return false end
    if accountType == 'cash' or accountType == 'money' then
        xPlayer.removeMoney(amount)
    else
        xPlayer.removeAccountMoney(accountType or 'bank', amount)
    end
    return true
end

function FrameworkAdapter.AddESXItem(src, item, amount)
    local xPlayer = FrameworkAdapter.GetESXPlayer(src)
    if not xPlayer then return false end
    amount = tonumber(amount) or 1
    xPlayer.addInventoryItem(item, amount)
    return true
end

function FrameworkAdapter.ClearESXInventory(src)
    local xPlayer = FrameworkAdapter.GetESXPlayer(src)
    if not xPlayer then return false end
    if xPlayer.inventory then
        for _, item in pairs(xPlayer.inventory) do
            if item.count and item.count > 0 then
                xPlayer.setInventoryItem(item.name, 0)
            end
        end
    end
    return true
end
