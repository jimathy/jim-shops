Targets, Peds, Blips = {}, {}, {}

local pedVoices = { -- Testing forcing certain voices for jim-talktonpc
	[`mp_m_shopkeep_01`] = "MP_M_SHOPKEEP_01_PAKISTANI_MINI_01",
	[`S_F_Y_Shop_LOW`] = "S_F_Y_SHOP_LOW_WHITE_MINI_01",
	[`S_F_Y_SweatShop_01`] = "S_F_Y_SHOP_LOW_WHITE_MINI_01",
	--add ped model and voice names here
}

CreateThread(function()
	Locations = triggerCallback("jim-shops:server:syncShops")
	for k, v in pairs(Locations) do
		if k == "vendingmachine" and Config.Overrides.VendOverride then
			for l, b in pairs(v["coords"]) do
				if Config.Overrides.Peds then
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
				local coord = triggerCallback("jim-shops:server:getBlackMarketLoc")
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
				local options = { {
					icon = (v["targetIcon"] or "fas fa-cash-register"),
					label = (v["targetLabel"] or "Browse Shop"),
					item = v["requiredItem"],
					job = v["job"] or nil,
					gang = v["gang"] or nil,
					action = function()
						TriggerEvent("jim-shops:ShopMenu", { shoptable = v, name = v["label"], k = k, l = l, entity = Peds[label] })
					end,
					},
				}
				if k == "casino" then
					options[#options+1] = {
						action = function() TriggerServerEvent("jim-shops:server:sellChips") end,
						icon = "fab fa-galactic-republic", label = "Trade Chips ($"..Config.Overrides.SellCasinoChips.pricePer.." per chip)",
					}
				end
				if Config.Overrides.Peds then
					Targets[label] = createEntityTarget(Peds[label], options, 2.0)
				else
					Targets[label] = exports['qb-target']:AddCircleZone(label, vector3(b.x, b.y, b.z), 2.0,	{ name=label, debugPoly=Config.System.Debug, useZ=true, },
						{ options = options, distance = 2.0 })
				end
			end
		end
	end
end)

RegisterNetEvent('jim-shops:ShopMenu', function(data, custom)
	local products, hasLicence, hasLicenceItems, stashItems, vendID = data.shoptable.products, nil, nil, {}, data.vendID or nil
	local ShopMenu = {}
	local setheader = " "

	if data.custom and not custom then custom = true end
	if GetResourceState("jim-talktonpc") == "started" then
		exports["jim-talktonpc"]:createCam(data.entity, true, "shop", true)
	end

	if Config.Overrides.Limit and data.vend then
		if not vendID then
			vendID = "["..string.sub(data.shoptable.label, 1, 4)..math.floor(GetEntityCoords(data.entity).x or 1)..math.floor(GetEntityCoords(data.entity).y or 1).."]"
		end
		if Config.System.Callback == "qb" then
			local p = promise.new()
			Core.Functions.TriggerCallback('jim-shops:server:GetStashItems', function(cb) p:resolve(cb) end, vendID)
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
		elseif Config.System.Callback == "ox" then
			stashItems = lib.callback.await('jim-shops:server:GetStashItems', false, "["..data.k.."("..data.l..")]")
		end
	end

	for i = 1, #products do
		local amount, lock = products[i].amount, false
		if Config.System.Debug then print("^5Debug^7: ^3ShopMenu ^7- ^2Searching for item ^7'^6"..products[i].name.."^7'") end

		if not Items[products[i].name:lower()] then
			print("^5Debug^7: ^3ShopItems ^7- ^1Can't ^2find item ^7'^6"..products[i].name.."^7'")
		else
			if products[i].price == 0 then price = "Free" else price = "Cost: $"..products[i].price end

			local text = ""
			if products[i].info and products[i].info.item then text = text.."Item: "..products[i].info.item..br end
			text = text..price..br.."Weight: "..(Items[products[i].name].weight / 1000)..Config.Overrides.Measurement

			if Config.Overrides.Limit and not custom then
				if stashItems[i] then
					if not stashItems[i].amount or stashItems[i].amount == 0 then
						amount = 0
						lock = true
					else
						amount = tonumber(stashItems[i].amount)
					end
					if amount ~= 0 then
						text = price..br.."Amount: x"..amount..br.."Weight: "..(Items[products[i].name].weight / 1000)..Config.Overrides.Measurement
					elseif amount == 0 then
						text = price..br.."Out Of Stock"..br.."Weight: "..(Items[products[i].name].weight / 1000)..Config.Overrides.Measurement
					end
				else
					text = price..br.."Out Of Stock"..br.."Weight: "..(Items[products[i].name].weight / 1000)..Config.Overrides.Measurement
					lock = true
				end
			end
			local canSee = false
			if products[i].requiredJob then
				for k, v in pairs(products[i].requiredJob) do
					if getJob("job").name == k and getJob("job").grade >= v then
						canSee = true
					end
				end
			end
			if products[i].requiredGang then
				for i2 = 1, #products[i].requiredGang do
					if getJob("gang").name == products[i].requiredGang[i2] then canSee = true end
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
				for _, v in pairs(products[i].requiresItem) do canSee = HasItem(v) and hasLicense Wait(0) end
			end
			if canSee or (not products[i].requiresItem and not products[i].requiresLicense and not products[i].requiredGang and not products[i].requiredJob) then
				ShopMenu[#ShopMenu+1] = {
					icon = "nui://"..Config.System.img..Items[products[i].name].image,
					image = "nui://"..Config.System.img..Items[products[i].name].image,
					isMenuHeader = lock,
					header = Items[products[i].name].label, txt = text,
					onSelect = function()
						TriggerEvent("jim-shops:Charge", {
							item = products[i].name,
							cost = products[i].price,
							info = products[i].info,
							shoptable = data.shoptable,
							vendID = vendID,
							k = data.k or vendID,
							l = data.l or "",
							amount = amount,
							custom = custom,
						})
					end,
				}
			end
		end
	end
	local header = ""
	if Config.System.Menu == "qb" then
		header = data.shoptable["logo"] and "<center><img src="..data.shoptable["logo"].." width=250.0rem>" or data.shoptable["label"]
	elseif Config.System.Menu == "ox" then
		header = data.shoptable["logo"] and '!['..''.. ']('..data.shoptable["logo"]..')' or data.shoptable["label"]
	elseif Config.System.Menu == "gta" then
		header =  data.shoptable["label"]
	end
	openMenu(ShopMenu, {
		header = header,
		canClose = true,
		onExit = function() end,
	})
end)

