AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

--========================================================--
--   GLOBAL COOLDOWN (5 SECONDS)
--========================================================--
local GLOBAL_COOLDOWN = 5
ENT.NextUse = 0

--========================================================--
--   INITIALIZATION
--========================================================--
function ENT:Initialize()
    self:SetModel("models/props_c17/door03_left.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self:SetUseType(SIMPLE_USE)
end

--========================================================--
--   DESTINATION TABLES (UPDATED)
--========================================================--

local NormalDestinations = {
    Vector(-10863.704102 -5011.519043 -2134.968750),
    Vector(-9800.527344 -6275.436035 -2134.968750),
    Vector(-7840.583496 -4452.623047 -2134.968750),
    Vector(-12062.970703 -1742.412598 -2526.596436),
}

local RareDestinations = {
    Vector(-13192.783203 -5485.566406 -2134.529297),
}

local UltraRareDestinations = {
    Vector(2153.743652 1083.073853 -500.005493),
}

--========================================================--
--   DESTINATION SELECTION
--========================================================--
local function ChooseDestination()
    local roll = math.random(1, 10000)

    if roll <= 10 then
        return table.Random(UltraRareDestinations), "ULTRA_RARE"
    end

    if roll <= 210 then
        return table.Random(RareDestinations), "RARE"
    end

    return table.Random(NormalDestinations), "NORMAL"
end

--========================================================--
--   USE INTERACTION + COOLDOWN + SOUND
--========================================================--
function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    -- GLOBAL COOLDOWN CHECK
    if CurTime() < self.NextUse then
        local wait = math.Round(self.NextUse - CurTime(), 1)
        activator:ChatPrint("[SCP-249] The door resists... (" .. wait .. "s)")
        return
    end

    -- Set next allowed use
    self.NextUse = CurTime() + GLOBAL_COOLDOWN

    -- Play door movement sound
    self:EmitSound("doors/door1_move.wav", 75, 100)

    -- Choose teleport destination
    local dest, rarity = ChooseDestination()

    -- Feedback
    if rarity == "RARE" then
        activator:ChatPrint("[SCP-249] The door hums strangely...")
    elseif rarity == "ULTRA_RARE" then
        activator:ChatPrint("[SCP-249] Reality bends as the door opens...")
    end

    -- Teleport player
    activator:SetPos(dest)
    activator:ScreenFade(SCREENFADE.IN, Color(0,0,0,255), 0.5, 0.5)
end