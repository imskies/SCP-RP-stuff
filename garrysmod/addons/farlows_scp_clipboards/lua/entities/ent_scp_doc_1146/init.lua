print("[SCP DEBUG] INIT LOADED for ent_scp_doc_1146")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("SCP_OpenClipboard")

function ENT:Initialize()
    self:SetModel("models/props_lab/clipboard.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self.UseCooldown = {}
end

local function CanUse(ent, ply)
    local sid = ply:SteamID()
    local now = CurTime()
    local last = ent.UseCooldown[sid] or 0

    if now - last < 1 then return false end
    ent.UseCooldown[sid] = now
    return true
end

function ENT:Use(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not CanUse(self, ply) then return end

    local file = SCP_Files[self.SCP_ID]
    if not file then
        ply:ChatPrint("This SCP file is missing from the database.")
        return
    end

    if GetPlayerClearance(ply) < file.clearance then
        ply:ChatPrint("ACCESS DENIED — Insufficient clearance level.")
        return
    end

    net.Start("SCP_OpenClipboard")
        net.WriteString(self.SCP_ID)
    net.Send(ply)
end