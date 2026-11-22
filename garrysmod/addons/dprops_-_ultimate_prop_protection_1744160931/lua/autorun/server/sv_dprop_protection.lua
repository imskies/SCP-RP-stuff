
util.AddNetworkString("dprops_notify")
util.AddNetworkString("dprops_openMenu")
util.AddNetworkString("dprops_removeProps")
util.AddNetworkString("dprops_disableProps")
util.AddNetworkString("dprops_ghostProps")
util.AddNetworkString("dprops_unghostProps")
util.AddNetworkString("dprops_freezeProps")

function DPROP.Notify(ply, msg)

	net.Start("dprops_notify")
	net.WriteString(msg)
	net.Send(ply)

end 

function DPROP.CanPickup(ply, ent)

	DPROP.Ghost(ply, ent)

end 

function DPROP.CanGhost(ent) 

	return not ent.dprop_isghosted

end 

function DPROP.Ghost(ply, ent)
	if FPP and FPP.UnGhost then FPP.UnGhost(ply, ent) end
	if ent.CPPICanPhysgun and not ent:CPPICanPhysgun(ply) then return end
	if DPROP.GhostEnabled and not IsValid(ent) or not DPROP.CanGhost(ent) and not ent:IsPlayer() then return end
	if DPROP.GhostedEnts[ent:GetClass()] or DPROP.VehicleGhost and ent:IsVehicle() then 
		ent.dprop_collision = ent:GetCollisionGroup()
		ent.dprop_color = ent.dprop_color or ent:GetColor()
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
		ent:SetRenderMode(RENDERMODE_TRANSALPHA)
		ent:DrawShadow(false)
		ent:SetTrigger(true)
		ent:SetColor(DPROP.GhostColor)
		ent.dprop_isghosted = true
	end 
end 


function DPROP.UnGhost(ply, ent)
	if DPROP.FreezeOnDrop then
		DPROP.FreezeProp(ent)
	end
	local phys = ent:GetPhysicsObject()
	if DPROP.KillVelocity then 
		phys:SetVelocityInstantaneous(Vector(0,0,0))
		phys:AddAngleVelocity(phys:GetAngleVelocity() * -1)
	end
	if DPROP.GhostEnabled and DPROP.CanGhost(ent) then return end
	if ent.dprop_collision then 
		ent:SetCollisionGroup(ent.dprop_collision)
	end
	if ent.dprop_color then 
		ent:SetColor(ent.dprop_color)
	end
	ent:DrawShadow(true)
	ent:SetTrigger(false)
	ent.dprop_isghosted = false
	phys:Wake()
	local reghost = phys:IsPenetrating()
	if DPROP.GhostDistanceCheck then 
		for k,v in pairs(player.GetAll()) do
			if v:GetPos():Distance(ent:GetPos()) < 65 then
				reghost = true
				break
			end 
		end
	end
	if reghost then 
		DPROP.Ghost(ply, ent)
		DPROP.FreezeProp(ent)
	end
end 

function DPROP.DisableDamage(target, dmg)

	local attacker = dmg:GetAttacker()
	local inflictor = dmg:GetInflictor()
	if IsValid(inflictor) then 
		if not DPROP.VehicleDamage and inflictor:IsVehicle() then
			return true
		end 
		if DPROP.NoDamage[attacker:GetClass()] or DPROP.NoDamage[inflictor:GetClass()] then
			return true 
		end
	end

end

function DPROP.FreezeProp(ent)
	if DPROP.GhostedEnts[ent:GetClass()] then

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end
end 

function DPROP.FreezeAllProps()

	if DPROP.PropAutoFreeze then 
		for k,v in pairs(ents.FindByClass("prop_physics")) do
			DPROP.FreezeProp(v)
		end
	end 

end

function DPROP.CreateTimers()
	timer.Create("DPROP:AutoFreeze", DPROP.TimerUpdate, 0, function()
		hook.Run("DPROPTimer")
	end) 
end


