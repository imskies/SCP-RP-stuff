-- scp6243_dg/cl_init.lua
-- Clientside visuals for SCP-6243-DG

include("shared.lua")

local activeClientFX = {}         -- effectID -> {start,duration,sound}
local RENDER_HOOK = "SCP6243_RenderFX"

local function PlayLoopSoundForEffect(effectID)
    local soundName
    if effectID == 1 then soundName = "ambient/machines/spin_loop.wav"
    elseif effectID == 2 then soundName = "ambient/explosions/explode_4.wav"
    elseif effectID == 3 then soundName = "ambient/fire/fire_small_loop1.wav"
    elseif effectID == 4 then soundName = "buttons/button9.wav"
    elseif effectID == 5 then soundName = "items/suitchargeok1.wav"
    elseif effectID == 6 then soundName = "ambient/levels/citadel/portal_beam_shoot1.wav"
    elseif effectID == 7 then soundName = "npc/overwatch/radiovoice/on1.wav"
    elseif effectID == 8 then soundName = "items/ammo_pickup.wav"
    elseif effectID == 9 then soundName = "items/battery_pickup.wav"
    elseif effectID == 10 then soundName = "ambient/alarms/klaxon1.wav"
    elseif effectID == 11 then soundName = "vo/npc/male01/ohno.wav"
    elseif effectID == 12 then soundName = "ambient/levels/citadel/weapon_disintegrate2.wav"
    end

    if not soundName then return nil end
    local lp = LocalPlayer()
    if not IsValid(lp) then return nil end
    local snd = CreateSound(lp, soundName)
    if snd then
        snd:Play()
        return snd
    end
    return nil
end

net.Receive("SCP6243_FlipFX", function()
    surface.PlaySound("buttons/button14.wav")
    local ed = EffectData()
    local lp = LocalPlayer()
    local pos = lp:GetEyeTrace().HitPos or lp:GetPos()
    ed:SetOrigin(pos)
    util.Effect("cball_explode", ed)
end)

net.Receive("SCP6243_ApplyEffect", function()
    local effectID = net.ReadInt(8)
    local duration = net.ReadInt(16)
    duration = math.max(1, duration or ENT.Config.effectDuration or 12)

    if activeClientFX[effectID] and activeClientFX[effectID].sound then
        activeClientFX[effectID].sound:Stop()
    end

    local snd = PlayLoopSoundForEffect(effectID)
    activeClientFX[effectID] = { start = CurTime(), duration = duration, sound = snd }
end)

net.Receive("SCP6243_ClearEffect", function()
    for id, fx in pairs(activeClientFX) do
        if fx.sound and fx.sound.Stop then fx.sound:Stop() end
    end
    activeClientFX = {}
end)

hook.Add("Think", "SCP6243_ClientFXThink", function()
    for id, fx in pairs(activeClientFX) do
        if fx.start + fx.duration < CurTime() then
            if fx.sound and fx.sound.Stop then fx.sound:Stop() end
            activeClientFX[id] = nil
        end
    end

    local lp = LocalPlayer()
    if IsValid(lp) and not lp:Alive() and next(activeClientFX) then
        for id, fx in pairs(activeClientFX) do
            if fx.sound and fx.sound.Stop then fx.sound:Stop() end
        end
        activeClientFX = {}
    end
end)

hook.Add("RenderScreenspaceEffects", RENDER_HOOK, function()
    if not next(activeClientFX) then return end

    if activeClientFX[1] then
        local fx = activeClientFX[1]
        local t = math.Clamp(((fx.start + fx.duration) - CurTime()) / fx.duration, 0, 1)
        local tab = {}
        tab["$pp_colour_addr"] = 0.03 * t
        tab["$pp_colour_addg"] = 0
        tab["$pp_colour_addb"] = 0
        tab["$pp_colour_brightness"] = 0.01 * t
        tab["$pp_colour_contrast"] = 1 + 0.03 * t
        tab["$pp_colour_colour"] = 1
        DrawColorModify(tab)
    end

    if activeClientFX[2] then
        local fx = activeClientFX[2]
        local t = math.Clamp(((fx.start + fx.duration) - CurTime()) / fx.duration, 0, 1)
        local tab = {}
        tab["$pp_colour_addr"] = 0.06 * t
        tab["$pp_colour_addg"] = 0.06 * t
        tab["$pp_colour_addb"] = 0.06 * t
        tab["$pp_colour_brightness"] = 0.02 * t
        tab["$pp_colour_contrast"] = 1 + 0.05 * t
        tab["$pp_colour_colour"] = 1
        DrawColorModify(tab)
        DrawMotionBlur(0.06 * t, 0.6 * t, 0.01)
    end

    if activeClientFX[3] then
        local fx = activeClientFX[3]
        local t = math.Clamp(((fx.start + fx.duration) - CurTime()) / fx.duration, 0, 1)
        local tab = {}
        tab["$pp_colour_addr"] = 0.04 * t
        tab["$pp_colour_addg"] = 0
        tab["$pp_colour_addb"] = 0
        tab["$pp_colour_brightness"] = -0.01 * t
        tab["$pp_colour_contrast"] = 1 - 0.05 * t
        tab["$pp_colour_colour"] = 1 - 0.3 * t
        DrawColorModify(tab)
    end

    if activeClientFX[5] then
        local fx = activeClientFX[5]
        local t = math.Clamp(((fx.start + fx.duration) - CurTime()) / fx.duration, 0, 1)
        DrawMotionBlur(0.02 * t, 0.6 * t, 0.01)
    end

    if activeClientFX[6] then
        local fx = activeClientFX[6]
        local t = math.Clamp(((fx.start + fx.duration) - CurTime()) / fx.duration, 0, 1)
        local tab = {}
        tab["$pp_colour_addr"] = 0
        tab["$pp_colour_addg"] = 0.02 * t
        tab["$pp_colour_addb"] = 0.04 * t
        tab["$pp_colour_brightness"] = -0.01 * t
        DrawColorModify(tab)
    end
end)

hook.Add("OnPlayerChangedTeam", "SCP6243_ClearOnRespawn", function(ply)
    if ply == LocalPlayer() then
        for id, fx in pairs(activeClientFX) do
            if fx.sound and fx.sound.Stop then fx.sound:Stop() end
        end
        activeClientFX = {}
    end
end)