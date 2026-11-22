local C = SCPRPEvents.Config
local current = nil
local announcement = nil

local colors = {
    info = Color(70, 150, 220),
    danger = Color(220, 65, 65),
    success = Color(65, 190, 120)
}

surface.CreateFont("SCPRPEvents_Title", {
    font = "Roboto",
    size = 28,
    weight = 900,
    extended = true
})

surface.CreateFont("SCPRPEvents_Body", {
    font = "Roboto",
    size = 18,
    weight = 500,
    extended = true
})

net.Receive("SCPRPEvents_Announcement", function()
    announcement = {
        Title = net.ReadString(),
        Text = net.ReadString(),
        EndTime = CurTime() + net.ReadFloat(),
        Color = colors[net.ReadString()] or colors.info
    }
    surface.PlaySound("ambient/alarms/klaxon1.wav")
    chat.AddText(announcement.Color, "[SITE EVENT] ", color_white, announcement.Title .. " — " .. announcement.Text)
end)

net.Receive("SCPRPEvents_State", function()
    if not net.ReadBool() then
        current = nil
        return
    end

    current = {
        Id = net.ReadString(),
        Title = net.ReadString(),
        Description = net.ReadString(),
        Effect = net.ReadString(),
        EndTime = net.ReadFloat()
    }
end)

