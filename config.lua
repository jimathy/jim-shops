print("Jim-Shops v1.5 - Shop Script by Jimathy")

-- If you need support I now have a discord available, it helps me keep track of issues and give better support.

-- https://discord.gg/xKgQZ6wZvS

Config = {
	Debug = false, -- Enable to add debug boxes and message.
	img = "qb-inventory/html/images/", -- Set this to your inventory
	Peds = true, -- Set to true if you want Shops to have Peds
	Limit = false, -- Enable this to add Stash features, This adds limits to items and gets refilled at each restart
	MaxSlots = 41, -- Set this to your player inventory slot count, this is default "41"
	BlackMarket = false, -- enable to add blackmarket locations (defined at the bottom of this file)
	Measurement = "kg", -- Custom Weight measurement
	JimMenu = false, -- Enable this if you are using my customised qb-menu resource
}

Config.Products = {
    ["normal"] = {
		[1] = { name = "tosti", price = 2, amount = 50, info = {} },
        [2] = { name = "water_bottle", price = 2, amount = 50, info = {} },
        [3] = { name = "kurkakola", price = 2, amount = 50, info = {} },
        [4] = { name = "twerks_candy", price = 2, amount = 50, info = {} },
        [5] = { name = "snikkel_candy", price = 2, amount = 50, info = {} },
        [6] = { name = "sandwich", price = 2, amount = 50, info = {} },
        [7] = { name = "beer", price = 7, amount = 50, info = {} },
        [8] = { name = "whiskey", price = 10, amount = 50, info = {} },
        [9] = { name = "vodka", price = 12, amount = 50, info = {} },
        [10] = { name = "bandage", price = 100, amount = 50, info = {} },
        [11] = { name = "lighter", price = 2, amount = 50, info = {} },
        [12] = { name = "rolling_paper", price = 2, amount = 5000, info = {} },
    },
    ["hardware"] = {
        [1] = { name = "lockpick", price = 200, amount = 50, info = {} },
        [2] = { name = "weapon_wrench", price = 250, amount = 250, info = {} },
        [3] = { name = "weapon_hammer", price = 250, amount = 250, info = {} },
        [4] = { name = "repairkit", price = 250, amount = 50, info = {}, requiredJob = { "mechanic", "police" } },
        [5] = { name = "screwdriverset", price = 350, amount = 50, info = {} },
        [6] = { name = "phone", price = 850, amount = 50, info = {} },
        [7] = { name = "radio", price = 250, amount = 50, info = {} },
        [8] = { name = "binoculars", price = 50, amount = 50, info = {} },
        [9] = { name = "firework1", price = 50, amount = 50, info = {} },
        [10] = { name = "firework2", price = 50, amount = 50, info = {} },
        [11] = { name = "firework3", price = 50, amount = 50, info = {} },
        [12] = { name = "firework4", price = 50, amount = 50, info = {} },
        [13] = { name = "fitbit", price = 400, amount = 150, info = {} },
        [14] = { name = "cleaningkit", price = 150, amount = 150, info = {} },
        [15] = { name = "advancedrepairkit", price = 500, amount = 50, info = {}, requiredJob = { "mechanic" } },
    },
    ["weedshop"] = {
        [1] = { name = "joint", price = 10, amount = 1000, info = {} },
        [2] = { name = "weapon_poolcue", price = 100, amount = 1000, info = {} },
        [3] = { name = "weed_nutrition", price = 20, amount = 1000, info = {} },
        [4] = { name = "empty_weed_bag", price = 2, amount = 1000, info = {} },
        [5] = { name = "rolling_paper", price = 2, amount = 1000, info = {} },
    },
    ["gearshop"] = {
        [1] = { name = "diving_gear", price = 2500, amount = 10, info = {} },
        [2] = { name = "jerry_can", price = 200, amount = 50, info = {} },
    },
    ["leisureshop"] = {
        [1] = { name = "parachute", price = 2500, amount = 10, info = {} },
        [2] = { name = "binoculars", price = 50, amount = 50, info = {} },    
        [3] = { name = "diving_gear", price = 2500, amount = 10, info = {} },
    },
    ["weapons"] = {
        [1] = { name = "weapon_knife", price = 250, amount = 250, info = nil },
        [2] = { name = "weapon_bat", price = 250, amount = 250, info = {} },
        [3] = { name = "weapon_hatchet",price = 250, amount = 250, info = {}, requiredJob = { "mechanic", "police" } },
        [4] = { name = "weapon_pistol", price = 2500, amount = 5, info = nil, requiresLicense = true },
        [5] = { name = "weapon_snspistol", price = 1500, amount = 5, info = nil, requiresLicense = true },
        [6] = { name = "weapon_vintagepistol", price = 4000, amount = 5, info = nil, requiresLicense = true },
        [7] = { name = "pistol_ammo", price = 250, amount = 250, info = {}, requiresLicense = true },
    },    

    ["coffeeplace"] = {
        [1] = { name = "coffee", price = 5, amount = 500 },
        [2] = { name = "lighter", price = 2, amount = 50 },
    },
    ["casino"] = {
        [1] = { name = 'casinochips', price = 100, amount = 999999 },
    },
	["electronics"] = {
        [1] = { name = "phone", price = 850, amount = 50 },
        [2] = { name = "radio", price = 250, amount = 50, },
        [3] = { name = "screwdriverset", price = 350, amount = 50, },
        [4] = { name = "binoculars", price = 50, amount = 50, },
        [5] = { name = "fitbit", price = 400, amount = 150, },
	},	
	["blackmarket"] = {
        [1] = { name = "radioscanner", price = 850, amount = 5 },
	},
}

