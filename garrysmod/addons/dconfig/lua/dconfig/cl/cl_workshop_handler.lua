
local saveDir = "dconfig2/workshop/"
file.CreateDir(saveDir)

function DCONFIG2.DownloadWorkshopAddon(id)
	DCONFIG2.MsgC("Downloading Workshop Content For " .. id)
	steamworks.DownloadUGC(id, function(name, fileData)
		local success, files = game.MountGMA(name)
		print("FILES:")
		//PrintTable(files)
		if success then
			DCONFIG2.MsgC("Sucessfully Mounted Workshop Content " .. id)
		else
			DCONFIG2.MsgC("FAILED TO MOUNT WORKSHOP CONTENT " .. id)
		end
	end)
end

--DCONFIG2.DownloadWorkshopAddon("1359524327")

function DCONFIG2.PreviewWorkshopContent(idTbl, callback)

	// TODO: Finish implementation
	for _,id in pairs(idTbl) do
		DCONFIG2.DownloadWorkshopAddon(id)
	end
	timer.Simple(2, function()
		callback()
	end)
end

local function GetWorkshopContent(id)
	steamworks.DownloadUGC(id, function(name, fileData)
		local success, files = game.MountGMA(name)
		if success then
			print("Sucessfully Mounted Workshop Content " .. id)
		else
			print("FAILED TO MOUNT WORKSHOP CONTENT " .. id)
		end
	end)
end

function DCONFIG2.HasMaterialError(materials)
	// TODO: Finish implementation
	for k,v in pairs(materials) do
		if v == "models/error/new light1" then
			return true
		end
	end
	return false
end
