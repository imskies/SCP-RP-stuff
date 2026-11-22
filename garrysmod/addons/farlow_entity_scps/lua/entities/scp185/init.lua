AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Load the full history table returned by history.lua
local fullHistory = include("history.lua") or {}

util.AddNetworkString("SCP185_OpenKeypad")
util.AddNetworkString("SCP185_SubmitCode")
util.AddNetworkString("SCP185_ChatMessage")

function ENT:Initialize()
    self:SetModel("models/props_lab/reciever01b.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    -- Use the full history table
    self.HistoricalCodes = fullHistory
    self.InputCooldown = 0
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if CurTime() < self.InputCooldown then return end

    net.Start("SCP185_OpenKeypad")
    net.WriteEntity(self)
    net.Send(activator)
end

-- Helper: sanitize and normalize input
local function NormalizeYearInput(input)
    if not input then return nil end
    input = tostring(input):Trim()
    -- Try numeric parse first
    local n = tonumber(input)
    if n then
        -- clamp to expected range if you want (1700-2026)
        if n < 1700 or n > 2026 then
            return tostring(n) -- still return string so lookup can fail gracefully
        end
        return tostring(math.floor(n))
    end
    -- If not numeric, return trimmed string (allows keys like "1898" or custom keys)
    return input
end

-- Handle keypad code submissions
net.Receive("SCP185_SubmitCode", function(len, ply)
    local codeRaw = net.ReadString()
    local ent = net.ReadEntity()

    if not IsValid(ent) or ent:GetClass() ~= "scp_185" then return end
    if not IsValid(ply) then return end

    local codeKey = NormalizeYearInput(codeRaw)

    local msg = "Radio transmission: Static noise... Invalid code."

    if codeKey and ent.HistoricalCodes then
        -- Direct lookup by string key
        local found = ent.HistoricalCodes[codeKey]
        if found then
            msg = found
        else
            -- Optional: if numeric and out of range, give clearer feedback
            local num = tonumber(codeKey)
            if num then
                if num < 1700 or num > 2026 then
                    msg = "Radio transmission: No records for that year range (1700-2026)."
                else
                    msg = "Radio transmission: No entry found for year " .. codeKey .. "."
                end
            else
                msg = "Radio transmission: Invalid input format."
            end
        end
    end

    net.Start("SCP185_ChatMessage")
    net.WriteString(msg)
    net.Send(ply)

    ent.InputCooldown = CurTime() + 2
end)