AddCSLuaFile()

SWEP.Category                  = "SCP Sweps"
SWEP.Instructions              = "Primary: Bite\nSecondary: Corrosive Spit \nReload: Roar"
SWEP.Author                    = "PapuMaster & Bombón Asesino"
SWEP.Spawnable                 = true
SWEP.AdminSpawnable            = true
SWEP.PrintName                 = "SCP-3199 SWEP"

SWEP.Slot                      = 0
SWEP.SlotPos                   = 4

SWEP.DrawAmmo                  = false
SWEP.DrawCrosshair             = true

SWEP.ViewModel                 = Model("") 
SWEP.WorldModel                = Model("") 
SWEP.UseHands                  = false
SWEP.HoldType                  = "knife"

SWEP.Primary.ClipSize          = -1
SWEP.Primary.DefaultClip       = -1
SWEP.Primary.Automatic         = true
SWEP.Primary.Ammo              = "none"

SWEP.HitSound                  = "SCP3199.Bite"
SWEP.HitCooldown               = 0.9
SWEP.HitRange                  = 58
SWEP.HitForce                  = 120
SWEP.HitForceScale             = 10000
SWEP.HitDamage                 = {42, 44}
SWEP.HitSize = {
    Min = Vector(-15, -15, -10),
    Max = Vector(15, 15, 10)
}

SWEP.Secondary.ClipSize        = -1
SWEP.Secondary.DefaultClip     = -1
SWEP.Secondary.Automatic       = true
SWEP.Secondary.Ammo            = "none"

SWEP.SpitCooldown              = 6
SWEP.SpitForce                 = 1200
SWEP.SpitAccuracy              = 80
SWEP.SpitSound                 = "SCP3199.Vomit"

SWEP.RoarCooldown              = 4
SWEP.RoarSound                 = "SCP3199.Scream"
SWEP.RoarFreezeTime            = 2.3

SWEP.DestroySound = "physics/wood/wood_furniture_break1.wav"
SWEP.DestroyModels = {
    ["models/scp_asset_remaster/hcz_door_r.mdl"] = true,
    ["models/custom/br_site65/gate_01_0.mdl"] = true,
}

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end

function SWEP:IsDoor(ent)
    if not IsValid(ent) then return false end

    local class = ent:GetClass()
    local mdl   = ent:GetModel()

    -- Functional doors: ALWAYS breakable
    if class == "func_door"
    or class == "func_door_rotating"
    or class == "func_movelinear" then
        return true
    end

    -- Visible door props: only if listed
    if class == "prop_dynamic"
    or class == "prop_dynamic_override"
    or class == "prop_physics" then
        return self.DestroyModels[mdl] == true
    end

    return false
end

function SWEP:Equip()
    self:SetNextPrimaryFire(CurTime() + 0.5)
end

function SWEP:OnRemove()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if owner.IsSCREAMING and owner:IsFrozen() then
        owner:SetInSCP3199Taunt(false)
        owner.IsSCREAMING = false
    end
end

local phys_pushscale = GetConVar("phys_pushscale")

function SWEP:OnBite(ent)
    -- optional callback
end

-- Core bite logic (damage + physics)
function SWEP:SCP3199Bite()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    owner:LagCompensation(true)

    local startPos = owner:GetShootPos()
    local endPos   = startPos + owner:GetAimVector() * self.HitRange
    local filter   = { owner }

    local tr = util.TraceLine({
        start  = startPos,
        endpos = endPos,
        filter = filter,
        mask   = MASK_SHOT_HULL
    })

    if not IsValid(tr.Entity) then
        tr = util.TraceHull({
            start  = startPos,
            endpos = endPos,
            filter = filter,
            mins   = self.HitSize.Min or Vector(-16, -16, -8),
            maxs   = self.HitSize.Max or Vector(16, 16, 8),
            mask   = MASK_SHOT_HULL
        })
    end

    if not tr.Hit then
        owner:LagCompensation(false)
        return
    end

    local ent    = tr.Entity
    local Damage = math.random(self.HitDamage[1], self.HitDamage[2])

    if SERVER and tr.Hit then
        local dmg = DamageInfo()
        dmg:SetDamage(Damage)
        dmg:SetAttacker(owner)
        dmg:SetInflictor(self)
        dmg:SetDamageType(DMG_SLASH)

        if IsValid(ent) then
            if ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot() then
                dmg:SetDamageForce(owner:GetAimVector() * self.HitForceScale * phys_pushscale:GetFloat())
                owner:EmitSound("npc/fast_zombie/claw_strike" .. math.random(1, 3) .. ".wav", 65, math.random(115, 120), 0.8)
                self:OnBite(ent)
            end

            ent:TakeDamageInfo(dmg)

            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:ApplyForceOffset(owner:GetAimVector() * self.HitForce * phys:GetMass() * phys_pushscale:GetFloat(), tr.HitPos)
            end
        end
    end

    owner:LagCompensation(false)
