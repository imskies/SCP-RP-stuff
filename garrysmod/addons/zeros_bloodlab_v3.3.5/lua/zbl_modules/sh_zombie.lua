/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

/*

	This module will spawn a infected zombie once a corpse explodes which can infect players if he attacks them

*/

local enabled = false
local ZombieLimit = 10
local ZombieList = {
	["npc_zombie"] = true,
	["npc_fastzombie"] = true,
	["npc_fastzombie_torso"] = true,
	["npc_zombie_torso"] = true,
}
if not enabled then return end

for k,v in pairs(ZombieList) do
	zbl.config.Contamination.ents[k] = true
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

if CLIENT then return end

local ZombieCache = {}
local function GetZombieCount()
	local count = 0
	for k,v in pairs(ZombieCache) do
		if not IsValid(v) then continue end
		count = count + 1
	end
	return count
end

// Gets called when a corpse explodes
hook.Add("zbl_OnCorpseExplosion", "zbl_OnCorpseExplosion_zombie", function(corpse, virus_id)

	// Check if there arent too many zombies on the map
	if GetZombieCount() < ZombieLimit then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

		local _,key = table.Random(ZombieList)

		// Spawn the zombie where the corpse explodes
		local ent = ents.Create(key)
		ent:SetPos(corpse:GetPos() + Vector(0,0,5))
		ent:Spawn()
		ent:Activate()

		table.insert(ZombieCache,ent)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

		zbl.Vaccine.Set(ent, virus_id,1)

		ent:SetMaterial(zbl.Vaccine.GetMaterial(virus_id))

		// Die after 5 minutes
		timer.Simple(300,function()
			if IsValid(ent) then
				ent:TakeDamage(2000, ent, ent)
			end
		end)
	end
end)

hook.Add("EntityTakeDamage", "zbl_zombie_damage", function(target, dmginfo)
	if IsValid(target) and target:IsPlayer() and target:Alive() then

		local attacker = dmginfo:GetAttacker()
		if IsValid(attacker) and ZombieList[attacker:GetClass()] and zbl.Contamination.IsObjectContaminated(attacker) then

			// Infect the player with the virus
			zbl.Player.Infect(target, {
				vaccine_id = zbl.Vaccine.Get(attacker),
				vaccine_stage = 1,
				inflictor = attacker,
				infect_type = "cough"
			})
		end
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360
