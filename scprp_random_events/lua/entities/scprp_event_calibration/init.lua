AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_lab/reciever01b.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(CONTINUOUS_USE)
    self:SetProgress(0)
    self:SetStage(0)
    local physics = self:GetPhysicsObject()
    if IsValid(physics) then physics:EnableMotion(false) end
end

function ENT:Use(ply)
    if self.Completed or not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
    self.NextUse = self.NextUse or {}
    if (self.NextUse[ply] or 0) > CurTime() then return end
    self.NextUse[ply] = CurTime() + 0.2

    if self:GetStage() == 0 then
        if not SCPRPEvents.Config.IgnoreJobRequirements and not SCPRPEvents.IsRole(ply, "Research") then
            ply:ChatPrint("A member of Research must calibrate this station first.")
            return
        end

        self:SetProgress(math.min(100, self:GetProgress() + 3))
        self:EmitSound("buttons/lightswitch2.wav", 55, 95 + self:GetProgress() * 0.2, 0.25)
        if self:GetProgress() >= 100 then
            self:SetStage(1)
            hook.Run("SCPRPEventCalibrationResearch", self, ply)
        end
        return
    end

    if not SCPRPEvents.Config.IgnoreJobRequirements and not SCPRPEvents.IsRole(ply, "Security") then
        ply:ChatPrint("Security authorization is required.")
        return
    end

    self.Completed = true
    self:SetStage(2)
    self:EmitSound("buttons/button9.wav", 65, 105, 0.7)
    hook.Run("SCPRPEventCalibrationAuthorized", self, ply)
    SafeRemoveEntityDelayed(self, 0.35)
end
