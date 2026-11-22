local _P = FindMetaTable("Player")

function _P:GiveJobValues(_job)
	timer.Simple(0, function()
		if not IsValid(self) then return end
		if RPExtraTeams[_job] then
			local job = RPExtraTeams[_job]
			local walkSpeed = job.walkSpeed or job.walkspeed
			if walkSpeed then
				self:SetWalkSpeed(walkSpeed)
			end
			local runSpeed = job.runSpeed or job.runspeed
			if runSpeed then
				self:SetRunSpeed(runSpeed)
			end
			local health = job.health or job.hp
			if health then
				self:SetHealth(health)
				self:SetMaxHealth(health)
			end
			if job.armor then
				self:SetArmor(job.armor)
				self:SetMaxArmor(job.maxArmor or 255)
			end
			local jumpPower = job.jumpPower or job.jumppower
			if jumpPower then
				self:SetJumpPower(jumpPower)
			end
			local modelScale = job.modelScale or job.modelscale
			if modelScale then
				self:SetModelScale(modelScale)
			end
			if job.material then
				self:SetMaterial(job.material)
			else
				self:SetMaterial("")
			end
			if job.skin then
				self:SetSkin(job.skin)
			end
			if job.bodygroup0 then
				self:SetBodygroup(0, job.bodygroup0)
			end
			if job.bodygroup1 then
				self:SetBodygroup(1, job.bodygroup1)
			end
			if job.bodygroup2 then
				self:SetBodygroup(2, job.bodygroup2)
			end
			if job.bodygroup3 then
				self:SetBodygroup(3, job.bodygroup3)
			end
			if job.bodygroup4 then
				self:SetBodygroup(4, job.bodygroup4)
			end

		end

	end)

end


hook.Add("OnPlayerChangedTeam", "DCONFIG_CustomJobFields", function(ply, before,  after)

	ply:GiveJobValues(after)

end)

hook.Add("PlayerSpawn", "DCONFIG_CustomJobFieldsSpawn", function(ply)

	ply:GiveJobValues(ply:Team())

end)

hook.Add("PlayerInitialSpawn", "DCONFIG_CustomJobFieldsSpawn", function(ply)

	ply:GiveJobValues(ply:Team())

end)


hook.Add("playerCanChangeTeam", "DConfigHandleCustomJobMethods", function(ply, teamID, force)
	local jobData = RPExtraTeams[teamID]
	local steamids = jobData.steamids
	local accessGroups = jobData.accessgroups
	local hasAccess = true
	local failMsg = "You do not have access to this job!"
	if steamids and not steamids[ply:SteamID()] then
		return false, failMsg
	end
	if accessGroups and not accessGroups[ply:GetUserGroup()] then
		failMsg = "Your usergroup does not have access to this job!"
		return false, failMsg
	elseif accessGroups and accessGroups[ply:GetUserGroup()] then
		return true, failMsg
	end
	
end)

hook.Add("canBuyCustomEntity", "DConfigHandleCustomEntityMethods", function( ply, entTable)
	local steamids = entTable.steamids
	local accessGroups = entTable.accessgroups
	local hasAccess = true
	local failMsg = "You do not have access to this entity!"
	if steamids and not steamids[ply:SteamID()] then
		return false, false, failMsg
	end
	if accessGroups and not accessGroups[ply:GetUserGroup()] then
		failMsg = "Your usergroup does not have access to this entity!"
		return false, false, failMsg
	elseif accessGroups and accessGroups[ply:GetUserGroup()] then
		return true, false, failMsg
	end

end)

hook.Add("EntityTakeDamage", "DConfigEntityTakeDamage", function( target, dmg )

	local attacker = dmg:GetAttacker()
	if attacker:IsPlayer() then
		local jobData = RPExtraTeams[attacker:Team()]
		if not jobData then return end

		local dmgScale = jobData.damageScale or jobData.damagescale
		if not dmgScale then return end

		dmg:ScaleDamage(dmgScale)
	end

end)

hook.Add("GetFallDamage", "DConfigFallDamage", function(ply, speed)

	local jobData = RPExtraTeams[ply:Team()]
	if jobData then
		if jobData.noFallDamage or jobData.nofalldamage then
			return 0
		end
	end

end)

hook.Add("PlayerDeath", "DemoteOnDeathDConfig", function(victim, inflictor, attacker)
	local gm = (GM or GAMEMODE)
	local job = RPExtraTeams[victim:Team()] or nil
	if job then
		local demoteOnDeath = job.demoteOnDeath or job.demotedeath 
		local demoteDeathMessage = job.demoteOnDeathMessage or job.deathmessage
		if demoteOnDeath then
			victim:StripWeapons()
			if demoteDeathMessage then
				DarkRP.notifyAll(0, 4, demoteDeathMessage)
			end
			victim:changeTeam(gm.DefaultTeam, true)
			for k,v in pairs(ents.FindByClass("weapon_physgun")) do
				if v:GetPos():Distance(victim:GetPos()) < 200 then
					if v:GetOwner() == victim then
						v:Remove()
					end
				end
			end
		end
	end

end)