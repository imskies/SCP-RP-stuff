-- lua/entities/psych_computer/init.lua (server)
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props/cs_office/computer.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:EnableMotion(false) end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    activator._PsychEvalNextUse = activator._PsychEvalNextUse or 0
    if activator._PsychEvalNextUse > CurTime() then return end
    activator._PsychEvalNextUse = CurTime() + 0.75

    -- Instead of sending eval data directly, instruct the client to open the chooser UI.
    -- The chooser will then request data from the server (PsychEval_RequestOpen).
    net.Start("PsychEval_OpenChooser")
    net.Send(activator)
end