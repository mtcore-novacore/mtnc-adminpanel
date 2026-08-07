fx_version 'cerulean'
games { 'gta5' }

author 'NovaCore-MTCore'
description 'A panel supports vrp-esx-qbcore'
version '1.0.0'

client_scripts {
  'config.lua',
  'client/main.lua'
}

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  'config.lua',
  'server/*.lua'
}

ui_page 'ui/ui.html'

files {
  'ui/ui.html',
  'ui/assets/style.css',
  'ui/assets/script.js'
}
