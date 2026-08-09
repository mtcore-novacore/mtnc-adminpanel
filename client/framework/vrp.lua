--[[
  MTNC AdminPanel — Client Framework Adapter: vRP
--]]

local vRPClient = {}

function vRPClient.Init()
    return GetResourceState("vrp") == "started"
end

_G.MTNC_vRP_Client = vRPClient
