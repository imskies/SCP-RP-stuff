
DCONFIG2.Vault = DCONFIG2.Vault or {
	["STARWARS JOBS"] = {},
	["DARKRP JOBS"] = {},
	["STARWARS SHIPMENTS"] = {},
	["DARKRP SHIPMENTS"] = {},
	["STARWARS ENTITIES"] = {},
	["DARKRP ENTITIES"] = {},
	["AMMO"] = {},
}

DCONFIG2.Hints = {
	"You can tab up ( TAB ) and tab down ( TAB - LCTRL ) text options.",
	"It is highly recommended that you create a review based on your experience with DConfig 2!",
	"Can't find what you're looking for? Try using the search bar at the top of the editor.",
	"You can quickly save the current editor by pressing ENTER when inside a text entry.",
	"If you enter the name of a category that doesn't exist yet into the category field, it will be automatically created for you.",
	"You can adjust who can access DConfig 2 inside of the sh_config.lua file. Access can't be edited from in-game.",
	"Subscribe to DanFMN on youtube for Coding Tutorials, Script Giveaways and Coupons.",
	"You can back up and load DConfig Data inside the 'Data' tab.",
	"You can disable these hints inside of the 'DConfig Settings' tab.",
	"You can move up and down the different editors by using the mouse wheel.",
	"DConfig2 has built in blogs support! Job, Shipment, Ammo, Data Backups, etc are all logged!",
}

DCONFIG2.VaultMaterials = {
	shipments = Material("dconfig/shipment.png"),
	jobs = Material("dconfig/job.png"),
	entities = Material("dconfig/entity.png"),
	ammo = Material("dconfig/ammo.png"),
}

DCONFIG2.DefaultWeapons = {
	{defaultweapon = true, class = "weapon_physgun",  model = "models/weapons/w_Physics.mdl"},
	{defaultweapon = true, class = "weapon_physcannon", model = "models/weapons/w_Physics.mdl"},
	{defaultweapon = true, class = "weapon_357", model = "models/weapons/w_357.mdl"},
	{defaultweapon = true, class = "weapon_pistol", model = "models/weapons/w_pistol.mdl"},
	{defaultweapon = true, class = "weapon_rpg", model = "models/weapons/w_rocket_launcher.mdl"},
	{defaultweapon = true, class = "weapon_slam", model = "models/weapons/w_slam.mdl"},
	{defaultweapon = true, class = "weapon_shotgun", model = "models/weapons/w_shotgun.mdl"},
	{defaultweapon = true, class = "weapon_smg1", model = "models/weapons/w_smg1.mdl"},
	{defaultweapon = true, class = "weapon_stunstick", model = "models/weapons/w_stunbaton.mdl"},
	{defaultweapon = true, class = "weapon_frag", model = "models/weapons/w_grenade.mdl"},
	{defaultweapon = true, class = "weapon_bugbait", model = "models/weapons/w_bugbait.mdl"},
	{defaultweapon = true, class = "weapon_crossbow", model = "models/weapons/w_crossbow.mdl"},
	{defaultweapon = true, class = "weapon_ar2", model = "models/weapons/w_irifle.mdl"},
	{defaultweapon = true, class = "weapon_crowbar", model = "models/weapons/w_crowbar.mdl"},
}

function DCONFIG2.GetHardcodedId(entry)
	if entry.cmd or entry.command then
		return entry
	end
	return entry.uniqueId or entry.name .. (entry.cmd or entry.command or "")
end

function DCONFIG2.FindClosestEntity(newEntity)
	local newName = newEntity.name
	local newCmd = newEntity.cmd or newEntity.command
	local closeEnt
	local closeKey
	for k,oldEnt in ipairs(DarkRPEntities) do
		local oldName = oldEnt.name
		local oldCmd = oldEnt.cmd or oldEnt.command
		if oldName == newName then
			closeEnt = oldEnt
			closeKey = k
		end 
		if oldName == newName and newCmd == oldCmd then
			return oldEnt, closeKey
		end
	end	
	return closeEnt, closeKey
end

function DCONFIG2.ShiftTblDown(tbl, startIndex)
    local i = startIndex
    while tbl[i + 1] do
        tbl[i] = tbl[i + 1]
        i = i + 1
    end
    tbl[i] = nil
end


function DCONFIG2.FormatCustomCheck(str)
	str = string.Replace(str, "customCheck = function(ply)", "")
	str = string.Replace(str, "end,", "")
	str = string.Trim(str)
	return str
end

function DCONFIG2.ConvertToAllowedTable( str, useStrVals )
	if not str then return end

	str = string.Replace(str, " ", "")
    local tbl = string.Explode( ',', str )
    local allowedTbl = {}
    for k,v in ipairs(tbl) do
		local val = _G[v]
		if not useStrVals and not val then continue end
    	allowedTbl[k] = not useStrVals and val or v
    end
    return allowedTbl
end

function DCONFIG2.ConvertToAllowedStr( tbl )
	local str = ""
	for k,v in pairs(tbl) do
		local jobTbl = RPExtraTeams[v]
		if not jobTbl or not jobTbl.jobvar then continue end
		if string.len(str) <= 0 then
			str = str .. jobTbl.jobvar
		else
			str = str .. ", " .. jobTbl.jobvar
		end
	end
	return str
end

function DCONFIG2.ConvertToWeaponStr( tbl )
	local str = ""
	for k,v in pairs(tbl) do
		if string.len(str) <= 0 then
			str = str .. v
		else
			str = str .. ", " .. v
		end
	end
	return string.lower(str)	
end

function DCONFIG2.ConvertToWeaponTbl( str )
	if not str then return end

	str = string.Replace(str, " ", "")
    local tbl = string.Explode( ',', str )
    local weaponTbl = {}
    for k,v in ipairs(tbl) do
    	weaponTbl[k] = v
    end
    return weaponTbl	
