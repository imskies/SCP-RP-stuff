/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

zpiz = zpiz or {}
zpiz.Player = zpiz.Player or {}

// Does the player have the correctjob
function zpiz.Player.IsPizzaChef(ply)
	if zpiz.config.Jobs and table.Count(zpiz.config.Jobs) > 0 then
		if zpiz.config.Jobs[zclib.Player.GetJob(ply)] then
			return true
		else
			return false
		end
	else
		return true
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 02d4e064402d16696deab5b093c9a34ae7a407e6165a08b9f87e1e597f153041

function zpiz.Player.CanInteract(ply,ent)
	if zpiz.Player.IsPizzaChef(ply) == false then return false end
	if zpiz.config.EquipmentSharing then return true end
	if ent.IsPublicEntity then return true end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- fde1005ae952a630057a2cc575fe1335e7c9809985c0483424501baa23d5a1ad

	if zclib.Player.IsOwner(ply, ent) then
		return true
	else
		return false
	end
end

function zpiz.Player.GetNearPizzaChef(ent)
	local cook = false
	// 1087110040
	for k, v in pairs(zclib.Player.List) do
		if not IsValid(v) then continue end
		if not v:IsPlayer() then continue end
		if not v:Alive() then continue end
		if zclib.util.InDistance(v:GetPos(), ent:GetPos(), 300) == false then continue end
		if zpiz.Player.CanInteract(v,ent) then
			cook = v
			break
		end
	end
	return cook
end

// Returns how many valid ingredients the player has currently spawned
function zpiz.Player.ReachedIngredientLimit(ply)
	ply.zpiz_SpawnedIngredients = ply.zpiz_SpawnedIngredients or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ee71cdadb4c1697a1f320cfc75c78c5f0135879a492afb53058e82fcefbc72f0

	local count = 0
	for k,v in pairs(ply.zpiz_SpawnedIngredients) do
		if IsValid(v) then
			count = count + 1
		end
	end
	return count >= zpiz.config.Ingredient.Limit
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350945
