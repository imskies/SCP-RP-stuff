/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

zbl = zbl or {}
zbl.Quest = zbl.Quest or {}

zbl.config = zbl.config or {}
zbl.config.NPC = zbl.config.NPC or {}
zbl.config.NPC.quests = zbl.config.NPC.quests or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

// For easier quest creation
function zbl.Quest.CreateConfig(quest) return table.insert(zbl.config.NPC.quests, quest) end

zbl.Quests = {}
function zbl.Quest.Create(quest) return table.insert(zbl.Quests, quest) end

// The player needs to bring unique player samples to the npc
ZBL_SUPPLY_UNIQUE_PLAYER_SAMPLES = zbl.Quest.Create({
	icon = zbl.materials["zbl_dna_icon"],
	color = zbl.colors["virus_red"],
	// Gets called when the job got accepted
	OnStart = function(ply, quest_data) end,

	// Gets called when the player clicks on the finish button
	OnProgressCheck = function(ply, quest_data)

		// Lets check if the player has everything to complete the quest
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return false end

		return zbl.Injector.HasFlask(swep, quest_data.count, true, "player", nil, 1)
	end,

	// Called when the player finishes the quest
	OnCompleted = function(ply, quest_data)

		// Removes the unique samples from the players gun
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return end
		zbl.Injector.RemoveFlask(swep, quest_data.count, true, "player", nil, 1)
	end
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

// The player needs to bring virus samples to the npc
ZBL_SUPPLY_VIRUS_SAMPLES = zbl.Quest.Create({
	icon = zbl.materials["zbl_icon_virusdna"],
	color = zbl.colors["sample_blue"],
	OnStart = function(ply, quest_data) end,
	OnProgressCheck = function(ply, quest_data)
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return false end

		return zbl.Injector.HasFlask(swep, quest_data.count, false, quest_data.sample_class, quest_data.virus_id, 1)
	end,
	OnCompleted = function(ply, quest_data)
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return end
		zbl.Injector.RemoveFlask(swep, quest_data.count, false, quest_data.sample_class, quest_data.virus_id, 1)
	end
})

// The player needs to bring specified samples
ZBL_SUPPLY_SAMPLES = zbl.Quest.Create({
	icon = zbl.materials["zbl_dna_icon"],
	color = zbl.colors["sample_blue"],
	OnStart = function(ply, quest_data) end,
	OnProgressCheck = function(ply, quest_data)
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return false end

		return zbl.Injector.HasFlask(swep, quest_data.count, false, quest_data.sample_class, quest_data.virus_id, 1)
	end,
	OnCompleted = function(ply, quest_data)
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return end
		zbl.Injector.RemoveFlask(swep, quest_data.count, false, quest_data.sample_class, quest_data.virus_id, 1)
	end
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

// The player needs to bring virus flasks
ZBL_SUPPLY_VACCINE = zbl.Quest.Create({
	icon = zbl.materials["zbl_icon_vaccine"],
	color = zbl.colors["virus_red"],
	OnStart = function(ply, quest_data) end,
	OnProgressCheck = function(ply, quest_data)
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return false end

		return zbl.Injector.HasFlask(swep, quest_data.count, false, nil, quest_data.virus_id, 2)
	end,
	OnCompleted = function(ply, quest_data)
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return end
		zbl.Injector.RemoveFlask(swep, quest_data.count, false, nil, quest_data.virus_id, 2)
	end
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

// The player needs to bring cure flasks
ZBL_SUPPLY_CURE = zbl.Quest.Create({
	icon = zbl.materials["zbl_cure_icon"],
	color = zbl.colors["cure_green"],
	OnStart = function(ply, quest_data) end,
	OnProgressCheck = function(ply, quest_data)
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return false end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

		return zbl.Injector.HasFlask(swep, quest_data.count, false, nil, quest_data.virus_id, 3)
	end,
	OnCompleted = function(ply, quest_data)
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return end
		zbl.Injector.RemoveFlask(swep, quest_data.count, false, nil, quest_data.virus_id, 3)
	end
})
