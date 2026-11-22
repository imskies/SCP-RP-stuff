-- init.lua (server)
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("SCP072_Blackout_Start")
util.AddNetworkString("SCP072_Blackout_Stop")
util.AddNetworkString("SCP072_ShowHint")
util.AddNetworkString("SCP072_PlaySound")
util.AddNetworkString("SCP072_PostEffect_Start")
util.AddNetworkString("SCP072_PostEffect_Stop")
util.AddNetworkString("SCP072_LieStart")
util.AddNetworkString("SCP072_LieStop")

CreateConVar("scp072_blackout_seconds", "8", {FCVAR_ARCHIVE})
CreateConVar("scp072_initial_damage", "80", {FCVAR_ARCHIVE})
CreateConVar("scp072_tick_damage", "1", {FCVAR_ARCHIVE})
CreateConVar("scp072_tick_interval", "1", {FCVAR_ARCHIVE})
CreateConVar("scp072_slow_walk_speed", "40", {FCVAR_ARCHIVE})
CreateConVar("scp072_slow_run_speed", "60", {FCVAR_ARCHIVE})
CreateConVar("scp072_slow_duration", "60", {FCVAR_ARCHIVE})
CreateConVar("scp072_bed_model", "models/props/de_inferno/bed.mdl", {FCVAR_ARCHIVE})
CreateConVar("scp072_play_sound", "guthen_scp/player/die3.ogg", {FCVAR_ARCHIVE})
CreateConVar("scp072_debug_align", "0", {FCVAR_ARCHIVE})

local STATE = {}

local function SaveSpeeds(ply)
    local jump = 200
    if ply.GetJumpPower then
        local ok, val = pcall(function() return ply:GetJumpPower() end)
        if ok and type(val) == "number" then jump = val end
    end
    return { walk = ply:GetWalkSpeed(), run = ply:GetRunSpeed(), jump = jump }
end

local function RestoreSpeeds(ply, speeds)
    if not IsValid(ply) or not speeds then return end
    ply:SetWalkSpeed(speeds.walk or 200)
    ply:SetRunSpeed(speeds.run or 400)
    if speeds.jump and ply.SetJumpPower then
        pcall(function() ply:SetJumpPower(speeds.jump) end)
    end
end

local function PlaySoundToPlayer(ply)
    local snd = GetConVar("scp072_play_sound"):GetString()
    if snd ~= "" then
        net.Start("SCP072_PlaySound")
        net.WriteString(snd)
        net.Send(ply)
    end
end

local function SafeUnSpectate(ply)
    if not IsValid(ply) then return end
    if ply.UnSpectate then pcall(function() ply:UnSpectate() end) return end
    if ply.SetObserverMode then pcall(function() ply:SetObserverMode(OBS_MODE_NONE) end) end
end

local function SmoothResetView(ply, dur)
    if not IsValid(ply) then return end
    dur = math.max(0, dur or 0)
    if dur <= 0 then
        local eye = ply:EyeAngles()
        ply:SetEyeAngles(Angle(0, eye.y, 0))
        return
    end

    local steps = math.max(1, math.floor(dur / 0.05))
    local startAng = ply:EyeAngles()
    local targetAng = Angle(0, startAng.y, 0)
    local step = 0
    local timerName = "scp072_viewreset_" .. ply:SteamID64()

    timer.Create(timerName, dur / steps, steps, function()
        if not IsValid(ply) then timer.Remove(timerName) return end
        step = step + 1
        ply:SetEyeAngles(LerpAngle(step / steps, startAng, targetAng))
        if step >= steps then timer.Remove(timerName) end
    end)
end

local function CleanupPlayer(ply)
    if not IsValid(ply) then return end
    local sid = ply:SteamID64()
    local s = STATE[sid]

    if s then
        if s.dotTimer then timer.Remove(s.dotTimer) end
        if s.blackoutTimer then timer.Remove(s.blackoutTimer) end
        if s.origSpeeds then RestoreSpeeds(ply, s.origSpeeds) end
        STATE[sid] = nil
    end

    ply:SetNWBool("SCP072_IsLying", false)
    ply:SetNWEntity("SCP072_LieBed", nil)
    ply:Freeze(false)
    SmoothResetView(ply, 0.12)

    net.Start("SCP072_Blackout_Stop") net.Send(ply)
    net.Start("SCP072_PostEffect_Stop") net.Send(ply)

    net.Start("SCP072_LieStop")
    net.WriteEntity(ply)
    net.Broadcast()

    SafeUnSpectate(ply)
end

