
function DCONFIG2.RefreshDefaultF4Menu()
	if CLIENT and IsValid(DarkRP.getF4MenuPanel()) then DarkRP.getF4MenuPanel():Remove() end
end

function DCONFIG2.AddCustomJob(job)
	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Adding/Updating Custom Job " .. job.name)
	end
	local jobColor = job.color
	if jobColor then 
		job.color = Color(jobColor.r, jobColor.g, jobColor.b, jobColor.a)
	end
	if job.customCheckString and SERVER then
		local check
		local errorMSG
		if job.customCheckString then
			check, errorMSG = CompileString("local ply = select(1,...) " .. job.customCheckString, "customCheck", false)
		end
		if type(check) == "function" then
			job.customCheck = check
		else
			DCONFIG2.MsgC("CUSTOM CHECK MISTAKE " .. check)
			return false
		end
	end
	if not DCONFIG2.IsValidCategory("jobs", job.category) then
		print("Creating category for ", job.category)
		dpcall(DarkRP.createCategory, {
			name = job.category,
			sortOrder = 100,
			categorises = "jobs",
			color = Color(0, 107, 0, 255),
			startExpanded = true,
			dconfig = true,
		})
	end
	local onJobPlayers = {}
	local oldID = _G[job.jobvar]
	if SERVER then
		for k,ply in ipairs(player.GetAll()) do
			if ply:Team() == oldID then
				onJobPlayers[ply] = true
			end
		end
	end
	--TODO: Update entities, shipments, door groups, ammo, allowed with new IDS!!
	--print("SWAT:", TEAM_SWAT)
    local oldJobData = RPExtraTeams[oldID]
	if oldJobData then
        job.inLuaFile = oldJobData.inLuaFile
		job.teamKey = oldID
		DarkRP.removeJob(oldID)
		--print("REMOVING", job.jobvar, " OLD ", oldID)
	end
	local newID = dpcall(DarkRP.createJobDConfig, job.name, job)
	if (GM or GAMEMODE).DefaultTeam == oldID then
		(GM or GAMEMODE).DefaultTeam = newID
	end 
	DCONFIG2.MsgC("[DEBUG]: SETTING " .. job.jobvar .. " to " .. newID)
	-- PrintTable(job)
	if not job.jobvar then
		DCONFIG2.MsgC("FAILED TO LOAD A JOB: " .. job.name or "Unknown Job", true)
		PrintTable(job)
	end
	_G[job.jobvar] = newID
	if SERVER then
		for ply, _ in pairs(onJobPlayers) do
			timer.Simple(0, function()
				ply:SetTeam(-1)
				ply:changeTeam(newID, true, false)
			end)
		end
	end
	if job.cp and not (GM or GAMEMODE).CivilProtection[newID] then
		(GM or GAMEMODE).CivilProtection[newID] = true
	end
	if job.hitman then
		dpcall(DarkRP.addHitmanTeam, newID)
	end
	if job.defaultTeam then
		(GM or GAMEMODE).DefaultTeam = newID
	end

	DCONFIG2.RefreshDefaultF4Menu()
	return true
end


function DCONFIG2.AddCustomAmmo(ammo, isLoad)
	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Adding Ammo " .. ammo.name)
	end
	local ammoColor = ammo.color
	if ammoColor then 
		ammo.color = Color(ammoColor.r, ammoColor.g, ammoColor.b, ammoColor.a)
	end
	if not DCONFIG2.IsValidCategory("ammo", ammo.category) then
		dpcall(DarkRP.createCategory, {
			name = ammo.category,
			sortOrder = 100,
			categorises = "ammo",
			color = Color(0, 107, 0, 255),
			startExpanded = true,
			dconfig = true,
		})
	end
	local ammoTypes = (GM or GAMEMODE).AmmoTypes
	for k,v in pairs(ammoTypes) do
		if ammo.name == v.name then
			if isLoad then
				ammo.allowed = v.allowed
			end
			ammo.inLuaFile = v.inLuaFile
			ammo.originalName = v.originalName
			ammo.id = v.id
			DarkRP.removeAmmoType(k)
			break
		end
	end
	if ammo.allowedStr then
		ammo.allowed = DCONFIG2.ConvertToAllowedTable(ammo.allowedStr) or nil
	end
	if ammo.customCheckString then
		ammo.customCheck = CompileString("local ply = select(1,...) " .. ammo.customCheckString, "customCheck", false)
	end
	dpcall(DarkRP.createAmmoTypeDConfig, ammo.ammoType, ammo)
	DCONFIG2.RefreshDefaultF4Menu()
	return true
