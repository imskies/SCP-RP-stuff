AddCSLuaFile()

SWEP.PrintName      = "SCP-1000"
SWEP.Author         = "ynot01"
SWEP.Purpose        = ""
SWEP.Instructions   = "Left click Punch, Right click Boost"

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

-- Safety code in case config is missing
local SCPJobsConfig = SCPJobsConfig or {}
SCPJobsConfig[1000] = SCPJobsConfig[1000] or {}

if CLIENT then

    surface.CreateFont( "ySCP1000Font", {
        font = "Consolas",
        size = ScreenScale(16),
    } )

    local scrw = ScrW() -- lowercase to differentiate from the function
    local scrh = ScrH()

    local HPText = {
        text = "0",
        font = "ySCP1000Font",
        pos = {scrw * 0.5, scrh * 0.85 + 25},
        xalign = TEXT_ALIGN_CENTER,
        yalign = TEXT_ALIGN_CENTER,
        color = color_white,
    }

    hook.Add("OnScreenSizeChanged", "ySCP1000:UpdateResolution", function(oldW, oldH)
        scrw = ScrW()
        scrh = ScrH()
        HPText.pos = {scrw * 0.5, scrh * 0.85 + 25}
    end)

    function SWEP:DrawHUD()


        draw.NoTexture()
        -------------- Boost CD --------------
        if self:GetLastBoost() > CurTime() then
            print("YE")
            surface.SetDrawColor(0,0,0)
            surface.DrawRect(scrw / 2 - scrw * 0.1 - 6, scrh * 0.81 - 6, scrw * 0.2 + 12, 32)

            surface.SetDrawColor(26,26,26)
            surface.DrawRect(scrw / 2 - scrw * 0.1 - 5, scrh * 0.81 - 5, scrw * 0.2 + 10, 30)

            surface.SetDrawColor(62,62,62)
            surface.DrawRect(scrw / 2 - scrw * 0.1 - 1, scrh * 0.81 - 1, scrw * 0.2 + 2, 22)

            surface.SetDrawColor(0,180,0)
            surface.DrawRect(
                ScrW() / 2 - ScrW() * 0.1,
                ScrH() * 0.81,
                Lerp( (self:GetLastBoost() - CurTime()) / ((SCPJobsConfig[1000].BoostDuration or 10) * 2), 0, ScrW() * 0.2 ),
                20
            )
        end

        --------------- HP Bar ---------------
        surface.SetDrawColor(0,0,0)
        surface.DrawRect(scrw / 2 - scrw * 0.1-6, scrh * 0.85-6, scrw * 0.2 + 12,62)

        surface.SetDrawColor(26,26,26)
        surface.DrawRect(scrw / 2 - scrw * 0.1-5, scrh * 0.85-5, scrw * 0.2 + 10,60)

        surface.SetDrawColor(62,62,62)
        surface.DrawRect(scrw / 2 - scrw * 0.1 - 1, scrh * 0.85 - 1, scrw * 0.2 + 2, 52)

        surface.SetDrawColor(210,0,0)
        surface.DrawRect(
            ScrW() / 2-ScrW() * 0.1,
            ScrH() * 0.85,
            ScrW() * 0.2 * (LocalPlayer():Health() / LocalPlayer():GetMaxHealth()),
            50
        )

        HPText.text = LocalPlayer():Health()
        draw.Text(HPText)

    end

end

function SWEP:SetupDataTables()
    self:NetworkVar("Float",0,"LastBoost")
end

function SWEP:Initialize()
    self:SetLastBoost(0)
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

    self:SetNextPrimaryFire(CurTime() + .45)
end

