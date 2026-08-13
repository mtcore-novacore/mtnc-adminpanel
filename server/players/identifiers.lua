PlayerIdentifiers = {}

function PlayerIdentifiers.Get(src)
    return {
        steam = CoreUtils.GetPlayerIdentifier(src, "steam"),
        discord = CoreUtils.GetPlayerIdentifier(src, "discord"),
        license = CoreUtils.GetPlayerIdentifier(src, "license"),
        fivem = CoreUtils.GetPlayerIdentifier(src, "fivem")
    }
end
