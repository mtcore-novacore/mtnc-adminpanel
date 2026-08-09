--[[
  ███╗   ███╗████████╗███╗   ██╗ ██████╗
  ████╗ ████║╚══██╔══╝████╗  ██║██╔════╝
  ██╔████╔██║   ██║   ██╔██╗ ██║██║
  ██║╚██╔╝██║   ██║   ██║╚██╗██║██║
  ██║ ╚═╝ ██║   ██║   ██║ ╚████║╚██████╗
  ╚═╝     ╚═╝   ╚═╝   ╚═╝  ╚═══╝ ╚═════╝

  MTNC AdminPanel v2.5.0 — NovaCore
  Public Configuration File
--]]

Config = {}

Config.version = "2.5.0"

-- ── FRAMEWORK VALG ────────────────────────────────────
-- "auto"       → Detekterer automatisk qb-core, qbx_core, es_extended, vrp
-- "qbcore"     → qb-core (kan tilpasses i framework/qbcore.lua)
-- "qbox"       → qbx_core (kan tilpasses i framework/qbox.lua)
-- "esx"        → es_extended (kan tilpasses i framework/esx.lua)
-- "vrp"        → vrp (kan tilpasses i framework/vrp.lua)
-- "custom"     → Dit eget custom framework (rediger framework/custom.lua)
-- "standalone" → vanilla FiveM
Config.framework = "auto"

-- ── GENERELT ──────────────────────────────────────────
Config.general = {
    openCommand = "mtncadmin",     -- Primær kommando (også /mtncmenu og /admin)
    hotkey      = 104,             -- Numpad 8 (eller konfigurerbar F10)
    uiTitle     = "MTNC Admin Tablet",
    closeKey    = 322,             -- ESC
    notifySound = true,
    debug       = false
}

-- ── DATABASE ──────────────────────────────────────────
-- Bruger automatisk MySQL-forbindelsen fra server.cfg via oxmysql.
Config.database = {
    driver      = "oxmysql",
    autoInstall = true,
    autoMigrate = true
}

-- ── PERMISSIONS ───────────────────────────────────────
Config.permissions = {
    allowAll             = false,
    allowedSteamIds      = {},
    esxGroups            = { "superadmin", "admin", "moderator" },
    qbRoles              = { "god", "admin" },
    acePermission        = "mtnc.admin",
    enableFrameworkCheck = true
}

-- ── KATEGORIER OG HANDLINGER ──────────────────────────
Config.categories = {
    players   = true,
    vehicles  = true,
    world     = true,
    economy   = true,
    staff     = true,
    logs      = true,
    reports   = true,
    resources = true
}

Config.weatherTypes = {
    "CLEAR", "EXTRASUNNY", "CLOUDS", "OVERCAST",
    "RAIN", "THUNDER", "FOGGY", "SNOWLIGHT", "BLIZZARD"
}
