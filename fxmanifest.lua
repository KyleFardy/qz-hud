fx_version 'adamant'
games { 'gta5' };
name 'qz-hud'
author 'miquelmq20'
description 'A Simple Clean Interface Hud For QBCore'
version '2.0.0'
ui_page 'html/ui.html'
files {
    'html/*.png',
    'html/img/**.png',
    'html/fonts/**.ttf',
    'html/ui.html',
    'html/script.js',
    'html/main.css'
}
client_scripts {
    'client/main.lua'
}
shared_scripts {
    'shared/config.lua'
}
server_scripts {
    'server/main.lua'
}