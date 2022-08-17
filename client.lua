local QBCore = exports['qb-core']:GetCoreObject()
PlayerGang = {}
PlayerJob = {}
Targets = {}
ped = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() QBCore.Functions.GetPlayerData(function(PlayerData) PlayerJob = PlayerData.job end) end)
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo) PlayerJob = JobInfo end)
RegisterNetEvent('QBCore:Client:SetDuty', function(duty) onDuty = duty end)
RegisterNetEvent('QBCore:Client:OnGangUpdate', function(GangInfo) PlayerGang = GangInfo end)
AddEventHandler('onResourceStart', function(resource) if GetCurrentResourceName() ~= resource then return end QBCore.Functions.GetPlayerData(function(PlayerData) PlayerJob = PlayerData.job end) end)

--Loading/Unloading Asset Functions
function loadModel(model) if not HasModelLoaded(model) then if Config.Debug then print("^5Debug^7: ^2Loading Model^7: '^6"..model.."^7'") end RequestModel(model) while not HasModelLoaded(model) do Wait(0) end end end
function unloadModel(model) if Config.Debug then print("^5Debug^7: ^2Removing Model^7: '^6"..model.."^7'") end SetModelAsNoLongerNeeded(model) end
function loadAnimDict(dict)	if Config.Debug then print("^5Debug^7: ^2Loading Anim Dictionary^7: '^6"..dict.."^7'") end while not HasAnimDictLoaded(dict) do RequestAnimDict(dict) Wait(5) end end
function unloadAnimDict(dict) if Config.Debug then print("^5Debug^7: ^2Removing Anim Dictionary^7: '^6"..dict.."^7'") end RemoveAnimDict(dict) end
function destroyProp(entity) if Config.Debug then print("^5Debug^7: ^2Destroying Prop^7: '^6"..entity.."^7'") end SetEntityAsMissionEntity(entity) Wait(5) DetachEntity(entity, true, true) Wait(5) DeleteObject(entity) end

