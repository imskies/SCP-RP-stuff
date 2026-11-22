-- local table `nets` with strings of network string names
local nets = {
    "dconfig2_requestBackups",
    "dconfig2_createBackup",
    "dconfig2_importDConfig",
    "dconfig2_requestData",
    "dconfig2_deleteSaveData",
    "dconfig2_restoreSaveData",
    "dconfig2_viewSaveData",
    "dconfig2_sendRestart",
    "dconfig2_syncDoorgroups",
    "dconfig2_downloadVault",
}

-- loop through the elements of `nets` table
-- and call `util.AddNetworkString` with each value to add the network string
for k,v in ipairs(nets) do
    util.AddNetworkString(v)
end 

-- function to prepare data for saving
function DCONFIG2.PrepareData()
	-- create the main data directory path
	local mainPath = DCONFIG2.Data.SaveDir
	-- if the main directory does not exist, create it
	if not file.Exists(mainPath, "DATA") then
		file.CreateDir(mainPath)
	end
	-- loop through the sub folders of the main directory
	for dir,active in pairs(DCONFIG2.Data.SubFolders) do
		dir = mainPath .. "/" .. dir
		-- if the sub folder does not exist, create it
		if not file.Exists(dir, "DATA") then
			file.CreateDir(dir)
		end
	end
	-- get the existing backups
	DCONFIG2.GetBackups()
end

-- function to get existing backups in the `saves` subfolder
function DCONFIG2.GetBackups()
	-- initialize the `Backups` field of the `Data` table
	DCONFIG2.Data.Backups = {}
	-- create the `saves` directory path
	local savesDir = DCONFIG2.Data.SaveDir .. "/saves/"
	-- get the files and directories in the `saves` folder
	local files, dirs = file.Find(savesDir .. "*", "DATA")
	-- loop through the directories
	for k,v in pairs(dirs) do
		-- if the directory name is "active", skip it
		if v == "active" then continue end
		-- add the directory name as a key to the `Backups` table with value `true`
		DCONFIG2.Data.Backups[v] = true
	end
end

-- function to save data of the specified type
function DCONFIG2.SaveData(dataType)
	-- get the data information for the specified type
	local fileInfo = DCONFIG2.Data.FileManager[dataType]
	-- variable to store error message
	local msg
	-- if the data information does not exist, return an error
	if not fileInfo then
		msg = "An Internal Saving Error has occured. Please create a support ticket. Save Key: " .. dataType
		DCONFIG2.MsgC(msg, true)
		return false, msg
	end

	local dataToSave = {}
	local shouldSaveEntry = fileInfo.shouldSaveEntry
	if shouldSaveEntry then
		local data = table.Copy(fileInfo.data())
		for k,v in pairs(data) do
			if shouldSaveEntry(v) then
				-- Remove unused hardcoded flag
				v.hardcoded = nil
				-- Wipe indication that it's in a luaFile as we only want this to be available if it's found in a file still.
				v.inLuaFile = nil
				table.insert(dataToSave, v)
			else
				print("SKIPPING SAVE FOR: ")
				PrintTable(v)
				continue
			end 
		end
	else
		dataToSave = fileInfo.data()
	end
	-- PrintTable(dataToSave)
	-- create the save directory path for the specified type
	local saveDir = not fileInfo.path and DCONFIG2.Data.SaveDir .. "/saves/active/" .. dataType .. ".txt" or fileInfo.path
	file.Write(saveDir, util.TableToJSON(dataToSave, true))
	return true
end

