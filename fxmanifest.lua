fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
author 'Haxalott'
description 'Tebex system for FiveM'
version '1.0.0'

client_scripts {
    'client/cl_*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_*.lua',
    'config.lua'
}

shared_scripts {
    '@ox_lib/init.lua'
}

dependencies {
    'ox_lib',
    'oxmysql'
}