AddCSLuaFile()

SWEP.PrintName      = "SCP-049-2"
SWEP.Author         = "ynot01"
SWEP.Purpose        = ""
SWEP.Instructions   = "Obey SCP-049 and click to punch"

SWEP.Category       = "ynot01's SWEPs"

SWEP.Slot           = 2
SWEP.SlotPos        = 0

SWEP.Spawnable      = true

SWEP.ViewModel      = Model( "models/weapons/c_arms.mdl" )
SWEP.WorldModel     = ""
SWEP.ViewModelFOV   = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.WepSelectIcon = nil
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.DestroySound = "physics/wood/wood_furniture_break1.wav"
SWEP.DestroyModels = {
    ["models/foundation/doors/lcz_door.mdl"] = true,
    ["models/foundation/doors/hcz_door_01.mdl"] = true,
    ["models/foundation/doors/hcz_door_02.mdl"] = true,
	["models/foundation/containment/door01.mdl"] = true,
    ["models/novux/map/models/ez_cor_door_1.mdl"] = true,
    ["models/novux/map/models/ez_cor_door_2.mdl"] = true,
	["models/vgis/doors/main_door.mdl"] = true,
	["models/scp_asset_remaster/remastered_door.mdl"] = true,
    ["models/scp_asset_remaster/hcz_door_r.mdl"] = true,
    ["models/custom/br_site65/gate_01_0.mdl"] = true,
}

SWEP.RespawnTime = 180

if CLIENT then

    local scrw = ScrW() -- lowercase to differentiate from the function
    local scrh = ScrH()

    local HPText = {
        text = "0",
        font = "ySCP1048Font",
        pos = {scrw*0.5, scrh*0.85+25},
        xalign = TEXT_ALIGN_CENTER,
        yalign = TEXT_ALIGN_CENTER,
        color = color_white,
    }

    hook.Add("OnScreenSizeChanged", "ySCP1048A:UpdateResolution", function(oldW, oldH)
        scrw = ScrW()
        scrh = ScrH()
        HPText.pos = {scrw*0.5, scrh*0.85+25}
    end)

    function SWEP:DrawHUD()

        --------------- HP Bar ---------------
        draw.NoTexture()

        surface.SetDrawColor(0,0,0)
        surface.DrawRect(scrw/2-scrw*0.1-6,scrh*0.85-6,scrw*0.2+12,62)

        surface.SetDrawColor(26,26,26)
        surface.DrawRect(scrw/2-scrw*0.1-5,scrh*0.85-5,scrw*0.2+10,60)

        surface.SetDrawColor(62,62,62)
        surface.DrawRect(scrw/2-scrw*0.1-1,scrh*0.85-1,scrw*0.2+2,52)

        surface.SetDrawColor(210,0,0)
        surface.DrawRect(
            ScrW()/2-ScrW()*0.1, 
            ScrH()*0.85, 
            ScrW()*0.2*(LocalPlayer():Health()/LocalPlayer():GetMaxHealth()), 
            50
        )

        HPText.text = LocalPlayer():Health()
        draw.Text(HPText)

    end

end

function SWEP:SetupDataTables()
end

function SWEP:Initialize()
    self:SetHoldType( "fist" )
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
	local side = "fists_left"

	if math.random(1,2) == 1 then 
        side = "fists_right" 
    end

	if not(IsFirstTimePredicted()) then
		self:DoBFSAnimation(side)
		owner:GetViewModel():SetPlaybackRate(1)
		return
	end

	owner:ViewPunch(Angle(0,0,math.random(-2,2)))
	self:DoBFSAnimation(side)
	owner:SetAnimation(PLAYER_ATTACK1)
	owner:GetViewModel():SetPlaybackRate(1)

	if SERVER then
		sound.Play("weapons/slam/throw.wav",self:GetPos(),65,math.random(90,110))
		owner:ViewPunch( Angle(0,0,math.random(-2,2)) )
		timer.Simple(.15, function()
			if IsValid(self) then
				self:PunchFunc()
			end
		end)
	end
    
	self:SetNextPrimaryFire(CurTime()+.45)
	self:SetNextSecondaryFire(CurTime()+.45)
