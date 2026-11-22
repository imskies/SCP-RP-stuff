local function CopyColorSafe(col, fallback)
    local src = ((IsColor and IsColor(col)) and col) or fallback or color_white
    return Color(src.r or 255, src.g or 255, src.b or 255, src.a or 255)
end

local SHARED_BG_GRAD = Material("bg_grad.png", "smooth")

local function DrawRoundedStencilMask(x, y, w, h, radius, segments)
    radius = math.max(0, math.min(radius or 0, w * 0.5, h * 0.5))
    if radius <= 0 then
        surface.DrawRect(x, y, w, h)
        return
    end

    segments = math.max(6, segments or 10)
    local poly = {}

    local function AddArc(cx, cy, startDeg, endDeg)
        for i = 0, segments do
            local frac = i / segments
            local ang = math.rad(startDeg + ((endDeg - startDeg) * frac))
            poly[#poly + 1] = {
                x = cx + math.cos(ang) * radius,
                y = cy + math.sin(ang) * radius
            }
        end
    end

    AddArc(x + w - radius, y + radius, -90, 0)
    AddArc(x + w - radius, y + h - radius, 0, 90)
    AddArc(x + radius, y + h - radius, 90, 180)
    AddArc(x + radius, y + radius, 180, 270)

    draw.NoTexture()
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawPoly(poly)
end

function PsychEval_DrawRoundedMaterial(radius, x, y, w, h, mat, col)
    if not mat or (mat.IsError and mat:IsError()) then return false end

    local tint = CopyColorSafe(col, color_white)
    local bleed = math.max(8, radius)

    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilWriteMask(0xFF)
    render.SetStencilTestMask(0xFF)
    render.SetStencilReferenceValue(1)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render.SetStencilFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilZFailOperation(STENCILOPERATION_KEEP)

    render.OverrideColorWriteEnable(true, false)
    DrawRoundedStencilMask(x, y, w, h, radius, 12)
    render.OverrideColorWriteEnable(false, false)

    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
    render.SetStencilPassOperation(STENCILOPERATION_KEEP)
    render.SetStencilFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilZFailOperation(STENCILOPERATION_KEEP)

    surface.SetMaterial(mat)
    surface.SetDrawColor(tint.r, tint.g, tint.b, tint.a or 255)
    surface.DrawTexturedRect(x - bleed, y - bleed, w + (bleed * 2), h + (bleed * 2))

    render.SetStencilEnable(false)
    render.ClearStencil()
    return true
end

function PsychEval_DrawGradientShell(radius, w, h, baseColor, tintColor, alpha, gradMat)
    local outerRadius = math.max(radius + 8, 18)
    local inset = 4
    local innerRadius = math.max(outerRadius - 2, 16)
    local innerW, innerH = w - (inset * 2), h - (inset * 2)
    local tint = CopyColorSafe(tintColor, color_white)
    local shellColor = CopyColorSafe(baseColor, Color(16, 20, 27))

    draw.RoundedBox(outerRadius, 0, 0, w, h, Color(6, 4, 10, 190))
    draw.RoundedBox(innerRadius, inset, inset, innerW, innerH, shellColor)

    local mat = gradMat or SHARED_BG_GRAD
    if mat and not (mat.IsError and mat:IsError()) then
        PsychEval_DrawRoundedMaterial(innerRadius, inset, inset, innerW, innerH, mat, Color(tint.r, tint.g, tint.b, alpha or 12))
    end
end

