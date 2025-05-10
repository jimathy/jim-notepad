name "Jim-Notepad"
author "Jimathy"
version "2.0"
description "Notepad Script"
fx_version "cerulean"
game "gta5"
lua54 'yes'

server_script '@oxmysql/lib/MySQL.lua'

shared_scripts {
	'locales/*.lua',
	'config.lua',

    --Jim Bridge
    '@jim_bridge/starter.lua',
}
client_scripts {
    'client.lua'
}

server_script 'server.lua'

dependency 'jim_bridge'