hook.Add("HUDPaint", "SCPRPEvents_HUD", function()
    if not C.UseBuiltInHUD then return end

    if announcement and announcement.EndTime > CurTime() then
        local remaining = announcement.EndTime - CurTime()
        local alpha = math.Clamp(math.min(remaining * 2, 1) * 255, 0, 255)
        local width = math.min(ScrW() - 40, 720)
        local x = (ScrW() - width) / 2
        local y = 65

        draw.RoundedBox(8, x, y, width, 92, Color(10, 14, 20, alpha * 0.94))
        draw.RoundedBox(8, x, y, 6, 92, ColorAlpha(announcement.Color, alpha))
        draw.SimpleText(announcement.Title, "SCPRPEvents_Title", ScrW() / 2, y + 25, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(announcement.Text, "SCPRPEvents_Body", ScrW() / 2, y + 62, Color(220, 225, 230, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    if current and current.EndTime > CurTime() then
        local seconds = math.max(0, math.ceil(current.EndTime - CurTime()))
        local text = current.Title .. "  •  " .. string.FormattedTime(seconds, "%02i:%02i")
        draw.RoundedBox(6, ScrW() / 2 - 145, 12, 290, 34, Color(10, 14, 20, 210))
        draw.SimpleText(text, "SCPRPEvents_Body", ScrW() / 2, 29, Color(235, 240, 245), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local exposure = LocalPlayer():GetNWFloat("SCPRPEvents_008Exposure", 0)
    local transformed = LocalPlayer():GetNWBool("SCPRPEvents_008Transformed", false)
    if exposure > 0 or transformed then
        local width = 260
        local x = ScrW() / 2 - width / 2
        local y = ScrH() - 92
        draw.RoundedBox(6, x, y, width, 45, Color(8, 15, 8, 225))
        draw.SimpleText(
            transformed and "SCP-008-2 INSTANCE" or
                (LocalPlayer():GetNWBool("SCPRPEvents_008Infected", false) and "SCP-008 INFECTION" or "SCP-008 EXPOSURE"),
            "SCPRPEvents_Body",
            ScrW() / 2,
            y + 13,
            Color(190, 235, 95),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
        draw.RoundedBox(3, x + 20, y + 29, width - 40, 8, Color(35, 45, 35))
        draw.RoundedBox(3, x + 20, y + 29, (width - 40) * math.Clamp(exposure / 100, 0, 1), 8, transformed and Color(195, 55, 55) or Color(150, 220, 70))
    end

    local exposure610 = LocalPlayer():GetNWFloat("SCPRPEvents_610Exposure", 0)
    local transformed610 = LocalPlayer():GetNWBool("SCPRPEvents_610Transformed", false)
    if exposure610 > 0 or transformed610 then
        local width = 260
        local x = ScrW() / 2 - width / 2
        local y = (exposure > 0 or transformed) and (ScrH() - 145) or (ScrH() - 92)
        draw.RoundedBox(6, x, y, width, 45, Color(20, 7, 7, 225))
        draw.SimpleText(
            transformed610 and "SCP-610 INSTANCE" or "SCP-610 EXPOSURE",
            "SCPRPEvents_Body",
            ScrW() / 2,
            y + 13,
            Color(235, 95, 80),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
        draw.RoundedBox(3, x + 20, y + 29, width - 40, 8, Color(55, 25, 25))
        draw.RoundedBox(3, x + 20, y + 29, (width - 40) * math.Clamp(exposure610 / 100, 0, 1), 8, Color(215, 60, 45))
    end

    local cognitoExposure = LocalPlayer():GetNWFloat("SCPRPEvents_CognitoExposure", 0)
    local cognitoExposed = LocalPlayer():GetNWBool("SCPRPEvents_CognitoExposed", false)
    if cognitoExposure > 0 or cognitoExposed then
        local width = 260
        local x = ScrW() / 2 - width / 2
        local y = ScrH() - 92
        if exposure > 0 or transformed then y = y - 53 end
        if exposure610 > 0 or transformed610 then y = y - 53 end

        draw.RoundedBox(6, x, y, width, 45, Color(18, 10, 28, 225))
        draw.SimpleText(
            cognitoExposed and "COGNITOHAZARD EXPOSED" or "COGNITOHAZARD STATIC",
            "SCPRPEvents_Body",
            ScrW() / 2,
            y + 13,
            Color(205, 145, 255),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
        draw.RoundedBox(3, x + 20, y + 29, width - 40, 8, Color(42, 30, 54))
        draw.RoundedBox(3, x + 20, y + 29, (width - 40) * math.Clamp(cognitoExposure / 100, 0, 1), 8, Color(185, 95, 235))
    end

    if LocalPlayer():GetNWBool("SCPRPEvents_MedicalScreening", false) then
        local width = 280
        local x = ScrW() / 2 - width / 2
        local y = ScrH() - 198
        draw.RoundedBox(6, x, y, width, 40, Color(8, 18, 24, 225))
        draw.SimpleText(
            LocalPlayer():GetNWBool("SCPRPEvents_AnomalousCarrier", false) and "ABNORMAL READINGS DETECTED" or "MEDICAL SCREENING REQUIRED",
            "SCPRPEvents_Body",
            ScrW() / 2,
            y + 20,
            Color(115, 220, 255),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    end
end)

hook.Add("RenderScreenspaceEffects", "SCPRPEvents_Effects", function()
    if not current or current.EndTime <= CurTime() then return end

    if current.Effect == "resonance" then
        DrawColorModify({
            ["$pp_colour_addr"] = 0.025,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0.04,
            ["$pp_colour_brightness"] = 0,
            ["$pp_colour_contrast"] = 1.05,
            ["$pp_colour_colour"] = 0.88,
            ["$pp_colour_mulr"] = 0.02,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0.03
        })
    elseif current.Effect == "biohazard" then
        local exposure = math.max(
            LocalPlayer():GetNWFloat("SCPRPEvents_008Exposure", 0),
            LocalPlayer():GetNWFloat("SCPRPEvents_610Exposure", 0)
        ) / 100
        DrawColorModify({
            ["$pp_colour_addr"] = exposure * 0.025,
            ["$pp_colour_addg"] = exposure * 0.035,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = -exposure * 0.025,
            ["$pp_colour_contrast"] = 1 + exposure * 0.08,
            ["$pp_colour_colour"] = 1 - exposure * 0.3,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = exposure * 0.04,
            ["$pp_colour_mulb"] = 0
        })
    elseif current.Effect == "cognito" then
        local exposure = LocalPlayer():GetNWFloat("SCPRPEvents_CognitoExposure", 0) / 100
        DrawColorModify({
            ["$pp_colour_addr"] = exposure * 0.035,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = exposure * 0.045,
            ["$pp_colour_brightness"] = -exposure * 0.025,
            ["$pp_colour_contrast"] = 1 + exposure * 0.12,
            ["$pp_colour_colour"] = 1 - exposure * 0.45,
            ["$pp_colour_mulr"] = exposure * 0.03,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = exposure * 0.05
        })
    elseif current.Effect == "temporal" then
        local pulse = (math.sin(CurTime() * 5) + 1) * 0.5
        DrawColorModify({
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = pulse * 0.018,
            ["$pp_colour_addb"] = pulse * 0.04,
            ["$pp_colour_brightness"] = 0,
            ["$pp_colour_contrast"] = 1.04 + pulse * 0.04,
            ["$pp_colour_colour"] = 0.82 + pulse * 0.15,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = pulse * 0.02,
            ["$pp_colour_mulb"] = pulse * 0.04
        })
    elseif current.Effect == "sinkhole" then
        local pulse = (math.sin(CurTime() * 7) + 1) * 0.5
        DrawColorModify({
            ["$pp_colour_addr"] = pulse * 0.018,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = pulse * 0.025,
            ["$pp_colour_brightness"] = -0.015 - pulse * 0.015,
            ["$pp_colour_contrast"] = 1.12 + pulse * 0.08,
            ["$pp_colour_colour"] = 0.78,
            ["$pp_colour_mulr"] = pulse * 0.025,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = pulse * 0.035
        })
    elseif current.Effect == "power" then
        local flicker = math.random() > 0.92 and 0.08 or 0
        DrawColorModify({
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = flicker,
            ["$pp_colour_addb"] = flicker,
            ["$pp_colour_brightness"] = -0.09 + flicker,
            ["$pp_colour_contrast"] = 1.15,
            ["$pp_colour_colour"] = 0.65,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0.015,
            ["$pp_colour_mulb"] = 0.025
        })
    end
end)
