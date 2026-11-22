if SERVER then
    AddCSLuaFile()
    AddCSLuaFile("autorun/sh_scprp_457_config.lua")
end

SCP457 = SCP457 or {}
SCP457.Config = SCP457.Config or {}

local C = SCP457.Config

SWEP.PrintName = "SCP-457"
SWEP.Author = "SCP-RP"
SWEP.Purpose = "Ignite personnel within SCP-457's thermal aura."
SWEP.Instructions = "Left click or reload to toggle the thermal aura."
SWEP.Category = "SCP-RP"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = ""
SWEP.ViewModelFOV = 54
SWEP.UseHands = true
SWEP.HoldType = "normal"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

local function configNumber(name, fallback, minimum)
    local value = tonumber(C[name]) or fallback
    return math.max(minimum or 0, value)
end

local function jobData(ply)
    return RPExtraTeams and RPExtraTeams[ply:Team()] or nil
end

local function isImmune(ent)
    if not IsValid(ent) then return true end

    local model = string.lower(ent:GetModel() or "")
    for immuneModel in pairs(C.ImmuneModels or {}) do
        if model == string.lower(immuneModel) then return true end
    end

    if not ent:IsPlayer() then return false end

    local data = jobData(ent)
    local jobName = data and data.name or team.GetName(ent:Team())
    local category = data and data.category or nil

    if C.ImmuneJobs and C.ImmuneJobs[jobName] then return true end
    if category and C.ImmuneCategories and C.ImmuneCategories[category] then return true end

    return false
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "AuraEnabled")
    self:NetworkVar("Float", 0, "NextAuraScan")
    self:NetworkVar("Float", 1, "NextAuraToggle")
    self:NetworkVar("Float", 2, "NextGrowthUpdate")
    self:NetworkVar("Float", 3, "Current457Scale")
    self:NetworkVar("Int", 0, "NearbyPlayerCount")
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)

    if SERVER then
        self:SetAuraEnabled(C.StartEnabled ~= false)
        self:SetNextAuraScan(0)
        self:SetNextAuraToggle(0)
        self:SetNextGrowthUpdate(0)
        self:SetCurrent457Scale(configNumber("BaseModelScale", 1, 0.1))
        self:SetNearbyPlayerCount(0)
    end
end

function SWEP:RememberOwnerScale(owner)
    if CLIENT or not IsValid(owner) then return end
    if self.SCP457ScaleOwner == owner then return end

    self:RestoreOwnerScale()
    self.SCP457ScaleOwner = owner
    self.SCP457OriginalScale = owner:GetModelScale()
end

function SWEP:RestoreOwnerScale()
    if CLIENT then return end

    local owner = self.SCP457ScaleOwner
    if IsValid(owner) then
        owner:SetModelScale(self.SCP457OriginalScale or 1, configNumber("GrowthTransitionTime", 0.45, 0))
    end

    self.SCP457ScaleOwner = nil
    self.SCP457OriginalScale = nil
    self:SetNearbyPlayerCount(0)
end

function SWEP:Deploy()
    self:SetHoldType(self.HoldType)

    if SERVER then
        self:RememberOwnerScale(self:GetOwner())
        self:SetAuraEnabled(C.StartEnabled ~= false)
        self:SetNextAuraScan(CurTime())
        self:SetNextGrowthUpdate(CurTime())
    end

    return true
end

function SWEP:Holster()
    if SERVER then
        self:SetAuraEnabled(false)
        self:RestoreOwnerScale()
    end
    return true
end

function SWEP:OnRemove()
    if SERVER then
        self:SetAuraEnabled(false)
        self:RestoreOwnerScale()
    end
end

function SWEP:OwnerChanged()
    if SERVER then
        self:RestoreOwnerScale()
        self:SetAuraEnabled(false)
        self:SetNextAuraScan(0)
        self:SetNextGrowthUpdate(0)
    end
end

function SWEP:CanAffect(ent, owner, radiusSqr)
    if not IsValid(ent) or ent == owner then return false end

    if ent:IsPlayer() then
        if not C.IgnitePlayers then return false end
        if C.IgnoreDeadPlayers ~= false and not ent:Alive() then return false end
    elseif ent:IsNPC() or ent:IsNextBot() then
        if not C.IgniteNPCs then return false end
    else
        return false
    end

    if isImmune(ent) then return false end
    if owner:GetPos():DistToSqr(ent:GetPos()) > radiusSqr then return false end

    if C.RequireLineOfSight then
        local trace = util.TraceLine({
            start = owner:WorldSpaceCenter(),
            endpos = ent:WorldSpaceCenter(),
            filter = { owner, self },
            mask = MASK_SOLID
        })

        if trace.Hit and trace.Entity ~= ent then return false end
    end

    return true
end