end

function DCONFIG2.AddCustomDoorgroup(doorgroup)
	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Adding Doorgroup " .. doorgroup.name)
	end
    local teams = doorgroup.allowed
    if not teams then
        local tempTbl = table.Copy(doorgroup)
        tempTbl.name = nil
        tempTbl.allowedStr = nil
        teams = tempTbl
    end 
    AddDoorGroup(doorgroup.name, unpack(teams))
	local newDoorgroup = RPExtraTeamDoors[doorgroup.name]
	for k,origDoorgroup in pairs(DCONFIG2.DarkRPOriginalData.doorgroups) do
		if origDoorgroup.name == doorgroup.name then
			newDoorgroup.originalName = origDoorgroup.originalName
			newDoorgroup.inLuaFile = origDoorgroup.inLuaFile
			break 
		end 
	end
    newDoorgroup.allowedStr = doorgroup.allowedStr
	DCONFIG2.RefreshDefaultF4Menu()
	return true
end


function DCONFIG2.AddCustomShipment(shipment, isLoad)
	shipment.amount = shipment.amount or 10
	shipment.category = shipment.category or "Weapons"
	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Adding Shipment " .. shipment.name)
	end
	local shipmentColor = shipment.color
	if shipmentColor then 
		shipment.color = Color(shipmentColor.r, shipmentColor.g, shipmentColor.b, shipmentColor.a)
	end
	if not DCONFIG2.IsValidCategory("shipments", shipment.name) then
		dpcall(DarkRP.createCategory, {
			name = shipment.category,
			sortOrder = 100,
			categorises = "shipments",
			color = Color(0, 107, 0, 255),
			startExpanded = true,
			dconfig = true,
		})
	end
	if not DCONFIG2.IsValidCategory("weapons", shipment.name) then
		dpcall(DarkRP.createCategory, {
			name = shipment.category,
			sortOrder = 100,
			categorises = "weapons",
			color = Color(0, 107, 0, 255),
			startExpanded = true,
			dconfig = true,
		})
	end

	if shipment.customCheckString then
		shipment.customCheck = CompileString("local ply = select(1,...) " .. shipment.customCheckString, "customCheck", false)
	end
	
	if isLoad then
		for k,v in pairs(CustomShipments) do
			if v.name == shipment.name then
				shipment.allowed = v.allowed
			end
		end 
	end
	
	if shipment.allowedStr then
		shipment.allowed = DCONFIG2.ConvertToAllowedTable(shipment.allowedStr) or nil
	end
	dpcall(DarkRP.createShipmentDConfig, shipment)

	DCONFIG2.RefreshDefaultF4Menu()
	return true
end

function DCONFIG2.AddCustomEntity(entity, isLoad)
	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Adding Entity " .. entity.name)
	end
	local entityColor = entity.color
	if entityColor then 
		entity.color = Color(entityColor.r, entityColor.g, entityColor.b, entityColor.a)
	end
	if not DCONFIG2.IsValidCategory("entities", entity.name) then
		dpcall(DarkRP.createCategory, {
			name = entity.category,
			sortOrder = 100,
			categorises = "entities",
			color = Color(0, 107, 0, 255),
			startExpanded = true,
			dconfig = true,
		})
	end
	
	local closeEnt, closeKey = DCONFIG2.FindClosestEntity(entity)
	if closeEnt and closeKey then 
		if isLoad then
			entity.allowed = closeEnt.allowed
		end
		DCONFIG2.MsgC(entity.name .. " already exists in memory. It's being replaced.")
		entity.inLuaFile = closeEnt.inLuaFile
		entity.originalName = closeEnt.originalName
		entity.id = closeEnt.id or closeKey
		DarkRP.removeEntity(closeKey)
	end
	if entity.allowedStr then
		local allowed = DCONFIG2.ConvertToAllowedTable(entity.allowedStr) or nil
		entity.allowed = DCONFIG2.ConvertToAllowedTable(entity.allowedStr) or nil
	end
	if entity.customCheckString then
		entity.customCheck = CompileString("local ply = select(1,...) " .. entity.customCheckString, "customCheck", false)
	end

	DarkRP.createEntityDConfig(entity.name, entity)
	DCONFIG2.RefreshDefaultF4Menu()
	return true
