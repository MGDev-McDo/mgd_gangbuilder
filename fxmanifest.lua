author 'MGDev - McDo™'
discord 'https://discord.com/invite/9t2ZxNkvjq'
github 'https://github.com/MGDev-McDo'
tebex 'https://mgdev.tebex.io/'

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
version '2.0'
description 'MGDev RageUI GangBuilder w/o reboot'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'shared/locale.lua',
    'shared/shared.lua'
}

client_scripts {
    'src/RageUI.lua',
    'src/Menu.lua',
    'src/MenuController.lua',
    'src/components/*.lua',
    'src/elements/*.lua',
    'src/items/*.lua',
    'client/main.lua',
    'client/builder.lua',
    'client/boss.lua',
    'client/garage.lua',
    'client/inventory.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

dependencies {
    'ox_lib',
    'ox_target',
    'oxmysql',
    'es_extended',
    'esx_datastore'
} 