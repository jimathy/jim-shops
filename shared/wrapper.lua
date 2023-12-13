function isOx()
    return (Config.System.Menu == "ox" or Config.System.Menu == "gta")
end
function openMenu(Menu, data)
    if Config.System.Menu == "ox" then
        if data.onBack then
            table.insert(Menu, 1, { icon = "fas fa-circle-arrow-left",
                title = "Return",
                onSelect = data.onBack,
            })
        end
        for k in pairs(Menu) do
            if not Menu[k].title then
                if Menu[k].header ~= nil and Menu[k].header ~= "" then
                    Menu[k].title = Menu[k].header
                    if Menu[k].txt then Menu[k].description = Menu[k].txt else Menu[k].description = "" end
                else
                    Menu[k].title = Menu[k].txt
                end
            end
            if Menu[k].params then
                Menu[k].event = Menu[k].params.event
                Menu[k].args = Menu[k].params.args or {}
            end
            if Menu[k].isMenuHeader then
                Menu[k].disabled = true
            end
        end
        lib.registerContext({id = 'Menu', title = data.header..br..br..(data.headertxt and data.headertxt or ""), position = 'top-right', options = Menu, onExit = data.onExit and data.onExit or (function() end), })
        lib.showContext("Menu")
    elseif Config.System.Menu == "qb" then
        if data.onBack then
            table.insert(Menu, 1, { icon = "fas fa-circle-arrow-left",
                header = " ", txt = "Return",
                params = {
                    isAction = true,
                    event = data.onBack,
                }
            })
        end
        if data.canClose then
            table.insert(Menu, 1, { icon = "fas fa-circle-xmark",
                header = " ", txt = "Close",
                params = {
                    isAction = true,
                    event = data.onExit and data.onExit or (function() exports["qb-menu"]:closeMenu() end),
                }
            })
        end
        if data.header ~= nil then
            local tempMenu = {}
            for k, v in pairs(Menu) do tempMenu[k+1] = v end
            tempMenu[1] = { header = data.header, txt = data.headertxt and data.headertxt or "", isMenuHeader = true }
            Menu = tempMenu
        end
        for k in pairs(Menu) do
            if Menu[k].onSelect then
                Menu[k].params = {
                    isAction = true,
                    event = Menu[k].onSelect,
                }
            end
            if not Menu[k].header then Menu[k].header = " " end
            if Menu[k].arrow then Menu[k].icon = "fas fa-angle-right" end
            --[[if Menu[k].progress then
                if not Menu[k].txt then Menu[k].txt = "" end
                Menu[k].txt = Menu[k].txt..nosBar(Menu[k].progress, Menu[k].colourScheme and Menu[k].progress or nil)
            end]]
        end
        exports["qb-menu"]:openMenu(Menu)
    elseif Config.System.Menu == "gta" then
        WarMenu.CreateMenu(tostring(Menu),
            data.header,
            data.headertxt or " ",
            {   titleColor = { 222, 255, 255 },
                maxOptionCountOnScreen = 15,
                width = 0.25,
                x = 0.7,
            })
        if WarMenu.IsAnyMenuOpened() then return end
        WarMenu.OpenMenu(tostring(Menu))
        CreateThread(function()
            local close = true
            while true do
                if WarMenu.Begin(tostring(Menu)) then
                    if data.onBack then
                        if WarMenu.SpriteButton("Return", 'commonmenu', "arrowleft", 127, 127, 127) then
                            WarMenu.CloseMenu()
                            Wait(10)
                            data.onBack()
                        end
                    end
                    for k in pairs(Menu) do
                        local pressed = WarMenu.Button(Menu[k].header)
                        if not Menu[k].header then
                            Menu[k].header = Menu[k].txt
                            Menu[k].txt = nil
                        end
                        if Menu[k].txt and Menu[k].txt ~= "" and WarMenu.IsItemHovered() then
                            print(Menu[k].isMenuHeader)
                            if Menu[k].disabled or Menu[k].isMenuHeader then
                                WarMenu.ToolTip("~b~Unavailable", 0.18, true)
                            else
                                WarMenu.ToolTip(
                                    (Menu[k].blip and "~BLIP_".."8".."~ " or "")..
                                    Menu[k].txt:gsub("%:", ":~g~"):gsub("%\n", "\n~s~"), 0.18,
                                    true)
                            end
                        end
                        if pressed and not Menu[k].isMenuHeader then
                            WarMenu.CloseMenu()
                            close = false
                            Menu[k].onSelect()
                        end
                    end
                    WarMenu.End()
                else
                    return
                end
                if not WarMenu.IsAnyMenuOpened() and close then
                    stopTempCam(cam)
                    if data.onExit then data.onExit() end
                end
                Wait(0)
            end
        end)
    end
