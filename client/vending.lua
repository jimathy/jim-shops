Shops = Shops or {}

Shops.Vending = {}

onPlayerLoaded(function()
	Wait(1000)
	for k, v in pairs(Locations) do
        if v.isVendingMachine == true and Config.Overrides.VendOverride then
			if v.coords and #v.coords > 0 then
				for i = 1, #v.coords do				-- Add custom vending machine locations
					if v.model then
						local modelPick = math.random(1, #v.model)
						if not IsModelAPed(v.model[i]) then
							makeDistProp({ prop = v.model[modelPick], coords = v.coords[i] }, true, false)
						end
					end
				end
			end
            createModelTarget(v.model, {
                {
                    action = function(data)
                        Shops.Vending.Menu({
                            isVendingMachine = true,
							shop = k,
							shopTable = v,
							entity = type(data) == "table" and data.entity or data
                        })
                    end,
                    icon = v.targetIcon,
                    label = v.targetLabel,
                },
            }, 1.5)
        end
	end
end, true)

Shops.Vending.Menu = function(data)
	local products, stashItems, vendID = data.shopTable.products, {}, data.vendID or nil
	local ShopMenu = {}
	local setheader = " "

	if Config.Overrides.generateStoreLimits then
		if not vendID then
			vendID = "Vend:["..string.sub(data.shopTable.label, 1, 4)..math.floor(GetEntityCoords(data.entity).x or 1)..math.floor(GetEntityCoords(data.entity).y or 1).."]"
		end
		stashItems = triggerCallback('jim-shops:callback:GetStashItems', vendID, data.shopTable)
	end

	for i = 1, #products do
		local amount, lock = products[i].amount, false

        local item = products[i].name:lower()
        if not Items[item] then
			print("^5Debug^7: ^3ShopItems ^7- ^1Can't ^2find item ^7'^6"..item.."^7'")
		else
            local price = products[i].price == 0 and "Free" or "Cost: $"..products[i].price

			local text = (products[i].info and products[i].info.item) and ("Item: "..products[i].info.item..br) or ""
			text = text..price..br.."Weight: "..(Items[item].weight / 1000)..Config.Overrides.Measurement

			if Config.Overrides.generateStoreLimits then
				if stashItems[item] then
					if not stashItems[item].amount or stashItems[item].amount == 0 then
						amount = 0
						lock = true
					else
						amount = tonumber(stashItems[item].amount)
					end
					text = price..br..(amount <= 0 and "Out Of Stock" or"Amount: x"..amount)..br.."Weight: "..(Items[item].weight / 1000)..Config.Overrides.Measurement
				else
					text = price..br.."Out Of Stock"..br.."Weight: "..(Items[item].weight / 1000)..Config.Overrides.Measurement
					lock = true
				end
			end

			local canSee = true
			if products[i].requiresItem then
				canSee = false
				for _, v in pairs(products[i].requiresItem) do
					canSee = hasItem(v)
					Wait(0)
				end
			end

			if canSee then
				ShopMenu[#ShopMenu+1] = {
					icon = invImg(item),
					isMenuHeader = lock,
					header = Items[item]?.label,
                    txt = text,
					onSelect = function()
						Shops.Vending.Charge({
							item = item,
							cost = products[i].price,
							info = products[i].info,
							shopTable = data.shopTable,
							shop = data.shop,
							vendID = vendID,
							amount = amount,
                            isVendingMachine = data.isVendingMachine,
						})
					end,
				}
			end
		end
	end

	local header = ""
	if Config.System.Menu == "qb" then
		header = data.shopTable["logo"] and "<center><img src="..data.shopTable["logo"].." width=200px>" or data.shopTable["label"]
	elseif Config.System.Menu == "ox" then
		header = data.shopTable["logo"] and '!['..'lol'.. ']('..data.shopTable["logo"]..')' or data.shopTable["label"]
	else
		header = data.shopTable["label"]
	end
	openMenu(ShopMenu, {
		header = header,
		canClose = true,
		onExit = function() end,
	})
end

Shops.Vending.Charge = function(data)
    local price = data.cost == "Free" and data.cost or "$"..data.cost
    local weight = Items[data.item].weight == 0 and "" or "Weight: "..(Items[data.item].weight / 1000)..Config.Overrides.Measurement
    local settext = ""
    local header = "<center><p><img src=nui://"..invImg(data.item).." width=100px></p>"..Items[data.item]?.label
    if data.shopTable["logo"] then
        header = "<center><p><img src="..data.shopTable["logo"].." width=150px></img></p>"..header
    end
    local max = data.amount if max == 0 and not Config.Overrides.generateStoreLimits then max = nil end
    if Config.System.Menu == "qb" then
        settext =
        "- Confirm Purchase -"..br..br.. ((Config.Overrides.generateStoreLimits and data.amount ~= 0) and "Amount: "..data.amount..br or "") ..weight..br.." Cost per item: "..price..br..br.."- Payment Type -"
    else
        settext = (Config.Overrides.generateStoreLimits == true and data.amount ~= 0) and "Amnt: "..data.amount.." | Cost: "..price or "Cost: "..price
    end
    local dialog = createInput(Config.System.Menu == "qb" and header or Items[data.item].label, { {
            type = 'radio',
            label = "Payment Type",
            name = 'billtype',
            text = settext,
            options = {
                { value = "cash", text = "Cash" },
                { value = "bank", text = "Card" }
            }
        },
        {
            type = 'number',
            isRequired = true,
            name = 'amount',
            text = 'Amount to buy',
            txt = settext,
            min = 0, max = max, default = 1
        },
    })
    if dialog then
		local billType = (dialog.billtype or dialog[1]):lower()
		local amount = tonumber(dialog.amount or dialog[2])

		if not dialog.amount then return end
		if Config.Overrides.generateStoreLimits and data.custom == nil then
			if amount > tonumber(data.amount) then
				triggerNotify(getName(data.shop), "Incorrect amount", "error")
				Shops.Vending.Charge(data)
				return
			end
		end
		if amount <= 0 then
			triggerNotify(getName(data.shop), "Incorrect amount", "error")
			Shops.Vending.Charge(data)
			return
		end
		if data.cost == "Free" then
			data.cost = 0
		end
		TriggerServerEvent("jim-shops:server:BuyItem", {
            amount = amount,
            billType = billType,
            item = data.item,
            shopTable = data.shopTable,
            price = data.cost,
            info = data.info or nil,
            vendID = data.vendID,
            stash = data.amount and true or false,
            custom = data.custom,
            isVendingMachine = data.isVendingMachine,
        })
    end
end