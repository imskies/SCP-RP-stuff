AddCSLuaFile()

SWEP.PrintName      = "SCP-966"
SWEP.Author         = "ynot01"
SWEP.Purpose        = "Successful strikes will heal you"
SWEP.Instructions   = "Primary attack to strike"

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
SWEP.DrawCrosshair = false

SWEP.BurnTime = 0

if CLIENT then
    surface.CreateFont( "ySCP966Font", {
        font = "Consolas",
        size = ScreenScale(16),
    } )

    local scrw = ScrW() -- lowercase to differentiate from the function
    local scrh = ScrH()

    local GreyCol = Color(100,100,100)
    local RedCol = Color(255,0,0)

    local VisText = {
        text = "Invisible",
        font = "ySCP966Font",
        pos = {scrw * 0.5, scrh * 0.85 + 25},
        xalign = TEXT_ALIGN_CENTER,
        yalign = TEXT_ALIGN_CENTER,
        color = color_white,
    }

    hook.Add("OnScreenSizeChanged", "ySCP966:UpdateResolution", function(oldW, oldH)
        scrw = ScrW()
        scrh = ScrH()
        VisText.pos = {scrw * 0.5, scrh * 0.85 + 25}
    end)

    function SWEP:DrawHUD()

        --------------- Strike Cooldown ---------------
        if self:GetLastStrike() > CurTime() then
            draw.NoTexture()

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
                Lerp( (self:GetLastStrike() - CurTime()) / SCPJobsConfig[966].AttackCooldown, 0, ScrW() * 0.2 ),
                20
            )
        end

        --------------- Visible Status ---------------
        draw.NoTexture()

        surface.SetDrawColor(0,0,0)
        surface.DrawRect(scrw / 2 - scrw * 0.1 - 6, scrh * 0.85 - 6, scrw * 0.2 + 12, 62)

        surface.SetDrawColor(26,26,26)
        surface.DrawRect(scrw / 2 - scrw * 0.1 - 5, scrh * 0.85 - 5, scrw * 0.2 + 10, 60)

        --surface.SetDrawColor(62,62,62)
        --surface.DrawRect(scrw/2-scrw*0.1-1,scrh*0.85-1,scrw*0.2+2,52)

        VisText.text = self:GetVisible() and "Visible!" or "Invisible"
        VisText.color = self:GetVisible() and RedCol or GreyCol
        draw.Text(VisText)

    end


end

function SWEP:SetupDataTables()
    self:NetworkVar("Float",0,"LastStrike")
    self:NetworkVar("Bool",0,"Visible")
    self:NetworkVar("Entity",0,"Targ")
end

function SWEP:Initialize()
    self:SetLastStrike(0)
    self:SetVisible(false)
    self:SetHoldType("normal")
end

local FireDistance = 80
local FireDistanceSqr = FireDistance^2

function SWEP:PrimaryAttack()
    if CLIENT then return end

    if self:GetLastStrike() > CurTime() then return end

    self:SetLastStrike( CurTime() + SCPJobsConfig[966].AttackCooldown )


    local owner = self:GetOwner()

    local Tr = DGUtil.Trace:Weapon(owner, owner:GetAimVector() * FireDistance)

    if ( !IsValid( Tr.Entity ) ) then 
        Tr = owner:GetEyeTrace()
    end

    self:GetOwner():EmitSound("npc/vort/claw_swing" .. math.random(1,2) .. ".wav", 65, 100, 1, CHAN_AUTO)

    if !Tr.Hit then
        return
    end

    if owner:GetPos():DistToSqr( Tr.Entity:GetPos() ) > FireDistanceSqr then return end

    if Tr.HitWorld or Tr.Entity.SCPNum or !Tr.Entity:IsPlayer() or Tr.Entity:HasWeapon("weapon_ynot966") then
        self:GetOwner():EmitSound("physics/body/body_medium_impact_hard" .. math.random(1,6) .. ".wav", 65, 100, 1, CHAN_AUTO)
        return
    end


    self:GetOwner():EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1,4) .. ".wav", 65, 100, 1, CHAN_AUTO)

    local ply = Tr.Entity

    local dmg = DamageInfo()
    local dmgnum = math.Rand( SCPJobsConfig[966].AttackDamage * 0.9, SCPJobsConfig[966].AttackDamage * 1.1 )
    dmg:SetDamagePosition( Tr.HitPos )
    dmg:SetDamageType( DMG_SLASH )
    dmg:SetDamage( math.Round(dmgnum) )
    dmg:SetAttacker( owner )
    dmg:SetInflictor( self )
    dmg:SetDamageForce( owner:GetForward() * dmgnum^2 )
    ply:TakeDamageInfo( dmg )

    owner:SetHealth( math.min( owner:GetMaxHealth(), owner:Health() + ( dmgnum / 4 ) ) )


end

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
    self:GetOwner():SetNoDraw(true)
    self:GetOwner():DrawShadow(false)
    return true
end

function SWEP:Holster()
    self:GetOwner():SetNoDraw(false)
    self:GetOwner():DrawShadow(true)
    return true
end

function SWEP:DrawWorldModel()
    self:DestroyShadow(true)
end

function SWEP:Think()
    if CLIENT then return end
    if self:GetVisible() == true and self.BurnTime < CurTime() then
        self:SetVisible(false)
        self:GetOwner():SetNoDraw(true)
        self:GetOwner():DrawShadow(false)
    end
end

if SERVER then
    hook.Add("EntityTakeDamage", "ySCP966:DamageReveal", function(victim, dmg)

        -- IsPlayer, Is DMG_BURN, Weapon valid, Weapon is weapon_ynot966
        if victim:IsPlayer() and bit.band(dmg:GetDamageType(), DMG_BURN) == DMG_BURN and IsValid(victim:GetActiveWeapon()) and victim:GetActiveWeapon():GetClass() == "weapon_ynot966" then
            local wep = victim:GetActiveWeapon()
            wep.BurnTime = CurTime() + SCPJobsConfig[966].VisibleDuration
            victim:SetNoDraw(false)
            victim:DrawShadow(true)
            wep:SetVisible(true)
        end

    end)
end