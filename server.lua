local BlackMarketSyncCoord = nil

AddEventHandler('onResourceStart', function(r) if GetCurrentResourceName() ~= r then return end
	TriggerEvent("jim-shops:MakeStash")
	for k, v in pairs(Products) do
		for i = 1, #v do
			if Config.System.Inv == "qb" then
				if not Core.Shared.Items[Products[k][i].name] then
					print("^5Debug^7: ^3Config^7.^3Products^7['^6"..k.."^7'] ^2can't find item^7: ^6"..Products[k][i].name.."^7")
				end
			elseif Config.System.Inv == "ox" then
				if not exports.ox_inventory:Items(Products[k][i].name) then
					print("^5Debug^7: ^3Config^7.^3Products^7['^6"..k.."^7'] ^2can't find item^7: ^6"..Products[k][i].name.."^7")
				end
			end
		end
	end
	for k, v in pairs(Locations) do
		if v["products"] == nil then
			print("^5Debug^7: ^3Config^7.^3Locations^7['^6"..k.."^7']^2 can't find its product table^7")
		end
		Locations[k]["model"] = { Locations[k]["model"][math.random(1, #Locations[k]["model"])] } -- Pick a single ped model from the list of possible ones
	end
	if Config.Overrides.BlackMarket then
		BlackMarketSyncCoord = Locations["blackmarket"]["coords"][math.random(1, #Locations["blackmarket"]["coords"])]
	end
end)

local function GetStashItems(stashId)
	local items = {}
	local result = MySQL.Sync.fetchScalar('SELECT items FROM stashitems WHERE stash = ?', {stashId})
	if result then
		local stashItems = json.decode(result)
		if stashItems then
			for k, item in pairs(stashItems) do
				local itemInfo = Core.Shared.Items[item.name:lower()]
				if itemInfo then
					items[item.slot] = {
						name = itemInfo["name"],
						amount = tonumber(item.amount) or tonumber(item.count),
						info = item.info ~= nil and item.info or "",
						label = itemInfo["label"],
						description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
						weight = itemInfo["weight"],
						type = itemInfo["type"],
						unique = itemInfo["unique"],
						useable = itemInfo["useable"],
						image = itemInfo["image"],
						slot = item.slot,
					}
				end
			end
		end
	end
	return items
end

--Wrapper converting for opening shops externally
RegisterServerEvent('jim-shops:ShopOpen', function(shop, name, shoptable)
	local data = { shoptable = { products = shoptable.items, label = shoptable.label, }, custom = true }
	TriggerClientEvent('jim-shops:ShopMenu', source, data, true)
end)

local function GetTotalWeight(items)
	local weight = 0
	if not items then return 0 end
	for _, item in pairs(items) do
		weight += item.weight * (item.amount or item.count)
	end
	return tonumber(weight)
end

RegisterServerEvent('jim-shops:GetItem', function(amount, billtype, item, shoptable, price, info, shop, num, nostash)
	local src = source local Player = Core.Functions.GetPlayer(src)
	--Inventory space checks
	local totalWeight = nil
	if Config.System.Inv == "qb" then
		totalWeight = GetTotalWeight(Player.PlayerData.items)
	elseif Config.System.Inv == "ox" then
		local PlayerInventory = exports.ox_inventory.Inventory(src)
		totalWeight = exports.ox_inventory:CanCarryAmount(src, item, amount)
	end
    local maxWeight = 120000 -- Fix until I work out how to get the player weight again
	local slots = 0
	for _ in pairs(Player.PlayerData.items) do slots = slots +1 end
	slots = Config.Overrides.MaxSlots - slots
	local balance = Player.Functions.GetMoney(tostring(billtype))

	if Config.System.Inv == "qb" then
		-- If too heavy:
		if (totalWeight + (Core.Shared.Items[item].weight * amount)) > maxWeight then
			triggerNotify(nil, "Not enough space in inventory", "error", src)
			return
			-- If unique and it would poof away:
		elseif Core.Shared.Items[item].unique and (tonumber(slots) < tonumber(amount)) then
			triggerNotify(nil, "Not enough slots in inventory", "error", src)
			return
		end
	elseif Config.System.Inv == "ox" then
		if not totalWeight then
			triggerNotify(nil, "Not enough space in inventory", "error", src)
			return
		end
	end
	--Money Check
	if balance < (tonumber(price) * tonumber(amount)) then -- Check for money first if not enough, stop here
		triggerNotify(nil, "Not enough money", "error", src)
	end
	-- If its a weapon or a unique item, do this:
	if Config.System.Inv == "qb" then
		if Core.Shared.Items[item].type == "weapon" or Core.Shared.Items[item].unique then
			if Core.Shared.Items[item].type == "weapon" then info = nil end
			for i = 1, amount do -- Make a loop to put items into different slots rather than full amount in 1 slot
				if Player.Functions.AddItem(item, 1, nil, info) then
					if tonumber(i) == tonumber(amount) then -- when its on its last loop do this
						Player.Functions.RemoveMoney(tostring(billtype), (tonumber(price) * tonumber(amount)), 'ticket-payment')
						TriggerClientEvent('inventory:client:ItemBox', src, Core.Shared.Items[item], "add", amount)
						TriggerClientEvent("jim-shops:SellAnim", src, {item = item, shoptable = shoptable})
					end
				else
					triggerNotify(nil, "Can't give item!", "error", src) break -- stop the item giving loop
				end
				Wait(5)
			end
		else
			-- if its a normal item, do normal things
			if Player.Functions.AddItem(item, amount, nil, info) then
				Player.Functions.RemoveMoney(tostring(billtype), (tonumber(price) * tonumber(amount)), 'shop-purchase')
				if Config.Overrides.ApGov then exports['ap-government']:chargeCityTax(Player.PlayerData.source, "Item", (tonumber(price) * tonumber(amount))) end
				TriggerClientEvent('inventory:client:ItemBox', src, Core.Shared.Items[item], "add", amount)
				TriggerClientEvent("jim-shops:SellAnim", src, {item = item, shoptable = shoptable})
			else
				triggerNotify(nil, "Can't give item!", "error", src)
			end
		end
	elseif Config.System.Inv == "ox" then
		local itemInfo = exports.ox_inventory:Items(item)
		if itemInfo.weapon or not itemInfo.stack then
			if itemInfo.weapon then info = nil end
			local numsuccess = 0
			for i = 1, amount do
				local success, response = exports.ox_inventory:AddItem(src, item, 1, info)
				if success then
					numsuccess = numsuccess + 1
				else
					TriggerClientEvent('QBCore:Notify', src, 'Error when giving item', 'error', 2500) break
				end
			end
			if numsuccess > 0 then
				Player.Functions.RemoveMoney(tostring(billtype), (tonumber(price) * numsuccess), 'shop-purchase')
				if Config.Overrides.ApGov then exports['ap-government']:chargeCityTax(Player.PlayerData.source, "Item", (tonumber(price) * tonumber(numsuccess))) end
				TriggerClientEvent('inventory:client:ItemBox', src, item.name, "add", numsuccess)
				TriggerClientEvent('jim-shops:SellAnim', src, {item = item, shoptable = shoptable})
			end
		else
			local success, response = exports.ox_inventory:AddItem(src, item, amount, info)
			if success then
				Player.Functions.RemoveMoney(tostring(billtype), (tonumber(price) * tonumber(amount)), 'ticket-payment')
				if Config.Overrides.ApGov then exports['ap-government']:chargeCityTax(Player.PlayerData.source, "Item", (tonumber(price) * tonumber(amount))) end
				TriggerClientEvent('inventory:client:ItemBox', src, item.name, "add", amount)
				TriggerClientEvent("jim-shops:SellAnim", src, {item = item, shoptable = shoptable})
			else
				TriggerClientEvent('QBCore:Notify', source,  "Can't give item!", "error")
			end
		end
	end
	--Remove item from stash
	if Config.Overrides.Limit and not nostash then
		local stashname = ""
		if num == "" then stashname = shop
		else stashname = "["..shop.."("..num..")]" end
		local stashItems = GetStashItems(stashname)
		if Config.System.Debug then print("^5Debug^7: ^2Retrieving stash info^7: '^6"..stashname.."^7'") end
		for i = 1, #stashItems do
			if stashItems[i].name == item then
				if (stashItems[i].amount - amount) <= 0 then stashItems[i].amount = 0 else stashItems[i].amount = stashItems[i].amount - amount end
				TriggerEvent('jim-shops:server:SaveStashItems', stashname, stashItems)
				if Config.System.Debug then print("^5Debug^7: ^2Removing ^7'^6"..Core.Shared.Items[item].label.." ^2x^6"..amount.." ^2from Shop's Stash^7: '^6"..stashname.."^7'") end
			end
		end
	end
	--Make data to send back to main shop menu
	local data = {}
	data.shoptable = shoptable
	custom = true
	if Config.Overrides.Limit and not nostash then
		custom = nil
		if num == "" then data.vendID = shop data.vend = true
		else data.k = shop data.l = num end
	else
		if Config.System.Menu == "ox" then
			data.k = shop
			data.l = num
		end
	end
	TriggerClientEvent('jim-shops:ShopMenu', src, data, custom)
end)

RegisterNetEvent("jim-shops:MakeStash", function()
	local result = MySQL.Sync.fetchAll('SELECT * FROM stashitems', {1})
	for _, v in pairs(result) do --Clear Vending Machine Stashes
		if string.find(v.stash, "Vend") then MySQL.Async.execute('DELETE FROM stashitems WHERE stash= ?', { v.stash }) end
	end
	for k, v in pairs(Locations) do
		if k ~= "vendingmachine" then
			local stashTable = {}
			for l, b in pairs(v["coords"]) do
				local stashname = "[" .. k .. "(" .. l .. ")]"
				MySQL.Async.execute('DELETE FROM stashitems WHERE stash= ?', {stashname})
				Wait(10)
				for i = 1, #v["products"] do
					if Config.System.Debug then
						print("^5Debug^7: ^3MakeStash ^7- ^2Searching for item ^7'^6"..v["products"][i].name.."^7'")
						if Config.System.Inv == "qb" then
							if not Core.Shared.Items[v["products"][i].name:lower()] then
								print("^5Debug^7: ^3MakeStash ^7- ^2Can't find item ^7'^6"..v["products"][i].name.."^7'")
							end
						elseif Config.System.Inv == "ox" then
							if not exports.ox_inventory:Items(v.products[i].name) then
								print("^5Debug^7: ^3MakeStash ^7- ^2Can't find item ^7'^6"..v["products"][i].name.."^7'")
							end
						end
					end
					local itemInfo = Core.Shared.Items[v["products"][i].name:lower()]
					if itemInfo then
						stashTable[i] = {
							name = itemInfo["name"],
							amount = tonumber(v["products"][i].amount),
							info = v["products"][i].info or nil,
							label = itemInfo["label"],
							description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
							weight = itemInfo["weight"],
							type = itemInfo["type"],
							unique = itemInfo["unique"],
							useable = itemInfo["useable"],
							image = itemInfo["image"],
							slot = i,
						}
						if Config.Overrides.RandomAmount then
							stashTable[i].amount = math.random(1, tonumber(v["products"][i].amount))
						end
						if itemInfo["name"] == Config.CasinoChips then stashTable[i].amount = v["products"][i].amount end
					end
				end
				if Config.Overrides.Limit then TriggerEvent('jim-shops:server:SaveStashItems', "["..k.."("..l..")]", stashTable)
				elseif not Config.Overrides.Limit then stashname = "["..k.."("..l..")]" MySQL.Async.execute('DELETE FROM stashitems WHERE stash= ?', {stashname}) end
			end
		end
	end
end)

RegisterNetEvent("jim-shops:GenerateVend", function(data)
	local stashTable = {}
	local v = data[1].shoptable
	for i = 1, #v["products"] do
		local itemInfo = Core.Shared.Items[v["products"][i].name:lower()]
		if not itemInfo then print("^5Debug^7: ^3MakeStash ^7- ^2Can't find item ^7'^6"..v["products"][i].name.."^7'")
		elseif itemInfo then
			stashTable[i] = {
				name = itemInfo["name"],
				amount = tonumber(v["products"][i].amount),
				info = v["products"][i].info or {},
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = i,
			}
			if Config.Overrides.RandomAmount then stashTable[i].amount = math.random(1, tonumber(v["products"][i].amount)) end
		end
	end
	TriggerEvent('jim-shops:server:SaveStashItems', data[2], stashTable)
end)

--Compatability Wrapper Event for qb-truckerjob to refill shop stashes
RegisterNetEvent("qb-shops:server:RestockShopItems", function(storeinfo)
	local k, l = nil
	local storename = storeinfo
	if string.find(storename, "247supermarket") then k = "247supermarket"
	elseif string.find(storename, "hardware") then k = "hardware"
	elseif string.find(storename, "robsliquor") then k = "robsliquor"
	elseif string.find(storename, "ltdgasoline") then k = "ltdgasoline"
	end
	l = storename:gsub(k,"")
	if l == "" then l = 1 end
	local stashTable = {}
	local item
	for i = 1, #Config.Locations[k]["products"] do
		if Config.System.Debug then --print("^5Debug^7: ^3RestockShopItems ^7- ^3Searching for item ^7'^6"..v["products"][i].name.."^7'")
			if Config.System.Inv == "qb" then
				if not Core.Shared.Items[v["products"][i].name:lower()] then
					print("^5Debug^7: ^3RestockShopItems ^7- ^1Can't ^2find item ^7'^6"..v["products"][i].name.."^7'")
				end
			elseif Config.System.Inv == "ox" then
				item = exports.ox_inventory:Items(Config.Locations[k]["products"][i].name)
				if not item then
					print("^5Debug^7: ^3RestockShopItems ^7- ^1Can't ^2find item ^7'^6"..v["products"][i].name.."^7'")
				end
			end
		end
		if Config.System.Inv == "qb" then
			local itemInfo = Core.Shared.Items[Config.Locations[k]["products"][i].name:lower()]
			if itemInfo then
				stashTable[i] = {
					name = itemInfo["name"],
					amount = tonumber(Config.Locations[k]["products"][i].amount),
					info = {},
					label = itemInfo["label"],
					description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
					weight = itemInfo["weight"],
					type = itemInfo["type"],
					unique = itemInfo["unique"],
					useable = itemInfo["useable"],
					image = itemInfo["image"],
					slot = i,
				}
			end
		elseif Config.System.Inv == "ox" then
			if item then
				stashTable[i] = {
					name = item.name,
					amount = tonumber(Config.Locations[k]["products"][i].amount),
					info = item.info or {},
					slot = i,
				}
				if Config.Overrides.Limit then exports.ox_inventory:AddItem("["..k.."("..l..")]", stashTable[i].name, stashTable[i].amount, stashTable[i].info) end
			end
		end
	end
	if Config.System.Inv == "qb" then
		if Config.Overrides.Limit then TriggerEvent('jim-shops:server:SaveStashItems', "["..k.."("..l..")]", stashTable) end
	end
end)

if Config.System.Callback == "qb" then
	Core.Functions.CreateCallback('jim-shops:server:getBlackMarketLoc', function(source, cb) cb(BlackMarketSyncCoord) end)
	Core.Functions.CreateCallback('jim-shops:server:syncShops', function(source, cb) cb(Locations) end)
	Core.Functions.CreateCallback('jim-shops:server:getLicenseStatus', function(source, cb, licenseArray)
		local src = source
		local hasLicense = true
		local Player = Core.Functions.GetPlayer(src)
		local licenseTable = Player.PlayerData.metadata["licences"]
		for k,v in pairs(licenseArray) do
			if not licenseTable[v] then hasLicense = false end
		end
		cb(hasLicense)
	end)
	Core.Functions.CreateCallback('jim-shops:server:getItemStatus', function(source, cb, itemArray)
		local src = source
		local hasItem = true
		for k,v in pairs(itemArray) do
			if Config.System.Inv == "qb" and not Core.Functions.HasItem(src,v,1) then hasItem = false
			elseif Config.System.Inv == "ox" and exports.ox_inventory:Search(src, count, v) < 1 then hasItem = false end
		end
		cb(hasItem)
	end)

	Core.Functions.CreateCallback('jim-shops:server:GetStashItems',function(source, cb, stashId) cb(GetStashItems(stashId)) end)
elseif Config.System.Callback == "ox" then
	lib.callback.register('jim-shops:server:getBlackMarketLoc', function(source) return GetStashItems(BlackMarketSyncCoord) end)
	lib.callback.register('jim-shops:server:syncShops', function(source) cb(Locations) end)
	lib.callback.register('jim-shops:server:getLicenseStatus', function(source, licenseArray)
		local src = source
		local hasLicense = true
		local Player = Core.Functions.GetPlayer(src)
		local licenseTable = Player.PlayerData.metadata["licences"]
		for k,v in pairs(licenseArray) do
			if not licenseTable[v] then hasLicense = false end
		end
		return hasLicense
	end)
	lib.callback.register('jim-shops:server:getItemStatus', function(source, itemArray)
		local src = source
		local hasItem = true
		for k,v in pairs(itemArray) do
			if Config.System.Inv == "qb" and not Core.Functions.HasItem(src, v, 1) then hasItem = false
			elseif Config.System.Inv == "ox" and exports.ox_inventory:Search(src, 'count', v) < 1 then hasItem = false end
		end
		return hasItem
	end)
	lib.callback.register('jim-shops:server:GetStashItems', function(source, stashId) return GetStashItems(stashId) end)
end

RegisterNetEvent('jim-shops:server:sellChips', function()
    local src = source
    local Player = Core.Functions.GetPlayer(src)
	if Config.System.Inv == "qb" then
		if not Player.Functions.GetItemByName(Config.Overrides.SellCasinoChips.chipItem) then TriggerClientEvent("QBCore:Notify", src, "You don't have any "..Core.Shared.Items[Config.Overrides.SellCasinoChips.chipItem].label.." to sell") return
		elseif Player.Functions.GetItemByName(Config.Overrides.SellCasinoChips.chipItem) then
			local amount = Player.Functions.GetItemByName(Config.Overrides.SellCasinoChips.chipItem).amount
			local price = Config.Overrides.SellCasinoChips.pricePer * amount
			if Player.Functions.RemoveItem(Config.Overrides.SellCasinoChips.chipItem, amount) then
				TriggerClientEvent('QBCore:Notify', src, "You sold your chips for $"..price)
				Player.Functions.AddMoney("cash", price, "sold-casino-chips")
			end
		end
	elseif Config.System.Inv == "ox" then
		local item = exports.ox_inventory:Items(Config.Overrides.SellCasinoChips.chipItem)
		if not Player.Functions.GetItemByName(Config.Overrides.SellCasinoChips.chipItem) then TriggerClientEvent("QBCore:Notify", src, "You don't have any "..item.label.." to sell") return
		elseif Player.Functions.GetItemByName(Config.Overrides.SellCasinoChips.chipItem) then
			local amount = Player.Functions.GetItemByName(Config.Overrides.SellCasinoChips.chipItem).amount
			local price = Config.Overrides.SellCasinoChips.pricePer * amount
			if Player.Functions.RemoveItem(Config.Overrides.SellCasinoChips.chipItem, amount) then
				TriggerClientEvent('QBCore:Notify', src, "You sold your chips for $"..price)
				Player.Functions.AddMoney("cash", price, "sold-casino-chips")
			end
		end
    end
end)

RegisterNetEvent('jim-shops:server:SaveStashItems', function(stashId, items)
	MySQL.Async.insert('INSERT INTO stashitems (stash, items) VALUES (:stash, :items) ON DUPLICATE KEY UPDATE items = :items', { ['stash'] = stashId, ['items'] = json.encode(items) })
end)