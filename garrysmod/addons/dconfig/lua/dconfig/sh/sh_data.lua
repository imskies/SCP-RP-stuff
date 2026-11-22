local _P = FindMetaTable("Player")

local function errhandler(err)
	ErrorNoHalt("\nDConfig prevented an error from breaking the addon entirely."
		      .."\n ** This is most likely an error with your hard-coded jobs, weapons or entities in .lua files.\n\n")
	ErrorNoHalt(err)
end
function dpcall(fn, ...)
	local ret = {xpcall(fn, errhandler, ...)}

	local succ = table.remove(ret, 1)

	return unpack(ret)
end

DCONFIG2.Data = {
	SaveDir = "dconfig2",
	SubFolders = {
		["general"] = true,
		["saves"] = true,
		["saves/active"] = true,
		["stats"] = true,
	},
	Backups = {},
	BlockedEntities = {
		zfs_fruitbox = true, 
		/*entity_drone_base = true, 
		entity_drone_bomb = true, 
		entity_drone_gold = true, 
		entity_drone_gun = true, 
		entity_drone_medic = true, 
		entity_drone_police = true, 
		entity_drone_spy = true, 
		entity_drone_transport = true, 
		entity_dronejammer = true, 
		entity_dronepad = true, */
	},
	FileManager = {
		vault = {
			data = function()
				return DCONFIG2.Vault
			end,
			loadBulk = DCONFIG2.UpdateVault,
		},
        jobs = {
            data = function()
				return RPExtraTeams
			end,
			loadEntry = DCONFIG2.AddCustomJob,
			shouldLoadEntry = function(dataEntry)
				if not dataEntry.jobvar then
					return false
				end
				return true
			end,
			shouldSaveEntry = function(dataEntry)
				if dataEntry.shouldReset then
					return false
				end
				return true
			end,
		},
		shipments = {
            data = function()
				return CustomShipments
			end,
			loadEntry = DCONFIG2.AddCustomShipment,
			shouldSaveEntry = function(dataEntry)
				if dataEntry.shouldReset then
					return false
				end
				return true
			end,
		},
		ammo = {
            data = function()
				return (GM or GAMEMODE).AmmoTypes
			end,
			loadEntry = DCONFIG2.AddCustomAmmo,
			deleteEntry = DCONFIG2.RemoveAmmo,
			shouldSaveEntry = function(dataEntry)
				if dataEntry.shouldReset then
					return false
				end
				return true
			end,
		},
		categories = {
            data = function()
				local categories = {}
				for categoryType, categoryTypeContent in pairs(DarkRP.getCategories()) do
					for k,v in pairs(categoryTypeContent) do 
						table.insert(categories, v)
					end 
				end
				return categories
			end,
			loadEntry = DCONFIG2.AddCustomCategory,
			shouldSaveEntry = function(dataEntry)
				if dataEntry.shouldReset then
					return false
				end
				return true
			end,
		},
		entities = {
            data = function()
				return DarkRPEntities
			end,
			loadEntry = DCONFIG2.AddCustomEntity,
			shouldLoadEntry = function(dataEntry)
				if DCONFIG2.Data.BlockedEntities[dataEntry.ent] then return false, "Not Supported." end

				return true
			end,
			shouldSaveEntry = function(dataEntry)
				if dataEntry.shouldReset then
					return false
				end
				return true
			end,
		},
		doorgroups = {
            data = function()
				return RPExtraTeamDoors
			end,
            loadEntry = DCONFIG2.AddCustomDoorgroup,
			shouldSaveEntry = function(dataEntry)
				if dataEntry.shouldReset then
					return false
				end
				return true
			end,
		},
		dconfig = {
            path = "dconfig2/general/dconfig.txt",
			data = function()
				return DCONFIG2.IngameConfig
			end,
			loadBulk = DCONFIG2.UpdateDConfigSettings,
		},
		settings = {
            data = function()
				return DCONFIG2.ChangedSettings
			end,
			loadBulk = function(data)
				DCONFIG2.ChangedSettings = data
				for k,v in pairs(DCONFIG2.ChangedSettings) do 
					local oldValue = DCONFIG2.GetOriginalDarkRPSetting(k)
					if oldValue != v then
						(GM or GAMEMODE).Config[k] = v
						if SERVER or CLIENT and DCONFIG2.CanDConfig(LocalPlayer()) then
							DCONFIG2.ChangedSettings[k] = v
							DCONFIG2.MsgC("Updating DarkRP Setting " .. k .. " from " .. tostring(oldValue) .. " to " .. tostring(v))
						end
					else
						DCONFIG2.ChangedSettings[k] = nil
					end
				end
			end,
		},
        stats_jobs = {
            path = "dconfig2/stats/jobs.txt",
            data = function()
                return DCONFIG2.Stats.Data.jobs
            end,
            loadBulk = function(data)
                DCONFIG2.UpdateDConfigStat("jobs", data)
            end,
        },
        stats_shipments = {
            path = "dconfig2/stats/shipments.txt",
            data = function()
                return DCONFIG2.Stats.Data.shipments
            end,
            loadBulk = function(data)
                DCONFIG2.UpdateDConfigStat("shipments", data)
            end,
        },
        stats_weapons = {
            path = "dconfig2/stats/weapons.txt",
            data = function()
                return DCONFIG2.Stats.Data.weapons
            end,
            loadBulk = function(data)
                DCONFIG2.UpdateDConfigStat("weapons", data)
            end,
        },
        stats_entities = {
            path = "dconfig2/stats/entities.txt",
            data = function()
                return DCONFIG2.Stats.Data.entities
            end,
            loadBulk = function(data)
                DCONFIG2.UpdateDConfigStat("entities", data)
            end,
        },
        stats_ammo = {
            path = "dconfig2/stats/ammo.txt",
            data = function()
                return DCONFIG2.Stats.Data.ammo
            end,
            loadBulk = function(data)
                DCONFIG2.UpdateDConfigStat("ammo", data)
            end,
        },
	}
}