end

function DCONFIG2.AddCustomCategory(category)
	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Adding Category " .. ( category.name or "Unknown Name"))
	end
	category.members = nil
	category.color = Color(category.color.r, category.color.g, category.color.b, category.color.a)
	local categoriesList = DarkRP.getCategories()[category.categorises]
	if categoriesList then 
		for k,cat in pairs(categoriesList) do
			if cat.name == category.name and cat.categorises == category.categorises then
				category.inLuaFile = cat.inLuaFile
				category.originalName = cat.originalName
				break
			end 
		end
	end
	if category.categorises == "shipments" or category.categorises == "weapons" then
		category.categorises = "weapons"
		dpcall(DarkRP.createCategory, category)
		category.categorises = "shipments"
		dpcall(DarkRP.createCategory, category)
	else
		dpcall(DarkRP.createCategory, category)
	end
	DCONFIG2.RefreshDefaultF4Menu()
	return true
end

DCONFIG2.ChangedSettings = DCONFIG2.ChangedSettings or {}
DCONFIG2.OriginalSettings = DCONFIG2.OriginalSettings or {}

function DCONFIG2.GetOriginalDarkRPSetting(key)
	local cachedVal = DCONFIG2.OriginalSettings[key]
	local gmVal = (GM or GAMEMODE).Config[key]
	if not cachedVal then
		DCONFIG2.OriginalSettings[key] = gmVal
		return gmVal
	end
	return cachedVal
end

function DCONFIG2.UpdateDarkRPSettings(data)
	for k,v in pairs(data) do
		if k == "updateTime" then continue end

		local oldValue = DCONFIG2.GetOriginalDarkRPSetting(k)
		if oldValue != v then
			(GM or GAMEMODE).Config[k] = v
			if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
				DCONFIG2.ChangedSettings[k] = v
				DCONFIG2.MsgC("Updating DarkRP Setting " .. k .. " from " .. tostring(oldValue) .. " to " .. tostring(v))
			end
		else
			(GM or GAMEMODE).Config[k] = oldValue
			DCONFIG2.ChangedSettings[k] = nil
		end
	end
	return true
end

function DCONFIG2.UpdateDConfigSettings(data)
	for k,v in pairs(DCONFIG2.IngameConfig) do
		DCONFIG2.IngameConfig[k] = data[k] or v
	end 
end

function DCONFIG2.UpdateDConfigStat(stat, data)
    DCONFIG2.Stats.Data[stat] = data or {}
end 

function DCONFIG2.RemoveAmmo(ammo)

	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Removing Ammo " .. ammo.name)
	end
	local ammoTypes = (GM or GAMEMODE).AmmoTypes
	local found = false
	for k,v in pairs(ammoTypes) do
		if ammo.name == ammoTypes[k].name then
			DarkRP.removeAmmoType(k)
			found = true
		end
	end
	return found
end

function DCONFIG2.ResetAmmo(ammo)
	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Resetting ammo " .. ammo.name)
	end
	for k,originalAmmo in pairs(DCONFIG2.DarkRPOriginalData.ammo) do
		if ammo.originalName == originalAmmo.originalName then
			originalAmmo.shouldReset = true
			return DCONFIG2.AddCustomAmmo(originalAmmo)
		end
	end	
	return false
end