end
function isWarMenuOpen()
	if Config.System.Menu == "gta" then return WarMenu.IsAnyMenuOpened()
	else return false end
end

-- Targets --
local targetEntities = {}
function createEntityTarget(entity, opts, dist)
    targetEntities[#targetEntities+1] = entity
    if Config.System.Target == "qb" then
        local options = { options = opts, distance = dist }
        exports['qb-target']:AddTargetEntity(entity, options)
    end
    if Config.System.Target == "ox" then
        local options = {}
        for i = 1, #opts do
            options[i] = {
                icon = opts[i].icon,
                label = opts[i].label,
                item = opts[i].item or nil,
                groups = opts[i].job or opts[i].gang,
                onSelect = opts[i].action,
                canInteract = function(_, distance)
                    return distance < dist and true or false
                end
            }
        end
        exports.ox_target:addLocalEntity(entity, options)
    end
end

AddEventHandler('onResourceStop', function(r)
    if r ~= GetCurrentResourceName() then return end
    for k, v in pairs(targetEntities) do
        if Config.System.Target == "qb" then
            exports["qb-target"]:RemoveTargetEntity(v)
        end
        if Config.System.Target == "ox" then
            exports.ox_target:removeLocalEntity(v, nil)
        end
    end
end)

-- NOTIFICATIONS --
function triggerNotify(title, message, type, src)
	if Config.System.Notify == "okok" then
		if not src then TriggerEvent('okokNotify:Alert', title, message, 6000, type)
		else TriggerClientEvent('okokNotify:Alert', src, title, message, 6000, type) end
	elseif Config.System.Notify == "qb" then
		if not src then	TriggerEvent("QBCore:Notify", message, type)
		else TriggerClientEvent("QBCore:Notify", src, message, type) end
	elseif Config.System.Notify == "ox" then
		if not src then TriggerEvent('ox_lib:notify', {title = title, description = message, type = type or "success"})
		else TriggerClientEvent('ox_lib:notify', src, { type = type or "success", title = title, description = message }) end
	elseif Config.System.Notify == "gta" then
		if not src then TriggerEvent(GetCurrentResourceName()..":DisplayNotify", title, message)
		else TriggerClientEvent(GetCurrentResourceName()..":DisplayNotify", src, title, message) end
	end
end

RegisterNetEvent(GetCurrentResourceName()..":DisplayNotify", function(title, text)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringKeyboardDisplay(text)
	EndTextCommandThefeedPostMessagetext("CHAR_DEFAULT", "CHAR_DEFAULT", true, 1, title or GetCurrentResourceName(), nil, text);
	EndTextCommandThefeedPostTicker(true, false)
end)

function DisplayHelpMsg(text)
	BeginTextCommandDisplayHelp("STRING")
	AddTextComponentScaleform(text)
	EndTextCommandDisplayHelp(0, true, false, -1)
end

-- Callbacks -- **experitmental**
--- I hate doing them like this, its simplyfying the code, but its basically the same thing
function createCallback(callbackName, funct)
    if Config.System.Callback == "qb" then
        print("Registering QB Callback", callbackName)
        Core.Functions.CreateCallback(callbackName, funct)
    elseif Config.System.Callback == "ox" then
        print("Registering OX Callback", callbackName)
        lib.callback.register(callbackName, funct)
    end
end

function triggerCallback(callBackName) local result = nil
    if Config.System.Callback == "qb" then
        local p = promise.new()
        Core.Functions.TriggerCallback(callBackName, function(cb) p:resolve(cb) end)
        result = Citizen.Await(p)
    elseif Config.System.Callback == "ox" then
        result = lib.callback.await(callBackName)
    end
    return result
end

-- INPUT --
function createInput(title, opts)
    local dialog = nil
    local options = {}
    if Config.System.Menu == "ox" then
        for i = 1, #opts do
            if opts[i].type == "radio" then
                for k in pairs(opts[i].options) do
                    opts[i].options[k].label = opts[i].options[k].text
                end
                options[i] = {
                    type = "select",
                    isRequired = opts[i].isRequired,
                    label = opts[i].label,
                    name = opts[i].name,
                    default = opts[i].options[1].value,
                    options = opts[i].options,
                }
            end
            if opts[i].type == "number" then
                options[i] = {
                    type = "number",
                    label = opts[i].text.." - "..opts[i].txt,
                    isRequired = opts[i].isRequired,
                    name = opts[i].name,
                    options = opts[i].options,
                    min = opts[i].min,
                    max = opts[i].max,
                    default = opts[i].default,
                }
            end
        end
        dialog = exports.ox_lib:inputDialog(title, options)
        return dialog
    end
    if Config.System.Menu == "qb" then
        dialog = exports['qb-input']:ShowInput({ header = title, submitText = "Pay", inputs = opts })
        return dialog
    end
    if Config.System.Menu == "gta" then
        WarMenu.CreateMenu(tostring(opts),
        title,
        " ",
        {   titleColor = { 222, 255, 255 },
            maxOptionCountOnScreen = 15,
            width = 0.25,
            x = 0.7,
        })
        if WarMenu.IsAnyMenuOpened() then return end
        WarMenu.OpenMenu(tostring(opts))
        local close = true
        local _comboBoxItems = { }
        local _comboBoxIndex = { 1, 1 }
        while true do
            if WarMenu.Begin(tostring(opts)) then
                for i = 1, #opts do
                    if opts[i].type == "radio" then
                        for k in pairs(opts[i].options) do
                            if not _comboBoxItems[i] then _comboBoxItems[i] = {} end
                            _comboBoxItems[i][k] = opts[i].options[k].text
                        end
                        local _, comboBoxIndex = WarMenu.ComboBox(opts[i].label, _comboBoxItems[i], _comboBoxIndex[i])
                        if _comboBoxIndex[i] ~= comboBoxIndex then
                            _comboBoxIndex[i] = comboBoxIndex
                        end
                    end
                    if opts[i].type == "number" then
                        for b = 1, opts[i].max do
                            if not _comboBoxItems[i] then _comboBoxItems[i] = {} end
                            _comboBoxItems[i][b] = b
                        end
                        local _, comboBoxIndex = WarMenu.ComboBox(opts[i].text, _comboBoxItems[i], _comboBoxIndex[i])
                        if _comboBoxIndex[i] ~= comboBoxIndex then
                            _comboBoxIndex[i] = comboBoxIndex
                        end
                    end
                end
                local pressed = WarMenu.Button("Pay")
                if pressed then
                    WarMenu.CloseMenu()
                    close = false
                    local result = {}
                    for i = 1, #_comboBoxIndex do
                        result[i] = _comboBoxItems[i][_comboBoxIndex[i]]
                    end
                    return result
                end
                WarMenu.End()
            else
                return
            end
            if not WarMenu.IsAnyMenuOpened() and close then
                if data.onExit then data.onExit() end
            end
            Wait(0)
        end
    end
end

-- IN NO WAY PERFECT --