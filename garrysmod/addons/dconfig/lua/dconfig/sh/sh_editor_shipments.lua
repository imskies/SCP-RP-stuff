DCONFIG2.Editor.OnSave("shipments", function(saveData)
	local success =  DCONFIG2.AddCustomShipment(saveData)
	local msg = "Successfully Saved " .. saveData.name
	if not success then
		return {success = false, msg = "Failed to create shipment."}
	end
	return {success = true, msg = msg, icon = "dconfig/shipment.png", refresh = true}
end)

DCONFIG2.Editor.OnDelete("shipments", function(saveData)
	local success =  DCONFIG2.RemoveShipment(saveData)
	local msg = "Successfully Deleted " .. saveData.name
	if not success then
		return {success = false, msg = "Failed to delete shipment."}
	end
	return {success = true, msg = msg, icon = "dconfig/shipment.png", refresh = true}
end)

DCONFIG2.Editor.OnReset("shipments", function(contentData)
	local success = DCONFIG2.ResetShipment(contentData)
	local msg = "Successfully Reset " .. contentData.name
	if not success then
		return {success = false, msg = "Failed to reset shipment."}
	end
	return {success = true, msg = msg, icon = "dconfig/shipment.png", refresh = true}
end)

local ignoreVals = {
	["dconfig"] = true,
	["name"] = true,
	["updateTime"] = true,
	["allowed"] = true,
}

local formatVals = {
	customCheckString = function(val)
		return {
			key = "customCheck",
			val = "function(ply) " .. val .. " end",
		}
	end,
	allowedStr = function(val)
		return {
			key = "allowed",
			val = DCONFIG2.FormatAllowedStrExport(val)
		}
	end,
}


DCONFIG2.Editor.OnExport("shipments", function(contentData)
	local codeStr = DCONFIG2.FormatExport(contentData, ignoreVals, formatVals)
	codeStr = 'DarkRP.createShipment(' .. '"' .. contentData.name .. '", { \n'.. codeStr
	print(codeStr)
	SetClipboardText(codeStr)
	return {success = true, msg = "Successfully copied shipment code to clipboard.", icon = "dconfig/shipment.png", refresh = true}
end)

DCONFIG2.Editor.Options["shipments"] = {}

DCONFIG2.AddUpdateInfo("shipments")

DCONFIG2.Editor.AddOption("shipments", {
	name = "Shipment Name",
	description = "The name of the Shipment. Names act as a unique identifier for Shipments.",
	key = "name",
	type = "string",
	default = "MISSING NAME",
	required = true,
})

DCONFIG2.Editor.AddOption("shipments", {
	name = "Weapon Classname",
	description = "The classname of the weapon.",
	key = "entity",
	type = "string",
	required = true,
})

DCONFIG2.Editor.AddOption("shipments", {
	name = "Weapon Model",
	description = "The world model of the weapon.",
	key = "model",
	type = "string",
	default = "models/Items/item_item_crate.mdl",
	required = true,
})

DCONFIG2.Editor.AddOption("shipments", {
	name = "Weapon Lookup",
	description = "Select a weapon - Autofills Model and Classname.",
	nokey = true,
	key = "weapon_lookup",
	type="searchlist",

	searchList = {
		getSelected = function(body, editorOptions)
			return nil
		end,
		isSorted = true,
		getList = function(body, selectedOptions)
			return DCONFIG2.SortSelectedTable(weapons.GetList())
		end,
		isSearchFound = function(searchStr, key, weapon)
			return string.find(string.lower(weapon.ClassName), searchStr)
		end,
		getModel = function(weapon)
			return weapon.WorldModel
		end,
		getTitleLabel = function(key, value)
			return value.PrintName or value.ClassName
		end,
		getSubLabel = function(key, value)
			return value.ClassName
		end,
		click = function(weapon, body, panel, editorOptions, data)
			editorOptions.name.textEntry:SetValue(weapon.PrintName or weapon.ClassName)
			editorOptions.entity.textEntry:SetValue(weapon.ClassName)
			editorOptions.model.textEntry:SetValue(weapon.WorldModel)
		end,
			
	}
})

DCONFIG2.Editor.AddOption("shipments", {
    name = "Category List",
    description = "Select a category - Autofills category.",
    key = "category_lookup",
    nokey = true,
    required = false,
    type = "list",
    getlist = function()
        local catNames = {}
        for k,v in ipairs(DarkRP.getCategories()["shipments"]) do
            table.insert(catNames, v.name)
        end 
        return catNames
    end,
    postbuild = function(body, panel, editorOptions, data)
        panel.comboBox.OnSelect = function(me, value, optionData)
            editorOptions.category.textEntry:SetValue(optionData)
        end
    end,
})

