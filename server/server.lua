

local registeredShops = {}
function registerJimShop(name, label, items, society, coords)
	registeredShops[label] = registeredShops[label] or {}
	registeredShops[label][#registeredShops[label]+1] = { label = label, items = items, society = society, coords = coords }
	debugPrint("^5Debug^7: "..(GetInvokingResource() or "Internal").." ^2Shop ^7'^4"..label.."^7' ^2Registered at^7: "..formatCoord(coords))
end
exports("registerShop", function(...)
	registerJimShop(...)
end)

onResourceStart(function()

	createCallback("jim-shops:checkShopExploit", function(source, shop)
		local src = source
		local ped = GetPlayerPed(src)
		local srcCoords = GetEntityCoords(ped)
		for k in pairs(registeredShops) do
			if shop:find(k) then
				for v = 1, #registeredShops[k] do
					if #(registeredShops[k][v].coords.xy  - srcCoords.xy) <= 10 then
						return true
					end
				end
			end
		end
		return false
	end)

	for k, v in pairs(Products) do -- Scan products table, to remove any items
		debugPrint("^5Debug^7: ^2Scanning product table^7 - ^3Products^7['^6"..k.."^7']")
		for i = 1, #v do
			local item = Products[k][i].name
            if not doesItemExist(item) then
				print("^5Debug^7: ^3Products^7['^6"..k.."^7'] ^2can't find item^7: ^6"..item.."^7")
			end
		end
	end

	for k, v in pairs(Locations) do
		if v.products == nil then
			debugPrint("^5Debug^7: ^3Locations^7['^6"..k.."^7']^2 can't find its product table^7")
		end
		if not v.isVendingMachine and Locations[k]["model"] and next(Locations[k]["model"]) then
			Locations[k]["model"] = { -- Pick a single ped model from the list so all players see same one
				Locations[k]["model"][math.random(1, #Locations[k]["model"])]
			}
		end
		if v.coords and #v.coords > 0 then
			for i = 1, #v.coords do
				registerJimShop(k, v.label, v.products, v.gang or v.job or nil, v.coords[i])
			end
		end
	end

	if Config.Overrides.BlackMarket then -- if true, pick a random coord from table for the market to appear
		Locations["blackmarket"]["coords"] = {
			Locations["blackmarket"]["coords"][math.random(1, #Locations["blackmarket"]["coords"])]
		}
	end
	-- Use global statebag to sync location table between players
	GlobalState.jimShopLocationsData = Locations
	debugPrint("^5Statebag^7: ^2Updating^3 jimShopLocationsData ^2Global Statebag^7")

end, true)

onResourceStop(function()
	-- Ensure statebag is clean
	GlobalState.jimShopLocationsData = nil
end, true)

createCallback('jim-shops:server:getLicenseStatus', function(source, licenseArray)
	local src = source
	local hasLicense = true
	local Player = Core.Functions.GetPlayer(src)
	local licenseTable = Player.PlayerData.metadata["licences"]
	for k, v in pairs(licenseArray) do
		if not licenseTable[v] then hasLicense = false end
	end
	return hasLicense
end)

--Wrapper converting for opening shops externally
RegisterServerEvent('jim-shops:ShopOpen', function(shop, name, shopTable)
	local src = source
	local ped = GetPlayerPed(src)
	local srcCoords = GetEntityCoords(ped)
	local allow = false
	for k in pairs(registeredShops) do
		if shopTable.label:find(k) then
			for v = 1, #registeredShops[k] do
				if #(registeredShops[k][v].coords.xy  - srcCoords.xy) <= 10 then
					allow = true
					break
				else
					allow = false
				end
			end
		end
	end

	if not allow then return end

	local data = {
		shopTable = {
			products = shopTable.items,
			label = shopTable.label,
			societyCharge = shopTable.society or shopTable.societyCharge or nil
		}, custom = true }
	TriggerClientEvent('jim-shops:ShopMenu', src, data, true)
end)

RegisterServerEvent('jim-shops:server:BuyItem', function(data)
	--jsonPrint(data)
	local src = source
	local cost = (data.price * data.amount)
	local balance = data.shopTable.societyCharge
		and getSocietyAccount(data.shopTable.societyCharge)
		or getPlayer(src)[tostring(data.billType)]

	--Inventory space checks
	if canCarry({ [data.item] = data.amount }, src) then
		goto continue
	else
		triggerNotify(getName(data.shop), "Not enough space in inventory", "error", src)
		return
	end
	::continue::

	--Money Check
	if balance <= cost then -- Check for money first if not enough, stop here
		triggerNotify(getName(data.shop), "Not enough money", "error", src)
		return
	end

	-- If its a weapon or a unique item, do this:
	if Items[data.item].type == "weapon" or Items[data.item].unique then
		if Items[data.item].type == "weapon" then data.info = nil end
		for i = 1, data.amount do -- Make a loop to put items into different slots rather than full amount in 1 slot
			addItem(data.item, 1, data.info, src)
			Wait(5)
		end
	else
		addItem(data.item, data.amount, data.info, src) -- if its a normal item, add full amount in one go
	end

	if cost == 0 then
		triggerNotify(nil, "Free item", "success", src)
	else
		if tostring(data.billType) == "society" then
			local societyCharge = data.shopTable.societyCharge or data.society
			triggerNotify(getName(data.shop), "Charing society for purchase", "success", src)
			chargeSociety(societyCharge, cost)
		else
			chargePlayer(cost, tostring(data.billType), src)
		end
	end

	if data.shopTable.societyOwned then
		-- if store is "owned" by a society, send money to that bank account
		-- required the shop table to have `societyOwned = job` otherwise this won't be used
		fundSociety(data.shopTable.societyOwned, cost)
	end
	TriggerClientEvent("jim-shops:SellAnim", src, data)

	--Remove item from stash
	if Config.Overrides.generateStoreLimits and data.stash and not data.custom then
		--jsonPrint(data)
		local stashName = data.vendID or data.shop..(data.shopNum and "_"..data.shopNum or "")

		debugPrint("^5Debug^7: ^2Adjusting cache info^7: '^6"..stashName.."^7'")
		if itemStashCache[stashName] then
			if (itemStashCache[stashName][data.item:lower()].amount - data.amount) <= 0 then
				itemStashCache[stashName][data.item:lower()].amount = 0
			else
				itemStashCache[stashName][data.item:lower()].amount -= data.amount
			end
			debugPrint("^5Debug^7: ^2Removing ^7'^3"..getItemLabel(data.item).."^7' x"..data.amount.." ^2from Shop's Stash^7: ^6"..stashName.."^7")
		else
			debugPrint("^1Error^7: ^2Can't adjust cache info^7: '^6"..stashName.."^7'")
		end
	end
end)