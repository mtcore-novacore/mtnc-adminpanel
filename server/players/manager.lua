PlayersManager = {}

function PlayersManager.GetAll()
    local players = {}
    for _, id in ipairs(GetPlayers()) do
        table.insert(players, {
            id = tonumber(id),
            name = GetPlayerName(id),
            ping = GetPlayerPing(id),
            steam = CoreUtils.GetPlayerIdentifier(id, "steam") or "N/A"
        })
    end
    return players
end
