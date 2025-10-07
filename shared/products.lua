Products = {
    ["normal"] = {
        --{ name = "tosti", price = 2, amount = 50, },
        --{ name = "water_bottle", price = 2, amount = 50, },
        --{ name = "kurkakola", price = 2, amount = 50, },
        --{ name = "twerks_candy", price = 2, amount = 50, },
        --{ name = "snikkel_candy", price = 2, amount = 50, },
        { name = "sandwich", price = 2, amount = 50, },
        { name = "beer", price = 7, amount = 50, },
        { name = "whiskey", price = 10, amount = 50, },
        { name = "vodka", price = 70000, amount = 50, },
        { name = "bandage", price = 100, amount = 50, },
        { name = "lighter", price = 2, amount = 50, },
        { name = "rolling_paper", price = 2, amount = 5000,  },
    },
    ["bar"] = {
        --{ name = "water_bottle", price = 2, amount = 50, },
        { name = "beer", price = 7, amount = 50, },
        { name = "whiskey", price = 10, amount = 50, },
        { name = "vodka", price = 70000, amount = 50, },
    },
    ["hardware"] = {
        ["tools"] = {
            header = "Tools",
            Items = {
                { name = "weapon_wrench", price = 250, amount = 250, },
                { name = "weapon_hammer", price = 250, amount = 250, },
                { name = "weapon_bat", price = 500, amount = 50,  requiredGang = { "lostmc" } },  -- Gang only options in stores
                { name = "repairkit", price = 250, amount = 50,  requiredJob = { ["mechanic"] = 0, ["police"] = 0 } },
                { name = "cleaningkit", price = 150, amount = 150, },
                { name = "advancedrepairkit", price = 500, amount = 50,  requiredJob = { ["mechanic"] = 0 } },
            },
        },
        ["fireworks"] = {
            header = "Fireworks",
            Items = {
                { name = "firework1", price = 50, amount = 50, },
                { name = "firework2", price = 50, amount = 50, },
                { name = "firework3", price = 50, amount = 50, },
                { name = "firework4", price = 50, amount = 50, },
            },
        },
        ["tech"] = {
            header = "Tech Products",
            Items = {
                { name = "lockpick", price = 200, amount = 50, },
                { name = "screwdriverset", price = 350, amount = 50, },
                { name = "phone", price = 850, amount = 50, },
                { name = "radio", price = 250, amount = 50, },
                { name = "fitbit", price = 400, amount = 150, },
                { name = "binoculars", price = 50, amount = 50, },
            },
        },
    },
    ["weedshop"] = {
        { name = "joint", price = 10, amount = 1000, },
        { name = "weapon_poolcue", price = 100, amount = 1000, },
        { name = "weed_nutrition", price = 20, amount = 1000, },
        { name = "empty_weed_bag", price = 2, amount = 1000, },
        { name = "rolling_paper", price = 2, amount = 1000, },
    },
    ["gearshop"] = {
        { name = "diving_gear", price = 2500, amount = 10, },
        { name = "jerry_can", price = 200, amount = 50, },
    },
    ["leisureshop"] = {
        { name = "parachute", price = 2500, amount = 10, },
        { name = "binoculars", price = 50, amount = 50, },
        { name = "diving_gear", price = 2500, amount = 10, },
    },
    ["weapons"] = {
        { name = "weapon_knife", price = 250, amount = 250, },
        { name = "weapon_bat", price = 250, amount = 250, },
        { name = "weapon_hatchet",price = 250, amount = 250,  requiredJob = { ["mechanic"] = 0, ["police"] = 0 } },
        { name = "weapon_pistol", price = 2500, amount = 5, requiresLicense = {"weapon"}, requiresItem = {"weaponlicense"} },
        { name = "weapon_snspistol", price = 1500, amount = 5, requiresLicense = {"weapon"}, requiresItem = {"weaponlicense"} },
        { name = "weapon_vintagepistol", price = 4000, amount = 5, requiresLicense = {"weapon", "hunting"}, requiresItem = {"weaponlicense", "huntinglicense"} },
        --{ name = "pistol_ammo", price = 250, amount = 250,  requiresLicense = {"weapon"}, requiresItem = {"weaponlicense"} },
    },
    ["coffeeplace"] = {
        { name = "coffee", price = 5, amount = 500 },
        { name = "lighter", price = 2, amount = 50 },
    },
    ["casino"] = {
        { name = 'casinochips', price = 1, amount = 999999 },
    },
    ["electronics"] = {
        { name = "phone", price = 850, amount = 50 },
        { name = "radio", price = 250, amount = 50, },
        { name = "screwdriverset", price = 350, amount = 50, },
        { name = "binoculars", price = 50, amount = 50, },
        { name = "fitbit", price = 400, amount = 150, },
    },
    ["vending"] = {
       -- { name = "water_bottle", price = 100, amount = 25, },
        --{ name = "kurkakola", price = 100, amount = 25, },
        { name = "sprunk", price = 100, amount = 25, },
        { name = "sprunklight", price = 100, amount = 25, },
        { name = "ecola", price = 100, amount = 25, },
        { name = "ecolalight", price = 100, amount = 25, },
        --{ name = "twerks_candy", price = 100, amount = 25, },
        --{ name = "snikkel_candy", price = 100, amount = 25, },
    },
    ["blackmarket"] = {
        { name = "radioscanner", price = 850, amount = 5 },
    },
}