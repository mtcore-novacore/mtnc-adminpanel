--[[
  MTNC AdminPanel — Framework Adapter: QBCore
--]]

local QBCoreAdapter = {}
local QBCore = nil

function QBCoreAdapter.Init()
    if GetResourceState("qb-core") ~= "started" then return false end
    QBCore = exports["qb-core"]:GetCoreObject()
    return QBCore ~= nil
end

function QBCoreAdapter.GetPlayer(src)
    return QBCore and QBCore.Functions.GetPlayer(src) or nil
end

function QBCoreAdapter.GetGroup(src)
    return QBCore and QBCore.Functions.GetPermission(src) or "user"
end

function QBCoreAdapter.GetJob(src)
    local player = QBCoreAdapter.GetPlayer(src)
    if not player or not player.PlayerData.job then return { name = "unemployed", label = "Unemployed", grade = 0, grade_name = "0" } end
    return {
        name = player.PlayerData.job.name,
        label = player.PlayerData.job.label or player.PlayerData.job.name,
        grade = player.PlayerData.job.grade.level or 0,
        grade_name = player.PlayerData.job.grade.name or "0"
    }
end

function QBCoreAdapter.GetMoney(src, mtype)
    local player = QBCoreAdapter.GetPlayer(src)
    if not player then return 0 end
    local account = (mtype == "bank") and "bank" or "cash"
    return player.Functions.GetMoney(account) or 0
end

function QBCoreAdapter.AddMoney(src, mtype, amount)
    local player = QBCoreAdapter.GetPlayer(src)
    if not player then return false end
    local account = (mtype == "bank") and "bank" or "cash"
    return player.Functions.AddMoney(account, amount, "mtnc-admin-give")
end

function QBCoreAdapter.RemoveMoney(src, mtype, amount)
    local player = QBCoreAdapter.GetPlayer(src)
    if not player then return false end
    local account = (mtype == "bank") and "bank" or "cash"
    return player.Functions.RemoveMoney(account, amount, "mtnc-admin-remove")
end

function QBCoreAdapter.Revive(src)
    TriggerClientEvent("hospital:client:Revive", src)
end

function QBCoreAdapter.Heal(src)
    TriggerClientEvent("hospital:client:HealInjury", src, "full")
end

_G.MTNC_QBCore = QBCoreAdapter