function DPROP.CanReloadPhys(weapon, ply)
	return DPROP.CanReloadPhysgun
end 

function DPROP.GravGunPunt(ply, ent)
	return DPROP.CanGravGunPunt
end 


 
function DPROP.PlayerSpawnedProp(ply, model, ent)
	if DPROP.PropLimits then
		local count = ply:GetCount("props")
		local max = DPROP.PropLimitRanks[ply:GetUserGroup()] or DPROP.DefaultPropLimit
		if count >= max then
			DPROP.Notify(ply, "You've hit the prop limit of " .. max .. "!")
			ent:Remove()
			return
		end 
	end 
	if DPROP.BlacklistedModels[model] then
		DPROP.Notify(ply, "That model is on the blacklist!")
		ent:Remove()
		return
	end
	if DPROP.CantSpawnProps[ply:GetUserGroup()] then
		DPROP.Notify(ply, "You don't have access to spawn props!")
		ent:Remove()
		return
	end 
	if ply:GetNWBool("dprops_propBan") then
		DPROP.Notify(ply, "Prop spawning has been disabled for you!")
		ent:Remove()
		return
	end 
	local min, max = ent:GetCollisionBounds()
	local diff = max - min
	local cubicUnits = math.Round(diff.x * diff.y * diff.z)
	ent.dprop_owner = ply
	if DPROP.MaxCubicUnits > 0 and cubicUnits > DPROP.MaxCubicUnits then
		DPROP.Notify(ply,"You can't spawn a prop with more than " .. DPROP.MaxCubicUnits .. " Units. Units: " .. cubicUnits)
		ent:Remove()
	end 
	if IsValid(ent) then  
		if not DPROP.OutsideProps then
			if not DPROP.OutsideAccessTeams[ply:Team()] and not DPROP.OutsideAccessGroups[ply:GetUserGroup()] then
				if DPROP.IsOutside(ent) then
					DPROP.Notify(ply, "You can't build outside!")
					ent:Remove()
				end 
			end 
		end
	end 
end 

function DPROP.IsOutside(ent)
	local tr = util.TraceLine({
		start = ent:GetPos(),
		endpos = ent:GetPos() + Vector(0,0,16000),
		filter = function(hitEnt) if hitEnt == ent then return false end end, 
	})
	return tr.HitSky
end 

function DPROP.ControlOutsideProps()
	if not DPROP.OutsideProps then 
		local notify = {}
		for k,v in pairs(ents.FindByClass("prop_physics")) do
			local owner = DPROP.GetOwner(v) 
			if not IsValid(owner) or DPROP.OutsideAccessTeams[owner:Team()] or DPROP.OutsideAccessGroups[owner:GetUserGroup()] then continue end 
			if DPROP.IsOutside(v) then
				notify[owner] = true
				v:Remove()
			end 
		end 
		for k,v in pairs(notify) do
			if IsValid(k) then
				DPROP.Notify(k, "One or more of your outside props have been removed.")
			end 
		end
	end 
end 

function DPROP.CanTargetPlayer(attacker, victim)
	local attackerRank = DPROP.AdminRankHierchy[attacker:GetUserGroup()] or 0
	local victimRank = DPROP.AdminRankHierchy[victim:GetUserGroup()] or 0
	return attackerRank >= victimRank
end 

hook.Add("DPROPTimer", "DPropFreeze", function()
	DPROP.FreezeAllProps()
	DPROP.ControlOutsideProps()
end)

hook.Add("PlayerSay", "OpenDPropsMenu", function( sender, text, teamChat )

	if string.lower(text) == "!dprops" then
		if not DPROP.AdminRankHierchy[sender:GetUserGroup()] then
			DPROP.Notify(sender, "No access!")
		else
			net.Start("dprops_openMenu")
			net.Send(sender)
		end
	end 

end)