Config.Locations = {
    -- 24/7 Locations
    ["247supermarket"] = {
        ["label"] = "24/7 Supermarket",
		["type"] = "items",
		["model"] = { 
			[1] = `mp_m_shopkeep_01`,
			[2] = `S_F_Y_Shop_LOW`,
			[3] = `S_F_Y_SweatShop_01`,
		},
		["killable"] = true,
		["logo"] = "https://i.imgur.com/bPcM0TM.png",
        ["coords"] = {
			vector4(24.5, -1346.19, 29.5, 266.78),
			vector4(-3039.91, 584.26, 7.91, 16.79),
			vector4(-3243.27, 1000.1, 12.83, 358.73),
			vector4(1728.28, 6416.03, 35.04, 242.45),
			vector4(1697.96, 4923.04, 42.06, 326.61),
			vector4(1959.6, 3740.93, 32.34, 296.84),
			vector4(549.16, 2670.35, 42.16, 92.53),
			vector4(2677.41, 3279.8, 55.24, 334.16),
			vector4(2556.19, 380.89, 108.62, 355.58),
			vector4(372.82, 327.3, 103.57, 255.46),
			vector4(161.21, 6642.32, 31.61, 223.57),
		},
        ["products"] = Config.Products["normal"],
        ["blipsprite"] = 628,
		["blipcolour"] = 2,
    },
   
	-- 24/7 GABZ Locations
--[[    ["247supermarket"] = {
        ["label"] = "24/7 Supermarket",
		["type"] = "items",
		["model"] = { 
			[1] = `mp_m_shopkeep_01`,
			[2] = `S_F_Y_Shop_LOW`,
			[3] = `S_F_Y_SweatShop_01`,
		},
		["killable"] = true,
		["logo"] = "https://i.imgur.com/bPcM0TM.png",
        ["coords"] = {
			vector4(24.91, -1346.86, 29.5, 268.37),
			vector4(-3039.64, 584.78, 7.91, 21.88),
			vector4(-3242.73, 1000.46, 12.83, 2.08),
			vector4(1728.44, 6415.4, 35.04, 243.26),
			vector4(1697.96, 4923.04, 42.06, 326.61),
			vector4(1960.26, 3740.6, 32.34, 300.45),
			vector4(548.67, 2670.94, 42.16, 101.0),
			vector4(2677.97, 3279.95, 55.24, 325.89),
			vector4(2556.8, 381.27, 108.62, 359.15),
			vector4(373.08, 326.75, 103.57, 253.14),
			vector4(161.2, 6641.74, 31.7, 221.02),
		},
        ["products"] = Config.Products["normal"],
        ["blipsprite"] = 628,
		["blipcolour"] = 2,
    },]]

    -- LTD Gasoline Locations
    ["ltdgasoline"] = {
        ["label"] = "LTD Gasoline",
		["type"] = "items",
		["model"] = { 
			[1] = `s_m_m_autoshop_02`,
			[2] = `S_F_M_Autoshop_01`,
			[3] = `S_M_M_AutoShop_01`,
			[4] = `S_M_M_Autoshop_03`,
			[5] = `IG_Benny`,
			[6] = `IG_Benny_02`,
			[7] = `MP_F_BennyMech_01`,
		},
		["logo"] = "https://static.wikia.nocookie.net/gtawiki/images/7/72/LTD-GTAO-LSTunersBanner.png",
        ["coords"] = {
			vector4(-47.42, -1758.67, 29.42, 47.26),
			vector4(-706.17, -914.64, 19.22, 88.77),
			vector4(-1819.53, 793.49, 138.09, 131.46),
			vector4(1164.82, -323.66, 69.21, 106.86),
		},
        ["products"] = Config.Products["normal"],
        ["blipsprite"] = 628,
		["blipcolour"] = 5,
    },
    -- Rob's Liquor Locations
    ["robsliquor"] = {
        ["label"] = "Rob's Liqour",
		["type"] = "items",
		["model"] = { 
			[1] = `cs_nervousron`,
			[2] = `IG_RussianDrunk`,
			[3] = `U_M_Y_MilitaryBum`,
			[4] = `A_F_M_TrampBeac_01`,
			[5] = `A_M_M_Tramp_01`,
		},
		["logo"] = "https://static.wikia.nocookie.net/gtawiki/images/d/de/RebsLiquor-GTAV.png",
        ["coords"] = {
			vector4(-1221.38, -907.89, 12.33, 27.51),
			vector4(-1486.82, -377.48, 40.16, 130.89),
			vector4(-2966.41, 391.62, 15.04, 87.82),
			vector4(1165.15, 2710.78, 38.16, 177.96),
			vector4(1134.3, -983.26, 46.42, 276.3),
		},
        ["products"] = Config.Products["normal"],
        ["blipsprite"] = 628,
		["blipcolour"] = 31,
    },	
    -- Hardware Store Locations
    ["hardware"] = {
        ["label"] = "Hardware Store",
 		["type"] = "items",
		["model"] = { 
			[1] = `s_m_m_autoshop_02`,
			[2] = `S_F_M_Autoshop_01`,
			[3] = `S_M_M_AutoShop_01`,
			[4] = `S_M_M_Autoshop_03`,
			[5] = `IG_Benny`,
			[6] = `IG_Benny_02`,
			[7] = `MP_F_BennyMech_01`,
		},
		["coords"] = {
			vector4(46.52, -1749.55, 29.64, 50.82),
			vector4(2747.76, 3472.9, 55.67, 243.88),
			vector4(-421.65, 6135.97, 31.88, 232.98),
		},
        ["products"] = Config.Products["hardware"],
        ["blipsprite"] = 402,
		["blipcolour"] = 5,
    },
	-- Ammunation VANILLA Locations
    ["ammunation"] = {
        ["label"] = "Ammunation",
		["type"] = "weapons",
		["model"] = { 
			[1] = `s_m_m_ammucountry`,
			[2] = `S_M_Y_AmmuCity_01`,
			[3] = `MP_M_WareMech_01`,
			[4] = `A_M_M_Farmer_01`,
			[5] = `MP_M_ExArmy_01`,
			[6] = `S_M_Y_ArmyMech_01`,
			[7] = `S_M_M_Armoured_02`,
		},
		["logo"] = "https://static.wikia.nocookie.net/gtawiki/images/a/aa/Ammunation-GTAV.png",
        ["coords"] = {
            vector4(808.94, -2158.99, 29.62, 330.26),
            vector4(-660.98, -933.6, 21.83, 154.74),
			vector4(1693.16, 3761.94, 34.71, 189.83),
            vector4(-330.72, 6085.81, 31.45, 190.52),
			vector4(253.41, -51.67, 69.94, 28.88),
			vector4(23.69, -1105.95, 29.8, 124.58),
            vector4(2566.81, 292.54, 108.73, 320.09),
            vector4(-1118.19, 2700.5, 18.55, 185.31),
            vector4(841.31, -1035.28, 28.19, 334.27),
			vector4(-1304.44, -395.68, 36.7, 41.85),
		},
        ["products"] = Config.Products["weapons"],
        ["blipsprite"] = 567,
		["blipcolour"] = 1,
    },
	
    -- Ammunation GABZ Locations
--[[	["ammunation"] = {
        ["label"] = "Ammunation",
		["type"] = "weapons",
		["model"] = { 
			[1] = `s_m_m_ammucountry`,
			[2] = `S_M_Y_AmmuCity_01`,
			[3] = `MP_M_WareMech_01`,
			[4] = `A_M_M_Farmer_01`,
			[5] = `MP_M_ExArmy_01`,
			[6] = `S_M_Y_ArmyMech_01`,
			[7] = `S_M_M_Armoured_02`,
		},
		["logo"] = "https://static.wikia.nocookie.net/gtawiki/images/a/aa/Ammunation-GTAV.png",
        ["coords"] = {
            vector4(-659.16, -939.79, 21.83, 91.25),
			vector4(812.85, -2155.16, 29.62, 355.85),
			vector4(1698.04, 3757.43, 34.71, 136.69),
			vector4(-326.03, 6081.17, 31.45, 138.33),
			vector4(246.87, -51.3, 69.94, 335.47),
			vector4(18.71, -1108.24, 29.8, 158.71),
			vector4(2564.85, 298.83, 108.74, 283.17),
			vector4(-1112.4, 2697.08, 18.55, 152.96),
			vector4(841.16, -1028.63, 28.19, 294.2),
			vector4(-1310.71, -394.33, 36.7, 340.51),
		},
        ["products"] = Config.Products["weapons"],
        ["blipsprite"] = 110,
		["blipcolour"] = 1,
    },
]]
    -- Casino Locations
	["casino"] = {
		["label"] = "Diamond Casino",
		["type"] = "items",
		["model"] = { 
			[1] = `U_F_M_CasinoShop_01`,
		},
		["coords"] = { vector4(949.3, 32.01, 71.84, 81.33), },
		["products"] = Config.Products["casino"],
		["blipsprite"] = 617,
		["blipcolour"] = 0,
	},
    ["casino2"] = {
		["label"] = "Casino Bar",
		["coords"] = { vector4(950.68, 34.56, 71.85, 29.86), },
		["type"] = "items",
		["model"] = { 
			[1] = `S_M_M_HighSec_01`,
		},
		["products"] = Config.Products["normal"],
		["blipsprite"] = 52,
		["blipcolour"] = 0,
	},

    -- Weedshop Locations
    ["weedshop"] = {
		["label"] = "Smoke on the Water",
		["type"] = "items",
		["model"] = { 
			[1] = `mp_f_weed_01`,
			[2] = `MP_M_Weed_01`,
			[3] = `A_M_Y_MethHead_01`,
			[4] = `A_F_Y_RurMeth_01`,
		},
		["coords"] = { vector4(-1173.12, -1572.71, 4.66, 123.56), },
		["products"] = Config.Products["weedshop"],
		["blipsprite"] = 496,
		["blipcolour"] = 2,
   },

    -- Bean Coffee Locations
    ["beancoffee"] = {
		["label"] = "Bean Machine Coffee",
		["type"] = "items",
		["model"] = { 
			[1] = `A_F_Y_Hipster_02`,
		},
		["coords"] = { vector4(-628.97, 238.27, 81.9, 1.28), },
		["products"] = Config.Products["coffeeplace"],
		["blipsprite"] = 52,
		["blipcolour"] = 31,
    },

    -- Sea Word Locations
    ["seaworld"] = {
		["label"] = "Sea World",
		["type"] = "items",
		["model"] = { 
			[1] = `mp_m_boatstaff_01`,
		},
		["coords"] = { vector4(-1686.48, -1072.53, 13.15, 49.85), },
		["products"] = Config.Products["gearshop"],
		["blipsprite"] = 52,
		["blipcolour"] = 3,
   },

    -- Leisure Shop Locations
    ["leisureshop"] = {
		["label"] = "Leisure Shop",
		["type"] = "items",
		["model"] = { 
			[1] = `mp_m_boatstaff_01`,
		},
		["coords"] = { vector4(-1505.67, 1512.29, 115.29, 244.94) },
		["products"] = Config.Products["leisureshop"],
		["blipsprite"] = 52,
		["blipcolour"] = 2,
    },

    -- Local Store Locations
    ["delvecchioliquor"] = {
        ["label"] = "Del Vecchio Liquor",
		["type"] = "items",
		["model"] = { 
			[1] = `cs_nervousron`,
			[2] = `IG_RussianDrunk`,
			[3] = `U_M_Y_MilitaryBum`,
			[4] = `A_F_M_TrampBeac_01`,
			[5] = `A_M_M_Tramp_01`,
		},
        ["coords"] = { vector4(-160.54, 6320.85, 31.59, 317.79), },
        ["products"] = Config.Products["normal"],
        ["blipsprite"] = 52,
		["blipcolour"] = 2,
    },
	["digitalden"] = {
		["label"] = "Digital Den",
		["type"] = "items",
		["model"] = { 
			[1] = `S_M_M_LifeInvad_01`,
			[2] = `IG_Ramp_Hipster`,
			[3] = `A_M_Y_Hipster_02`,
			[4] = `A_F_Y_Hipster_01`,
			[5] = `IG_LifeInvad_01`,
			[6] = `IG_LifeInvad_02`,
			[7] = `CS_LifeInvad_01`,
		},
		["logo"] = "https://static.wikia.nocookie.net/gtawiki/images/b/b5/DigitalDen-GTAV-Logo.png",
		["coords"] = { 
			vector4(391.76, -832.79, 29.29, 223.77),
			vector4(1136.99, -473.13, 66.53, 254.85),
			vector4(-509.55, 278.63, 83.31, 176.65),
			vector4(-656.27, -854.73, 24.5, 359.39),
			vector4(-1088.29, -254.3, 37.76, 252.7),
			},
		["products"] = Config.Products["electronics"],
		["blipsprite"] = 619,
		["blipcolour"] = 7,
	},
	["blackmarket"] = {
		["label"] = "Black Market",
		["type"] = "items",
		["model"] = { 
			[1] = `mp_f_weed_01`,
			[2] = `MP_M_Weed_01`,
			[3] = `A_M_Y_MethHead_01`,
			[4] = `A_F_Y_RurMeth_01`,
			[5] = `A_M_M_RurMeth_01`,
			[6] = `MP_F_Meth_01`,
			[7] = `MP_M_Meth_01`,
		},
		["coords"] = { 
			vector4(776.24, 4184.08, 41.8, 92.12),
			vector4(2482.51, 3722.28, 43.92, 39.98),
			vector4(462.67, -1789.16, 28.59, 317.53),
			vector4(-115.15, 6369.07, 31.52, 232.08),
			vector4(752.52, -3198.33, 6.07, 301.72)
			},
		["products"] = Config.Products["blackmarket"],
		["hideblip"] = true,
	},
}
