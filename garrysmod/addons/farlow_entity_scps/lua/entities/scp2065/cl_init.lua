-- scp2065/cl_init.lua
-- Client side effects and UI for the SCP-style book entity

include("shared.lua")

-- Show the tip prefixed with [SCP-2065] where the bracket text is red
net.Receive("SCP2065_ShowTip", function()
    local tip = net.ReadString()
    -- Red bracket text "[SCP-2065]" followed by the tip in white
    chat.AddText(Color(255,0,0), "[SCP-2065] ", Color(255,255,255), tip)
    notification.AddLegacy(tip, NOTIFY_GENERIC, 5)
    surface.PlaySound("buttons/button15.wav")
end)

local activeFX = {}
local RENDER_HOOK_NAME = "SCP2065_RenderFX"

-- Receive stage and duration; keep the on-screen effects for the entire stage duration
net.Receive("SCP2065_ClientFX", function()
    local stage = net.ReadInt(8)
    local duration = net.ReadInt(16)
    duration = math.max(1, duration or (ENT and ENT.Config and ENT.Config.stageInterval) or 20)

    local totalStages = math.max(1, (ENT and ENT.Config and ENT.Config.totalStages) or 5)
    local intensity = math.Clamp(stage / totalStages, 0, 1)

    -- Add or replace an active effect keyed by stage (so it persists for the stage duration)
    local id = "stage_" .. tostring(stage)
    activeFX[id] = {stage = stage, intensity = intensity, start = CurTime(), duration = duration}

    -- Play subtle sound (no chat prefix)
    surface.PlaySound("ambient/atmosphere/ambience1.wav")
end)

-- Clean up expired stage effects
local function CleanupFX()
    for id, fx in pairs(activeFX) do
        if fx.start + fx.duration < CurTime() then
            activeFX[id] = nil
        end
    end
end

hook.Add("Think", "SCP2065_FXThink", function()
    CleanupFX()
end)

hook.Add("RenderScreenspaceEffects", RENDER_HOOK_NAME, function()
    local any = false
    local maxIntensity = 0
    for _, v in pairs(activeFX) do
        any = true
        if v.intensity > maxIntensity then maxIntensity = v.intensity end
    end

    if not any then return end

    -- Color modify
    local tab = {}
    tab["$pp_colour_addr"] = 0
    tab["$pp_colour_addg"] = 0
    tab["$pp_colour_addb"] = 0
    tab["$pp_colour_brightness"] = -0.02 * maxIntensity
    tab["$pp_colour_contrast"] = 1 - 0.15 * maxIntensity
    tab["$pp_colour_colour"] = 1 - 0.6 * maxIntensity
    DrawColorModify(tab)

    -- Motion blur scaled by intensity
    DrawMotionBlur(0.1 * maxIntensity, 0.8 * maxIntensity, 0.01)
end)

-- HUD "Book Effect Stage" removed per request (no HUDPaint hook)