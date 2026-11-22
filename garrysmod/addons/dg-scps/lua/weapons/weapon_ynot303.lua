AddCSLuaFile()

SWEP.PrintName      = "SCP-303"
SWEP.Author         = "ynot01"
SWEP.Purpose        = ""
SWEP.Instructions   = "Left click to attack, Right click to mark prey; you can only hurt marked prey"

SWEP.Category       = "ynot01's SWEPs"

SWEP.Slot           = 2
SWEP.SlotPos        = 0

SWEP.Spawnable      = true

SWEP.ViewModel      = Model( "models/weapons/c_arms.mdl" )
SWEP.WorldModel     = ""
SWEP.ViewModelFOV   = 54

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
SWEP.DrawCrosshair = true

-- Safety code in case config is missing
local SCPJobsConfig = SCPJobsConfig or {}
SCPJobsConfig[303] = SCPJobsConfig[303] or {}

if CLIENT then

    local TargMat = Material("sprites/glow04_noz")

    local PlayerList = player.GetAll()
    timer.Create("ySCP303UpdatePlys", 15, 0, function()
        PlayerList = player.GetAll()
    end)

    local scrw = ScrW() -- lowercase to differentiate from the function
    local scrh = ScrH()

    -- Victim: when hit by invisible projectile, some sort of overlay (or sound) to show theyre being tracked 
    hook.Add("HUDPaint", "ySCP1000Danger", function()
        if LocalPlayer():GetNWBool("ySCP1000Danger") then
            draw.NoTexture()
            surface.SetDrawColor(255,0,0,30)
            surface.DrawRect(0,0,scrw,scrh)
        end
    end)

    hook.Add("OnScreenSizeChanged", "ySCP303:UpdateResolution", function(oldW, oldH)
        scrw = ScrW()
        scrh = ScrH()
    end)

    function SWEP:DrawHUD()

        draw.NoTexture()

        -------------- Attack CD --------------
        if self:GetNextPrimaryFire() > CurTime() then
            surface.SetDrawColor(0,0,0)
            surface.DrawRect(scrw / 2 - scrw * 0.1 - 6, scrh * 0.85 - 6, scrw * 0.2 + 12, 32)

            surface.SetDrawColor(26,26,26)
            surface.DrawRect(scrw / 2 - scrw * 0.1 - 5, scrh * 0.85 - 5, scrw * 0.2 + 10, 30)

            surface.SetDrawColor(62,62,62)
            surface.DrawRect(scrw / 2 - scrw * 0.1 - 1, scrh * 0.85 - 1, scrw * 0.2 + 2, 22)

            surface.SetDrawColor(180,0,0)
            surface.DrawRect(
                ScrW() / 2 - ScrW() * 0.1,
                ScrH() * 0.85,
                Lerp( (self:GetNextPrimaryFire() - CurTime()) / (SCPJobsConfig[303].AttackCD or 0.75), 0, ScrW() * 0.2 ),
                20
            )
        end

        -------------- Tracker Projectile CD --------------
        if self:GetNextSecondaryFire() > CurTime() then
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
                Lerp( (self:GetNextSecondaryFire() - CurTime()) / (SCPJobsConfig[303].ShootCD or 2), 0, ScrW() * 0.2 ),
                20
            )
        end

        -- Tracker Outline --
        for k,v in ipairs( PlayerList ) do
            if not v:GetNWBool("ySCP1000Danger") then continue end

            local pos = v:GetPos()
            pos.z = pos.z + 50
            local TPos = pos:ToScreen()

            local AlphaSin = math.sin(CurTime() * 40) / 2 + 0.5
            local Size1, Size2 = 350, 100

            surface.SetMaterial(TargMat)

            surface.SetDrawColor(255,0,0,255 * AlphaSin)
            surface.DrawTexturedRect(TPos.x - Size1 / 2, TPos.y - Size1 / 2 ,Size1, Size1)

            surface.SetDrawColor(255, 255, 255, 255 * AlphaSin)
            surface.DrawTexturedRect(TPos.x - Size2 / 2, TPos.y - Size2 / 2, Size2, Size2)
        end

    end

end

function SWEP:SetupDataTables()
    self:NetworkVar("Int",0,"Example")
end

