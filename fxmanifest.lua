name "Jim-Notepad"
author "Jimathy"
version "v1.0.1"
description "Notepad Script By Jimathy"
fx_version "cerulean"
game "gta5"

dependencies { 'qb-input', 'qb-menu', 'qb-target', }

shared_scripts { 'config.lua', 'locales/*.lua', 'shared/*.lua' }

client_scripts { 'client/*.lua', }

server_script { 'server/*.lua' }

lua54 'yes'

escrow_ignore {
	'*.lua*',
	'client/*.lua*',
	'server/*.lua*',
	'locales/*.lua',
    'shared/*.lua'
}
