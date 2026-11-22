AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_c17/canister01a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(CONTINUOUS_USE)
    self:SetNeutralization(0)
    self:SetColor(Color(130, 170, 90))

    local physics = self:GetPhysicsObject()
    if IsValid(physics) then physics:EnableMotion(false) end
end

function ENT:Use(ply)
    if self.Neutralized or not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
    if not SCPRPEvents.Config.IgnoreJobRequirements and not SCPRPEvents.IsRole(ply, "Medical") then
        ply:ChatPrint("Medical or Research personnel must neutralize this SCP-008 leak.")
        return
    end

    self.NextUse = self.NextUse or {}
    if (self.NextUse[ply] or 0) > CurTime() then return end
    self.NextUse[ply] = CurTime() + 0.2

    self:SetNeutralization(math.min(100, self:GetNeutralization() + 2.5))
    self:EmitSound("ambient/machines/keyboard2_clicks.wav", 55, 95 + self:GetNeutralization() * 0.15, 0.25)

    if self:GetNeutralization() >= 100 then
        self.Neutralized = true
        self:EmitSound("ambient/machines/steam_release_2.wav", 70, 110, 0.7)
        hook.Run("SCPRPEvent008Neutralized", self, ply)
        SafeRemoveEntityDelayed(self, 0.35)
    end
end

function ENT:Think()
    if math.random(1, 3) == 1 then
        local effect = EffectData()
        effect:SetOrigin(self:GetPos() + Vector(0, 0, 35))
        effect:SetScale(0.45)
        util.Effect("smoke", effect, true, true)
    end
    self:NextThink(CurTime() + 1)
    return true
end
