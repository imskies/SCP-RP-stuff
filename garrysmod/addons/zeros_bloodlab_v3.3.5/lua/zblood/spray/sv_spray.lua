/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.Spray = zbl.Spray or {}


function zbl.Spray.GetTarget(swep)
	local tr = swep:GetOwner():GetEyeTrace()
	local ent = tr.Entity

	if tr.Hit == false then return end
	if not IsValid(ent) then return end

	if not ent:IsPlayer() then return end

	if zclib.util.InDistance(swep:GetOwner():GetPos(), ent:GetPos(), 200) == false then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

	return ent
end

function zbl.Spray.Initialize(swep)
	zclib.Debug("zbl.Spray.Initialize")
	swep:SetHoldType(swep.HoldType)
	swep:SetBusy(false)

	swep.IsSpraying = false
end

function zbl.Spray.Primary(swep)

	if swep:GetBusy() == true then
		return false
	end

	if swep:GetSprayAmount() <= 0 then
		swep:SetBusy(false)
		swep:GetOwner():StripWeapon("zbl_spray")
		return false
	end

	swep:GetOwner():EmitSound("zbl_spray")
	zclib.NetEvent.Create("zbl_player_disinfect", {swep:GetOwner()})

	swep:SetSprayAmount(swep:GetSprayAmount() - zbl.config.DisinfectantSpray.UsagePerClick)

	zbl.Spray.PlayShootAnim(swep)

	local tr = swep:GetOwner():GetEyeTrace()
	if tr.Hit and zclib.util.InDistance(swep:GetOwner():GetPos(), tr.HitPos, 200) and IsValid(tr.Entity) then

		local ent = tr.Entity
		if ent:GetClass() == "zbl_virusnode" then
			ent:TakeDamage( zbl.config.DisinfectantSpray.VirusNode_Damage, swep:GetOwner(), swep )
		elseif ent:GetClass() == "zbl_corpse" then
			SafeRemoveEntity(ent)
		elseif ent:GetClass() == "zbl_diaria_spot" then
			SafeRemoveEntity(ent)
		elseif zbl.Contamination.CanBeContaminated(ent) then

			if (zbl.config.DisinfectantSpray.Clear_Time or 0) > 0 then

				// Remove virus and make object immun against virus for certain amount of time
				zbl.Contamination.ObjectSterilize(ent)
			else

				// Remove virus from object
				zbl.Contamination.ObjectSanitise(ent)
			end

			zbl.Spray.ShowObjectStatus(swep,ent)
		elseif ent:IsPlayer() and ent:Alive() and zbl.Occopation.IsContaminated(ent) then
			zbl.Player.ForceCure(ent)
		end
	end

	swep:SetNextPrimaryFire(CurTime() + swep.Primary.Delay)
end

util.AddNetworkString("zbl_spray_scan")
function zbl.Spray.ShowObjectStatus(swep,ent)

	// Shows the object current contamination status
	net.Start("zbl_spray_scan")
	net.WriteEntity(ent)
	net.Send(swep:GetOwner())
end
function zbl.Spray.Secondary(swep)

	swep:SetNextSecondaryFire(CurTime() + swep.Secondary.Delay)
end

function zbl.Spray.Equip(swep)
	zclib.Debug("zbl.Spray.Equip")
	zbl.Spray.PlayDrawAnim(swep)
end

function zbl.Spray.Deploy(swep)
	zclib.Debug("zbl.Spray.Deploy")

	zclib.Timer.Remove("zbl_spray_drawanim_" .. swep:EntIndex() .. "_timer")
	zclib.Timer.Remove("zbl_spray_shootanim_" .. swep:EntIndex() .. "_timer")
	zclib.Timer.Remove("zbl_spray_reloadanim_" .. swep:EntIndex() .. "_timer")
	zclib.Timer.Remove("zbl_spray_shootanim_end_" .. swep:EntIndex() .. "_timer")

	swep.IsSpraying = false

	zbl.Spray.PlayDrawAnim(swep)
end

function zbl.Spray.Holster(swep)
	zclib.Debug("zbl.Spray.Holster")

	zclib.Timer.Remove("zbl_spray_drawanim_" .. swep:EntIndex() .. "_timer")
	zclib.Timer.Remove("zbl_spray_shootanim_" .. swep:EntIndex() .. "_timer")
	zclib.Timer.Remove("zbl_spray_reloadanim_" .. swep:EntIndex() .. "_timer")
	zclib.Timer.Remove("zbl_spray_shootanim_end_" .. swep:EntIndex() .. "_timer")

	swep.IsSpraying = false

	swep:SendWeaponAnim(ACT_VM_HOLSTER)

	swep:SetBusy(false)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337



function zbl.Spray.PlayShootAnim(swep)
	if not IsValid(swep) then return end // Safety first!

	if swep.IsSpraying == false then
		swep:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		//swep:GetOwner():SetAnimation(PLAYER_ATTACK1)
		swep.IsSpraying = true
	end

	local timerID = "zbl_spray_shootanim_" .. swep:EntIndex() .. "_timer"
	zclib.Timer.Remove(timerID)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

	zclib.Timer.Create(timerID,0.1,1,function()
		zclib.Timer.Remove(timerID)

		if IsValid(swep) and IsValid(swep:GetOwner()) and IsValid(swep:GetOwner():GetActiveWeapon()) and swep:GetOwner():GetActiveWeapon():GetClass() == "zbl_spray"  then

			swep:SetBusy(true)

			swep:SendWeaponAnim(ACT_VM_THROW)
			//swep:GetOwner():SetAnimation(PLAYER_ATTACK1)
			local timerID01 = "zbl_spray_shootanim_end_" .. swep:EntIndex() .. "_timer"
			zclib.Timer.Create(timerID01,0.1,1,function()
				zclib.Timer.Remove(timerID01)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

				swep.IsSpraying = false
				zbl.Spray.PlayIdleAnim(swep)
			end)
		end
	end)
end

function zbl.Spray.PlayDrawAnim(swep)
	if not IsValid(swep) then return end // Safety first!
	if not IsValid(swep:GetOwner()) then return end
	swep:SetBusy(true)

	swep:GetOwner():SetAnimation(PLAYER_IDLE)
	swep:SendWeaponAnim(ACT_VM_DRAW) // Play draw anim

	local timerID = "zbl_spray_drawanim_" .. swep:EntIndex() .. "_timer"
	zclib.Timer.Remove(timerID)

	zclib.Timer.Create(timerID,0.5,1,function()
		zclib.Timer.Remove(timerID)

		if IsValid(swep) and IsValid(swep:GetOwner()) and IsValid(swep:GetOwner():GetActiveWeapon()) and swep:GetOwner():GetActiveWeapon():GetClass() == "zbl_spray"  then

			zbl.Spray.PlayIdleAnim(swep)
		end
	end)
end

function zbl.Spray.PlayIdleAnim(swep)
	if not IsValid(swep) then return end // Safety first!
	if not IsValid(swep:GetOwner()) then return end
	zclib.Debug("zbl.Spray.PlayIdleAnim")
	swep:SendWeaponAnim(ACT_VM_IDLE)
	swep:GetOwner():SetAnimation(PLAYER_IDLE)

	swep:SetBusy(false)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c
