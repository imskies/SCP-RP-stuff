-- local table `nets` with strings of network string names
local nets = {
	"dconfig2_saveEditor",
	"dconfig2_deleteContent",
	"dconfig2_resetContent",
	"dconfig2_createJob",
	"dconfig2_requestVaultData",
	"dconfig2_requestDefaultData",
	"dconfig2_open",
	"dconfig2_sendPopup",
	"dconfig2_sendText",
	"dconfig2_requestEntityModel",
}

-- loop through the elements of `nets` table
-- and call `util.AddNetworkString` with each value to add the network string
for k,v in ipairs(nets) do
	util.AddNetworkString(v)
end

net.Receive("dconfig2_requestVaultData", function(len, ply)
	if not DCONFIG2.CanDoTask(ply, "dconfig2_requestVaultData") then return end
	local category = net.ReadString()
	local id = net.ReadUInt(8)
	local data = DCONFIG2.Vault[category] and DCONFIG2.Vault[category][id] or nil
	if not data then return end

	-- local dataAddons = data.workshopid
	-- TODO: Complete implementation
end)

net.Receive("dconfig2_requestDefaultData", function(len, ply)
	local returnData = {}

	-- Iterate through Jobs
	for k,v in ipairs(RPExtraTeams) do
		-- Send appended values if available
		if v.inLuaFile and v.jobvar then
			returnData[k] = {}
			returnData[k].customCheckString = v.customCheckString
			returnData[k].jobvar = v.jobvar
		end
	end

	local data = util.Compress(util.TableToJSON(returnData))
	local length = data:len()
	
	net.Start("dconfig2_requestDefaultData")
	net.WriteUInt(length, 32)
	net.WriteData(data, length)
	net.Send(ply)
end)

net.Receive("dconfig2_deleteContent", function(len, ply)
	-- Checks for valid permissions
	if not DCONFIG2.CanDConfig(ply) then return end
	if not DCONFIG2.CanDoTask(ply, "dconfig2_deleteContent") then return end

	-- Read data sent from client.
	local editorType = net.ReadString()
	local length = net.ReadUInt(32)
	local compressedData = net.ReadData(length)
	-- Get the data that was saved by the player
	local contentData = util.JSONToTable(util.Decompress(compressedData))
	local networkSaveData = table.Copy(saveData)
	local deleteMethod = DCONFIG2.Editor.Deleting[editorType]
	-- If there is a delete method for what the client is trying to delete continue
	if deleteMethod then
		-- Get returned data from delete method 
		local data = deleteMethod(contentData)
		-- Send message according to success
		if not data.success then
			if data.msg then
				ply:ChatPrint("Error: " .. data.msg)
			else
				ply:ChatPrint("An internal error has occured. Please check your server's console.")
			end
		-- Send data to clients so they can delete the content on their end.
		elseif data.success then

			net.Start("dconfig2_deleteContent")
			net.WriteString(editorType)
			net.WriteUInt(length, 32)
			net.WriteData(compressedData, length)
			net.WriteEntity(ply)	
			net.Broadcast()

			--Show respective popup for deletion
			local saveSuccess, msg = DCONFIG2.SaveData(editorType)
			if not saveSuccess then
				DCONFIG2.ShowPopup(ply, msg, "dconfig/close.png", 5, true)
			else
				DCONFIG2.ShowPopup(ply, data.msg, data.icon, 5)
                hook.Run("DConfig2EditSuccess", ply, editorType, contentData)
			end
		end
	end
end)

-- Used for resetting hardcoded values in content
net.Receive("dconfig2_resetContent", function(len, ply)
	-- Checks for valid permissions
	if not DCONFIG2.CanDConfig(ply) then return end
	if not DCONFIG2.CanDoTask(ply, "dconfig2_resetContent") then return end

	-- Read data sent from client.
	local editorType = net.ReadString()
	local length = net.ReadUInt(32)
	local compressedData = net.ReadData(length)
	-- Get the data that was saved by the player
	local contentData = util.JSONToTable(util.Decompress(compressedData))
	local networkSaveData = table.Copy(saveData)
	local resetMethod = DCONFIG2.Editor.Resetting[editorType]
	-- If there is a reset method for what the client is trying to reset continue

	if resetMethod then
		-- Attempt to reset data
		local data = resetMethod(contentData)
		if not data.success then
			if data.msg then
				ply:ChatPrint("Error: " .. data.msg)
			else
				ply:ChatPrint("An internal error has occured. Please check your server's console.")
			end
		-- Send data to clients so they can delete the content on their end.
		elseif data.success then

			net.Start("dconfig2_resetContent")
			net.WriteString(editorType)
			net.WriteUInt(length, 32)
			net.WriteData(compressedData, length)
			net.WriteEntity(ply)		
			net.Broadcast()

			--Show respective popup for reset
			local saveSuccess, msg = DCONFIG2.SaveData(editorType)
			if not saveSuccess then
				DCONFIG2.ShowPopup(ply, msg, "dconfig/close.png", 5, true)
			else
				DCONFIG2.ShowPopup(ply, data.msg, data.icon, 5)
                hook.Run("DConfig2EditSuccess", ply, editorType, contentData)
			end
		end
	end
end)

