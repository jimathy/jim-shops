Targets, Peds, Blips = {}, {}, {}

Shops = {
	Stores = {}
}

onPlayerLoaded(function()
	Locations = triggerCallback("jim-shops:callback:syncShops")
	for k, v in pairs(Locations) do
		if not v.isVendingMachine then
			for l, b in pairs(v.coords) do
				local label = "Shop - ['"..k.."("..l..")']"
				if not v["hideblip"] then
					Blips[#Blips+1] = makeBlip({
						coords = b,
						sprite = v.blipsprite,
						col = v.blipcolour,
						scale = 0.7,
						disp = 6,
						category = nil,
						name = v.label
					})
				end
				local options = { {
					icon = v.targetIcon or "fas fa-cash-register",
					label = v.targetLabel or "Browse Shop",
					item = v.requiredItem,
					job = v["job"] or nil,
					gang = v["gang"] or nil,
					action = function(data)
						Shops.Stores.Menu({
							shopTable = v,
							name = v.label,
							shop = k,
							shopNum = l,
							entity = type(data) == "table" and data.entity or data
						})
					end,
				},}
				if v.isCasino then
					options[#options+1] = {
						action = function()
							TriggerServerEvent("jim-shops:server:sellChips")
						end,
						icon = "fab fa-galactic-republic",
						label = "Trade Chips ($"..Config.Overrides.SellCasinoChips.pricePer.." per chip)",
					}
				end
				if Config.Overrides.Peds then
					if v["model"] then
						local i = math.random(1, #v.model)
						loadModel(v.model[i])
						if IsModelAPed(v.model[i]) then
							if not Peds[label] then
								makeDistPed(v.model[i], b, true, false, v.scenario, nil, nil)
							end
							-- if not v["killable"] then SetEntityInvincible(Peds[label], true) end
							-- SetEntityNoCollisionEntity(entity, PlayerPedId(), false)
						end
						if not IsModelAPed(v.model[i]) then
							if not Peds[label] then
								Peds[#Peds+1] = makeProp({
									prop = v.model[i],
									coords = b
								}, true, false)
							end
						end
					end
				end

				createCircleTarget({ label, vec3(b.x, b.y, b.z), 1.0,
					{
						name = label,
						debugPoly = debugMode,
						useZ = true
					}
				}, options, 1.5)
			end
		end
	end
end, true)


RegisterNetEvent('jim-shops:ShopMenu', function(data, custom)
	Shops.Stores.Menu(data, custom)
end)

