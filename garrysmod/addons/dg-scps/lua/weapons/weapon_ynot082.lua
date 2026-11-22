AddCSLuaFile()



SWEP.PrintName      = "SCP-082"

SWEP.Author         = "ynot01"

SWEP.Purpose        = "Knighting has a "..SCPJobsConfig[82].KnightCooldown.." second cooldown."

SWEP.Instructions   = "Left click to punch, right click to knight someone"



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

SWEP.Secondary.Automatic = true

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

}



SWEP.RespawnTime = 180



local FireDistance = 80

local FireDistanceSqr = FireDistance^2



function SWEP:SetupDataTables()

	self:NetworkVar("Float",0,"LastKnight")

end



function SWEP:Initialize()

	self:SetLastKnight(0)

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

		owner:GetViewModel():SetPlaybackRate(0.5)

		return

	end



	owner:ViewPunch(Angle(0,0,math.random(-2,2)))

	self:DoBFSAnimation(side)

	owner:SetAnimation(PLAYER_ATTACK1)

	owner:GetViewModel():SetPlaybackRate(1)



	if SERVER then

		sound.Play("weapons/slam/throw.wav",self:GetPos(),65,math.random(90,110))

		owner:ViewPunch( Angle(0,0,math.random(-2,2)) )

		timer.Simple(.3, function()

			if IsValid(self) then

				self:PunchFunc()

			end

		end)

	end

    

	self:SetNextPrimaryFire(CurTime()+.9)

end



function SWEP:SecondaryAttack()

    if CLIENT then return end

    if self:GetLastKnight() > CurTime() then return end



    local owner = self:GetOwner()



    local Tr = owner:GetEyeTrace()



    if ( !IsValid( Tr.Entity ) ) then

        Tr = util.TraceHull( {

            start = owner:GetShootPos(),

            endpos = owner:GetShootPos() + owner:GetAimVector() * FireDistance,

            filter = owner,

            mins = Vector( -10, -10, -8 ),

            maxs = Vector( 10, 10, 8 ),

            mask = MASK_SHOT_HULL

        } )

    end



    if Tr.HitWorld or not Tr.Hit then return end

    if Tr.Entity.SCPNum or !Tr.Entity:IsPlayer() or Tr.Entity:HasWeapon("weapon_ynot049") or Tr.Entity:GetModel() == "models/player/knight.mdl" then return end

    

    if owner:GetPos():DistToSqr( Tr.Entity:GetPos() ) > FireDistanceSqr then return end





    local ply = Tr.Entity



    ply.RDOTable["Mute"] = true -- Radio addon (mutes player's comms)

    ply:SendInformations() -- Radio addon (updates metatable to player)



    ply:SetModel("models/player/knight.mdl")

    ply:StripWeapons()

    ply:EmitSound("physics/metal/metal_grate_impact_hard"..math.random(1,3)..".wav")



    self:SetLastKnight(CurTime()+SCPJobsConfig[82].KnightCooldown)



    ply:SetMaxHealth( SCPJobsConfig[82].KnightHealth )

    ply:SetHealth( SCPJobsConfig[82].KnightHealth )

    ply:SetArmor( SCPJobsConfig[82].KnightArmor )



	if isstring(SCPJobsConfig[82].KnightSword) then

		ply:Give( SCPJobsConfig[82].KnightSword )

	elseif istable(SCPJobsConfig[82].KnightSword) then

		for k,v in pairs(SCPJobsConfig[82].KnightSword) do

			ply:Give(v)

		end

	end



end



function SWEP:Deploy()

	if not IsFirstTimePredicted() then

		self:DoBFSAnimation("fists_draw")

		self.Owner:GetViewModel():SetPlaybackRate(.5)

		return

	end

	self:SetNextPrimaryFire(CurTime() + 1)

	self:DoBFSAnimation("fists_draw")

	return true

end



function SWEP:Holster()

    if not IsFirstTimePredicted() then return end

    return true

end



function SWEP:Think()

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



		local DamageAmt = SCPJobsConfig[82].PunchDamage



        Mul = math.random(Mul*0.9, Mul*1.1)



        if Ent:IsPlayer() and (Ent.SCPNum or Ent:GetModel() == "models/player/knight.mdl") then Mul = 0 end



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

			if math.Rand(0,1) < 0.5 then 

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



function SWEP:DoBFSAnimation(anim) -- from pabz SCP-096

	local vm=self.Owner:GetViewModel()

	vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))

end



function SWEP:IsEntSoft(ent) -- from pabz SCP-096

	return ((ent:IsNPC())or(ent:IsPlayer()))

end



if CLIENT then



    local scrw = ScrW() -- lowercase to differentiate from the function

    local scrh = ScrH()



    hook.Add("OnScreenSizeChanged", "ySCP082:UpdateResolution", function(oldW, oldH)

        scrw = ScrW()

        scrh = ScrH()

    end)



    function SWEP:DrawHUD()



        --------------- Cure Cooldown ---------------

        if self:GetLastKnight() > CurTime() then

            draw.NoTexture()



            surface.SetDrawColor(0,0,0)

            surface.DrawRect(scrw/2-scrw*0.1-6,scrh*0.81-6,scrw*0.2+12,32)



            surface.SetDrawColor(26,26,26)

            surface.DrawRect(scrw/2-scrw*0.1-5,scrh*0.81-5,scrw*0.2+10,30)



            surface.SetDrawColor(62,62,62)

            surface.DrawRect(scrw/2-scrw*0.1-1,scrh*0.81-1,scrw*0.2+2,22)



            surface.SetDrawColor(0,180,0)

            surface.DrawRect(

                ScrW()/2-ScrW()*0.1, 

                ScrH()*0.81, 

                Lerp( (self:GetLastKnight() - CurTime()) / SCPJobsConfig[82].KnightCooldown, 0, ScrW()*0.2 ), 

                20

            )

        end



    end

end



function SWEP:IsDoor(ent)

	return IsValid(ent) and (ent:GetClass() == "func_door" or (ent:GetClass() == "prop_dynamic" and self.DestroyModels[ent:GetModel()]))

end