end

function SWEP:PrimaryAttack()
    if not IsValid(self:GetOwner()) or not IsValid(self) then return end
    if not IsFirstTimePredicted() then return end

    local owner = self:GetOwner()

    owner:ViewPunch(Angle(math.random(3, 7), math.random(-2, 2), 0))
    owner:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)
    owner:EmitSound(self.HitSound)

    if SERVER then
      owner:LagCompensation(true)

      local tr = util.TraceHull({
          start  = owner:GetShootPos(),
          endpos = owner:GetShootPos() + owner:GetAimVector() * self.HitRange,
          filter = owner,
          mins   = self.HitSize.Min,
          maxs   = self.HitSize.Max,
          mask   = MASK_SHOT_HULL
      })

      local ent = tr.Entity

      if IsValid(ent) then
          print("[SCP3199] Hit entity:", ent, ent:GetClass(), ent:GetModel())
        end

      if IsValid(ent) and self:IsDoor(ent) then
          if math.Rand(0, 1) < 0.5 then
            DeepSCP_DestroyDoor(ent, owner, self)
          end
        end

      owner:LagCompensation(false)
    end
    -- Normal bite damage
    self:SCP3199Bite()
    self:SetNextPrimaryFire(CurTime() + self.HitCooldown)
end

function SWEP:SCP3199Spit()
    if not SERVER then return end

    local owner    = self:GetOwner()
    if not IsValid(owner) then return end

    local spitball = ents.Create("scp3199_spitball")
    if not IsValid(spitball) then return end

    spitball:SetModel("models/grub_nugget_large.mdl")
    spitball:SetPos(owner:EyePos() + owner:GetAimVector())
    spitball:SetAngles(owner:EyeAngles())
    spitball:SetOwner(owner)
    spitball:Spawn()

    local phys = spitball:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:ApplyForceCenter(owner:GetAimVector() * self.SpitForce + VectorRand() * self.SpitAccuracy)
    end
end

function SWEP:SecondaryAttack()
    if not IsValid(self:GetOwner()) or not IsValid(self) then return end
    if not IsFirstTimePredicted() then return end

    local owner = self:GetOwner()
    owner:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)

    if not SERVER then return end

    owner:EmitSound(self.SpitSound)
    owner:ViewPunch(Angle(math.random(-8, -12), 0, 0))
    self:SCP3199Spit()
    self:SetNextSecondaryFire(CurTime() + self.SpitCooldown)
    self:SetNextPrimaryFire(CurTime() + self.HitCooldown)
end

function SWEP:SCP3199Roar()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    owner:DoAnimationEvent(ACT_GMOD_TAUNT_LAUGH)
    owner:ViewPunch(Angle(math.random(-1.5, -2), 0, 0))
    owner:EmitSound(self.RoarSound)
    owner:SetInSCP3199Taunt(true)
    owner.IsSCREAMING  = true 
    self.NextRoar      = CurTime() + self.RoarCooldown

    timer.Simple(self.RoarFreezeTime, function()
        if IsValid(owner) then
            owner:ViewPunch(Angle(math.random(1, 2), 0, 0))
            owner.IsSCREAMING = false
            owner:SetInSCP3199Taunt(false)
        end
    end)
end

function SWEP:Reload()
    if not IsValid(self:GetOwner()) or not IsValid(self) then return end
    if not IsFirstTimePredicted() then return end
    if CurTime() < (self.NextRoar or 0) then return end

    self:SCP3199Roar()
end

function SWEP:Holster()
    local owner = self:GetOwner()
    if SERVER and IsValid(owner) then
        if owner.IsSCREAMING then 
            return false
        end
    end
    return true
end

----------------------------------------------------------------------------------------------------

local function SCP3199OnKillEffect(attacker)
    if math.random(0, 1) == 1 then
        timer.Simple(0.2, function()
            if IsValid(attacker) and attacker:Alive() then
                attacker:EmitSound("SCP3199.Idle")
            end
        end)
    end
end

hook.Add("OnNPCKilled", "SCP3199_Cheer", function(npc, attacker, inflictor)
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if not IsValid(inflictor) or inflictor:GetClass() ~= "scp3199swep" then return end
    SCP3199OnKillEffect(attacker)
end)

hook.Add("PlayerDeath", "SCP3199_Cheer", function(victim, inflictor, attacker)
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if not IsValid(inflictor) or inflictor:GetClass() ~= "scp3199swep" then return end
    SCP3199OnKillEffect(attacker)
end)