DCONFIG2.Editor.AddOption("shipments", {
	name = "Category",
	description = "The name of the category. If the category does not exist, it will be automatically created.",
	key = "category",
	type = "string",
	required = true,
	default = "Other",
})


DCONFIG2.Editor.AddOption("shipments", {
	name = "Price",
	description = "How much the shipment should cost.",
	key = "price",
	type = "number",
	default = function()
		return DCONFIG2.IngameConfig.shipment_default_price or 100
	end,
	required = false,
})


DCONFIG2.Editor.AddOption("shipments", {
	name = "Allowed Jobs",
	description = "Which teams are allowed to buy this shipment/separate gun. Example: TEAM_GUN,TEAM_BLACKMARKET",
	key = "allowed",
	type = "string",
	required = false,
	loadFormat = function(val, editorData, contentData)
		if editorData["allowedStr"] then
			return editorData["allowedStr"]
		end
		if contentData and contentData.allowed then
            if DCONFIG2.AllowsAll( contentData.allowed ) then
                return ""
            end 
			return DCONFIG2.ConvertToAllowedStr( contentData.allowed )
		end
		return val
	end,
	saveformat = function(val)
		return DCONFIG2.ConvertToAllowedTable( val )
	end,
	presave = function(option, saveData, formattedVal, rawVal)
        if formattedVal and DCONFIG2.AllowsAll( formattedVal ) then
            saveData["allowedStr"] = nil
            return
        end 
		saveData["allowedStr"] = rawVal
	end,
	shoulderror = function(editorOptions, formattedVal, rawVal)
		if rawVal == nil then return false end
		if table.Count(formattedVal) < 1 then
			return true, "The team variable listed is invalid or no longer exists."
		end
		return false
	end,
})

DCONFIG2.AddAllowedSearch("shipments")

DCONFIG2.Editor.AddOption("shipments", {
	name = "Separate Weapon",
	description = "Whether the item should be sold as a single weapon.",
	key = "separate",
	type = "boolean",
	default = true,
	required = false,
})

DCONFIG2.Editor.AddOption("shipments", {
	name = "No Shipment",
	description = "Whether the item should be sold as a shipment.",
	key = "noship",
	type = "boolean",
	default = false,
	required = false,
})

DCONFIG2.Editor.AddOption("shipments", {
	name = "Separate Price",
	description = "The price of the separately sold weapon.",
	key = "pricesep",
	type = "number",
	default = function()
		return DCONFIG2.IngameConfig.shipment_default_single_price or 10
	end,
	required = false,
})


DCONFIG2.Editor.AddOption("shipments", {
	name = "Sort Order",
	description = "The position of the shipment in it's category. The lower the number, the higher the position",
	key = "sortOrder",
	type = "number",
	required = false,
	default = 1,
})

DCONFIG2.Editor.AddOption("shipments", {
	name = "Shipment Spare Ammo",
	description = "Gives additional spare ammo.",
	key = "spareammo",
	type = "number",
	default = 0,
})

DCONFIG2.Editor.AddOption("shipments", {
	name = "Shipment Primary Clip",
	description = "The ammount of rounds in the primary clip by default.",
	key = "clip1",
	type = "number",
	default = 0,
})

DCONFIG2.Editor.AddOption("shipments", {
	name = "Shipment Secondary Clip",
	description = "The ammount of rounds in the secondary clip by default.",
	key = "clip2",
	type = "number",
	default = 0,
})

DCONFIG2.Editor.AddOption("shipments", {
	name = "Shipment Amount",
	description = "The amount of weapons to spawn in a shipment.",
	key = "amount",
	type = "number",
	default = 10,
})

DCONFIG2.Editor.AddOption("shipments", {
	name = "Shipment Custom Check",
	description = "Custom check takes priorty over steamids and usergroup fields. This is an Advanced Feature. Ex: return ply:Health() > 10",
	key = "customCheckString",
	type = "function",
	required = false,
	hardcodelock = true,
	lockmessage = "NO HARDCODE SUPPORT",
})

DCONFIG2.Editor.AddOption("shipments", {
	name = "Shipment Custom Check Fail Message",
	description = "The message to be displayed when the custom check fails!",
	key = "CustomCheckFailMsg ",
	type = "string",
	required = false,
	default = "You don't have access to this shipment!",
})

DCONFIG2.Editor.AddOption("shipments", {
	name = "Player Level - Requires Vrondakis Level System",
	description = "Level requirement to access this shipment.",
	key = "level",
	type = "number",
	required = false,
})