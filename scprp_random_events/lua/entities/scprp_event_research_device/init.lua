AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_lab/reciever01a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(CONTINUOUS_USE)
    self:SetProgress(0)
    self:SetDeviceLabel(self:GetDeviceLabel() ~= "" and self:GetDeviceLabel() or "RESEARCH DEVICE")
    self:SetActionLabel(self:GetActionLabel() ~= "" and self:GetActionLabel() or "HOLD E")

    local physics = self:GetPhysicsObject()
    if IsValid(physics) then physics:EnableMotion(false) end
end

function ENT:Use(ply)
    if self.Completed or not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
    self.NextUse = self.NextUse or {}
    if (self.NextUse[ply] or 0) > CurTime() then return end
    self.NextUse[ply] = CurTime() + 0.18

    if not SCPRPEvents.Config.IgnoreJobRequirements and not SCPRPEvents.IsRole(ply, "Research") then
        ply:ChatPrint("Research personnel must operate this device.")
        return
    end

    self:SetProgress(math.min(100, self:GetProgress() + (self.ProgressStep or 4)))
    self:EmitSound("buttons/lightswitch2.wav", 55, 90 + self:GetProgress() * 0.25, 0.22)

    if self:GetProgress() >= 100 then
        self.Completed = true
        self:EmitSound("buttons/button14.wav", 70, 105, 0.75)
        hook.Run("SCPRPEventResearchDeviceCompleted", self, ply)
    end
end
