AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/antlion_grub.mdl")
    self:SetModelScale(2.4, 0)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetHealth(650)
    self:SetMaxHealth(650)
    self:SetIntegrity(100)
    self:SetColor(Color(175, 55, 55))
end

function ENT:OnTakeDamage(damage)
    if self.Destroyed then return end
    self:TakePhysicsDamage(damage)
    self:SetHealth(self:Health() - damage:GetDamage())
    self:SetIntegrity(math.Clamp((self:Health() / self:GetMaxHealth()) * 100, 0, 100))
    self:EmitSound("physics/flesh/flesh_impact_bullet" .. math.random(1, 5) .. ".wav", 60, 85, 0.45)

    if self:Health() <= 0 then
        self.Destroyed = true
        local effect = EffectData()
        effect:SetOrigin(self:WorldSpaceCenter())
        util.Effect("BloodImpact", effect, true, true)
        hook.Run("SCPRPEvent610Destroyed", self, damage:GetAttacker())
        SafeRemoveEntityDelayed(self, 0.1)
    end
end
