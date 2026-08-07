fx_version 'cerulean'
games { 'gta5' }

author 'NovaCore-MTCore'
description 'MTNC Admin Panel — Remote Hosted NUI Admin Menu'
version '2.5.0'

client_scripts {
  'config.lua',
  'client/main.lua',
  'client/vehicles.lua',
  'client/staff.lua',
}

server_scripts {
  'licensekey.lua',
  'config.lua',
  'server/main.lua',
  'server/players.lua',
  'server/world.lua',
  'server/economy.lua',
  'server/logs.lua',
}

-- Hosted NUI Web Application URL (webserver)
ui_page 'http://127.0.0.1:3009/nui'