CreateThread(function()
	for k, v in pairs(Config.Locations) do
		if k == "vendingmachine" and Config.VendOverride then
			for l, b in pairs(v["coords"]) do
				if Config.Peds then
					if v["model"] then
						local i = math.random(1, #v["model"])
						loadModel(v["model"][i])
						if not IsModelAPed(v["model"][i]) then
							if not ped["Shop - ['"..k.."("..l..")']"] then
								ped["Shop - ['"..k.."("..l..")']"] = CreateObject(v["model"][i], b.x, b.y, b.z-1.03, 0, 0, 0)
								SetEntityHeading(ped["Shop - ['"..k.."("..l..")']"], b.w)
							end
						end
						FreezeEntityPosition(ped["Shop - ['"..k.."("..l..")']"], true)
						if Config.Debug then print("^5Debug^7: ^6Ped ^2Created for Shop ^7- '^6"..k.."^7(^6"..l.."^7)'") end
					end
				end
				exports['qb-target']:AddTargetModel(v["model"], {
					options = { {
						event = "jim-shops:ShopMenu", icon = (v["targetIcon"]), label = (v["targetLabel"]),
						shoptable = v, name = v["label"], vend = true }, },
					distance = 1.5, })
			end
		else
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
					if v["model"] then
						local i = math.random(1, #v["model"])
						loadModel(v["model"][i])
						if IsModelAPed(v["model"][i]) then
							if not ped["Shop - ['"..k.."("..l..")']"] then ped["Shop - ['"..k.."("..l..")']"] = CreatePed(0, v["model"][i], b.x, b.y, b.z-1.0, b.a, false, false) end
							if not v["killable"] then SetEntityInvincible(ped["Shop - ['"..k.."("..l..")']"], true) end
							TaskStartScenarioInPlace(ped["Shop - ['"..k.."("..l..")']"], v["scenario"] or Config.Scenarios[math.random(1, #Config.Scenarios)], -1, true)
							SetBlockingOfNonTemporaryEvents(ped["Shop - ['"..k.."("..l..")']"], true)
							SetEntityNoCollisionEntity(ped["Shop - ['"..k.."("..l..")']"], PlayerPedId(), false)
						end
						if not IsModelAPed(v["model"][i]) then
							if not ped["Shop - ['"..k.."("..l..")']"] then
								ped["Shop - ['"..k.."("..l..")']"] = CreateObject(v["model"][i], b.x, b.y, b.z-1.03, 0, 0, 0)
								SetEntityHeading(ped["Shop - ['"..k.."("..l..")']"], b.w)
							end
						end
						FreezeEntityPosition(ped["Shop - ['"..k.."("..l..")']"], true)
						if Config.Debug then print("^5Debug^7: ^6Ped ^2Created for Shop ^7- '^6"..k.."^7(^6"..l.."^7)'") end
					end
				end
				local options = { { event = "jim-shops:ShopMenu", icon = (v["targetIcon"] or "fas fa-cash-register"), label = (v["targetLabel"] or "Browse Shop"), item = v["requiredItem"], job = v["job"] or nil, gang = v["gang"] or nil,
				shoptable = v, name = v["label"], k = k, l = l, }, }
				if k == "casino" then
					options[#options+1] = { type = "server", event = "jim-shops:server:sellChips", icon = "fab fa-galactic-republic", label = "Trade Chips ($"..Config.SellCasinoChips.pricePer.." per chip)", }
				end
				Targets["Shop - ['"..k.."("..l..")']"] =
					exports['qb-target']:AddCircleZone("Shop - ['"..k.."("..l..")']", vector3(b.x, b.y, b.z), 2.0, { name="Shop - ['"..k.."("..l..")']", debugPoly=Config.Debug, useZ=true, },
					{ options = options, distance = 2.0 })
			end
		end
	end
end)

RegisterNetEvent('jim-shops:ShopMenu', function(data, custom)
	local products = data.shoptable.products
	local ShopMenu = {}
	local hasLicense, hasLicenseItem, stashItems = nil
	local setheader = ""
	local vendID = data.vendID or nil

	if Config.Limit and data.vend then
		if not vendID then vendID = "["..string.sub(data.shoptable.label, 1, 4)..math.floor(GetEntityCoords(data.entity).x or 1)..math.floor(GetEntityCoords(data.entity).y or 1).."]" end
		local p = promise.new()
		QBCore.Functions.TriggerCallback('jim-shops:server:GetStashItems', function(stash) p:resolve(stash) end, vendID)
		stashItems = Citizen.Await(p)
		if json.encode(stashItems) == "[]" then
			if Config.Debug then print("^5Debug^7: ^2Generating Vending Machine Stash^7: ^6"..vendID) end
			TriggerServerEvent("jim-shops:GenerateVend", {data, vendID})
			Wait(1000)
			local p = promise.new()
			QBCore.Functions.TriggerCallback('jim-shops:server:GetStashItems', function(stash) p:resolve(stash) end, vendID)
			stashItems = Citizen.Await(p)
		end
	end

	if Config.Limit and not custom and not data.vend then
		local p = promise.new()
		QBCore.Functions.TriggerCallback('jim-shops:server:GetStashItems', function(stash) p:resolve(stash) end, "["..data.k.."("..data.l..")]")
		stashItems = Citizen.Await(p)
	end

	if data.shoptable["logo"] then ShopMenu[#ShopMenu + 1] = { isDisabled = true, header = "<center><img src="..data.shoptable["logo"].." width=250.0rem>", txt = "", isMenuHeader = true }
	else ShopMenu[#ShopMenu + 1] = { header = data.shoptable["label"], txt = "", isMenuHeader = true } end

	ShopMenu[#ShopMenu + 1] = { icon = "fas fa-circle-xmark", header = "", txt = "Close", params = { event = "jim-shops:CloseMenu" } }

	if data.shoptable["type"] == "weapons" then
		local p = promise.new()	local p2 = promise.new()
		QBCore.Functions.TriggerCallback("jim-shops:server:getLicenseStatus", function(hasLic, hasLicItem) p:resolve(hasLic) p2:resolve(hasLicItem) end)
		hasLicense = Citizen.Await(p) hasLicenseItem = Citizen.Await(p2)
	end
	for i = 1, #products do
		local amount, text, setheader = table.unpack({nil,nil,nil})
		local lock = false
		if Config.Debug then print("^5Debug^7: ^3ShopMenu ^7- ^2Searching for item ^7'^6"..products[i].name.."^7'") end
		if not QBCore.Shared.Items[products[i].name:lower()] then
			print("^5Debug^7: ^3ShopItems ^7- ^1Can't ^2find item ^7'^6"..products[i].name.."^7'")
		else
			if Config.Limit and not custom then
				if stashItems[i].amount == 0 then amount = 0 lock = true else amount = tonumber(stashItems[i].amount) end
			end
			if products[i].price == 0 then price = "Free" else price = "Cost: $"..products[i].price end

			if not Config.JimMenu then setheader = "<img src=nui://"..Config.img..QBCore.Shared.Items[products[i].name].image.." width=30px onerror='this.onerror=null; this.remove();'>"..QBCore.Shared.Items[products[i].name].label
			else setheader = QBCore.Shared.Items[products[i].name].label end
			local text = price.."<br>Weight: "..(QBCore.Shared.Items[products[i].name].weight / 1000)..Config.Measurement
			if Config.Limit and not custom then
				if amount ~= 0 then	text = price.."<br>Amount: x"..amount.."<br>Weight: "..(QBCore.Shared.Items[products[i].name].weight / 1000)..Config.Measurement
				else text = price.."<br>Out Of Stock<br>Weight: "..(QBCore.Shared.Items[products[i].name].weight / 1000)..Config.Measurement end
			end
			if products[i].requiredJob then
			for k, v in pairs(products[i].requiredJob) do
				if QBCore.Functions.GetPlayerData().job.name == k and QBCore.Functions.GetPlayerData().job.grade.level >= v then
					local icon, header = nil, nil
					if products[i].info ~= nil and products[i].info.image ~= nil then icon = "qb-inventory/html/images/"..products[i].info.image else icon = products[i].name end
					if products[i].info ~= nil and products[i].info.label ~= nil then header = products[i].info.label else header = setheader end
					ShopMenu[#ShopMenu + 1] = { icon = icon, header = header, txt = text, isMenuHeader = lock,
						params = { event = "jim-shops:Charge", args = { item = products[i].name, cost = products[i].price, info = products[i].info or {}, shoptable = data.shoptable, k = data.k, l = data.l, amount = amount, custom = custom } } }
					end
				end
			elseif products[i].requiredGang then
			for i2 = 1, #products[i].requiredGang do
				if QBCore.Functions.GetPlayerData().gang.name == products[i].requiredGang[i2] then
					local icon, header = nil, nil
					if products[i].info ~= nil and products[i].info.image ~= nil then icon = "qb-inventory/html/images/"..products[i].info.image else icon = products[i].name end
					if products[i].info ~= nil and products[i].info.label ~= nil then header = products[i].info.label else header = setheader end
					ShopMenu[#ShopMenu + 1] = { icon = icon, header = header, txt = text, isMenuHeader = lock,
						params = { event = "jim-shops:Charge", args = { item = products[i].name, cost = products[i].price, info = products[i].info or {}, shoptable = data.shoptable, k = data.k, l = data.l, amount = amount, custom = custom } } }
					end
				end
			elseif products[i].requiresLicense then
				if hasLicense and hasLicenseItem then
					local icon, header = nil, nil
					if products[i].info ~= nil and products[i].info.image ~= nil then icon = "qb-inventory/html/images/"..products[i].info.image else icon = products[i].name end
					if products[i].info ~= nil and products[i].info.label ~= nil then header = products[i].info.label else header = setheader end
					ShopMenu[#ShopMenu + 1] = { icon = icon, header = header, txt = text, isMenuHeader = lock,
					params = { event = "jim-shops:Charge", args = { item = products[i].name, cost = products[i].price, info = products[i].info or {}, shoptable = data.shoptable, k = data.k, l = data.l, amount = amount, custom = custom } } }
				end
			else
				local icon, header = nil, nil
				if products[i].info ~= nil and products[i].info.image ~= nil then icon = "qb-inventory/html/images/"..products[i].info.image else icon = products[i].name end
				if products[i].info ~= nil and products[i].info.label ~= nil then header = products[i].info.label else header = setheader end
				ShopMenu[#ShopMenu + 1] = { icon = icon, header = header, txt = text, isMenuHeader = lock,
				params = { event = "jim-shops:Charge", args = {
					item = products[i].name,
					cost = products[i].price,
					info = products[i].info,
					shoptable = data.shoptable,
					k = data.k or vendID,
					l = data.l or "",
					amount = amount,
					custom = custom,
				} } }
			end
		end
	end
	exports['qb-menu']:openMenu(ShopMenu)
end)
--Selling animations are simply a pass item to seller animation
RegisterNetEvent('jim-shops:SellAnim', function(data)
	if string.find(data.shoptable.label, "Vending") then
		loadAnimDict("mp_common")
		loadAnimDict("amb@prop_human_atm@male@enter")
		local model = `prop_paper_bag_small`
		if Config.ItemModels[data.item] then model = Config.ItemModels[data.item] end
		loadModel(model)
		if prop == nil then prop = CreateObject(model, 0.0, 0.0, 0.0, true, false, false) end
		TaskPlayAnim(PlayerPedId(), "amb@prop_human_atm@male@enter", "enter", 1.0, 1.0, 0.3, 16, 0.2, 0, 0, 0)	--Start animations
		Wait(1000)
		AttachEntityToEntity(prop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.1, -0.0, 0.0, -90.0, 0.0, 0.0, true, true, false, true, 1, true)
		Wait(1000)
		StopAnimTask(PlayerPedId(), "amb@prop_human_atm@male@enter", "enter", 1.0)
		unloadAnimDict("mp_common")
		unloadAnimDict("amb@prop_human_atm@male@enter")
		destroyProp(prop) unloadModel(model)
		prop = nil
		return
	end
	for _, v in pairs (ped) do
		if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(v)) < 2 then
			ppRot = GetEntityRotation(v)
			ppheading = GetEntityHeading(v)
			ppcoords = GetEntityCoords(v)
			loadAnimDict("mp_common")
			loadAnimDict("amb@prop_human_atm@male@enter")
			local model = `prop_paper_bag_small`
			if Config.ItemModels[data.item] then model = Config.ItemModels[data.item] end
			loadModel(model)
			if prop == nil then prop = CreateObject(model, 0.0, 0.0, 0.0, true, false, false) end
			AttachEntityToEntity(prop, v, GetPedBoneIndex(v, 57005), 0.1, -0.0, 0.0, -90.0, 0.0, 0.0, true, true, false, true, 1, true)
			--Calculate if you're facing the ped--
			if tostring(data.shoptable["scenario"]) ~= "PROP_HUMAN_SEAT_CHAIR_FOOD" then ClearPedTasksImmediately(v) end
			if not IsPedHeadingTowardsPosition(PlayerPedId(), GetEntityCoords(v), 20.0) then TaskTurnPedToFaceCoord(PlayerPedId(), GetEntityCoords(v), 1500) Wait(1500) end
			TaskPlayAnim(PlayerPedId(), "amb@prop_human_atm@male@enter", "enter", 1.0, 1.0, 0.3, 16, 0.2, 0, 0, 0)	--Start animations
			TaskPlayAnim(v, "mp_common", "givetake2_b", 1.0, 1.0, 0.3, 16, 0.2, 0, 0, 0)
			Wait(1000)
			AttachEntityToEntity(prop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.1, -0.0, 0.0, -90.0, 0.0, 0.0, true, true, false, true, 1, true)
            Wait(1000)
            StopAnimTask(PlayerPedId(), "amb@prop_human_atm@male@enter", "enter", 1.0)
			StopAnimTask(v, "mp_common", "givetake2_b", 1.0)
			TaskStartScenarioInPlace(v, data.shoptable["scenario"] or Config.Scenarios[math.random(1, #Config.Scenarios)], -1, true)
			unloadAnimDict("mp_common")
			unloadAnimDict("amb@prop_human_atm@male@enter")
			destroyProp(prop) unloadModel(model)
			prop = nil
			break
		end
	end
end)

RegisterNetEvent('jim-shops:CloseMenu', function() exports['qb-menu']:closeMenu() end)

RegisterNetEvent('jim-shops:Charge', function(data)
	if data.cost == "Free" then price = data.cost else price = "$"..data.cost end
	if QBCore.Shared.Items[data.item].weight == 0 then weight = "" else weight = "Weight: "..(QBCore.Shared.Items[data.item].weight / 1000)..Config.Measurement end
	local settext = "- Confirm Purchase -<br><br>"
	if Config.Limit and data.amount ~= nil then settext = settext.."Amount: "..data.amount.."<br>" end
	settext = settext..weight.."<br> Cost per item: "..price.."<br><br>- Payment Type -"
	local header = "<center><p><img src=nui://"..Config.img..QBCore.Shared.Items[data.item].image.." width=100px></p>"..QBCore.Shared.Items[data.item].label
	if data.shoptable["logo"] then header = "<center><p><img src="..data.shoptable["logo"].." width=150px></img></p>"..header end

	local newinputs = {
		{ type = 'radio', name = 'billtype', text = settext, options = { { value = "cash", text = "Cash" }, { value = "bank", text = "Card" } } },
		{ type = 'number', isRequired = true, name = 'amount', text = 'Amount to buy' } }

	local dialog = exports['qb-input']:ShowInput({ header = header, submitText = "Pay", inputs = newinputs })
	if dialog then
		if not dialog.amount then return end
		if Config.Limit and data.custom == nil then	if tonumber(dialog.amount) > tonumber(data.amount) then TriggerEvent("QBCore:Notify", "Incorrect amount", "error") TriggerEvent("jim-shops:Charge", data) return end end
		if tonumber(dialog.amount) <= 0 then TriggerEvent("QBCore:Notify", "Incorrect amount", "error") TriggerEvent("jim-shops:Charge", data) return end
		if data.cost == "Free" then data.cost = 0 end
		if data.amount == nil then nostash = true end
		TriggerServerEvent('jim-shops:GetItem', dialog.amount, dialog.billtype, data.item, data.shoptable, data.cost, data.info, data.k, data.l or nil, nostash)
	end
end)

AddEventHandler('onResourceStop', function(resource) if resource ~= GetCurrentResourceName() then return end
	for k in pairs(Targets) do exports['qb-target']:RemoveZone(k) end
	for _, v in pairs(ped) do unloadModel(v) if IsModelAPed(GetEntityModel(v)) then DeletePed(v) else DeleteObject(v) end end
end)