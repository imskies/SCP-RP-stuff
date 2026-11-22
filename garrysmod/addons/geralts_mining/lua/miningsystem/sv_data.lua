
hook.Add("PlayerInitialSpawn", "LoadOreData", function(ply)
	local ore_path = "miningsystem/" .. ply:SteamID64() .. "_ores.txt"

	for k, v in pairs (MININGSYSTEM.Ores) do 
		if tonumber(ply:GetPData("CMS_"..v['Name'], 0)) <= 0 then 
			ply:SetNWInt("CMS_"..v['Name'], 0)
		else 
			ply:SetNWInt("CMS_"..v['Name'], tonumber(ply:GetPData("CMS_"..v['Name'], 0)))
		end 
		if !file.Exists(ore_path, "DATA") then 
			return
		else
			local ore_data = util.JSONToTable(file.Read(ore_path, "DATA"))
			ply:SetNWInt("CMS_"..v.Name, ore_data[v.Name])
			
			ply:RemovePData("CMS_"..v.Name)
		end 		
	end 
	if ply:GetNWInt("CMS_MiningLevel") == 0 then 
		ply:SetNWInt("CMS_MiningLevel", 1)
	else 
		ply:SetNWInt("CMS_MiningLevel", tonumber(ply:GetPData("CMS_MiningLevel", 1)))
	end 
	ply:SetNWInt("CMS_LevelProgress", tonumber(ply:GetPData("CMS_LevelProgress", 0)))
	
	local level_path = "miningsystem/" .. ply:SteamID64() .. "_level.txt"
	
	if !file.Exists(level_path, "DATA") then 
		return
	else
		local level_data = util.JSONToTable(file.Read(level_path, "DATA"))
		ply:SetNWInt("CMS_LevelProgress", level_data["Progress"])
		ply:SetNWInt("CMS_MiningLevel", level_data["Level"])
		
		ply:RemovePData("CMS_LevelProgress")
		ply:RemovePData("CMS_MiningLevel")
	end 
end)

local function save_txt_data(ply)
	file.CreateDir("miningsystem")
	local tab = {}
	for k, v in pairs (MININGSYSTEM.Ores) do 
		tab[k] = ply:GetNWInt("CMS_"..v.Name)
	end 
	-- PrintTable(tab)
	tab = util.TableToJSON(tab)
	
	local level = {}
	level["Level"] = ply:GetNWInt("CMS_MiningLevel")
	level["Progress"] = ply:GetNWInt("CMS_LevelProgress")
	level = util.TableToJSON(level)
	file.Write("miningsystem/" .. ply:SteamID64() .. "_ores.txt", tab)
	file.Write("miningsystem/" .. ply:SteamID64() .. "_level.txt", level)
end 

hook.Add("PlayerDisconnected", "StoreOreData", function(ply)
	save_txt_data(ply)
end)

hook.Add("Initialize", "DataSavingTimer", function(ply)
	if !MININGSYSTEM.SaveDataTimer then return end 
	
	timer.Create("CMS_SaveData", MININGSYSTEM.SaveDataTimer, 0, function()
		for k, v in pairs(player.GetAll()) do 
			save_txt_data(v)
		end 
	end)
end)
