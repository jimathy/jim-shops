local QBCore = exports['qb-core']:GetCoreObject()

--Wrapper converting for opening shops externally
RegisterServerEvent('jim-shops:ShopOpen', function(shop, name, shoptable)
	local data = { shoptable = { products = shoptable.items, label = shoptable.label }, }
	TriggerClientEvent('jim-shops:ShopMenu', source, data)
end)

RegisterServerEvent('jim-shops:GetItem', function(amount, billtype, item, shoptable, name, price)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	--Inventory space checks
	local totalWeight = QBCore.Player.GetTotalWeight(Player.PlayerData.items)
    local maxWeight = QBCore.Config.Player.MaxWeight
	local balance = Player.Functions.GetMoney(tostring(billtype))
	print(balance)
	if (totalWeight + (QBCore.Shared.Items[item].weight * amount)) > maxWeight then 
		TriggerClientEvent("QBCore:Notify", src, "Not enough space in inventory", "error") 
	else
		--Money checks
		if balance >= (tonumber(price) * tonumber(amount)) then 
			Player.Functions.RemoveMoney(tostring(billtype), (tonumber(price) * tonumber(amount)), 'ticket-payment')
		else 
			TriggerClientEvent("QBCore:Notify", src, "Not enough money", "error") return
		end
		Player.Functions.AddItem(item, amount, false, {["quality"] = nil})
		TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add", amount)
		--Make data to send back to main shop menu
		
	end
	
	local data = {}
	data.shoptable = shoptable
	data.name = name
	TriggerClientEvent('jim-shops:ShopMenu', src, data)
end)

QBCore.Functions.CreateCallback('jim-shops:server:getLicenseStatus', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local licenseTable = Player.PlayerData.metadata["licences"]
    local licenseItem = Player.Functions.GetItemByName("weaponlicense")
    cb(licenseTable.weapon, licenseItem)
end)