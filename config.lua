-- If you need support I now have a discord available, it helps me keep track of issues and give better support.

-- https://discord.gg/9pCDHmjYwd

Config = {
	Lan = "en",
	System = {
		Debug = false, -- Enable to add debug boxes and message.
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

		generateStoreLimits = true, -- Enable this to add Stash features, This adds limits to items and gets refilled at each restart
		RandomAmount = true, -- Sets wether a stash should have a "random" amount of stock or full.

		MaxSlots = 41, -- Set this to your player inventory slot count, this is default "41"

		BlackMarket = true, 	-- enable to add blackmarket locations
								-- when enabled the server side will decide a location and players recieve that on connecting
		Measurement = "lb", -- Custom Weight measurement
		Gabz247 = GetResourceState("cfx-gabz-247"):find("start"),  -- Enable if using gabz 247 stores
		GabzAmmu = GetResourceState("cfx-gabz-ammunation"):find("start"), -- Enable if using gabz Ammunation stores

		VendOverride = true, 	-- Enable this if you want all the vending machines to use this script

		-- WIP ⚠️
		BasketSystem = false, 	-- If enabled, this creates a "Basket" for all shops, which users add items to and then can purchase in one go
		--
	},
}