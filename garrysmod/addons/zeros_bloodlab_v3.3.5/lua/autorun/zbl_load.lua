/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

local DebugPrint = false

local function NicePrint(txt)
	if DebugPrint == false then return end

	if SERVER then
		MsgC(Color(84, 150, 197), txt .. "\n")
	else
		MsgC(Color(193, 193, 98), txt .. "\n")
	end
end

local function PreLoadFile(path)
	if CLIENT then
		include(path)
	else
		AddCSLuaFile(path)
		include(path)
	end
end

local function LoadFiles(path)
	local files, _ = file.Find(path .. "/*", "LUA")

	for _, v in ipairs(files) do
		if string.sub(v, 1, 3) == "sh_" then
			if CLIENT then
				include(path .. "/" .. v)
			else
				AddCSLuaFile(path .. "/" .. v)
				include(path .. "/" .. v)
			end
			NicePrint("// Loaded " .. v .. string.rep(" ", 38 - v:len()) .. " //")
		end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

	for _, v in ipairs(files) do
		if string.sub(v, 1, 3) == "cl_" then
			if CLIENT then
				include(path .. "/" .. v)
				NicePrint("// Loaded " .. v .. string.rep(" ", 38 - v:len()) .. " //")
			else
				AddCSLuaFile(path .. "/" .. v)
			end
		elseif string.sub(v, 1, 3) == "sv_" then
			include(path .. "/" .. v)
			NicePrint("// Loaded " .. v .. string.rep(" ", 38 - v:len()) .. " //")
		end
	end
end



local function Initialize()
	NicePrint(" ")
	NicePrint("///////////////////////////////////////////////////")
	NicePrint("//////////////// Zero´s GenLab ////////////////////")
	NicePrint("///////////////////////////////////////////////////")
	NicePrint("//                                               //")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

	PreLoadFile("zblood/util/sh_materials.lua")
	PreLoadFile("zblood/quest/sh_quest.lua")

	PreLoadFile("sh_zbl_config_vaccines.lua")
	PreLoadFile("sh_zbl_config_main.lua")
	PreLoadFile("sh_zbl_config_effects.lua")
	PreLoadFile("sh_zbl_config_models.lua")
	PreLoadFile("sh_zbl_hooks.lua")

	LoadFiles("zbl_languages")

	PreLoadFile("sh_zbl_config_quests.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

	LoadFiles("zblood/virus")
	LoadFiles("zblood/util")
	LoadFiles("zblood/util/player")
	LoadFiles("zblood/antiinfection")

	LoadFiles("zblood/fence")
	LoadFiles("zblood/flask")
	LoadFiles("zblood/gasmask")
	LoadFiles("zblood/hotspot")
	LoadFiles("zblood/injector")
	LoadFiles("zblood/dna")
	LoadFiles("zblood/lab")
	LoadFiles("zblood/npc")
	LoadFiles("zblood/quest")
	LoadFiles("zblood/sign")
	LoadFiles("zblood/spray")
	LoadFiles("zblood/medicalunit")

	LoadFiles("zbl_modules")

	NicePrint("//                                               //")
	NicePrint("///////////////////////////////////////////////////")
	NicePrint("///////////////////////////////////////////////////")

	if DebugPrint == false then
		if SERVER then
			MsgC(Color(84, 150, 197), "Zeros GenLab - Loaded\n")
		else
			MsgC(Color(193, 193, 98), "Zeros GenLab - Loaded\n")
		end
	end
end

PreLoadFile("zblood/util/cl_settings.lua")

timer.Simple(0,function()

	// If zeros libary is not installed on the server then lets tell them
	if zclib == nil then
		local function Warning(ply, msg)
			if DarkRP and DarkRP.notify then
				DarkRP.notify(ply, 1, 8, msg)
			else
				ply:ChatPrint(msg)
			end
		end

		MsgC(Color(255, 0, 0), "[Zero´s GenLab] > Zeros Lua Libary not found!")
		MsgC(Color(255, 0, 0), "https://steamcommunity.com/sharedfiles/filedetails/?id=2532060111")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

		if CLIENT then
			surface.PlaySound( "common/warning.wav" )
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

		if SERVER then
			for k,v in ipairs(player.GetAll()) do
				if IsValid(v) then
					Warning(v, "[Zero´s GenLab] > Zeros Lua Libary not found!")
					Warning(v, "https://steamcommunity.com/sharedfiles/filedetails/?id=2532060111")
				end
			end
		end
		return
	end

	Initialize()
end)