function DCONFIG2.RemoveEntity(entity)
	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Removing Entity " .. entity.name)
	end
	// Using pairs since the data that is being loaded in is not always going to be sequential. Sorry :-( ( DConfig 1 did not respect order )
	for k,v in pairs(DarkRPEntities) do
		if entity.name == DarkRPEntities[k].name then
			DarkRP.removeEntity(k)
			DCONFIG2.ShiftTblDown(DarkRPEntities, k)
			return true
		end
	end	
	return false
end

function DCONFIG2.ResetEntity(entity)
	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Resetting Entity " .. entity.name)
	end
	for k,originalEntity in pairs(DCONFIG2.DarkRPOriginalData.entities) do
		if entity.originalName == originalEntity.originalName then
			originalEntity.shouldReset = true
			return DCONFIG2.AddCustomEntity(originalEntity)
		end
	end	
	return false
end

function DCONFIG2.RemoveShipment(shipment)
	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Removing Shipment " .. shipment.name)
	end
	for k,v in pairs(CustomShipments) do
		if shipment.name == v.name then
			DarkRP.removeShipment(k)
			DCONFIG2.ShiftTblDown(CustomShipments, k)
			return true
		end
	end	
	return false
end

function DCONFIG2.ResetShipment(shipment)
	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Resetting Shipment " .. shipment.name)
	end
	for k,originalShipment in pairs(DCONFIG2.DarkRPOriginalData.shipments) do
		if shipment.originalName == originalShipment.originalName then
			originalShipment.shouldReset = true
			return DCONFIG2.AddCustomShipment(originalShipment)
		end
	end	
	return false
end

local function ResetPlayersOnJobDelete(deleteID)
	if SERVER then 
		for k,v in ipairs(player.GetAll()) do
			if v:Team() == deleteID then
				v:changeTeam((GM or GAMEMODE).DefaultTeam, true, false)
				DarkRP.notify(v, 1, 4, "Your job is no longer available.")
				continue
			end
			-- The table will have shifted everything above deletedID so we offset player's team by 1.
			if v:Team() > deleteID then
				v:SetTeam(v:Team() - 1)
			end 
		end
	end
end

local function RebuildAllowedTableOnDelete(deleteID, obj)
	if not obj.allowed then return end
	local shifted = false
	for k, jobID in pairs(obj.allowed) do
		if jobID > deleteID then
			obj.allowed[k] = jobID - 1
			shifted = true
		end
	end
	if not shifted then
		local deletedEntry = false
		for k,v in pairs(obj.allowed) do
			if v == deleteID then
				obj.allowed[k] = nil
				deletedEntry = true
				break
			end 
		end
		if deletedEntry and table.Count(obj.allowed) == 0 then
			obj.allowed = nil
			obj.allowedStr = nil
		end
	end 
end

local function RebuildAllowedTablesOnDelete(deleteID)
	for k,v in pairs(CustomShipments) do
		RebuildAllowedTableOnDelete(deleteID, v)
	end
	for k,v in pairs(DarkRPEntities) do
		RebuildAllowedTableOnDelete(deleteID, v)
	end
	for k,v in pairs((GM or GAMEMODE).AmmoTypes) do
		RebuildAllowedTableOnDelete(deleteID, v)
	end
end

local function ResetJobVarsOnDelete(deleteID)
	for k,v in pairs(RPExtraTeams) do
		--Update internal reference with new value.
		local jobID = _G[v.jobvar]
		if jobID and jobID > deleteID then
			local newID = jobID - 1
			DCONFIG2.MsgC("UPDATING: ".. v.jobvar .. " from " .. jobID .. " to ".. newID )
			_G[v.jobvar] = newID
			local storedJob = RPExtraTeams[newID]
			storedJob.teamKey = newID
			storedJob.team = newID
			DCONFIG2.getJobsByCommands()[storedJob.command] = newID
			addTeamCommands(storedJob, storedJob.max)
		end 
	end
end

function DCONFIG2.RemoveJob(job)
	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Removing Job " .. job.name)
	end
	local deleteID = _G[job.jobvar]
    local jobData = RPExtraTeams[deleteID]
	if jobData then
		-- Only necessary when shifting
		ResetPlayersOnJobDelete(deleteID)
		DarkRP.removeJob(deleteID)
		-- Only necessary when shifting
		DCONFIG2.ShiftTblDown(RPExtraTeams, deleteID)
		-- Only necessary when shifting
		ResetJobVarsOnDelete(deleteID)
		-- Only necessary when shifting
		RebuildAllowedTablesOnDelete(deleteID)
		return true
	end
	return false
