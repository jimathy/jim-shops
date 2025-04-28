Locations = {
    -- 24/7 Locations
    ["247supermarket"] = {
        label = "24/7 Supermarket",
		type = "items",
		model = {
			"mp_m_shopkeep_01",
			"S_F_Y_Shop_LOW",
			"S_F_Y_SweatShop_01",
		},
		killable = true,
		logo = "nui://"..getScript().."/images/247.png",
        coords = {
			vec4(24.5, -1346.19, 29.5, 266.78),
			vec4(-3039.91, 584.26, 7.91, 16.79),
			vec4(-3243.27, 1000.1, 12.83, 358.73),
			vec4(1728.28, 6416.03, 35.04, 242.45),
			vec4(1697.96, 4923.04, 42.06, 326.61),
			vec4(1959.6, 3740.93, 32.34, 296.84),
			vec4(549.16, 2670.35, 42.16, 92.53),
			vec4(2677.41, 3279.8, 55.24, 334.16),
			vec4(2556.19, 380.89, 108.62, 355.58),
			vec4(372.82, 327.3, 103.57, 255.46),
			vec4(161.21, 6642.32, 31.61, 223.57),
		},
        products = Products.normal,
        blipsprite = 628,
		blipcolour = 2,
    },
    -- LTD Gasoline Locations
    ["ltdgasoline"] = {
        label = "LTD Gasoline",
		type = "items",
		model = {
			"s_m_m_autoshop_02",
			"S_F_M_Autoshop_01",
			"S_M_M_AutoShop_01",
			"S_M_M_Autoshop_03",
			"IG_Benny",
			"IG_Benny_02",
			"MP_F_BennyMech_01",
		},
		logo = "nui://"..getScript().."/images/ltd.png",
        coords = {
			vec4(-47.42, -1758.67, 29.42, 47.26),
			vec4(-706.17, -914.64, 19.22, 88.77),
			vec4(-1819.53, 793.49, 138.09, 131.46),
			vec4(1164.82, -323.66, 69.21, 106.86),
		},
        products = Products.normal,
        blipsprite = 628,
		blipcolour = 5,
    },
    -- Rob's Liquor Locations
    ["robsliquor"] = {
        label = "Rob's Liqour",
		type = "items",
		model = {
			"cs_nervousron",
			"IG_RussianDrunk",
			"U_M_Y_MilitaryBum",
			"A_F_M_TrampBeac_01",
			"A_M_M_Tramp_01",
		},
		logo = "nui://"..getScript().."/images/robs.webp",
        coords = {
			vec4(-1221.38, -907.89, 12.33, 27.51),
			vec4(-1486.82, -377.48, 40.16, 130.89),
			vec4(-2966.41, 391.62, 15.04, 87.82),
			vec4(1165.15, 2710.78, 38.16, 177.96),
			vec4(1134.3, -983.26, 46.42, 276.3),
		},
        products = Products.bar,
        blipsprite = 628,
		blipcolour = 31,
    },
    -- Hardware Store Locations
    ["hardware"] = {
        label = "Hardware Store",
		type = "items",
		model = {
			"s_m_m_autoshop_02",
			"S_F_M_Autoshop_01",
			"S_M_M_AutoShop_01",
			"S_M_M_Autoshop_03",
			"IG_Benny",
			"IG_Benny_02",
			"MP_F_BennyMech_01",
		},
		coords = {
			vec4(46.52, -1749.55, 29.64, 50.82),
			vec4(2747.76, 3472.9, 55.67, 243.88),
			vec4(-421.65, 6135.97, 31.88, 232.98),
		},
        products = Products.hardware,
        blipsprite = 402,
		blipcolour = 5,
    },
	-- Ammunation VANILLA Locations
    ["ammunation"] = {
        label = "Ammunation",
        targetLabel = "Open Ammunation",
		type = "weapons",
		model = {
			"s_m_m_ammucountry",
			"S_M_Y_AmmuCity_01",
			"MP_M_WareMech_01",
			"A_M_M_Farmer_01",
			"MP_M_ExArmy_01",
			"S_M_Y_ArmyMech_01",
			"S_M_M_Armoured_02",
		},
		logo = "nui://"..getScript().."/images/ammu.png",
        coords = {
            vec4(808.94, -2158.99, 29.62, 330.26),
            vec4(-660.98, -933.6, 21.83, 154.74),
			vec4(1693.16, 3761.94, 34.71, 189.83),
            vec4(-330.72, 6085.81, 31.45, 190.52),
			vec4(253.41, -51.67, 69.94, 28.88),
			vec4(23.69, -1105.95, 29.8, 124.58),
            vec4(2566.81, 292.54, 108.73, 320.09),
            vec4(-1118.19, 2700.5, 18.55, 185.31),
            vec4(841.31, -1035.28, 28.19, 334.27),
			vec4(-1304.44, -395.68, 36.7, 41.85),
		},
        products = Products.weapons,
        blipsprite = 567,
		blipcolour = 1,
    },
    -- Casino Locations
	["casino"] = {
		label = "Diamond Casino",
		targetLabel = "Buy Chips",
		type = "items",
		model = {
			"U_F_M_CasinoShop_01",
			"U_F_M_CasinoCash_01",
			"S_F_Y_Casino_01",
			"S_M_Y_Casino_01",
		},
		coords = {
			vec4(990.08, 30.35, 71.47, 94.81),
			vec4(990.96, 31.8, 71.47, 19.59),
		},
		products = Products.casino,
		hideblip = true,
		blipsprite = 617,
		blipcolour = 0,
		isCasino = true,
	},
    ["casino2"] = {
		label = "Casino Bar",
		coords = { vec4(979.44, 25.4, 71.46, 0.75), },
		type = "items",
		model = {
			"S_M_M_HighSec_01",
		},
		products = Products.bar,
		blipsprite = 52,
		blipcolour = 0,
	},

    -- Weedshop Locations
    ["weedshop"] = {
		label = "Smoke on the Water",
		type = "items",
		model = {
			"mp_f_weed_01",
			"MP_M_Weed_01",
			"A_M_Y_MethHead_01",
			"A_F_Y_RurMeth_01",
			"a_m_y_hippy_01",
		},
		coords = { vec4(-1173.12, -1572.71, 4.66, 123.56), },
		products = Products.weedshop,
		blipsprite = 496,
		blipcolour = 2,
	},

    -- Bean Coffee Locations
    ["beancoffee"] = {
		label = "Bean Machine Coffee",
		type = "items",
		model = {
			"A_F_Y_Hipster_02",
		},
		coords = {
			vec4(-628.97, 238.27, 81.9, 1.28),
			vec4(126.55, -1028.12, 29.36, 343.0),
		},
		products = Products.coffeeplace,
		blipsprite = 52,
		blipcolour = 31,
    },

    -- Sea Word Locations
    ["seaworld"] = {
		label = "Sea World",
		type = "items",
		model = {
			"mp_m_boatstaff_01",
			"a_m_y_beach_01",
		},
		coords = {
			vec4(-1686.48, -1072.53, 13.15, 49.85)
		},
		products = Products.gearshop,
		blipsprite = 52,
		blipcolour = 3,
	},

    -- Leisure Shop Locations
    ["leisureshop"] = {
		label = "Leisure Shop",
		type = "items",
		model = {
			"mp_m_boatstaff_01",
			"a_m_y_beach_01",
		},
		coords = {
			vec4(-1505.67, 1512.29, 115.29, 244.94)
		},
		products = Products.leisureshop,
		blipsprite = 52,
		blipcolour = 2,
    },

    -- Local Store Locations
    ["delvecchioliquor"] = {
        label = "Del Vecchio Liquor",
		type = "items",
		model = {
			"cs_nervousron",
			"IG_RussianDrunk",
			"U_M_Y_MilitaryBum",
			"A_F_M_TrampBeac_01",
			"A_M_M_Tramp_01",
		},
        coords = {
			vec4(-160.54, 6320.85, 31.59, 317.79),
		},
        products = Products.normal,
        blipsprite = 52,
		blipcolour = 2,
    },
	["digitalden"] = {
		label = "Digital Den",
		type = "items",
		model = {
			"S_M_M_LifeInvad_01",
			"IG_Ramp_Hipster",
			"A_M_Y_Hipster_02",
			"A_F_Y_Hipster_01",
			"IG_LifeInvad_01",
			"IG_LifeInvad_02",
			"CS_LifeInvad_01",
		},
		logo = "nui://"..getScript().."/images/digitalden.png",
		coords = {
			vec4(391.76, -832.79, 29.29, 223.77),
			vec4(1136.99, -473.13, 66.53, 254.85),
			vec4(-509.55, 278.63, 83.31, 176.65),
			vec4(-656.27, -854.73, 24.5, 359.39),
			vec4(-1088.29, -254.3, 37.76, 252.7),
		},
		products = Products.electronics,
		blipsprite = 619,
		blipcolour = 7,
	},
	["lostmc"] = { -- More of a test/example - Gang accessible stores
		label = "Lost MC",
		type = "items",
		gang = "lostmc",
		model = {
			"G_F_Y_Lost_01",
			"G_M_Y_Lost_01",
			"G_M_Y_Lost_02",
			"G_M_Y_Lost_03",
		},
		coords = {
			vec4(999.59, -131.58, 74.06, 12.95),
		},
		products = Products.coffeeplace, -- example using coffeplace info
		hideblip = true,
	},
}

