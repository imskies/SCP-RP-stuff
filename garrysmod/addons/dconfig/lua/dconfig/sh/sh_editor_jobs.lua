DCONFIG2.Editor.OnSave("jobs", function(saveData)
	local success = DCONFIG2.AddCustomJob(saveData)
	local msg = "Successfully Saved " .. saveData.name
	if not success then
		return {success = false, msg = "Failed to create job."}
	end
	return {success = true, msg = msg, icon = "dconfig/job.png", refresh = true}
end)

DCONFIG2.Editor.OnDelete("jobs", function(contentData)
	local success = DCONFIG2.RemoveJob(contentData)
	local msg = "Successfully Deleted " .. contentData.name
	if not success then
		return {success = false, msg = "Failed to delete job."}
	end
	return {success = true, msg = msg, icon = "dconfig/job.png", refresh = true}
end)

DCONFIG2.Editor.OnReset("jobs", function(contentData)
	local success = DCONFIG2.ResetJob(contentData)
	local msg = "Successfully Reset " .. contentData.name
	if not success then
		return {success = false, msg = "Failed to reset job."}
	end
	return {success = true, msg = msg, icon = "dconfig/job.png", refresh = true}
end)

local formatVals = {
	customCheckString = function(val)
		local returnData = {
			key = "customCheck",
			val = "function(ply) " .. val .. " end",
		}
		return returnData
	end,
}

local ignoreVals = {
	["team"] = true,
	["dconfig"] = true,
	["name"] = true,
	["updateTime"] = true,
	["customCheckString"] = true,
	["jobvar"] = true,
}

DCONFIG2.Editor.OnExport("jobs", function(contentData)
	local codeStr = DCONFIG2.FormatExport(contentData, ignoreVals, formatVals)
	codeStr =  contentData.jobvar .. ' = DarkRP.createJob(' .. '"' .. contentData.name .. '", { \n'.. codeStr
	print(codeStr)
	SetClipboardText(codeStr)
	return {success = true, msg = "Successfully copied job code to clipboard.", icon = "dconfig/job.png", refresh = true}
end)


DCONFIG2.Editor.Options["jobs"] = {}

DCONFIG2.AddUpdateInfo("jobs")

DCONFIG2.Editor.AddOption("jobs", {
	name = "Team Variable",
	description = "This variable must be unique for each job. Example: TEAM_DANFMN or TEAM_COP or TEAM_ADMIN",
	key = "jobvar",
	type = "string",
	default = "TEAM_EXAMPLE",
	required = true,
	hardcodelock = true,
	lockmessage = "Hardcoded jobs do not support function editing.",
    postbuild = function(body, panel, editorOptions, data)
        panel.originalValue = panel:GetValue()
    end,
    shoulderror = function(editorOptions, val)
        if val == editorOptions["jobvar"].originalValue then
            return false
        end 
        local storedTeam = _G[val]
        if not storedTeam or not RPExtraTeams[storedTeam] then
            return false
        end
        if RPExtraTeams[storedTeam] and RPExtraTeams[storedTeam].inLuaFile then
            return true, "This Variable belongs to a hard coded job. If you wish to edit the hard coded job, please select it from the editor."
        end 
    end,
})


DCONFIG2.Editor.AddOption("jobs", {
	name = "Name",
	description = "The name of the job",
	key = "name",
	type = "string",
	default = "MISSING NAME",
	required = true,
})

