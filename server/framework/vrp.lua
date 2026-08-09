--[[
  MTNC AdminPanel — Framework Adapter: vRP
--]]

local vRPAdapter = {}
local vRP = nil

function vRPAdapter.Init()
    if GetResourceState("vrp") ~= "started" then return false end
    local Proxy = module and module("vrp", "lib/Proxy")
    if Proxy then vRP = Proxy.getInterface("vRP") end
    return vRP ~= nil
end

function vRPAdapter.GetPlayer(src)
    return vRP and vRP.getUserId({src}) or nil
end

function vRPAdapter.GetGroup(src)
    local uid = vRPAdapter.GetPlayer(src)
    if not uid then return "user" end
    if vRP.hasGroup and vRP.hasGroup({uid, "admin"}) then return "admin" end
    if vRP.hasGroup and vRP.hasGroup({uid, "superadmin"}) then return "superadmin" end
    return "user"
end

function vRPAdapter.GetJob(src)
    return { name = "citizen", label = "Borger", grade = 0, grade_name = "0" }
end

function vRPAdapter.GetMoney(src, mtype)
    local uid = vRPAdapter.GetPlayer(src)
    if not uid or not vRP then return 0 end
    if mtype == "bank" then
        return vRP.getBankMoney and vRP.getBankMoney({uid}) or 0
    else
        return vRP.getMoney and vRP.getMoney({uid}) or 0
    end
end

function vRPAdapter.AddMoney(src, mtype, amount)
    local uid = vRPAdapter.GetPlayer(src)
    if not uid or not vRP then return false end
    if mtype == "bank" then
        vRP.giveBankMoney({uid, amount})
    else
        vRP.giveMoney({uid, amount})
    end
    return true
end

function vRPAdapter.RemoveMoney(src, mtype, amount)
    local uid = vRPAdapter.GetPlayer(src)
    if not uid or not vRP then return false end
    if mtype == "bank" then
        return vRP.tryWithdraw({uid, amount})
    else
        return vRP.tryPayment({uid, amount})
    end
end

function vRPAdapter.Revive(src)
    TriggerClientEvent("mtnc:client:healSelf", src)
end

function vRPAdapter.Heal(src)
    TriggerClientEvent("mtnc:client:healSelf", src)
end

_G.MTNC_vRP = vRPAdapter
