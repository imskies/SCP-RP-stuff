AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_combine/combine_mine01.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)
    self:SetRenderMode(RENDERMODE_TRANSALPHA)

    local physics = self:GetPhysicsObject()
    if IsValid(physics) then physics:EnableMotion(false) end
end
