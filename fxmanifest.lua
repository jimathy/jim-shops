name "Jim-Shops"
author "Jimathy"
version "2.0.2"
description "Shop Script By Jimathy"
fx_version "cerulean"
game "gta5"
lua54 'yes'

shared_scripts { 'config.lua', 'shared/shared.lua', 'shared/products.lua', 'shared/shops.lua', 'shared/itemmodels.lua',  }
client_scripts { '@PolyZone/client.lua', '@PolyZone/BoxZone.lua', '@PolyZone/EntityZone.lua', '@PolyZone/CircleZone.lua', '@PolyZone/ComboZone.lua', 'client.lua', }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server.lua', }

--Remove if not using OX_Lib
shared_script { '@ox_lib/init.lua' }