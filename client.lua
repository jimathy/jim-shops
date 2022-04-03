local QBCore = exports['qb-core']:GetCoreObject()

PlayerJob = {}
RegisterNetEvent('QBCore:Client:OnPlayerLoaded') AddEventHandler('QBCore:Client:OnPlayerLoaded', function() QBCore.Functions.GetPlayerData(function(PlayerData) PlayerJob = PlayerData.job end) end)
RegisterNetEvent('QBCore:Client:OnJobUpdate') AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo) PlayerJob = JobInfo end)
RegisterNetEvent('QBCore:Client:SetDuty') AddEventHandler('QBCore:Client:SetDuty', function(duty) onDuty = duty end)
AddEventHandler('onResourceStart', function(resource)
	if GetCurrentResourceName() == resource then 
		QBCore.Functions.GetPlayerData(function(PlayerData) 
			PlayerJob = PlayerData.job 
		end) 
	end 
end)

ped = {}
CreateThread(function()
	for k, v in pairs(Config.Locations) do
		for l, b in pairs(v["coords"]) do
			if not v["hideblip"] then
				StoreBlip = AddBlipForCoord(b)
				SetBlipSprite(StoreBlip, v["blipsprite"])
				SetBlipScale(StoreBlip, 0.7)
				SetBlipDisplay(StoreBlip, 6)
				SetBlipColour(StoreBlip, v["blipcolour"])
				SetBlipAsShortRange(StoreBlip, true)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentSubstringPlayerName(v["label"])
				EndTextCommandSetBlipName(StoreBlip)
			end
			if Config.Peds then
				local model = v["model"] RequestModel(model) while not HasModelLoaded(model) do Wait(0) end
				if ped["Shop - ['"..k.."("..l..")']"] == nil then ped["Shop - ['"..k.."("..l..")']"] = CreatePed(0, model, b.x, b.y, b.z-1.0, b.a, true, false) end
				if not v["killable"] then SetEntityInvincible(ped["Shop - ['"..k.."("..l..")']"], true) end
				SetBlockingOfNonTemporaryEvents(ped["Shop - ['"..k.."("..l..")']"], true)
				FreezeEntityPosition(ped["Shop - ['"..k.."("..l..")']"], true)
				if Config.Debug then print("Ped Created for Shop - ['"..k.."("..l..")']") end
			end
			if Config.Debug then print("Shop - ['"..k.."("..l..")']") end
			exports['qb-target']:AddCircleZone("Shop - ['"..k.."("..l..")']", vector3(b.x, b.y, b.z), 2.0, { name="Shop - ['"..k.."("..l..")']", debugPoly=Config.Debug, useZ=true, }, 
			{ options = { { event = "jim-shops:ShopMenu", icon = "fas fa-certificate", label = "Browse Shop", 
				shoptable = v, name = v["label"], k = k, l = l, }, },
			distance = 2.0 })
			
		end
	end
end)