-- DCONFIG2.LoadData(dataType) loads the data from a specified file.
function DCONFIG2.LoadData(dataType)
	-- The path of the file is obtained from the `fileInfo` table, which is accessed using `dataType` as the key.
	local fileInfo = DCONFIG2.Data.FileManager[dataType]
	-- If `fileInfo` is not found, an error message is displayed and the function returns.
	if not fileInfo then
		DCONFIG2.MsgC("An Internal Loading Error has occured. Please create a support ticket. Load Key: " .. dataType, true)
		return
	end 
	
	local saveDir = not fileInfo.path and DCONFIG2.Data.SaveDir .. "/saves/active/" .. dataType .. ".txt" or fileInfo.path
	-- The contents of the file are read and stored in `storedData`.
	local storedData = file.Read(saveDir, "DATA")
	if not storedData then return end
	storedData = util.JSONToTable(storedData)
	
	-- If `fileInfo.loadEntry` is not nil, each data entry in `storedData` is passed to `fileInfo.loadEntry` for processing. 
	if fileInfo.loadEntry then 
		for k,dataEntry in pairs(storedData) do
			if dataType == "jobs" then 
				dataEntry.teamKey = nil
			end
			if dataType == "ammo" or dataType == "entities" then
				dataEntry.id = nil
			end 
			if fileInfo.shouldLoadEntry then
				local shouldLoad, failMsg = fileInfo.shouldLoadEntry(dataEntry)
				if not shouldLoad then 
					DCONFIG2.MsgC("Skipping loading of a data entry: " .. DCONFIG2.GetEntryName(dataEntry) .. " | Reason: " .. (failMsg or "Not Provided."))
					continue
				end
			end
			fileInfo.loadEntry(dataEntry, true)
			hook.Run("DConfig2PostLoadDataEntry", dataType, dataEntry)
		end
		-- If `fileInfo.loadBulk` is not nil, `storedData` is passed to `fileInfo.loadBulk` for processing.
	elseif fileInfo.loadBulk then
		fileInfo.loadBulk(storedData)
	end
	-- The hook `DConfig2PostLoadDataType` is then run with `dataType` as a parameter.
	hook.Run("DConfig2PostLoadDataType", dataType)
	-- Finally, the data is sent to the network with the message `sendDConfig2Data`.
	bignet.send("sendDConfig2Data", {dataType = dataType, data = storedData})
end

-- DCONFIG2.LoadStats() loads statistics-related data.
function DCONFIG2.LoadStats()
    DCONFIG2.LoadData("stats_jobs")
    DCONFIG2.LoadData("stats_shipments")
    DCONFIG2.LoadData("stats_weapons")
    DCONFIG2.LoadData("stats_entities")
    DCONFIG2.LoadData("stats_ammo")
end

-- DCONFIG2.LoadDarkRPData() loads data for DarkRP.

function DCONFIG2.LoadDarkRPData()
    DCONFIG2.LoadData("settings")
    DCONFIG2.LoadData("categories")
    DCONFIG2.LoadData("jobs")
    DCONFIG2.LoadData("shipments")
    DCONFIG2.LoadData("entities")
    DCONFIG2.LoadData("ammo")
	if DCONFIG2.IngameConfig.load_doorgroups then 
    	DCONFIG2.LoadData("doorgroups")
		DCONFIG2.MsgC("SKIPPING DOOR GROUP DATA LOAD. ENABLE IN DCONFIG SETTINGS 'Load DConfig Doorgroups'", true)
	end
end

-- findFiles is a table that lists the files to be backed up.
local findFiles = {
	["/jobs.txt"] = true,
	["/entities.txt"] = true,
	["/shipments.txt"] = true,
	["/ammo.txt"] = true,
	["/doorgroups.txt"] = true,
	["/categories.txt"] = true,
	["/settings.txt"] = true,
	["/vault.txt"] = true,
}

-- DCONFIG2.CreateDataBackup(refresh, title) creates a backup of the data.
function DCONFIG2.CreateDataBackup(refresh, title)
	-- The backup title is obtained using `DCONFIG2.GetDefaultBackupTitle` and is modified using `title` if provided.
	local backupTitle = DCONFIG2.GetDefaultBackupTitle()
	backupTitle = title and title .. " " .. backupTitle or backupTitle
	-- The backup title is then formatted using `DCONFIG2.FormatDirectory`.
	backupTitle = DCONFIG2.FormatDirectory(backupTitle)
	DCONFIG2.Data.Backups[backupTitle] = true
	local newDir = DCONFIG2.Data.SaveDir .. "/saves/" .. backupTitle
	-- A new directory with the backup title is created if it doesn't exist.
	if not file.Exists(newDir, "DATA") then
		file.CreateDir(newDir)
        local activeDir = DCONFIG2.Data.SaveDir .. "/saves/active" 
		-- The files listed in `findFiles` are read from the active directory and written to the new backup directory.
        for k,v in pairs(findFiles) do
            if not file.Exists(activeDir .. k, "DATA") then continue end
			
			local data = file.Read(activeDir .. k, "DATA")
			file.Write(newDir .. k, data)            
        end 
		DCONFIG2.MsgC("Creating new backup for data: " .. newDir)
	end
	-- The backups are then refreshed by calling `DCONFIG2.RefreshBackups(refresh)`.
    DCONFIG2.RefreshBackups(refresh)
	-- The function returns `true` and the path of the new directory.
	return true, newDir
