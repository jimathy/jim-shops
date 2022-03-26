local QBCore = exports['qb-core']:GetCoreObject()

PlayerJob = {}
RegisterNetEvent('QBCore:Client:OnPlayerLoaded') AddEventHandler('QBCore:Client:OnPlayerLoaded', function() QBCore.Functions.GetPlayerData(function(PlayerData) PlayerJob = PlayerData.job end) end)
RegisterNetEvent('QBCore:Client:OnJobUpdate') AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo) PlayerJob = JobInfo end)
RegisterNetEvent('QBCore:Client:SetDuty') AddEventHandler('QBCore:Client:SetDuty', function(duty) onDuty = duty end)
AddEventHandler('onResourceStart', function(resource) if GetCurrentResourceName() == resource then QBCore.Functions.GetPlayerData(function(PlayerData) PlayerJob = PlayerData.job end) end end)

CreateThread(function()
	for k, v in pairs(Config.Locations) do
		for l, b in pairs(v["coords"]) do
			StoreBlip = AddBlipForCoord(b)
			SetBlipSprite(StoreBlip, Config.Locations[k]["blipsprite"])
			SetBlipScale(StoreBlip, 0.7)
			SetBlipDisplay(StoreBlip, 6)
			if Config.Locations[k]["products"] == Config.Products["normal"] then SetBlipColour(StoreBlip, 2)
			elseif Config.Locations[k]["products"] == Config.Products["weapons"] then SetBlipColour(StoreBlip, 1)
			elseif Config.Locations[k]["products"] == Config.Products["hardware"] then SetBlipColour(StoreBlip, 5)
			else SetBlipColour(StoreBlip, 0) end
			SetBlipAsShortRange(StoreBlip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentSubstringPlayerName(Config.Locations[k]["label"])
			EndTextCommandSetBlipName(StoreBlip)

			if Config.Debug then print("Shop - ['"..k.."("..l..")']") end
			exports['qb-target']:AddCircleZone("Shop - ['"..k.."("..l..")']", b, 2.0, { name="Shop - ['"..k.."("..l..")']", debugPoly=Config.Debug, useZ=true, }, 
			{ options = { { event = "jim-shops:ShopMenu", icon = "fas fa-certificate", label = "Browse Shop", 
				shoptable = Config.Locations[tostring(k)], name = Config.Locations[tostring(k)]["label"], }, },
			distance = 2.0 })
		end
	end
end)

RegisterNetEvent('jim-shops:ShopMenu', function(data)
	local products = data.shoptable.products
	local ShopMenu = {}
	if data.shoptable["logo"] ~= nil then
		ShopMenu[#ShopMenu + 1] = { header = "<img src="..data.shoptable["logo"].." width=200px>", txt = "", isMenuHeader = true }
	else
		ShopMenu[#ShopMenu + 1] = { header = data.shoptable.label, txt = "", isMenuHeader = true }
	end
	ShopMenu[#ShopMenu + 1] = { header = "", txt = "❌ Close", params = { event = "jim-shops:CloseMenu" } }
	if products == Config.Products["weapons"] then
		while hasLicense == nil do QBCore.Functions.TriggerCallback("jim-shops:server:getLicenseStatus", function(hasLic, hasLicItem) hasLicense = hasLic hasLicenseItem = hasLicItem end) Wait(0) end
	end
	for i = 1, #products do
		if products[i].price == 0 then price = "Free" else price = "Cost: $"..products[i].price end
		local setheader = QBCore.Shared.Items[products[i].name].label
		local text = price.." - Weight: "..QBCore.Shared.Items[products[i].name].weight.."kg"
		if products[i].requiredJob then
			for i2 = 1, #products[i].requiredJob do
				if QBCore.Functions.GetPlayerData().job.name == products[i].requiredJob[i2] then
					ShopMenu[#ShopMenu + 1] = { header = "<img src=nui://"..Config.img..QBCore.Shared.Items[products[i].name].image.." width=30px>"..setheader, txt = text, 
						params = { event = "jim-shops:Charge", args = { item = products[i].name, cost = products[i].price, shoptable = data.shoptable, name = data.name } } }
				end
			end
		elseif products[i].requiresLicense then
			if hasLicense and hasLicenseItem then
			ShopMenu[#ShopMenu + 1] = { header = "<img src=nui://"..Config.img..QBCore.Shared.Items[products[i].name].image.." width=30px>"..setheader, txt = text, 
					params = { event = "jim-shops:Charge", args = { item = products[i].name, cost = products[i].price, shoptable = data.shoptable, name = data.name } } }
			end
		else
			ShopMenu[#ShopMenu + 1] = { header = "<img src=nui://"..Config.img..QBCore.Shared.Items[products[i].name].image.." width=30px>"..setheader, txt = text, 
						params = { event = "jim-shops:Charge", args = { item = products[i].name, cost = products[i].price, shoptable = data.shoptable, name = data.name } } }
		end
			text, setheader = nil
	end
	
	exports['qb-menu']:openMenu(ShopMenu)
end)

RegisterNetEvent('jim-shops:CloseMenu', function() exports['qb-menu']:closeMenu() end)

RegisterNetEvent('jim-shops:Charge', function(data)
	if data.cost == "Free" then price = data.cost else price = "$"..data.cost end
	if QBCore.Shared.Items[data.item].weight == 0 then weight = "" else weight = "Weight: "..QBCore.Shared.Items[data.item].weight end
	local settext = "- Confirm Purchase -<br><br>"..weight.."<br> Cost per item: "..price.."<br><br>- Payment Type -"
	local header = "<center><p><img src=nui://"..Config.img..QBCore.Shared.Items[data.item].image.." width=100px></p>"..QBCore.Shared.Items[data.item].label
	if data.shoptable["logo"] ~= bil then header = "<center><p><img src="..data.shoptable["logo"].." width=150px></img></p>"..header end
	local dialog = exports['qb-input']:ShowInput({ header = header, submitText = "Pay",
	inputs = {
			{ type = 'radio', name = 'billtype', text = settext, options = { { value = "cash", text = "Cash" }, { value = "bank", text = "Card" } } }, 
			{ type = 'number', isRequired = true, name = 'amount', text = 'Amount to buy' },}
	})
	if dialog then
		if not dialog.amount then return end
		if data.cost == "Free" then data.cost = 0 end
		TriggerServerEvent('jim-shops:GetItem', dialog.amount, dialog.billtype, data.item, data.shoptable, data.name, data.cost)
		RequestAnimDict('amb@prop_human_atm@male@enter')
        while not HasAnimDictLoaded('amb@prop_human_atm@male@enter') do Wait(1) end
        if HasAnimDictLoaded('amb@prop_human_atm@male@enter') then TaskPlayAnim(PlayerPedId(), 'amb@prop_human_atm@male@enter', "enter", 1.0,-1.0, 1500, 1, 1, true, true, true) end
	end
end)

AddEventHandler('onResourceStop', function(resource) 
	if resource == GetCurrentResourceName() then for k, v in pairs(Config.Locations) do for l, b in pairs(v["coords"]) do exports['qb-target']:RemoveZone("Shop - ['"..k.."("..l..")']") end end end
end)
