--[[
#########################################################

# ███╗   ███╗████████╗███╗   ██╗ ██████╗
# ████╗ ████║╚══██╔══╝████╗  ██║██╔════╝
# ██╔████╔██║   ██║   ██╔██╗ ██║██║     
# ██║╚██╔╝██║   ██║   ██║╚██╗██║██║     
# ██║ ╚═╝ ██║   ██║   ██║ ╚████║╚██████╗
# ╚═╝     ╚═╝   ╚═╝   ╚═╝  ╚═══╝ ╚═════╝
                                      

#########################################################
--]]

Config = {}

Config.framework = "esx" -- esx // vrp // qbcore





Config.general = {
    openCommand = "admin",
    hotkey = "104",
    allowAll = false,
    debug = false,
    useMySQL = true,
    useLogs = true,
    uiTitle = "NovaCore Admin Panel",
    closeKey = 322,
    notifySound = true
}

Config.api = {
    enabled = true,
    baseUrl = "http://127.0.0.1:3009",
    healthEndpoint = "/api/health",
    configEndpoint = "/api/config",
    registerEndpoint = "/api/servers/register",
    heartbeatEndpoint = "/api/servers/heartbeat",
    timeout = 5000,
    serverName = "NovaCore FiveM Server"
}

Config.permissions = {
    allowAll = false,
    allowedSteamIds = {
        -- "steam:11000010abcdefg"
    },
    esxGroups = {
        "superadmin",
        "admin"
    },
    qbRoles = {
        "god",
        "admin"
    },
    vrpGroups = {
        "admin",
        "moderator"
    },
    enableFrameworkCheck = true,
    useDatabaseUsers = true,
    defaultRole = "moderator"
}

Config.categories = {
    player = true,
    vehicle = true,
    world = true,
    character = true,
    staff = true,
    logs = true,
    settings = true
}

Config.actions = {
    player = {
        ban = true,
        kick = true,
        mute = true,
        warn = true,
        teleport = true,
        bring = true,
        revive = true,
        heal = true,
        freeze = true,
        godmode = true
    },
    vehicle = {
        spawn = true,
        repair = true,
        fuel = true,
        delete = true,
        giveKeys = true,
        plate = true
    },
    world = {
        weather = true,
        time = true,
        restartResources = true,
        startEvents = true,
        announcement = true
    },
    character = {
        money = true,
        bankMoney = true,
        giveItems = true,
        giveWeapons = true,
        changeOutfit = true,
        giveXp = true
    },
    staff = {
        noclip = true,
        spectate = true,
        invisible = true,
        freecam = true,
        showPlayerNames = true,
        blips = true,
        godmode = true,
        superJump = true
    },
    logs = {
        staffLogs = true,
        chatLogs = true,
        banLogs = true,
        kickLogs = true,
        itemLogs = true,
        moneyLogs = true
    }
}

Config.messages = {
    noAccess = "Du har ikke adgang til admin-panelet.",
    actionSuccess = "Handling udført.",
    actionDenied = "Du har ikke tilladelse til denne handling."
}

Config.openCMD = Config.general.openCommand
Config.hotkey = Config.general.hotkey
Config.allowAll = Config.permissions.allowAll
Config.allowedSteamIds = Config.permissions.allowedSteamIds


