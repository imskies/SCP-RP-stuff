DCONFIG2.Editor.OnSave("entities", function(saveData)
	local success =  DCONFIG2.AddCustomEntity(saveData)
	if not success then
		return {success = false, msg = "Failed to create entity.", icon = "dconfig/entity.png"}
	end
	return {success = true, msg = "Sucessfully Saved " .. saveData.name, icon = "dconfig/entity.png", refresh = true}
end)

DCONFIG2.Editor.OnDelete("entities", function(contentData)
	local success =  DCONFIG2.RemoveEntity(contentData)
	if not success then
		return {success = false, msg = "Failed to remove entity.", icon = "dconfig/entity.png"}
	end
	return {success = true, msg = "Sucessfully Deleted " .. contentData.name, icon = "dconfig/entity.png", refresh = true}
end)

DCONFIG2.Editor.OnReset("entities", function(contentData)
	local success = DCONFIG2.ResetEntity(contentData)
	local msg = "Successfully Reset " .. contentData.name
	if not success then
		return {success = false, msg = "Failed to reset entity."}
	end
	return {success = true, msg = msg, icon = "dconfig/entity.png", refresh = true}
end)


local ignoreVals = {
	["dconfig"] = true,
	["name"] = true,
	["updateTime"] = true,
	["allowed"] = true,
	["customCheckString"] = true,
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


DCONFIG2.Editor.OnExport("entities", function(contentData)
	local codeStr = DCONFIG2.FormatExport(contentData, ignoreVals, formatVals)
	codeStr = 'DarkRP.createEntity(' .. '"' .. contentData.name .. '", { \n'.. codeStr
	print(codeStr)
	SetClipboardText(codeStr)
	return {success = true, msg = "Successfully copied entity code to clipboard.", icon = "dconfig/entity.png", refresh = true}
end)


DCONFIG2.Editor.Options["entities"] = {}

DCONFIG2.AddUpdateInfo("entities")

DCONFIG2.Editor.AddOption("entities", {
	name = "Name",
	description = "The name of the entity. This is also a unique identifier.",
	key = "name",
	type = "string",
	default = "MISSING NAME",
	required = true,
})

DCONFIG2.Editor.AddOption("entities", {
	name = "Entity",
	description = "The classname of the entitiy.",
	key = "ent",
	type = "string",
	required = true,
})

DCONFIG2.Editor.AddOption("entities", {
	name = "Model",
	description = "The model for the entity in the F4 menu.",
	key = "model",
	type = "string",
	required = true,
})

DCONFIG2.Editor.AddOption("entities", {
	name = "Entity Lookup",
	description = "Select an Entity - Populates Entity",
	nokey = true,
	key = "entity_lookup",
	type="searchlist",
	searchList = {
		getSelected = function(body, editorOptions)
			return nil
		end,
		getList = function(body, selectedOptions)
			return scripted_ents.GetList()
		end,
		isSearchFound = function(searchStr, className, entity)
			return string.find(string.lower(className), searchStr)
		end,
		getModel = function(entity)
			local entData = entity.t
			return entData.WorldModel or "models/props_c17/consolebox01a.mdl"
		end,
		getTitleLabel = function(key, entity)
			local entData = entity.t
			return entData.PrintName or entData.ClassName
		end,
		getSubLabel = function(key, entity)
			return entity.t.ClassName
		end,
		click = function(entity, body, panel, editorOptions, data, modelPanel)
			editorOptions.ent.textEntry:SetValue(entity.t.ClassName)
			editorOptions.model.textEntry:SetValue(modelPanel.path)
			if entity.t.PrintName then
				editorOptions.name.textEntry:SetValue(entity.t.PrintName)
			end
		end,
		generateModel = function(entity)
			return DCONFIG2.GetEntityModel(entity.t.ClassName)
		end,		
	},
})

DCONFIG2.Editor.AddOption("entities", {
	name = "Command",
	description = "The unique command for the entity. Do not include '/' for it's done automatically. Example: buyprinter",
	key = "cmd",
	type = "string",
	required = true,
	shoulderror = function(editorOptions, val)
		local name = editorOptions.name:GetValue()
		for k,v in ipairs(DarkRPEntities) do
			if v.name != name and val == v.cmd then
				return true, "The command: " .. val .. " is not unique! Entity: " .. v.name .. " already uses this command."
			end
		end
		return false
	end,
})

DCONFIG2.Editor.AddOption("entities", {
	name = "Price",
	description = "How much the entity should cost.",
	key = "price",
	type = "number",
	default = 100,
	required = true,
})

DCONFIG2.Editor.AddOption("entities", {
	name = "Max Entities",
	description = "The maximum amount of times a player can buy this entitiy.",
	key = "max",
	type = "number",
	required = true,
	default = 4,
})

DCONFIG2.Editor.AddOption("entities", {
	name = "Allowed Jobs",
	description = "Which teams are allowed to buy this entity. Example: TEAM_GUN, TEAM_BLACKMARKET",
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

DCONFIG2.AddAllowedSearch("entities")

DCONFIG2.Editor.AddOption("entities", {
	name = "Category List",
	description = "Select a category - Autofills category.",
	key = "category_lookup",
	nokey = true,
	required = false,
	type = "list",
	getlist = function()
		local catNames = {}
		for k,v in ipairs(DarkRP.getCategories()["entities"]) do
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

DCONFIG2.Editor.AddOption("entities", {
	name = "Category",
	description = "The name of the category. If the category does not exist, it will be automatically created.",
	key = "category",
	type = "string",
	required = true,
})

DCONFIG2.Editor.AddOption("entities", {
	name = "Steam ID Access",
	description = "Lock this entity to a list of Steam IDs. Example: STEAM_0:0:90950610, STEAM_0:0:42950610",
	key = "steamids",
	type = "string",
	required = false,
	saveformat = function(val)
		return DCONFIG2.ConvertStrToLookupTbl( val )
	end,
	loadFormat = function(val, editorData, contentData)
		if contentData and contentData.steamids then
			return DCONFIG2.ConvertLookupTblToStr( contentData.steamids )
		end
	end,
})

DCONFIG2.Editor.AddOption("entities", {
	name = "Usergroup Access",
	description = "Lock this entity to a list of usergroups. Example: vip, admin, superadmin, founder",
	key = "accessgroups",
	type = "string",
	required = false,
	saveformat = function(val)
		return DCONFIG2.ConvertStrToLookupTbl( val )
	end,
	loadFormat = function(val, editorData, contentData)
		if contentData and contentData.accessgroups then
			return DCONFIG2.ConvertLookupTblToStr( contentData.accessgroups )
		end
	end,
})

DCONFIG2.Editor.AddOption("entities", {
	name = "Entity Custom Check",
	description = "Custom check takes priorty over steamids and usergroup fields. This is an Advanced Feature. Ex: return ply:Health() > 10",
	key = "customCheckString",
	type = "function",
	required = false,
	hardcodelock = true,
	lockmessage = "NO HARDCODE SUPPORT",
})

DCONFIG2.Editor.AddOption("entities", {
	name = "Entity Custom Check Fail Message",
	description = "The message to be displayed when the custom check fails!",
	key = "CustomCheckFailMsg ",
	type = "string",
	required = false,
	default = "You don't have access to this entity!",
})


DCONFIG2.Editor.AddOption("entities", {
	name = "Sort Order",
	description = "The position of the job in it's category. The lower the number, the higher the position.",
	key = "sortOrder",
	type = "number",
	required = false,
	default = 1,
})

DCONFIG2.Editor.AddOption("entities", {
	name = "Player Level - Requires Vrondakis Level System",
	description = "Level requirement to access this entity.",
	key = "level",
	type = "number",
	required = false,
})