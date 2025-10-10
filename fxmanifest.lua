name "Jim-Shops"
author "Jimathy"
version "3.0.09"
description "Shop Script"
fx_version "cerulean"
game "gta5"
lua54 'yes'

server_script '@oxmysql/lib/MySQL.lua'

shared_scripts {
	--'locales/*.lua',
	'config.lua',

    --Jim Bridge - https://github.com/jimathy/jim_bridge
    '@jim_bridge/starter.lua',

	'shared/*.lua',
}
client_scripts {
    'client/*.lua'
}

server_script 'server/*.lua'

files {
    'images/**.*',
}

dependency 'jim_bridge'