fx_version 'cerulean'
game 'gta5'

author 'Votre Nom'
description 'Système bancaire pour FiveM compatible avec ESX et jaksam_core'
version '1.2.0'

shared_scripts {
    'bridge.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/style.css',
    'html/script.js'
}
