name "Jim-Notepad"
author "Jimathy"
version "2.0"
description "Notepad Script"
fx_version "cerulean"
game "gta5"
lua54 'yes'

shared_scripts {
	'locales/*.lua',
	'config.lua',

    -- Required core scripts
    '@ox_lib/init.lua',
    '@ox_core/lib/init.lua',

    '@es_extended/imports.lua',

    '@qbx_core/modules/playerdata.lua',

    --Jim Bridge
    '@jim_bridge/starter.lua',
}
client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client.lua'
}

server_script 'server.lua'

dependency 'jim_bridge'