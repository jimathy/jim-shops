----- Changes in this version:
- Full QB and OX support for inventory, input, menu and callbacks. Config options to specify QB or OX for each
- Full support for changing QB-Core export in config so shop can easily be used with qb-core, qbx-core, or a custom one if you've renamed it
- Support in config for custom qb-menu names, so you can use qbx-menu, qb-menu or jimathy-menu etc
- Extra monetary types are possible for items besides bank and cash. You can specify an item requires a specific money type, or an entire shop. Great for crypto or dirty money sales

Full shop Sample:
```
	Config.Locations["blackmarket"] = {
		["label"] = "Black Market",
		["type"] = "items",
		["paymentType"] = {{type = "dirtymoney", text = "Dirty Money"}},
		["model"] = {
			`A_M_Y_MethHead_01`,
		},
		["coords"] = {
			vector4(776.24, 4184.08, 41.8, 92.12),
		},
		["products"] = Config.Products["blackmarket"],
		["hideblip"] = true,
	}
```
Single Item Sample:
```
		["freshfood"] = {
			{ name = "strawberry", price = 3.5, amount = 10, info = {}, paymentType = {{type = "crypto", text = "QBit Coin" }} },

```

- Licenses now allow multiple license types instead of just weapons, and only looks at the metatable
- Every license listed must be owned in order to buy the item

Sample:
```
{ name = "weapon_pistol", price = 2500, amount = 5, requiresLicense = {"weapon", "hunting"} },
```

- New parameter to check for inventory items that must be held to buy an item

Sample:
```
{ name = "weapon_pistol", price = 2500, amount = 5, requiresItem = {"huntinglicense"} },
```

- Refactored the shop building to use several if's instead of elseif so items can require multiple things, such as jobrole police & requireslicense weapon before you can buy it.

- Config.SellCasinoChips now includes chipItem for easy changing your casino chip if needed

----- Original README Information
# jim-shops
- QBCore based shops system
- Written from scratch by me, but based on `qb-shops` and `qb-menu`

### If you think I did a good job here, consider donating as it keeps by lights on and my cat fat/floofy:
https://ko-fi.com/jixelpatterns


- This script is designed to be a replacement for `QB-Shops`
- Making shops work perfectly with `QB-Menu`, `QB-Input` and `QB-Target`

---
# Installation

- I always recommend starting my scripts **AFTER** `[qb]` not inside it as it can mess with any dependancies on server load
- I have a separate folder called `[jim]` (that is also in the resources folder) that starts WAY after everything else.
- This ensure's it has everything it requires before trying to load
- Example of my load order:
```CSS
# QBCore & Extra stuff
ensure qb-core
ensure [qb]
ensure [standalone]
ensure [voice]
ensure [defaultmaps]
ensure [vehicles]

# Extra Jim Stuff
ensure [jim]
```

---
## Features
- Supports items that require jobs
- Supports Gun License being required for weapons
- Support for opening shops externally
- Ability to choose and spawn shop peds
- Stash Support, adds ability to limit purchases between restarts
- Ability to hide blips for shops, might be useful for a blackmarket shop
- Support for casino buying and selling of chips

---
## Setup a new shop
- Everything needed is in `config.lua` and its essentially the same as qb-shop's config.
- `Limit` Enable this to add Stash features, This adds limits to items in stores and gets refilled at each restart
- `MaxSlots` Set this to your player inventory slot count, this is default "41"
- `BlackMarket` Enable to add blackmarket locations (defined at the bottom of this file)
- `Measurement` Custom Weight measurement, default "kg"
- `Gabz247` Enable if using gabz 247 stores
- `GabzAmmu` Enable if using gabz Ammunation stores
- `VendOverride` -- Enable this if you want all the vending machines to use this script
- `RandomAmount` -- Sets wether a stash should have a "random" amount of stock or full.

