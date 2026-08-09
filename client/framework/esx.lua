--[[
  MTNC AdminPanel — Client Framework Adapter: ESX
--]]

local ESXClient = {}
local ESX = nil

function ESXClient.Init()
    if GetResourceState("es_extended") ~= "started" then return false end
    ESX = exports["es_extended"]:getSharedObject()
    return ESX ~= nil
end

_G.MTNC_ESX_Client = ESXClient
