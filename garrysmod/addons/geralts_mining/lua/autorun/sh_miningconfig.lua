MININGSYSTEM = MININGSYSTEM or {}
MINING_Language = MINING_Language or {}
icons = icons or {}
MININGSYSTEM.Background = "miningsystem/background.png"
MININGSYSTEM.CurrentLanguage = "English" -- Available Languages: Russian, English, German, French, Spanish
MININGSYSTEM.FunMode = false

MININGSYSTEM.UtilizeKeyInsteadContext = false
MININGSYSTEM.UtilizeKey = KEY_G -- https://wiki.facepunch.com/gmod/Enums/KEY

MININGSYSTEM.OreIcon = "miningsystem/icons/ore_stone.png"
MININGSYSTEM.GemIcon = "miningsystem/icons/gem.png"
MININGSYSTEM.WoodIcon = "miningsystem/icons/timber.png"
MININGSYSTEM.SaveDataTimer = 300
MININGSYSTEM.NPCModel = "models/Eli.mdl"
MININGSYSTEM.CraftingTableModel = "models/props_wasteland/controlroom_desk001b.mdl"
MININGSYSTEM.SuitModel = "models/player/police.mdl"
MININGSYSTEM.LevelProgress = 1000
MININGSYSTEM.RemoveOresOnDie = true 
MININGSYSTEM.BuyPriceMultiplier = 2
MININGSYSTEM.CanBeDropped = true
MININGSYSTEM.MaxOres = 999 -- maximum amount of ores, that can be handled 
MININGSYSTEM.HoverSound = "garrysmod/ui_hover.wav"
MININGSYSTEM.ClickSound = "garrysmod/ui_click.wav"

MININGSYSTEM.WeatherAddon = "None" --Use (None, StormFox or Atmos)  

MININGSYSTEM.RadioationDamageRadius = 300 --Hammer points

MININGSYSTEM.RadioactiveSuitPrice = 50000
MININGSYSTEM.RadioactiveSuitTime = 1200 -- 5 minutes
MININGSYSTEM.AutomaticWeaponsDebuff = 10 --Automatic weapons will have 10x lesser chance to drop ore and 10x lesser XP progress
MININGSYSTEM.DrillOverheatRate = 1 -- overheating speed (the more it is, the faster drill overheating)

MININGSYSTEM.XPProgress = 100 --XP Amount given for each success ore mining which is divide on drop chance. Example: 100 / Iron drop chance will 100 / 95 = ~1
MININGSYSTEM.MiningWeapons = {
	["cms_pickaxe"] = {1}, -- first value is classname, second is bonus, set third to true, if this weapon automatic
	["cms_drill"] = {1, true},
}
MININGSYSTEM.LevelBonus = 1 -- +1 ore per level


icons = {
	ore = Material(MININGSYSTEM.OreIcon, "smooth mips"),
	gem = Material(MININGSYSTEM.GemIcon, "smooth mips"),
	wood = Material(MININGSYSTEM.WoodIcon, "smooth mips"),
	gun = Material("miningsystem/icons/gun.png", "smooth mips"),
	box = Material("miningsystem/icons/box.png", "smooth mips"),
}

MININGSYSTEM.Categories = {
	{
		Name = "Weapons",
	},
	
	{
		Name = "Other",
	},
}

MININGSYSTEM.Ores = {
	["Iron"] = {
		Name = "Iron", -- Name 
		Price = 50, --Sell Price
		Color = Color(100,100,100),
		Icon = icons.ore, --Icon that will be shown in menu 
		Type = "Ore", --Type of material 
		DropChance = 95, --Drop chance, while mining 
		ResourceModel = "models/geralts/preda/rock.mdl", --Model of ore entity
		MaterialModel = "models/geralts/preda/tiny.mdl", --Model of entity, which spawns when you drop material 
	},
	
	["Bronze"] = {
		Name = "Bronze",
		Price = 100,
		Color = Color(250,86,15),
		Icon = icons.ore,
		Type = "Ore",
		DropChance = 75,
		ResourceModel = "models/geralts/preda/rock.mdl",
		MaterialModel = "models/geralts/preda/tiny.mdl",
	},
	
	["Ruby"] = {
		Name = "Ruby",
		Price = 150,
		Color = Color(255,10,10),
		Icon = icons.gem,
		Type = "Gem",
		DropChance = 50,
		ResourceModel = "models/geralts/preda/cr.mdl",
		MaterialModel = "models/geralts/preda/tiny_cr.mdl",
	},	
	
	["Sapphire"] = {
		Name = "Sapphire",
		Price = 150,
		Color = Color(82, 45, 186),
		Icon = icons.gem,
		Type = "Gem",
		DropChance = 50,
		ResourceModel = "models/geralts/preda/cr.mdl",
		MaterialModel = "models/geralts/preda/tiny_cr.mdl",
	},
	
	["Titanium"] = {
		Name = "Titanium",
		Price = 250,
		Color = Color(150,150,150),
		Icon = icons.ore,
		Type = "Ore",
		DropChance = 35,
		ResourceModel = "models/geralts/preda/rock.mdl",		
		MaterialModel = "models/geralts/preda/tiny.mdl",
	},
	
	["Emerald"] = {
		Name = "Emerald",
		Price = 300,
		Color = Color(100,255,100),
		Icon = icons.gem,
		Type = "Gem",
		DropChance = 25,
		ResourceModel = "models/geralts/preda/cr.mdl",
		MaterialModel = "models/geralts/preda/tiny_cr.mdl",
	},
	
	["Gold"] = {
		Name = "Gold",
		Price = 350,
		Color = Color(255,208,0),
		Icon = icons.ore,
		Type = "Ore",
		DropChance = 15,
		ResourceModel = "models/geralts/preda/rock.mdl",
		MaterialModel = "models/geralts/preda/tiny.mdl",
	},
	
	["Platinum"] = {
		Name = "Platinum",
		Price = 450,
		Color = Color(229,228,226),
		Icon = icons.ore,
		Type = "Ore",
		DropChance = 10,
		ResourceModel = "models/geralts/preda/rock.mdl",
		MaterialModel = "models/geralts/preda/tiny.mdl",
	},
	
	["Diamond"] = {
		Name = "Diamond",
		Price = 500,
		Color = Color(185,242,255),
		Icon = icons.gem,
		Type = "Gem",
		DropChance = 10,
		ResourceModel = "models/geralts/preda/cr.mdl",
		MaterialModel = "models/geralts/preda/tiny_cr.mdl",
	},
	
	["Tiberium"] = {
		Name = "Tiberium",
		Price = 750,
		Color = Color(37,255,5),
		Icon = icons.ore,
		Type = "Ore",
		ResourceModel = "models/geralts/preda/rock.mdl",
		MaterialModel = "models/geralts/preda/tiny.mdl",
		DropChance = 1,
		Radioactive = true, -- Should have light?
		Brightness = 2, -- Light brightness
		Size = 512, -- Light size
	},
	
	["Wood"] = {
		Name = "Wood",
		Price = 50,
		Color = Color(105,50,0),
		Icon = icons.wood,
		Type = "Wood",
		ResourceModel = "models/props_foliage/tree_springers_01a.mdl",
		MaterialModel = "models/props_phx/construct/wood/wood_panel1x1.mdl",
		DropChance = 95,
	},
}

