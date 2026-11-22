AddCSLuaFile()

SWEP.PrintName      = "Foundation AI"
SWEP.Author         = "ynot01"
SWEP.Purpose        = "Makes you invisible and pass-through while holding the SWEP"
SWEP.Instructions   = "Left click to toggle noclip"

SWEP.Category       = "ynot01's SWEPs"

SWEP.Slot           = 2
SWEP.SlotPos        = 0

SWEP.Spawnable      = true

SWEP.ViewModel      = Model( "models/weapons/c_arms.mdl" )
SWEP.WorldModel     = ""
SWEP.ViewModelFOV   = 54

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.WepSelectIcon = nil
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

function SWEP:SetupDataTables()
    --self:NetworkVar("Int",0,"Example")
end

function SWEP:Initialize()
    --self:SetExample(0)
    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
    if CLIENT then return end
    local own = self:GetOwner()
    if own:GetMoveType() == MOVETYPE_WALK then
        own:SetMoveType( MOVETYPE_NOCLIP )
    elseif own:GetMoveType() == MOVETYPE_NOCLIP then
        own:SetMoveType( MOVETYPE_WALK )
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:DrawWorldModel()
	self:DestroyShadow(true)
end

function SWEP:Deploy()
    self:GetOwner():SetNoDraw(true)
    self:GetOwner():DrawShadow(false)
    self:GetOwner():SetSolid(SOLID_NONE)
    return true
end

function SWEP:Holster()
    self:GetOwner():SetNoDraw(false)
    self:GetOwner():DrawShadow(true)
    self:GetOwner():SetSolid(SOLID_VPHYSICS)
    return true
end

function SWEP:Think()
    if self:GetOwner():IsOnFire() then
        self:GetOwner():Extinguish()
    end
end