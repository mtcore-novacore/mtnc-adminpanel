--[[
  MTNC AdminPanel — Framework Adapter: Standalone (Vanilla FiveM)
--]]

local StandaloneAdapter = {}

function StandaloneAdapter.Init()
    return true
end

function StandaloneAdapter.GetPlayer(src)
    return src
end

function StandaloneAdapter.GetGroup(src)
    return "user"
end

function StandaloneAdapter.GetJob(src)
    return { name = "civilian", label = "Civilian", grade = 0, grade_name = "0" }
end

function StandaloneAdapter.GetMoney(src, mtype)
    return 0
end

function StandaloneAdapter.AddMoney(src, mtype, amount)
    return false
end

function StandaloneAdapter.RemoveMoney(src, mtype, amount)
    return false
end

function StandaloneAdapter.Revive(src)
    TriggerClientEvent("mtnc:client:healSelf", src)
end

function StandaloneAdapter.Heal(src)
    TriggerClientEvent("mtnc:client:healSelf", src)
end

_G.MTNC_Standalone = StandaloneAdapter
