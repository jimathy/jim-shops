onResourceStart(function()
	for k, v in pairs(Products) do -- Scan products table, to remove any items
		debugPrint("^5Debug^7: ^2Scanning product table^7 - ^3Products^7['^6"..k.."^7']")
		for i = 1, #v do
			local item = Products[k][i].name
			if not Items[item] then
				print("^5Debug^7: ^3Config^7.^3Products^7['^6"..k.."^7'] ^2can't find item^7: ^6"..item.."^7")
			end
		end
	end
	for k, v in pairs(Locations) do
		if v.products == nil then
			debugPrint("^5Debug^7: ^3Config^7.^3Locations^7['^6"..k.."^7']^2 can't find its product table^7")
		end
		if not v.isVendingMachine then
			Locations[k]["model"] = { -- Pick a single ped model from the list so all players see same one
				Locations[k]["model"][math.random(1, #Locations[k]["model"])]
			}
		end
	end
	if Config.Overrides.BlackMarket then -- if true, pick a random coord from table for the market to appear
		Locations["blackmarket"]["coords"] = {
			Locations["blackmarket"]["coords"][math.random(1, #Locations["blackmarket"]["coords"])]
		}
	end
end, true)

createCallback("jim-shops:callback:syncShops", function(source)
	return Locations
end)

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
	local data = { shopTable = { products = shopTable.items, label = shopTable.label, societyCharge = shopTable.society or shopTable.societyCharge or nil }, custom = true }
	TriggerClientEvent('jim-shops:ShopMenu', src, data, true)
end)

local function GetTotalWeight(items)
	local weight = 0
	if not items then return 0 end
	for _, item in pairs(items) do
		weight += item.weight * (item.amount or item.count)
	end
	return tonumber(weight)
end

RegisterServerEvent('jim-shops:server:BuyItem', function(data)
	--jsonPrint(data)
	local src = source
	local Player = nil
	local inventory = nil

	--Inventory space checks
	local totalWeight = nil
	if isStarted(QBInv) then
		Player = Core.Functions.GetPlayer(src)
		inventory = Player.PlayerData.items
		totalWeight = GetTotalWeight(inventory)
	elseif isStarted(OXInv) then
		inventory = exports[OXInv]:Inventory(src)
		totalWeight = exports[OXInv]:CanCarryAmount(src, data.item, data.amount)
	end
	-- Check for empty slots
	local slots = 0
	for _ in pairs(inventory) do
		slots += 1
	end
	-- create table and check if the player can acutally hold the amount
	if canCarry({ [data.item] = data.amount }, src) then
		totalWeight += (Items[data.item].weight * data.amount)
	else
		triggerNotify(getName(data.shop), "Not enough space in inventory", "error", src)
		return
	end

	slots = Config.Overrides.MaxSlots - slots
	local balance = data.shopTable.societyCharge and getSocietyAccount(data.shopTable.societyCharge) or getPlayer(src)[tostring(data.billType)]
	local cost = (data.price * data.amount)
	-- If too heavy:
	if (totalWeight + (Items[data.item].weight * data.amount)) > InventoryWeight then
		triggerNotify(getName(data.shop), "Not enough space in inventory", "error", src)
		return
		-- If unique and it would poof away:
	elseif Items[data.item].unique and (tonumber(slots) < tonumber(data.amount)) then
		triggerNotify(getName(data.shop), "Not enough slots in inventory", "error", src)
		return
	end

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
	else		-- if its a normal item, do normal things
		addItem(data.item, data.amount, data.info, src)
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
		-- if store is "owned" by a society, send money to their bank
		-- required the shop table to have `societyOwned = job` otherwise this will fail1
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
			debugPrint("^5Debug^7: ^2Removing ^7'^3"..Items[data.item].label.."^7' x"..data.amount.." ^2from Shop's Stash^7: ^6"..stashName.."^7")
		else
			debugPrint("^1Error^7: ^2Can't adjust cache info^7: '^6"..stashName.."^7'")
		end
	end
end)

RegisterNetEvent('jim-shops:server:sellChips', function()
	local item = Config.Overrides.SellCasinoChips.chipItem
    local src = source
	local _, hasTable = hasItem(item, 1, src)
	if hasTable[item].hasItem then
		removeItem(item, hasTable[item].count, src)
		local price = Config.Overrides.SellCasinoChips.pricePer * hasTable[item].count
		triggerNotify(getName("casino"), "You sold your chips for $"..price, "success", src)
	else
		triggerNotify(getName("casino"), "You don't have any chips to trade", "error", src)
	end
end)