local function StartDOT(ply)
    if not IsValid(ply) then return end
    local sid = ply:SteamID64()
    local s = STATE[sid] or {}

    ply:Freeze(false)
    ply:SetMoveType(MOVETYPE_WALK)

    if s.bed and IsValid(s.bed) then
        ply:SetPos(s.bed:GetPos() + s.bed:GetForward() * 60 + Vector(0,0,10))
    end

    SmoothResetView(ply, 0.12)

    net.Start("SCP072_Blackout_Stop") net.Send(ply)
    net.Start("SCP072_PostEffect_Start") net.Send(ply)

    net.Start("SCP072_LieStop")
    net.WriteEntity(ply)
    net.Broadcast()

    ply:ChatPrint("you feel something swipe at your feet. You can't feel your feet.")
    PlaySoundToPlayer(ply)

    local initial = GetConVar("scp072_initial_damage"):GetInt()
    if initial > 0 and ply:Alive() then
        local di = DamageInfo()
        di:SetDamage(initial)
        di:SetAttacker(game.GetWorld())
        di:SetInflictor(game.GetWorld())
        ply:TakeDamageInfo(di)
    end

    if not ply:Alive() then CleanupPlayer(ply) return end

    ply:SetWalkSpeed(GetConVar("scp072_slow_walk_speed"):GetInt())
    ply:SetRunSpeed(GetConVar("scp072_slow_run_speed"):GetInt())

    local saved = SaveSpeeds(ply)
    STATE[sid].origSpeeds = saved
    pcall(function() ply:SetJumpPower(0) end)

    local interval = GetConVar("scp072_tick_interval"):GetFloat()
    local timerName = "scp072_dot_" .. sid

    timer.Create(timerName, interval, 0, function()
        if not ply:Alive() then timer.Remove(timerName) CleanupPlayer(ply) return end
        local di = DamageInfo()
        di:SetDamage(1)
        di:SetAttacker(game.GetWorld())
        di:SetInflictor(game.GetWorld())
        ply:TakeDamageInfo(di)
    end)

    STATE[sid].dotTimer = timerName

    local slowDur = GetConVar("scp072_slow_duration"):GetInt()
    if slowDur > 0 then
        timer.Simple(slowDur, function()
            if IsValid(ply) and STATE[sid] and STATE[sid].origSpeeds then
                RestoreSpeeds(ply, STATE[sid].origSpeeds)
                net.Start("SCP072_PostEffect_Stop") net.Send(ply)
                STATE[sid] = nil
            end
        end)
    end
end

-- ⭐ Pelvis-based alignment with ONLY X+50 and Z+30 offsets
local function BeginLying(ply, ent)
    if not IsValid(ply) or not IsValid(ent) then return end
    if ply:GetNWBool("SCP072_IsLying", false) then return end

    local sid = ply:SteamID64()
    local orig = SaveSpeeds(ply)

    local bmin, bmax = ent:OBBMins(), ent:OBBMaxs()
    local bedTopCenter = ent:LocalToWorld(Vector((bmin.x+bmax.x)/2, (bmin.y+bmax.y)/2, bmax.z))

    local pelvis = ply:LookupBone("ValveBiped.Bip01_Pelvis")
    local bonePos = pelvis and select(1, ply:GetBonePosition(pelvis)) or ply:GetPos()

    -- CUSTOM OFFSET (X forward +50, Z up +30)
    local offset = Vector(40, 0, 20)

    local desiredBonePos = bedTopCenter
        + ent:GetForward() * offset.x
        + ent:GetUp()      * (1.5 + offset.z)

    local originToBone = bonePos - ply:GetPos()
    local finalPos = desiredBonePos - originToBone

    local finalAng = ent:GetAngles()
    finalAng:RotateAroundAxis(finalAng:Right(), 90)

    if GetConVar("scp072_debug_align"):GetInt() ~= 0 then
        print("[SCP072] Pelvis-align finalPos:", finalPos, "offset:", offset)
    end

    ply:SetPos(finalPos)
    ply:SetEyeAngles(finalAng)
    ply:SetLocalVelocity(vector_origin)
    ply:Freeze(true)

    ply:SetNWBool("SCP072_IsLying", true)
    ply:SetNWEntity("SCP072_LieBed", ent)

    STATE[sid] = {
        ply = ply,
        origSpeeds = orig,
        bed = ent,
        finalPos = finalPos,
        finalAng = finalAng
    }

    net.Start("SCP072_Blackout_Start")
    net.WriteFloat(GetConVar("scp072_blackout_seconds"):GetFloat())
    net.Send(ply)

    net.Start("SCP072_ShowHint") net.Send(ply)

    net.Start("SCP072_LieStart")
    net.WriteEntity(ply)
    net.WriteEntity(ent)
    net.WriteVector(finalPos)
    net.WriteAngle(finalAng)
    net.Broadcast()

    local blackoutSec = GetConVar("scp072_blackout_seconds"):GetFloat()
    local timerName = "scp072_blackout_" .. sid

    timer.Create(timerName, blackoutSec, 1, function()
        if IsValid(ply) and ply:GetNWBool("SCP072_IsLying", false) then
            StartDOT(ply)
        end
    end)

    STATE[sid].blackoutTimer = timerName
end

function ENT:Initialize()
    local mdl = GetConVar("scp072_bed_model"):GetString()
    if not util.IsValidModel(mdl) then mdl = "models/props_wasteland/prison_bedframe001b.mdl" end
    self:SetModel(mdl)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end
    self:SetUseType(SIMPLE_USE)
end

function ENT:Use(activator)
    if IsValid(activator) and activator:IsPlayer() and activator:Alive() then
        if not activator:GetNWBool("SCP072_IsLying", false) then
            BeginLying(activator, self)
        end
    end
end

function ENT:OnRemove()
    for sid, s in pairs(STATE) do
        if s and IsValid(s.ply) then
            s.ply:Freeze(false)
            s.ply:SetNWBool("SCP072_IsLying", false)
            s.ply:SetNWEntity("SCP072_LieBed", nil)
            if s.origSpeeds then RestoreSpeeds(s.ply, s.origSpeeds) end
            SmoothResetView(s.ply, 0.12)
        end
        if s and s.dotTimer then timer.Remove(s.dotTimer) end
        if s and s.blackoutTimer then timer.Remove(s.blackoutTimer) end
    end
    STATE = {}
end

hook.Add("PlayerDisconnected", "SCP072_CleanupDisconnect", CleanupPlayer)
hook.Add("PlayerDeath", "SCP072_CleanupOnDeath", CleanupPlayer)
hook.Add("PlayerSpawn", "SCP072_CleanupOnSpawn", CleanupPlayer)