function SWEP:PunchFunc()
    if CLIENT then return end
    local owner = self:GetOwner()
    owner:LagCompensation(true)
    local Ent, HitPos = self:WhomILookinAt(owner,.3,55)
    local AimVec = owner:GetAimVector()
    if IsValid(Ent) or ( Ent and Ent.IsWorld and Ent:IsWorld() ) then

        local SelfForce, Mul = 125, 1

        if self:IsEntSoft(Ent) then
            SelfForce = 25
            sound.Play("Flesh.ImpactHard", HitPos, 65, math.random(90,110))
        else
            sound.Play("Flesh.ImpactSoft", HitPos, 65, math.random(90,110))
        end

        local DamageAmt = SCPJobsConfig[1000].PunchDamage or 75

        local Dam = DamageInfo()
        Dam:SetAttacker(owner)
        Dam:SetInflictor(self)
        Dam:SetDamage(DamageAmt * Mul)
        Dam:SetDamageForce(AimVec * Mul^3)
        Dam:SetDamageType(DMG_CLUB)
        Dam:SetDamagePosition(HitPos)
        Ent:TakeDamageInfo(Dam)

        local Phys = Ent:GetPhysicsObject()

        if (IsValid(Phys)) then
            if Ent:IsPlayer() then
                Ent:SetVelocity( AimVec * SelfForce * 1.5 )
            end
            Phys:ApplyForceOffset( AimVec * 10 * Mul, HitPos )
        end

        if self:IsDoor(Ent) and math.Rand(0,1) < (SCPJobsConfig[1000].DoorPunchChance or 50) then
            DGUtil:DestroyDoor(self:GetOwner():GetPos(), self:GetOwner())
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

    if not IsValid( Tr.Entity ) then
        Tr = util.TraceHull( {
            start = ply:GetShootPos(),
            endpos = ply:GetShootPos() + ply:GetAimVector() * 80,
            filter = ply,
            mins = Vector( -10, -10, -8 ),
            maxs = Vector( 10, 10, 8 ),
            mask = MASK_SHOT_HULL
        } )
    end
    if Tr.Hit then return Tr.Entity,Tr.HitPos end
end


-- Speed Boost
function SWEP:SecondaryAttack()
    if CLIENT then return end
    -- Safe code in case config is missing, no need to edit this --
    local MonkeySound = SCPJobsConfig[1000].BoostSound or "npc/strider/striderx_pain2.wav"
    local JumpMult = SCPJobsConfig[1000].BoostJumpMultiplier or 2
    local SpeedMult = SCPJobsConfig[1000].BoostJumpMultiplier or 2
    local BoostDuration = SCPJobsConfig[1000].BoostDuration or 10
    ---------------------------------------------------------------
    local BoostCooldown = BoostDuration * 2

    if self:GetLastBoost() > CurTime() then return end

    self:SetLastBoost(CurTime() + BoostCooldown)
    self:SetNextSecondaryFire(CurTime() + BoostCooldown)

    local ply = self:GetOwner()

    ply:EmitSound(MonkeySound, 75, 100, 0.25)

    ply:SetWalkSpeed(ply:GetWalkSpeed() * SpeedMult)
    ply:SetRunSpeed(ply:GetRunSpeed() * SpeedMult)
    ply:SetJumpPower(ply:GetJumpPower() * JumpMult)
    timer.Simple(BoostDuration, function()
        ply:SetWalkSpeed(ply:GetWalkSpeed() / SpeedMult)
        ply:SetRunSpeed(ply:GetRunSpeed() / SpeedMult)
        ply:SetJumpPower(ply:GetJumpPower() / JumpMult)
    end)


end

function SWEP:Deploy()
    if not IsFirstTimePredicted() then
        self:DoBFSAnimation("fists_draw")
        self:GetOwner():GetViewModel():SetPlaybackRate(.1)
        return
    end
    self:SetNextPrimaryFire(CurTime() + .1)
    self:DoBFSAnimation("fists_draw")
    return true
end

function SWEP:Holster()
    if not IsFirstTimePredicted() then return end
    return true
end

function SWEP:Think()
end

function SWEP:IsDoor(ent)
    return IsValid(ent) and (ent:GetClass() == "func_door" or ent:GetClass() == "prop_dynamic" or ent:GetClass() == "prop_physics")
end

function SWEP:DoBFSAnimation(anim) -- from pabz SCP-096
    local vm = self:GetOwner():GetViewModel()
    vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
end

function SWEP:IsEntSoft(ent) -- from pabz SCP-096
    return ent:IsNPC() or ent:IsPlayer()
end