end

function DCONFIG2.ResetJob(job)
	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Resetting Job " .. job.name)
	end
	local deleteID = _G[job.jobvar]
	local originalData = DCONFIG2.DarkRPOriginalData.jobs[deleteID]
	if not originalData then
		DCONFIG2.MsgC("Failed to find original data for Job " .. job.name, true)
		return false
	end 
	originalData.jobvar = job.jobvar
	originalData.shouldReset = true
	return DCONFIG2.AddCustomJob(originalData)
end

function DCONFIG2.RemoveCategory(category)
	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Removing Category " .. category.name)
	end
	local destination = category.categorises
	for k,v in pairs(DarkRP.getCategories()[destination]) do
		local cat = DarkRP.getCategories()[destination][k] 
		// PrintTable(cat)
		if cat.name == category.name then
			table.remove(DarkRP.getCategories()[destination], k)
			return true
		end 
	end
	return false
end

function DCONFIG2.ResetCategory(category)
	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Resetting Category " .. category.name)
	end
	local destination = category.categorises
	for k,cat in pairs(DCONFIG2.DarkRPOriginalData.categories) do
		if cat.originalName == category.originalName and cat.categorises == category.categorises then
			return DCONFIG2.AddCustomCategory(cat)
		end 
	end
	return false
end

function DCONFIG2.RemoveDoorGroup(doorGroup)
	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Removing Door Group " .. doorGroup.name)
	end
	RPExtraTeamDoors[doorGroup.name] = nil
	RPExtraTeamDoorIDs[doorGroup.name] = nil
	return true
end

function DCONFIG2.ResetDoorGroup(doorgroup)
	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Resetting doorgroup " .. doorgroup.name)
	end

	for k,origDoorgroup in pairs(DCONFIG2.DarkRPOriginalData.doorgroups) do
		if origDoorgroup.originalName == doorgroup.originalName then
			return DCONFIG2.AddCustomDoorgroup(origDoorgroup)
		end 
	end
	return false
end

function DCONFIG2.AddVaultPack(pack)
	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Adding Vault Pack " .. pack.name)
	end
	local cat = pack.category
	local packs = DCONFIG2.Vault[cat]
	if packs then 
		for k,foundPack in pairs(packs) do
			if foundPack.name == pack.name then
				packs[k] = pack
				return true
			end 
		end
		table.insert(packs, pack)
		return true
	else
		DCONFIG2.Vault[cat] = {pack}
		return true
	end
	return false
end 

function DCONFIG2.RemoveVaultPack(pack)
	if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
		DCONFIG2.MsgC("Removing Vault Pack " .. pack.name)
	end
	local cat = pack.category
	local packs = DCONFIG2.Vault[cat]
	if packs then 
		for k,foundPack in pairs(packs) do
			if foundPack.name == pack.name then
				packs[k] = nil
				if table.Count(packs) == 0 then
					DCONFIG2.Vault[cat] = nil
				end 
				return true
			end 
		end
	end
	return false
end 

function DCONFIG2.UpdateVault(data)
	DCONFIG2.Vault = data
end

function DCONFIG2.DownloadVaultFromNetwork(ignoreTbl, category, dataID)
	local vaultData = DCONFIG2.Vault[category][dataID]
	local downloadData = table.Copy(vaultData.data)
	for category,ignoredOptions in pairs(ignoreTbl) do
		for id, _ in pairs(ignoredOptions) do 
			downloadData[category][id] = nil
		end
	end
	for category, content in pairs(downloadData) do
		local fileManager = DCONFIG2.Data.FileManager[category]
		if not fileManager.loadEntry then continue end

		for k,data in pairs(content) do 
			local isValidModel = util.IsValidModel( type(data.model) == "string" and data.model or data.model[1] )
			if not isValidModel then
				
				return
			end
			fileManager.loadEntry(data)
		end
	end
end