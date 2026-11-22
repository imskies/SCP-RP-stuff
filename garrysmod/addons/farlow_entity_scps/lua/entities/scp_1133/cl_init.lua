include("shared.lua")

-- Fonts
surface.CreateFont("SCP_Header", {
    font = "Roboto",
    size = 20,
    weight = 700,
})

surface.CreateFont("SCP_Sub", {
    font = "Roboto",
    size = 16,
    weight = 500,
})

surface.CreateFont("SCP_Button", {
    font = "Roboto",
    size = 20,
    weight = 600,
})

surface.CreateFont("SCP_Status", {
    font = "Roboto",
    size = 16,
    weight = 500,
})

-- Chat messages
net.Receive("scp1133_Chat", function()
    local ent = net.ReadEntity()
    local msg = net.ReadString()
    if not IsValid(ent) then return end
    chat.AddText(Color(255, 100, 100), "[SCP-1133] ", Color(255,255,255), msg or "")
end)

-- Effect state
local Eff = { kind = nil, expire = 0, fade = 0 }

local function startEffect(kind, duration)
    Eff.kind   = kind
    Eff.expire = CurTime() + duration   -- FIXED: removed "or 10"
    Eff.fade   = 1

    local sounds = {
        PrideInfuse     = "buttons/button9.wav",
        PrideExtract    = "player/pl_pain5.wav",
        GreedInfuse     = "items/suitchargeok1.wav",
        GreedExtract    = "items/suitchargeno1.wav",
        LustInfuse      = "ambient/levels/labs/equipment1.wav",
        LustExtract     = "ambient/levels/labs/equipment2.wav",
        EnvyInfuse      = "buttons/button17.wav",
        EnvyExtract     = "buttons/button11.wav",
        GluttonyInfuse  = "npc/zombie/zombie_pain1.wav",
        GluttonyExtract = "npc/zombie/zombie_pain4.wav",
        WrathInfuse     = "weapons/physcannon/energy_sing_explosion2.wav",
        WrathExtract    = "weapons/physcannon/physcannon_claws_close.wav",
        SlothInfuse     = "player/footsteps/dirt1.wav",
        SlothExtract    = "player/footsteps/dirt4.wav"
    }

    if sounds[kind] then
        surface.PlaySound(sounds[kind])
    end
end

net.Receive("scp1133_Effect", function()
    local kind = net.ReadString()
    local dur  = net.ReadFloat()
    startEffect(kind, dur)
end)

local function clearEffect()
    Eff.kind   = nil
    Eff.expire = 0
    Eff.fade   = 0
end

hook.Add("PlayerDeath", "scp1133_clearVisuals", function(ply)
    if ply == LocalPlayer() then clearEffect() end
end)
hook.Add("PlayerSilentDeath", "scp1133_clearVisualsSilent", function(ply)
    if ply == LocalPlayer() then clearEffect() end
end)
hook.Add("PlayerSpawn", "scp1133_clearVisualsSpawn", function(ply)
    if ply == LocalPlayer() then clearEffect() end
end)

