-- cl_init.lua
-- Clientside for SCP-028-1 (Knowledge Stone)
-- Foundation-style UI, debuff messages, and dizziness screen effects

include("shared.lua")

if CLIENT then
    -- Fonts
    surface.CreateFont("SCP0281_Header", {font = "Roboto", size = 24, weight = 800, antialias = true})
    surface.CreateFont("SCP0281_Sub", {font = "Roboto", size = 16, weight = 600, antialias = true})
    surface.CreateFont("SCP0281_Body", {font = "Roboto", size = 16, weight = 500, antialias = true})
    surface.CreateFont("SCP0281_Rarity", {font = "Roboto", size = 14, weight = 700, antialias = true})
    surface.CreateFont("SCP0281_Debuff", {font = "Roboto", size = 32, weight = 800, antialias = true})
    surface.CreateFont("SCP0281_Button", {font = "Roboto", size = 18, weight = 700, antialias = true})

    local rarityColors = {
        COMMON = Color(180, 180, 180),
        UNCOMMON = Color(90, 180, 90),
        RARE = Color(200, 120, 40)
    }

    -- Debuff HUD state
    local lastDebuffText = ""
    local lastDebuffEnd = 0

    -- Create Foundation-style knowledge frame
    local function CreateFoundationFrame(text, rarity)
        local w, h = 640, 320
        local frame = vgui.Create("DFrame")
        frame:SetSize(w, h)
        frame:Center()
        frame:SetTitle("")
        frame:ShowCloseButton(false)
        frame:MakePopup()
        frame:SetDraggable(true)
        frame:SetKeyboardInputEnabled(true)

        frame.Paint = function(self, fw, fh)
            draw.RoundedBox(6, 0, 0, fw, fh, Color(18, 18, 18))
            draw.RoundedBoxEx(6, 0, 0, fw, 48, Color(12, 12, 12), true, true, false, false)
            surface.SetDrawColor(60, 60, 60, 120)
            surface.DrawRect(0, 48, fw, 1)

            -- Header text (updated)
            draw.SimpleText("The Stone Gives you knowledge", "SCP0281_Header", 18, 10, Color(230,230,230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText("Foundation Research Terminal", "SCP0281_Sub", fw - 18, 14, Color(150,150,150), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

            local col = rarityColors[rarity] or rarityColors.COMMON
            surface.SetDrawColor(col.r, col.g, col.b, 200)
            surface.DrawRect(0, fh - 8, fw, 8)
        end

        -- Icon panel
        local iconPanel = vgui.Create("DPanel", frame)
        iconPanel:SetPos(16, 68)
        iconPanel:SetSize(80, 80)
        iconPanel.Paint = function(self, iw, ih)
            draw.RoundedBox(4, 0, 0, iw, ih, Color(28, 28, 28))
            draw.SimpleText("KS", "SCP0281_Header", iw/2, ih/2 - 8, Color(200,200,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("028-1", "SCP0281_Sub", iw/2, ih/2 + 18, Color(140,140,140), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        -- Rarity label
        local rarityLabel = vgui.Create("DLabel", frame)
        rarityLabel:SetPos(110, 66)
        rarityLabel:SetSize(w - 260, 20)
        rarityLabel:SetFont("SCP0281_Rarity")
        rarityLabel:SetTextColor(rarityColors[rarity] or rarityColors.COMMON)
        rarityLabel:SetText("Rarity: " .. (rarity or "COMMON"))

        -- Metadata line
        local meta = vgui.Create("DLabel", frame)
        meta:SetPos(110, 88)
        meta:SetSize(w - 260, 18)
        meta:SetFont("SCP0281_Sub")
        meta:SetTextColor(Color(140,140,140))
        meta:SetText("Logged to Foundation Archive | " .. os.date("%Y-%m-%d %H:%M:%S"))

        -- Scrollable knowledge body
        local scroll = vgui.Create("DScrollPanel", frame)
        scroll:SetPos(110, 112)
        scroll:SetSize(w - 260, 140)
        scroll.Paint = function() end

        local body = vgui.Create("DLabel", scroll)
        body:Dock(TOP)
        body:SetFont("SCP0281_Body")
        body:SetTextColor(Color(230,230,230))
        body:SetWrap(true)
        body:SetAutoStretchVertical(true)
        body:SetText(text)
        body:SizeToContents()

        -- Acknowledge button (restyled: black with white outline and white text)
        local btnClose = vgui.Create("DButton", frame)
        btnClose:SetText("Acknowledge")
        btnClose:SetFont("SCP0281_Button")
        btnClose:SetPos(w - 160, h - 64)
        btnClose:SetSize(132, 40)
        btnClose.DoClick = function()
            frame:Close()
        end
        btnClose.Paint = function(self, bw, bh)
            -- black background
            draw.RoundedBox(6, 0, 0, bw, bh, Color(10,10,10))
            -- white outline
            surface.SetDrawColor(255,255,255,200)
            surface.DrawOutlinedRect(0,0,bw,bh)
            -- text (white)
            draw.SimpleText(self:GetText(), "SCP0281_Button", bw/2, bh/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        return frame
    end

    -- Network receivers
    net.Receive("SCP0281_ShowKnowledge", function()
        local text = net.ReadString()
        local rarity = net.ReadString()
        CreateFoundationFrame(text, rarity)
    end)

    net.Receive("SCP0281_DebuffMsg", function()
        lastDebuffText = net.ReadString()
        local dur = net.ReadFloat() or 10
        lastDebuffEnd = CurTime() + dur
        surface.PlaySound("ambient/voices/citizen_beaten1.wav")
    end)

    -- Screen effects: buffs and penalties
    hook.Add("RenderScreenspaceEffects", "SCP0281_FoundationEffects", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local now = CurTime()
        local buffEnd = ply:GetNWFloat("SCP0281_BuffEnd", 0)
        local penEnd = ply:GetNWFloat("SCP0281_PenaltyEnd", 0)

        if now < buffEnd then
            local amt = math.Clamp((buffEnd - now) / 30, 0, 1)
            DrawSharpen(0.12 * amt, 1)
            DrawColorModify({
                ["$pp_colour_addr"] = 0.01 * amt,
                ["$pp_colour_addg"] = 0.01 * amt,
                ["$pp_colour_addb"] = 0.01 * amt,
                ["$pp_colour_brightness"] = 0.01 * amt,
                ["$pp_colour_contrast"] = 1 + (0.04 * amt),
                ["$pp_colour_colour"] = 1 + (0.04 * amt)
            })
        end

        if now < penEnd then
            local amt = math.Clamp((penEnd - now) / 30, 0, 1)
            DrawMotionBlur(0.18 * amt, 0.8 * amt, 0.01 * amt)
            DrawBloom(0.35 * amt, 1.0 * amt, 9, 9, 1, 1, 255, 255, 255)
            DrawColorModify({
                ["$pp_colour_addr"] = -0.02 * amt,
                ["$pp_colour_addg"] = -0.02 * amt,
                ["$pp_colour_addb"] = -0.02 * amt,
                ["$pp_colour_brightness"] = -0.03 * amt,
                ["$pp_colour_contrast"] = 1 - (0.08 * amt),
                ["$pp_colour_colour"] = 0.6 - (0.35 * (1-amt))
            })

            -- Vignette
            surface.SetDrawColor(0, 0, 0, 120 * amt)
            surface.DrawRect(0, 0, ScrW(), ScrH())

            -- Subtle wobble overlay
            local wobbleX = math.sin(CurTime() * 3.2) * (6 * amt)
            local wobbleY = math.cos(CurTime() * 2.1) * (4 * amt)
            cam.Start2D()
                surface.SetDrawColor(255, 255, 255, 8 * amt)
                surface.DrawRect(wobbleX, wobbleY, ScrW(), ScrH())
            cam.End2D()
        end
    end)

    -- Debuff HUD: red text with outline
    hook.Add("HUDPaint", "SCP0281_FoundationDebuffHUD", function()
        if CurTime() < lastDebuffEnd and lastDebuffText ~= "" then
            local remaining = lastDebuffEnd - CurTime()
            local alpha = math.Clamp(remaining / 5, 0, 1)
            local col = Color(255, 90, 90, 255 * alpha)
            draw.SimpleTextOutlined(lastDebuffText, "SCP0281_Debuff", ScrW() / 2, ScrH() * 0.14, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, Color(0,0,0,200))
        end
    end)

    -- Hover hint: shows stone global cooldown and your personal cooldown
    hook.Add("HUDPaint", "SCP0281_EntityHintWithCooldown", function()
        local tr = LocalPlayer():GetEyeTrace()
        if not tr or not tr.Entity or not IsValid(tr.Entity) then return end
        local ent = tr.Entity
        if ent:GetClass() ~= "scp028_1" and ent:GetClass() ~= "ent_scp_028_1" then return end

        local hintX, hintY = ScrW() / 2, ScrH() * 0.85
        local hint = "SCP-028-1 — Knowledge Stone (Use to receive knowledge)"
        draw.SimpleTextOutlined(hint, "DermaDefaultBold", hintX, hintY, Color(220,220,220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,200))

        local now = CurTime()
        local nextUse = ent:GetNWFloat("SCP0281_NextUse", 0)
        if nextUse > now then
            local gWait = math.max(0, math.Round(nextUse - now, 1))
            local gText = "Stone cooldown: " .. gWait .. "s"
            draw.SimpleTextOutlined(gText, "DermaDefault", hintX, hintY + 20, Color(200,200,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,200))
        end

        local pEnd = LocalPlayer():GetNWFloat("SCP0281_PlayerCooldownEnd", 0)
        if pEnd > now then
            local pWait = math.max(0, math.Round(pEnd - now, 1))
            local pText = "Your cooldown: " .. pWait .. "s"
            draw.SimpleTextOutlined(pText, "DermaDefault", hintX, hintY + 40, Color(200,200,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,200))
        end
    end)
end