Shops.Stores.Menu = function(data, custom)
	local products, stashItems = data.shopTable.products, {}
	local ShopMenu = {}
	local setheader = " "
	local custom = data.custom or custom

	if isStarted("jim-talktonpc") then
		exports["jim-talktonpc"]:createCam(data.entity, true, "shop", true)
	end

	--if data.shopTable.products

	if Config.Overrides.generateStoreLimits and not custom then
		stashItems = triggerCallback('jim-shops:callback:GetStashItems', data.shop.."_"..data.shopNum)
	end

	for i = 1, #products do
		local amount, lock = products[i].amount, false

		local item = products[i].name:lower()
		if not Items[item] then
			print("^1Error^7: ^3ShopMenu ^7- ^2Can't find item ^7'^6"..item.."^7'")
		else
			local price = products[i].price <= 0 and "Free" or "Cost: $"..products[i].price

			local text = (products[i].info and products[i].info.item) and ("Item: "..products[i].info.item..br) or ""..br
			text = text..price..br.."Weight: "..(Items[item].weight / 1000)..Config.Overrides.Measurement

			if Config.Overrides.generateStoreLimits and not custom then
				if stashItems[item] then
					if not stashItems[item].amount or stashItems[item].amount == 0 then
						amount = 0
						lock = true
					else
						amount = tonumber(stashItems[item].amount)
					end
					text = price..br..(amount <= 0 and "Out Of Stock" or"Amount: x"..amount)..br.."Weight: "..(Items[item].weight / 1000)..Config.Overrides.Measurement
				else
					text = price..br.."Out Of Stock"..br.."Weight: "..(Items[item].weight / 1000)..Config.Overrides.Measurement
					lock = true
				end
			end
			local canSee = true
			if products[i].requiredJob then
				canSee = false
				for k, v in pairs(products[i].requiredJob) do
					if hasJob(k, nil, v) then
						canSee = true
					end
				end
			end
			--[[if products[i].requiredGang then
				canSee = false
				for i2 = 1, #products[i].requiredGang do
					if getJob("gang").name == products[i].requiredGang[i2] then
						canSee = true
					end
				end
			end]]
			if products[i].requiresLicense then
				canSee = false
				local hasLicense = triggerCallback('jim-shops:server:getLicenseStatus', false, products[i].requiresLicense)
				if hasLicense == true then
					if products[i].type == "gun" then
						local hasPurchased = triggerCallback('jim-shops:server:checkifweaponpurchased', false, products[i].requiresLicense)
						canSee = not hasPurchased
					else
						canSee = true
					end
				end
			end
			if products[i].requiresItem then
				canSee = false
				for _, v in pairs(products[i].requiresItem) do
					canSee = hasItem(v, 1)
					Wait(0)
				end
			end

			if canSee then
				ShopMenu[#ShopMenu+1] = {
					icon = invImg(products[i].name),
					isMenuHeader = lock,
					header = Items[products[i].name].label, txt = text,
					onSelect = function()
						Shops.Stores.Charge({
							item = products[i].name,
							cost = products[i].price,
							info = products[i].info,
							shopTable = data.shopTable,
							shop = data.shop,
							shopNum = data.shopNum or nil,
							amount = amount,
							entity = data.entity,
							custom = custom,
						})
					end,
				}
			end
		end
	end
	local header = ""
	if Config.System.Menu == "qb" then
		header = data.shopTable["logo"] and "<center><img src="..data.shopTable["logo"].." width=200px>" or data.shopTable["label"]
	elseif Config.System.Menu == "ox" then
		header = data.shopTable["logo"] and '!['..''.. ']('..data.shopTable["logo"]..')' or data.shopTable["label"]
	elseif Config.System.Menu == "gta" then
		header =  data.shopTable["label"]
	end
	openMenu(ShopMenu, {
		header = header,
		canClose = true,
		onExit = function()
			if isStarted("jim-talktonpc") then
				exports["jim-talktonpc"]:stopCam()
			end
		end,
	})
end

Shops.Stores.Charge = function(data)
	jsonPrint(data)
    local price = data.cost == "Free" and data.cost or "$"..data.cost
    local weight = Items[data.item].weight == 0 and "" or "Weight: "..(Items[data.item].weight / 1000)..Config.Overrides.Measurement
    local settext = ""
    local header = "<center><p><img src=nui://"..invImg(data.item:lower()).." width=100px></p>"..Items[data.item]?.label
    if data.shopTable["logo"] then
        header = "<center><p><img src="..data.shopTable["logo"].." width=150px></img></p>"..header
    end
    local max = data.amount if max == 0 and not Config.Overrides.generateStoreLimits then max = nil end
    if Config.System.Menu == "ox" then
        settext = (Config.Overrides.generateStoreLimits == true and data.amount ~= 0) and "Amnt: "..data.amount.." | Cost: "..price or "Cost: "..price
    else
        settext =
        "- Confirm Purchase -"..br..br.. ((Config.Overrides.generateStoreLimits and data.amount ~= 0) and "Amount: "..data.amount..br or "") ..weight..br.." Cost per item: "..price..br..br.."- Payment Type -"
    end
	--print(price, type(price), price == "$0")
	local dialogTable = {}
	if price ~= "$0" then
		dialogTable = {
			{
				type = 'radio',
				label = "Payment Type",
				name = 'billtype',
				text = settext,
				options = {
					{ value = "cash", text = "Cash" },
					{ value = "bank", text = "Card" },
					data.shopTable.societyCharge and { value = "society", text = "Society" } or nil,
				}
			},
			{
				type = 'number',
				isRequired = true,
				name = 'amount',
				text = 'Amount to buy',
				txt = settext,
				min = 0, max = max, default = 1
			}
		}
	else

        dialogTable = {{
            type = 'number',
            isRequired = true,
            name = 'amount',
            text = 'Amount to buy',
            txt = settext,
            min = 0, max = max, default = 1
        }}
	end
	local dialog = createInput(Config.System.Menu == "qb" and header or Items[data.item].label, dialogTable)

    if dialog then
		jsonPrint(dialog)
		local amount, billType = 0, nil
        if dialog[1] then   -- if ox menu, auto adjust values
			if not dialog[2] then
				amount = dialog[1]
			else
				amount = dialog[2]
				billType = dialog[1]
			end
		else
			billType = dialog.billtype
			amount = tonumber(dialog.amount)
		end

		if Config.Overrides.generateStoreLimits and not data.custom then
			if amount > max then
				triggerNotify(getName(data.shop), "Incorrect amount", "error")
				Shops.Vending.Charge(data)
				return
			end
		end

		if amount <= 0 then
			triggerNotify(getName(data.shop), "Incorrect amount", "error")
			Shops.Vending.Charge(data)
			return
		end
		if data.cost == "Free" then
			data.cost = 0
		end

		if isStarted("jim-talktonpc") then
			exports["jim-talktonpc"]:stopCam()
		end
		TriggerServerEvent("jim-shops:server:BuyItem",
			{
				amount = amount,
				billType = billType,
				item = data.item,
				shopTable = data.shopTable,
				price = data.cost,
				info = data.info or nil,
				shop = data.shop,
				shopNum = data.shopNum or nil,
				entity = data.entity or nil,
				stash = data.amount and true or false,
				custom = data.custom,
			}
		)
	end