function SWEP:ApplyAura()
    if CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() or not owner:Alive() then return end
    if owner:GetActiveWeapon() ~= self or not self:GetAuraEnabled() then return end

    local radius = configNumber("Radius", 225, 1)
    local damageAmount = configNumber("DamagePerTick", 2, 0)
    local igniteDuration = configNumber("IgniteDuration", 1.25, 0.1)

    for _, ent in ipairs(ents.FindInSphere(owner:GetPos(), radius)) do
        if not self:CanAffect(ent, owner, radius * radius) then continue end

        if damageAmount > 0 then
            local damage = DamageInfo()
            damage:SetAttacker(owner)
            damage:SetInflictor(self)
            damage:SetDamage(damageAmount)
            damage:SetDamageType(DMG_BURN)
            damage:SetDamagePosition(ent:WorldSpaceCenter())
            ent:TakeDamageInfo(damage)
        end

        if IsValid(ent) then ent:Ignite(igniteDuration, 0) end
    end
end

function SWEP:UpdatePlayerGrowth()
    if CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() or not owner:Alive() then
        self:RestoreOwnerScale()
        return
    end

    self:RememberOwnerScale(owner)

    if C.EnablePlayerGrowth == false or not self:GetAuraEnabled() then
        local disabledScale = configNumber("BaseModelScale", 1, 0.1)
        owner:SetModelScale(disabledScale, configNumber("GrowthTransitionTime", 0.45, 0))
        self:SetCurrent457Scale(disabledScale)
        self:SetNearbyPlayerCount(0)
        return
    end

    local radius = configNumber("GrowthRadius", 500, 1)
    local count = 0

    for _, ent in ipairs(ents.FindInSphere(owner:GetPos(), radius)) do
        if IsValid(ent) and ent:IsPlayer() and ent ~= owner and ent:Alive() then
            count = count + 1
        end
    end

    local baseScale = configNumber("BaseModelScale", 1, 0.1)
    local maximumScale = math.max(baseScale, configNumber("MaximumModelScale", 1.65, 0.1))
    local targetScale = math.Clamp(
        baseScale + count * configNumber("ScalePerPlayer", 0.08, 0),
        baseScale,
        maximumScale
    )

    self:SetNearbyPlayerCount(count)

    if math.abs(self:GetCurrent457Scale() - targetScale) >= 0.005 then
        self:SetCurrent457Scale(targetScale)
        owner:SetModelScale(targetScale, configNumber("GrowthTransitionTime", 0.45, 0))
    end
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if CLIENT then
        if self:GetAuraEnabled() and owner:GetActiveWeapon() == self then
            local light = DynamicLight(self:EntIndex())
            if light then
                light.pos = owner:WorldSpaceCenter()
                light.r = 255
                light.g = 95
                light.b = 20
                light.brightness = 2
                light.decay = 700
                light.size = math.min(configNumber("Radius", 225, 1), 420)
                light.dietime = CurTime() + 0.2
            end
        end
        return
    end

    if owner:GetActiveWeapon() == self and CurTime() >= self:GetNextGrowthUpdate() then
        self:SetNextGrowthUpdate(CurTime() + configNumber("GrowthUpdateInterval", 0.5, 0.1))
        self:UpdatePlayerGrowth()
    end

    if not self:GetAuraEnabled() or owner:GetActiveWeapon() ~= self then return end
    if CurTime() < self:GetNextAuraScan() then return end

    self:SetNextAuraScan(CurTime() + configNumber("ScanInterval", 0.35, 0.1))
    self:ApplyAura()
end

function SWEP:ToggleAura()
    if CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) or CurTime() < self:GetNextAuraToggle() then return end

    self:SetNextAuraToggle(CurTime() + configNumber("ToggleCooldown", 1, 0.1))
    self:SetAuraEnabled(not self:GetAuraEnabled())
    self:SetNextAuraScan(CurTime())

    local soundName = self:GetAuraEnabled() and C.ToggleOnSound or C.ToggleOffSound
    if isstring(soundName) and soundName ~= "" then owner:EmitSound(soundName, 70, 100, 0.8) end
end

function SWEP:SuppressWithExtinguishers()
    if CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() or not owner:Alive() then return end

    local baseScale = configNumber("BaseModelScale", 1, 0.1)
    self:SetAuraEnabled(false)
    self:SetNextAuraScan(0)
    self:SetCurrent457Scale(baseScale)
    self:SetNearbyPlayerCount(0)

    owner:Extinguish()
    owner:SetModelScale(baseScale, configNumber("GrowthTransitionTime", 0.45, 0))

    local soundName = C.ExtinguisherSuccessSound
    if isstring(soundName) and soundName ~= "" then
        owner:EmitSound(soundName, 75, 90, 0.9)
    end

    owner:ChatPrint("Two fire suppression units have extinguished your thermal aura.")
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + configNumber("ToggleCooldown", 1, 0.1))
    if IsFirstTimePredicted() then self:ToggleAura() end
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
    if not IsFirstTimePredicted() then return end
    self:ToggleAura()
end