end

-- DCONFIG2.ImportOldData() imports data from an old directory `oldDir`.
function DCONFIG2.ImportOldData()
	local oldDir = "darkrpmasterconfig"
	local newDir = DCONFIG2.Data.SaveDir .. "/saves/dconfig1"
	local successFiles = {}
	if not DCONFIG2.HasOldData() then
		return false
	else
		if not file.Exists(newDir, "DATA") then
			file.CreateDir(newDir)
		end
		local count = 0
		-- The files listed in `findFiles` are read from `oldDir` and written to `newDir`.
		for k,v in pairs(findFiles) do
			-- A new directory `newDir` is created if it doesn't exist.
			if not file.Exists(oldDir .. k, "DATA") then continue end
			count = count + 1
			local data = file.Read(oldDir .. k, "DATA")
			file.Write(newDir .. k, data)
			successFiles[k] = true
		end
		local successStr = "Sucessfully imported old data from inside of " .. oldDir .. ":"
		for fileName,v in pairs(successFiles) do
			successStr = successStr .. " " .. fileName
		end
		if count == 0 then
			return false, "The data folder " .. oldDir .. " does not contain any data!"
		end
		DCONFIG2.GetBackups()
		return true, successStr
	end
	-- The function returns `false` if the old data is not found, or a list of the successfully imported files otherwise.
	return false
end

-- DCONFIG2.HasOldData()
-- This function checks if an old data directory exists in the "darkrpmasterconfig" directory.
-- If it exists, it returns true, otherwise it returns false.
function DCONFIG2.HasOldData()
	-- local variable to store the old directory name
	local oldDir = "darkrpmasterconfig"
	-- return the result of checking if the old directory exists
	return file.Exists(oldDir, "DATA")
end

-- DCONFIG2.ReadSave(saveDir)
-- This function reads data from a specified save directory and converts it into a table format.
-- If the save directory does not exist, it will display a message and return nil.
-- Otherwise, it will return a table of data.
function DCONFIG2.ReadSave(saveDir)
	-- Check if the save directory exists
    if not file.Exists(saveDir, "DATA") then
		-- Display a message if the save directory does not exist
        DCONFIG2.MsgC("No save data found for " .. saveDir, true)
		-- Return nil if the save directory does not exist
        return
    end 
	-- Create a local variable to store the save data as a table
    local saveData = {}
	-- Loop through the files in the save directory
	for k,v in pairs(findFiles) do
		-- Check if the current file exists
		-- Skip to the next iteration if the file does not exist
        if not file.Exists(saveDir .. k, "DATA") then continue end

		-- Read the data from the current file
        local data = file.Read(saveDir .. k, "DATA")
		-- Skip to the next iteration if there is no data
        if not data then continue end
        
		-- Clean up the key name
        local key = string.Replace(k, ".txt", "")
        key = string.Replace(key, "/", "")
		-- Assign the cleaned up key name to the value in the saveData table
        saveData[key] = util.JSONToTable(data)
    end
	-- Return the save data table
    return saveData
end

