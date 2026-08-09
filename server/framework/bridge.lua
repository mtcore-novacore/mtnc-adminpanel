--[[
  MTNC AdminPanel — Unified Framework Bridge
  (Åben for serverejere — understøtter qbcore, qbox, esx, vrp, standalone og custom)
--]]

local Bridge = {}
Bridge.name = "standalone"
Bridge.adapter = nil

function Bridge.Init()
    local mode = Config.framework or "auto"

    if (mode == "custom") and MTNC_Custom_Server and MTNC_Custom_Server.Init() then
        Bridge.name = "custom"
        Bridge.adapter = MTNC_Custom_Server
    elseif (mode == "qbcore" or mode == "auto") and MTNC_QBCore and MTNC_QBCore.Init() then
        Bridge.name = "qbcore"
        Bridge.adapter = MTNC_QBCore
    elseif (mode == "qbox" or mode == "auto") and MTNC_Qbox and MTNC_Qbox.Init() then
        Bridge.name = "qbox"
        Bridge.adapter = MTNC_Qbox
    elseif (mode == "esx" or mode == "auto") and MTNC_ESX and MTNC_ESX.Init() then
        Bridge.name = "esx"
        Bridge.adapter = MTNC_ESX
    elseif (mode == "vrp" or mode == "auto") and MTNC_vRP and MTNC_vRP.Init() then
        Bridge.name = "vrp"
        Bridge.adapter = MTNC_vRP
    else
        Bridge.name = "standalone"
        Bridge.adapter = MTNC_Standalone
    end

    MTNC_Logger.Info(string.format("Framework Bridge aktiv: %s", string.upper(Bridge.name)))
end

function Bridge.GetPlayer(src)
    return Bridge.adapter and Bridge.adapter.GetPlayer(src)
end

function Bridge.GetGroup(src)
    return Bridge.adapter and Bridge.adapter.GetGroup(src) or "user"
end

function Bridge.GetJob(src)
    return Bridge.adapter and Bridge.adapter.GetJob(src) or { name = "civilian", label = "Civilian", grade = 0, grade_name = "0" }
end

function Bridge.GetMoney(src, mtype)
    return Bridge.adapter and Bridge.adapter.GetMoney(src, mtype) or 0
end

function Bridge.AddMoney(src, mtype, amount)
    return Bridge.adapter and Bridge.adapter.AddMoney(src, mtype, amount) or false
end

function Bridge.RemoveMoney(src, mtype, amount)
    return Bridge.adapter and Bridge.adapter.RemoveMoney(src, mtype, amount) or false
end

function Bridge.Revive(src)
    if Bridge.adapter and Bridge.adapter.Revive then Bridge.adapter.Revive(src) end
end

function Bridge.Heal(src)
    if Bridge.adapter and Bridge.adapter.Heal then Bridge.adapter.Heal(src) end
end

_G.MTNC_Bridge = Bridge
