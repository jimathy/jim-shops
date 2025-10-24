-- https://discord.gg/9pCDHmjYwd

Config = {
	Lan = "en",
	System = {
		Debug = false, -- Enable to add debug boxes and messages.
		EventDebug = false,


		--- FRAMEWORK OPTIONS ---
		Menu = "qb",        -- Supports "qb"    (qb-menu)
							-- "ox"             (ox_lib)
							-- "lation"			(lation_ui)

		Notify = "gta",     -- Supports "qb"    (qb-core)
							-- "ox"             (ox_lib)
							-- "gta"            (gta native)
							-- "lation"			(lation_ui)
							-- "esx"			(esx)
							-- "okok"			(okok)
	},


	Overrides = {
		Peds = true, -- Set to true if you want Shops to have Peds

		generateStoreLimits = true, 	-- Enable this to add Stash features, This adds limits to items and gets refilled at each restart
		RandomAmount = true, 			-- Sets wether a stash should have a "random" amount of stock or full.

		BlackMarket = true, 			-- enable to add blackmarket locations
										-- when enabled the server side will decide a location and players recieve that on connecting
		Measurement = "lb", 			-- Custom Weight measurement
		Currency = "$",					-- Custom Currency

		Gabz247 = GetResourceState("cfx-gabz-247"):find("start"),  -- Auto-Enable if using gabz 247 stores
		GabzAmmu = GetResourceState("cfx-gabz-ammunation"):find("start"), -- Auto-Enable if using gabz Ammunation stores

		VendOverride = true, 	-- Enable this if you want all the vending machines to use this script

		BasketSystem = false, 	-- If enabled, this creates a "Basket" for all shops, which users add items to and then can purchase in one go
	},
}

curVal = Config.Overrides.Currency or "$"

-- Function for locales
-- Don't touch unless you know what you're doing
-- This needs to be here because it loads before everything else
function locale(section, string)
    if not Config.Lan or Config.Lan == "" then
        print("^1Error^7: ^3Config^7.^3Lan ^1not set^7, ^2falling back to Config.Lan = 'en'")
        Config = Config or {}
        Config.Lan = "en"
    end

    local localTable = Loc[Config.Lan]
    -- If Loc[..] doesn't exist, warn user
    if not localTable then
		print("Locale Table '"..Config.Lan.."' Not Found")
        return "Locale Table '"..Config.Lan.."' Not Found"
    end

    -- If Loc[..].section doesn't exist, warn user
    if not localTable[section] then
		print("^1Error^7: Locale Section: ['"..section.."'] Invalid")
        return "Locale Section: ['"..section.."'] Invalid"
    end

    -- If Loc[..].section.string doesn't exist, warn user
    if not localTable[section][string] then
		print("^1Error^7: Locale String: ['"..string.."'] Invalid")
        return "Locale String: ['"..string.."'] Invalid"
    end

    -- If no issues, return the string
    return localTable[section][string]
end