local QBCore = exports['qb-core']:GetCoreObject()

AddEventHandler('onResourceStart', function(resource)
	if GetCurrentResourceName() == resource then 
		TriggerEvent("jim-shops:MakeStash")
	end 
end)

local function GetStashItems(stashId)
	local items = {}
	local result = MySQL.Sync.fetchScalar('SELECT items FROM stashitems WHERE stash = ?', {stashId})
	if result then
		local stashItems = json.decode(result)
		if stashItems then
			for k, item in pairs(stashItems) do
				local itemInfo = QBCore.Shared.Items[item.name:lower()]
				if itemInfo then
					items[item.slot] = {
						name = itemInfo["name"],
						amount = tonumber(item.amount),
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

RegisterServerEvent('jim-shops:GetItem', function(amount, billtype, item, shoptable, price, info, shop, num, nostash)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	--Inventory space checks
	local totalWeight = QBCore.Player.GetTotalWeight(Player.PlayerData.items)
    local maxWeight = QBCore.Config.Player.MaxWeight
	local balance = Player.Functions.GetMoney(tostring(billtype))
	if (totalWeight + (QBCore.Shared.Items[item].weight * amount)) > maxWeight then 
		TriggerClientEvent("QBCore:Notify", src, "Not enough space in inventory", "error") 
	else
		--Money checks
		if balance >= (tonumber(price) * tonumber(amount)) then 
			Player.Functions.RemoveMoney(tostring(billtype), (tonumber(price) * tonumber(amount)), 'ticket-payment')
		else 
			TriggerClientEvent("QBCore:Notify", src, "Not enough money", "error") return
		end
		if QBCore.Shared.Items[item].type == "weapon" then
			Player.Functions.AddItem(item, amount)
		else
			Player.Functions.AddItem(item, amount, nil, info)
		end
		TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add", amount)
		if Config.Limit and not nostash then
			stashItems = GetStashItems("["..shop.."("..num..")]")
			for i = 1, #stashItems do
				if stashItems[i].name == item then
					if (stashItems[i].amount - amount) <= 0 then stashItems[i].amount = 0 else stashItems[i].amount = stashItems[i].amount - amount end 
					TriggerEvent('qb-inventory:server:SaveStashItems', "["..shop.."("..num..")]", stashItems)
					if Config.Debug then print("Removing "..QBCore.Shared.Items[item].label.." x"..amount.." from Shop's Stash: '["..shop.."("..num..")]") end
				end
			end
		end
	end
	
	--Make data to send back to main shop menu
	local data = {}
	data.shoptable = shoptable
	custom = true
	if Config.Limit and not nostash then
		custom = nil
		data.k = shop 
		data.l = num
	end
	TriggerClientEvent('jim-shops:ShopMenu', src, data, custom)
end)

RegisterNetEvent("jim-shops:MakeStash", function ()
	for k, v in pairs(Config.Locations) do
		local stashTable = {}
		for l, b in pairs(v["coords"]) do
			for i = 1, #v["products"] do
				local itemInfo = QBCore.Shared.Items[v["products"][i].name:lower()]
				stashTable[i] = {
					name = itemInfo["name"],
					amount = tonumber(v["products"][i].amount),
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
		if Config.Limit then TriggerEvent('qb-inventory:server:SaveStashItems', "["..k.."("..l..")]", stashTable)
		elseif Config.Limit == false then stashname = "["..k.."("..l..")]" MySQL.Async.execute('DELETE FROM stashitems WHERE stash= ?', {stashname}) end 
		end
	end

end)

QBCore.Functions.CreateCallback('jim-shops:server:getLicenseStatus', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local licenseTable = Player.PlayerData.metadata["licences"]
    local licenseItem = Player.Functions.GetItemByName("weaponlicense")
    cb(licenseTable.weapon, licenseItem)
end)