DCONFIG2.Editor.AddOption("jobs", {
    name = "Category List",
    description = "Select a category - Autofills category.",
    key = "category_lookup",
    nokey = true,
    required = false,
    type = "list",
    getlist = function()
        local catNames = {}
        for k,v in ipairs(DarkRP.getCategories()["jobs"]) do
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

DCONFIG2.Editor.AddOption("jobs", {
	name = "Category",
	description = "The Category the job will be associated with. Manually enter the category or use the selector below.",
	key = "category",
	type = "string",
	required = true,
})


DCONFIG2.Editor.AddOption("jobs", {
	name = "Command",
	description = "The unique command for the job. Do not include '/' for it's done automatically. Example: swat",
	key = "command",
	type = "string",
	required = true,
	shoulderror = function(editorOptions, val)
		local name = editorOptions.name:GetValue()
		local jobvar = editorOptions["jobvar"].textEntry:GetValue()
		local storedTeam = _G[jobvar]

		for k,v in ipairs(RPExtraTeams) do
			if storedTeam == k then continue end
			
			if val == v.command then
				print(storedTeam, k)
				return true, "The command: " .. val .. " is not unique! Job: " .. v.name .. " already uses this command."
			end
		end
		return false
	end,
})


DCONFIG2.Editor.AddOption("jobs", {
	name = "Player Model",
	description = "The player model(s) for the job. Manually enter the path or use the selector below. Example: modelpath1, modelpath2",
	key = "model",
	type = "string",
	required = true,
	saveformat = function(val)
		return DCONFIG2.ConvertToModelTbl( val )
	end,
	loadFormat = function(val, editorData, contentData)
		if contentData and contentData.model then
			return DCONFIG2.ConvertToModelStr( contentData.model )
		end
		return val
	end,
	valuechange = function(val, editorData)
		local modelLookup = editorData["model_lookup"]
		if modelLookup then
			local models = DCONFIG2.ConvertToModelTbl( val )
			modelLookup.selectedModels = modelLookup.selectedModels or {}
			for selectedModel,v in pairs(modelLookup.selectedModels) do
				if not table.HasValue(models, selectedModel) then
					modelLookup.selectedModels[selectedModel] = nil
				end
			end
			for k,typedModel in pairs(models) do
				if not modelLookup.selectedModels[typedModel] then
					modelLookup.selectedModels[typedModel] = true
				end
			end
		end
	end,
})


DCONFIG2.Editor.AddOption("jobs", {
	name = "Player Model List",
	description = "Select a player model - Autofills Playermodel.",
	nokey = true,
	key = "model_lookup",
	type="searchlist",
	required = false,
	searchList = {
		isSelected = function(model, selectedOptions)
			return selectedOptions[string.lower(model)]
		end,		
		getSelected = function(body, editorOptions)
			return DCONFIG2.ConvertStrToLookupTbl( editorOptions.model.textEntry:GetValue(), function(val)
				return string.lower(val)
			end)
		end,
		isSorted = true,
		getList = function(body, selectedOptions)
			return DCONFIG2.SortSelectedTable(player_manager.AllValidModels(), selectedOptions, function(val)
				return string.lower(val)
			end)
		end,
		isSearchFound = function(searchStr, key, model)
			return string.find(model, searchStr)
		end,
		getModel = function(model)
			return model
		end,
		getTitleLabel = function(key, value)
			return key
		end,
		getSubLabel = function(key, value)
			return value
		end,
		click = function(value, body, panel, editorOptions, data)
			value = string.lower(value)
			if not panel.selectedOptions[value] then
				local curVal = editorOptions.model.textEntry:GetValue()
				local newVal = ""
				if string.len(curVal) > 0 then
					newVal = curVal .. ", " .. value
				else
					newVal = value
				end
				panel.selectedOptions[value] = true
				editorOptions.model.textEntry:SetValue(newVal)
			else
				panel.selectedOptions[value] = nil
				local str = ""
				for k,v in pairs(panel.selectedOptions) do
					if string.len(str) <= 0 then
						str = k
					else
						str = str .. ", " .. k
					end
				end
				editorOptions.model.textEntry:SetValue(str)
			end
			if editorOptions.bodyGroupTool then 
				editorOptions.bodyGroupTool.rebuildResults()
			end
		end,
	},
	postbuild = function(body, panel, editorOptions, data)
		
	end,
})

/*

DCONFIG2.Editor.AddOption("jobs", {
	name = "Body Group Selector",
	description = "Select Body Groups",
	nokey = true,
	key = "bodyGroupTool",
	type = "bodygroup",
	required = false,
	bodyGroupTool = {
		getSelected = function(body, editorOptions)
			return DCONFIG2.ConvertStrToLookupTbl( editorOptions.model.textEntry:GetValue(), function(val)
				return string.lower(val)
			end)
		end,
	}
})
*/

/*
	TEAM_ZOMBIE = ...
		bodyGroups = {
			['zombie.mdl'] = {
				[0] = 1,
				[1] = 3,
				[2] = 0,
				[3] = 0,
				[4] = 1,
			},
			['citizen.mdl'] = {
				[0] = 1,
			},	
		}

*/


DCONFIG2.Editor.AddOption("jobs", {
	name = "Description",
	description = "The description of the job. This is commonly displayed near the job in the F4 menu. ( Use Arrow Keys to navigate )",
	key = "description",
	type = "string",
	multiLine = true,
	required = true,
	default = "This is a job. Please utilize this job appropriately."
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Max Players",
	description = "The amount of players that can have this job at once.",
	key = "max",
	type = "number",
	required = true,
	default = 4,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Admin Value",
	description = "The admin value for this job.",
	key = "admin",
	type = "number",
	required = false,
	default = 0,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Salary",
	description = "The amount of money this job pays each paycheck.",
	key = "salary",
	type = "number",
	required = false,
	default = 25,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Health",
	description = "The health of the player on spawn.",
	key = "health",
	type = "number",
	required = false,
	default = 100,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Armor",
	description = "The armor of the player on spawn.",
	key = "armor",
	type = "number",
	required = false,
	default = 0,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Max Armor",
	description = "The max amount of Armor this job should have. Most often used for UI.",
	key = "maxArmor",
	type = "number",
	required = false,
	default = 255,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Walk Speed",
	description = "How fast the player will walk on this job.",
	key = "walkSpeed",
	type = "number",
	required = false,
	default = 160,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Run Speed",
	description = "How fast the player will run on this job.",
	key = "runSpeed",
	type = "number",
	required = false,
	default = 240,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Jump Power",
	description = "The Jump power of the player.",
	key = "jumpPower",
	type = "number",
	required = false,
	default = 200,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "No Fall Damage",
	description = "Whether or not this job should take fall damage.",
	key = "noFallDamage",
	type = "boolean",
	required = false,
	default = false,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Damage Scale",
	description = "How much to scale this player's damage by when they're on this job.",
	key = "damageScale",
	type = "number",
	required = false,
	default = 1,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Player Model Material",
	description = "Apply a custom material to the player model.",
	key = "material",
	type = "string",
	required = false,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Sort Order",
	description = "The position of the job in it's category. The lower the number, the higher the position.",
	key = "sortOrder",
	type = "number",
	required = false,
	default = 1,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Model Scale",
	description = "The player model scale.",
	key = "modelScale",
	type = "number",
	required = false,
	default = 1,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Weapons",
	description = "The weapons the job will give on spawn.",
	key = "weapons",
	type = "string",
	saveformat = function(val)
		return DCONFIG2.ConvertToWeaponTbl( val )
	end,
	loadFormat = function(val, editorData, contentData)
		if contentData and contentData.weapons then
			return DCONFIG2.ConvertToWeaponStr( contentData.weapons )
		end
	end,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Weapons List",
	description = "Select a weapon - Autofills Weapons.",
	nokey = true,
	key = "weapons_lookup",
	type="searchlist",
	required = false,
	searchList = {
		isSelected = function(weapon, selectedOptions)
			return selectedOptions[weapon.ClassName]
		end,
		getSelected = function(body, editorOptions)
			return DCONFIG2.ConvertStrToLookupTbl( editorOptions.weapons.textEntry:GetValue() )
		end,
		isSorted = true,
		getList = function(body, selectedOptions)
			return DCONFIG2.SortSelectedTable(weapons.GetList(), selectedOptions, function(weapon)
				return weapon.ClassName
			end)
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
			local className = weapon.ClassName
			if not panel.selectedOptions[className] then
				local curVal = editorOptions.weapons.textEntry:GetValue()
				local newVal = ""
				if string.len(curVal) > 0 then
					newVal = curVal .. ", " .. className
				else
					newVal = className
				end
				panel.selectedOptions[className] = true
				editorOptions.weapons.textEntry:SetValue(newVal)
			else
				panel.selectedOptions[className] = nil
				local str = ""
				--PrintTable(panel.selectedOptions)
				for k,v in pairs(panel.selectedOptions) do
					if string.len(str) <= 0 then
						str = k
					else
						str = str .. ", " .. k
					end
				end
				editorOptions.weapons.textEntry:SetValue(str)
			end
		end,
	},
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Color",
	description = "The color of the job. ( Some F4 menus do not support this feature )",
	key = "color",
	type = "color",
	required = false,
	default = Color(255,255,255),
})


DCONFIG2.Editor.AddOption("jobs", {
	name = "Ammo",
	description = "The ammo that will be given on spawn.",
	key = "ammo",
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Has a License",
	description = "Whether this job has a license.",
	key = "hasLicense",
	type = "boolean",
	default = false,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Requires Vote",
	description = "Whether this job requires a vote to access it.",
	key = "vote",
	type = "boolean",
	default = false,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Can Demote",
	description = "Whether this job can be demoted or not.",
	key = "candemote",
	type = "boolean",
	default = true,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Demote On Death",
	description = "Whether the player should be set to the default job on death.",
	key = "demoteOnDeath",
	type = "boolean",
	default = false,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Demote On Death Message",
	description = "The message that is sent to all players when the player is demoted from death.",
	key = "demoteOnDeathMessage",
	type = "string",
	default = "The mayor has died! The position is now available."
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Player Spawn Function",
	description = "Run custom code on the player after they spawn. Example: ply:ChatPrint('You just spawned in!')",
	key = "PlayerSpawnStr",
	type = "function",
	hardcodelock = true,
	lockmessage = "Hardcoded jobs do not support function editing.",
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Steam ID Access",
	description = "Lock this job to a list of Steam IDs. Example: STEAM_0:0:90950610, STEAM_0:0:42950610",
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

DCONFIG2.Editor.AddOption("jobs", {
	name = "Usergroup Access",
	description = "Lock this job to a list of usergroups. Example: vip, admin, superadmin, founder",
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

DCONFIG2.Editor.AddOption("jobs", {
	name = "Job Custom Check",
	description = "Custom check takes priorty over steamids and usergroup fields. This is an Advanced Feature. Ex: return ply:Health() > 10",
	key = "customCheckString",
	type = "function",
	required = false,
	shoulderror = function(editorOptions, val)
		if not val then return false end

		local check, errorMSG = CompileString("local ply = select(1,...) " .. val, "customCheck", false)
		if type(check) == "function" then
			return false
		else
			return true, check
		end
		return false
	end,
	hardcodelock = true,
	lockmessage = "Hardcoded jobs do not support function editing.",
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Job Custom Check Fail Message",
	description = "The message to be displayed when the custom check fails!",
	key = "CustomCheckFailMsg ",
	type = "string",
	required = false,
	default = "You don't have access to this job!",
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Mayor",
	description = "Whether this job is considered a mayor or not.",
	key = "mayor",
	type = "boolean",
	default = false,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Hitman",
	description = "Whether this job is considered a hitman or not.",
	key = "hitman",
	type = "boolean",
	default = false,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Hobo",
	description = "Whether this job is considered a hobo or not.",
	key = "hobo",
	type = "boolean",
	default = false,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Chief",
	description = "Whether this job is considered a chief or not.",
	key = "chief",
	type = "boolean",
	default = false,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Medic",
	description = "Whether this job is considered a medic or not.",
	key = "medic",
	type = "boolean",
	default = false,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Cook",
	description = "Whether this job is considered a cook or not.",
	key = "cook",
	type = "boolean",
	default = false,
})

DCONFIG2.Editor.AddOption("jobs", {
	name = "Player Level - Requires Vrondakis Level System",
	description = "Level requirement to access this job.",
	key = "level",
	type = "number",
	required = false,
})


