-- init.lua (server)
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("knowledge_pool.lua")

include("shared.lua")
local knowledge = include("knowledge_pool.lua")

-- CONFIG
local MODEL = "models/props_junk/rock001a.mdl"
local GLOBAL_COOLDOWN = 0         -- no global cooldown (0 seconds)
local PLAYER_COOLDOWN = 5         -- seconds per player (now 5s)
local MAX_USES_PER_DAY = 2
local PENALTY_DURATION = 30
local LOG_FILE = "scp_028_1_usage.log"

local DebuffMessages = {
    "You feel nauseous and dizzy from all the knowledge you've gained.",
    "A wave of vertigo hits you; your head swims with too much information.",
    "Your vision blurs and your stomach churns from the influx of facts.",
    "A pounding headache and queasy stomach follow the stone's revelations.",
    "You stagger as a flood of details overwhelms your senses.",
    "Your thoughts tangle; you feel faint and disoriented.",
    "A heavy pressure behind your eyes makes you want to sit down.",
    "You taste metal and the room tilts; the knowledge is too much.",
    "Your limbs feel light and your head heavy; nausea sets in.",
    "A sudden dizziness forces you to steady yourself against a wall."
}

if SERVER then
    util.AddNetworkString("SCP0281_ShowKnowledge")
    util.AddNetworkString("SCP0281_DebuffMsg")
end

function ENT:Initialize()
    self:SetModel(MODEL)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self:SetUseType(SIMPLE_USE)

    self.NextUse = 0
    self.PlayerLastUse = {}
    self.PlayerDailyCount = {}

    -- networked global cooldown value (kept for compatibility; 0 means no global cooldown)
    self:SetNWFloat("SCP0281_NextUse", 0)
end

local function ChooseKnowledge()
    local roll = math.random(1,100)
    local entry = nil
    local rarity = "COMMON"

    if roll <= 2 then
        rarity = "RARE"
    elseif roll <= 20 then
        rarity = "UNCOMMON"
    else
        rarity = "COMMON"
    end

    for i=1,100 do
        local candidate = knowledge[math.random(1,#knowledge)]
        local len = #candidate
        if rarity == "COMMON" and len <= 140 then
            entry = candidate
            break
        elseif rarity == "UNCOMMON" and len > 140 and len <= 220 then
            entry = candidate
            break
        elseif rarity == "RARE" and len > 220 then
            entry = candidate
            break
        end
    end

    if not entry then
        entry = knowledge[math.random(1,#knowledge)]
    end

    return entry, rarity
end

local function LogUsage(ply, knowledgeID, rarity)
    if not IsValid(ply) then return end
    local line = string.format("[%s] %s (%s) used SCP-028-1: Rarity=%s; Knowledge=\"%s\"\n",
        os.date("%Y-%m-%d %H:%M:%S"), ply:Nick(), ply:SteamID(), rarity, knowledgeID)
    file.Append(LOG_FILE, line)
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    local steam = activator:SteamID()
    local now = CurTime()

    -- No global cooldown enforced (GLOBAL_COOLDOWN == 0)
    if GLOBAL_COOLDOWN > 0 then
        if self.NextUse and now < self.NextUse then
            local wait = math.Round(self.NextUse - now, 1)
            activator:ChatPrint("[SCP-028-1] The stone resists... (" .. wait .. "s)")
            return
        end
    end

    -- Player cooldown
    local last = self.PlayerLastUse[steam] or 0
    if now < last + PLAYER_COOLDOWN then
        local wait = math.Round((last + PLAYER_COOLDOWN) - now, 1)
        activator:ChatPrint("[SCP-028-1] Your mind is still recovering... (" .. wait .. "s)")
        return
    end

    -- Update player cooldown
    self.PlayerLastUse[steam] = now
    activator:SetNWFloat("SCP0281_PlayerCooldownEnd", now + PLAYER_COOLDOWN)

    -- If GLOBAL_COOLDOWN > 0 we would set NextUse; keep compatibility but set to 0
    if GLOBAL_COOLDOWN > 0 then
        self.NextUse = now + GLOBAL_COOLDOWN
        self:SetNWFloat("SCP0281_NextUse", self.NextUse)
    else
        self.NextUse = 0
        self:SetNWFloat("SCP0281_NextUse", 0)
    end

    -- Track daily count (24 minutes window)
    local record = self.PlayerDailyCount[steam]
    if not record or now > (record.firstTimestamp + 1440) then
        self.PlayerDailyCount[steam] = { count = 1, firstTimestamp = now }
    else
        self.PlayerDailyCount[steam].count = record.count + 1
    end

    -- Choose knowledge
    local entry, rarity = ChooseKnowledge()

    -- Send to client for UI
    net.Start("SCP0281_ShowKnowledge")
        net.WriteString(entry)
        net.WriteString(rarity)
    net.Send(activator)

    -- Apply effects: buffs for uncommon/rare
    if rarity == "UNCOMMON" then
        activator:SetNWFloat("SCP0281_BuffEnd", now + 30)
        activator:ChatPrint("[SCP-028-1] You feel unusually focused for a short time.")
    elseif rarity == "RARE" then
        activator:SetNWFloat("SCP0281_BuffEnd", now + 60)
        activator:ChatPrint("[SCP-028-1] A surge of clarity floods your mind.")
    else
        activator:ChatPrint("[SCP-028-1] You gain a small insight.")
    end

    -- Penalty for repeated exposure
    local uses = self.PlayerDailyCount[steam] and self.PlayerDailyCount[steam].count or 0
    if uses > MAX_USES_PER_DAY then
        activator:SetNWFloat("SCP0281_PenaltyEnd", now + PENALTY_DURATION)
        local msg = DebuffMessages[math.random(1,#DebuffMessages)]
        net.Start("SCP0281_DebuffMsg")
            net.WriteString(msg)
            net.WriteFloat(PENALTY_DURATION)
        net.Send(activator)
        activator:ChatPrint("[SCP-028-1] You feel unwell after repeated exposure.")
    else
        activator:ScreenFade(SCREENFADE.IN, Color(0,0,0,120), 0.2, 0.2)
    end

    -- Log usage
    LogUsage(activator, entry, rarity)
end