basketFunc = {}

local currentPayment = "cash" -- store current payment type for other stores

basketFunc.viewMenu = function(data)
    local prevData = data.prevData
    local basketMenu = {}
    data.totalCost = 0
    for k, v in pairs(data.currentBasket) do
        data.totalCost += (v.cost or 0)
    end
    local tempBasket = {}
    for k, v in pairs(data.currentBasket) do
        tempBasket[k] = v.amount
    end
    local canCarryCheck = triggerCallback(getScript()..":server:canCarry", tempBasket)
    -- if player can't carry the items, show warning
    if not canCarryCheck then
        basketMenu[#basketMenu+1] = {
            header = locale("error", "noSpace"),
            icon = "fas fa-xmark",
            disabled = true,
        }
    end

    local getMoney = 0
    local hasMoney = false
    if currentPayment == "cash" or currentPayment == "bank" then
        getMoney = getPlayer()[currentPayment]
        hasMoney = getMoney >= data.totalCost
    end
    if currentPayment == "society" then
        getMoney = triggerCallback(getScript()..":server:getAccount", prevData.shopTable.societyCharge)
        getMoney = type(getMoney) ~= "number" and 0 or getMoney
        hasMoney = getMoney >= data.totalCost
    end
    basketMenu[#basketMenu+1] = {
        header = locale("general", "paymentType").." "..currentPayment,
        icon = currentPayment == "cash" and "fas fa-money-bill" or currentPayment == "bank" and "fas fa-credit-card" or "fas fa-vault",
        txt = locale("basket", "balance").." - "..curVal..cv(getMoney),
        arrow = true,
        onSelect = function()
            if prevData.shopTable.societyCharge then
                currentPayment = (currentPayment == "cash" and "bank") or (currentPayment == "bank" and "society") or "cash"
            else
                if currentPayment == "society" then
                    currentPayment = "bank"
                end
                currentPayment = (currentPayment == "cash" and "bank" or "cash")
            end
            basketFunc.viewMenu(data)
        end,
    }

    basketMenu[#basketMenu+1] = {
        header = hasMoney and locale("general", "confirm") or locale("error", "noMoney"),
        txt = locale("basket", "totalCost").." "..curVal..cv(data.totalCost),
        icon = hasMoney and "fas fa-check",
        disabled = not hasMoney,
        onSelect = function()
            TriggerServerEvent(getScript()..":server:BuyBasketItems", {
                shop = prevData.shop,
                shopNum = prevData.shopNum,
                shopTable = prevData.shopTable,
                billType = currentPayment,
                totalCost = data.totalCost,
                currentBasket = data.currentBasket,
                societyCharge = currentPayment == "society" and prevData.shopTable.societyCharge or nil,
                societyOwned = prevData.shopTable.societyOwned,
                entity = prevData.entity
            })
            if isStarted("jim-talktonpc") then
                exports["jim-talktonpc"]:stopCam()
            end
        end,
    }

    basketMenu[#basketMenu+1] = {
        header = locale("basket", "itemsBasket"),
        disabled = true,
    }
    for k, v in pairs(data.currentBasket) do
        basketMenu[#basketMenu + 1] = {
            header = getItemLabel(k).." - x"..v.amount.." - "..curVal..cv(v.cost),
            icon = invImg(k),
            image = invImg(k),
            onSelect = function()
                basketFunc.editMenu(data)
            end,
        }
    end

    basketMenu[#basketMenu+1] = {
        header = locale("basket", "clearBasket"),
        icon = "fas fa-trash",
        onSelect = function()
            if triggerCallback(getScript()..":server:clearBasket", prevData.shop.."_"..prevData.shopNum) then
                data.currentBasket = nil
                Shops.Stores.Menu(data.prevData, data.custom)
            end
        end,
    }

    openMenu(basketMenu, {
        header = locale("basket", "basketHeader"),
        headertxt = countTable(data.currentBasket).." "..locale("basket", "items"),
        onBack = function()
            Shops.Stores.Menu(prevData, data.custom)
        end,
    })
end

basketFunc.editMenu = function(data)
    local prevData = data.prevData
    local editMenu = {}
    editMenu[#editMenu+1] = {
        header = locale("basket", "removeBasket"),
        icon = "fas fa-trash",
        onSelect = function()
            if triggerCallback(getScript()..":server:editBasketItem", {
                shop = prevData.shop,
                shopNum = prevData.shopNum,
                shopName = prevData.shopName,
                item = prevData.item,
                remove = true,
            }) then
                data.currentBasket = triggerCallback(getScript()..":server:getBasket", prevData.shop.."_"..prevData.shopNum)
                if countTable(data.currentBasket) == 0 then
                    Shops.Stores.Menu(data.prevData, data.custom)
                else
                    basketFunc.viewMenu(data)
                end
            end
        end,
    }
    editMenu[#editMenu+1] = {
        header = locale("basket", "editAmount"),
        icon = "fas fa-pen",
        txt = locale("basket", "editTxt"),
        onSelect = function()
            local newTable = cloneTable(data)
            newTable.item = prevData.item

            basketFunc.editAmount(newTable)
        end,
    }
    openMenu(editMenu, {
        header = getItemLabel(prevData.item),
        onBack = function()
            basketFunc.viewMenu(data)
        end,
    })
