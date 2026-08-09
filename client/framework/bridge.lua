--[[
  MTNC AdminPanel — Client Framework Bridge
  (Åben for serverejere — understøtter qbcore, qbox, esx, vrp, standalone og custom)
--]]

local ClientBridge = {}
ClientBridge.name = "standalone"

function ClientBridge.Init()
    local mode = Config.framework or "auto"

    if (mode == "custom") and MTNC_Custom_Client and MTNC_Custom_Client.Init() then
        ClientBridge.name = "custom"
    elseif (mode == "qbcore" or mode == "auto") and MTNC_QBCore_Client and MTNC_QBCore_Client.Init() then
        ClientBridge.name = "qbcore"
    elseif (mode == "qbox" or mode == "auto") and MTNC_Qbox_Client and MTNC_Qbox_Client.Init() then
        ClientBridge.name = "qbox"
    elseif (mode == "esx" or mode == "auto") and MTNC_ESX_Client and MTNC_ESX_Client.Init() then
        ClientBridge.name = "esx"
    elseif (mode == "vrp" or mode == "auto") and MTNC_vRP_Client and MTNC_vRP_Client.Init() then
        ClientBridge.name = "vrp"
    else
        ClientBridge.name = "standalone"
    end
end

_G.MTNC_ClientBridge = ClientBridge
