local basketSystem = {}

onResourceStart(function()
	createCallback(getScript()..":server:getBasket", function(source, shopName)
        local src = source
        --print(shopName)
		return basketSystem[shopName] and basketSystem[shopName][src] or {}
	end)

	createCallback(getScript()..":server:editBasketItem", function(source, data)
		local src = source
		local shopName = data.shop and data.shop.."_"..data.shopNum or data.shopTable.label
		debugPrint("^6Debug^7: ^2Editing player ^4"..src.." ^2basket for shop^7: '^3"..shopName.."^7'")
		if data.remove then
			debugPrint("^6Debug^7: ^2Removing item from basket^7: '^3"..getItemLabel(data.item).."^7'")
			if basketSystem[shopName] and basketSystem[shopName][src] and basketSystem[shopName][src][data.item] then
				basketSystem[shopName][src][data.item] = nil
				print("removed")
			end
		else
			if basketSystem[shopName] and basketSystem[shopName][src] and basketSystem[shopName][src][data.item] then
				debugPrint("^6Debug^7: ^2Editing item in basket^7: '^3"..getItemLabel(data.item).."^7' - ^3"..data.amount.."^7' for '^3"..(data.price * data.amount).."^7'")
				basketSystem[shopName][src][data.item].amount = data.amount
				basketSystem[shopName][src][data.item].cost = data.price * data.amount
			end
		end
		return true
	end)

	createCallback(getScript()..":server:clearBasket", function(source, shopName)
        local src = source
        if basketSystem[shopName] and basketSystem[shopName][src] then
			debugPrint("^6Debug^7: ^2Clearing player ^4"..src.." ^2basket for shop^7: '^3"..shopName.."^7'")
            basketSystem[shopName][src] = nil
        end
        return true
    end)
end, true)

RegisterNetEvent(getScript()..":server:addBasketItem", function(data)
    local src = source
    local shopName = data.shop and data.shop.."_"..data.shopNum or data.shopTable.label
	debugPrint("^6Debug^7: ^2Adding item to player ^4"..src.." ^2basket for shop^7: '^3"..shopName.."^7'")
    basketSystem[shopName] = basketSystem[shopName] or {}
    basketSystem[shopName][src] = basketSystem[shopName][src] or {}
	local amount = data.amount
	if basketSystem[shopName][src][data.item] then
		amount += basketSystem[shopName][src][data.item].amount
	end
    basketSystem[shopName][src][data.item] = {
        amount = amount,
        cost = data.price * amount,
    }
    triggerNotify(data.shopTable.label, "Added "..data.amount.." Item(s) to basket", "success", src)
end)

RegisterServerEvent(getScript()..":server:BuyBasketItems", function(data)
    local src = source
	local shopName = data.shop and data.shop.."_"..data.shopNum or data.shopTable.label
    local currentBasket = basketSystem[shopName][src]
    if currentBasket == nil then
        print("ERROR NO BASKET FOUND")
    end
	local src = source
	local cost = data.totalCost
	local balance = data.shopTable.societyCharge
		and getSocietyAccount(data.shopTable.societyCharge)
		or getPlayer(src)[tostring(data.billType)]

	balance = type(balance) ~= "number" and 0 or balance

	--Inventory space checks
    local tempBasket = {}
    for k, v in pairs(currentBasket) do
        tempBasket[k] = v.amount
    end
	if not canCarry(tempBasket, src) then
		triggerNotify(getName(data.shop), "Not enough space in inventory", "error", src)
		return -- Stop here
    end
	print(balance, cost, balance <= cost)
	--Money Check
	if balance < cost then -- Check for money first if not enough, stop here
		triggerNotify(getName(data.shop), "Not enough money", "error", src)
		return
	end

    for k, v in pairs(currentBasket) do
        -- If its a weapon or a unique item, give item individually to stop stacking them:
        if Items[k].type == "weapon" or Items[k].unique then
            if Items[k].type == "weapon" then v.info = nil end
            for i = 1, v.amount do -- Make a loop to put items into different slots rather than full amount in 1 slot
                addItem(k, 1, v.info, src)
                Wait(5)
            end
        else
            addItem(k, v.amount, v.info, src) -- if its a normal item, add full amount in one go
        end
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

	TriggerClientEvent(getScript()..":SellAnim", src, data)

	local stashName = data.vendID or data.shop and data.shop.."_"..data.shopNum or data.shopTable.label
	--Remove item from stash

	if Config.Overrides.generateStoreLimits and itemStashCache[stashName] and not data.custom then
		debugPrint("^5Debug^7: ^2Adjusting cache info^7: '^6"..stashName.."^7'")
		for k, v in pairs(tempBasket) do
			if (itemStashCache[stashName][k:lower()].amount - v) <= 0 then
				itemStashCache[stashName][k:lower()].amount = 0
			else
				itemStashCache[stashName][k:lower()].amount -= v
			end
			debugPrint("^5Debug^7: ^2Removing ^7'^3"..getItemLabel(k).."^7' x"..v.." ^2from Shop's Stash^7: ^6"..stashName.."^7")
		end
	end

	debugPrint("^5Debug^7: ^7["..src.."] ^2Purchase complete^7, ^2clearing basket cache^7")
	basketSystem[shopName][src] = nil
end)