--if Gabz locations are enabled, override their coords with these
if Config.Overrides.Gabz247 then
	Locations["247supermarket"].coords = {
		vec4(24.91, -1346.86, 29.5, 268.37),
		vec4(-3039.64, 584.78, 7.91, 21.88),
		vec4(-3242.73, 1000.46, 12.83, 2.08),
		vec4(1728.44, 6415.4, 35.04, 243.26),
		vec4(1697.96, 4923.04, 42.06, 326.61),
		vec4(1960.26, 3740.6, 32.34, 300.45),
		vec4(548.67, 2670.94, 42.16, 101.0),
		vec4(2677.97, 3279.95, 55.24, 325.89),
		vec4(2556.8, 381.27, 108.62, 359.15),
		vec4(373.08, 326.75, 103.57, 253.14),
		vec4(161.2, 6641.74, 31.7, 221.02),
		vec4(812.86, -782.01, 26.17, 270.01),
	}
end
if Config.Overrides.GabzAmmu then
	Locations["ammunation"].coords = {
		vec4(-659.16, -939.79, 21.83, 91.25),
		vec4(812.85, -2155.16, 29.62, 355.85),
		vec4(1698.04, 3757.43, 34.71, 136.69),
		vec4(-326.03, 6081.17, 31.45, 138.33),
		vec4(246.87, -51.3, 69.94, 335.47),
		vec4(18.71, -1108.24, 29.8, 158.71),
		vec4(2564.85, 298.83, 108.74, 283.17),
		vec4(-1112.4, 2697.08, 18.55, 152.96),
		vec4(841.16, -1028.63, 28.19, 294.2),
		vec4(-1310.71, -394.33, 36.7, 340.51),
	}
