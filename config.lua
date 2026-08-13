--[[
  ███╗   ███╗████████╗███╗   ██╗ ██████╗
  ████╗ ████║╚══██╔══╝████╗  ██║██╔════╝
  ██╔████╔██║   ██║   ██╔██╗ ██║██║
  ██║╚██╔╝██║   ██║   ██║╚██╗██║██║
  ██║ ╚═╝ ██║   ██║   ██║ ╚████║╚██████╗
  ╚═╝     ╚═╝   ╚═╝   ╚═╝  ╚═══╝ ╚═════╝

  MTNC AdminPanel v3.0.0 — NovaCore & MTCore
  Public Configuration File
--]]

Config = {}

Config.version = "3.0.0"

-- ── FRAMEWORK INTEGRATION ────────────────────────────
-- "auto"       → Detekterer automatisk qb-core, qbx_core, es_extended, vrp
-- "qbcore"     → qb-core
-- "qbox"       → qbx_core
-- "esx"        → es_extended
-- "vrp"        → vrp
-- "standalone" → vanilla FiveM
Config.framework = "auto"

-- ── SCRIPT ADAPTER INTEGRATIONER ──────────────────────
-- 📱 Telefon Integration (Henter automatisk nummer, beskeder & PIN fra databasen)
Config.Phone = "auto" -- "auto", "lb-phone", "qs-smartphone", "gksphone", "qb-phone", "esx_phone"

-- 🏠 Housing Integration (Henter automatisk ejendomme, ejere, tier & dør-låse)
Config.Housing = "auto" -- "auto", "esx_property", "qb-houses", "ps-housing", "loaf_housing", "qs-housing"

-- 📦 Inventar Integration (Henter automatisk spillerinventar, stashes, trunks & gloveboxes)
Config.Inventory = "auto" -- "auto", "ox_inventory", "qb-inventory", "qs-inventory", "esx_inventory"

-- ── CONFIG STAFF OPBYGNING ────────────────────────────
-- Staff tilføjes uden PIN-krav ved opstart, tildeles automatisk standard PIN "1234"
Config.Staff = {
    ["discord:3928192847291823"] = "SUPERADMIN",
}

-- ── GENERELT & TABLET ──────────────────────────────────
Config.general = {
    openCommand  = "mtncadmin",     -- Primær admin kommando (/admin /tablet)
    playerTablet = "profile",       -- Åbn spiller-profil for alle spillere via /tablet
    hotkey       = 104,             -- Numpad 8
    uiTitle      = "MTNC ADMIN TABLET",
    closeKey     = 322,             -- ESC
    notifySound  = true,
    debug        = false
}

-- ── DATABASE ──────────────────────────────────────────
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
    dashboard = true,
    players   = true,
    vehicles  = true,
    world     = true,
    inventory = true,
    economy   = true,
    tickets   = true,
    activity  = true,
    logs      = true,
    staff     = true,
    resources = true,
    developer = true,
    housing   = true,
    phone     = true,
    settings  = true,
}

Config.weatherTypes = {
    "CLEAR", "EXTRASUNNY", "CLOUDS", "OVERCAST",
    "RAIN", "THUNDER", "FOGGY", "SNOWLIGHT", "BLIZZARD"
}