if SERVER then
    local function isActivelySprayingAt(sprayer, target)
        if not IsValid(sprayer) or not sprayer:IsPlayer() or not sprayer:Alive() then return false end
        if sprayer == target or not sprayer:KeyDown(IN_ATTACK) then return false end

        local weapon = sprayer:GetActiveWeapon()
        if not IsValid(weapon) or weapon:GetClass() ~= (C.ExtinguisherWeaponClass or "weapon_extinguisher") then
            return false
        end

        local maximumRange = configNumber("ExtinguisherMaximumRange", 300, 1)
        local targetPosition = target:WorldSpaceCenter()
        local offset = targetPosition - sprayer:GetShootPos()
        local distance = offset:Length()
        if distance > maximumRange or distance <= 0 then return false end

        local trace = util.TraceLine({
            start = sprayer:GetShootPos(),
            endpos = targetPosition,
            filter = sprayer,
            mask = MASK_SHOT
        })

        if trace.Hit and trace.Entity ~= target then return false end

        local aimTolerance = math.Clamp(tonumber(C.ExtinguisherAimTolerance) or 0.92, -1, 1)
        return sprayer:GetAimVector():Dot(offset / distance) >= aimTolerance
    end

    local function activeSprayers(target, required)
        local sprayers = {}

        for _, ply in ipairs(player.GetAll()) do
            if isActivelySprayingAt(ply, target) then
                sprayers[#sprayers + 1] = ply
                if #sprayers >= required then break end
            end
        end

        return sprayers
    end

    local function trySuppress457(target)
        if not IsValid(target) or not target:IsPlayer() or not target:Alive() then return false end

        local weapon = target:GetWeapon("weapon_scprp_457")
        if not IsValid(weapon) or target:GetActiveWeapon() ~= weapon then return false end

        local baseScale = configNumber("BaseModelScale", 1, 0.1)
        if not weapon:GetAuraEnabled() and weapon:GetCurrent457Scale() <= baseScale + 0.005 then
            return false
        end

        local required = math.max(2, math.floor(tonumber(C.ExtinguishersRequired) or 2))
        local sprayers = activeSprayers(target, required)
        if #sprayers < required then return false end

        weapon:SuppressWithExtinguishers()

        for _, sprayer in ipairs(sprayers) do
            if IsValid(sprayer) then
                sprayer:ChatPrint("SCP-457's thermal aura has been suppressed.")
            end
        end

        return true
    end

    hook.Add("ExtinguisherDoExtinguish", "SCP457_TwoPersonSuppression", function(target)
        if trySuppress457(target) then return true end
    end)

    -- Some legacy SCP-457 addons return a value from the extinguisher hook for
    -- every target, which can stop other hook handlers from running. This small
    -- fallback checks only active SCP-457 users and keeps compatibility intact.
    hook.Add("Think", "SCP457_TwoPersonSuppressionFallback", function()
        for _, target in ipairs(player.GetAll()) do
            local weapon = target:GetActiveWeapon()
            if not IsValid(weapon) or weapon:GetClass() ~= "weapon_scprp_457" then continue end
            if (weapon.SCP457NextSuppressionCheck or 0) > CurTime() then continue end

            weapon.SCP457NextSuppressionCheck = CurTime() + 0.1
            trySuppress457(target)
        end
    end)
end

function SWEP:DrawWorldModel()
end

if CLIENT then
    surface.CreateFont("SCP457_AuraTitle", {
        font = "Roboto",
        size = 24,
        weight = 900,
        extended = true
    })

    surface.CreateFont("SCP457_AuraBody", {
        font = "Roboto",
        size = 17,
        weight = 600,
        extended = true
    })

    function SWEP:DrawHUD()
        if C.ShowHUD == false then return end

        local enabled = self:GetAuraEnabled()
        local width, height = 280, 62
        local x, y = ScrW() / 2 - width / 2, ScrH() - 115
        local accent = enabled and Color(245, 90, 25) or Color(110, 115, 125)

        draw.RoundedBox(8, x, y, width, height, Color(10, 12, 16, 225))
        draw.RoundedBox(8, x, y, 5, height, accent)
        draw.SimpleText("SCP-457 THERMAL AURA", "SCP457_AuraTitle", x + 18, y + 10, color_white)
        draw.SimpleText(
            enabled and "ACTIVE  |  LMB / RELOAD TO DISABLE" or "DORMANT  |  LMB / RELOAD TO ENABLE",
            "SCP457_AuraBody",
            x + 18,
            y + 39,
            accent
        )

        if C.EnablePlayerGrowth ~= false then
            draw.SimpleText(
                string.format("MASS x%.2f  |  %d NEARBY", self:GetCurrent457Scale(), self:GetNearbyPlayerCount()),
                "SCP457_AuraBody",
                x + width - 12,
                y - 7,
                Color(255, 175, 90),
                TEXT_ALIGN_RIGHT,
                TEXT_ALIGN_BOTTOM
            )
        end
    end
end
