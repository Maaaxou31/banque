fx_version 'cerulean'
game 'gta5'

author 'Votre Nom'
description 'Système bancaire pour FiveM compatible avec ESX (es_extended)'
version '1.1.0'

shared_scripts {
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