hook.Add("RenderScreenspaceEffects", "scp1133_screenspace", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    -- FIX: instantly clear effects on death
    if not ply:Alive() then
        clearEffect()
        return
    end

    if not Eff.kind then return end

    local now = CurTime()
    if now > Eff.expire then
        Eff.fade = math.max(Eff.fade - FrameTime() * 0.5, 0)
        if Eff.fade <= 0 then
            clearEffect()
            return
        end
    else
        Eff.fade = math.min(Eff.fade + FrameTime() * 2, 1)
    end

    local fade = Eff.fade
    local cm = {
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = 1,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    }

    local sharpen, blur = 0, 0
    local k = Eff.kind

    if k == "PrideInfuse" then
        cm["$pp_colour_contrast"] = 1.2
        cm["$pp_colour_colour"]   = 1.2
        sharpen = 1.0
    elseif k == "PrideExtract" then
        cm["$pp_colour_contrast"] = 0.9
        cm["$pp_colour_colour"]   = 0.85
        blur = 0.5
    elseif k == "GreedInfuse" then
        cm["$pp_colour_addg"]     = 0.06
        cm["$pp_colour_contrast"] = 1.1
    elseif k == "GreedExtract" then
        cm["$pp_colour_contrast"] = 0.95
        cm["$pp_colour_colour"]   = 0.9
        blur = 0.4
    elseif k == "LustInfuse" then
        cm["$pp_colour_addr"]     = 0.06
        cm["$pp_colour_addb"]     = 0.06
        cm["$pp_colour_colour"]   = 1.3
    elseif k == "LustExtract" then
        cm["$pp_colour_contrast"] = 0.95
        cm["$pp_colour_colour"]   = 0.9
        blur = 0.3
    elseif k == "EnvyInfuse" then
        cm["$pp_colour_addg"]     = 0.05
        cm["$pp_colour_contrast"] = 1.05
        sharpen = 0.6
    elseif k == "EnvyExtract" then
        cm["$pp_colour_contrast"] = 0.95
        cm["$pp_colour_colour"]   = 0.85
        blur = 0.3
    elseif k == "GluttonyInfuse" then
        cm["$pp_colour_brightness"] = 0.03
        cm["$pp_colour_contrast"]   = 1.05
        blur = 0.6
    elseif k == "GluttonyExtract" then
        cm["$pp_colour_contrast"] = 0.95
        sharpen = 0.5
    elseif k == "WrathInfuse" then
        cm["$pp_colour_mulr"]     = 0.15
        cm["$pp_colour_contrast"] = 1.2
        sharpen = 1.2
    elseif k == "WrathExtract" then
        cm["$pp_colour_mulb"]     = 0.05
        cm["$pp_colour_contrast"] = 0.9
        blur = 0.6
    elseif k == "SlothInfuse" then
        cm["$pp_colour_brightness"] = -0.03
        cm["$pp_colour_contrast"]   = 0.9
        cm["$pp_colour_colour"]     = 0.85
        blur = 0.8
    elseif k == "SlothExtract" then
        cm["$pp_colour_brightness"] = 0.02
        cm["$pp_colour_contrast"]   = 1.1
        cm["$pp_colour_colour"]     = 1.1
        sharpen = 0.8
    end

    for key, val in pairs(cm) do
        cm[key] = Lerp(fade, 0, val)
    end

    DrawColorModify(cm)
    if blur > 0 then
        DrawMotionBlur(0.1, blur * fade, 0.01)
    end
    if sharpen > 0 then
        DrawSharpen(sharpen * fade, 1.0)
    end
end)