end
if Config.Overrides.BlackMarket then
	Locations["blackmarket"] = {
		label = "Black Market",
		type = "items",
		model = {
			"mp_f_weed_01",
			"MP_M_Weed_01",
			"A_M_Y_MethHead_01",
			"A_F_Y_RurMeth_01",
			"A_M_M_RurMeth_01",
			"MP_F_Meth_01",
			"MP_M_Meth_01",
		},
		coords = {
			vec4(776.24, 4184.08, 41.8, 92.12),
			vec4(2482.51, 3722.28, 43.92, 39.98),
			vec4(462.67, -1789.16, 28.59, 317.53),
			vec4(-115.15, 6369.07, 31.52, 232.08),
			vec4(752.52, -3198.33, 6.07, 301.72)
		},
		products = Products.blackmarket,
		hideblip = false,
	}
end

if Config.Overrides.VendOverride then
	Locations["vendingmachine"] = {
		label = "Vending Machine",
		targetIcon = "fas fa-calculator",
		targetLabel = "Use Vending Machine",
		type = "items",
		logo = "https://static.wikia.nocookie.net/gtawiki/images/d/d4/Ecola-GTAO-LSTunersBanner.png",
		model = { -- You can add more models to this, but these make the most sense for the vending machine stuff
			"prop_vend_soda_01",
			"prop_vend_soda_02",
			"prop_vend_snak_01",
			"prop_vend_snak_01_tu"
		},
		coords = { -- If you want to place custom vending machine locations
			vec4(131.13, -3007.16, 7.04, 0.0), -- GABZ LS Tuners
		},
		products = Products.vending,
		isVendingMachine = true,
	}
end