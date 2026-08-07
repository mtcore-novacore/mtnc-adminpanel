fx_version 'cerulean'
games { 'gta5' }

author 'NovaCore-MTCore'
description 'A panel supports vrp-esx-qbcore'
version '1.0.0'

client_script 'client.lua'

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  'config.lua',
  'server/*.lua'
}
