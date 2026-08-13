--[[
  MTNC API Bridge Connector v3.0.0 — NovaCore & MTCore
  Dynamisk Aflæsning af Skiftende VPS IP & Dynamisk Port fra server.cfg
--]]

APIConnect = {}

local function GetDynamicPort()
    local tcpPort = GetConvar("net_tcpPort", "")
    if tcpPort ~= "" and tonumber(tcpPort) then return tostring(tcpPort) end

    local tcpAdd = GetConvar("endpoint_add_tcp", "")
    if tcpAdd ~= "" and tcpAdd:find(":") then
        local p = tcpAdd:match(":([0-9]+)")
        if p then return p end
    end

    local ep = GetConvar("endpoint", "")
    if ep ~= "" and ep:find(":") then
        local p = ep:match(":([0-9]+)")
        if p then return p end
    end

    return tostring(GetConvarInt("net_tcpPort", 30120))
end

APIConnect.Analyse = function()
    local serverPort = GetDynamicPort()
    local serverIp = GetConvar("endpoint", "127.0.0.1")

    if serverIp:find(":") then
        serverIp = serverIp:match("([^:]+)")
    end

    local fullEndpoint = serverIp .. ":" .. serverPort
    return {
        status = "ONLINE",
        version = Config.version,
        serverIp = fullEndpoint,
        rawIp = serverIp,
        serverPort = serverPort,
        serverName = GetConvar("sv_hostname", "MTNC FiveM Server Node"),
        players = #GetPlayers(),
        maxPlayers = GetConvarInt("sv_maxclients", 128)
    }
end

exports('GetMTNCConnect', function()
    return APIConnect
end)
