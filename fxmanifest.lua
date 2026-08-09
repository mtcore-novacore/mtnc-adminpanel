--[[
  ███╗   ███╗████████╗███╗   ██╗ ██████╗
  ████╗ ████║╚══██╔══╝████╗  ██║██╔════╝
  ██╔████╔██║   ██║   ██╔██╗ ██║██║
  ██║╚██╔╝██║   ██║   ██║╚██╗██║██║
  ██║ ╚═╝ ██║   ██║   ██║ ╚████║╚██████╗
  ╚═╝     ╚═╝   ╚═╝   ╚═╝  ╚═══╝ ╚═════╝

  MTNC AdminPanel v2.5.0 — fxmanifest.lua
  Modular Architecture & Encryption-Ready
--]]

fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

author 'NovaCore-MTCore'
description 'MTNC AdminPanel — Modular Multi-Framework FiveM Administration System'
version '2.5.0'

dependency 'oxmysql'

-- ── FIVE M ESCROW / KRYPTERING IGNORE LISTE ──
-- Disse filer forbliver ÅBNE og krypteres IKKE af FiveM Escrow / Tebex / Obfuscators
escrow_ignore {
  'config.lua',
  'licensekey.lua',
  'apiconnect.lua',
  'KRYPTERINGSGUIDE.md',
  -- Åbne Framework Adaptere
  'client/framework/qbcore.lua',
  'client/framework/qbox.lua',
  'client/framework/esx.lua',
  'client/framework/vrp.lua',
  'client/framework/standalone.lua',
  'client/framework/custom.lua',
  'client/framework/bridge.lua',
  'server/framework/qbcore.lua',
  'server/framework/qbox.lua',
  'server/framework/esx.lua',
  'server/framework/vrp.lua',
  'server/framework/standalone.lua',
  'server/framework/custom.lua',
  'server/framework/bridge.lua',
  -- NUI Brugerflade
  'html/index.html',
  'html/style.css',
  'html/app.js'
}

-- ── ÅBNE / OFFENTLIGE SCRIPTS ──
shared_scripts {
  'config.lua',
  'apiconnect.lua'
}

-- ── CLIENT-SIDE SCRIPTS ──
client_scripts {
  'config.lua',
  'apiconnect.lua',
  -- Åbne Framework Adaptere (Kan frit tilpasses)
  'client/framework/qbcore.lua',
  'client/framework/qbox.lua',
  'client/framework/esx.lua',
  'client/framework/vrp.lua',
  'client/framework/standalone.lua',
  'client/framework/custom.lua',
  'client/framework/bridge.lua',
  -- Core & Features (Krypteres)
  'client/core/utils.lua',
  'client/core/nui.lua',
  'client/features/vehicles.lua',
  'client/features/staff.lua',
  'client/features/noclip.lua',
  'client/features/world.lua',
  'client/commands/admin.lua',
  'client/core/events.lua',
  'client/core/main.lua',
}

-- ── SERVER-SIDE SCRIPTS ──
server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'licensekey.lua',
  'config.lua',
  'apiconnect.lua',
  -- Åbne Framework Adaptere (Kan frit tilpasses)
  'server/framework/qbcore.lua',
  'server/framework/qbox.lua',
  'server/framework/esx.lua',
  'server/framework/vrp.lua',
  'server/framework/standalone.lua',
  'server/framework/custom.lua',
  'server/framework/bridge.lua',
  -- Core & Sikkerhed (Krypteres)
  'server/core/logger.lua',
  'server/core/utils.lua',
  'server/core/security.lua',
  'server/core/permissions.lua',
  -- Database engine (Krypteres)
  'server/database/schema.lua',
  'server/database/connection.lua',
  'server/database/migrations.lua',
  'server/database/installer.lua',
  -- License & API gateway (Krypteres)
  'server/license/integration.lua',
  'server/api/authentication.lua',
  'server/api/connection.lua',
  'server/api/heartbeat.lua',
  -- GitHub update checker (Krypteres)
  'server/updates/github.lua',
  -- Feature managers (Krypteres)
  'server/logs/audit.lua',
  'server/players/identifiers.lua',
  'server/players/manager.lua',
  'server/punishments/manager.lua',
  'server/reports/manager.lua',
  'server/vehicles/manager.lua',
  'server/economy/manager.lua',
  'server/staff/manager.lua',
  'server/resources/manager.lua',
  -- Events router & main coordinator (Krypteres)
  'server/core/events.lua',
  'server/core/main.lua',
}

-- ── EXPORTS TIL EKSTERNE SCRIPTS ──
server_exports {
  'Analyse',
  'GetSystemAnalysis',
  'HasPermission',
  'GetPlayerRole',
  'SendAuditLog',
  'TriggerSos',
  'KickPlayer',
  'BanPlayer',
  'HealPlayer',
  'GiveMoney'
}

exports {
  'OpenAdminMenu',
  'CloseAdminMenu',
  'ToggleNoclip',
  'IsNoclipActive',
  'AnalyseClient'
}

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/style.css',
  'html/app.js'
}
