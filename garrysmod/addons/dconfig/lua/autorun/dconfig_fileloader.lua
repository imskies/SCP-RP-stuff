DCONFIG2 = DCONFIG2 or {}
DCONFIG2.Config = DCONFIG2.Config or {}

local ignoreFiles = {}
local handledFiles = {}

function DCONFIG2.MsgC(msg, isError)
	MsgC(not isError and Color(0, 255, 0) or Color(255, 0, 0), "[DCONFIG 2] " .. msg .. "\n")
end

function DCONFIG2.LoadAllFiles(fileDir)
	local files, dirs = file.Find(fileDir .. "*", "LUA")

	for _, subFilePath in ipairs(files) do
		if (string.match(subFilePath, ".lua") and not ignoreFiles[subFilePath] and not handledFiles[fileDir .. subFilePath]) then

			local fileRealm = string.sub(subFilePath, 1, 2)
			if SERVER and fileRealm != "sv" then
				DCONFIG2.MsgC("Adding CSLuaFile File " .. fileDir .. subFilePath)
				handledFiles[fileDir .. subFilePath] = true
				AddCSLuaFile(fileDir .. subFilePath)
			end

			if CLIENT and fileRealm != "sv" then
				include(fileDir .. subFilePath)
				handledFiles[fileDir .. subFilePath] = true
				DCONFIG2.MsgC("Including File " .. fileDir .. subFilePath)
			elseif SERVER and fileRealm != "cl" then
				include(fileDir .. subFilePath)
				handledFiles[fileDir .. subFilePath] = true
				DCONFIG2.MsgC("Including File " .. fileDir .. subFilePath)
			end
		end
	end

	for _, dir in ipairs(dirs) do
		DCONFIG2.LoadAllFiles(fileDir .. dir .. "/")
	end
end

DCONFIG2.LoadAllFiles("dconfig/sh/")
DCONFIG2.LoadAllFiles("dconfig/")
//DCONFIG2.LoadAllFiles("darkrp_modules/")
