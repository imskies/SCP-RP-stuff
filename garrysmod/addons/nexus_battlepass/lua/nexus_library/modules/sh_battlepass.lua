Nexus:AddLanguages("nBattlepass", "en", {
    ["Battlepass"] = "Battlepass",
    ["Challenges"] = "Challenges",

    ["Admin"] = "Admin",
    ["Incorrect Usergroup"] = "Incorrect Usergroup",
    ["Success"] = "Success",
    ["Delete"] = "Delete",

    ["Ammo Bought"] = "Purchase Ammos",
    ["Entity Bought"] = "Purchase Entitys",
    ["Door Bought"] = "Purchase Doors",
    ["Vehicle Bought"] = "Purchase Vehicles",
    ["Food Bought"] = "Purchase Foods",
    ["Weapon Bought"] = "Purchase Weapons",
    ["Shipment Bought"] = "Purchase Shipments",
    ["Props Placed"] = "Props Placed",
    ["Distance Moved"] = "Distance Moved",
    ["Damage Dealt"] = "Damage Dealt",
    ["Damage Taken"] = "Damage Taken",
    ["Arrests"] = "Arrests",
    ["Change Jobs"] = "Change Jobs",
    ["Give Money"] = "Give Money To Others",
    ["Lockpick Doors"] = "Lockpick Doors",

    ["Challenge Complete"] = "Challenge completed! You have earned %s Battlepass Tiers.",
    ["Purchase for 1 Switch Token"] = "Are you sure you want to purchase this for 1 switch token?",
    ["Not enough switch tokens"] = "Not enough switch tokens",
    ["Not your battlepass"] = "This is not your battlepass",
    ["Are you sure"] = "Are you sure you want to do this?",
    ["Already holding"] = "You are already holding this weapon",

    ["Reward"] = "Reward",
    ["Free Tier Item Chances"] = "Free Tier Item Chances",
    ["Premium Tier Item Chances"] = "Premium Tier Item Chances",
    ["Delete Battlepass"] = "Delete Last Battlepass (Generates a new one)",
    ["Generate Battlepass"] = "Generate Battlepass",
    ["Claim Tier"] = "Claim Tier",
    ["Cooldown"] = "You are on cooldown please wait.",
    ["Switch Tokens"] = "Switch Tokens",
    ["Havent Unlocked Tier"] = "You havent unlocked this tier yet!",
    ["Not got premium"] = "You have not got premium on this battlepass!",
    ["Successfully Claimed Tier"] = "Successfully Claimed Tier",
    ["Already claimed reward"] = "Already claimed reward",
    ["Next Battlepass In"] = "Next Battlepass In",

    [":Chat Commands"] = "Chat Commands",
    [":Edit Admins"] = "Admins who can edit the battlepass",
    [":DBType"] = "Database Type",
    [":SQLDetails"] = "MySQL Details (if you are using MySQL)",
    [":Force Generate Tier"] = "Force a tier to generate an item",
    [":Force Tier Value"] = "Force a tier to be a certain item",
    [":Generate Chance"] = "Chances to generate on the tier",
    [":Next BP Tiers"] = "How many tiers will the next Battlepass have?",
    [":Next Name"] = "What will the next Battlepass be named? (%s = Season Number)",
    [":Next BP Duration"] = "How long until we generate a new Battlepass? (in seconds)",
    [":Store Link"] = "Store Link",
    [":NPC Model"] = "NPC Model",
})

