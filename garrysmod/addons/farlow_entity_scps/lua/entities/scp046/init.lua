AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Network strings for client effects/sounds
util.AddNetworkString("SCP046_InfluenceStart")
util.AddNetworkString("SCP046_InfluenceStop")
util.AddNetworkString("SCP046_Kill")

-- Configurable values
local ATTRACT_RADIUS = 140      -- distance where effect begins
local DEATH_RADIUS = 80         -- too close → lethal over time
local DAMAGE_PER_SECOND = 30    -- how fast SCP-046 kills you when very close
local PULL_FORCE = 175          -- subtle pull strength for low-health players
local MESSAGE_INTERVAL = 5      -- seconds between repeated messages (user requested 5s)

-- High-health damage: exactly 1 HP every 2 seconds
local HIGHHEALTH_DAMAGE_AMOUNT = 1      -- 1 HP
local HIGHHEALTH_DAMAGE_INTERVAL = 2.0  -- every 2 seconds

-- Crunch sound and cooldown (server-side)
local CRUNCH_SOUND = "npc/barnacle/barnacle_crunch3.wav"
local CRUNCH_COOLDOWN = 1.5 -- seconds between crunch sounds per player while in death radius

-- varied messages to send while influenced
local LIE_DOWN_MESSAGES = {
    "You want to lie down with the holly bush...",
    "The holly looks so soft... just rest here.",
    "You feel so tired. The bush will keep you safe.",
    "Everything is calm. Lie down beside the holly.",
    "You could sleep forever under the holly..."
}

