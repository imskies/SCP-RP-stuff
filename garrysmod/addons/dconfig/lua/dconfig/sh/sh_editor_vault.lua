// Internal Tool Used by Dan exclusively.
DCONFIG2.Editor.OnSave("vault", function(saveData)
	local success =  DCONFIG2.AddVaultPack(saveData)
	local msg = "Successfully Saved " .. saveData.name
	if not success then
		return {success = false, msg = "Failed to create vault pack."}
	end
	return {success = true, msg = msg, icon = "dconfig/vault.png", refresh = true}
end)

DCONFIG2.Editor.OnDelete("vault", function(saveData)
	local success =  DCONFIG2.RemoveVaultPack(saveData)
	local msg = "Successfully Deleted " .. saveData.name
	if not success then
		return {success = false, msg = "Failed to delete vault pack."}
	end
	return {success = true, msg = msg, icon = "dconfig/vault.png", refresh = true}
end)

DCONFIG2.Editor.Options["vault"] = {}


DCONFIG2.Editor.AddOption("vault", {
	name = "Pack Name",
	description = "The name of the content pack.",
	key = "name",
	type = "string",
  required = true,
})

DCONFIG2.Editor.AddOption("vault", {
	name = "Category",
	description = "The content pack category this pack is associated with.",
	key = "category",
	type = "string",
  required = true,
})

DCONFIG2.Editor.AddOption("vault", {
	name = "Imgur URL",
	description = "The end of the imgur image url.",
	key = "img",
	type = "string",
  required = false,
})

DCONFIG2.Editor.AddOption("vault", {
	name = "Steam URL",
	description = "The complete steam URL",
	key = "steamImg",
	type = "string",
  required = true,
})


DCONFIG2.Editor.AddOption("vault", {
	name = "Workshop IDs",
	description = "A list of the workshop ids that are necessary for this content pack to function.",
	key = "workshopid",
	type = "string",
    required = true,
	saveformat = function(val)
		return DCONFIG2.ConvertToModelTbl( val )
	end,
	loadFormat = function(val, editorData, contentData)
		if contentData and contentData.workshopid then
			return DCONFIG2.ConvertToModelStr( contentData.workshopid )
		end
		return val
	end,
})

DCONFIG2.Editor.AddOption("vault", {
	name = "Job List",
	description = "Select jobs for pack",
	key = "job_lookup",
	type="searchlist",
	required = false,
	presave = function(option, saveData, formattedVal, rawVal)
		saveData.data = saveData.data or {}
		saveData.data.jobs = {}
		for jobVar, jobData in pairs(option.contentPanel.selectedOptions) do
			table.insert(saveData.data.jobs, jobData)
		end
	end,
	searchList = {
		isSorted = true,
		isSelected = function(value, selectedOptions)
			return selectedOptions[string.lower(value.jobvar)]
		end,
		getSelected = function(body, editorData)
			local contentData = body.editorPanel.contentData
			if not contentData then return end
			local selected = {}
			if not contentData.data or not contentData.data.jobs then return end
			for k,v in pairs(contentData.data.jobs) do
				selected[v] = string.lower(v.jobvar)
			end
			return selected, true
		end,
		getList = function(body, selectedOptions)
			return DCONFIG2.SortSelectedTable(RPExtraTeams)
		end,
		isSearchFound = function(searchStr, key, val)
			return string.find(string.lower(val.name), string.lower(searchStr))
		end,
		getModel = function(value)
			return type(value.model) == "string" and value.model or value.model[1]
		end,
		getTitleLabel = function(key, value)
			return value.name
		end,
		getSubLabel = function(key, value)
			return value.category
		end,
		click = function(value, body, panel, editorOptions, data, yes)
			local jobVar = string.lower(value.jobvar)
			if not panel.selectedOptions[jobVar] then
				panel.selectedOptions[jobVar] = value
			else
				panel.selectedOptions[jobVar] = nil
			end
		end,
		rightClick = function(value, body, panel, editorOptions, data)
			PrintTable(value)
		end,
	},
})


DCONFIG2.Editor.AddOption("vault", {
	name = "Shipment List",
	description = "Select shipments for pack",
	key = "shipment_lookup",
	type="searchlist",
	required = false,
	presave = function(option, saveData, formattedVal, rawVal)
		saveData.data = saveData.data or {}
		saveData.data.shipments = {}
		for jobVar, jobData in pairs(option.contentPanel.selectedOptions) do
			table.insert(saveData.data.shipments, jobData)
		end
	end,
	searchList = {
		isSorted = true,
		isSelected = function(value, selectedOptions)
			return selectedOptions[string.lower(value.name)]
		end,
		getSelected = function(body, editorData)
			local contentData = body.editorPanel.contentData
			if not contentData then return end
			if not contentData.data or not contentData.data.shipments then return end
			local selected = {}
			for k,v in pairs(contentData.data.shipments) do
				selected[v] = string.lower(v.name)
			end
			return selected
		end,
		getList = function(body, selectedOptions)
			local contentData = body.editorPanel.contentData
			if not contentData then return DCONFIG2.SortSelectedTable(CustomShipments) end
			if not contentData.data or not contentData.data.shipments then return DCONFIG2.SortSelectedTable(CustomShipments) end
			local shipments = {}
			local created = {}
			for k,v in ipairs(contentData.data.shipments) do
				created[v.name .. v.price] = true
				table.insert(shipments, v)
			end
			for k,v in ipairs(CustomShipments) do
				if created[v.name .. v.price] then continue end
				table.insert(shipments, v)
			end
			return DCONFIG2.SortSelectedTable(shipments)
		end,
		isSearchFound = function(searchStr, key, val)
			return string.find(string.lower(val.name), string.lower(searchStr)) or string.find(string.lower(val.entity), string.lower(searchStr))
		end,
		getModel = function(value)
			return type(value.model) == "string" and value.model or value.model[1]
		end,
		getTitleLabel = function(key, value)
			return value.name
		end,
		getSubLabel = function(key, value)
			return value.entity
		end,
		click = function(value, body, panel, editorOptions, data, yes)
			local name = string.lower(value.name)
			if not panel.selectedOptions[name] then
				panel.selectedOptions[name] = value
			else
				panel.selectedOptions[name] = nil
			end
		end,
		rightClick = function(value, body, panel, editorOptions, data)
			PrintTable(value)
		end,
	},
})