-- This function is used to format hardcoded jobs from a file path
function DCONFIG2.FormatHardcodedJobs(filePath)

	-- Read the file and split it into lines
	local fileData = file.Read(filePath, "LUA")
	if not fileData then return end
	
	local fileLines = string.Explode("\n", fileData)
	-- Initialize the jobs table and lastIndex variable
	local jobs = {}
	local lastIndex
	-- Loop through each line in the file
	for lineNumber,lineText in pairs(fileLines) do
		-- Check if the line contains "DarkRP.createJob"
		if string.find(lineText, "DarkRP.createJob") then
			-- Format the line to remove spaces
			local formatted = string.Replace(lineText, " ", "")
			-- Find the end of the job variable
			local teamEnd = string.find(formatted, "=")
			-- Get the job variable from the line
			local jobvar = string.Left(formatted, teamEnd - 1)
			-- Check if the job exists in RPExtraTeams
			if RPExtraTeams[_G[jobvar]] then
				-- Get the index of the job in RPExtraTeams
				local index = _G[jobvar]
				-- Set the lastIndex to the current index
				lastIndex = index
				-- Set the jobvar and hardcoded properties in RPExtraTeams
				RPExtraTeams[index].jobvar = jobvar
				RPExtraTeams[index].inLuaFile = true
				RPExtraTeams[index].inLuaFile = true
			end
		end
		-- Check if the line contains "customCheck"
		if string.find(lineText, "customCheck") then
			-- Initialize the customCheckString
			local customCheckString = ""
			-- Set the start line number
			local startLine = lineNumber
			-- Initialize the end line number
			local endLine
			-- Loop through the remaining lines to find the end of the customCheck
			for i = lineNumber, table.Count(fileLines) do
				-- Concatenate the current line to the customCheckString
				customCheckString = customCheckString .. fileLines[i]
				-- Check if the line contains "end,"
				if string.find(fileLines[i], "end,") then
					-- Set the end line number
					endLine = i
					-- Break out of the loop
					break
				end
			end
			-- Check if the lastIndex is set
			if lastIndex then
				-- Format the customCheckString and set it in RPExtraTeams
				RPExtraTeams[lastIndex].customCheckString = DCONFIG2.FormatCustomCheck(customCheckString)
			end
		end
	end
end


-- net.Receive function to handle received data from the "dconfig2_saveEditor" channel
net.Receive("dconfig2_saveEditor", function(len, ply)
	-- Check if the player has permission to use the DConfig2 feature
	if not DCONFIG2.CanDConfig(ply) then return end
	if not DCONFIG2.CanDoTask(ply, "dconfig2_saveEditor") then return end

	-- Get the type of editor that the player is using
	local editorType = net.ReadString()
	local length = net.ReadUInt(32)
	local compressedData = net.ReadData(length)
	-- Get the data that was saved by the player
	local saveData = util.JSONToTable(util.Decompress(compressedData))
	local networkSaveData = table.Copy(saveData)
	-- Get the saving method for the type of editor
	local saveMethod = DCONFIG2.Editor.Saving[editorType]
	if saveMethod then
		saveData.updateTime = os.time()
		saveData.updateBy = ply:Name()
		saveData.updateByID = ply:SteamID()
		-- Call the saving method for the editor type to process the data
		local data = saveMethod(saveData)
		-- If the saving method returns an error, show a chat message to the player
		if not data.success then
			if data.msg then
				ply:ChatPrint("Error: " .. data.msg)
			else
				ply:ChatPrint("An internal error has occured. Please check your server's console.")
			end
		elseif data.success then
			-- If the saving method is successful, attempt to save the data
			local saveSuccess, msg = DCONFIG2.SaveData(editorType)
			if not saveSuccess then
				-- If saving the data fails, show an error popup to the player
				DCONFIG2.ShowPopup(ply, msg, "dconfig/close.png", 5, true)
			else
				-- If saving the data is successful, show a success popup to the player
				DCONFIG2.ShowPopup(ply, data.msg, data.icon, 5)

				-- Send the saved data to all other players
				net.Start("dconfig2_saveEditor")
				net.WriteString(editorType)
				net.WriteUInt(length, 32)
				net.WriteData(compressedData, length)
				net.WriteEntity(ply)
				net.Broadcast()
				-- Run the "DConfig2EditSuccess" hook
                hook.Run("DConfig2EditSuccess", ply, editorType, saveData)
			end
		end
	end

end)