function ENT:Initialize()
    -- Use the requested bush model
    self:SetModel("models/props/de_inferno/largebush06.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    
    -- No collision
    self:SetSolid(SOLID_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

    -- Disable physics motion
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end

    -- Track influenced players to avoid spamming start/stop
    self._influenced = {} -- keyed by ply:SteamID64()
end

local function StartLieDownMessages(ply)
    if not IsValid(ply) then return end
    local sid = ply:SteamID64()
    local timerName = "scp046_msg_" .. sid
    if timer.Exists(timerName) then return end

    -- Send one message immediately, then every MESSAGE_INTERVAL seconds
    local function SendRandomMessage()
        if not IsValid(ply) then
            if timer.Exists(timerName) then timer.Remove(timerName) end
            return
        end
        local msg = LIE_DOWN_MESSAGES[math.random(#LIE_DOWN_MESSAGES)]
        ply:ChatPrint(msg)
    end

    -- immediate + repeated every MESSAGE_INTERVAL
    SendRandomMessage()
    timer.Create(timerName, MESSAGE_INTERVAL, 0, SendRandomMessage)
end

local function StopLieDownMessages(ply)
    if not IsValid(ply) then return end
    local sid = ply:SteamID64()
    local timerName = "scp046_msg_" .. sid
    if timer.Exists(timerName) then
        timer.Remove(timerName)
    end
end

function ENT:Think()
    local pos = self:GetPos()

    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) then
            continue
        end

        -- clear state for dead players
        if not ply:Alive() then
            local sid = ply:SteamID64()
            if self._influenced[sid] then
                self._influenced[sid] = nil
                StopLieDownMessages(ply)
                net.Start("SCP046_InfluenceStop") net.Send(ply)
            end
            ply:SetNWBool("scp046_influence", false)
            ply._scp046_msg2 = false
            ply._scp046_highDamageAcc = nil
            ply._scp046_lastCrunch = nil
            continue
        end

        local dist = pos:Distance(ply:GetPos())
        local sid = ply:SteamID64()

        -- Attraction zone (applies to all players within radius)
        if dist <= ATTRACT_RADIUS then
            if not self._influenced[sid] then
                -- first time entering influence
                self._influenced[sid] = true
                net.Start("SCP046_InfluenceStart") net.Send(ply)

                -- initial chat messages (varying)
                ply:ChatPrint("You feel attracted to the holly bush.")
                ply:ChatPrint(LIE_DOWN_MESSAGES[math.random(#LIE_DOWN_MESSAGES)])

                -- start repeated "lie down" messages (immediate + every MESSAGE_INTERVAL)
                StartLieDownMessages(ply)
            end

            ply:SetNWBool("scp046_influence", true)

            -- If player is low health (<=50) pull them in; otherwise apply slow damage (1 HP every 2s)
            if ply:Health() <= 50 then
                -- Pull player slightly toward bush
                local dir = (pos - ply:GetPos()):GetNormalized()
                ply:SetVelocity(dir * PULL_FORCE)
            else
                -- Accumulate time and apply 1 HP every HIGHHEALTH_DAMAGE_INTERVAL seconds
                ply._scp046_highDamageAcc = (ply._scp046_highDamageAcc or 0) + FrameTime()
                while ply._scp046_highDamageAcc >= HIGHHEALTH_DAMAGE_INTERVAL do
                    ply._scp046_highDamageAcc = ply._scp046_highDamageAcc - HIGHHEALTH_DAMAGE_INTERVAL
                    -- apply exactly 1 HP damage
                    local dmg = DamageInfo()
                    dmg:SetDamage(HIGHHEALTH_DAMAGE_AMOUNT)
                    dmg:SetAttacker(self)
                    dmg:SetInflictor(self)
                    dmg:SetDamageType(DMG_GENERIC)
                    ply:TakeDamageInfo(dmg)
                end
            end

            -- Close enough to get comfy message (only once)
            if dist <= (ATTRACT_RADIUS / 2) and not ply._scp046_msg2 then
                ply:ChatPrint("You're very tired, this holly looks comfy.")
                ply._scp046_msg2 = true
            end

            -- Lethal zone: apply damage over time and play spaced crunch sounds
            if dist <= DEATH_RADIUS then
                local dmgAmount = DAMAGE_PER_SECOND * FrameTime()
                -- play crunch sound spaced out using last timestamp on player
                local now = CurTime()
                if not ply._scp046_lastCrunch or (now - ply._scp046_lastCrunch) >= CRUNCH_COOLDOWN then
                    ply._scp046_lastCrunch = now
                    -- play crunch sound for the player (audible to them and nearby)
                    ply:EmitSound(CRUNCH_SOUND, 75, 100)
                end

                -- If this damage will kill the player, send kill notification
                if ply:Health() <= dmgAmount then
                    -- send kill net to client so they can play death effects
                    net.Start("SCP046_Kill")
                    net.Send(ply)

                    -- play a server-side death sound for the victim (audible to them)
                    ply:EmitSound("vo/npc/male01/pain07.wav", 75, 100)

                    -- apply fatal damage
                    local dmg = DamageInfo()
                    dmg:SetDamage(dmgAmount)
                    dmg:SetAttacker(self)
                    dmg:SetInflictor(self)
                    dmg:SetDamageType(DMG_GENERIC)
                    ply:TakeDamageInfo(dmg)
                else
                    -- non-fatal damage tick
                    local dmg = DamageInfo()
                    dmg:SetDamage(dmgAmount)
                    dmg:SetAttacker(self)
                    dmg:SetInflictor(self)
                    dmg:SetDamageType(DMG_GENERIC)
                    ply:TakeDamageInfo(dmg)
                end
            end
        else
            -- leaving influence
            if self._influenced[sid] then
                self._influenced[sid] = nil
                StopLieDownMessages(ply)
                net.Start("SCP046_InfluenceStop") net.Send(ply)
            end

            ply:SetNWBool("scp046_influence", false)
            ply._scp046_msg2 = false
            ply._scp046_highDamageAcc = nil
            ply._scp046_lastCrunch = nil
        end
    end

    self:NextThink(CurTime() + 0.1)
    return true
end

function ENT:OnRemove()
    -- cleanup any timers we created for players (defensive)
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            StopLieDownMessages(ply)
            ply:SetNWBool("scp046_influence", false)
            local sid = ply:SteamID64()
            if self._influenced and self._influenced[sid] then
                self._influenced[sid] = nil
                net.Start("SCP046_InfluenceStop") net.Send(ply)
            end
            ply._scp046_highDamageAcc = nil
            ply._scp046_lastCrunch = nil
        end
    end
end