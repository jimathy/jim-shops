Targets, Peds, Blips = {}, {}, {}

Shops = {
	Stores = {}
}

onPlayerLoaded(function()

    -- Wait for global statebag sync
	while not GlobalState.jimShopLocationsData do Wait(100) end
	Locations = GlobalState.jimShopLocationsData
	debugPrint("^5Statebag^7: ^2Recieving ^4jimShopLocationsData: ^7'^6"..countTable(Locations).."^7'")

	for k, v in pairs(Locations) do
		if not v.isVendingMachine then
			for l, b in pairs(v.coords) do
				local label = locale("target", "shopBlip").." - ['"..k.."("..l..")']"
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
					label = v.targetLabel or locale("target", "browseShop"),
					item = v.requiredItem,
					job = v["job"] or nil,
					gang = v["gang"] or nil,
					action = function(data)
						if not v.products or countTable(v.products) == 0 then
							triggerNotify(nil, locale("error", "noItems"), "error")
							return
						end
						Shops.Stores.Menu({
							shopTable = v,
							name = v.label,
							shop = k,
							shopNum = l,
							entity = type(data) == "table" and data.entity or data
						})
					end,
				},}

				if Config.Overrides.Peds then
					if v["model"] then
						local i = math.random(1, #v.model)
						loadModel(v.model[i])
						if IsModelAPed(v.model[i]) then
							if not Peds[label] then
								makeDistPed(v.model[i], b, true, false, v.scenario, nil, nil, function(ped)
									if v["killable"] then
										SetEntityInvincible(ped, false)
										SetBlockingOfNonTemporaryEvents(ped, false)
										FreezeEntityPosition(ped, false)
									end
								end)
							end
						end
						if not IsModelAPed(v.model[i]) then
							if not Peds[label] then
								Peds[#Peds+1] = makeDistProp({
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


RegisterNetEvent("jim-shops:ShopMenu", function(...)
	Shops.Stores.Menu(...)
end)

Shops.Stores.Menu = function(data, custom)
	if triggerCallback(getScript()..":checkShopExploit", data.shopTable.label) then
	else
		return print("^1Error^7: ^1This shop wasn't registered^7")
	end
	local products, stashItems = data.shopTable.products, {}
	local ShopMenu = {}
	local setheader = " "
	local custom = data.custom or custom

	local header = ""
	if Config.System.Menu == "qb" then
		header = data.shopTable["logo"] and "<center><img src="..data.shopTable["logo"].." width=200px>" or data.shopTable["label"]
	elseif Config.System.Menu == "ox" then
		header = data.shopTable["logo"] and "![".."".."]("..data.shopTable["logo"]..")" or data.shopTable["label"]
	else
		header =  data.shopTable["label"]
	end

	if isStarted("jim-talktonpc") then
		exports["jim-talktonpc"]:createCam(data.entity, true, "shop", true)
	end
	local countBasket = function(table)
		local count = 0
		local cost = 0
		for k, v in pairs(table) do
			if doesItemExist(k) then
				count += v.amount
				cost += v.cost
			end
		end
		return count, cost
	end
	local currentBasket = {}
	if Config.Overrides.BasketSystem then
		jsonPrint(data)
		currentBasket = triggerCallback(getScript()..":server:getBasket", data.shop and data.shop.."_"..data.shopNum or data.shopTable.label)
		jsonPrint(currentBasket)
		local countedItems, countedPrice = countBasket(currentBasket)
		if not data.goBack then
			ShopMenu[#ShopMenu+1] = {
				header = countedItems == 0 and locale("basket", "basketEmpty") or locale("basket", "itemBasket"),
				txt = countedItems > 0 and (countedItems.." "..locale("basket", "items")..br..curVal..cv(countedPrice)) or nil,
				icon = "fas fa-basket-shopping",
				disabled = countedItems == 0,
				onSelect = function()
					basketFunc.viewMenu({
						currentBasket = currentBasket,
						prevData = data,
						custom = custom,
					})
				end,
			}
		end
	end
	-- Must be a subbed menu
	if products[1] == nil then
		for k, v in pairsByKeys(products) do
			local itemList = v.Items or v.items
			local countItems = function(table)
				local count = 0
				for i = 1, #table do
					if doesItemExist(table[i].name) then
						count += 1
					end
				end
				return count
			end
			ShopMenu[#ShopMenu+1] = {
				header = v.header or ("Sub Menu "..k),
				txt = countItems(itemList).." "..locale("general", "products"),
				icon = invImg(itemList[1].name),
				onSelect = function()
					local newTable = cloneTable(data)

					-- store original table to be used in return button
					newTable.origProducts = newTable.shopTable.products

					-- Swap out menu items with embedded items
					newTable.shopTable.products = v.Items or v.items

					newTable.goBack = function()
						newTable.shopTable.products = newTable.origProducts
						Shops.Stores.Menu(newTable, custom)
					end
					Shops.Stores.Menu(newTable, custom)
				end,
				onBack = function()
					Shops.Stores.Menu(data, custom)
				end,
			}
		end
		openMenu(ShopMenu, { header = header, canClose = true })
		return
	end
	if Config.Overrides.generateStoreLimits and not custom then
		stashItems = triggerCallback(getScript()..":callback:GetStashItems", data.shop.."_"..data.shopNum)
	end
	if data.goBack then
		ShopMenu[#ShopMenu+1] = {
			header = locale("general", "goBack"),
			icon = "fa-solid fa-arrow-rotate-left",
			onSelect = function()
				local backFunc = data.goBack
				data.goBack = nil
				return backFunc()
			end,
		}
	end
	for i = 1, #products do
		local amount, lock = products[i].amount, false

		local item = products[i].name:lower()
		if not doesItemExist(item) then
			print("^1Error^7: ^3ShopMenu ^7- ^2Can't find item ^7'^6"..item.."^7'")
		else
			local price = products[i].price <= 0 and locale("general", "free") or locale("general", "cost").." "..curVal..products[i].price

			local text = (products[i].info and products[i].info.item) and (products[i].info.item..br) or ""..br
			text = text..price..br..locale("general", "weight").." "..(Items[item].weight / 1000)..Config.Overrides.Measurement

			if Config.Overrides.generateStoreLimits and not custom then
				if stashItems[item] then
					if not stashItems[item].amount or stashItems[item].amount == 0 then
						amount = 0
						lock = true
					else
						amount = tonumber(stashItems[item].amount)
					end
					amount -= (currentBasket[item] and currentBasket[item].amount) or 0
					text =
						price..
						br..
						(amount <= 0 and locale("general", "outOfStock") or locale("general", "amount")..": x"..amount)..
						br..
						locale("general", "weight").." "..(Items[item].weight / 1000)..Config.Overrides.Measurement
				else
					text =
						price..
						br..
						locale("general", "outOfStock")..
						br..
						locale("general", "amount")..(Items[item].weight / 1000)..Config.Overrides.Measurement
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
			if products[i].requiredGang then
				canSee = false
				for k, v in pairs(products[i].requiredGang) do
					if hasJob(k, nil, v) then
						canSee = true
					end
				end
			end
			if products[i].requiresLicense then
				canSee = false
				local hasLicense = triggerCallback(getScript()..":server:getLicenseStatus", false, products[i].requiresLicense)
				if hasLicense == true then
					if products[i].type == "gun" then
						local hasPurchased = triggerCallback(getScript()..":server:checkifweaponpurchased", false, products[i].requiresLicense)
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
					image = invImg(products[i].name),
					isMenuHeader = lock,
					header = getItemLabel(products[i].name),
					txt = text,

					onSelect = function()
						Shops.Stores.Charge({
							item = products[i].name,
							cost = products[i].price,
							info = products[i].info,
							origProducts = data.origProducts,
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
    local price = data.cost == locale("general", "free") and data.cost or curVal..data.cost
    local weight = Items[data.item].weight == 0 and "" or locale("general", "weight").." "..(Items[data.item].weight / 1000)..Config.Overrides.Measurement
    local settext = ""
    local header = "<center><p><img src=nui://"..invImg(data.item:lower()).." width=100px></p>"..getItemLabel(data.item)
    if data.shopTable["logo"] then
        header = "<center><p><img src="..data.shopTable["logo"].." width=150px></img></p>"..header
    end
    local max = data.amount if max == 0 and not Config.Overrides.generateStoreLimits then max = nil end
    if Config.System.Menu == "qb" then
        settext =
			"- "..locale("general", "confirm").." -"..
			br..
			br..
			((Config.Overrides.generateStoreLimits and data.amount ~= 0) and locale("general", "amount")..": "..data.amount..br or "")..
			weight..
			br.." "..locale("general", "costPerItem").." "..price..
			br..
			br.."- "..locale("general", "paymentType").." -"
    else
        settext =
            (Config.Overrides.generateStoreLimits == true and data.amount ~= 0) and
            locale("general", "amount")..": "..data.amount.." | "..locale("general", "cost").." "..price or locale("general", "cost").." "..price
    end
	local dialogTable = {}
	if price ~= curVal.."0" and not Config.Overrides.BasketSystem then

		dialogTable = {
			{
				type = 'radio',
				label = locale("general", "paymentType"),
				name = 'billtype',
				text = settext,
				options = {
					{ value = "cash", text = locale("general", "cash") },
					{ value = "bank", text = locale("general", "card") },
					data.shopTable.societyCharge and { value = "society", text = lcoale("general", "socierty") } or nil,
				}
			},
			{
				type = 'number',
				isRequired = true,
				name = 'amount',
				text = locale("general", "amountToBuy"),
				txt = settext,
				min = 0, max = max, default = 1
			}
		}

	else

        dialogTable = {
			{
				type = 'number',
				isRequired = true,
				name = 'amount',
				text = locale("general", "amountToBuy"),
				txt = settext,
				min = 0, max = max, default = 1
			}
	}
	end
	local dialog = createInput(Config.System.Menu == "qb" and header or getItemLabel(data.item), dialogTable)

    if dialog then
		local amount, billType = 0, nil
        if dialog[1] then   -- if ox menu, auto adjust values
			if not dialog[2] then
				amount = dialog[1]
				billType = "cash"
			else
				amount = dialog[2]
				billType = dialog[1]
			end
		else
			billType = dialog.billtype or "cash"
			amount = tonumber(dialog.amount)
		end

		if Config.Overrides.generateStoreLimits and not data.custom then
			if amount > max then
				triggerNotify(getName(data.shop), locale("error", "incorrectAmount"), "error")
				if Config.Overrides.BasketSystem then
					-- Force return to correct table
					local newTable = cloneTable(data)
					newTable.goBack = newTable.origProducts and (function()
						newTable.shopTable.products = newTable.origProducts
						Shops.Stores.Menu(newTable, data.custom)
					end) or nil
					Shops.Stores.Menu(newTable, data.custom)
				else
					Shops.Vending.Charge(data)
				end
				return
			end
		end

		if amount <= 0 then
				triggerNotify(getName(data.shop), locale("error", "incorrectAmount"), "error")
			if Config.Overrides.BasketSystem then
			-- Force return to correct table
			local newTable = cloneTable(data)
				newTable.goBack = newTable.origProducts and (function()
					newTable.shopTable.products = newTable.origProducts
					Shops.Stores.Menu(newTable, data.custom)
				end) or nil
				Shops.Stores.Menu(newTable, data.custom)
			else
				Shops.Vending.Charge(data)
			end
			return
		end
		if data.cost == locale("general", "free") then
			data.cost = 0
		end

		if isStarted("jim-talktonpc") and not Config.Overrides.BasketSystem then
			exports["jim-talktonpc"]:stopCam()
		end
		local newData = {
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
		if Config.Overrides.BasketSystem then
			TriggerServerEvent(getScript()..":server:addBasketItem", newData)
			Wait(300)

			-- Force return to correct table
			local newTable = cloneTable(data)
			newTable.goBack = newTable.origProducts and (function()
				newTable.shopTable.products = newTable.origProducts
				Shops.Stores.Menu(newTable, data.custom)
			end) or nil
			Shops.Stores.Menu(newTable, data.custom)

		else
			TriggerServerEvent(getScript()..":server:BuyItem", newData)
		end
	end
end

--Selling animations are simply a pass item to seller animation
RegisterNetEvent(getScript()..":SellAnim", function(data)
	local Ped = PlayerPedId()
	if checkExportExists("jim-talktonpc", "injectEmotion") then
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