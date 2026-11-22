AddCSLuaFile()

SWEP.PrintName = "SCP-610"
SWEP.Author = "ynot01"
SWEP.Purpose = "Players killed with this weapon are revived and given the SCP-610 SWEP."
SWEP.Instructions = "Left click to punch. Killed players respawn with `weapon_ynot610`."
SWEP.Category = "ynot01's SWEPs"

SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = ""
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.WepSelectIcon = nil
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.RespawnTime = 60 * 3 -- How long broken doors stay broken, 60 * 3 is three minutes

SWEP.DestroySound = "physics/wood/wood_furniture_break1.wav"
SWEP.DestroyModels = {
    ["models/foundation/doors/lcz_door.mdl"] = true,
    ["models/foundation/doors/hcz_door_01.mdl"] = true,
    ["models/foundation/doors/hcz_door_02.mdl"] = true,
    ["models/foundation/containment/door01.mdl"] = true,
    ["models/novux/map/models/ez_cor_door_1.mdl"] = true,
    ["models/novux/map/models/ez_cor_door_2.mdl"] = true,
    ["models/vgis/doors/main_door.mdl"] = true,
    ["models/scp_asset_remaster/remastered_door.mdl"] = true,
    ["models/scp_asset_remaster/hcz_door_r.mdl"] = true,
    ["models/custom/br_site65/gate_01_0.mdl"] = true,
}

local FireDistance = 80
local FireDistanceSqr = FireDistance ^ 2

local function Get610PunchDamage()
    return (SCPJobsConfig and SCPJobsConfig[610] and SCPJobsConfig[610].PunchDamage) or 75
end

local function CanInfectPlayer(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    if ply.SCPNum then return false end
    if TEAM_SCP610 and ply:Team() == TEAM_SCP610 then return false end
    return true
end

function SWEP:Initialize()
    self:SetHoldType("fist")
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    local side = "fists_left"

    if math.random(1, 2) == 1 then
        side = "fists_right"
    end

    if not IsFirstTimePredicted() then
        self:DoBFSAnimation(side)
        owner:GetViewModel():SetPlaybackRate(0.5)
        return
    end

    owner:ViewPunch(Angle(0, 0, math.random(-2, 2)))
    self:DoBFSAnimation(side)
    owner:SetAnimation(PLAYER_ATTACK1)
    owner:GetViewModel():SetPlaybackRate(1)

    if SERVER then
        sound.Play("weapons/slam/throw.wav", self:GetPos(), 65, math.random(90, 110))
        owner:ViewPunch(Angle(0, 0, math.random(-2, 2)))
        timer.Simple(0.3, function()
            if IsValid(self) then
                self:PunchFunc()
            end
        end)
    end

    self:SetNextPrimaryFire(CurTime() + 0.9)
end

function SWEP:SecondaryAttack()
    return
end

function SWEP:Deploy()
    if not IsFirstTimePredicted() then
        self:DoBFSAnimation("fists_draw")
        self.Owner:GetViewModel():SetPlaybackRate(0.5)
        return
    end

    self:SetNextPrimaryFire(CurTime() + 1)
    self:DoBFSAnimation("fists_draw")
    return true
end

function SWEP:Holster()
    if not IsFirstTimePredicted() then return end
    return true
end

function SWEP:Think()
end

function SWEP:InfectPlayer(ply)
    if CLIENT then return end
    if not CanInfectPlayer(ply) then return end

    local deathPos = ply:GetPos() -- Save death position before spawning

    timer.Simple(0, function()
        if not IsValid(ply) then return end
        if ply:Alive() then return end

        ply:Spawn()

        timer.Simple(0, function()
            if not IsValid(ply) or not ply:Alive() then return end

            ply:SetPos(deathPos) -- Teleport back to where they died

            -- Set infected player model
            ply:SetModel("models/player/zombie_soldier.mdl")

            -- Strip all weapons except the 610 SWEP
            for _, wep in ipairs(ply:GetWeapons()) do
                if IsValid(wep) and wep:GetClass() ~= "weapon_ynot610" then
                    ply:StripWeapon(wep:GetClass())
                end
            end

            if not ply:HasWeapon("weapon_ynot610") then
                ply:Give("weapon_ynot610")
            end
            ply:SelectWeapon("weapon_ynot610")
        end)
    end)
end

function SWEP:PunchFunc()
    if CLIENT then return end

    local owner = self:GetOwner()
    owner:LagCompensation(true)

    local ent, hitPos = self:WhomILookinAt(owner, 0.3, 55)
    local aimVec = owner:GetAimVector()

    if IsValid(ent) or ((ent) and (ent.IsWorld) and ent:IsWorld()) then
        local selfForce, mul = 125, 1

        if self:IsEntSoft(ent) then
            selfForce = 25
            sound.Play("Flesh.ImpactHard", hitPos, 65, math.random(90, 110))
        else
            sound.Play("Flesh.ImpactSoft", hitPos, 65, math.random(90, 110))
        end

        local damageAmt = Get610PunchDamage()
        mul = math.Rand(mul * 0.9, mul * 1.1)

        if ent:IsPlayer() and (ent.SCPNum or (TEAM_SCP610 and ent:Team() == TEAM_SCP610)) then
            mul = 0
        end

        local dam = DamageInfo()
        dam:SetAttacker(owner)
        dam:SetInflictor(self.Weapon)
        dam:SetDamage(damageAmt * mul)
        dam:SetDamageForce(aimVec * mul ^ 3)
        dam:SetDamageType(DMG_CLUB)
        dam:SetDamagePosition(hitPos)
        ent:TakeDamageInfo(dam)

        if IsValid(ent) and ent:IsPlayer() and not ent:Alive() then
            self:InfectPlayer(ent)
        end

        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            if ent:IsPlayer() then
                ent:SetVelocity(aimVec * selfForce * 1.5)
            end
            phys:ApplyForceOffset(aimVec * 10 * mul, hitPos)
        end

        if self:IsDoor(ent) then
            if math.Rand(0, 1) < 0.5 then
                DeepSCP_DestroyDoor(self:GetOwner():GetPos(), self:GetOwner(), self)
            end
        end
    end

    owner:LagCompensation(false)
end

function SWEP:WhomILookinAt(ply)
    local tr = util.TraceLine({
        start = ply:GetShootPos(),
        endpos = ply:GetShootPos() + ply:GetAimVector() * 80,
        filter = ply,
        mask = MASK_SHOT_HULL
    })

    if not IsValid(tr.Entity) then
        tr = util.TraceHull({
            start = ply:GetShootPos(),
            endpos = ply:GetShootPos() + ply:GetAimVector() * 80,
            filter = ply,
            mins = Vector(-10, -10, -8),
            maxs = Vector(10, 10, 8),
            mask = MASK_SHOT_HULL
        })
    end

    if tr.Hit then return tr.Entity, tr.HitPos end
end

function SWEP:DoBFSAnimation(anim)
    local vm = self.Owner:GetViewModel()
    vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
end

function SWEP:IsEntSoft(ent)
    return (ent:IsNPC() or ent:IsPlayer())
end

function SWEP:IsDoor(ent)
    return IsValid(ent) and (ent:GetClass() == "func_door" or (ent:GetClass() == "prop_dynamic" and self.DestroyModels[ent:GetModel()]))
end