--[[
  ███╗   ███╗████████╗███╗   ██╗ ██████╗
  ████╗ ████║╚══██╔══╝████╗  ██║██╔════╝
  ██╔████╔██║   ██║   ██╔██╗ ██║██║
  ██║╚██╔╝██║   ██║   ██║╚██╗██║██║
  ██║ ╚═╝ ██║   ██║   ██║ ╚████║╚██████╗
  ╚═╝     ╚═╝   ╚═╝   ╚═╝  ╚═══╝ ╚═════╝

  MTNC Framework Adapter — Support for QBCore, Qbox, ESX, vRP & Standalone
--]]

local Framework = {}
Framework.name = "standalone"
Framework.object = nil

local vRP = nil

function Framework.Detect()
    local cfgMode = Config.framework or "auto"

    if cfgMode == "qbcore" or (cfgMode == "auto" and GetResourceState("qb-core") == "started") then
        Framework.name = "qbcore"
        Framework.object = exports["qb-core"]:GetCoreObject()
        print("^2[MTNC-FRAMEWORK] ✅ Detekteret Framework: QBCore^7")
    elseif cfgMode == "qbox" or (cfgMode == "auto" and GetResourceState("qbx_core") == "started") then
        Framework.name = "qbox"
        Framework.object = exports["qbx_core"]
        print("^2[MTNC-FRAMEWORK] ✅ Detekteret Framework: Qbox (QBX)^7")
    elseif cfgMode == "esx" or (cfgMode == "auto" and GetResourceState("es_extended") == "started") then
        Framework.name = "esx"
        Framework.object = exports["es_extended"]:getSharedObject()
        print("^2[MTNC-FRAMEWORK] ✅ Detekteret Framework: ESX (es_extended)^7")
    elseif cfgMode == "vrp" or (cfgMode == "auto" and GetResourceState("vrp") == "started") then
        Framework.name = "vrp"
        local Proxy = module and module("vrp", "lib/Proxy")
        if Proxy then vRP = Proxy.getInterface("vRP") end
        print("^2[MTNC-FRAMEWORK] ✅ Detekteret Framework: vRP^7")
    else
        Framework.name = "standalone"
        print("^3[MTNC-FRAMEWORK] ℹ️ Kører i Standalone tilstand (Vanilla FiveM)^7")
    end
end

-- Get player data wrapper
function Framework.GetPlayer(src)
    if Framework.name == "esx" and Framework.object then
        return Framework.object.GetPlayerFromId(src)
    elseif (Framework.name == "qbcore" or Framework.name == "qbox") and Framework.object then
        return Framework.object.Functions.GetPlayer(src)
    elseif Framework.name == "vrp" and vRP then
        return vRP.getUserId({src})
    end
    return nil
end

-- Give Money wrapper (ESX, QBCore, Qbox, vRP)
function Framework.GiveMoney(src, mtype, amount)
    if Framework.name == "esx" and Framework.object then
        local xPlayer = Framework.object.GetPlayerFromId(src)
        if xPlayer then
            local account = (mtype == "bank") and "bank" or "money"
            xPlayer.addAccountMoney(account, amount)
            return true
        end
    elseif (Framework.name == "qbcore" or Framework.name == "qbox") and Framework.object then
        local player = Framework.object.Functions.GetPlayer(src)
        if player then
            local account = (mtype == "bank") and "bank" or "cash"
            player.Functions.AddMoney(account, amount, "mtnc-admin-give")
            return true
        end
    elseif Framework.name == "vrp" and vRP then
        local user_id = vRP.getUserId({src})
        if user_id then
            if mtype == "bank" then
                vRP.giveBankMoney({user_id, amount})
            else
                vRP.giveMoney({user_id, amount})
            end
            return true
        end
    end
    return false
end

-- Remove Money wrapper (ESX, QBCore, Qbox, vRP)
function Framework.RemoveMoney(src, mtype, amount)
    if Framework.name == "esx" and Framework.object then
        local xPlayer = Framework.object.GetPlayerFromId(src)
        if xPlayer then
            local account = (mtype == "bank") and "bank" or "money"
            xPlayer.removeAccountMoney(account, amount)
            return true
        end
    elseif (Framework.name == "qbcore" or Framework.name == "qbox") and Framework.object then
        local player = Framework.object.Functions.GetPlayer(src)
        if player then
            local account = (mtype == "bank") and "bank" or "cash"
            player.Functions.RemoveMoney(account, amount, "mtnc-admin-remove")
            return true
        end
    elseif Framework.name == "vrp" and vRP then
        local user_id = vRP.getUserId({src})
        if user_id then
            if mtype == "bank" then
                vRP.tryWithdraw({user_id, amount})
            else
                vRP.tryPayment({user_id, amount})
            end
            return true
        end
    end
    return false
end

AddEventHandler("onResourceStart", function(res)
    if GetCurrentResourceName() ~= res then return end
    Framework.Detect()
end)

_G.MTNCFramework = Framework
