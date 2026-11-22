-- cl_init.lua (client)
include("shared.lua")

local blackoutPanel, blackoutStart, blackoutDuration, fadeAlpha = nil, 0, 0, 0
local fadeHookName = "SCP072_Blackout_Fade"
local safetyTimerName = "SCP072_Blackout_Safety"
local postPanel = nil

-- lying visuals: sid64 -> { model = ClientsideModel, ply = player, bed = entity, finalPos, finalAng }
local lyingVisuals = {}

local function RemoveBlackoutUI()
    if IsValid(blackoutPanel) then blackoutPanel:Remove(); blackoutPanel = nil end
    hook.Remove("HUDPaint", fadeHookName)
    timer.Remove(safetyTimerName)
end

local function CreateBlackoutUI(duration)
    RemoveBlackoutUI()
    blackoutStart = CurTime()
    blackoutDuration = math.max(0.01, duration)
    fadeAlpha = 0

    blackoutPanel = vgui.Create("DPanel")
    blackoutPanel:SetSize(ScrW(), ScrH())
    blackoutPanel:SetPos(0,0)
    blackoutPanel:SetDrawOnTop(true)
    blackoutPanel.Paint = function(self, w, h)
        surface.SetDrawColor(0,0,0, math.Clamp(fadeAlpha,0,255))
        surface.DrawRect(0,0,w,h)
        if fadeAlpha >= 10 then
            draw.SimpleTextOutlined("Your mind wanders as you drift to sleep", "DermaLarge", w*0.5, h*0.45, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0,200))
        end
    end

    hook.Add("HUDPaint", fadeHookName, function()
        local t = math.Clamp((CurTime() - blackoutStart) / blackoutDuration, 0, 1)
        fadeAlpha = Lerp(t * t, 0, 255)
    end)

    timer.Create(safetyTimerName, blackoutDuration + 5, 1, function() RemoveBlackoutUI() end)
end

local function CreatePostEffect()
    if IsValid(postPanel) then return end
    postPanel = vgui.Create("DPanel")
    postPanel:SetSize(ScrW(), ScrH()); postPanel:SetPos(0,0); postPanel:SetDrawOnTop(true)
    postPanel.Paint = function(self, w, h)
        surface.SetDrawColor(0,0,0,120); surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(120,0,0,30); surface.DrawRect(0,0,w,h)
        for i=1,30 do surface.SetDrawColor(0,0,0, math.random(0,6)); surface.DrawRect(math.random(0,w), math.random(0,h), 2, 2) end
    end
end

local function RemovePostEffect()
    if IsValid(postPanel) then postPanel:Remove(); postPanel = nil end
end

-- Create clientsided lying model at server-provided pos/ang
local function CreateLyingVisualAt(ply, bed, finalPos, finalAng)
    if not IsValid(ply) or not IsValid(bed) then return end
    local sid = ply:SteamID64()
    if lyingVisuals[sid] then
        if IsValid(lyingVisuals[sid].model) then lyingVisuals[sid].model:Remove() end
        lyingVisuals[sid] = nil
    end

    local mdl = ply:GetModel() or "models/player/kleiner.mdl"
    local cs = ClientsideModel(mdl, RENDERGROUP_OPAQUE)
    if not IsValid(cs) then return end
    cs:SetNoDraw(false)
    cs:SetModelScale(1,0)
    cs:SetSkin(ply:GetSkin() or 0)
    cs:SetColor(ply:GetColor() or Color(255,255,255))

    cs:SetPos(finalPos)
    cs:SetAngles(finalAng)
    cs:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

    -- Try to hide the real player model as well (both methods for reliability)
    if IsValid(ply) then
        pcall(function() ply:SetNoDraw(true) end)
    end

    lyingVisuals[sid] = { model = cs, ply = ply, bed = bed, finalPos = finalPos, finalAng = finalAng }
end

