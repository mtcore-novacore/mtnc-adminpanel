--[[
  MTNC AdminPanel — Framework Adapter: ESX
--]]

local ESXAdapter = {}
local ESX = nil

function ESXAdapter.Init()
    if GetResourceState("es_extended") ~= "started" then return false end
    ESX = exports["es_extended"]:getSharedObject()
    return ESX ~= nil
end

function ESXAdapter.GetPlayer(src)
    return ESX and ESX.GetPlayerFromId(src) or nil
end

function ESXAdapter.GetGroup(src)
    local xPlayer = ESXAdapter.GetPlayer(src)
    return xPlayer and xPlayer.getGroup and xPlayer.getGroup() or "user"
end

function ESXAdapter.GetJob(src)
    local xPlayer = ESXAdapter.GetPlayer(src)
    if not xPlayer or not xPlayer.job then return { name = "unemployed", label = "Arbejdsløs", grade = 0, grade_name = "0" } end
    return {
        name = xPlayer.job.name,
        label = xPlayer.job.label or xPlayer.job.name,
        grade = xPlayer.job.grade or 0,
        grade_name = xPlayer.job.grade_label or tostring(xPlayer.job.grade or 0)
    }
end

function ESXAdapter.GetMoney(src, mtype)
    local xPlayer = ESXAdapter.GetPlayer(src)
    if not xPlayer then return 0 end
    if mtype == "bank" then
        local account = xPlayer.getAccount and xPlayer.getAccount("bank")
        return account and account.money or 0
    else
        return xPlayer.getMoney and xPlayer.getMoney() or 0
    end
end

function ESXAdapter.AddMoney(src, mtype, amount)
    local xPlayer = ESXAdapter.GetPlayer(src)
    if not xPlayer then return false end
    if mtype == "bank" then
        xPlayer.addAccountMoney("bank", amount)
    else
        xPlayer.addMoney(amount)
    end
    return true
end

function ESXAdapter.RemoveMoney(src, mtype, amount)
    local xPlayer = ESXAdapter.GetPlayer(src)
    if not xPlayer then return false end
    if mtype == "bank" then
        xPlayer.removeAccountMoney("bank", amount)
    else
        xPlayer.removeMoney(amount)
    end
    return true
end

function ESXAdapter.Revive(src)
    TriggerClientEvent("esx_ambulancejob:revive", src)
end

function ESXAdapter.Heal(src)
    TriggerClientEvent("esx_basicneeds:healPlayer", src)
end

_G.MTNC_ESX = ESXAdapter
