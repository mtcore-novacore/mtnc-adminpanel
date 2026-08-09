--[[
  MTNC AdminPanel — Client Framework Adapter: QBCore
--]]

local QBCoreClient = {}
local QBCore = nil

function QBCoreClient.Init()
    if GetResourceState("qb-core") ~= "started" then return false end
    QBCore = exports["qb-core"]:GetCoreObject()
    return QBCore ~= nil
end

_G.MTNC_QBCore_Client = QBCoreClient
