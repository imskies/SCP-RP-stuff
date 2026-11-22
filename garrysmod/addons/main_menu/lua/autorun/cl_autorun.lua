if SERVER then return end

local BACKGROUND_BOOT = Material("bg2.png", "smooth")
local BACKGROUND_MAIN = Material("bg1.png", "smooth")
local SCP_LOGO = Material("scp_logo.png", "smooth")
local SCP_LOGO_LIGHT = Material("scp_logo_light.png", "smooth")

-- Fixed CalcView camera. Set `CALCVIEW_ORIGIN` to `nil` to use the player-relative offset fallback.
local CALCVIEW_ORIGIN = Vector(-14536.932617, -6088.538574, -1989.855713)
local CALCVIEW_OFFSET = Vector(-72, 26, 10)
local CALCVIEW_ANGLES = Angle(13.175174, 52.693237, 0)

local MENU_PANEL
local FONTS_READY = false

local COLOR_WHITE = Color(255, 255, 255)
local COLOR_TEXT_SOFT = Color(255, 255, 255, 185)
local COLOR_TEXT_FAINT = Color(255, 255, 255, 120)
local BUTTON_HOVER_SOUND = "other/oakman/deadspace/ui/tic.wav"
local BUTTON_CLICK_SOUND = "other/oakman/deadspace/ui/hud_save_confirm.wav"
local MENU_AMBIENT_PATH = "menu_amb.mp3"
local MENU_AMBIENT_STATION

local function DrawRGBScanlines(x, y, w, h, alphaScale, spacing)
    alphaScale = alphaScale or 1
    spacing = spacing or 4

    for lineY = y, y + h, spacing do
        surface.SetDrawColor(255, 70, 70, math.floor(3 * alphaScale))
        surface.DrawRect(x - 1, lineY, w, 1)
        surface.SetDrawColor(80, 255, 180, math.floor(3 * alphaScale))
        surface.DrawRect(x, lineY, w, 1)
        surface.SetDrawColor(90, 170, 255, math.floor(4 * alphaScale))
        surface.DrawRect(x + 1, lineY, w, 1)
    end
end

local function DrawBootCalcView(w, h)
    local ply = LocalPlayer()

    if not IsValid(ply) then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(BACKGROUND_MAIN)
        surface.DrawTexturedRect(0, 0, w, h)
        return
    end

    local time = CurTime()
    local swayPitch = math.cos(time * 0.75) * 0.9
    local swayYaw = math.sin(time * 0.5) * 1.8
    local swayRoll = math.sin(time * 0.95) * 0.6

    local viewAngles = Angle(
        CALCVIEW_ANGLES.p + swayPitch,
        CALCVIEW_ANGLES.y + swayYaw,
        CALCVIEW_ANGLES.r + swayRoll
    )

    render.RenderView({
        origin = CALCVIEW_ORIGIN,
        angles = viewAngles,
        x = 0,
        y = 0,
        w = w,
        h = h,
        fov = ply:GetFOV(),
        drawviewmodel = false,
        drawhud = false,
        dopostprocess = true
    })
end

local function StopMenuAmbient()
    if MENU_AMBIENT_STATION then
        MENU_AMBIENT_STATION:Stop()
        MENU_AMBIENT_STATION = nil
    end
end

local function StartMenuAmbient()
    local ply = LocalPlayer()
    if not IsValid(ply) then
        timer.Simple(0, function()
            if IsValid(MENU_PANEL) then
                StartMenuAmbient()
            end
        end)
        return
    end

    StopMenuAmbient()

    MENU_AMBIENT_STATION = CreateSound(ply, MENU_AMBIENT_PATH)
    if MENU_AMBIENT_STATION then
        MENU_AMBIENT_STATION:PlayEx(0.12, 100)
    end
end

local function EnsureFonts()
    if FONTS_READY then return end

    surface.CreateFont("SCP.Menu.Title", {
        font = "Bauhaus Light",
        size = 46,
        weight = 500,
        antialias = true,
        extended = true
    })

    surface.CreateFont("SCP.Menu.Subtitle", {
        font = "DIN Pro Medium",
        size = 20,
        weight = 500,
        antialias = true,
        extended = true
    })

    surface.CreateFont("SCP.Menu.Button", {
        font = "DIN Pro Medium",
        size = 22,
        weight = 500,
        antialias = true,
        extended = true
    })

    surface.CreateFont("SCP.Menu.Body", {
        font = "DIN Pro Regular",
        size = 17,
        weight = 400,
        antialias = true,
        extended = true
    })

    surface.CreateFont("SCP.Menu.Small", {
        font = "DIN Pro Regular",
        size = 14,
        weight = 400,
        antialias = true,
        extended = true
    })

    surface.CreateFont("SCP.Menu.Live", {
        font = "DIN Pro Bold",
        size = 24,
        weight = 800,
        antialias = true,
        extended = true
    })

    FONTS_READY = true
