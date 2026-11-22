/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3a7bd44c53efd46df183636fbe76c3de2bd5fbbd78a3773db33588e14b60a4d

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 30
	local ent = ents.Create(self.ClassName)
	local angle = ply:GetAimVector():Angle()
	angle = Angle(0, angle.yaw, 0)
	ent:SetAngles(angle)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	zclib.Player.SetOwner(ent, ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

	return ent
end

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	local phys = self:GetPhysicsObject()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- fde1005ae952a630057a2cc575fe1335e7c9809985c0483424501baa23d5a1ad

	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)
		phys:EnableDrag(true)
		phys:SetDragCoefficient(1)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350945

	self.PhysgunDisabled = zpiz.config.DisablePhysgun
	zpiz.Ingredient.Add(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350945
