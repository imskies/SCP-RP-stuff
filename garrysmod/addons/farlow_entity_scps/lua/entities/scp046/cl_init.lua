include("shared.lua")

-- Local state
local isInfluenced = false
local influenceSound = nil
local influenceSoundName = "ambient/voices/playground_memory.wav" -- requested ambient sound
local killSoundName = "ambient/alarms/klaxon1.wav" -- sound to play on death (clientside)
local colorIntensity = 0 -- 0..1, used for smooth interpolation
local flashIntensity = 0 -- temporary flash on kill

-- client-side copy of ATTRACT_RADIUS to compute intensity by distance
local ATTRACT_RADIUS = 140

-- Start influence: play looping sound and enable screen effect
net.Receive("SCP046_InfluenceStart", function()
    if isInfluenced then return end
    isInfluenced = true

    -- create and play looping ambient sound for the local player
    if not influenceSound then
        influenceSound = CreateSound(LocalPlayer(), influenceSoundName)
    end
    if influenceSound then
        influenceSound:Play()
        influenceSound:ChangeVolume(0.9, 0)
        influenceSound:ChangePitch(95, 0)
    end

    notification.AddLegacy("You feel drawn to the holly bush...", NOTIFY_HINT, 3)
end)

-- Stop influence: stop sound and fade effect
net.Receive("SCP046_InfluenceStop", function()
    if not isInfluenced then return end
    isInfluenced = false

    if influenceSound then
        influenceSound:FadeOut(0.4)
        timer.Simple(0.45, function()
            if influenceSound then
                influenceSound:Stop()
                influenceSound = nil
            end
        end)
    end

    notification.AddLegacy("You pull away from the holly bush.", NOTIFY_GENERIC, 3)
end)

-- Kill notification: play a distinct death sound and a brief flash
net.Receive("SCP046_Kill", function()
    surface.PlaySound(killSoundName)
    flashIntensity = math.max(flashIntensity, 2.0)
end)

-- Draw the model as usual
function ENT:Draw()
    if not IsValid(self) then return end
    self:DrawModel()
end

-- Compute per-frame intensity based on nearest SCP-046 distance when influenced
local function ComputeLocalIntensity()
    if not isInfluenced then return 0 end
    local ply = LocalPlayer()
    if not IsValid(ply) then return 0 end

    local bestDist = math.huge
    for _, ent in ipairs(ents.FindByClass("scp_046")) do
        if not IsValid(ent) then continue end
        local d = ply:GetPos():Distance(ent:GetPos())
        if d < bestDist then bestDist = d end
    end

    if bestDist == math.huge then return 1 end
    local t = math.Clamp(1 - (bestDist / ATTRACT_RADIUS), 0, 1)
    return t
end

-- Smoothly interpolate colorIntensity based on isInfluenced and distance
hook.Add("Think", "SCP046_ClientThink", function()
    local target = isInfluenced and ComputeLocalIntensity() or 0
    colorIntensity = Lerp(0.12, colorIntensity, target)

    -- decay flashIntensity over time
    if flashIntensity > 0 then
        flashIntensity = math.max(0, flashIntensity - FrameTime() * 2.5)
    end
end)

-- Strong hallucination effect: heavy saturation, color shifts, bloom, chromatic tint and wobble
hook.Add("RenderScreenspaceEffects", "SCP046_ColorModify", function()
    if colorIntensity <= 0.01 and flashIntensity <= 0.01 then return end

    local intensity = math.Clamp(colorIntensity, 0, 1)

    -- Strong saturation and contrast tweak
    local SATURATION_MULT = 2.2 -- stronger saturation
    local CONTRAST_REDUCTION = 0.45
    local sat = 1 + ((SATURATION_MULT - 1) * intensity)
    local contrast = 1 - (CONTRAST_REDUCTION * intensity)
    local brightness = 0

    local tab = {
        ["$pp_colour_addr"] = 0.02 * intensity, -- slight red shift
        ["$pp_colour_addg"] = -0.01 * intensity, -- slight green reduction
        ["$pp_colour_addb"] = -0.02 * intensity, -- slight blue reduction
        ["$pp_colour_brightness"] = brightness,
        ["$pp_colour_contrast"] = contrast,
        ["$pp_colour_colour"] = sat,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    }

    DrawColorModify(tab)

    -- Chromatic tint overlay that subtly shifts colors over time (hallucination)
    local t = CurTime()
    local r = 30 * math.sin(t * 1.2) * intensity
    local g = 20 * math.sin(t * 1.5 + 1) * intensity
    local b = 40 * math.sin(t * 0.9 + 2) * intensity
    surface.SetDrawColor(255, 200 + r, 200 + g, 40 * intensity)
    surface.DrawRect(0, 0, ScrW(), ScrH())

    -- Wobble: slight screen-space displacement using a translucent noise overlay
    local wobble = math.sin(CurTime() * 2.5) * 4 * intensity
    render.SetScissorRect(0, 0, ScrW(), ScrH(), true)
    surface.SetDrawColor(255, 255, 255, 12 * intensity)
    surface.DrawRect(wobble, 0, ScrW(), ScrH())
    render.SetScissorRect(0, 0, 0, 0, false)

    -- Strong vignette
    local vignAlpha = math.Clamp(intensity, 0, 1) * 220
    surface.SetDrawColor(0, 0, 0, vignAlpha)
    surface.DrawRect(0, 0, ScrW(), ScrH())

    -- Bloom when strongly influenced
    if intensity > 0.5 then
        local bloomIntensity = (intensity - 0.5) * 2
        DrawBloom(0.7 * bloomIntensity, 1.2 * bloomIntensity, 9, 9, 1, 1, 1, 1, 1)
    end

    -- flash overlay for kill
    if flashIntensity > 0.01 then
        local f = math.Clamp(flashIntensity, 0, 2)
        surface.SetDrawColor(255, 220, 200, 200 * f)
        surface.DrawRect(0, 0, ScrW(), ScrH())
    end
end)

-- Stop sound on death/respawn for local player
hook.Add("PlayerDeath", "SCP046_LocalStopSound", function(ply)
    if ply ~= LocalPlayer() then return end
    if influenceSound then
        influenceSound:Stop()
        influenceSound = nil
    end
    isInfluenced = false
    colorIntensity = 0
    flashIntensity = 1.2
end)

-- Clean up when the client unloads the entity or map changes
hook.Add("ShutDown", "SCP046_Cleanup", function()
    if influenceSound then
        influenceSound:Stop()
        influenceSound = nil
    end
end)