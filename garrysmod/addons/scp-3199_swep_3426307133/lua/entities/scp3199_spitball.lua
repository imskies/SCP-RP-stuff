AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "base_anim"
ENT.PrintName       = "SCP-3199 Spit"
ENT.Author          = "PapuMaster y Bombón Asesino"
ENT.Category        = "SCP"
ENT.Spawnable       = false
ENT.AdminSpawnable  = false

ENT.Damage          = {26, 32}
ENT.Radius          = 50
ENT.Sound           = "npc/antlion/antlion_poisonball2.wav"

function ENT:Initialize()
    self:SetModel("models/grub_nugget_large.mdl")
    self:SetMaterial("models/spitball/spitball")

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

    local phys    = self:GetPhysicsObject()
    if (IsValid(phys)) then
        phys:Wake()
        phys:SetMass(1)
    end

    self.SpawnTime = CurTime()
    self.Lifetime  = 10
    self.HasHit    = false

    if (SERVER) then
        self:EmitSound(self.Sound)
    end
    ParticleEffectAttach("antlion_spit_trail", PATTACH_ABSORIGIN_FOLLOW, self, 0)
end

function ENT:SplashDamage(pos, radius, owner)
    if (!SERVER) then return end
    local origin = pos or self:WorldSpaceCenter()
    for _, ent in ipairs(ents.FindInSphere(origin, radius)) do
        if (!IsValid(ent)) then continue end
        if (ent:IsPlayer() and ent:HasWeapon("scp3199swep")) then continue end
        if (SCP3199 and ent:IsPlayer() and SCP3199.IsSCP3199 and SCP3199.IsSCP3199(ent)) then continue end
        if (ent:GetClass() == "scp3199_egg") then continue end
        if (ent == owner) then continue end
        if (ent:Health() <= 0) then continue end
        local tr = util.TraceLine({
            start  = origin,
            endpos = ent:WorldSpaceCenter(),
            filter = {self, owner, ent}, 
            mask   = MASK_SOLID_BRUSHONLY 
        })
        if (tr.Hit) then continue end
        local dmg = DamageInfo()
        dmg:SetDamageType(DMG_ACID)
        dmg:SetAttacker(owner)
        dmg:SetInflictor(self)
        local Damage = math.random(self.Damage[1], self.Damage[2])
        dmg:SetDamage(Damage)
        ent:TakeDamageInfo(dmg)
        ent:EmitSound("SCP3199.AcidImpact")
    end
end

function ENT:Explode(pos)
    if (!IsValid(self)) or (self.HasHit) then return end
    self.HasHit        = true
    if (SERVER) then
        self:StopSound(self.Sound)
    end
    local explosionPos = pos or self:GetPos()
    local owner        = self:GetOwner()

    ParticleEffect("antlion_spit_05", explosionPos, Angle(0, 0, 0), owner)
    ParticleEffect("antlion_spit", explosionPos, Angle(0, 0, 0), owner)
    self:EmitSound("SCP3199.Corrosion")
    self:SplashDamage(explosionPos, self.Radius, owner)

    if (!SERVER) then return end
    self:Remove()
end

function ENT:PhysicsCollide(data, phys)
    if (self.HasHit) then return end

    local pos  = data.HitPos
    local norm = data.HitNormal

    util.Decal("BeerSplash",  pos + norm * 2, pos - norm * 2)
    util.Decal("YellowBlood", pos + norm * 2, pos - norm * 2)

    self:Explode(pos)
end

function ENT:Think()
    if (self:WaterLevel() > 1) then 
        self:Explode()
    elseif (!self.HasHit and CurTime() >= self.SpawnTime + self.Lifetime) then
        self:Explode()
    end
    self:NextThink(CurTime())
    return true
end

function ENT:Draw()
    self:DrawModel()
    self:DrawShadow(false)
end