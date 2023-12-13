name "Jim-Shops"
author "Jimathy"
version "2.1"
description "Shop Script By Jimathy"
fx_version "cerulean"
game "gta5"
lua54 'yes'

shared_scripts { 'config.lua', 'shared/*.lua',  }
client_scripts { '@PolyZone/client.lua', '@PolyZone/BoxZone.lua', '@PolyZone/EntityZone.lua', '@PolyZone/CircleZone.lua', '@PolyZone/ComboZone.lua', 'client.lua', }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server.lua', }

shared_script '@ox_lib/init.lua'

--client_script '@warmenu/warmenu.lua'