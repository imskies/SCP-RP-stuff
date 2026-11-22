AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

-- Register networking channel
util.AddNetworkString("SCP324_Interact")

ENT.Model = "models/props/de_inferno/largebush04.mdl"
ENT.Cooldown = 5

function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end

    self.LastUse = 0
end

function ENT:Use(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    if CurTime() < (self.LastUse + self.Cooldown) then
        return
    end
    self.LastUse = CurTime()

    -- Send effect trigger to client
    net.Start("SCP324_Interact")
    net.Send(ply)
end