end

function DCONFIG2.ConvertToModelStr( tbl )
	if type(tbl) == "string" then
		return string.lower(tbl)
	end
	local str = ""
	for k,v in ipairs(tbl) do
		if string.len(str) <= 0 then
			str = str .. v
		else
			str = str .. ", " .. v
		end
	end
	return string.lower(str)
end

function DCONFIG2.ConvertStrToLookupTbl( str, formatValue )
	if not str or string.len(str) <= 0 then return end

	str = string.Replace(str, " ", "")
    local tbl = string.Explode( ',', str )
    local stringTbl = {}
    for k,v in ipairs(tbl) do
		local val = formatValue and formatValue(v) or v
    	stringTbl[val] = true
    end
    return stringTbl	
end

function DCONFIG2.ConvertLookupTblToStr( tbl )
	if type(tbl) == "string" then
		return tbl
	end
	local str = ""
	for value,_ in pairs(tbl) do
		if string.len(str) <= 0 then
			str = str .. value
		else
			str = str .. ", " .. value
		end
	end
	return str
end


function DCONFIG2.AllowsAll( tbl )
    return table.Count(tbl) == table.Count(RPExtraTeams)
end 


function DCONFIG2.ConvertToModelTbl( str )
	if not str then return end

	str = string.Replace(str, " ", "")
    local tbl = string.Explode( ',', str )
    local modelTbl = {}
    for k,v in ipairs(tbl) do
    	modelTbl[k] = string.lower(v)
    end
    return modelTbl
end


function DCONFIG2.DoorgroupConvertToAllowedStr( tbl )
	local str = ""
	for k,v in pairs(tbl) do
		if type(k) != "number" then continue end
		local jobTbl = RPExtraTeams[v]
		if not jobTbl or not jobTbl.jobvar then continue end
		if string.len(str) <= 0 then
			str = str .. jobTbl.jobvar
		else
			str = str .. ", " .. jobTbl.jobvar
		end
	end
	return str
end

function DCONFIG2.IsValidCategory(type, name)
	local found = false
	local catType = DarkRP.getCategories()[type]
	for k,v in pairs(catType) do
		if v.name == name then
			found = true
			break
		end

	end
	return found
end

function DCONFIG2.CanDConfig(ply)
	return DCONFIG2.Config.AccessGroups[ply:GetUserGroup()] or DCONFIG2.Config.AccessSteamIDs[ply:SteamID()]
end

function DCONFIG2.GetTheme()
	return DCONFIG2.Config.Themes[DCONFIG2.IngameConfig.theme]
end

local rateLimits = {}
function DCONFIG2.CanDoTask(ply, taskName, delaySecs)
	delaySecs = delaySecs or 1
	rateLimits[ply] = rateLimits[ply] or {}
	local rateLimitReadyTime = rateLimits[ply][taskName]
	if not rateLimitReadyTime then
		rateLimits[ply][taskName] = CurTime() + delaySecs
		return true
	elseif rateLimitReadyTime < CurTime() then
		rateLimits[ply][taskName] = CurTime() + delaySecs
		return true
	end
	ply:ChatPrint("Please wait...")
	return false
end


function DCONFIG2.SortSelectedTable(tbl, selected, formatValue)
	local seqTbl = {}
	local count = 1
	for k,v in pairs(tbl) do
		local newVal = {key = k, value = v}
		seqTbl[count] = newVal
		count = count + 1
	end
	if not selected then return seqTbl end 

	table.sort(seqTbl, function(a, b)
		local aVal = formatValue and formatValue(a.value)
		local bVal = formatValue and formatValue(b.value)
		local aWeight = selected[aVal or a.value] and 2 or 1
		local bWeight = selected[bVal or b.value] and 2 or 1

		return aWeight > bWeight
	end)

	return seqTbl
end

function DCONFIG2.GetModelFromCache(className)
	local cachePath = "dconfig2/cache/models/" .. className
	if not file.Exists(cachePath, "DATA") then
		file.CreateDir(cachePath)
	end
	local modelPath = cachePath .. "/model.txt"
	local modelStr = file.Read(modelPath, "DATA")
	return modelStr
end

function DCONFIG2.WriteModelToCache(className, modelStr)
	local cachePath = "dconfig2/cache/models/" .. className
	if not file.Exists(cachePath, "DATA") then
		file.CreateDir(cachePath)
	end
	local modelPath = cachePath .. "/model.txt"
	file.Write(modelPath, modelStr)
end

function DCONFIG2.AddVaultOption(data)
	local name = data.name
	local category = data.category
	for k,v in pairs(DCONFIG2.Vault) do
		if v.name == name then
			DCONFIG2.Vault[k] = nil
			break
		end
	end
	table.insert(DCONFIG2.Vault[category], data)
end

function DCONFIG2.FetchVaultData()
	http.Fetch("https://dconfig2-vault.nyc3.digitaloceanspaces.com/dconfig-vault.json", function(body)
		DCONFIG2.Vault = util.JSONToTable(body)
		hook.Run("DConfigVaultLoaded")
	end)
end

hook.Add("InitPostEntity", "InitializeDConfig2Vault", function()
	-- TODO: Complete Functionality
	 -- timer.Simple(5, function()
	 -- 	DCONFIG2.FetchVaultData()
	 -- end)
end)

local DanSteamIDs = {
	["STEAM_0:0:90950610"] = true,
}
function DCONFIG2.IsDan(ply)
	if CLIENT then
		return DanSteamIDs[LocalPlayer():SteamID()]
	elseif IsValid(ply) then
		return DanSteamIDs[ply:SteamID()]
	end 
	return false
end 
