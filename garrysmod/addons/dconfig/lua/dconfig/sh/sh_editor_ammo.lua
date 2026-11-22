DCONFIG2.Editor.OnSave("ammo", function(saveData)
	local success = DCONFIG2.AddCustomAmmo(saveData)
	local msg = "Successfully Saved " .. saveData.name
	if not success then
		return {success = false, msg = "Failed to create ammo."}
	end
	return {success = true, msg = msg, icon = "dconfig/ammo.png", refresh = true}
end)

DCONFIG2.Editor.OnDelete("ammo", function(contentData)
	local success = DCONFIG2.RemoveAmmo(contentData)
	local msg = "Successfully Deleted " .. contentData.name
	if not success then
		return {success = false, msg = "Failed to delete ammo."}
	end
	return {success = true, msg = msg, icon = "dconfig/ammo.png", refresh = true}
end)

DCONFIG2.Editor.OnReset("ammo", function(contentData)
	local success = DCONFIG2.ResetAmmo(contentData)
	local msg = "Successfully Reset " .. contentData.name
	if not success then
		return {success = false, msg = "Failed to reset ammo."}
	end
	return {success = true, msg = msg, icon = "dconfig/ammo.png", refresh = true}
end)

local ignoreVals = {
	["dconfig"] = true,
	["updateTime"] = true,
	["allowed"] = true,
	["ammoType"] = true,
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

DCONFIG2.Editor.OnExport("ammo", function(contentData)
	local codeStr = DCONFIG2.FormatExport(contentData, ignoreVals, formatVals)
	codeStr = 'DarkRP.createAmmoType(' .. '"' .. contentData.ammoType .. '", { \n'.. codeStr
	print(codeStr)
	SetClipboardText(codeStr)
	return {success = true, msg = "Successfully copied ammo code to clipboard.", icon = "dconfig/ammo.png", refresh = true}
end)


DCONFIG2.Editor.Options["ammo"] = {}

DCONFIG2.AddUpdateInfo("ammo")

DCONFIG2.Editor.AddOption("ammo", {
	name = "Ammo Name",
	description = "The name of the ammo. This is also a unique identifier.",
	key = "name",
	type = "string",
	required = true,
})

DCONFIG2.Editor.AddOption("ammo", {
	name = "Ammo Type",
	description = "The ammo type.",
	key = "ammoType",
	type = "string",
	required = true,
})

DCONFIG2.Editor.AddOption("ammo", {
	name = "Price",
	description = "The cost of the ammo.",
	key = "price",
	type = "number",
	default = function()
		return DCONFIG2.IngameConfig.ammo_default_price or 25
	end,
	required = true,
})

DCONFIG2.Editor.AddOption("ammo", {
	name = "Model",
	description = "The model for the ammo type.",
	key = "model",
	type = "string",
	required = true,
})

DCONFIG2.Editor.AddOption("ammo", {
	name = "Ammo Lookup",
	description = "Select an Ammo - Populates Ammo",
	nokey = true,
	key = "ammo_lookup",
	type="searchlist",
	searchList = {
		getSelected = function(body, editorOptions)
			return nil
		end,
		getList = function(body, selectedOptions)
			return {
				{name = "ar2", model = "models/items/combine_rifle_cartridge01.mdl"}, 
				{name = "ar2altfire", model = "models/items/combine_rifle_ammo01.mdl"},
				{name = "pistol", model = "models/items/boxsrounds.mdl"},
				{name = "smg1", model = "models/items/boxmrounds.mdl"},
				{name = "357", model = "models/items/357ammo.mdl"},
				{name = "xbowbolt", model = "models/items/crossbowrounds.mdl"},
				{name = "buckshot", model = "models/items/boxbuckshot.mdl"},
				{name = "rpg_round", model = "models/weapons/w_missile_closed.mdl"},
				{name = "smg1_grenade", model = "models/items/ar2_grenade.mdl"},
				{name = "grenade", model = "models/weapons/w_npcnade.mdl"},
				{name = "slam", model = "models/Items/item_item_crate_dynamic.mdl"},
				{name = "alyxgun", model = "models/items/boxmrounds.mdl"},		
			}
		end,
		isSearchFound = function(searchStr, className, ammo)
			return string.find(string.lower(ammo.name), searchStr)
		end,
		getModel = function(ammo)
			return ammo.model
		end,
		getTitleLabel = function(key, ammo)
			return ammo.name
		end,
		getSubLabel = function(key, ammo)
			return ammo.model
		end,
		click = function(ammo, body, panel, editorOptions, data, modelPanel)
			editorOptions.ammoType.textEntry:SetValue(ammo.name)
			editorOptions.model.textEntry:SetValue(ammo.model)
		end,	
	},
})


DCONFIG2.Editor.AddOption("ammo", {
	name = "Amount Given",
	description = "The amount of ammo to give on pickup.",
	key = "amountGiven",
	type = "number",
	default = 30,
	required = true,
})


DCONFIG2.Editor.AddOption("ammo", {
	name = "Allowed Jobs",
	description = "Which teams are allowed to buy this ammo. Example: TEAM_GUN, TEAM_BLACKMARKET",
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

DCONFIG2.AddAllowedSearch("ammo")

DCONFIG2.Editor.AddOption("ammo", {
	name = "Category List",
	description = "Select a category - Autofills category.",
	key = "category_lookup",
	nokey = true,
	required = false,
	type = "list",
	getlist = function()
		local catNames = {}
		for k,v in ipairs(DarkRP.getCategories()["ammo"]) do
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

DCONFIG2.Editor.AddOption("ammo", {
	name = "Category",
	description = "The name of the category. If the category does not exist, it will be automatically created.",
	key = "category",
	type = "string",
	required = true,
})

DCONFIG2.Editor.AddOption("ammo", {
	name = "Ammo Custom Check",
	description = "Custom check takes priorty over steamids and usergroup fields. This is an Advanced Feature. Ex: return ply:Health() > 10",
	key = "customCheckString",
	type = "function",
	required = false,
	hardcodelock = true,
	lockmessage = "NO HARDCODE SUPPORT",
})

DCONFIG2.Editor.AddOption("ammo", {
	name = "Ammo Custom Check Fail Message",
	description = "The message to be displayed when the custom check fails!",
	key = "CustomCheckFailMsg ",
	type = "string",
	required = false,
	default = "You don't have access to this ammo!",
})

DCONFIG2.Editor.AddOption("ammo", {
	name = "Player Level - Requires Vrondakis Level System",
	description = "Level requirement to access this ammo.",
	key = "level",
	type = "number",
	required = false,
})