--[[
  MTNC AdminPanel — Client Framework Adapter: Qbox
--]]

local QboxClient = {}

function QboxClient.Init()
    return GetResourceState("qbx_core") == "started"
end

_G.MTNC_Qbox_Client = QboxClient
