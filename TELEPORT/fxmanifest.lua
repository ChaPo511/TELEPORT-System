fx_version 'bodacious'
games { 'gta5' }

author 'TELEPORT | discord.gg/lodstudio'
description 'Kortz Estate Scripts'
version '1.0.2'

lua54 'yes'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/css/style.css',
    'ui/js/script.js'
}

shared_scripts {
    '@oxmysql/lib/MySQL.lua'
}

client_scripts {
    'config.lua',
    'client/client.lua'
}

server_scripts {
    'server/vector_fix.lua',
    'config.lua',
    'server/server.lua'
}

escrow_ignore {
  'config.lua',
}
