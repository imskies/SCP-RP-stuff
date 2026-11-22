if !SERVER then return end 

util.AddNetworkString("OreBuyingSelling")
util.AddNetworkString("CreateOre")
util.AddNetworkString("OreMenu")
util.AddNetworkString("CraftItem")
util.AddNetworkString("SetPlayerSuit")
util.AddNetworkString("RefiningStationMenu")
util.AddNetworkString("OpenMinerMenu")
util.AddNetworkString("OpenCraftingMenu")
util.AddNetworkString("DropOre")

net.Receive("SetPlayerSuit", function(len, ply)
	local Language = MINING_Language[MININGSYSTEM.CurrentLanguage]
	
	if ply:getDarkRPVar("money") < MININGSYSTEM.RadioactiveSuitPrice then return DarkRP.notify(player, 1, 5, Language.NotEnoughMoneyFailMsg) end 
	
	ply:addMoney(-MININGSYSTEM.RadioactiveSuitPrice)
	
	if ply:GetModel() == MININGSYSTEM.SuitModel then return DarkRP.notify(ply, 1, 5, Language.BuySuitFailMsg) end
	
	local PlayerID = player.GetBySteamID64( net.ReadString() )
	
	PreviousModel = PlayerID:GetModel()
	
	PlayerID:SetModel(MININGSYSTEM.SuitModel)
	
	timer.Simple(MININGSYSTEM.RadioactiveSuitTime, function()
		if !PlayerID:IsValid() then return end 
		
		PlayerID:SetModel(PreviousModel)
	end)
end)

net.Receive("OreBuyingSelling", function(len, ply)
	local Language = MINING_Language[MININGSYSTEM.CurrentLanguage]
	local BuyOrSell = net.ReadBool()
	local OreName = net.ReadString()
	local OreCount = tonumber(net.ReadString())
	local HowMuch = tonumber(net.ReadString())
	local FindNPC = ents.FindInSphere( ply:GetPos(), 250 )
	local found = nil 

	for k,v in pairs(FindNPC) do 
		if v:GetClass() == "cms_miner_npc" then 
			found = true
			break
		end 
	end 

	if found == nil then return end 
	if OreCount < 0 then return end 
	
	local getname = string.Replace( OreName, "CMS_", "" )
	local actualprice = MININGSYSTEM.Ores[getname].Price * OreCount
	if BuyOrSell then 
		if (HowMuch < actualprice * MININGSYSTEM.BuyPriceMultiplier) or (HowMuch > actualprice * MININGSYSTEM.BuyPriceMultiplier) then return end 
		if ply:getDarkRPVar("money") < HowMuch then return DarkRP.notify(ply, 1, 5, Language.NotEnoughMoneyFailMsg) end 
		
		ply:SetNWInt(OreName, ply:GetNWInt(OreName) + OreCount)
		ply:addMoney(-HowMuch)		
		
		DarkRP.notify(ply, 0, 5, Language.Bought .. OreCount .. " of " .. OreName .. " for " .. DarkRP.formatMoney(HowMuch))
	else 
		if (HowMuch < actualprice) or (HowMuch > actualprice) then return end 
		
		if ply:GetNWInt(OreName) < OreCount then DarkRP.notify(ply, 1, 5, Language.SellingOresFailMsg) return end 

		ply:SetNWInt(OreName, ply:GetNWInt(OreName) - OreCount)
		
		ply:addMoney(HowMuch)

		DarkRP.notify(ply, 0, 5, Language.Sold .. OreCount .. " of " .. OreName .. " for " .. DarkRP.formatMoney(HowMuch))
	end 
end)

net.Receive("CraftItem", function(len, ply)
	local itemname = net.ReadString()
	local Language = MINING_Language[MININGSYSTEM.CurrentLanguage]
	local recipes = MININGSYSTEM.Recipes[itemname]
	local crafting_table = crafting_tables[ply]
	
	if crafting_table == nil then return end 
	if crafting_table == NULL then return end
	if ply:GetPos():DistToSqr(crafting_table:GetPos()) > 250*250 then return end 
	if recipes.Level != nil then 
		if (tonumber(ply:GetNWInt("CMS_MiningLevel")) < recipes.Level) then return DarkRP.notify(ply, 1, 5, Language.CraftingFailMsg) end 
	end
	for k, v in pairs(recipes.Resources) do
		local NWInt = "CMS_" .. v[2]
		local Quantity = v[1]
		if (tonumber(ply:GetNWInt(NWInt)) < tonumber(Quantity)) then return DarkRP.notify(ply, 1, 5, Language.CraftingFailMsg) end 

		ply:SetNWInt(NWInt, ply:GetNWInt(NWInt) - Quantity)		
	end 
	ply:addMoney(-recipes.CraftPrice)
	DarkRP.notify(ply, 0, 5, Language.CraftSuccessMsg .. itemname)
	
	if recipes.IsWeapon == true then 
		ply:Give(itemname)
	else 
		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 85
		trace.filter = ply

		local tr = util.TraceLine(trace)

		local ent = ents.Create(recipes.ItemID);
		ent:SetPos(tr.HitPos);
		ent:Spawn();
	end 
end)

