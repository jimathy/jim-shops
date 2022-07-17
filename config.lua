print("^2Jim^7-^2Shops v^41^7.^46 ^7- ^2Shop Script by ^1Jimathy^7")

-- If you need support I now have a discord available, it helps me keep track of issues and give better support.

-- https://discord.gg/xKgQZ6wZvS

Config = {
	Debug = false, -- Enable to add debug boxes and message.
	img = "qb-inventory/html/images/", -- Set this to your inventory
	JimMenu = false, -- Enable this if you are using an updated qb-menu resource with icon support
	Peds = true, -- Set to true if you want Shops to have Peds
	Limit = true, -- Enable this to add Stash features, This adds limits to items and gets refilled at each restart
	MaxSlots = 41, -- Set this to your player inventory slot count, this is default "41"
	BlackMarket = false, -- enable to add blackmarket locations (defined at the bottom of this file)
	Measurement = "kg", -- Custom Weight measurement
	Gabz247 = false,  -- Enable if using gabz 247 stores
	GabzAmmu = false, -- Enable if using gabz Ammunation stores

	Scenarios = { -- List of scenarios the peds do, This is called "fun", much better than standing staring at the void.
		"WORLD_HUMAN_GUARD_PATROL",
		"WORLD_HUMAN_JANITOR",
		"WORLD_HUMAN_MUSCLE_FLEX",
		"WORLD_HUMAN_MUSCLE_FREE_WEIGHTS",
		"PROP_HUMAN_STAND_IMPATIENT",
		"WORLD_HUMAN_VALET",
		"WORLD_HUMAN_AA_COFFEE",
		"WORLD_HUMAN_AA_SMOKE",
		"WORLD_HUMAN_DRUG_DEALER",
		"WORLD_HUMAN_GUARD_STAND_CASINO",
	},
	Products = {
		["normal"] = {
			{ name = "tosti", price = 2, amount = 50, info = {} },
			{ name = "water_bottle", price = 2, amount = 50, info = {} },
			{ name = "kurkakola", price = 2, amount = 50, info = {} },
			{ name = "twerks_candy", price = 2, amount = 50, info = {} },
			{ name = "snikkel_candy", price = 2, amount = 50, info = {} },
			{ name = "sandwich", price = 2, amount = 50, info = {} },
			{ name = "beer", price = 7, amount = 50, info = {} },
			{ name = "whiskey", price = 10, amount = 50, info = {} },
			{ name = "vodka", price = 70000, amount = 50, info = {} },
			{ name = "bandage", price = 100, amount = 50, info = {} },
			{ name = "lighter", price = 2, amount = 50, info = {} },
			{ name = "rolling_paper", price = 2, amount = 5000, info = {}, },
		},
		["hardware"] = {
			{ name = "lockpick", price = 200, amount = 50, info = {} },
			{ name = "weapon_wrench", price = 250, amount = 250, info = {} },
			{ name = "weapon_hammer", price = 250, amount = 250, info = {} },
			{ name = "weapon_bat", price = 500, amount = 50, info = {}, requiredGang = { "lostmc" } },  -- Gang only options in stores
			{ name = "repairkit", price = 250, amount = 50, info = {}, requiredJob = { ["mechanic"] = 0, ["police"] = 0 } },
			{ name = "screwdriverset", price = 350, amount = 50, info = {} },
			{ name = "phone", price = 850, amount = 50, info = {} },
			{ name = "radio", price = 250, amount = 50, info = {} },
			{ name = "binoculars", price = 50, amount = 50, info = {} },
			{ name = "firework1", price = 50, amount = 50, info = {} },
			{ name = "firework2", price = 50, amount = 50, info = {} },
			{ name = "firework3", price = 50, amount = 50, info = {} },
			{ name = "firework4", price = 50, amount = 50, info = {} },
			{ name = "fitbit", price = 400, amount = 150, info = {} },
			{ name = "cleaningkit", price = 150, amount = 150, info = {} },
			{ name = "advancedrepairkit", price = 500, amount = 50, info = {}, requiredJob = { ["mechanic"] = 0 } },
		},
		["weedshop"] = {
			{ name = "joint", price = 10, amount = 1000, info = {} },
			{ name = "weapon_poolcue", price = 100, amount = 1000, info = {} },
			{ name = "weed_nutrition", price = 20, amount = 1000, info = {} },
			{ name = "empty_weed_bag", price = 2, amount = 1000, info = {} },
			{ name = "rolling_paper", price = 2, amount = 1000, info = {} },
		},
		["gearshop"] = {
			{ name = "diving_gear", price = 2500, amount = 10, info = {} },
			{ name = "jerry_can", price = 200, amount = 50, info = {} },
		},
		["leisureshop"] = {
			{ name = "parachute", price = 2500, amount = 10, info = {} },
			{ name = "binoculars", price = 50, amount = 50, info = {} },
			{ name = "diving_gear", price = 2500, amount = 10, info = {} },
		},
		["weapons"] = {
			{ name = "weapon_knife", price = 250, amount = 250, info = nil },
			{ name = "weapon_bat", price = 250, amount = 250, info = {} },
			{ name = "weapon_hatchet",price = 250, amount = 250, info = {}, requiredJob = { ["mechanic"] = 0, ["police"] = 0 } },
			{ name = "weapon_pistol", price = 2500, amount = 5, info = nil, requiresLicense = true },
			{ name = "weapon_snspistol", price = 1500, amount = 5, info = nil, requiresLicense = true },
			{ name = "weapon_vintagepistol", price = 4000, amount = 5, info = nil, requiresLicense = true },
			{ name = "pistol_ammo", price = 250, amount = 250, info = {}, requiresLicense = true },
		},

		["coffeeplace"] = {
			{ name = "coffee", price = 5, amount = 500 },
			{ name = "lighter", price = 2, amount = 50 },
		},
		["casino"] = {
			{ name = 'casinochips', price = 100, amount = 999999 },
		},
		["electronics"] = {
			{ name = "phone", price = 850, amount = 50 },
			{ name = "radio", price = 250, amount = 50, },
			{ name = "screwdriverset", price = 350, amount = 50, },
			{ name = "binoculars", price = 50, amount = 50, },
			{ name = "fitbit", price = 400, amount = 150, },
		},
		["blackmarket"] = {
			{ name = "radioscanner", price = 850, amount = 5 },
		},
	},
}
Config.Locations = {
    -- 24/7 Locations
    ["247supermarket"] = {
        ["label"] = "24/7 Supermarket",
		["type"] = "items",
		["model"] = {
			`mp_m_shopkeep_01`,
			`S_F_Y_Shop_LOW`,
			`S_F_Y_SweatShop_01`,
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
    -- LTD Gasoline Locations
    ["ltdgasoline"] = {
        ["label"] = "LTD Gasoline",
		["type"] = "items",
		["model"] = {
			`s_m_m_autoshop_02`,
			`S_F_M_Autoshop_01`,
			`S_M_M_AutoShop_01`,
			`S_M_M_Autoshop_03`,
			`IG_Benny`,
			`IG_Benny_02`,
			`MP_F_BennyMech_01`,
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
			`cs_nervousron`,
			`IG_RussianDrunk`,
			`U_M_Y_MilitaryBum`,
			`A_F_M_TrampBeac_01`,
			`A_M_M_Tramp_01`,
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
			`s_m_m_autoshop_02`,
			`S_F_M_Autoshop_01`,
			`S_M_M_AutoShop_01`,
			`S_M_M_Autoshop_03`,
			`IG_Benny`,
			`IG_Benny_02`,
			`MP_F_BennyMech_01`,
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
			`s_m_m_ammucountry`,
			`S_M_Y_AmmuCity_01`,
			`MP_M_WareMech_01`,
			`A_M_M_Farmer_01`,
			`MP_M_ExArmy_01`,
			`S_M_Y_ArmyMech_01`,
			`S_M_M_Armoured_02`,
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
    -- Casino Locations
	["casino"] = {
		["label"] = "Diamond Casino",
		["type"] = "items",
		["model"] = {
			`U_F_M_CasinoShop_01`,
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
			`S_M_M_HighSec_01`,
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
			`mp_f_weed_01`,
			`MP_M_Weed_01`,
			`A_M_Y_MethHead_01`,
			`A_F_Y_RurMeth_01`,
			`a_m_y_hippy_01`,
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
			`A_F_Y_Hipster_02`,
		},
		["coords"] = {
			vector4(-628.97, 238.27, 81.9, 1.28),
			vector4(126.55, -1028.12, 29.36, 343.0),
		},
		["products"] = Config.Products["coffeeplace"],
		["blipsprite"] = 52,
		["blipcolour"] = 31,
    },

    -- Sea Word Locations
    ["seaworld"] = {
		["label"] = "Sea World",
		["type"] = "items",
		["model"] = {
			`mp_m_boatstaff_01`,
			`a_m_y_beach_01`,
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
			`mp_m_boatstaff_01`,
			`a_m_y_beach_01`,
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
			`cs_nervousron`,
			`IG_RussianDrunk`,
			`U_M_Y_MilitaryBum`,
			`A_F_M_TrampBeac_01`,
			`A_M_M_Tramp_01`,
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
			`S_M_M_LifeInvad_01`,
			`IG_Ramp_Hipster`,
			`A_M_Y_Hipster_02`,
			`A_F_Y_Hipster_01`,
			`IG_LifeInvad_01`,
			`IG_LifeInvad_02`,
			`CS_LifeInvad_01`,
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
	["lostmc"] = { -- More of a test/example - Gang accessible stores
		["label"] = "Lost MC",
		["type"] = "items",
		["gang"] = "lostmc",
		["logo"] = "https://static.wikia.nocookie.net/gtawiki/images/b/b6/LostMCPatch-GTAV-Worn.png",
		["model"] = {
			`G_F_Y_Lost_01`,
			`G_M_Y_Lost_01`,
			`G_M_Y_Lost_02`,
			`G_M_Y_Lost_03`,
		},
		["coords"] = {
			vector4(999.59, -131.58, 74.06, 12.95),
		},
		["products"] = Config.Products["coffeeplace"], -- example using coffeplace info
		["hideblip"] = true,
	},
}

--if Gabz locations are enabled, override their coords with these
if Config.Gabz247 then
	Config.Locations["247supermarket"]["coords"] = {
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
		vector4(812.86, -782.01, 26.17, 270.01),
	}
end
if Config.GabzAmmu then
	Config.Locations["ammunation"]["coords"] = {
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
	}
end
if Config.BlackMarket then
	Config.Locations["blackmarket"] = {
		["label"] = "Black Market",
		["type"] = "items",
		["model"] = {
			`mp_f_weed_01`,
			`MP_M_Weed_01`,
			`A_M_Y_MethHead_01`,
			`A_F_Y_RurMeth_01`,
			`A_M_M_RurMeth_01`,
			`MP_F_Meth_01`,
			`MP_M_Meth_01`,
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
	}
end
Config.ItemModels = {
	["repairkit"] = `v_ind_cs_toolbox4`,
	["advancedrepairkit"] = `v_ind_cs_toolbox4`,
	["phone"] = `p_amb_phone_01`,
	["tosti"] = `prop_sandwich_01`,
	["sandwich"] = `prop_sandwich_01`,
	["water_bottle"] = `ba_prop_club_water_bottle`,
	["kurkacola"] = `prop_ecola_can`,
	["twerks_candy"] = `prop_choc_pq`,
	["snikkel_candy"] = `prop_choc_pq`,
	["beer"] = `prop_sh_beer_pissh_01`,
	["whiskey"] = `prop_whiskey_bottle`,
	["vodka"] = `prop_vodka_bottle`,
	["lighter"] = `lux_prop_lighter_luxe`,

	["screwdriverset"] = `prop_tool_screwdvr01`,
	["radio"] = `prop_cs_hand_radio`,
	["binoculars"] = `v_serv_ct_binoculars`,
	["cleaningkit"] = `prop_huf_rag_01`,

	["diving_gear"] = `p_s_scuba_tank_s`,
	["jerry_can"] = `prop_jerrycan_01a`,
	["parachute"] = `p_parachute_s_shop`,

	["coffee"] = `prop_fib_coffee`,
	["fitbit"] = `p_watch_02`,
	["radioscanner"] = `prop_police_radio_main`,
	--Weapons
	["weapon_bat"] = `p_cs_bbbat_01`,
	["weapon_knife"] = `prop_w_me_knife_01`,
	["weapon_hammer"] = `w_me_hammer`,
	["weapon_hatchet"] = `prop_w_me_hatchet`,
	['weapon_dagger'] = `prop_w_me_dagger`,
	['weapon_bottle'] = `prop_w_me_bottle`,
	['weapon_crowbar'] = `prop_ing_crowbar`,
	['weapon_flashlight'] = `w_me_flashlight`,
	['weapon_golfclub'] = `prop_golf_iron_01`,
	['weapon_knuckle'] = `w_me_knuckle`,
	['weapon_machete'] = `prop_ld_w_me_machette`,
	['weapon_switchblade'] = `w_me_switchblade`,
	['weapon_nightstick'] = `w_me_nightstick`,
	['weapon_wrench'] = `v_ind_cs_wrench`,
	['weapon_battleaxe'] = `w_me_battleaxe`,
	['weapon_poolcue'] = `w_me_poolcue`,
	['weapon_handcuffs']  = `prop_cs_cuffs_01`,
	['weapon_bread']  = `v_res_fa_bread01`,
	['weapon_stone_hatchet'] = `w_me_stonehatchet`,

	['weapon_pistol'] = `w_pi_pistol`,
	['weapon_pistol_mk2'] = `w_pi_pistolmk2`,
	['weapon_combatpistol'] = `w_pi_combatpistol`,
	['weapon_appistol']  = `w_pi_appistol`,
	['weapon_stungun'] 	 = `w_pi_stungun`,
	['weapon_pistol50']  = `w_pi_pistol50`,
	['weapon_snspistol']  = `w_pi_sns_pistol`,
	['weapon_heavypistol']  = `w_pi_heavypistol`,
	['weapon_vintagepistol'] = `w_pi_vintage_pistol`,
	['weapon_flaregun'] = `w_pi_flaregun`,
	--['weapon_marksmanpistol'] = ``,
	['weapon_revolver'] = `w_pi_revolver`,
	['weapon_revolver_mk2'] = `w_pi_revolvermk2`,
	['weapon_doubleaction'] = `w_pi_wep1_gun`,
	['weapon_snspistol_mk2'] = `w_pi_sns_pistolmk2`,
	['weapon_raypistol'] = `w_pi_raygun_ev`,
	['weapon_ceramicpistol'] = `w_pi_ceramic_pistol`,
	['weapon_navyrevolver'] = `w_pi_wep2_gun`,
	--['weapon_gadgetpistol'] = ``,
	['weapon_microsmg'] = `w_sb_microsmg`,
	['weapon_smg'] = `w_sb_smg`,
	['weapon_smg_mk2'] = `w_sb_smgmk2`,
	['weapon_assaultsmg'] = `w_sb_assaultsmg`,
	['weapon_combatpdw'] = `w_sb_pdw`,
	--['weapon_machinepistol'] = ``,
	['weapon_minismg'] = `w_sb_minismg`,
	['weapon_raycarbine'] = `w_ar_srifle`,
	['weapon_pumpshotgun'] = `w_sg_pumpshotgun`,
	['weapon_pumpshotgun_mk2'] = `w_sg_pumpshotgunmk2`,
	['weapon_sawnoffshotgun'] = `w_sg_sawnoff`,
	['weapon_assaultshotgun'] = `w_sg_assaultshotgun`,
	['weapon_bullpupshotgun'] = `w_sg_bullpupshotgun`,
	['weapon_musket'] = `w_ar_musket`,
	['weapon_heavyshotgun'] = `w_sg_heavyshotgun`,
	['weapon_dbshotgun'] = `w_sg_doublebarrel`,
	--['weapon_autoshotgun'] = ``,
	--['weapon_combatshotgun'] = ``,

	['weapon_assaultrifle'] = `w_ar_assaultrifle`,
	['weapon_assaultrifle_mk2'] = `w_ar_assaultriflemk2`,
	['weapon_carbinerifle'] = `w_ar_carbinerifle`,
	['weapon_carbinerifle_mk2'] = `w_ar_carbineriflemk2`,
	['weapon_advancedrifle'] = `w_ar_advancedrifle`,
	['weapon_specialcarbine'] = `w_ar_specialcarbine`,
	['weapon_specialcarbine_mk2'] = `w_ar_specialcarbinemk2`,
	['weapon_bullpuprifle'] = `w_ar_bullpuprifle`,
	['weapon_bullpuprifle_mk2'] = `w_ar_bullpupriflemk2`,
	['weapon_compactrifle']  = `w_ar_assaultrifle_smg`,
	['weapon_militaryrifle'] = `w_ar_heavyrifleh`,
	['weapon_mg'] = `w_mg_mg`,
	['weapon_combatmg'] = `w_mg_combatmg`,
	['weapon_combatmg_mk2'] = `w_mg_combatmgmk2`,
	['weapon_gusenberg'] = `w_sb_gusenberg`,

	['weapon_sniperrifle'] = `w_sr_sniperrifle`,
	['weapon_heavysniper'] = `w_sr_heavysniper`,
	['weapon_heavysniper_mk2'] = `w_sr_heavysnipermk2`,
	['weapon_marksmanrifle'] = `w_sr_marksmanrifle`,
	['weapon_marksmanrifle_mk2'] = `w_sr_marksmanriflemk2`,
	--['weapon_remotesniper'] = ``,
	['weapon_rpg'] = `w_lr_rpg`,
	['weapon_grenadelauncher'] = `w_lr_grenadelauncher`,
	['weapon_grenadelauncher_smoke'] = `w_lr_grenadelauncher`,
	['weapon_minigun'] = `prop_minigun_01`,
	['weapon_firework'] = `w_lr_firework`,
	['weapon_railgun'] = `w_ar_railgun`,
	--['weapon_hominglauncher'] = ``,
	--['weapon_compactlauncher'] = ``,
	--['weapon_rayminigun'] = ``,
	['weapon_grenade'] = `w_ex_grenadefrag`,
	['weapon_bzgas'] = `prop_gas_grenade`,
	['weapon_molotov'] = `w_ex_molotov`,
	--['weapon_stickybomb'] = ``,
	['weapon_proxmine'] = `gr_prop_gr_pmine_01a`,
	['weapon_snowball'] = `w_ex_snowball`,
	['weapon_pipebomb'] = `w_ex_pipebomb`,
	['weapon_ball'] = `w_am_baseball`,
	['weapon_smokegrenade'] = `w_ex_grenadesmoke`,
}