DCONFIG2.Editor.AddOption("vault", {
	name = "Ammo List",
	description = "Select entities for pack",
	key = "ammo_lookup",
	type="searchlist",
	required = false,
	presave = function(option, saveData, formattedVal, rawVal)
		saveData.data = saveData.data or {}
		saveData.data.ammo = {}
		for jobVar, jobData in pairs(option.contentPanel.selectedOptions) do
			table.insert(saveData.data.ammo, jobData)
		end
	end,
	searchList = {
		isSorted = true,
		isSelected = function(value, selectedOptions)
			return selectedOptions[string.lower(value.name)]
		end,
		getSelected = function(body, editorData)
			local contentData = body.editorPanel.contentData
			if not contentData then return end
			if not contentData.data or not contentData.data.ammo then return end
			local selected = {}
			for k,v in pairs(contentData.data.ammo) do
				selected[v] = string.lower(v.name)
			end
			return selected
		end,
		getList = function(body, selectedOptions)
			local contentData = body.editorPanel.contentData
			local storedAmmo = (GM or GAMEMODE).AmmoTypes
			if not contentData then return DCONFIG2.SortSelectedTable(storedAmmo) end
			if not contentData.data or not contentData.data.ammo then return DCONFIG2.SortSelectedTable(storedAmmo) end
			local ammo = {}
			local created = {}
			for k,v in ipairs(contentData.data.ammo) do
				created[v.name .. v.price] = true
				table.insert(ammo, v)
			end
			for k,v in ipairs(storedAmmo) do
				if created[v.name .. v.price] then continue end
				table.insert(ammo, v)
			end
			return DCONFIG2.SortSelectedTable(ammo)
		end,
		isSearchFound = function(searchStr, key, val)
			return string.find(string.lower(val.name), string.lower(searchStr))
		end,
		getModel = function(value)
			return type(value.model) == "string" and value.model or value.model[1]
		end,
		getTitleLabel = function(key, value)
			return value.name
		end,
		getSubLabel = function(key, value)
			return value.ammoType
		end,
		click = function(value, body, panel, editorOptions, data)
			local name = string.lower(value.name)
			if not panel.selectedOptions[name] then
				panel.selectedOptions[name] = value
			else
				panel.selectedOptions[name] = nil
			end
		end,
		rightClick = function(value, body, panel, editorOptions, data)
			PrintTable(value)
		end,
	},
})

DCONFIG2.Editor.AddOption("vault", {
	name = "Entity List",
	description = "Select entities for pack",
	key = "entity_lookup",
	type="searchlist",
	required = false,
	presave = function(option, saveData, formattedVal, rawVal)
		saveData.data = saveData.data or {}
		saveData.data.entities = {}
		for jobVar, jobData in pairs(option.contentPanel.selectedOptions) do
			table.insert(saveData.data.entities, jobData)
		end
	end,
	searchList = {
		isSorted = true,
		isSelected = function(value, selectedOptions)
			return selectedOptions[string.lower(value.name)]
		end,
		getSelected = function(body, editorData)
			local contentData = body.editorPanel.contentData
			if not contentData then return end
			if not contentData.data or not contentData.data.entities then return end
			local selected = {}
			for k,v in pairs(contentData.data.entities) do
				selected[v] = string.lower(v.name)
			end
			return selected
		end,
		getList = function(body, selectedOptions)
			local contentData = body.editorPanel.contentData
			if not contentData then return DCONFIG2.SortSelectedTable(DarkRPEntities) end
			if not contentData.data or not contentData.data.entities then return DCONFIG2.SortSelectedTable(DarkRPEntities) end
			local entities = {}
			local created = {}
			for k,v in ipairs(contentData.data.entities) do
				created[v.name .. v.price] = true
				table.insert(entities, v)
			end
			// Using pairs since the data that is being loaded in is not always going to be sequential. Sorry :-( 
			for k,v in pairs(DarkRPEntities) do
				if created[v.name .. v.price] then continue end
				table.insert(entities, v)
			end
			return DCONFIG2.SortSelectedTable(entities)
		end,
		isSearchFound = function(searchStr, key, val)
			return string.find(string.lower(val.name), string.lower(searchStr))
		end,
		getModel = function(value)
			return type(value.model) == "string" and value.model or value.model[1]
		end,
		getTitleLabel = function(key, value)
			return value.name
		end,
		getSubLabel = function(key, value)
			return value.ent
		end,
		click = function(value, body, panel, editorOptions, data, yes)
			local name = string.lower(value.name)
			if not panel.selectedOptions[name] then
				panel.selectedOptions[name] = value
			else
				panel.selectedOptions[name] = nil
			end
		end,
		rightClick = function(value, body, panel, editorOptions, data)
			PrintTable(value)
		end,
	},
})



// Create list selector for all jobs, shipments, categories, ammo, entities.
// index data with content.

