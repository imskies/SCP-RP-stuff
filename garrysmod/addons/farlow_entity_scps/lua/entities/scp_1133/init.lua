AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

util.AddNetworkString("scp1133_Chat")
util.AddNetworkString("scp1133_OpenMenu")
util.AddNetworkString("scp1133_ApplyChoice")
util.AddNetworkString("scp1133_Effect")
util.AddNetworkString("scp1133_Status")

function ENT:Initialize()
    self:SetModel("models/props_unique/hospital/iv_pole.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self.LastUseBy      = {}
    self.UseCooldown    = self.UseCooldown or 3
    self.EffectDuration = self.EffectDuration or 30 -- CHANGED FROM 10 → 30
end

local function say(ent, ply, msg)
    if not IsValid(ply) then return end
    net.Start("scp1133_Chat")
        net.WriteEntity(ent)
        net.WriteString(msg or "")
    net.Send(ply)
end

local function canUse(ent, ply)
    local sid  = ply:SteamID()
    local now  = CurTime()
    local last = ent.LastUseBy[sid] or 0
    if now - last < ent.UseCooldown then return false end
    ent.LastUseBy[sid] = now
    return true
end

local function adjustSpeed(ply, factor, dur)
    if not IsValid(ply) then return end
    local ws, rs = ply:GetWalkSpeed(), ply:GetRunSpeed()
    ply:SetWalkSpeed(ws * factor)
    ply:SetRunSpeed(rs * factor)

    local id = "scp1133_speedreset_" .. ply:SteamID64()
    timer.Create(id, dur, 1, function()
        if not IsValid(ply) or not ply:Alive() then return end
        ply:SetWalkSpeed(ws)
        ply:SetRunSpeed(rs)
    end)
end

local function adjustHealthTemp(ply, delta, dur)
    if not IsValid(ply) then return end
    ply:SetHealth(math.max(ply:Health() + delta, 1))

    local id = "scp1133_healthreset_" .. ply:SteamID64()
    timer.Create(id, dur, 1, function()
        if not IsValid(ply) or not ply:Alive() then return end
        ply:SetHealth(math.max(ply:Health() - delta, 1))
    end)
end

local sins = {
    Pride = {
        infuse = function(ent, ply)
            say(ent, ply, "You feel overwhelming pride.")
            adjustSpeed(ply, 1.2, ent.EffectDuration)
            net.Start("scp1133_Effect")
                net.WriteString("PrideInfuse")
                net.WriteFloat(ent.EffectDuration)
            net.Send(ply)
        end,
        extract = function(ent, ply)
            say(ent, ply, "Your pride is drained.")
            adjustSpeed(ply, 0.85, ent.EffectDuration)
            net.Start("scp1133_Effect")
                net.WriteString("PrideExtract")
                net.WriteFloat(ent.EffectDuration)
            net.Send(ply)
        end
    },
    Greed = {
        infuse = function(ent, ply)
            say(ent, ply, "Greed fills your veins.")
            adjustHealthTemp(ply, 20, ent.EffectDuration)
            net.Start("scp1133_Effect")
                net.WriteString("GreedInfuse")
                net.WriteFloat(ent.EffectDuration)
            net.Send(ply)
        end,
        extract = function(ent, ply)
            say(ent, ply, "Greed is siphoned away.")
            adjustHealthTemp(ply, -10, ent.EffectDuration)
            net.Start("scp1133_Effect")
                net.WriteString("GreedExtract")
                net.WriteFloat(ent.EffectDuration)
            net.Send(ply)
        end
    },
    Lust = {
        infuse = function(ent, ply)
            say(ent, ply, "A strange desire overwhelms you.")
            adjustSpeed(ply, 1.1, ent.EffectDuration)
            net.Start("scp1133_Effect")
                net.WriteString("LustInfuse")
                net.WriteFloat(ent.EffectDuration)
            net.Send(ply)
        end,
        extract = function(ent, ply)
            say(ent, ply, "Your desire fades.")
            adjustSpeed(ply, 0.9, ent.EffectDuration)
            net.Start("scp1133_Effect")
                net.WriteString("LustExtract")
                net.WriteFloat(ent.EffectDuration)
            net.Send(ply)
        end
    },
    Envy = {
        infuse = function(ent, ply)
            say(ent, ply, "Envy sharpens your senses.")
            adjustSpeed(ply, 1.05, ent.EffectDuration)
            net.Start("scp1133_Effect")
                net.WriteString("EnvyInfuse")
                net.WriteFloat(ent.EffectDuration)
            net.Send(ply)
        end,
        extract = function(ent, ply)
            say(ent, ply, "Envy drains away.")
            adjustSpeed(ply, 0.95, ent.EffectDuration)
            net.Start("scp1133_Effect")
                net.WriteString("EnvyExtract")
                net.WriteFloat(ent.EffectDuration)
            net.Send(ply)
        end
    },
    Gluttony = {
        infuse = function(ent, ply)
            say(ent, ply, "You feel bloated with excess.")
            adjustHealthTemp(ply, 15, ent.EffectDuration)
            net.Start("scp1133_Effect")
                net.WriteString("GluttonyInfuse")
                net.WriteFloat(ent.EffectDuration)
            net.Send(ply)
        end,
        extract = function(ent, ply)
            say(ent, ply, "Your excess is purged.")
            adjustHealthTemp(ply, -5, ent.EffectDuration)
            net.Start("scp1133_Effect")
                net.WriteString("GluttonyExtract")
                net.WriteFloat(ent.EffectDuration)
            net.Send(ply)
        end
    },
    Wrath = {
        infuse = function(ent, ply)
            say(ent, ply, "Wrath surges through you.")
            adjustSpeed(ply, 1.3, ent.EffectDuration)
            net.Start("scp1133_Effect")
                net.WriteString("WrathInfuse")
                net.WriteFloat(ent.EffectDuration)
            net.Send(ply)
        end,
        extract = function(ent, ply)
            say(ent, ply, "Wrath subsides.")
            adjustSpeed(ply, 0.8, ent.EffectDuration)
            net.Start("scp1133_Effect")
                net.WriteString("WrathExtract")
                net.WriteFloat(ent.EffectDuration)
            net.Send(ply)
        end
    },
    Sloth = {
        infuse = function(ent, ply)
            say(ent, ply, "Sloth slows your body.")
            adjustSpeed(ply, 0.7, ent.EffectDuration)
            net.Start("scp1133_Effect")
                net.WriteString("SlothInfuse")
                net.WriteFloat(ent.EffectDuration)
            net.Send(ply)
        end,
        extract = function(ent, ply)
            say(ent, ply, "Sloth is lifted.")
            adjustSpeed(ply, 1.1, ent.EffectDuration)
            net.Start("scp1133_Effect")
                net.WriteString("SlothExtract")
                net.WriteFloat(ent.EffectDuration)
            net.Send(ply)
        end
    }
}

local sinNames = {}
for name in pairs(sins) do
    table.insert(sinNames, name)
end

math.randomseed(os.time())
local function pickSin()
    local name = sinNames[math.random(#sinNames)]
    return name, sins[name]
end

local function sendStatus(ply, active, sinName, stacks, dur)
    net.Start("scp1133_Status")
        net.WriteBool(active or false)
        if active then
            net.WriteString(sinName or "")
            net.WriteUInt(stacks or 1, 3)
            net.WriteFloat(dur or 0)
        end
    net.Send(ply)
end

net.Receive("scp1133_ApplyChoice", function(_, ply)
    local ent    = net.ReadEntity()
    local choice = net.ReadString()

    if not IsValid(ent) or ent:GetClass() ~= "scp_1133" then return end
    if not IsValid(ply) or not ply:IsPlayer() then return end

    if not canUse(ent, ply) then
        say(ent, ply, "The IV refuses another adjustment—wait a moment.")
        return
    end

    local now = CurTime()
    ply.SCP1133Stacks = ply.SCP1133Stacks or 0
    ply.SCP1133Expire = ply.SCP1133Expire or 0

    if now > (ply.SCP1133Expire or 0) then
        ply.SCP1133Stacks = 0
    end

    -- CHANGED: Any stacking attempt during active effect kills the player
    if now <= (ply.SCP1133Expire or 0) and ply.SCP1133Stacks >= 1 then
        say(ent, ply, "Your body violently rejects the additional alteration.")
        ply:Kill()
        ply.SCP1133Stacks = 0
        ply.SCP1133Expire = 0
        sendStatus(ply, false)
        return
    end

    local sinName, sin = pickSin()
    if not sin then return end

    if choice == "Infuse" and sin.infuse then
        sin.infuse(ent, ply)
    elseif choice == "Extract" and sin.extract then
        sin.extract(ent, ply)
    else
        return
    end

    ply.SCP1133Stacks = (ply.SCP1133Stacks or 0) + 1
    ply.SCP1133Expire = now + ent.EffectDuration

    sendStatus(ply, true, sinName, ply.SCP1133Stacks, ent.EffectDuration)
end)

function ENT:Use(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    net.Start("scp1133_OpenMenu")
        net.WriteEntity(self)
    net.Send(ply)
end

local function clearBuffs(ply)
    timer.Remove("scp1133_speedreset_" .. ply:SteamID64())
    timer.Remove("scp1133_healthreset_" .. ply:SteamID64())
    if not IsValid(ply) then return end

    ply:SetWalkSpeed(200)
    ply:SetRunSpeed(400)

    ply.SCP1133Stacks = 0
    ply.SCP1133Expire = 0
    sendStatus(ply, false)
end

hook.Add("PlayerDeath", "scp1133_clearBuffs", clearBuffs)
hook.Add("PlayerSilentDeath", "scp1133_clearBuffsSilent", clearBuffs)