
itemStashCache = {}

if Config.Overrides.generateStoreLimits then    -- if enabled then do this
    onResourceStart(function()
        for k, v in pairs(Locations) do
            if not v.isVendingMachine then
                for i = 1, #v.coords do
                    local tempTable = {}
                    local stashName = k.."_"..i
                    debugPrint("^5Debug^7: ^2Creating amount cache for^7", stashName)
                    for i = 1, #v.products do
                        local item = v.products[i].name:lower()
                        if Items[item] then
                            tempTable[item] = {
                                amount =
                                    Config.Overrides.RandomAmount and math.random(1, v.products[i].amount) or
                                    v.products[i].amount,
                            }

                            if item == Config.Overrides.SellCasinoChips.chipItem then
                                tempTable[item].amount = v["products"][i].amount
                            end

                        else
                            print("^1Error^7: ^3makeFreshStashes ^7- ^2Can't find item ^7'^6"..item.."^7'")
                        end
                    end
                    -- Add created stash table to cache
                    itemStashCache[stashName] = tempTable
                end
            end
        end
    end, true)
end

RegisterNetEvent("jim-shops:server:GenerateVendStash", function(data)
    jsonPrint(data)
    debugPrint("^5Debug^7: ^3GenerateVend ^7- ^2Creating new stash for vending machine^7")
	local tempTable = {}
	local products = data.shopTable.products
	for i = 1, #products do
        local item = products[i].name:lower()
        if Items[item] then
            tempTable[item] = {
            amount =
                Config.Overrides.RandomAmount and math.random(1, products[i].amount) or
                products[i].amount,
            }
        else
            print("^5Debug^7: ^3GenerateVend ^7- ^2Can't find item ^7'^6"..item.."^7'")
        end
	end
    -- Add created stash table to cache
    itemStashCache[data.stashName] = tempTable
end)

createCallback('jim-shops:callback:GetStashItems',function(source, stashName, shopTable)
    if Config.Overrides.generateStoreLimits then
        if stashName:find("Vend") and not itemStashCache[stashName] then
            TriggerEvent("jim-shops:server:GenerateVendStash", { stashName = stashName, shopTable = shopTable })
        end

        return itemStashCache[stashName]
    else
        return {}
    end
end)

--Compatability Wrapper Event for qb-truckerjob to refill shop stashes
RegisterNetEvent("qb-shops:server:RestockShopItems", function(storeinfo)
	if Config.Overrides.generateStoreLimits then
        local storename = storeinfo
        if string.find(storename, "247supermarket") then
            name = "247supermarket"
        elseif string.find(storename, "hardware") then
            name = "hardware"
        elseif string.find(storename, "robsliquor") then
            name = "robsliquor"
        elseif string.find(storename, "ltdgasoline") then
            name = "ltdgasoline"
        end
        num = storename:gsub(name, "")
        if num == "" then
            num = 1
        end

        local stashTable = {}
        for i = 1, #Config.Locations[name]["products"] do
            local item = Config.Locations[name]["products"][i].name:lower()
            if not Items[item] then
                print("^5Debug^7: ^3RestockShopItems ^7- ^1Can't ^2find item ^7'^6"..item.."^7'")
            end
            itemStashCache[stashName][item].amount = Config.Locations[name]["products"][i].amount
        end
    else
        return
    end
end)