end

local function MakeMenuButton(parent, text, callback)
    local button = parent:Add("DButton")
    button:Dock(TOP)
    button:DockMargin(0, 0, 0, 12)
    button:SetTall(46)
    button:SetText("")
    button.Label = text

    button.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        self.HoverFade = Lerp(FrameTime() * 10, self.HoverFade or 0, hovered and 1 or 0)
        self.LogoSpin = Lerp(FrameTime() * 8, self.LogoSpin or 0, hovered and 1 or 0)

        if hovered and not self.WasHovered then
            surface.PlaySound(BUTTON_HOVER_SOUND)
        end

        self.WasHovered = hovered

        draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 8 + (self.HoverFade * 18)))
        surface.SetDrawColor(255, 255, 255, 40 + (self.HoverFade * 115))
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        local iconSize = 26
        local leftX = 28
        local rightX = w - 28
        local centerY = h * 0.5
        local spinAngle = self.LogoSpin * 180
        local iconAlpha = 170 + (self.HoverFade * 85)

        surface.SetMaterial(SCP_LOGO)
        surface.SetDrawColor(255, 255, 255, iconAlpha)
        surface.DrawTexturedRectRotated(leftX, centerY, iconSize, iconSize, -spinAngle)
        surface.DrawTexturedRectRotated(rightX, centerY, iconSize, iconSize, spinAngle)

        draw.SimpleText(self.Label, "SCP.Menu.Button", w * 0.5, h * 0.5, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    button.DoClick = function()
        surface.PlaySound(BUTTON_CLICK_SOUND)

        if isfunction(callback) then
            callback()
        end
    end

    return button
end

local function OpenSCPMenu()
    EnsureFonts()

    if IsValid(MENU_PANEL) then
        MENU_PANEL:Remove()
    end

    local frame = vgui.Create("EditablePanel")
    MENU_PANEL = frame
    frame:SetSize(ScrW(), ScrH())
    frame:MakePopup()
    frame:SetKeyboardInputEnabled(true)
    frame:SetMouseInputEnabled(true)
    frame:SetAlpha(0)
    frame:AlphaTo(255, 0.2, 0)
    frame.NextGlitch = CurTime() + 0.75
    frame.GlitchEnd = 0
    frame.LoadStart = CurTime()
    frame.LoadDuration = 5.4
    frame.LoadComplete = false
    frame.CCTVStrength = 0
    frame.CloseProgress = 0
    frame.OpenProgress = 0
    frame.TransitionStart = nil
    frame.TransitionDurationOut = 1.6
    frame.TransitionHold = 1.0
    frame.TransitionDurationIn = 1.05
    frame.MenuRevealStarted = false
    frame.ExitStarted = false
    frame.ExitDuration = 0.8
    frame.ExitHold = 0.14
    frame.ExitRevealDuration = 0.28
    frame.ExitFadeStarted = false

    StartMenuAmbient()

    frame.OnRemove = function()
        StopMenuAmbient()
    end

    frame.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE then
            self:Remove()
        end
    end

    local shell, description, buttonWrap

    function frame:BeginGameplayExit()
        if self.ExitStarted then return end

        self.ExitStarted = true
        self.ExitStart = CurTime()
        self:SetMouseInputEnabled(false)
        self:SetKeyboardInputEnabled(false)

        if IsValid(shell) then
            shell:AlphaTo(0, 0.18, 0)
        end

        if IsValid(description) then
            description:AlphaTo(0, 0.14, 0)
        end

        if IsValid(buttonWrap) then
            buttonWrap:SetMouseInputEnabled(false)
            buttonWrap:AlphaTo(0, 0.14, 0)
        end
    end

    frame.Paint = function(self, w, h)
        if CurTime() >= self.NextGlitch then
            self.GlitchEnd = CurTime() + math.Rand(0.05, 0.14)
            self.NextGlitch = CurTime() + math.Rand(0.6, 1.5)
        end

        local progress = math.Clamp((CurTime() - self.LoadStart) / self.LoadDuration, 0, 1)
        local transitionPulse = 0
        local closeFrac = 0
        local openFrac = 0

        if progress >= 1 and not self.LoadComplete then
            self.LoadComplete = true
            self.TransitionStart = CurTime()
            self.CCTVStrength = 0.3
        end

        if self.LoadComplete and self.TransitionStart then
            local elapsed = CurTime() - self.TransitionStart
            closeFrac = math.Clamp(elapsed / self.TransitionDurationOut, 0, 1)
            openFrac = closeFrac

            self.CloseProgress = closeFrac
            self.OpenProgress = openFrac
            transitionPulse = math.max(
                math.Clamp(1 - math.abs(elapsed - (self.TransitionDurationOut * 0.82)) / 0.33, 0, 1),
                math.Clamp(1 - math.abs(elapsed - (self.TransitionDurationOut * 0.55)) / 0.42, 0, 1) * 0.75
            )

            if openFrac > 0.1 and not self.MenuRevealStarted then
                self.MenuRevealStarted = true

                if IsValid(shell) then
                    shell:AlphaTo(255, 0.4, 0)
                end

                if IsValid(description) then
                    description:AlphaTo(255, 0.35, 0)
                end

                if IsValid(buttonWrap) then
                    buttonWrap:SetMouseInputEnabled(true)
                    buttonWrap:AlphaTo(255, 0.4, 0)
                end
            end
        else
            self.CloseProgress = Lerp(FrameTime() * 6, self.CloseProgress, 0)
            self.OpenProgress = Lerp(FrameTime() * 6, self.OpenProgress, 0)
        end

        local overlayActive = self.LoadComplete and self.MenuRevealStarted and self.OpenProgress >= 0.98 and not self.ExitStarted
        self.CCTVStrength = Lerp(FrameTime() * 1.1, self.CCTVStrength, overlayActive and 0.08 or 0)

        DrawBootCalcView(w, h)

        if self.OpenProgress > 0.001 then
            DrawRGBScanlines(0, 0, w, h, 1.1)

            if self.OpenProgress < 1 then
                local scanY = math.floor(h * self.OpenProgress)
                local scanAlpha = math.floor(90 * (1 - self.OpenProgress))
                surface.SetDrawColor(255, 70, 70, math.floor(scanAlpha * 0.75))
                surface.DrawRect(-2, scanY, w, 1)
                surface.SetDrawColor(80, 255, 180, math.floor(scanAlpha * 0.7))
                surface.DrawRect(0, scanY + 1, w, 1)
                surface.SetDrawColor(90, 170, 255, math.floor(scanAlpha * 0.8))
                surface.DrawRect(2, scanY + 2, w, 1)

                draw.SimpleText("ESTABLISHING VISUAL FEED", "SCP.Menu.Small", w * 0.5, scanY + 12, Color(255, 255, 255, math.floor(85 * (1 - self.OpenProgress))), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            end
        end

        if self.CloseProgress < 1 then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(BACKGROUND_BOOT)

            local segments = 22
            local segW = math.ceil(w / segments)
            local closeReveal = 1 - self.CloseProgress

            for i = 0, segments do
                local reverseIndex = segments - i
                local stagger = (reverseIndex % 5) * 0.04
                local segFrac = math.Clamp((closeReveal - stagger) / math.max(0.2, 1 - stagger), 0, 1)
                local steppedFrac = math.floor(segFrac * 8) / 8

                if steppedFrac > 0 then
                    local hiddenTop = math.floor(h * (1 - steppedFrac))
                    local drawH = math.max(1, h - hiddenTop)
                    local x = i * segW
                    local u0 = x / w
                    local u1 = math.min((x + segW) / w, 1)
                    local v0 = hiddenTop / h

                    surface.DrawTexturedRectUV(x, hiddenTop, segW, drawH, u0, v0, u1, 1)
                end
            end

            DrawRGBScanlines(0, 0, w, h, 1.1)

            if self.CloseProgress > 0.001 then
                local scanY = math.floor(h * (1 - closeReveal))
                local scanAlpha = math.floor(90 * closeReveal)
                surface.SetDrawColor(255, 70, 70, math.floor(scanAlpha * 0.75))
                surface.DrawRect(-2, scanY, w, 1)
                surface.SetDrawColor(80, 255, 180, math.floor(scanAlpha * 0.7))
                surface.DrawRect(0, scanY + 1, w, 1)
                surface.SetDrawColor(90, 170, 255, math.floor(scanAlpha * 0.8))
                surface.DrawRect(2, scanY + 2, w, 1)

                draw.SimpleText("CLOSING SECURE CHANNEL", "SCP.Menu.Small", w * 0.5, scanY - 10, Color(255, 255, 255, math.floor(85 * closeReveal)), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            end
        end

        draw.RoundedBox(0, 0, 0, w, h, Color(6, 8, 10, 205 + (progress * 22) + (transitionPulse * 18)))
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 35 + (progress * 55) + (transitionPulse * 45)))

        local menuVisible = self.LoadComplete and self.MenuRevealStarted
        DrawRGBScanlines(0, 0, w, h, menuVisible and 0.7 or 1, menuVisible and 7 or 4)

        if self.LoadComplete and self.MenuRevealStarted then
            surface.SetDrawColor(255, 255, 255, 24)
            surface.DrawOutlinedRect(28, 28, w - 56, h - 56, 1)
        end

        if CurTime() < self.GlitchEnd then
            local glitchPasses = 9
            local maxOffset = 20
            local minAlpha = 16
            local maxAlpha = 40
            local glitchColors = {
                Color(255, 70, 70),
                Color(80, 255, 180),
                Color(90, 170, 255),
                Color(255, 255, 255)
            }

            for _ = 1, glitchPasses do
                local barY = math.random(0, h)
                local barH = math.random(1, 3)
                local offset = math.random(-maxOffset, maxOffset)
                local glitchColor = glitchColors[math.random(1, #glitchColors)]

                surface.SetDrawColor(glitchColor.r, glitchColor.g, glitchColor.b, math.random(minAlpha, maxAlpha))
                surface.DrawRect(offset, barY, w, barH)
            end
        end

        if not self.LoadComplete then
            local marginX = 42
            local barW, barH = math.max(240, w - (marginX * 2)), 10
            local barX, barY = marginX, h - 96
            local innerShrink = (barW * 0.5) * progress
            local activeX = barX + innerShrink
            local activeW = math.max(10, barW - (innerShrink * 2))

            draw.SimpleText("INITIALIZING SITE ACCESS SYSTEM...", "SCP.Menu.Small", barX, barY - 18, COLOR_TEXT_SOFT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.RoundedBox(0, barX, barY, barW, barH, Color(255, 255, 255, 12))
            draw.RoundedBox(0, activeX, barY, activeW, barH, Color(255, 255, 255, 185))
        end

        if overlayActive and self.CCTVStrength > 0.02 then
            local noiseAlpha = math.floor(20 + (self.CCTVStrength * 35))
            local blinkOn = math.sin(CurTime() * 1.15) > 0.82
            local liveAlpha = 245
            local dotAlpha = blinkOn and 255 or 0

            for i = 1, 6 do
                local noiseY = math.random(40, h - 80)
                surface.SetDrawColor(255, 255, 255, math.random(noiseAlpha * 0.4, noiseAlpha))
                surface.DrawRect(math.random(-12, 12), noiseY, w, math.random(1, 2))
            end

            draw.SimpleText("LIVE", "SCP.Menu.Live", 44, 54, Color(255, 255, 255, liveAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.RoundedBox(10, w - 72, 40, 22, 22, Color(255, 60, 60, dotAlpha))
        end

        draw.SimpleText("SYSTEM ONLINE // LEVEL ### CLEARANCE", "SCP.Menu.Small", 40, h - 40, COLOR_TEXT_FAINT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(os.date("%d.%m.%Y  |  %H:%M:%S"), "SCP.Menu.Small", w - 40, h - 40, COLOR_TEXT_FAINT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

        if self.ExitStarted then
            local elapsed = CurTime() - self.ExitStart
            local exitFrac = math.Clamp(elapsed / self.ExitDuration, 0, 1)
            local segments = 22
            local segW = math.ceil(w / segments)

            for i = 0, segments do
                local reverseIndex = segments - i
                local stagger = (reverseIndex % 5) * 0.04
                local segFrac = math.Clamp((exitFrac - stagger) / math.max(0.2, 1 - stagger), 0, 1)
                local steppedFrac = math.floor(segFrac * 8) / 8

                if steppedFrac > 0 then
                    local coverH = math.max(1, math.floor(h * steppedFrac))
                    local x = i * segW

                    surface.SetDrawColor(0, 0, 0, 255)
                    surface.DrawRect(x, 0, segW, coverH)
                end
            end

            DrawRGBScanlines(0, 0, w, h, 0.9)

            if exitFrac < 1 then
                local scanY = math.floor(h * exitFrac)
                local scanAlpha = math.floor(115 * (1 - exitFrac))
                surface.SetDrawColor(255, 70, 70, math.floor(scanAlpha * 0.75))
                surface.DrawRect(-2, scanY, w, 1)
                surface.SetDrawColor(80, 255, 180, math.floor(scanAlpha * 0.7))
                surface.DrawRect(0, scanY + 1, w, 1)
                surface.SetDrawColor(90, 170, 255, math.floor(scanAlpha * 0.8))
                surface.DrawRect(2, scanY + 2, w, 1)
            end

            if exitFrac >= 1 and not self.ExitFadeStarted then
                self.ExitFadeStarted = true

                timer.Simple(self.ExitHold, function()
                    if not IsValid(self) then return end

                    self:AlphaTo(0, self.ExitRevealDuration, 0)

                    timer.Simple(self.ExitRevealDuration + 0.02, function()
                        if IsValid(self) then
                            self:Remove()
                        end
                    end)
                end)
            end
        end
    end

    shell = frame:Add("DPanel")
    shell:SetSize(math.min(540, ScrW() * 0.34), math.min(455, ScrH() * 0.56))
    shell:SetPos((ScrW() - shell:GetWide()) * 0.5, (ScrH() - shell:GetTall()) * 0.5)
    shell:SetAlpha(0)
    shell.Paint = function(_, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))

        local logoSize = math.min(w, h) * 1.75
        local logoAngle = (CurTime() * -4.4) % 360
        surface.SetMaterial(SCP_LOGO_LIGHT)
        surface.SetDrawColor(255, 255, 255, 4)
        surface.DrawTexturedRectRotated(w * 0.5, h * 0.5, logoSize, logoSize, logoAngle)

        surface.SetDrawColor(255, 255, 255, 34)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        surface.SetDrawColor(255, 255, 255, 18)
        surface.DrawRect(0, 0, w, 2)
    end

    local header = shell:Add("DPanel")
    header:Dock(TOP)
    header:DockMargin(18, 18, 18, 8)
    header:SetTall(106)
    header.Paint = function(_, w, h)
        local glitching = CurTime() < frame.GlitchEnd
        local jitterRange = 2
        local xJitter = glitching and math.random(-jitterRange, jitterRange) or 0
        local yJitter = glitching and math.random(-1, 1) or 0

        draw.SimpleText("Deep Gaming SCP-RP", "SCP.Menu.Title", xJitter, 0 + yJitter, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        if glitching then
            local ghostAlpha = 52
            draw.SimpleText("Deep Gaming SCP-RP", "SCP.Menu.Title", xJitter - 1, 0, Color(255, 70, 70, ghostAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText("Deep Gaming SCP-RP", "SCP.Menu.Title", xJitter + 1, 0, Color(80, 255, 180, ghostAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText("Deep Gaming SCP-RP", "SCP.Menu.Title", xJitter + 2, 1, Color(90, 170, 255, ghostAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        draw.SimpleText("SECURE. CONTAIN. PROTECT.", "SCP.Menu.Subtitle", 1, 56, COLOR_TEXT_SOFT, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("// TERMINAL ACCESS END-POINT //", "SCP.Menu.Small", 2, 82, COLOR_TEXT_FAINT, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        surface.SetDrawColor(255, 255, 255, 28)
        surface.DrawRect(0, h - 1, w, 1)
    end

    description = shell:Add("DLabel")
    description:Dock(TOP)
    description:DockMargin(20, 8, 20, 18)
    description:SetTall(60)
    description:SetWrap(true)
    description:SetFont("SCP.Menu.Body")
    description:SetTextColor(COLOR_TEXT_SOFT)
    description:SetText("Welcome to Deep Gaming SCP-RP. To get started please choose an option below.")
    description:SetAlpha(0)

    buttonWrap = shell:Add("DPanel")
    buttonWrap:Dock(FILL)
    buttonWrap:DockMargin(20, 0, 20, 20)
    buttonWrap.Paint = nil
    buttonWrap:SetAlpha(0)
    buttonWrap:SetMouseInputEnabled(false)

    MakeMenuButton(buttonWrap, "PLAY GAME", function()
        if IsValid(frame) then
            frame:BeginGameplayExit()
        end
    end)

    MakeMenuButton(buttonWrap, "DISCONNECT", function()
        RunConsoleCommand("disconnect")
    end)
end

concommand.Add("scp_open_menu", OpenSCPMenu)

hook.Add("InitPostEntity", "SCP.OpenMenuOnLoad", function()
    timer.Simple(0.75, function()
        if not IsValid(MENU_PANEL) then
            OpenSCPMenu()
        end
    end)
end)
