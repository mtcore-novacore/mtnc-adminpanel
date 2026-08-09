--[[
  MTNC AdminPanel — Framework Adapter: Qbox
--]]

local QboxAdapter = {}

function QboxAdapter.Init()
    return GetResourceState("qbx_core") == "started"
end

function QboxAdapter.GetPlayer(src)
    if exports.qbx_core and exports.qbx_core.GetPlayer then
        return exports.qbx_core:GetPlayer(src)
    end
    return MTNC_QBCore.GetPlayer(src)
end

function QboxAdapter.GetGroup(src)
    return MTNC_QBCore.GetGroup(src)
end

function QboxAdapter.GetJob(src)
    return MTNC_QBCore.GetJob(src)
end

function QboxAdapter.GetMoney(src, mtype)
    return MTNC_QBCore.GetMoney(src, mtype)
end

function QboxAdapter.AddMoney(src, mtype, amount)
    return MTNC_QBCore.AddMoney(src, mtype, amount)
end

function QboxAdapter.RemoveMoney(src, mtype, amount)
    return MTNC_QBCore.RemoveMoney(src, mtype, amount)
end

function QboxAdapter.Revive(src)
    TriggerClientEvent("qbx_medical:client:playerRevived", src)
end

function QboxAdapter.Heal(src)
    TriggerClientEvent("qbx_medical:client:heal", src)
end

_G.MTNC_Qbox = QboxAdapter