end

function SWEP:PunchFunc()
    if(CLIENT)then return end
    local owner = self:GetOwner()
	owner:LagCompensation(true)
	local Ent,HitPos=self:WhomILookinAt(owner,.3,55)
	local AimVec=owner:GetAimVector()
	if IsValid(Ent) or ( (Ent) and (Ent.IsWorld) and (Ent:IsWorld()) ) then

		local SelfForce, Mul = 125, 1

		if(self:IsEntSoft(Ent))then
			SelfForce = 25
			sound.Play("Flesh.ImpactHard", HitPos, 65, math.random(90,110))
		else
			sound.Play("Flesh.ImpactSoft", HitPos, 65, math.random(90,110))
		end

		local DamageAmt = SCPJobsConfig[49].PunchDamage

        if Ent:IsPlayer() and ( Ent:HasWeapon("weapon_ynot049_2") or Ent:HasWeapon("weapon_ynot049") ) then Mul = 0 end

		local Dam = DamageInfo()
		Dam:SetAttacker(owner)
		Dam:SetInflictor(self.Weapon)
		Dam:SetDamage(DamageAmt * Mul)
		Dam:SetDamageForce(AimVec * Mul^3)
		Dam:SetDamageType(DMG_CLUB)
		Dam:SetDamagePosition(HitPos)
		Ent:TakeDamageInfo(Dam)

		local Phys = Ent:GetPhysicsObject()

		if(IsValid(Phys))then
			if Ent:IsPlayer() then 
                Ent:SetVelocity( AimVec * SelfForce * 1.5 ) 
            end
			Phys:ApplyForceOffset( AimVec * 10 * Mul, HitPos )
		end

		if self:IsDoor(Ent) then
			if math.Rand(0,1) < SCPJobsConfig[49].DoorPunchChance then 
                DeepSCP_DestroyDoor(self:GetOwner():GetPos(), self:GetOwner(), self)
            end
		end

	end

	owner:LagCompensation(false)
end

function SWEP:WhomILookinAt(ply)
	local Tr = util.TraceLine( {
		start = ply:GetShootPos(),
		endpos = ply:GetShootPos() + ply:GetAimVector() * 80,
		filter = ply,
		mask = MASK_SHOT_HULL
	} )

	if ( !IsValid( Tr.Entity ) ) then
		Tr = util.TraceHull( {
			start = ply:GetShootPos(),
			endpos = ply:GetShootPos() + ply:GetAimVector() * 80,
			filter = ply,
			mins = Vector( -10, -10, -8 ),
			maxs = Vector( 10, 10, 8 ),
			mask = MASK_SHOT_HULL
		} )
	end
	if(Tr.Hit)then return Tr.Entity,Tr.HitPos end
end

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
	if not IsFirstTimePredicted() then
		self:DoBFSAnimation("fists_draw")
		self.Owner:GetViewModel():SetPlaybackRate(.1)
		return
	end
	self:SetNextPrimaryFire(CurTime() + .1)
	self:DoBFSAnimation("fists_draw")
    self.NextYell = CurTime() + math.Rand(5,15)
	return true
end

function SWEP:Holster()
    if not IsFirstTimePredicted() then return end
    return true
end

SWEP.NextYell = 0
function SWEP:Think()
    if CLIENT then return end
    if self.NextYell > CurTime() then return end
    self.NextYell = CurTime() + math.Rand(5,15)

    self:GetOwner():EmitSound("npc/zombie/zombie_voice_idle"..math.random(1,14)..".wav", 75, 100, 0.25)

end

function SWEP:IsDoor(ent)
	return IsValid(ent) and (ent:GetClass() == "func_door" or (ent:GetClass() == "prop_dynamic" and self.DestroyModels[ent:GetModel()]))
end

function SWEP:DoBFSAnimation(anim) -- from pabz SCP-096
	local vm=self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
end

function SWEP:IsEntSoft(ent) -- from pabz SCP-096
	return ((ent:IsNPC())or(ent:IsPlayer()))
end