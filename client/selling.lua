Selling = {
	Stores = {}
}

onPlayerLoaded(function()
    SellingLocations = nil
    -- Wait for global statebag sync
    while not GlobalState.jimShopSellLocationsData do Wait(100) end
    debugPrint("^5Statebag^7: ^2Recieving ^4jimShopLocationsData: ^7'^6"..countTable(GlobalState.jimShopSellLocationsData).."^7'")
    SellingLocations = GlobalState.jimShopSellLocationsData

	for k, v in pairs(SellingLocations) do
        for l, b in pairs(v.coords) do
            local label = "Seller - ['"..k.."("..l..")']"
            if not v["hideblip"] then
                Blips[#Blips+1] = makeBlip({
                    coords = b,
                    sprite = v.blipsprite,
                    col = v.blipcolour,
                    scale = 0.7,
                    disp = 6,
                    category = nil,
                    name = v.label
                })
            end
            local options = { {
                icon = v.targetIcon or "fas fa-cash-register",
                label = v.label or "Browse Shop",
                action = function(data)
                    local entity = type(data) == "table" and data.entity or data
                    if isStarted("jim-talktonpc") then
                        exports["jim-talktonpc"]:createCam(entity, true, "shop", true)
                    end
                    local products = v.products
                    products.Header = v.label
                    sellMenu({
                        name = k,
                        ped = entity,
                        sellTable = products
                    })
                end,
            },}
            if Config.Overrides.Peds then
                if v["model"] then
                    local i = math.random(1, #v.model)
                    loadModel(v.model[i])
                    if IsModelAPed(v.model[i]) then
                        if not Peds[label] then
                            makeDistPed(v.model[i], b, true, false, v.scenario, nil, nil)
                        end
                    end
                    if not IsModelAPed(v.model[i]) then
                        if not Peds[label] then
                            Peds[#Peds+1] = makeProp({
                                prop = v.model[i],
                                coords = b
                            }, true, false)
                        end
                    end
                end
            end
            createCircleTarget({ label, vec3(b.x, b.y, b.z), 1.0,
                {
                    name = label,
                    debugPoly = debugMode,
                    useZ = true
                }
            }, options, 1.5)
        end
	end
end, true)