local function RemoveLyingVisualForPlayer(ply)
    if not IsValid(ply) then return end
    local sid = ply:SteamID64()
    local v = lyingVisuals[sid]
    if v then
        if IsValid(v.model) then v.model:Remove() end
        lyingVisuals[sid] = nil
    end
    if IsValid(ply) then
        pcall(function() ply:SetNoDraw(false) end)
    end
end

-- Update lying visuals each frame (prefer server final pos/ang)
hook.Add("Think", "SCP072_UpdateLyingVisuals", function()
    for sid, v in pairs(lyingVisuals) do
        if not v or not IsValid(v.ply) or not IsValid(v.model) or not IsValid(v.bed) then
            if v and IsValid(v.model) then v.model:Remove() end
            if v and IsValid(v.ply) then pcall(function() v.ply:SetNoDraw(false) end) end
            lyingVisuals[sid] = nil
        else
            if v.finalPos and v.finalAng then
                v.model:SetPos(v.finalPos)
                v.model:SetAngles(v.finalAng)
            else
                -- fallback: use bed offsets if server didn't provide final pos/ang
                local off = v.offsets or { up = 18, forward = 6, right = 0 }
                local layPos = v.bed:GetPos() + v.bed:GetUp() * off.up + v.bed:GetForward() * off.forward + v.bed:GetRight() * off.right
                local layAng = v.bed:GetAngles(); layAng:RotateAroundAxis(layAng:Right(), 90)
                v.model:SetPos(layPos); v.model:SetAngles(layAng)
            end
        end
    end
end)

-- Prevent drawing of players that are in lyingVisuals (PrePlayerDraw)
hook.Add("PrePlayerDraw", "SCP072_PrePlayerDrawHideLying", function(ply)
    if not IsValid(ply) then return end
    local sid = ply:SteamID64()
    if lyingVisuals[sid] then
        return true
    end
end)

-- Net receivers
net.Receive("SCP072_Blackout_Start", function() CreateBlackoutUI(net.ReadFloat() or 8) end)
net.Receive("SCP072_Blackout_Stop", function() RemoveBlackoutUI() end)

net.Receive("SCP072_ShowHint", function()
    local hint = vgui.Create("DLabel")
    hint:SetText("You feel drowsy"); hint:SetFont("DermaLarge"); hint:SizeToContents()
    hint:SetPos(ScrW()*0.5 - hint:GetWide()*0.5, ScrH()*0.85); hint:SetTextColor(Color(255,255,255))
    timer.Simple(5, function() if IsValid(hint) then hint:Remove() end end)
end)

net.Receive("SCP072_PlaySound", function()
    local snd = net.ReadString() or ""
    if snd == "" then return end
    local ply = LocalPlayer()
    if IsValid(ply) then ply:EmitSound(snd, 75, 100) else surface.PlaySound(snd) end
end)

net.Receive("SCP072_PostEffect_Start", function() CreatePostEffect() end)
net.Receive("SCP072_PostEffect_Stop", function() RemovePostEffect() end)

-- LieStart now receives final pos/ang from server
net.Receive("SCP072_LieStart", function()
    local ply = net.ReadEntity()
    local bed = net.ReadEntity()
    local finalPos = net.ReadVector()
    local finalAng = net.ReadAngle()
    if not IsValid(ply) or not IsValid(bed) then return end
    CreateLyingVisualAt(ply, bed, finalPos, finalAng)
end)

net.Receive("SCP072_LieStop", function()
    local ply = net.ReadEntity()
    if not IsValid(ply) then return end
    RemoveLyingVisualForPlayer(ply)
end)

-- Safety cleanup for local player
hook.Add("OnPlayerDeath", "SCP072_ClientCleanupOnDeath", function(ply)
    if IsValid(ply) and ply == LocalPlayer() then RemoveBlackoutUI(); RemovePostEffect() end
end)
hook.Add("InitPostEntity", "SCP072_ClientInitCleanup", function() RemoveBlackoutUI(); RemovePostEffect() end)