## Examples and Explanations
![](https://user-images.githubusercontent.com/1885302/161044087-c9eb8f8d-a4a5-4174-a048-73a610231abe.jpg)
- Example of a `shop`
```lua
Locations = {
	["digitalden"] = { -- general name of the shops
		["label"] = "Digital Den", -- The label of the shop that will be seen by players
		["targetIcon"] = "fab fa-galactic-republic", -- Custom qb-target icon (default: "fas fa-cash-register")
        ["targetLabel"] = "Open Digital Den", -- Custom qb-target label (default: "Browse Shop")
		--["requiredItem"] = "phone", specify if this shop requires a certain item to be accessed (for examle:  a huntinglicense)
		--["scenario"] = "PROP_HUMAN_SEAT_CHAIR_FOOD", -- Support for specifiying specific scenarios
		["type"] = "items", -- What kind of items are in the shop
        --["job"] = "mechanic", -- Supports locking the shops to jobs's only
        --["gang"] = "lostmc", -- Supports locking the shops to gang's only
        ["killable"] = true, -- Makes it so you can kill the ped (maybe if you can rob that store)
		["model"] = { -- A list of possible PED models for the shop to spawn
			`sf_prop_sf_vend_drink_01a`, -- You can specfiy props and it will load these instead of a ped model
			`S_M_M_LifeInvad_01`,
			`IG_Ramp_Hipster`,
			`A_M_Y_Hipster_02`,
			`A_F_Y_Hipster_01`,
			`IG_LifeInvad_01`,
			`IG_LifeInvad_02`,
			`CS_LifeInvad_01`,
		},
		["logo"] = "https://static.wikia.nocookie.net/gtawiki/images/b/b5/DigitalDen-GTAV-Logo.png", -- customisable html link to a shop logo png
		["coords"] = { -- All the locations these shops will spawn
			vector4(391.76, -832.79, 29.29, 223.77), -- vector4 is a vector3 with the heading as the last nubmer
			vector4(1136.99, -473.13, 66.53, 254.85),
			vector4(-509.55, 278.63, 83.31, 176.65),
			vector4(-656.27, -854.73, 24.5, 359.39),
			vector4(-1088.29, -254.3, 37.76, 252.7),
		},
		["products"] = Config.Products["electronics"], -- The list of products will appear in the shop
		["blipsprite"] = 619, -- The blip that will appear on the map for this shop
		["blipcolour"] = 7, -- https://docs.fivem.net/docs/game-references/blips/
        ["hideblip"] = false, -- set to true if you want this shop to be hidden on the map (good for illegal shops)
	},
}
```
- Example of a `product` table
```lua
Products = {
    ["electronics"] = { -- The name of the table to be called by a shop
        { name = "phone", price = 850, amount = 50 }, -- spawn name of item, cost of item, amount in the shop
        { name = "radio", price = 250, amount = 50, requiredJob = { ["mechanic"] = 0 } }, -- Supports job + grade lock of specifc items
        { name = "screwdriverset", price = 350, amount = 50, requiredGang = { "lostmc" } },
        { name = "binoculars", price = 50, amount = 50, },
        { name = "fitbit", price = 400, amount = 150, },
    },
}
```
- Additional Items
```lua
["sprunk"] = {["name"] = "sprunk", ["label"] = "Sprunk", ["weight"] = 100, ["type"] = "item", ["image"] = "sprunk.png", ["unique"] = false, ["useable"] = true,     ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "", ['thirst'] = math.random(20, 30) },
["sprunklight"] = {["name"] = "sprunklight", ["label"] = "Sprunk Light", ["weight"] = 100, ["type"] = "item", ["image"] = "sprunklight.png", ["unique"] = false,     ["useable"] = true, ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "", ['thirst'] = math.random(20, 30) },
["ecola"] = {["name"] = "ecola", ["label"] = "eCola", ["weight"] = 100, ["type"] = "item", ["image"] = "ecola.png", ["unique"] = false, ["useable"] = true,     ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "", ['thirst'] = math.random(20, 30) },
["ecolalight"] = {["name"] = "ecolalight", ["label"] = "eCola Light", ["weight"] = 100, ["type"] = "item", ["image"] = "ecolalight.png", ["unique"] = false,     ["useable"] = true, ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "", ['thirst'] = math.random(20, 30) },
```
---
## Support for external shops
- You can easily change shops created in other scripts by swapping out the inventory event with my custom event
    - If you have a script that opens a shop, you can swap out the event `inventory:server:OpenInventory` for `jim-shops:ShopOpen` and it will open in my shop layout instead of the default inventory layout
    - All my scripts have an option to toggle this in the config
    - But it's very unlikely someone elses script won't
- For example:
- in `qb-ambulancejob > client > job.lua` there is the event
```lua
RegisterNetEvent('qb-ambulancejob:armory', function()
    if onDuty then
        TriggerServerEvent("inventory:server:OpenInventory", "shop", "hospital", Config.Items)
    end
end)
```
- Simply changing the event name from `inventory:server:OpenInventory` to `jim-shops:ShopOpen` will make it use my script instead
```lua
RegisterNetEvent('qb-ambulancejob:armory', function()
    if onDuty then
        TriggerServerEvent("jim-shops:ShopOpen", "shop", "hospital", Config.Items)
    end
end)
```
