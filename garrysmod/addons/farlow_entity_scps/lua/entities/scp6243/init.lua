-- scp6243_dg/init.lua
-- Server logic for SCP-6243-DG

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("SCP6243_FlipFX")
util.AddNetworkString("SCP6243_ApplyEffect")
util.AddNetworkString("SCP6243_ClearEffect")

local function TimerName(ent, ply, suffix)
    return "SCP6243_" .. tostring(ent:EntIndex()) .. "_" .. ply:SteamID():gsub(":", "_") .. "_" .. suffix
end

function ENT:Initialize()
    self:SetModel(self.Model or "models/custom/coin.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self:SetUseType(SIMPLE_USE)
    self.playerCooldowns = {}
    self.activeTimers = {} -- map sid -> {timerNames...}
    self._igniteTicks = {}
end

local function AddActiveTimer(ent, sid, name)
    ent.activeTimers = ent.activeTimers or {}
    ent.activeTimers[sid] = ent.activeTimers[sid] or {}
    table.insert(ent.activeTimers[sid], name)
end

local function RemoveActiveTimers(ent, sid)
    if not ent.activeTimers or not ent.activeTimers[sid] then return end
    for _, t in ipairs(ent.activeTimers[sid]) do
        if timer.Exists(t) then timer.Remove(t) end
    end
    ent.activeTimers[sid] = nil
end

local function ApplyUpwardFlip(ent)
    local phys = ent:GetPhysicsObject()
    if not IsValid(phys) then return end
    phys:ApplyForceCenter(Vector(0, 0, ent.Config.flipUpForce) * phys:GetMass())
    phys:AddAngleVelocity(ent.Config.flipSpin)
end

local function DoPropSpin(ent, duration)
    local phys = ent:GetPhysicsObject()
    if not IsValid(phys) then return end
    phys:AddAngleVelocity(Vector(0, 0, 2500))
    local tname = "SCP6243_propspin_" .. tostring(ent:EntIndex())
    if timer.Exists(tname) then timer.Remove(tname) end
    timer.Create(tname, duration, 1, function()
        if not IsValid(ent) then return end
        local p = ent:GetPhysicsObject()
        if IsValid(p) then p:SetAngleVelocityInstant(Vector(0,0,0)) end
    end)
end

local function DoExplosion(ent)
    local pos = ent:GetPos()
    local ex = ent.Config.explosion
    local effectdata = EffectData()
    effectdata:SetOrigin(pos)
    util.Effect(ex.effectName, effectdata, true, true)
    util.BlastDamage(ent, ent, pos, ex.radius, ex.damage)
end

local function DoIgnite(ent)
    local ign = ent.Config.ignite
    ent:Ignite(ign.duration, 0)
    local tickName = "SCP6243_ignite_tick_" .. tostring(ent:EntIndex())
    if timer.Exists(tickName) then timer.Remove(tickName) end
    timer.Create(tickName, 1, ign.duration, function()
        if not IsValid(ent) then timer.Remove(tickName) return end
        local pos = ent:GetPos()
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:Alive() and ply:GetPos():Distance(pos) <= 80 then
                local dmg = DamageInfo()
                dmg:SetDamage(ign.damagePerSecond)
                dmg:SetAttacker(ent)
                dmg:SetInflictor(ent)
                dmg:SetDamageType(DMG_BURN)
                ply:TakeDamageInfo(dmg)
            end
        end
    end)
    ent._igniteTicks = ent._igniteTicks or {}
    ent._igniteTicks[tickName] = true
end

local function TeleportPlayerRandom(ply, ent)
    if not IsValid(ply) or not IsValid(ent) then return false end
    local base = ent:GetPos()
    local radius = 400
    local tries = 12
    for i=1,tries do
        local offset = VectorRand() * math.Rand(80, radius)
        local dest = base + offset
        local tr = util.TraceHull({
            start = dest + Vector(0,0,50),
            endpos = dest,
            mins = ply:OBBMins(),
            maxs = ply:OBBMaxs(),
            filter = ply
        })
        if not tr.Hit then
            ply:SetPos(dest)
            return true
        end
    end
    ply:SetPos(ply:GetPos() + Vector(0,0,50))
    return false
end

local function MakePlayerInvisible(ply, duration)
    if not IsValid(ply) then return end
    ply:SetNoDraw(true)
    ply:SetNotSolid(true)
    local name = "SCP6243_invis_" .. tostring(ply:SteamID()):gsub(":", "_")
    if timer.Exists(name) then timer.Remove(name) end
    timer.Create(name, duration, 1, function()
        if IsValid(ply) then
            ply:SetNoDraw(false)
            ply:SetNotSolid(false)
        end
    end)
end

local function SetPlayerGravity(ply, grav, duration)
    if not IsValid(ply) then return end
    local old = ply:GetGravity()
    ply:SetGravity(grav)
    local name = "SCP6243_grav_" .. tostring(ply:SteamID()):gsub(":", "_")
    if timer.Exists(name) then timer.Remove(name) end
    timer.Create(name, duration, 1, function()
        if IsValid(ply) then ply:SetGravity(old) end
    end)
end

local function SpawnFriendlyNPC(ent)
    local cfg = ent.Config.npc
    local pos = ent:GetPos() + ent:GetForward() * cfg.distance + Vector(0,0,10)
    local npc = ents.Create(cfg.class)
    if not IsValid(npc) then return end
    npc:SetPos(pos)
    npc:Spawn()
    npc:SetKeyValue("citizentype", "3")
    npc:SetOwner(ent)
end

local function GiveWeaponToPlayer(ply, wep)
    if not IsValid(ply) then return end
    if not wep or wep == "" then return end
    ply:Give(wep)
end

local function RapidHeal(ply, amountPerSecond, duration)
    if not IsValid(ply) then return end
    local tickName = "SCP6243_heal_" .. tostring(ply:SteamID()):gsub(":", "_")
    if timer.Exists(tickName) then timer.Remove(tickName) end
    timer.Create(tickName, 1, duration, function()
        if not IsValid(ply) or not ply:Alive() then timer.Remove(tickName) return end
        ply:SetHealth(math.min(ply:GetMaxHealth(), ply:Health() + amountPerSecond))
    end)
end

local function PoisonPlayer(ent, ply, dps, duration)
    if not IsValid(ply) or not IsValid(ent) then return end
    local tickName = "SCP6243_poison_" .. tostring(ent:EntIndex()) .. "_" .. tostring(ply:SteamID()):gsub(":", "_")
    if timer.Exists(tickName) then timer.Remove(tickName) end
    timer.Create(tickName, 1, duration, function()
        if not IsValid(ply) or not ply:Alive() then timer.Remove(tickName) return end
        local dmg = DamageInfo()
        dmg:SetDamage(dps)
        dmg:SetAttacker(ent)
        dmg:SetInflictor(ent)
        dmg:SetDamageType(DMG_GENERIC)
        ply:TakeDamageInfo(dmg)
    end)
end

local function ShrinkPlayer(ply, minScale, duration)
    if not IsValid(ply) then return end
    if ply.SetModelScale then
        local orig = (ply.GetModelScale and ply:GetModelScale()) or 1
        ply:SetModelScale(minScale, 0)
        local name = "SCP6243_shrink_" .. tostring(ply:SteamID()):gsub(":", "_")
        if timer.Exists(name) then timer.Remove(name) end
        timer.Create(name, duration, 1, function()
            if IsValid(ply) and ply.SetModelScale then
                ply:SetModelScale(orig, 0)
            end
        end)
    end
end

local function ForcePush(ent)
    local pos = ent:GetPos()
    for _, v in ipairs(ents.FindInSphere(pos, 300)) do
        if v == ent then continue end
        local phys = v:GetPhysicsObject()
        if IsValid(phys) then
            local dir = (v:GetPos() - pos):GetNormalized()
            phys:ApplyForceCenter(dir * 60000)
        elseif v:IsPlayer() and v:Alive() then
            v:SetVelocity((v:GetPos() - pos):GetNormalized() * 400)
        end
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    local sid = activator:SteamID()
    local now = CurTime()
    if self.playerCooldowns[sid] and self.playerCooldowns[sid] > now then
        activator:ChatPrint("It needs a moment before it can be used again.")
        return
    end

    ApplyUpwardFlip(self)
    net.Start("SCP6243_FlipFX")
    net.Send(activator)

    local effectID = math.random(1, self.Config.effectCount)
    local duration = self.Config.effectDuration

    net.Start("SCP6243_ApplyEffect")
    net.WriteInt(effectID, 8)
    net.WriteInt(duration, 16)
    net.Send(activator)

    activator:ChatPrint(self.Config.effectMessages[effectID] or "Something happens.")

    RemoveActiveTimers(self, sid)

    if effectID == 1 then
        DoPropSpin(self, duration)

    elseif effectID == 2 then
        timer.Simple(0.6, function()
            if not IsValid(self) then return end
            DoExplosion(self)
        end)

    elseif effectID == 3 then
        DoIgnite(self)

    elseif effectID == 4 then
        TeleportPlayerRandom(activator, self)

    elseif effectID == 5 then
        MakePlayerInvisible(activator, duration)

    elseif effectID == 6 then
        SetPlayerGravity(activator, 0.35, duration)

    elseif effectID == 7 then
        SpawnFriendlyNPC(self)

    elseif effectID == 8 then
        GiveWeaponToPlayer(activator, self.Config.giveWeapon)

    elseif effectID == 9 then
        RapidHeal(activator, self.Config.heal.amountPerSecond, self.Config.heal.duration)

    elseif effectID == 10 then
        PoisonPlayer(self, activator, self.Config.poison.damagePerSecond, self.Config.poison.duration)

    elseif effectID == 11 then
        ShrinkPlayer(activator, self.Config.shrink.minScale, self.Config.shrink.duration)

    elseif effectID == 12 then
        ForcePush(self)
    end

    local cleanupName = TimerName(self, activator, "cleanup")
    if timer.Exists(cleanupName) then timer.Remove(cleanupName) end
    timer.Create(cleanupName, duration, 1, function()
        if IsValid(activator) then
            net.Start("SCP6243_ClearEffect")
            net.Send(activator)
        end
        RemoveActiveTimers(self, sid)
    end)
    AddActiveTimer(self, sid, cleanupName)

    self.playerCooldowns[sid] = CurTime() + self.Config.cooldown
end

function ENT:OnRemove()
    for sid, tlist in pairs(self.activeTimers or {}) do
        for _, tname in ipairs(tlist) do
            if timer.Exists(tname) then timer.Remove(tname) end
        end
    end
    if self._igniteTicks then
        for tname, _ in pairs(self._igniteTicks) do
            if timer.Exists(tname) then timer.Remove(tname) end
        end
    end
    self.activeTimers = {}
    self.playerCooldowns = {}
end

hook.Add("PlayerDeath", "SCP6243_ClearOnDeath", function(ply)
    local entList = ents.FindByClass("scp6243_dg")
    for _, ent in ipairs(entList) do
        if not IsValid(ent) then continue end
        local sid = ply:SteamID()
        local cleanupName = "SCP6243_" .. tostring(ent:EntIndex()) .. "_" .. sid:gsub(":", "_") .. "_cleanup"
        if timer.Exists(cleanupName) then timer.Remove(cleanupName) end
        net.Start("SCP6243_ClearEffect")
        net.Send(ply)
        RemoveActiveTimers(ent, sid)
    end
end)

hook.Add("PlayerDisconnected", "SCP6243_ClearOnDisconnect", function(ply)
    local entList = ents.FindByClass("scp6243_dg")
    for _, ent in ipairs(entList) do
        if not IsValid(ent) then continue end
        local sid = ply:SteamID()
        local cleanupName = "SCP6243_" .. tostring(ent:EntIndex()) .. "_" .. sid:gsub(":", "_") .. "_cleanup"
        if timer.Exists(cleanupName) then timer.Remove(cleanupName) end
        net.Start("SCP6243_ClearEffect")
        net.Send(ply)
        RemoveActiveTimers(ent, sid)
    end
end)