net.Receive("CreateOre", function(len, ply)
	if !ply:IsSuperAdmin() then return end 
	
	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)
	
	local ent = ents.Create("cms_miningrock");
	ent:SetPos(tr.HitPos);
	ent:SetNWString("RockType", net.ReadString())
	ent:Spawn();
	ent:Activate();
     
	return ent;
end)

net.Receive("DropOre", function(len, ply)
	local OreType = net.ReadString()
	local OreClass = net.ReadString()
	
	if ply:GetNWInt("CMS_"..OreType) > 0 then 
		ply:SetNWInt("CMS_"..OreType, ply:GetNWInt("CMS_"..OreType) - 1)
		
		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 85
		trace.filter = ply

		local tr = util.TraceLine(trace)

		local ent = ents.Create("cms_mat");
		ent:SetPos(tr.HitPos);
		ent:SetNWString("OreClass", OreClass)
		ent:SetNWString("OreType", OreType)
		ent:Spawn();

		return ent;
	end
end)
local ore_positions = {}

local function SpawnOres()
	ore_positions_table = file.Read("miningsystem/" .. game.GetMap() ..".txt", "DATA")

	if ore_positions_table == nil then return end 
	
	ore_positions_table = util.JSONToTable(ore_positions_table)

	for k, v in pairs(ore_positions_table) do 
		local ent = ents.Create("cms_miningrock")
	
		ent:SetPos(v.pos);
		ent:SetAngles(v.ang);
		ent:SetNWString("RockType", v.OreType)
		ent:Spawn();
		ent:Activate();
		
		local phys = ent:GetPhysicsObject()
		phys:EnableMotion(false)

	end 
end 
hook.Add("PostCleanupMap", "SpawnOresOnMap", function() 
    timer.Simple(3, function()
        SpawnOres()
    end)
end )

hook.Add("InitPostEntity", "SpawnOresOnMap", function() 
	timer.Simple(3, function()
		SpawnOres()
	end)
end )

local function AddOreToJson(entity)
	file.CreateDir( "miningsystem/") 	
	local pos = entity:GetPos()
	local ang = entity:GetAngles()
	local directory = "miningsystem/" .. game.GetMap()
	local AddOre = {}
	
	AddOre.pos = pos
	AddOre.ang = ang

	AddOre.OreType = entity:GetNWString("RockType")
	AddOre.MapName = game.GetMap()

	table.insert(ore_positions, AddOre)
	local jsontable = util.TableToJSON(ore_positions)
	
	file.Write( directory .. ".txt", jsontable )

end 

hook.Add("PlayerDeath", "RemoveOres", function(ply)
	local remove = MININGSYSTEM.RemoveOresOnDie
	
	if remove then 
		for k, v in pairs (MININGSYSTEM.Ores) do 
			ply:SetNWInt("CMS_" .. v.Name, 0)
		end 		
	end 
end)

local function SaveOres()
	local findOres = ents.FindByClass( "cms_miningrock" )

	for k,v in pairs(findOres) do
		AddOreToJson(v)
	end
end 

hook.Add( "PlayerSay", "CreateOreCommand", function( ply, text, team )
	if !ply:IsSuperAdmin() then return end 
	
	if ( string.sub( string.lower( text ), 1, 10 ) == "!createore" ) then
		net.Start("OreMenu")
		net.Send(ply)
	end 
	if (string.sub( string.lower( text ), 1, 8 ) == "!saveore" ) then 
		SaveOres()
		ply:ChatPrint("You're saved all ore positions to database")
	end
end )

concommand.Add( "cms_resetores", function( ply, cmd, args )
	if !ply:IsSuperAdmin() then return end 
	
    if not args[1] then return end
	
	local plyFound = nil 
	
	for k, v in pairs( player.GetAll() ) do 
		if string.find( v:Nick(), args[1], 1, true ) then
			plyFound = v
		end 
	end
	if (plyFound == nil) then
		ply:ChatPrint( "Player not found" )
	else 
		for k, v in pairs (MININGSYSTEM.Ores) do 
			plyFound:SetNWInt("CMS_" .. v['Name'], 0)
		end 
			ply:ChatPrint( "You reseted " .. plyFound:Nick() .. "'s ores" )
	end
end )

concommand.Add( "cms_setore", function( ply, cmd, args )
	if !ply:IsSuperAdmin() then return end 
    if not args[1] then return end
    if not args[2] then return end
    if not args[3] then return end
	local plyFound = nil 
	for k, v in pairs( player.GetAll() ) do 
		if string.find( v:Nick(), args[1], 1, true ) then
			plyFound = v
		end 
	end
	local Ore = args[2]
	local howmuch = args[3]
	
	if (plyFound == nil) then
		ply:ChatPrint( "Player not found" )
	else 
		plyFound:SetNWInt("CMS_" .. Ore, howmuch)
		ply:ChatPrint( "You set " .. Ore .. " on " .. howmuch .. " for ".. plyFound:Nick()  )
	end
end )