-- Dossier-style button painter
local function PaintButton(self, w, h, base)
    local hover = self:IsHovered()
    local bg = hover and Color(base.r - 15, base.g - 15, base.b - 15, base.a) or base

    draw.RoundedBox(4, 0, 0, w, h, bg)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(0, 0, w, h, 2)

    draw.SimpleText(self:GetText(), "SCP_Button", w / 2 + 1, h / 2 + 1,
        Color(0, 0, 0, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(self:GetText(), "SCP_Button", w / 2, h / 2,
        Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- Menu
net.Receive("scp1133_OpenMenu", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end

    local frame = vgui.Create("DFrame")
    frame:SetTitle("")
    frame:SetSize(420, 210)
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(true)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(220, 222, 228, 255))
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawOutlinedRect(0, 0, w, h, 2)

        draw.SimpleText("SCP FOUNDATION — PROCEDURE TERMINAL", "SCP_Header",
            16, 12, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        draw.SimpleText("SCP-1133: IV POLE", "SCP_Sub",
            16, 40, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawLine(12, 64, w - 12, 64)

        draw.SimpleText("Procedure Selection", "SCP_Sub",
            16, 72, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local infuseBtn = vgui.Create("DButton", frame)
    infuseBtn:SetPos(30, 100)
    infuseBtn:SetSize(160, 80)
    infuseBtn:SetText("INFUSE")
    infuseBtn:SetFont("SCP_Button")
    infuseBtn.Paint = function(self, w, h)
        PaintButton(self, w, h, Color(235, 235, 235, 255))
    end
    infuseBtn.DoClick = function()
        net.Start("scp1133_ApplyChoice")
            net.WriteEntity(ent)
            net.WriteString("Infuse")
        net.SendToServer()
        frame:Close()
    end

    local extractBtn = vgui.Create("DButton", frame)
    extractBtn:SetPos(230, 100)
    extractBtn:SetSize(160, 80)
    extractBtn:SetText("EXTRACT")
    extractBtn:SetFont("SCP_Button")
    extractBtn.Paint = function(self, w, h)
        PaintButton(self, w, h, Color(235, 235, 235, 255))
    end
    extractBtn.DoClick = function()
        net.Start("scp1133_ApplyChoice")
            net.WriteEntity(ent)
            net.WriteString("Extract")
        net.SendToServer()
        frame:Close()
    end
end)

-- Prompt when looking at SCP-1133
hook.Add("HUDPaint", "scp1133_prompt", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local tr = ply:GetEyeTrace()
    local ent = tr and tr.Entity
    if not IsValid(ent) or ent:GetClass() ~= "scp_1133" then return end
    if tr.HitPos:DistToSqr(ply:GetShootPos()) > (150 * 150) then return end

    local txt = "Press E to interact with SCP-1133"
    surface.SetFont("Trebuchet24")
    local tw, th = surface.GetTextSize(txt)
    surface.SetTextColor(255, 255, 255, 220)
    surface.SetTextPos(ScrW() * 0.5 - tw * 0.5, ScrH() * 0.85)
    surface.DrawText(txt)
end)

hook.Add("EntityRemoved", "scp1133_clearOnRemove", function(ent)
    if IsValid(ent) and ent:GetClass() == "scp_1133" then
        clearEffect()
    end
end)

-- Current Sin Status HUD (mid-left)
local SinStatus = {
    active = false,
    name   = "",
    stacks = 0,
    expire = 0,
    dur    = 0
}

net.Receive("scp1133_Status", function()
    local active = net.ReadBool()
    if not active then
        SinStatus.active = false
        SinStatus.name   = ""
        SinStatus.stacks = 0
        SinStatus.expire = 0
        SinStatus.dur    = 0
        return
    end

    local name   = net.ReadString()
    local stacks = net.ReadUInt(3)
    local dur    = net.ReadFloat()

    SinStatus.active = true
    SinStatus.name   = name
    SinStatus.stacks = stacks
    SinStatus.dur    = dur
    SinStatus.expire = CurTime() + dur
end)

hook.Add("HUDPaint", "scp1133_sinStatusHUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    if not SinStatus.active then return end

    local now = CurTime()
    local remaining = math.max(SinStatus.expire - now, 0)
    if remaining <= 0 then return end

    local w, h = 260, 90
    local x = 20
    local y = ScrH() * 0.5 - (h * 0.5)

    draw.RoundedBox(4, x, y, w, h, Color(220, 222, 228, 255))
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(x, y, w, h, 2)

    draw.SimpleText("SCP-1133 STATUS", "SCP_Header",
        x + 10, y + 8, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    local sinText = string.upper(SinStatus.name or "UNKNOWN")
    if SinStatus.stacks and SinStatus.stacks > 1 then
        sinText = sinText .. " (x" .. SinStatus.stacks .. ")"
    end

    draw.SimpleText("Current Sin: " .. sinText, "SCP_Status",
        x + 10, y + 34, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    local barW, barH = w - 20, 14
    local barX, barY = x + 10, y + h - barH - 10
    local frac = math.Clamp(remaining / (SinStatus.dur > 0 and SinStatus.dur or 1), 0, 1)

    draw.RoundedBox(4, barX, barY, barW, barH, Color(200, 202, 210, 255))
    draw.RoundedBox(4, barX, barY, barW * frac, barH, Color(60, 60, 60, 255))

    draw.SimpleText(string.format("Time Remaining: %.1fs", remaining), "SCP_Status",
        barX + barW / 2, barY - 4, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end)