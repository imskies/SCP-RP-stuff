/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

zbl = zbl or {}
zbl.Player = zbl.Player or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

player_manager.AddValidModel("Hazmat", "models/zerochain/props_bloodlab/zbl_hazmat.mdl")
player_manager.AddValidHands("Hazmat", "models/zerochain/props_bloodlab/zbl_hazmat_arms.mdl", 0, "00000000")

// Tells us if the player is male based on model or gives us a random result
function zbl.Player.IsMale(ply)
    local ply_model = ply:GetModel()
    if zbl.SoundByModel[ply_model] then
        if zbl.SoundByModel[ply_model] == "female" then
            return false
        else
            return true
        end
    else
        if zclib.util.RandomChance(50) then
            return true
        else
            return false
        end
    end
end

function zbl.Player.HurtSound(ply)
    if not IsValid(ply) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

    if zbl.Player.IsMale(ply) then
        ply:EmitSound("zbl_ouch_male")
    else
        ply:EmitSound("zbl_ouch_female")
    end
end

function zbl.Player.CoughSound(ply)
    if not IsValid(ply) then return end

    if zbl.Player.IsMale(ply) then
        ply:EmitSound("zbl_cough_male")
    else
        ply:EmitSound("zbl_cough_female")
    end
end

function zbl.Player.VomitSound(ply)
    if not IsValid(ply) then return end

    if zbl.Player.IsMale(ply) then
        ply:EmitSound("zbl_vomit_male")
    else
        ply:EmitSound("zbl_vomit_female")
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

function zbl.Player.IsResearcher(ply)
	if zbl.config.Jobs then
		if table.Count(zbl.config.Jobs) > 0 then
			if zbl.config.Jobs[zclib.Player.GetJob(ply)] then
				return true
			else
				return false
			end
		else
			return true
		end
	elseif BaseWars then
		return true
	else
		return false
	end
end

// Returns true if a research is on the server
function zbl.Player.ActiveResearcher()
	local result = false

	for k, v in pairs(zclib.Player.List) do
		if IsValid(v) and zbl.Player.IsResearcher(v) then
			result = true
			break
		end
	end

	return result
end

// This only returns true if the player is infected by a virus
function zbl.Player.IsInfected(ply)
    local id = zbl.Vaccine.Get(ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

    if zbl.Vaccine.IsVirus(id) then
        return true
    else
        return false
    end
end
