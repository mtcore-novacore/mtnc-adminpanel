-- ============================================================
-- MTNC ADMIN TABLET v3.0.2
-- PRODUCTION MASTER RELEASE
-- ============================================================
-- Developed by: NovaCore x MTCore
-- Lead Developers: MrWolfDk & MrGuld
-- Copyright (c) 2026 NovaCore x MTCore. All Rights Reserved.
-- ============================================================

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'MTNC Admin Tablet'
author 'NovaCore x MTCore (MrWolfDk & MrGuld)'
version '3.0.2'
description 'MTNC Admin Tablet v3.0.2 - Professional In-Game Tablet OS (c) 2026 NovaCore x MTCore'

ui_page 'nui/index.html'

shared_scripts {
    'config/config.lua',
    'config/permissions.lua',
    'config/integrations.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/db.lua',
    'licensekey.lua',
    'integrations/framework/qbcore.lua',
    'integrations/framework/qbox.lua',
    'integrations/framework/esx.lua',
    'integrations/framework/vrp.lua',
    'integrations/phone/lb-phone.lua',
    'integrations/housing/housing.lua',
    'integrations/vehicles/vehicles.lua',
    'server/audit.lua',
    'server/security.lua',
    'server/permissions.lua',
    'server/license.lua',
    'server/jobs.lua',
    'server/photos.lua',
    'server/phone.lua',
    'server/reports.lua',
    'server/updates.lua',
    'server/main.lua'
}

client_scripts {
    'client/admin_features.lua',
    'client/camera.lua',
    'client/notifications.lua',
    'client/tablet.lua',
    'client/main.lua'
}

files {
    'nui/index.html',
    'nui/css/style.css',
    'nui/css/apps.css',
    'nui/js/locales.js',
    'nui/js/api.js',
    'nui/js/apps.js',
    'nui/js/app.js'
}
