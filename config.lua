--[[
#########################################################

  ███╗   ███╗████████╗███╗   ██╗ ██████╗
  ████╗ ████║╚══██╔══╝████╗  ██║██╔════╝
  ██╔████╔██║   ██║   ██╔██╗ ██║██║
  ██║╚██╔╝██║   ██║   ██║╚██╗██║██║
  ██║ ╚═╝ ██║   ██║   ██║ ╚████║╚██████╗
  ╚═╝     ╚═╝   ╚═╝   ╚═╝  ╚═══╝ ╚═════╝

  MTNC Admin Panel v2.5.0 — NovaCore
#########################################################
--]]

Config = {}

-- ── LICENSNØGLE (PÅKRÆVET) ─────────────────────────────
-- Du skal have en gyldig licensnøgle for at køre admin-panelet.
-- Licensen valideres mod NovaCore API serveren ved opstart.
Config.licenseKey = "MTNC-ENT-2026-9988-X7"

-- ── FRAMEWORK ─────────────────────────────────────────
-- "esx"        → es_extended
-- "qbcore"     → qb-core
-- "vrp"        → vrp
-- "standalone" → ingen framework (vanilla FiveM)
Config.framework = "esx"

-- ── GENERELT ──────────────────────────────────────────
Config.general = {
    openCommand  = "admin",       -- /admin kommando
    hotkey       = 104,           -- Numpad 8
    uiTitle      = "MTNC Admin Panel",
    closeKey     = 322,           -- ESC lukker menuen
    notifySound  = true,
    debug        = false,
}

-- ── PERMISSIONS ───────────────────────────────────────
Config.permissions = {
    allowAll     = false,         -- Sæt true for at give alle adgang (KUN til test!)

    -- Steam IDs der altid har adgang (uanset framework)
    allowedSteamIds = {
        -- "steam:110000112345678",
    },

    -- ESX grupper med adgang
    esxGroups = {
        "superadmin",
        "admin",
        "moderator",
    },

    -- QBCore jobs/roles med adgang
    qbRoles = {
        "god",
        "admin",
    },

    -- Ace permissions (native FiveM)
    acePermission = "mtnc.admin",

    enableFrameworkCheck = true,
}

-- ── HVAD ER AKTIVERET ─────────────────────────────────
Config.categories = {
    players   = true,   -- Spiller management
    vehicles  = true,   -- Køretøjer
    world     = true,   -- Vejr, tid, resources
    economy   = true,   -- Penge & items
    staff     = true,   -- Staff tools (noclip, spectate etc.)
    logs      = true,   -- Log viewer fra backend
}

-- ── HANDLINGER ────────────────────────────────────────
Config.actions = {
    player = {
        ban      = true,
        kick     = true,
        warn     = true,
        freeze   = true,
        revive   = true,
        heal     = true,
        teleport = true,
        bring    = true,
        godmode  = true,
    },
    vehicle = {
        spawn    = true,
        repair   = true,
        fuel     = true,
        delete   = true,
        plate    = true,
    },
    world = {
        weather      = true,
        time         = true,
        restartRes   = true,
        announcement = true,
    },
    economy = {
        giveCash     = true,
        giveBank     = true,
        removeMoneyC = true,
        removeMoneyB = true,
    },
    staff = {
        noclip    = true,
        spectate  = true,
        invisible = true,
        godmode   = true,
        freecam   = true,
    },
}

-- ── VEJR MULIGHEDER ───────────────────────────────────
Config.weatherTypes = {
    "CLEAR", "EXTRASUNNY", "CLOUDS", "OVERCAST",
    "RAIN", "THUNDER", "FOGGY", "SNOWLIGHT", "BLIZZARD",
}

-- ── BESKEDER ──────────────────────────────────────────
Config.messages = {
    noAccess      = "❌ Du har ikke adgang til admin-panelet.",
    actionSuccess = "✅ Handling udført.",
    actionDenied  = "❌ Du har ikke tilladelse til denne handling.",
    playerGone    = "❌ Spiller ikke længere online.",
    invalidLicense= "❌ Ugyldig eller udløbet licensnøgle! Kontakt NovaCore support.",
}