MININGSYSTEM.Recipes = {
    ["cw_m1911"] = {
		Name = "m1911", -- "Beatiful" name of item
		ItemID = "cw_m1911", --Item ID (should be same like table name) 
		Model = "models/weapons/w_pistol.mdl", -- Model 
		Color = Color(255,255,255), -- Color of item 
		CraftPrice = 10000, --Craft Price 
		Level = 3, -- Level required to craft 
		Resources = { -- Resources Required to craft item 
			{100, "Iron"},
			{15, "Ruby"},
		},
		AdditionalViewPosZ = -4, --Menu Cam Pos Correction
		IsWeapon = true, --If true, then item will give to player, if false then it'll be spawn on workbench
		Category = "Weapons", -- Category of item
	},   

	["cw_p99"] = {
		Name = "P99",
		ItemID = "cw_p99",
		Model = "models/weapons/cw_p99.mdl",
		Color = Color(255,255,50),
		CraftPrice = 10000,
		Resources = {
			{45, "Titanium"},
			{60, "Ruby"},
		},
		IsWeapon = true,
		AdditionalViewPosZ = -4,
		Category = "Weapons",
	},	
	
	["MedKit"] = {
		Name = "Battery",
		ItemID = "weapon_medkit",
		Model = "models/items/weapon_medkit.mdl",
		Color = Color(125,125,200),
		CraftPrice = 2000,
		Resources = {
			{60, "Emerald"},
			{100, "Iron"},
		},
		AdditionalViewPosZ = 3,
		IsWeapon = false,
		Category = "Other",
	},

	["cw_p90"] = {
		Name = "P90",
		ItemID = "cw_p90",
		Model = "models/weapons/cw_p90.mdl",
		Color = Color(255,150,50),
		CraftPrice = 30000,
		Resources = {
			{55, "Saphire"},
			{75, "Diamond"},
		},
		IsWeapon = true,
		Category = "Weapons",
	},

  ["cw_l85a2"] = {
		Name = "l85a2",
		ItemID = "cw_l85a2",
		Model = "models/weapons/cw_l85a2.mdl",
		Color = Color(255,150,50),
		CraftPrice = 100000,
		Resources = {
			{35, "Saphire"},
			{100, "Diamond"},
            {25, "Tiberium"},
		},
		IsWeapon = true,
		Category = "Weapons",
	},

   ["weapon_cuff_rope"] = {
		Name = "weapon_cuff_rope",
		ItemID = "weapon_cuff_rope",
		Model = "models/weapons/weapon_cuff_elastic.mdl",
		Color = Color(255,150,50),
		CraftPrice = 5000,
		Resources = {
			{55, "Titanium"},
			{100, "Iron"},
            {100, "Bronze"},
		},
		IsWeapon = true,
		Category = "Weapons",
	},
  
}


MININGSYSTEM.Colors = {
	Background = Color(222,31,70,200),
	TextColor = Color(255,255,255),
	BuyButtonHover = Color(150,255,150),
	SellButtonHover = Color(200,10,10),
	BlackColor = Color(0,0,0),
	RadioactiveSuitHover = Color(200,200,50),
}


local files = file.Find( "miningsystem/*", "LUA" )
local languagefiles = file.Find( "miningsystem/languages/*", "LUA" )

if CLIENT then
	for _,v in pairs(files) do
		if string.StartWith(v,"cl_") then
			include("miningsystem/" .. v)
		end
	end	
	for _,v in pairs(languagefiles) do
		include("miningsystem/languages/" .. v)
	end
end 

if SERVER then
	for _,v in pairs(files) do
		if string.StartWith(v,"cl_") then
			AddCSLuaFile("miningsystem/" .. v)
		elseif string.StartWith(v,"sv_") then 
	        include("miningsystem/" .. v)
	    end
	end
	for _,v in pairs(languagefiles) do
		AddCSLuaFile("miningsystem/languages/" .. v)
		include("miningsystem/languages/" .. v)
	end
	resource.AddFile("resource/fonts/BebasNeue_B.ttf")
	resource.AddFile("resource/fonts/Dewberry_B.ttf")
	resource.AddWorkshop("1886197680")
end 