local replace = {
	[":"] = "-",
	["/"] = "-",
  [" "] = "_",
  ["?"] = "",
  ["."] = "",
}


function DCONFIG2.GetEntryName(dataEntry)
	return dataEntry.name or dataEntry.ent or dataEntry.jobvar or "Unknown Entry"
end 

function DCONFIG2.FormatDirectory(directory)
	for old,new in pairs(replace) do
		directory = string.Replace(directory, old, new)
	end
    return string.Trim(directory)
end


function DCONFIG2.GetDefaultBackupTitle()
    local backupTitle = string.lower(os.date("%x", os.time()) .. " " .. os.date("%I-%M-%p", os.time()))
    return DCONFIG2.FormatDirectory(backupTitle)
end

local hardCoded = {
	jobs = true,
	shipments = true,
	ammo = true,
	categories = true,
	entities = true,
	doorgroups = true,
}
DCONFIG2.DarkRPOriginalData = DCONFIG2.DarkRPOriginalData or {}
DCONFIG2.FormattedHardcoded = {}
function DCONFIG2.PrepareHardcodedData()
	DCONFIG2.MsgC("Flagging hardcoded data and original data backup.")
	for dataType,_ in pairs(hardCoded) do 
		if not DCONFIG2.FormattedHardcoded[dataType] then
			local fileInfo = DCONFIG2.Data.FileManager[dataType]
			if not fileInfo then continue end

			local nonJob = dataType != "jobs"
			for k,dataEntry in pairs(fileInfo.data()) do
				dataEntry.inLuaFile = true
				if nonJob then
					dataEntry.originalName = dataEntry.name
				end 
			end
			DCONFIG2.FormattedHardcoded[dataType] = true
			DCONFIG2.DarkRPOriginalData[dataType] = table.Copy(fileInfo.data())
		end 
	end

end

hook.Add("DConfigPreDataLoaded", "PrepareHardcodedData", function()
	DCONFIG2.PrepareHardcodedData()
end)