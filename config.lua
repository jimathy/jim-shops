print("Jim-Shops - Shop Script by Jimathy")

-- If you need support I now have a discord available, it helps me keep track of issues and give better support.

-- https://discord.gg/xKgQZ6wZvS

Config = {}

Config.Debug = false

Config.img = "qb-inventory/html/images/"

Config.Products = {
    ["normal"] = {
        [1] = { 
			name = "tosti", price = 2, amount = 50, info = {}, type = "item", slot = 1, },
        [2] = { 
			name = "water_bottle", price = 2, amount = 50, info = {}, type = "item", slot = 2, },
        [3] = { 
			name = "kurkakola", price = 2, amount = 50, info = {}, type = "item", slot = 3, },
        [4] = { 
			name = "twerks_candy", price = 2, amount = 50, info = {}, type = "item", slot = 4, },
        [5] = {
            name = "snikkel_candy", price = 2, amount = 50, info = {}, type = "item", slot = 5, },
        [6] = { 
			name = "sandwich", price = 2, amount = 50, info = {}, type = "item", slot = 6, },
        [7] = {
            name = "beer", price = 7, amount = 50, info = {}, type = "item", slot = 7, },
        [8] = {
            name = "whiskey", price = 10, amount = 50, info = {}, type = "item", slot = 8, },
        [9] = {
            name = "vodka", price = 12, amount = 50, info = {}, type = "item", slot = 9, },
        [10] = {
            name = "bandage", price = 100, amount = 50, info = {}, type = "item", slot = 10, },
        [11] = {
            name = "lighter", price = 2, amount = 50, info = {}, type = "item", slot = 11, },
        [12] = {
            name = "rolling_paper", price = 2, amount = 5000, info = {}, type = "item", slot = 12, },
    },
    ["hardware"] = {
        [1] = { 
			name = "lockpick", price = 200, amount = 50, info = {}, type = "item", slot = 1, },
        [2] = {
            name = "weapon_wrench", price = 250, amount = 250, info = {}, type = "item", slot = 2, },
        [3] = { 
			name = "weapon_hammer", price = 250, amount = 250, info = {}, type = "item", slot = 3, },
        [4] = {
            name = "repairkit", price = 250, amount = 50, info = {}, type = "item", slot = 4, requiredJob = { "mechanic", "police" } },
        [5] = {
			name = "screwdriverset", price = 350, amount = 50, info = {}, type = "item", slot = 5, },
        [6] = {
            name = "phone", price = 850, amount = 50, info = {}, type = "item", slot = 6, },
        [7] = {
            name = "radio", price = 250, amount = 50, info = {}, type = "item", slot = 7, },
        [8] = {
            name = "binoculars", price = 50, amount = 50, info = {}, type = "item", slot = 8, },
        [9] = {
            name = "firework1", price = 50, amount = 50, info = {}, type = "item", slot = 9, },
        [10] = {
            name = "firework2", price = 50, amount = 50, info = {}, type = "item", slot = 10, },
        [11] = {
            name = "firework3", price = 50, amount = 50, info = {}, type = "item", slot = 11, },
        [12] = {
            name = "firework4", price = 50, amount = 50, info = {}, type = "item", slot = 12, },
        [13] = {
            name = "fitbit", price = 400, amount = 150, info = {}, type = "item", slot = 13, },
        [14] = {
            name = "cleaningkit", price = 150, amount = 150, info = {}, type = "item", slot = 14, },
        [15] = {
            name = "advancedrepairkit", price = 500, amount = 50, info = {}, type = "item", slot = 15, requiredJob = { "mechanic" } },        
    },
    ["weedshop"] = {
        [1] = { 
			name = "joint", price = 10, amount = 1000, info = {}, type = "item", slot = 1, },
        [2] = {
            name = "weapon_poolcue", price = 100, amount = 1000, info = {}, type = "item", slot = 2, },
        [3] = {
            name = "weed_nutrition", price = 20, amount = 1000, info = {}, type = "item", slot = 3, },
        [4] = { 
			name = "empty_weed_bag", price = 2, amount = 1000, info = {}, type = "item", slot = 4, },
        [5] = {
            name = "rolling_paper", price = 2, amount = 1000, info = {}, type = "item", slot = 5, },
    },
    ["gearshop"] = {
        [1] = { 
			name = "diving_gear", price = 2500, amount = 10, info = {}, type = "item", slot = 1, },
        [2] = {
            name = "jerry_can", price = 200, amount = 50, info = {}, type = "item", slot = 2, },
    },
    ["leisureshop"] = {
        [1] = {
            name = "parachute", price = 2500, amount = 10, info = {}, type = "item", slot = 1 },
        [2] = {
            name = "binoculars", price = 50, amount = 50, info = {}, type = "item", slot = 2, },    
        [3] = {
            name = "diving_gear", price = 2500, amount = 10, info = {}, type = "item", slot = 3, },
    },
    ["weapons"] = {
        [1] = {
            name = "weapon_knife", price = 250, amount = 250, info = {}, type = "item", slot = 1, },
        [2] = {
            name = "weapon_bat", price = 250, amount = 250, info = {}, type = "item", slot = 2, },
        [3] = {
            name = "weapon_hatchet",price = 250, amount = 250, info = {}, type = "item", slot = 3, requiredJob = { "mechanic", "police" } },
        [4] = {
            name = "weapon_pistol", price = 2500, amount = 5, info = {}, type = "item", slot = 4, requiresLicense = true },
        [5] = {
            name = "weapon_snspistol", price = 1500, amount = 5, info = {}, type = "item", slot = 5, requiresLicense = true },
        [6] = {
            name = "weapon_vintagepistol", price = 4000, amount = 5, info = {}, type = "item", slot = 6, requiresLicense = true },
        [7] = {
            name = "pistol_ammo", price = 250, amount = 250, info = {}, type = "item", slot = 7, requiresLicense = true },
    },
    ["coffeeplace"] = {
        [1] = {
            name = "coffee", price = 5, amount = 500, info = {}, type = "item", slot = 1, },
        [2] = {
            name = "lighter", price = 2, amount = 50, info = {}, type = "item", slot = 2, },
    },
    ["casino"] = {
        [1] = {
            name = 'casinochips', price = 100, amount = 999999, info = {}, type = 'item', slot = 1, }
    },
}