-- DCONFIG2.RefreshBackups(refresh)
-- This function refreshes the backup data for all connected players.
-- If the refresh parameter is passed in as true, it will force a refresh.
function DCONFIG2.RefreshBackups(refresh)
	-- Get the latest backup data
	DCONFIG2.GetBackups()
	local data = util.Compress(util.TableToJSON(DCONFIG2.Data.Backups))
	local length = data:len()
	-- Loop through all connected players
	for k,v in ipairs(player.GetAll()) do
		-- Check if the current player is allowed to access the configuration
		-- Skip to the next iteration if the player is not allowed to access the configuration
		if not DCONFIG2.CanDConfig(v) then continue end

		-- Start a network message to request backup data
		-- Write the backup data to the network message
		-- Write the refresh parameter to the network message

		net.Start("dconfig2_requestBackups")
		net.WriteUInt(length, 32)
		net.WriteData(data, length)
		net.WriteBool(refresh or false)
		net.Send(v)
	end
end

-- DCONFIG2.DeleteSave function
function DCONFIG2.DeleteSave(saveDir)
	-- This function deletes the specified `saveDir` by checking if the file exists in the "DATA" directory.
    if not file.Exists(saveDir, "DATA") then
		-- If the file does not exist, it will print a message indicating the file was not found and return `false`.
        DCONFIG2.MsgC("Unable to delete save " .. saveDir .. ". File not found.", true)
        return false
    end
	
	-- Otherwise, it will loop through all `findFiles`, delete each individual file, and then delete the `saveDir` directory.
	for k,v in pairs(findFiles) do
        local targetFile = saveDir .. k
        if not file.Exists(targetFile, "DATA") then continue end
		
        file.Delete(targetFile)
        DCONFIG2.MsgC("Deleted data from " .. targetFile)
    end 
    file.Delete(saveDir)
    DCONFIG2.MsgC("Successfully deleted save directory: " .. saveDir)
	-- Finally, it will run the `DCONFIG2.RefreshBackups` function and return `true` indicating success.
    DCONFIG2.RefreshBackups(true)
    return true
end 

function DCONFIG2.RestartServer(ply)
	net.Start("dconfig2_sendRestart")
	net.WriteUInt(CurTime() + 11, 32)
	net.WriteEntity(ply)
	net.Broadcast()
	timer.Create("dconfig2_restore_restart", 10, 1, function()
		RunConsoleCommand("changelevel", game.GetMap())
	end)
end

-- DCONFIG2.RestoreSave function
function DCONFIG2.RestoreSave(saveDir)
	-- This function restores the specified `saveDir` by checking if the file exists in the "DATA" directory.
    if not file.Exists(saveDir, "DATA") then
		-- If the file does not exist, it will print a message indicating the file was not found and return `false`.
        DCONFIG2.MsgC("Unable to restore save " .. saveDir .. ". File not found.", true)
        return false
    end
	
    local activeDir = DCONFIG2.Data.SaveDir .. "/saves/active"
	-- Otherwise, it will delete the current "active" save directory, create a new "active" save directory,
    DCONFIG2.DeleteSave(activeDir)
    file.CreateDir(activeDir, "DATA")
	-- loop through all `findFiles`, write each file to the "active" save directory, and print a message indicating success.
	for k,v in pairs(findFiles) do
        local targetFile = saveDir .. k
        if not file.Exists(targetFile, "DATA") then continue end

        file.Write(activeDir .. k, file.Read(targetFile, "DATA"), "DATA")

        DCONFIG2.MsgC("Restored data from " .. targetFile)
    end 
    DCONFIG2.MsgC("Successfully restored save directory: " .. saveDir)
    return true
end 

-- net.Receive("dconfig2_viewSaveData") function
-- This function receives network data from the client and checks if the player has permission to use the "dconfig2_viewSaveData" task.
-- If the player has permission, it will read the specified `saveDir`, send the save data to the client, and return.
net.Receive("dconfig2_viewSaveData", function(len, ply)
    if not DCONFIG2.CanDConfig(ply) then return end
	if not DCONFIG2.CanDoTask(ply, "dconfig2_viewSaveData") then return end

    local directory = net.ReadString()
    local saveDir = DCONFIG2.Data.SaveDir .. "/saves/" .. directory
    bignet.send("sendDConfig2SaveData", DCONFIG2.ReadSave(saveDir), ply)
end)

