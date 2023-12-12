PlayerGang, PlayerJob, Targets, Peds, Blips = {}, {}, {}, {}, {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() Core.Functions.GetPlayerData(function(PlayerData) PlayerJob = PlayerData.job end) end)
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo) PlayerJob = JobInfo end)
RegisterNetEvent('QBCore:Client:SetDuty', function(duty) onDuty = duty end)
RegisterNetEvent('QBCore:Client:OnGangUpdate', function(GangInfo) PlayerGang = GangInfo end)
AddEventHandler('onResourceStart', function(resource) if GetCurrentResourceName() ~= resource then return end Core.Functions.GetPlayerData(function(PlayerData) PlayerJob = PlayerData.job end) end)

local pedVoices = { -- Testing forcing certain voices for jim-talktonpc
	[`mp_m_shopkeep_01`] = "MP_M_SHOPKEEP_01_PAKISTANI_MINI_01",
	[`S_F_Y_Shop_LOW`] = "S_F_Y_SHOP_LOW_WHITE_MINI_01",
	[`S_F_Y_SweatShop_01`] = "S_F_Y_SHOP_LOW_WHITE_MINI_01",
	--add ped model and voice names here
}

CreateThread(function()
	if Config.System.Callback == "qb" then
		local p = promise.new()
		Core.Functions.TriggerCallback('jim-shops:server:syncShops', function(locs) p:resolve(locs) end)
		Locations = Citizen.Await(p)
	elseif Config.System.Callback == "ox" then
		Locations = lib.callback.await('jim-shops:server:syncShops', false)
	end
	for k, v in pairs(Locations) do
		if k == "vendingmachine" and Config.Overrides.VendOverride then
			for l, b in pairs(v["coords"]) do
				if Config.Peds then
					if v["model"] then
						local i = math.random(1, #v["model"])
						loadModel(v["model"][i])
						if not IsModelAPed(v["model"][i]) then
							if not Peds["Shop - ['"..k.."("..l..")']"] then
								Peds["Shop - ['"..k.."("..l..")']"] = CreateObject(v["model"][i], b.x, b.y, b.z-1.03, 0, 0, 0)
								SetEntityHeading(Peds["Shop - ['"..k.."("..l..")']"], b.w)
							end
						end
						FreezeEntityPosition(Peds["Shop - ['"..k.."("..l..")']"], true)
						if Config.System.Debug then print("^5Debug^7: ^6Ped ^2Created for Shop ^7- '^6"..k.."^7(^6"..l.."^7)'") end
					end
				end
				if Config.System.Target == "qb" then
					exports['qb-target']:AddTargetModel(v["model"], {
						options = { {
							event = "jim-shops:ShopMenu", icon = (v["targetIcon"]), label = (v["targetLabel"]),
							shoptable = v, name = v["label"], vend = true }, },
						distance = 1.5, })

				elseif Config.System.Target == "ox" then
					exports.ox_target:addModel(v["model"], {{
						icon = (v["targetIcon"]), label = (v["targetLabel"]),
						onSelect = function() TriggerEvent("jim-shops:ShopMenu", { shoptable = v, name = v["label"], vend = true }) end,
						canInteract = function(_, distance)
							return distance < 1.5 and true or false
						end
					}})
				else
					if Config.System.Debug then print("^5Debug^7: ^2Config option ^6Config.System.Target ^2should be ^7ox ^2or ^7qb") end
				end
			end
		else
			if k == "blackmarket" then -- Server synced blackmarket coord
				local coord = nil
				if Config.System.Callback == "qb" then
					local p = promise.new()
					Core.Functions.TriggerCallback('jim-shops:server:getBlackMarketLoc', function(stash) p:resolve(stash) end)
					coord = Citizen.Await(p)
				elseif Config.System.Callback == "ox" then
					coord = lib.callback.await('jim-shops:server:getBlackMarketLoc', false)
				end
				Locations["blackmarket"]["coords"] = {}
				Locations["blackmarket"]["coords"][1] = coord
			end
			for l, b in pairs(v["coords"]) do
				local label = "Shop - ['"..k.."("..l..")']"
				if not v["hideblip"] then
					Blips[#Blips+1] = makeBlip({coords = b, sprite = v["blipsprite"], col = v["blipcolour"], scale = 0.7, disp = 6, category = nil, name = v["label"]})
				end
				if Config.Overrides.Peds then
					if v["model"] then
						local i = math.random(1, #v["model"])
						loadModel(v["model"][i])
						if IsModelAPed(v["model"][i]) then
							if not Peds[label] then
								Peds[label] = makePed(v["model"][i], b, true, v["scenario"] or nil, nil)
								SetAmbientVoiceName(Peds["Shop - ['"..k.."("..l..")']"], pedVoices[v["model"][i]])
								if GetResourceState("jim-talktonpc") == "started" then exports["jim-talktonpc"]:createDistanceMessage("shopgreetspec", Peds[label], 3.0, false) end
							end
							if not v["killable"] then SetEntityInvincible(Peds[label], true) end
							SetEntityNoCollisionEntity(Peds[label], PlayerPedId(), false)
						end
						if not IsModelAPed(v["model"][i]) then
							if not Peds[label] then
								Peds[#Peds+1] = makeProp({ prop = v["model"][i], coords = b }, true, false)
							end
						end
					end
				end
				if Config.System.Target == "qb" then
					local options = { {
						event = "jim-shops:ShopMenu",
						icon = (v["targetIcon"] or "fas fa-cash-register"),
						label = (v["targetLabel"] or "Browse Shop"),
						item = v["requiredItem"],
						job = v["job"] or nil,
						gang = v["gang"] or nil,
						shoptable = v, name = v["label"], k = k, l = l, },
					}
					if k == "casino" then
						options[#options+1] = {
							action = function() TriggerServerEvent("jim-shops:server:sellChips") end,
							icon = "fab fa-galactic-republic", label = "Trade Chips ($"..Config.Overrides.SellCasinoChips.pricePer.." per chip)",
						}
					end
					if Config.Overrides.Peds then -- if Config.Overrides.Peds is enaabled
						Targets[label] = exports['qb-target']:AddTargetEntity(Peds[label], { options = options, distance = 2.0 })
					else
						Targets[label] = exports['qb-target']:AddCircleZone(label, vector3(b.x, b.y, b.z), 2.0,	{ name=label, debugPoly=Config.System.Debug, useZ=true, },
							{ options = options, distance = 2.0 })
					end
				elseif Config.System.Target == "ox" then
					local options = {{
						event = "jim-shops:ShopMenu",
						icon = (v["targetIcon"] or "fas fa-cash-register"),
						label = (v["targetLabel"] or "Browse Shop"),
						idlabel = label,
						items = v["requiredItem"],
						groups = (v["job"] or v["gang"] or nil),
						shoptable = v,
						name = v["label"],
						k = k,
						l = l,
						canInteract = function(_, distance)
							return distance < 2.0 and true or false
						end
					}}
					if k == "casino" then
						options[#options+1] = {
							onSelect = function() TriggerServerEvent("jim-shops:server:sellChips") end,
							icon = "fab fa-galactic-republic", label = "Trade Chips ($"..Config.Overrides.SellCasinoChips.pricePer.." per chip)", }
					end
					if Config.Overrides.Peds then
						Targets[label] = exports.ox_target:addLocalEntity(Peds[label], options)
					else
						Targets[label] = exports.ox_target:addSphereZone({
							coords = vector3(b.x, b.y, b.z),
							radius = 2.0,
							debug = Config.System.Debug,
							options = options
						})
					end
				else
					if Config.System.Debug then
						print("^5Debug^7: ^2Config option ^6Config.System.Target ^2should be ^7ox ^2or ^7qb")
					end
				end
			end
		end
	end
end)

RegisterNetEvent('jim-shops:ShopMenu', function(data, custom)
	local products,  hasLicence, hasLicenceItems, stashItems, set, vendID = data.shoptable.products, nil, nil, nil, "", data.vendID or nil
	local ShopMenu = {}
	local setheader = " "

	if GetResourceState("jim-talktonpc") == "started" then exports["jim-talktonpc"]:createCam(data.entity, true, "shop", true) end

	if Config.Overrides.Limit and data.vend then
		if not vendID then
			vendID = "["..string.sub(data.shoptable.label, 1, 4)..math.floor(GetEntityCoords(data.entity).x or 1)..math.floor(GetEntityCoords(data.entity).y or 1).."]"
		end

		if Config.System.Callback == "qb" then
			local p = promise.new()
			Core.Functions.TriggerCallback('jim-shops:server:GetStashItems', function(stash) p:resolve(stash) end, vendID)
			stashItems = Citizen.Await(p)
		elseif Config.System.Callback == "ox" then
			stashItems = lib.callback.await('jim-shops:server:GetStashItems', false, vendID)
		end

		if json.encode(stashItems) == "[]" then
			if Config.System.Debug then print("^5Debug^7: ^2Generating Vending Machine Stash^7: ^6"..vendID) end
			TriggerServerEvent("jim-shops:GenerateVend", {data, vendID})
			Wait(1000)
			if Config.System.Callback == "qb" then
				local p = promise.new()
				Core.Functions.TriggerCallback('jim-shops:server:GetStashItems', function(stash) p:resolve(stash) end, vendID)
				stashItems = Citizen.Await(p)
			elseif Config.System.Callback == "ox" then
				stashItems = lib.callback.await('jim-shops:server:GetStashItems', false, vendID)
			end
		end
	end

	if Config.Overrides.Limit and not custom and not data.vend then
		if Config.System.Callback == "qb" then
			local p = promise.new()
			Core.Functions.TriggerCallback('jim-shops:server:GetStashItems', function(stash) p:resolve(stash) end, "["..data.k.."("..data.l..")]")
			stashItems = Citizen.Await(p)
			print(json.encode(stashItems))
		elseif Config.System.Callback == "ox" then
			stashItems = lib.callback.await('jim-shops:server:GetStashItems', false, "["..data.k.."("..data.l..")]")
		end
	end
	if Config.System.Menu == "qb" then
		ShopMenu[#ShopMenu + 1] = {	isDisabled = true, header = data.shoptable["logo"] and "<center><img src="..data.shoptable["logo"].." width=250.0rem>" or data.shoptable["label"],	isMenuHeader = true }
		ShopMenu[#ShopMenu + 1] = { icon = "fas fa-circle-xmark", header = " ", txt = "Close", params = { event = "jim-shops:CloseMenu" } }
	end

	for i = 1, #products do
		local amount, lock = 0, "", false
		if Config.System.Debug then print("^5Debug^7: ^3ShopMenu ^7- ^2Searching for item ^7'^6"..products[i].name.."^7'") end

		if not Core.Shared.Items[products[i].name:lower()] then
			print("^5Debug^7: ^3ShopItems ^7- ^1Can't ^2find item ^7'^6"..products[i].name.."^7'")
		else
			if products[i].price == 0 then price = "Free" else price = "Cost: $"..products[i].price end

			local text = ""
			if products[i].info and products[i].info.item then text = text.."Item: "..products[i].info.item..br end
			text = text..price..br.."Weight: "..(Core.Shared.Items[products[i].name].weight / 1000)..Config.Overrides.Measurement

			if Config.Overrides.Limit and not custom then
				if stashItems[i] then
					if not stashItems[i].amount or stashItems[i].amount == 0 then
						amount = 0
						lock = true
					else
						amount = tonumber(stashItems[i].amount)
					end
					if amount ~= 0 then
						text = price..br.."Amount: x"..amount..br.."Weight: "..(Core.Shared.Items[products[i].name].weight / 1000)..Config.Overrides.Measurement
					else
						text = price..br.."Out Of Stock"..br.."Weight: "..(Core.Shared.Items[products[i].name].weight / 1000)..Config.Overrides.Measurement
					end
				end
			end
			local canSee = false
			if products[i].requiredJob then
				for k, v in pairs(products[i].requiredJob) do
					if Core.Functions.GetPlayerData().job.name == k and Core.Functions.GetPlayerData().job.grade.level >= v then
						canSee = true
					end
				end
			end
			if products[i].requiredGang then
				for i2 = 1, #products[i].requiredGang do
					if Core.Functions.GetPlayerData().gang.name == products[i].requiredGang[i2] then canSee = true end
				end
			end
			if products[i].requiresLicense then
				if Config.System.Callback == "qb" then
					local p = promise.new()
					Core.Functions.TriggerCallback("jim-shops:server:getLicenseStatus", function(hasLic) p:resolve(hasLic) end, products[i].requiresLicense)
					hasLicense = Citizen.Await(p)
				elseif Config.System.Callback == "ox" then
					hasLicense = lib.callback.await('jim-shops:server:getLicenseStatus', false, products[i].requiresLicense)
				end
			end
			if products[i].requiresItem then
				for _, v in pairs(products[i].requiresItem) do canSee = HasItem(v) Wait(0) end
			end
			if canSee or (not products[i].requiresItem and not products[i].requiresLicense and not products[i].requiredGang and not products[i].requiredJob)  then
				ShopMenu[#ShopMenu + 1] = {
					icon = "nui://"..Config.System.img..Core.Shared.Items[products[i].name].image,
					image = "nui://"..Config.System.img..Core.Shared.Items[products[i].name].image,
					header = Core.Shared.Items[products[i].name].label, txt = text, isMenuHeader = lock,
					title = Core.Shared.Items[products[i].name].label, description = text, disabled = Config.System.Menu == "ox" and lock,
					params = { event = "jim-shops:Charge", args = {
						item = products[i].name,
						cost = products[i].price,
						info = products[i].info,
						shoptable = data.shoptable,
						vendID = vendID,
						k = data.k or vendID,
						l = data.l or "",
						amount = amount,
						custom = custom,
					} },
					event = "jim-shops:Charge", args = {
						item = products[i].name,
						cost = products[i].price,
						info = products[i].info,
						shoptable = data.shoptable,
						vendID = vendID,
						k = data.k or vendID,
						l = data.l or "",
						amount = amount,
						custom = custom,
					}
				}
			end
		end
	end
	if Config.System.Menu == "qb" then
		exports[Config.System.MenuExport]:openMenu(ShopMenu)
	elseif Config.System.Menu == "ox" then
		local shopName = ""
		if data.custom or custom then
			shopName = vendID or ("["..data.shoptable.label.."]")
		else
			shopName = vendID or ("["..data.k.."("..data.l..")]")
		end
		lib.registerContext({id = shopName, title = data.shoptable["logo"] and '!['..''.. ']('..data.shoptable["logo"]..')' or data.shoptable["label"], options = ShopMenu})
		lib.showContext(shopName)
	end
end)

--Selling animations are simply a pass item to seller animation
RegisterNetEvent('jim-shops:SellAnim', function(data) local Ped = PlayerPedId()
	if GetResourceState("jim-talktonpc") == "started" then exports["jim-talktonpc"]:injectEmotion("thanks") end
	if string.find(data.shoptable.label, "Vending") then
		loadAnimDict("mp_common")
		loadAnimDict("amb@prop_human_atm@male@enter")
		local model = `prop_paper_bag_small`
		if ItemModels[data.item] then model = ItemModels[data.item] end
		local prop = makeProp({prop = model, coords = vector4(0.0, 0.0, 0.0, 0.0)}, false, false)
		TaskPlayAnim(Ped, "amb@prop_human_atm@male@enter", "enter", 1.0, 1.0, 0.3, 16, 0.2, 0, 0, 0)	--Start animations
		Wait(1000)
		AttachEntityToEntity(prop, Ped, GetPedBoneIndex(Ped, 57005), 0.1, -0.0, 0.0, -90.0, 0.0, 0.0, true, true, false, true, 1, true)
		Wait(1000)
		StopAnimTask(Ped, "amb@prop_human_atm@male@enter", "enter", 1.0)
		unloadAnimDict("mp_common")
		unloadAnimDict("amb@prop_human_atm@male@enter")
		destroyProp(prop) unloadModel(model)
		return
	end
	for _, v in pairs(Peds) do
		if #(GetEntityCoords(Ped) - GetEntityCoords(v)) < 2 then
			ppRot = GetEntityRotation(v) ppheading = GetEntityHeading(v) ppcoords = GetEntityCoords(v)
			loadAnimDict("mp_common")
			loadAnimDict("amb@prop_human_atm@male@enter")
			local model = `prop_paper_bag_small`
			if ItemModels[data.item] then model = ItemModels[data.item] end
			local prop = makeProp({prop = model, coords = vector4(0.0, 0.0, 0.0, 0.0)}, false, false)
			AttachEntityToEntity(prop, v, GetPedBoneIndex(v, 57005), 0.1, -0.0, 0.0, -90.0, 0.0, 0.0, true, true, false, true, 1, true)
			--Calculate if you're facing the ped--
			if tostring(data.shoptable["scenario"]) ~= "PROP_HUMAN_SEAT_CHAIR_FOOD" then ClearPedTasksImmediately(v) end
			if not IsPedHeadingTowardsPosition(Ped, GetEntityCoords(v), 20.0) then TaskTurnPedToFaceCoord(Ped, GetEntityCoords(v), 1500) Wait(1500) end
			TaskPlayAnim(Ped, "amb@prop_human_atm@male@enter", "enter", 1.0, 1.0, 0.3, 16, 0.2, 0, 0, 0)	--Start animations
			TaskPlayAnim(v, "mp_common", "givetake2_b", 1.0, 1.0, 0.3, 16, 0.2, 0, 0, 0)
			Wait(1000)
			AttachEntityToEntity(prop, Ped, GetPedBoneIndex(Ped, 57005), 0.1, -0.0, 0.0, -90.0, 0.0, 0.0, true, true, false, true, 1, true)
            Wait(1000)
            StopAnimTask(Ped, "amb@prop_human_atm@male@enter", "enter", 1.0)
			StopAnimTask(v, "mp_common", "givetake2_b", 1.0)
			--TaskStartScenarioInPlace(v, data.shoptable["scenario"] or Config.Scenarios[math.random(1, #Config.Scenarios)], -1, true)
			unloadAnimDict("mp_common")
			unloadAnimDict("amb@prop_human_atm@male@enter")
			destroyProp(prop) unloadModel(model)
			break
		end
	end
end)

RegisterNetEvent('jim-shops:CloseMenu', function()
	if GetResourceState("jim-talktonpc") == "started" then exports["jim-talktonpc"]:stopCam() end
	exports[Config.System.MenuExport]:closeMenu()
end)

RegisterNetEvent('jim-shops:Charge', function(data) local dialog
	local price = data.cost == "Free" and data.cost or "$"..data.cost
	local weight = Core.Shared.Items[data.item].weight == 0 and "" or "Weight: "..(Core.Shared.Items[data.item].weight / 1000)..Config.Overrides.Measurement

	local header = "<center><p><img src=nui://"..Config.System.img..Core.Shared.Items[data.item].image.." width=100px></p>"..Core.Shared.Items[data.item].label
	if data.shoptable["logo"] then header = "<center><p><img src="..data.shoptable["logo"].." width=150px></img></p>"..header end

	if Config.System.Menu == "ox" then
		local settext = (Config.Overrides.Limit == true and data.amount ~= 0) and "Amnt: "..data.amount.." | Cost: "..price or "Cost: "..price
		local max = data.amount if max == 0 and not Config.Overrides.Limit then max = nil end
		local dialog = exports.ox_lib:inputDialog(Core.Shared.Items[data.item].label, {
			{ type = 'select', label = "Payment Type", default = "cash",
				options = {
					{ value = "cash", label = "Cash", },
					{ value = "bank", label = "Card", },
				}
			},
			{ type = 'number', label = "Amount to buy", description = settext, min = 0, max = max, default = 1 },
		})
		if dialog then
			if data.cost == "Free" then data.cost = 0 end
			if not data.amount == nil then nostash = true end
			TriggerServerEvent('jim-shops:GetItem', dialog[2], dialog[1], data.item, data.shoptable, data.cost, data.info, data.k, data.l or nil, nostash)

		end
	else
		local settext =
		"- Confirm Purchase -"..br..br.. ((Config.Overrides.Limit and data.amount ~= 0) and "Amount: "..data.amount..br or "") ..weight..br.." Cost per item: "..price..br..br.."- Payment Type -"
		local newinputs = {
			{ type = 'radio', name = 'billtype', text = settext, options = { { value = "cash", text = "Cash" }, { value = "bank", text = "Card" } } },
			{ type = 'number', isRequired = true, name = 'amount', text = 'Amount to buy' } }

		local dialog = exports['qb-input']:ShowInput({ header = header, submitText = "Pay", inputs = newinputs })
		if dialog then
			if not dialog.amount then return end
			if Config.Overrides.Limit and data.custom == nil then	if tonumber(dialog.amount) > tonumber(data.amount) then triggerNotify(nil, "Incorrect amount", "error") TriggerEvent("jim-shops:Charge", data) return end end
			if tonumber(dialog.amount) <= 0 then triggerNotify(nil, "Incorrect amount", "error") TriggerEvent("jim-shops:Charge", data) return end
			if data.cost == "Free" then data.cost = 0 end
			if not data.amount then nostash = true end
			TriggerServerEvent('jim-shops:GetItem', dialog.amount, dialog.billtype, data.item, data.shoptable, data.cost, data.info, data.k, data.l or nil, nostash)
		end
	end
end)

AddEventHandler('onResourceStop', function(resource) if resource ~= GetCurrentResourceName() then return end
	if Config.System.Target == "qb" then
		for k in pairs(Targets) do exports['qb-target']:RemoveZone(k) end
	elseif Config.System.Target == "ox" then
		for k in pairs(Targets) do exports.ox_target:removeZone(k) end
	end
	for _, v in pairs(Peds) do unloadModel(v) if IsModelAPed(GetEntityModel(v)) then DeletePed(v) else DeleteObject(v) end end
end)