author 'MGDev - McDo™'
discord 'https://discord.gg/pDNVUgWt7a'
github 'https://github.com/MGDev-McDo'
tebex 'https://mgdev.tebex.io/'

fx_version 'adamant'
game 'gta5'
lua54 'yes'
version '1.0'
description 'MGDev RageUI GangBuilder w/o reboot'

shared_scripts {
    '@es_extended/imports.lua',
    'shared/*.lua'
}

client_scripts {
    'src/RageUI.lua',
    'src/Menu.lua',
    'src/MenuController.lua',
    'src/components/*.lua',
    'src/elements/*.lua',
    'src/items/*.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}