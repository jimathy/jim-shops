onResourceStart(function()

	for k, v in pairs(SellingProducts) do -- Scan products table, to remove any items
		debugPrint("^5Debug^7: ^2Scanning product table^7 - ^3SellingProducts^7['^6"..k.."^7']")
		for i = 1, #v do
			local item = SellingProducts[k][i].item
			if not Items[item] then
				print("^5Debug^7: ^3Products^7['^6"..k.."^7'] ^2can't find item^7: ^6"..item.."^7")
			end
		end
	end

	for k, v in pairs(SellingLocations) do
		if v.products == nil then
			debugPrint("^5Debug^7: ^3SellLocations^7['^6"..k.."^7']^2 can't find its product table^7")
		else
			for item, amount in pairs(v.products.Items) do
				if not Items[item] then
					print("Item "..item.." doesn't exist, removing from list")
					SellingLocations[k].products.Items[item] = nil
				else
					SellingLocations[k].products.Items[item] = GetRandomTiming(SellingLocations[k].products.Items[item])
				end
			end
		end
	end

	-- Use global statebag to sync location table between players
	GlobalState.jimShopSellLocationsData = SellingLocations
	debugPrint("^5Statebag^7: ^2Updating^3 jimShopSellLocationsData ^2Global Statebag^7")

end, true)

onResourceStop(function()
	-- Ensure statebag is clean
	GlobalState.jimShopSellLocationsData = nil
end, true)