-- net.Receive("dconfig2_deleteSaveData") function
-- This function receives network data from the client and checks if the player has permission to use the "dconfig2_deleteSaveData" task.
-- If the player has permission, it will delete the specified `saveDir` and run the "DConfig2BackupDeleted" hook if successful.
-- It will also send a message to all players with `DCONFIG2.CanDConfig` permission.
net.Receive("dconfig2_deleteSaveData", function(len, ply)
    if not DCONFIG2.CanDConfig(ply) then return end
	if not DCONFIG2.CanDoTask(ply, "dconfig2_deleteSaveData") then return end

    local directory = net.ReadString()
    local saveDir = DCONFIG2.Data.SaveDir .. "/saves/" .. directory
    local success = DCONFIG2.DeleteSave(saveDir)
    if success then 
        for k,v in ipairs(player.GetAll()) do
            if not DCONFIG2.CanDConfig(v) then continue end
            DCONFIG2.ShowPopup(v, ply:Name() .. " successfully deleted data from " .. saveDir, "dconfig/data.png", 5)
        end
        hook.Run("DConfig2BackupDeleted", ply, saveDir)
		-- Restart server if the active DConfig Data is being deleted.
		if directory == "active" then
			DCONFIG2.PrepareData()
			DCONFIG2.RestartServer(ply)
		end
	else
		DCONFIG2.ShowPopup(ply, "Failed to delete the save data inside " .. saveDir, "dconfig/close.png", 5, true)
    end
end)

-- dconfig2_restoreSaveData 
net.Receive("dconfig2_restoreSaveData", function(len, ply)
	-- This function handles the restoring of saved data on the server, triggered by a player with the proper permissions. 
	-- It first checks if the player has the necessary permissions to do so and returns if not. 
    if not DCONFIG2.CanDConfig(ply) then return end
	if not DCONFIG2.CanDoTask(ply, "dconfig2_restoreSaveData") then return end
	
	-- Then it reads the directory from the network message and combines it with the save directory path to get the save directory. 
    local directory = net.ReadString()
    local saveDir = DCONFIG2.Data.SaveDir .. "/saves/" .. directory
    local success = DCONFIG2.RestoreSave(saveDir)
	-- If the restore operation is successful, a message is broadcasted to all players and a timer is created to restart the server. 
    if success then
        for k,v in ipairs(player.GetAll()) do
            DCONFIG2.AddText(v, ply:Name() .. " has initiated a server restart. Restarting in 10 seconds.")
            if not DCONFIG2.CanDConfig(v) then continue end
            DCONFIG2.ShowPopup(v, "RESTARTING - " .. ply:Name() .. " successfully restored data from " .. saveDir, "dconfig/data.png", 5)
        end
        DCONFIG2.RestartServer(ply)
		-- Finally, it runs a hook to notify other addons of the successful restore.
        hook.Run("DConfig2BackupRestored", ply, saveDir)
    end
end)

-- dconfig2_requestBackups 
-- This function handles the request for backup information from a player with proper permissions. 
-- It first checks if the player has the necessary permissions and returns if not. 
-- Then it starts a network message with the name "dconfig2_requestBackups" and writes the backup information to the network. 
-- Finally, it sends the message to the requesting player.
net.Receive("dconfig2_requestBackups", function(len, ply)
	if not DCONFIG2.CanDConfig(ply) then return end
	if not DCONFIG2.CanDoTask(ply, "dconfig2_requestBackups") then return end

	local data = util.Compress(util.TableToJSON(DCONFIG2.Data.Backups))
	local length = data:len()
	net.Start("dconfig2_requestBackups")
	net.WriteUInt(length, 32)
	net.WriteData(data, length)
	net.Send(ply)
end)

-- dconfig2_createBackup 
-- This function handles the creation of a new backup, triggered by a player with proper permissions. 
-- It first checks if the player has the necessary permissions and returns if not. 
-- Then it reads the backup title from the network message and creates a new backup with it. 
-- If the backup is successfully created, a popup notification is shown to the player
net.Receive("dconfig2_createBackup", function(len, ply)
	if not DCONFIG2.CanDConfig(ply) then return end
	if not DCONFIG2.CanDoTask(ply, "dconfig2_createBackup") then return end

    local title = net.ReadString()
	local success, dir = DCONFIG2.CreateDataBackup(true, title)
    if success then 
	    DCONFIG2.ShowPopup(ply, "Successfully created new backup: " .. dir, "dconfig/data.png", 5)
        hook.Run("DConfig2BackupCreated", ply, dir)
    end
end)