end

--Selling animations are simply a pass item to seller animation
RegisterNetEvent('jim-shops:SellAnim', function(data)
	local Ped = PlayerPedId()
	if isStarted("jim-talktonpc") then
		exports["jim-talktonpc"]:injectEmotion("thanks")
	end
	if data.entity then
		if #(GetEntityCoords(Ped) - GetEntityCoords(data.entity)) < 2 then

			local model = ItemModels[data.item] and ItemModels[data.item] or "prop_paper_bag_small"

			local prop = makeProp({ prop = model, coords = vector4(0.0, 0.0, 0.0, 0.0) }, false, false)
			AttachEntityToEntity(prop, data.entity, GetPedBoneIndex(data.entity, 57005), 0.1, -0.0, 0.0, -90.0, 0.0, 0.0, true, true, false, true, 1, true)
			--Calculate if you're facing the ped--
			if tostring(data.shopTable["scenario"]) ~= "PROP_HUMAN_SEAT_CHAIR_FOOD" then
				ClearPedTasksImmediately(data.entity)
			end
			if not IsPedHeadingTowardsPosition(Ped, GetEntityCoords(data.entity), 20.0) then
				TaskTurnPedToFaceCoord(Ped, GetEntityCoords(data.entityv), 1500)
				Wait(1500)
			end
			playAnim("amb@prop_human_atm@male@enter", "enter", 0.3, 16, Ped, 1.0)
			playAnim("mp_common", "givetake2_b", 0.3, 16, data.entity, 1.0)

			Wait(1000)
			if data.isVendingMachine then
				Shops.Vending.Menu(data) -- Open store here so players dont wait too long
			else
				Shops.Stores.Menu(data) -- Open store here so players dont wait too long
			end
			AttachEntityToEntity(prop, Ped, GetPedBoneIndex(Ped, 57005), 0.1, -0.0, 0.0, -90.0, 0.0, 0.0, true, true, false, true, 1, true)
			Wait(1000)
			stopAnim("amb@prop_human_atm@male@enter", "enter", Ped)
			stopAnim("mp_common", "givetake2_b", data.entity)

			--TaskStartScenarioInPlace(v, data.shopTable["scenario"] or Config.Scenarios[math.random(1, #Config.Scenarios)], -1, true)
			destroyProp(prop)
			unloadModel(model)
		end
	else
		if data.isVendingMachine then
			Shops.Vending.Menu(data)
		else
			Shops.Stores.Menu(data)
		end
	end
end)