Config.Locations = {
    -- 24/7 Locations
    ["247supermarket"] = {
        ["label"] = "24/7 Supermarket",
		["logo"] = "https://i.imgur.com/bPcM0TM.png",
        ["coords"] = {
			vector3(26.19, -1346.82, 29.5), 
			vector3(-3040.18, 585.94, 7.91), 
			vector3(-3242.75, 1001.74, 12.83), 
			vector3(1729.58, 6414.85, 35.04), 
			vector3(1698.57, 4924.01, 42.06),
			vector3(1961.29, 3741.36, 32.34),
			vector3(547.43, 2670.52, 42.16), 
			vector3(2678.44, 3281.25, 55.24), 
			vector3(2556.59, 382.55, 108.62), 
			vector3(374.4, 326.57, 103.57), 
		},
        ["products"] = Config.Products["normal"],
        ["blipsprite"] = 52
    },	
    -- LTD Gasoline Locations
    ["ltdgasoline"] = {
        ["label"] = "LTD Gasoline",
		["logo"] = "https://static.wikia.nocookie.net/gtawiki/images/7/72/LTD-GTAO-LSTunersBanner.png",
        ["coords"] = {
			vector3(-47.82, -1757.34, 29.42),
			vector3(-707.42, -913.87, 19.22),
			vector3(-1820.77, 793.15, 138.11),
			vector3(1163.49, -323.07, 69.21),
		},
        ["products"] = Config.Products["normal"],
        ["blipsprite"] = 52
    },
    -- Rob's Liquor Locations
    ["robsliquor"] = {
        ["label"] = "Rob's Liqour",
		["logo"] = "https://static.wikia.nocookie.net/gtawiki/images/d/de/RebsLiquor-GTAV.png",
        ["coords"] = {
			vector3(-1222.77, -907.19, 12.32),
			vector3(-1487.7, -378.53, 40.16),
			vector3(-2967.79, 391.64, 15.04),
			vector3(1165.28, 2709.4, 38.15),
			vector3(1135.66, -982.76, 46.41),
		},
        ["products"] = Config.Products["normal"],
        ["blipsprite"] = 52
    },	
    -- Hardware Store Locations
    ["hardware"] = {
        ["label"] = "Hardware Store",
        ["coords"] = {
			vector3(45.82, -1749.08, 29.62),
			vector3(2747.81, 3472.86, 55.67),
			vector3(-421.67, 6135.98, 31.88),
		},
        ["products"] = Config.Products["hardware"],
        ["blipsprite"] = 402
    },
	-- Ammunation VANILLA Locations
    ["ammunation"] = {
        ["label"] = "Ammunation",
		["logo"] = "https://static.wikia.nocookie.net/gtawiki/images/a/aa/Ammunation-GTAV.png",
        ["coords"] = {
            vector3(-662.1, -935.3, 21.8),
            vector3(810.2, -2157.3, 29.6),
			vector3(1693.4, 3759.5, 34.7),
            vector3(-330.2, 6083.8, 31.4),
			vector3(252.3, -50.0, 69.9),
			vector3(22.0, -1107.2, 29.8),
            vector3(2567.6, 294.3, 108.7),
            vector3(-1117.5, 2698.6, 18.5),
            vector3(842.4, -1033.4, 28.1),
		},
        ["products"] = Config.Products["weapons"],
        ["blipsprite"] = 110
    },
--[[
    -- Ammunation GABZ Locations
    ["ammunation"] = {
        ["label"] = "Ammunation",
		["logo"] = "https://static.wikia.nocookie.net/gtawiki/images/a/aa/Ammunation-GTAV.png",
        ["coords"] = {
            vector3(-660.93, -939.74, 21.83),
			vector3(813.39, -2153.58, 29.62),
			vector3(1697.11, 3755.97, 34.71),
			vector3(-327.21, 6079.98, 31.45),
			vector3(247.45, -49.76, 69.94),
			vector3(17.76, -1109.53, 29.8),
			vector3(2566.56, 298.98, 108.73),
			vector3(-1113.79, 2696.16, 18.55),
			vector3(842.83, -1028.51, 28.19),
		},
        ["products"] = Config.Products["weapons"],
        ["blipsprite"] = 110
    },
]]
    -- Casino Locations
    ["casino"] = {
        ["label"] = "Diamond Casino",
        ["coords"] = { vector3(948.66, 33.85, 71.84), },
        ["products"] = Config.Products["casino"],
        ["blipsprite"] = 617
    },
    ["casino2"] = {
        ["label"] = "Casino Bar",
        ["coords"] = { vector3(936.31, 28.5, 71.83), },
        ["products"] = Config.Products["normal"],
        ["blipsprite"] = 52
    },

    -- Weedshop Locations
    ["weedshop"] = {
        ["label"] = "Smoke on the Water",
        ["coords"] = { vector3(-1171.99, -1571.93, 4.66), },
        ["products"] = Config.Products["weedshop"],
        ["blipsprite"] = 140
    },

    -- Bean Coffee Locations
    ["beancoffee"] = {
        ["label"] = "Bean Machine Coffee",
        ["coords"] = { vector3(-633.72, 236.15, 81.88), },
        ["products"] = Config.Products["coffeeplace"],
        ["blipsprite"] = 52
    },

    -- Sea Word Locations
    ["seaworld"] = {
        ["label"] = "Sea World",
        ["coords"] = { vector3(-1686.9, -1072.23, 13.15), },
        ["products"] = Config.Products["gearshop"],
        ["blipsprite"] = 52
    },

    -- Leisure Shop Locations
    ["leisureshop"] = {
        ["label"] = "Leisure Shop",
        ["coords"] = { vector3(-1505.91, 1511.78, 115.29), },
        ["products"] = Config.Products["leisureshop"],
        ["blipsprite"] = 52
    },

    -- Local Store Locations
    ["delvecchioliquor"] = {
        ["label"] = "Del Vecchio Liquor",
        ["coords"] = { vector3(-159.36, 6321.59, 31.58), },
        ["products"] = Config.Products["normal"],
        ["blipsprite"] = 52
    },
    ["donscountrystore"] = {
        ["label"] = "Don's Country Store",
        ["coords"] = { vector3(161.41, 6640.78, 31.69), },
        ["products"] = Config.Products["normal"],
        ["blipsprite"] = 52
    },
}