Nexus.Builder:Start()
    :SetName("Nexus Battlepass")

    :AddButtons({
        id = "nbp-powerButtons",

        buttons = {
            {text = function() return Nexus:GetPhrase("Generate Battlepass", "nBattlepass") end, value = 1, color=Nexus:GetColor("green")},
            {text = function() return Nexus:GetPhrase("Delete Battlepass", "nBattlepass") end, value = 2},
        },

        onChange = function(value, ply)
            if value == 1 then
                Nexus.Battlepass:GenerateBattlepass()
            elseif value == 2 then
                Nexus:PopupAsk(ply, Nexus:GetPhrase("Are you sure", "nBattlepass", ply), function()
                    Nexus.Battlepass:DeleteLast()
                end)
            end
        end,
    })

    :AddButtons({
        id = "nbp-db",
        defaultValue = "sql",
        showSelected = true,
        label = {":DBType", "nBattlepass"},

        buttons = {
            {text = "sql", value = "sql"},
            {text = "MySQL", value = "mysql"},
        },

        onChange = function(value)
            Nexus.Battlepass:ConnectDatabase()
        end,
    })

    :AddMultiTextEntry({
        id = "nbp-mysql",
        dontNetwork = true,

        label = {":SQLDetails", "nBattlepass"},
        entries = {
            {id = "Host", default = "", placeholder = "Host", isNumeric = false},
            {id = "Port", default = 3306, placeholder = "Port", isNumeric = true},
            {id = "Username", default = "", placeholder = "Username", isNumeric = false},
            {id = "Password", default = "", placeholder = "Password", isNumeric = false},
            {id = "Database", default = "", placeholder = "Database", isNumeric = false},
        },

        onChange = function(value)
            Nexus.Battlepass:ConnectDatabase()
        end,
    })

    :AddKeyTable({
        id = "nbp-superadmin",
        label = {":Edit Admins", "nBattlepass"},

        defaultValue = {
            ["superadmin"] = true,
        },

        placeholder = "Usergroup",
        onChange = function(value) end,
    })

    :AddKeyTable({
        id = "nbp-chatCommands",
        label = {":Chat Commands", "nBattlepass"},

        defaultValue = {
            ["/battlepass"] = true,
            ["!battlepass"] = true,
            ["/bp"] = true,
            ["!bp"] = true,
        },

        placeholder = "Chat Command",
        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nbp-tiersCount",
        defaultValue = 100,
        dontNetwork = false,

        label = {":Next BP Tiers", "nBattlepass"},
        placeholder = "Amount",
        isNumeric = true,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nbp-name",
        defaultValue = "SEASON %s",
        dontNetwork = false,

        label = {":Next Name", "nBattlepass"},
        placeholder = "SEASON %s",
        isNumeric = false,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nbp-seasonDuration",
        defaultValue = 1814400,
        dontNetwork = false,

        label = {":Next BP Duration", "nBattlepass"},
        placeholder = "seconds",
        isNumeric = true,

        onChange = function(value)
        end,
    })

    :AddTextEntry({
        id = "nbp-storeURL",
        defaultValue = "https://www.gmodstore.com/market/view/battlepass",
        dontNetwork = false,

        label = {":Store Link", "nBattlepass"},
        placeholder = "URL",
        isNumeric = false,

        onChange = function(value)
        end,
    })

    :AddMultiTextEntry({
        id = "nbp-generationChances",
        dontNetwork = true,

        label = {":Generate Chance", "nBattlepass"},
        entries = {
            {id = "Free", default = 30, placeholder = "Free Chance", isNumeric = true},
            {id = "Premium", default = 60, placeholder = "Premium Chance", isNumeric = true},
        },

        onChange = function(value) end,
    })

    :AddTable({
        id = "nbp-forceTierToGenerate",
        dontNetwork = false, 
        defaultValue = {},

        label = {":Force Generate Tier", "nBattlepass"},

        values = {
            {id = "Tier", type = "TextEntry", placeholder = "Tier", isNumeric = true},
            {id = "IsPremiumSlot", type = "CheckBox", placeholder = "Premium Slot"},
        },

        onChange = function(value) end,
    })

    :AddTable({
        id = "nbp-forceTierValue",
        dontNetwork = false, 
        defaultValue = {},

        label = {":Force Tier Value", "nBattlepass"},

        values = {
            {id = "Tier", type = "TextEntry", placeholder = "Tier", isNumeric = true},
            {id = "IsPremiumSlot", type = "CheckBox", placeholder = "Premium Slot"},
            {id = "Reward", type = "ComboBox", placeholder = "Reward", values = function()
                local tbl = {}
                for id, v in pairs(Nexus.Battlepass.Rewards) do
                    if not v.ShouldShow() then continue end
                    table.insert(tbl, {text = v.Name, value = id})
                end
                return tbl
            end},
            {id = "Value", type = "TextEntry", placeholder = "Value"},
        },

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-battlepass-npcModel",
        defaultValue = "models/monk.mdl",
        dontNetwork = false,

        label = {":NPC Model", "nBattlepass"},
        placeholder = "models/monk.mdl",
        isNumeric = false,

        onChange = function(value) end,
    })
:End()