end

basketFunc.editAmount = function(data)
    local stashItems = {}
    local prevData = data.prevData

    -- generate limits and display info
    local productData = nil
    if prevData.shopTable.products[1] == nil then
        for k, v in pairs(prevData.shopTable.products) do
            for i = 1, #v.Items do
                if v.Items[i].name == data.item then
                    productData = v.Items[i]
                end
            end
        end
    else
        for i = 1, #prevData.shopTable.products do
            if prevData.shopTable.products[i].name == prevData.item then
                productData = prevData.shopTable.products[i]
            end
        end
    end

    local price = productData.price == (0 or nil) and locale("general", "free") or curVal..productData.price
    local weight = Items[data.item].weight == 0 and "" or locale("general", "weight").." "..(Items[data.item].weight / 1000)..Config.Overrides.Measurement
    local settext = ""
    local header = "<center><p><img src=nui://"..invImg(data.item:lower()).." width=100px></p>"..getItemLabel(data.item)
    if prevData.shopTable["logo"] then
        header = "<center><p><img src="..prevData.shopTable["logo"].." width=150px></img></p>"..header
    end

    -- Get stash item amounts
    local amount = 0
    if Config.Overrides.generateStoreLimits and not prevData.custom then
        stashItems = triggerCallback(getScript()..":callback:GetStashItems", data.prevData.shop.."_"..data.prevData.shopNum)
        if stashItems[data.item] then
            if not stashItems[data.item].amount or stashItems[data.item].amount == 0 then
                amount = 0
            else
                amount = tonumber(stashItems[data.item].amount)
                amount -= data.currentBasket[data.item].amount
            end
        end
    end


    local max = amount if max == 0 and not Config.Overrides.generateStoreLimits then max = nil end
    if Config.System.Menu == "qb" then
        settext =
            "- "..locale("general", "confirm").." -"..
            br..
            br..
            ((Config.Overrides.generateStoreLimits and amount ~= 0) and locale("general", "amount")..": "..amount..br or "")..
            weight..
            br.." "..locale("general", "costPerItem").." "..price..
            br..
            br.."- "..locale("general", "paymentType").." -"
    else
        settext =
            (Config.Overrides.generateStoreLimits == true and data.amount ~= 0) and
            locale("general", "amount")..": "..amount.." | "..locale("general", "cost").." "..price or locale("general", "cost").." "..price
    end
	local dialog = createInput(Config.System.Menu == "qb" and header or getItemLabel(data.item), {
        {
            type = 'number',
            isRequired = true,
            name = 'amount',
            text = locale("general", "amountToBuy"),
            txt = settext,
            min = 0, max = max, default = 1
        }}
    )

    if dialog then
		local amount, billType = 0, nil
        if dialog[1] then   -- if ox menu, auto adjust values
			if not dialog[2] then
				amount = dialog[1]
				billType = "cash"
			else
				amount = dialog[2]
				billType = dialog[1]
			end
		else
			billType = dialog.billtype or "cash"
			amount = tonumber(dialog.amount)
		end

		if Config.Overrides.generateStoreLimits and not data.custom then
			if amount > max then
				triggerNotify(getName(prevData.shop), locale("error", "incorrectAmount"), "error")
				basketFunc.editAmount(data)
				return
			end
		end

		if amount <= 0 then
			triggerNotify(getName(data.shop), locale("error", "incorrectAmount"), "error")
			basketFunc.editAmount(data)
			return
		end
		if data.cost == locale("general", "free") then
			data.cost = 0
		end
        if triggerCallback(getScript()..":server:editBasketItem", {
            shop = prevData.shop,
            shopNum = prevData.shopNum,
            shopName = prevData.shopName,
            item = prevData.item,
            amount = amount,
            price = productData.price,
        }) then
            data.currentBasket = triggerCallback(getScript()..":server:getBasket", prevData.shop.."_"..prevData.shopNum)
            if countTable(data.currentBasket) == 0 then
                Shops.Stores.Menu(data.prevData, data.custom)
            else
                basketFunc.viewMenu(data)
            end
        end
	end
end