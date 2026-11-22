AddCSLuaFile("cl_init.lua")

AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
local getfromtable = MININGSYSTEM.Ores[self:GetNWString("OreType")] 
    self:SetModel(getfromtable.MaterialModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetColor(getfromtable.Color);
	self:SetRenderMode(RENDERGROUP_BOTH)
end

local NextUse = 0
function ENT:Use(activator, caller)
	if CurTime() < NextUse then return end 
	if (caller:IsPlayer()) then
		caller:SetNWInt("CMS_"..self:GetNWString("OreType"), caller:GetNWInt("CMS_"..self:GetNWString("OreType")) + 1)
		NextUse = CurTime() + 0.5
		self:Remove()
	end
end