fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'mtnc-adminpanel'
author 'NovaCore & MTCore (MrWolfDk & MrGuld)'
description 'MTNC AdminPanel & Tablet V3 — Enterprise Multi-Framework System'
version '3.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

shared_scripts {
    'config.lua',
    'apiconnect.lua'
}

client_scripts {
    'client/core/utils.lua',
    'client/core/nui.lua',
    'client/main.lua'
}

server_scripts {
    'licensekey.lua',
    'server/database/schema.lua',
    'server/database/migrations.lua',
    'server/database/db.lua',
    'server/database/connection.lua',
    'server/database/installer.lua',
    'server/core/utils.lua',
    'server/core/logger.lua',
    'server/core/security.lua',
    'server/core/permissions.lua',
    'server/core/events.lua',
    'server/core/main.lua',
    'server/framework/framework.lua',
    'server/framework/qbcore.lua',
    'server/framework/qbox.lua',
    'server/framework/esx.lua',
    'server/framework/vrp.lua',
    'server/framework/standalone.lua',
    'server/framework/custom.lua',
    'server/framework/bridge.lua',
    'server/api/authentication.lua',
    'server/api/connection.lua',
    'server/api/heartbeat.lua',
    'server/license/integration.lua',
    'server/housing/housing.lua',
    'server/phone/phone.lua',
    'server/economy/manager.lua',
    'server/vehicles/manager.lua',
    'server/players/identifiers.lua',
    'server/players/manager.lua',
    'server/punishments/manager.lua',
    'server/reports/manager.lua',
    'server/resources/manager.lua',
    'server/staff/manager.lua',
    'server/logs/audit.lua',
    'server/updates/github.lua',
    'server/updates/updater.lua',
    'server/players.lua',
    'server/economy.lua',
    'server/vehicles.lua',
    'server/world.lua',
    'server/reports.lua',
    'server/logs.lua',
    'server/main.lua'
}

-- SIKKERHEDSFILER DER ER KRYPTERET OG BESKYTTET:
-- server/api/*, server/license/*, server/main.lua, client/main.lua, client/core/*, server/core/* (UNDTAGEN server/core/events.lua)
escrow_ignore {
    'config.lua',
    'licensekey.lua',
    'apiconnect.lua',
    'README.md',
    'html/*',
    'server/core/events.lua',
    'server/database/*',
    'server/economy/*',
    'server/framework/*',
    'server/housing/*',
    'server/logs/*',
    'server/phone/*',
    'server/players/*',
    'server/punishments/*',
    'server/reports/*',
    'server/resources/*',
    'server/staff/*',
    'server/updates/*',
    'server/vehicles/*',
    'server/players.lua',
    'server/economy.lua',
    'server/vehicles.lua',
    'server/world.lua',
    'server/reports.lua',
    'server/logs.lua'
}
