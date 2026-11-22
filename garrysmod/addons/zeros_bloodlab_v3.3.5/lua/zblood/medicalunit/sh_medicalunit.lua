/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

zbl = zbl or {}
zbl.MedicalUnit = zbl.MedicalUnit or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

// Called when the player joins the server
function zbl.MedicalUnit.CanInteract(MedicalUnit,ply)
    return zclib.Player.IsOwner(ply, MedicalUnit) or MedicalUnit:GetIsPublicEntity()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

/*
	Check if the entity can be targeted
*/
local CustomTargetList = {["zbl_virusnode"] = true,["zbl_corpse"] = true,["zbl_diaria_spot"] = true,}
function zbl.MedicalUnit.IsTarget(ent)
	if zbl.config.Contamination.enabled and zbl.config.Contamination.ents[ent:GetClass()] then return true end
	if ent:IsPlayer() then return true end
	if CustomTargetList[ent:GetClass()] then return true end
	return false
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

/*
	Returns a list of all infected targets nearby
*/
function zbl.MedicalUnit.GetScanned(MedicalUnit)
	local ScannedEntities = {}
	local FoundInfected = false
	for k,v in pairs(ents.FindInSphere(MedicalUnit:GetPos(),zbl.config.StationaryMedicalUnit.Scan.radius)) do
		if not IsValid(v) then continue end
		if v == MedicalUnit then continue end
		if v:IsWeapon() then continue end
		if not v.GetModel then continue end

		if not zbl.MedicalUnit.IsTarget(v) then continue end

		local mdl = v:GetModel()
		if not mdl then continue end
		if CLIENT then
			util.PrecacheModel(mdl)
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

		if zbl.Player.IsInfected(v) then
			FoundInfected = true

			if SERVER then
				MedicalUnit:SetFoundInfections(MedicalUnit:GetFoundInfections() + 1)
			end
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

		if SERVER then
			MedicalUnit:SetScannedOjbects(MedicalUnit:GetScannedOjbects() + 1)
		end

		table.insert(ScannedEntities,v)
	end
	return ScannedEntities , FoundInfected
end