local _P = FindMetaTable("Player")
function _P:SendDConfigNotice(str)
	DarkRP.notify(self, 3, 6, "[ DCONFIG 2 NOTICE ] " .. str)
end

hook.Add("PlayerSay", "DConfig2_Open", function( ply, text )
	if string.lower(text) == "!dconfig" then
		local canAccess = DCONFIG2.CanDConfig(ply)
		if canAccess then 
			net.Start("dconfig2_open")
			net.Send(ply)
			return ""
		else
			ply:ChatPrint("No Access! Please configure in sh_config.lua")
		end 
	end
end)

function DCONFIG2.ShowPopup(ply, msg, icon, seconds, isError)
	net.Start("dconfig2_sendPopup")
	net.WriteString(msg)
	net.WriteString(icon)
	net.WriteUInt(seconds, 8)
	net.WriteBool(isError or false)
	net.Send(ply)
end

function DCONFIG2.AddText(ply, msg)
	net.Start("dconfig2_sendText")
	net.WriteString(msg)
	net.Send(ply)
end 


local modelMap = {
	gmod_cameraprop = "models/dav0r/camera.mdl",
	darkrp_billboard = "models/props/cs_assault/billboard.mdl",
}

-- DCONFIG2.FindEntityModel function takes in a className as an argument
-- and returns the model string of the entity with that class name.
-- The function first checks if the model is in the modelMap table.
-- If not, it checks if the entity has a WorldModel property.
-- If not, it checks if the model is in the cache using DCONFIG2.GetModelFromCache.
-- If not, it checks if the entity has an initVars function.
-- If it does, it creates a fake entity and initializes it to retrieve the model string.
-- If not, it loops through the Initialize functions of the entity and uses jit.util to check if there is a model string or a SetModel function call.
-- If there is, it returns the model string.
-- If not, it returns nil.
function DCONFIG2.FindEntityModel(className)
	// print(className)
	local lookupModel = modelMap[className]
	if lookupModel then
		return lookupModel
	end 
	local entityData = scripted_ents.Get(className)
	if entityData.WorldModel then
		return entityData.WorldModel
	end 
	local modelStr = DCONFIG2.GetModelFromCache(className)

	-- If DarRKP ent that use initVars pull the model.
	if entityData.initVars then 
		local fakeEnt = {
			EntIndex = function() return 1 end,
		}
		entityData.initVars(fakeEnt)
		return fakeEnt.model
	end 
	
	if modelStr then
		return modelStr
	end

	for _, func in pairs({entityData.Initialize}) do
		if !func then continue end
		local info = jit.util.funcinfo(func)
		if info and !info.addr then
			local i = -1
			while -50 do -- let's not go futher than 50
				local const = jit.util.funck(func, i)
				local info = jit.util.funcinfo(func, i)
				if const == nil then
					break
				elseif type(const) == "string" and string.find(const, ".mdl") then
					return const 
				elseif const == "SetModel" then
					local modelStr = jit.util.funck(func, i - 1)
					return modelStr
				end
				i = i - 1
			end
		end
	end
	return nil
end

local function isValidModel(modelStr)
	if not modelStr then return false end

	return string.find(modelStr, ".mdl")
end 

local modelStrs = {}
net.Receive("dconfig2_requestEntityModel", function(len, ply)
	if not DCONFIG2.CanDConfig(ply) then return end

	local length = net.ReadUInt(32)
	local compressedData = net.ReadData(length)
	local classNames = util.JSONToTable(util.Decompress(compressedData))
	local response = {}
	for className, _ in pairs(classNames) do
		if modelStrs[className] then
			response[className] = modelStrs[className]
		else
			local modelStr = DCONFIG2.GetModelFromCache(className)
			if not modelStr then 
				modelStr = DCONFIG2.FindEntityModel(className)
				// print(string.find(className, "ammo"))
				modelStr = isValidModel(modelStr) and modelStr or string.find(className, "ammo") and "models/Items/BoxSRounds.mdl" or "models/maxofs2d/logo_gmod_b.mdl"
				DCONFIG2.WriteModelToCache(className, modelStr)
			end
			response[className] = modelStr
		end
	end
	local responseData = util.Compress(util.TableToJSON(response))
	local length = responseData:len()
	net.Start("dconfig2_requestEntityModel")
	net.WriteUInt(length, 32)
	net.WriteData(responseData, length)
	net.Send(ply)
end)
