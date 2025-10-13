local basketSystem = {}

onResourceStart(function()
	createCallback(getScript()..":server:getBasket", function(source, shopName)
        local src = source
        print(shopName)
		return basketSystem[shopName] and basketSystem[shopName][src] or {}
	end)
end, true)

RegisterNetEvent(getScript()..":server:addBasketItem", function(data)
    local src = source
    local shopName = data.shop.."_"..data.shopNum
    basketSystem[shopName] = basketSystem[shopName] or {}
    basketSystem[shopName][src] = basketSystem[shopName][src] or {}
    basketSystem[shopName][src][data.item] = {
        amount = data.amount,
        cost = data.price * data.amount,
        stash = data.stash,
        custom = data.custom
    }
    triggerNotify(data.shopTable.label, "Added "..data.amount.." Item(s) to basket", "success", src)
end)