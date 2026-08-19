-- ============================================================
-- MTNC ADAPTER - VRP (FULL MULTI-FRAMEWORK SUPPORT)
-- ============================================================
FrameworkAdapter = FrameworkAdapter or {}

local vRP = nil
local vRPclient = nil

local function GetVRP()
    if vRP then return vRP end
    if GetResourceState('vrp') == 'started' then
        pcall(function()
            local Proxy = module("vrp", "lib/Proxy")
            local Tunnel = module("vrp", "lib/Tunnel")
            if Proxy then
                vRP = Proxy.getInterface("vRP")
                vRPclient = Tunnel.getInterface("vRP","mtnc-adminpanel")
            end
        end)
    end
    return vRP
end

function FrameworkAdapter.IsVRP()
    return GetResourceState('vrp') == 'started'
end

function FrameworkAdapter.GetVRPUserId(src)
    local v = GetVRP()
    if not v then return nil end
    return v.getUserId({src})
end

function FrameworkAdapter.GetVRPCharacterName(src)
    local v = GetVRP()
    if not v then return GetPlayerName(src) end
    local userId = v.getUserId({src})
    if not userId then return GetPlayerName(src) end
    local identity = v.getUserIdentity({userId})
    if identity then
        local fn = identity.firstname or ''
        local ln = identity.name or ''
        local full = (fn .. ' ' .. ln):gsub('^%s*(.-)%s*$', '%1')
        if full ~= '' then return full end
    end
    return GetPlayerName(src)
end

function FrameworkAdapter.GetVRPPrimaryJob(src)
    local v = GetVRP()
    if not v then
        return { name = 'unemployed', label = 'Arbejdsloes', grade = 0, gradeLabel = 'Borger', duty = false, salary = 0, isBoss = false }
    end
    local userId = v.getUserId({src})
    if not userId then
        return { name = 'unemployed', label = 'Arbejdsloes', grade = 0, gradeLabel = 'Borger', duty = false, salary = 0, isBoss = false }
    end
    local group = v.getUserGroupByType and v.getUserGroupByType({userId, "job"}) or "unemployed"
    return {
        name = group,
        label = group,
        grade = 0,
        gradeLabel = 'Medarbejder',
        duty = true,
        salary = 0,
        isBoss = false
    }
end

function FrameworkAdapter.AddVRPMoney(src, accountType, amount, reason)
    local v = GetVRP()
    if not v then return false end
    local userId = v.getUserId({src})
    if not userId then return false end
    amount = tonumber(amount) or 0
    if amount <= 0 then return false end
    if accountType == 'cash' or accountType == 'money' then
        v.giveMoney({userId, amount})
    else
        v.giveBankMoney({userId, amount})
    end
    return true
end

function FrameworkAdapter.RemoveVRPMoney(src, accountType, amount, reason)
    local v = GetVRP()
    if not v then return false end
    local userId = v.getUserId({src})
    if not userId then return false end
    amount = tonumber(amount) or 0
    if amount <= 0 then return false end
    if accountType == 'cash' or accountType == 'money' then
        return v.tryPayment({userId, amount})
    else
        return v.tryFullPayment({userId, amount})
    end
end

function FrameworkAdapter.SetVRPJob(src, jobName, grade)
    local v = GetVRP()
    if not v then return false end
    local userId = v.getUserId({src})
    if not userId then return false end
    if v.addUserGroup then
        v.addUserGroup({userId, jobName})
    end
    return true
end
