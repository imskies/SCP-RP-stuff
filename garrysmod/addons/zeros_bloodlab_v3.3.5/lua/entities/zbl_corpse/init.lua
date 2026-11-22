/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
    local SpawnPos = tr.HitPos + tr.HitNormal * 15
    local ent = ents.Create(self.ClassName)
    ent:SetPos(SpawnPos)
    ent:Spawn()
    ent:Activate()
    zclib.Player.SetOwner(ent, ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

    return ent
end

function ENT:Initialize()

    self:SetModel( self.Model )
    self:PhysicsInit(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_NONE)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
    else
        self:Remove()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

        return
    end
    self:DrawShadow(false)
    self:UseClientSideAnimation()
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    self.PhysgunDisabled = true
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

function ENT:OnRemove()
    zbl.Corpse.OnRemove(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