--Selling animations are simply a pass item to seller animation
RegisterNetEvent('jim-shops:SellAnim', function(data)
	local Ped = PlayerPedId()
	if GetResourceState("jim-talktonpc") == "started" then
		exports["jim-talktonpc"]:injectEmotion("thanks")
	end
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

RegisterNetEvent('jim-shops:Charge', function(data) local dialog
	local price = data.cost == "Free" and data.cost or "$"..data.cost
	local weight = Items[data.item].weight == 0 and "" or "Weight: "..(Items[data.item].weight / 1000)..Config.Overrides.Measurement
	local settext = ""
	local header = "<center><p><img src=nui://"..Config.System.img..Items[data.item].image.." width=100px></p>"..Items[data.item].label
	if data.shoptable["logo"] then
		header = "<center><p><img src="..data.shoptable["logo"].." width=150px></img></p>"..header
	end
	local max = data.amount if max == 0 and not Config.Overrides.Limit then max = nil end
	if Config.System.Menu == "ox" then
		settext = (Config.Overrides.Limit == true and data.amount ~= 0) and "Amnt: "..data.amount.." | Cost: "..price or "Cost: "..price
	else
		settext =
		"- Confirm Purchase -"..br..br.. ((Config.Overrides.Limit and data.amount ~= 0) and "Amount: "..data.amount..br or "") ..weight..br.." Cost per item: "..price..br..br.."- Payment Type -"
	end
	local newinputs = { {
			type = 'radio',
			label = "Payment Type",
			name = 'billtype',
			text = settext,
			options = {
				{ value = "cash", text = "Cash" },
				{ value = "bank", text = "Card" }
			}
		},
		{
			type = 'number',
			isRequired = true,
			name = 'amount',
			text = 'Amount to buy',
			txt = settext,
			min = 0, max = max, default = 1
		},
	}
	local dialog = createInput(Config.System.Menu == "qb" and header or Items[data.item].label, newinputs)
	if dialog then
		for k, v in pairs(dialog) do
			if k == 1 then dialog.billtype = v dialog[1] = nil end
			if k == 2 then dialog.amount = v dialog[2] = nil end
			if dialog.billtype == "Card" then dialog.billtype = "bank" end
			if dialog.billtype == "Cash" then dialog.billtype = "cash" end
		end
		if dialog then
			if not dialog.amount then return end
			if Config.Overrides.Limit and data.custom == nil then
				if tonumber(dialog.amount) > tonumber(data.amount) then
					triggerNotify(getName(data.k), "Incorrect amount", "error")
					TriggerEvent("jim-shops:Charge", data)
					return
				end
			end
			if tonumber(dialog.amount) <= 0 then
				triggerNotify(getName(data.k), "Incorrect amount", "error")
				TriggerEvent("jim-shops:Charge", data)
				return
			end
			if data.cost == "Free" then data.cost = 0 end
			if not data.amount then nostash = true end
			TriggerServerEvent('jim-shops:GetItem', tonumber(dialog.amount), dialog.billtype, data.item, data.shoptable, data.cost, data.info, data.k, data.l or nil, nostash)
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