-- dconfig2_importDConfig 
-- This function handles the importing of data from an old version of DConfig. 
net.Receive("dconfig2_importDConfig", function(len, ply)
	-- It first checks if the player has the necessary permissions and returns if not. 
	if not DCONFIG2.CanDConfig(ply) then return end
	if not DCONFIG2.CanDoTask(ply, "dconfig2_importDConfig") then return end
	
	-- Then it imports the old data and starts a network message with the name "dconfig2_requestBackups" to update the backup information. 
	local success, msg = DCONFIG2.ImportOldData()
	if success then
		-- If the import is successful, a popup notification is shown to the player. 
		local data = util.Compress(util.TableToJSON(DCONFIG2.Data.Backups))
		local length = data:len()
		net.Start("dconfig2_requestBackups")
		net.WriteUInt(length, 32)
		net.WriteData(data, length)
		net.WriteBool(true)
		net.Send(ply)
		DCONFIG2.ShowPopup(ply, msg, "dconfig/data.png", 5)
	else
		-- If the import fails, an error message is shown in a popup notification.
		msg = msg or "Unable to find DConfig 1 Data. Please double check data/darkrpmasterconfig exists!"
		DCONFIG2.ShowPopup(ply, msg, "dconfig/close.png", 5, true)
	end
end)

-- dconfig2_requestData 
-- This function handles the request for data from a player. 
net.Receive("dconfig2_requestData", function(len, ply)
	-- It first checks if the player has the necessary permissions and returns if not. 
	if not DCONFIG2.CanDoTask(ply, "dconfig2_requestData", 600) then return end
	
	local data = {}
	for dataType,fileInfo in pairs(DCONFIG2.Data.FileManager) do 
		data[dataType] = fileInfo.data()
	end 
	-- Then it retrieves the data from the file manager and sends it to the player through a network message with the name "sendDConfig2FullData".
	bignet.send("sendDConfig2FullData", data, ply)
end)

-- dconfig2_downloadVault 
-- This function handles the downloading of data from the vault, triggered by a player with proper permissions. 
-- It first checks if the player has the necessary permissions and returns if not. 
-- Then it reads the ignore list, category, and data ID from the network message and downloads the data from the vault. 
-- Finally, it starts a network message with the name "dconfig2_downloadVault" and writes the ignore list, category, and data ID to the network.
net.Receive("dconfig2_downloadVault", function(len, ply)
	if not DCONFIG2.CanDConfig(ply) then return end
	if not DCONFIG2.CanDoTask(ply, "dconfig2_downloadVault") then return end
	-- TODO: Complete implementation
/*

	local ignoreTbl = net.ReadTable()
	local category = net.ReadString()
	local dataID = net.ReadUInt(8)
	DCONFIG2.DownloadVaultFromNetwork(ignoreTbl, category, dataID)
	local plys = {}
	for k,v in ipairs(player.GetAll()) do
		if ply == v then continue end
		table.insert(plys, v)
	end
	net.Start("dconfig2_downloadVault")
	net.WriteTable(ignoreTbl)
	net.WriteString(category)
	net.WriteUInt(dataID, 8)
	net.Send(plys)
*/

end)


-- Prepares DConfig 2 Data
hook.Add("InitPostEntity", "DCONFIG2_PrepareData", function()
	DCONFIG2.PrepareData()
end)

local synced = {}
net.Receive("dconfig2_syncDoorgroups", function(len, ply)
    if synced[ply] then return end
    ply:sendDoorData()
end)

-- Developer useage for new feature
concommand.Add("dconfig2_loadVault", function(ply)
	if DCONFIG2.IsDan(ply) then
		DCONFIG2.LoadData("vault")
	end 
end)