function SWEP:Initialize()
    self:SetExample(0)
    self:SetHoldType("normal")
end

local FireDistance = 80
local FireDistanceSqr = FireDistance^2

-- LMB: Regular attack, can only damage those with the halo (similar to 096's targeting)
function SWEP:PrimaryAttack()
    if CLIENT then return end

    -- Safe code in case config is missing, no need to edit this --
    local AttackDamage = SCPJobsConfig[303].AttackDamage or 50
    local AttackCD = SCPJobsConfig[303].AttackCD or 0.75
    ---------------------------------------------------------------

    self:SetNextPrimaryFire( CurTime() + AttackCD )

    local owner = self:GetOwner()

    local Tr = DGUtil.Trace:Weapon(owner, owner:GetAimVector() * FireDistance)

    if ( not IsValid( Tr.Entity ) ) then
        Tr = owner:GetEyeTrace()
    end

    owner:EmitSound("npc/vort/claw_swing" .. math.random(1,2) .. ".wav", 65, 100, 1, CHAN_AUTO)

    if not Tr.Hit then
        return
    end

    if owner:GetPos():DistToSqr( Tr.Entity:GetPos() ) > FireDistanceSqr then return end

    if Tr.HitWorld or Tr.Entity.SCPNum or not Tr.Entity:IsPlayer() or not Tr.Entity:GetNWBool("ySCP1000Danger") then
        owner:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1,6) .. ".wav", 65, 100, 1, CHAN_AUTO)
        return
    end


    owner:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1,4) .. ".wav", 65, 100, 1, CHAN_AUTO)

    local ply = Tr.Entity

    local dmg = DamageInfo()
    local dmgnum = math.Rand( AttackDamage * 0.9, AttackDamage * 1.1 )
    dmg:SetDamagePosition( Tr.HitPos )
    dmg:SetDamageType( DMG_SLASH )
    dmg:SetDamage( math.Round(dmgnum) )
    dmg:SetAttacker( owner )
    dmg:SetInflictor( self )
    dmg:SetDamageForce( owner:GetForward() * dmgnum^2 )
    ply:TakeDamageInfo( dmg )

end

-- RMB: Plays a scream sound ambient/voices/squeal1.wav, shoots an invisible projectile like a bullet, 
-- marks the person hit by said bullet with a halo or some sort of way to see them through walls (similar to 096's marking).
function SWEP:SecondaryAttack()
    -- Safe code in case config is missing, no need to edit this --
    local ShootRange = SCPJobsConfig[303].ShootRange or 750
    local ShootCD = SCPJobsConfig[303].ShootCD or 2
    local MarkLength = SCPJobsConfig[303].MarkLength or 30
    local ScreamSound = SCPJobsConfig[303].ScreamSound or "ambient/voices/squeal1.wav"
    ---------------------------------------------------------------

    local owner = self:GetOwner()

    if SERVER then
        owner:EmitSound(ScreamSound, 75, 100, 0.75)
    end

    -- Basic code with lag compensation, fires a trace line --
    local tracedata = {}
    tracedata.start = owner:GetShootPos()
    tracedata.endpos = owner:GetShootPos() + owner:GetAimVector() * ShootRange
    tracedata.filter = owner
    if ( owner:IsPlayer() ) then owner:LagCompensation( true ) end
    local tr = util.TraceLine( tracedata )
    if ( owner:IsPlayer() ) then owner:LagCompensation( false ) end
    ----------------------------------------------------------

    if tr.Hit and tr.Entity and tr.Entity:IsPlayer() and not tr.Entity:GetNWBool("ySCP1000Danger") then
        tr.Entity:SetNWBool("ySCP1000Danger", true)
        timer.Simple(MarkLength, function()
            tr.Entity:SetNWBool("ySCP1000Danger", false)
        end)
    end

    self:SetNextSecondaryFire( CurTime() + ShootCD )
end

function SWEP:Deploy()
    return true
end

function SWEP:Holster()
    if not IsFirstTimePredicted() then return end
    return true
end

function SWEP:Think()
end


-- Remove overlay/status when dead
if SERVER then
    hook.Add("PostPlayerDeath", "ySCP1000Death", function(dedply)
        dedply:SetNWBool("ySCP1000Danger", false)
    end)
end