net.Receive("dprops_removeProps", function(len,ply)
	local target = net.ReadEntity()
	local props = net.ReadTable()
	if not DPROP.AdminRankHierchy[ply:GetUserGroup()] then
		DPROP.Notify(ply, "No access!")
		return 
	end 
	if IsValid(target) and not DPROP.CanTargetPlayer(ply, target) then
		DPROP.Notify(ply, "You can't target " .. target:Name() .. "!")
		return 
	end
	for k,v in pairs(props) do
		if IsValid(v) then
			v:Remove()
		end 
	end
	local msg = ply:Name() .. " removed all props."
	if IsValid(target) then 
		msg = ply:Name() .. " removed " .. target:Name() .. "'s props."
	end 
	for k,v in pairs(player.GetAll()) do 
		DPROP.Notify(v, msg)
	end
end)

net.Receive("dprops_disableProps", function(len,ply)
	local target = net.ReadEntity()
	if not IsValid(target) then return end
	if not DPROP.AdminRankHierchy[ply:GetUserGroup()] then
		DPROP.Notify(ply, "No access!")
		return 
	end 
	if not DPROP.CanTargetPlayer(ply, target) then
		DPROP.Notify(ply, "You can't target " .. target:Name() .. "!")
		return 
	end 
	local isBanned = target:GetNWBool("dprops_propBan")
	local msg = ply:Name() .. " has disabled prop spawning for " .. target:Name() .. "."
	if not isBanned then 
		target:SetNWBool("dprops_propBan", true)
	else
		target:SetNWBool("dprops_propBan", false)
		msg = ply:Name() .. " has enabled prop spawning for " .. target:Name() .. "."
	end
	for k,v in pairs(player.GetAll()) do
		DPROP.Notify(v, msg)
	end 
end)

net.Receive("dprops_ghostProps", function(len,ply)
	if not DPROP.AdminRankHierchy[ply:GetUserGroup()] then
		DPROP.Notify(ply, "No access!")
		return 
	end 
	for k,v in pairs(ents.FindByClass("prop_physics")) do
		DPROP.Ghost(ply, v)
	end 
	for k,v in pairs(player.GetAll()) do
		DPROP.Notify(v, ply:Name() .. " ghosted all props.")
	end 
end)

net.Receive("dprops_unghostProps", function(len,ply)
	if not DPROP.AdminRankHierchy[ply:GetUserGroup()] then
		DPROP.Notify(ply, "No access!")
		return 
	end 
	for k,v in pairs(ents.FindByClass("prop_physics")) do
		DPROP.UnGhost(ply, v)
	end 
	for k,v in pairs(player.GetAll()) do
		DPROP.Notify(v, ply:Name() .. " unghosted all props.")
	end 
end)

net.Receive("dprops_freezeProps", function(len,ply)
	if not DPROP.AdminRankHierchy[ply:GetUserGroup()] then
		DPROP.Notify(ply, "No access!")
		return 
	end 
	for k,v in pairs(ents.GetAll()) do
		if not DPROP.GhostedEnts[v:GetClass()] then continue end 
		if IsValid(v:GetPhysicsObject()) then
			v:GetPhysicsObject():EnableMotion(false)
		end 
	end 
	for k,v in pairs(player.GetAll()) do
		DPROP.Notify(v, ply:Name() .. " froze all props.")   
	end 
end)

hook.Add("PhysgunPickup", "DPROP:CanPickup", DPROP.CanPickup)
hook.Add("PhysgunDrop", "DPROP:UnGhost", DPROP.UnGhost)
hook.Add("EntityTakeDamage", "DPROP:DisableDamage", DPROP.DisableDamage)
hook.Add("OnPhysgunReload", "DPROP:DisableDamage", DPROP.CanReloadPhys)
hook.Add("GravGunPunt", "DPROP:DisableDamage", DPROP.GravGunPunt)
hook.Add("Initialize", "DPROP:PropAutoFreeze", DPROP.CreateTimers)
hook.Add("PlayerSpawnedProp", "DPROP:PropAutoFreeze", DPROP.PlayerSpawnedProp)