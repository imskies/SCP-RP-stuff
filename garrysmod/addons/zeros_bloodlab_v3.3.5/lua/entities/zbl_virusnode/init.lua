/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

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
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_NONE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
    else
        self:Remove()

        return
    end

    self:DrawShadow(false)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:SetTrigger(true)
    self:SetCustomCollisionCheck(true)

    self:SetVHealth(zbl.config.VirusHotspots.node_health_default)
    self.NextTouch = CurTime()
    self.Virus_ID = 1
    self.Virus_Stage = 1
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

function ENT:StartTouch(other)
    if IsValid(other) and other:IsPlayer() and other:Alive() and self.Virus_ID and self.Virus_Stage and self.NextTouch < CurTime() then
        self.NextTouch = CurTime() + 2
        zbl.Node.ExplodeNode(self,zbl.config.VirusNodes.KillOnTouch)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

function ENT:OnRemove()
    zbl.Node.OnRemove(self)
end

function ENT:OnTakeDamage(dmginfo)
    if zbl.config.VirusHotspots.node_damage == false then return end

    if (not self.m_bApplyingDamage) then
        self.m_bApplyingDamage = true
        self:TakeDamageInfo(dmginfo)
        zbl.Node.ChangeHealth(self, math.Clamp(self:GetVHealth() - dmginfo:GetDamage(), 0, zbl.config.VirusHotspots.node_health_max),dmginfo:GetAttacker())
        self.m_bApplyingDamage = false
    end
end