function PsychEval_AddWindowCloseButton(frame, font, baseColor)
    if not IsValid(frame) then return nil end

    if IsValid(frame._PsychEvalCloseButton) then
        frame._PsychEvalCloseButton:Remove()
    end

    local closeColor = CopyColorSafe(baseColor, Color(240, 244, 248))
    local closeButton = vgui.Create("DButton", frame)
    closeButton:SetSize(30, 30)
    closeButton:SetText("")
    closeButton.Think = function(s)
        if not IsValid(frame) then return end
        s:SetPos(frame:GetWide() - 42, 14)
    end
    closeButton.DoClick = function()
        if IsValid(frame) then
            frame:Close()
        end
    end
    closeButton.Paint = function(s, w, h)
        local col = s:IsHovered() and Color(220, 70, 70) or closeColor
        draw.SimpleText("✕", font or "DermaDefaultBold", w * 0.5, h * 0.5 - 1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    frame._PsychEvalCloseButton = closeButton
    return closeButton
end

function PsychEval_StyleTextEntry(entry, opts)
    if not IsValid(entry) then return entry end

    opts = opts or {}
    local font = opts.font or "DermaDefault"
    local textColor = CopyColorSafe(opts.textColor, Color(240, 244, 248))
    local accentColor = CopyColorSafe(opts.accentColor, Color(126, 92, 255))
    local bgColor = CopyColorSafe(opts.bgColor, Color(11, 15, 21))
    local focusColor = CopyColorSafe(opts.focusColor, Color(18, 24, 32))
    local borderColor = CopyColorSafe(opts.borderColor, Color(accentColor.r, accentColor.g, accentColor.b, 110))
    local focusBorderColor = CopyColorSafe(opts.focusBorderColor, Color(accentColor.r, accentColor.g, accentColor.b, 220))
    local placeholderColor = CopyColorSafe(opts.placeholderColor, Color(156, 166, 181))
    local cornerRadius = opts.cornerRadius or 8
    local textInsetX = opts.textInsetX or 10
    local isMultiline = isfunction(entry.GetMultiline) and entry:GetMultiline() or false
    local topPadding = opts.topPadding or (isMultiline and 8 or 0)

    entry:SetFont(font)
    entry:SetTextColor(textColor)
    entry:SetCursorColor(textColor)
    entry:SetHighlightColor(Color(accentColor.r, accentColor.g, accentColor.b, 80))
    entry:SetDrawBackground(false)

    entry.Paint = function(self, w, h)
        local focused = self:HasFocus()
        local bg = focused and focusColor or bgColor
        local stroke = focused and focusBorderColor or borderColor

        draw.RoundedBox(cornerRadius, 0, 0, w, h, bg)
        surface.SetDrawColor(stroke.r, stroke.g, stroke.b, stroke.a)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        self:DrawTextEntryText(textColor, accentColor, textColor)

        if self:GetValue() == "" and not focused then
            local placeholder = self.GetPlaceholderText and self:GetPlaceholderText() or ""
            local selfIsMultiline = isfunction(self.GetMultiline) and self:GetMultiline() or isMultiline
            if placeholder ~= "" then
                draw.SimpleText(placeholder, font, textInsetX + 2, selfIsMultiline and topPadding + 2 or h * 0.5, placeholderColor, TEXT_ALIGN_LEFT, selfIsMultiline and TEXT_ALIGN_TOP or TEXT_ALIGN_CENTER)
            end
        end
    end

    return entry
end

function PsychEval_StyleComboBox(combo, opts)
    if not IsValid(combo) then return combo end

    opts = opts or {}
    local font = opts.font or "DermaDefault"
    local textColor = CopyColorSafe(opts.textColor, Color(230, 230, 230))
    local bgColor = CopyColorSafe(opts.bgColor, Color(24, 28, 34))
    local hoverColor = CopyColorSafe(
        opts.hoverColor,
        Color(math.min(bgColor.r + 10, 255), math.min(bgColor.g + 10, 255), math.min(bgColor.b + 10, 255), bgColor.a)
    )
    local borderColor = CopyColorSafe(opts.borderColor, Color(255, 255, 255, 24))
    local arrowColor = CopyColorSafe(opts.arrowColor, textColor)
    local menuBgColor = CopyColorSafe(
        opts.menuBgColor,
        Color(math.max(bgColor.r - 4, 0), math.max(bgColor.g - 4, 0), math.max(bgColor.b - 4, 0), 245)
    )
    local selectedColor = CopyColorSafe(
        opts.selectedColor,
        Color(math.min(bgColor.r + 18, 255), math.min(bgColor.g + 18, 255), math.min(bgColor.b + 18, 255), 255)
    )

    combo:SetFont(font)
    combo:SetTextColor(textColor)

    if IsValid(combo.TextEntry) then
        combo.TextEntry:SetVisible(false)
        combo.TextEntry:SetMouseInputEnabled(false)
        combo.TextEntry:SetKeyboardInputEnabled(false)
        combo.TextEntry:SetPaintBackground(false)
    end

    combo.UpdateColours = function() end

    combo.Paint = function(s, w, h)
        local bg = s:IsHovered() and hoverColor or bgColor
        if s:GetDisabled() then
            bg = Color(math.max(bgColor.r - 6, 0), math.max(bgColor.g - 6, 0), math.max(bgColor.b - 6, 0), bgColor.a)
        end

        draw.RoundedBox(6, 0, 0, w, h, bg)
        surface.SetDrawColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        local value = tostring(s:GetValue() or "")
        local displayColor = value ~= "" and textColor or Color(textColor.r, textColor.g, textColor.b, 120)
        draw.SimpleText(value ~= "" and value or (opts.placeholder or "Select an option"), font, 10, h * 0.5, displayColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        return true
    end

    if IsValid(combo.DropButton) then
        combo.DropButton:SetText("")
        combo.DropButton:SetWide(28)
        combo.DropButton.Paint = function(btn, w, h)

            return true
        end
    end

    local oldOpenMenu = combo.OpenMenu
    combo.OpenMenu = function(s, pControlOpener)
        if isfunction(oldOpenMenu) then
            oldOpenMenu(s, pControlOpener)
        end

        local menu = s.Menu
        if not IsValid(menu) then return end

        menu.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, menuBgColor)
        end

        local canvas = menu.GetCanvas and menu:GetCanvas() or nil
        if IsValid(canvas) then
            canvas.Paint = function() end

            for _, option in ipairs(canvas:GetChildren()) do
                if IsValid(option) then
                    if option.SetIcon then
                        option:SetIcon(nil)
                    end

                    option:SetTextColor(textColor)
                    option:SetFont(font)
                    option:SetTextInset(8, 0)
                    option.Paint = function(btn, w, h)
                        local fill = menuBgColor
                        if btn:GetText() == s:GetValue() then
                            fill = selectedColor
                        end
                        if btn:IsHovered() then
                            fill = hoverColor
                        end

                        draw.RoundedBox(4, 3, 1, w - 6, h - 2, fill)
                        draw.SimpleText(btn:GetText() or "", font, 12, h * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        return true
                    end
                end
            end
        end
    end

    return combo
end

-- Optional debug print (comment out if you don't want console output)
timer.Simple(1.5, function()
    if not IsValid(LocalPlayer()) then return end
    local teamName = (team and team.GetName and team.GetName(LocalPlayer():Team())) or tostring(LocalPlayer():Team())
    local accessEntry = PsychEval and PsychEval.AccessByTeamName and PsychEval.AccessByTeamName[teamName]
    local clearEntry  = PsychEval and PsychEval.ClearanceByTeamName and PsychEval.ClearanceByTeamName[teamName]
    print("[Research Computer] Client config loaded. Team:", teamName, "Access:", tostring(accessEntry), "Clearance:", tostring(clearEntry))
end)