RegisterNetEvent('jim-shops:ShopMenu', function(data, custom)
	local products = data.shoptable.products
	local ShopMenu = {}
	local hasLicense, hasLicenseItem = nil
	local stashItems = nil
	
	if Config.Limit and not custom then 
		while stashItems == nil do 
			QBCore.Functions.TriggerCallback('qb-inventory:server:GetStashItems', function(StashItems)
				stashItems = StashItems
			end, "["..data.k.."("..data.l..")]") 
			Wait(100)
		end
	end
	if data.shoptable["logo"] ~= nil then ShopMenu[#ShopMenu + 1] = { header = "<img src="..data.shoptable["logo"].." width=200px>", txt = "", isMenuHeader = true }
	else ShopMenu[#ShopMenu + 1] = { header = data.shoptable["label"], txt = "", isMenuHeader = true }
	end
	ShopMenu[#ShopMenu + 1] = { header = "", txt = "❌ Close", params = { event = "jim-shops:CloseMenu" } }
	if data.shoptable["type"] == "weapons" then
		while hasLicense == nil do QBCore.Functions.TriggerCallback("jim-shops:server:getLicenseStatus", function(hasLic, hasLicItem) hasLicense = hasLic hasLicenseItem = hasLicItem end) Wait(0) end
	end
	for i = 1, #products do
		local amount = nil
		local lock = false
		if Config.Limit and not custom then if stashItems[i] == nil then amount = 0 lock = true else amount = tonumber(stashItems[i].amount) end end
		if products[i].price == 0 then price = "Free" else price = "Cost: $"..products[i].price end
		local setheader = QBCore.Shared.Items[products[i].name].label
		local text = price.."<br>Weight: "..QBCore.Shared.Items[products[i].name].weight
		if Config.Limit and not custom then text = price.."<br>Amount: x"..amount.."<br>Weight: "..QBCore.Shared.Items[products[i].name].weight.."kg" end
		if products[i].requiredJob then
			for i2 = 1, #products[i].requiredJob do
				if QBCore.Functions.GetPlayerData().job.name == products[i].requiredJob[i2] then
					ShopMenu[#ShopMenu + 1] = { header = "<img src=nui://"..Config.img..QBCore.Shared.Items[products[i].name].image.." width=30px>"..setheader, txt = text, isMenuHeader = lock,
						params = { event = "jim-shops:Charge", args = { item = products[i].name, cost = products[i].price, info = products[i].info, shoptable = data.shoptable, k = data.k, l = data.l, amount = amount } } }
				end
			end
		elseif products[i].requiresLicense then
			if hasLicense and hasLicenseItem then
			ShopMenu[#ShopMenu + 1] = { header = "<img src=nui://"..Config.img..QBCore.Shared.Items[products[i].name].image.." width=30px>"..setheader, txt = text, isMenuHeader = lock,
					params = { event = "jim-shops:Charge", args = { item = products[i].name, cost = products[i].price, info = products[i].info, shoptable = data.shoptable, k = data.k, l = data.l, amount = amount } } }
			end
		else
			ShopMenu[#ShopMenu + 1] = { header = "<img src=nui://"..Config.img..QBCore.Shared.Items[products[i].name].image.." width=30px>"..setheader, txt = text, isMenuHeader = lock,
					params = { event = "jim-shops:Charge", args = { 
									item = products[i].name, 
									cost = products[i].price,
									info = products[i].info,
									shoptable = data.shoptable,
									k = data.k,
									l = data.l, 
									amount = amount 
								} } }
		end
	text, setheader = nil
	end
	exports['qb-menu']:openMenu(ShopMenu)
end)

RegisterNetEvent('jim-shops:CloseMenu', function() exports['qb-menu']:closeMenu() end)

RegisterNetEvent('jim-shops:Charge', function(data)
	if data.cost == "Free" then price = data.cost else price = "$"..data.cost end
	if QBCore.Shared.Items[data.item].weight == 0 then weight = "" else weight = "Weight: "..QBCore.Shared.Items[data.item].weight end
	local settext = "- Confirm Purchase -<br><br>"
	if Config.Limit and data.amount ~= nil then settext = settext.."Amount: "..data.amount.."<br>" end
	settext = settext..weight.."<br> Cost per item: "..price.."<br><br>- Payment Type -"
	local header = "<center><p><img src=nui://"..Config.img..QBCore.Shared.Items[data.item].image.." width=100px></p>"..QBCore.Shared.Items[data.item].label
	if data.shoptable["logo"] ~= bil then header = "<center><p><img src="..data.shoptable["logo"].." width=150px></img></p>"..header end
	local dialog = exports['qb-input']:ShowInput({ header = header, submitText = "Pay",
	inputs = {
			{ type = 'radio', name = 'billtype', text = settext, options = { { value = "cash", text = "Cash" }, { value = "bank", text = "Card" } } }, 
			{ type = 'number', isRequired = true, name = 'amount', text = 'Amount to buy' },}
	})
	if dialog then
		if not dialog.amount then return end
		if tonumber(dialog.amount) > tonumber(data.amount) then TriggerEvent("QBCore:Notify", "Incorrect amount", "error") TriggerEvent("jim-shops:Charge", data) return end
		if data.cost == "Free" then data.cost = 0 end
		if data.amount == nil then nostash = true end
		TriggerServerEvent('jim-shops:GetItem', dialog.amount, dialog.billtype, data.item, data.shoptable, data.cost, data.info, data.k, data.l, nostash)
		RequestAnimDict('amb@prop_human_atm@male@enter')
        while not HasAnimDictLoaded('amb@prop_human_atm@male@enter') do Wait(1) end
        if HasAnimDictLoaded('amb@prop_human_atm@male@enter') then TaskPlayAnim(PlayerPedId(), 'amb@prop_human_atm@male@enter', "enter", 1.0,-1.0, 1500, 1, 1, true, true, true) end
	end
end)

AddEventHandler('onResourceStop', function(resource) 
	if resource == GetCurrentResourceName() then
		for k, v in pairs(Config.Locations) do
			for l, b in pairs(v["coords"]) do
				exports['qb-target']:RemoveZone("Shop - ['"..k.."("..l..")']")
				if Config.Peds then	DeletePed(ped["Shop - ['"..k.."("..l..")']"]) end
			end 
		end 
	end
end)
