--[[
  MTNC API Bridge Connector v3.0.0 — NovaCore & MTCore
  Giver 3. parts scripts mulighed for direkte integration med MTNC AdminPanel.
--]]

APIConnect = {}

APIConnect.Analyse = function()
    local serverPort = GetConvar("net_tcpPort", "30120")
    local serverIp = GetConvar("endpoint", "127.0.0.1")
    if serverIp:find(":") then
        serverIp = serverIp:match("([^:]+)")
    end
    return {
        status = "ONLINE",
        version = Config.version,
        serverIp = serverIp .. ":" .. serverPort,
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
