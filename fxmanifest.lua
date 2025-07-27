fx_version 'cerulean'
game 'gta5'

author 'jxroo'
description 'Catalytic Converter Theft System (Secured & Optimized)'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_script 'client/main.lua'
server_script 'server/main.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'sounds/cutting.ogg',
    'locales/pl.lua'
}