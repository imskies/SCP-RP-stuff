-- cl_init.lua (client)
include("shared.lua")

local SCREEN_EFFECT_TIME = 30 -- seconds (user requested)
local overlayEndTime = 0
local NETMSG = "SCP1226_TransformClient"

-- Tunable parameters for requested stronger red + heavier motion blur
local MOTION_BLUR_STRENGTH = 1.4   -- overall intensity of motion blur (0-2)
local MOTION_BLUR_DELAY = 0.25     -- motion blur delay parameter for DrawMotionBlur
local RED_TINT_AMOUNT = 0.40       -- how strong the red tint is (0-1)
local COLOR_DESAT = 0.10           -- slight desaturation

net.Receive(NETMSG, function()
    local ply = net.ReadEntity()
    if not IsValid(ply) then return end

    if ply ~= LocalPlayer() then
        chat.AddText(Color(200,200,50), "[SCP-1226] ", Color(255,255,255), ply:Nick() .. " convulses and changes.")
    else
        overlayEndTime = CurTime() + SCREEN_EFFECT_TIME
        surface.PlaySound("npc/zombie/zombie_pain1.wav")
        chat.AddText(Color(200, 50, 50), "[SCP-1226] ", Color(255,255,255), "Your thoughts slow. You feel something reshaping you.")
        chat.AddText(Color(200, 50, 50), "[SCP-1226] ", Color(255,255,255), "You groan as your body expands and your mind narrows.")
        print("[SCP1226][CLIENT] Transform message received")
    end
end)

hook.Add("HUDPaint", "SCP1226_MinorOverlayText", function()
    if overlayEndTime == 0 then return end
    local t = overlayEndTime - CurTime()
    if t <= 0 then overlayEndTime = 0 return end

    local alpha = math.Clamp((t / SCREEN_EFFECT_TIME) * 220 + 35, 0, 255)
    draw.SimpleText("MIND: FRAGMENTING", "DermaLarge", ScrW() * 0.5, ScrH() * 0.12, Color(220, 180, 180, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)

hook.Add("RenderScreenspaceEffects", "SCP1226_MotionBlurRedTint", function()
    if overlayEndTime == 0 then return end
    local t = overlayEndTime - CurTime()
    if t <= 0 then overlayEndTime = 0 return end

    local frac = math.Clamp(t / SCREEN_EFFECT_TIME, 0, 1)

    -- Motion blur: heavier at start, eases out
    local mb = MOTION_BLUR_STRENGTH * frac
    -- DrawMotionBlur(delay, min, max)
    DrawMotionBlur(MOTION_BLUR_DELAY * mb, 0.9 * mb, 0.02 * mb)

    -- Color modify: stronger red tint and slight desaturation
    local tab = {
        ["$pp_colour_addr"] = 0.12 * RED_TINT_AMOUNT * frac,  -- add red
        ["$pp_colour_addg"] = 0.0,
        ["$pp_colour_addb"] = -0.04 * RED_TINT_AMOUNT * frac, -- reduce blue slightly
        ["$pp_colour_brightness"] = -0.02 * frac,
        ["$pp_colour_contrast"] = 1 - 0.08 * frac,
        ["$pp_colour_colour"] = 1 - COLOR_DESAT * frac
    }
    DrawColorModify(tab)
end)