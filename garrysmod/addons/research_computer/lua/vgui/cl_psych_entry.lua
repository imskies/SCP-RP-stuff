pcall(function() include("psych_eval/cl_shared.lua") end)

if not PsychEval then PsychEval = {} end

surface.CreateFont("SCP_Entry_Title_Large", {font = "Roboto Mono", size = 20, weight = 800})
surface.CreateFont("SCP_Entry_Label_Large", {font = "Roboto Mono", size = 16, weight = 600})
surface.CreateFont("SCP_Entry_Input_Large", {font = "Roboto Mono", size = 16, weight = 400})
surface.CreateFont("SCP_Entry_Button", {font = "Roboto Mono", size = 16, weight = 700})

local THEME = {
    panel = Color(18, 20, 22),
    accent = Color(200, 40, 40),
    text = Color(230, 230, 230),
    muted = Color(170, 170, 170),
    button_hover = Color(220, 60, 60),
    button_pressed = Color(160, 20, 20)
}

local BG_GRAD = Material("bg_grad.png", "smooth")
local HOVER_SOUND = "other/oakman/deadspace/ui/tic.wav"
local function AttachHoverSound(btn)
    if not IsValid(btn) then return btn end

    local prev = btn.OnCursorEntered
    btn.OnCursorEntered = function(self)
        surface.PlaySound(HOVER_SOUND)
        if isfunction(prev) then
            prev(self)
        end
    end

    return btn
end

local function DrawGradientShell(radius, w, h, baseColor, tintColor, alpha)
    if PsychEval_DrawGradientShell then
        PsychEval_DrawGradientShell(radius, w, h, baseColor, tintColor, alpha, BG_GRAD)
        return
    end

    local outerRadius = math.max(radius + 8, 18)
    local inset = 4
    local innerRadius = math.max(outerRadius - 2, 16)
    local innerW, innerH = w - (inset * 2), h - (inset * 2)

    draw.RoundedBox(outerRadius, 0, 0, w, h, Color(6, 4, 10, 190))
    draw.RoundedBox(innerRadius, inset, inset, innerW, innerH, baseColor)
end

local function DrawThemedButton(btn, w, h, text, isHovered, isDown)
    local bg = Color(11, 15, 21)
    if isDown then
        bg = Color(18, 24, 32)
    elseif isHovered then
        bg = Color(22, 28, 38)
    end

    draw.RoundedBox(8, 0, 0, w, h, bg)
    surface.SetDrawColor(255, 255, 255, 22)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
    surface.SetDrawColor(THEME.accent.r, THEME.accent.g, THEME.accent.b, 235)
    surface.DrawRect(0, 0, w, 4)
    draw.SimpleText(string.upper(text or "BUTTON"), "SCP_Entry_Button", w * 0.5, h * 0.5, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function CreateThemedButton(parent, x, y, w, h, text, onClick)
    local btn = vgui.Create("DButton", parent)
    btn:SetPos(x, y)
    btn:SetSize(w, h)
    btn:SetText("")
    btn.DoClick = function() if isfunction(onClick) then onClick() end end
    btn.Paint = function(s, pw, ph)
        DrawThemedButton(s, pw, ph, text, s:IsHovered(), s:IsDown())
    end
    return AttachHoverSound(btn)
end

local function StyleField(entry)
    if PsychEval_StyleTextEntry then
        PsychEval_StyleTextEntry(entry, {
            font = "SCP_Entry_Input_Large",
            textColor = THEME.text,
            accentColor = THEME.accent,
            bgColor = Color(11, 15, 21),
            focusColor = Color(18, 24, 32),
            borderColor = Color(THEME.accent.r, THEME.accent.g, THEME.accent.b, 110),
            focusBorderColor = Color(THEME.accent.r, THEME.accent.g, THEME.accent.b, 220),
            placeholderColor = THEME.muted
        })
    end
    return entry
end

function OpenPsychEntry(entry, index, onComplete)
    local isEdit = entry ~= nil
    local frame = vgui.Create("DFrame")
    frame:SetSize(640, 640)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame.Paint = function(s, w, h)
        DrawGradientShell(8, w, h, THEME.panel, THEME.accent, 16)
        draw.SimpleText(isEdit and "EDIT EVALUATION" or "NEW EVALUATION", "SCP_Entry_Title_Large", 16, 10, THEME.accent)
    end
    if PsychEval_AddWindowCloseButton then
        PsychEval_AddWindowCloseButton(frame, "SCP_Entry_Label_Large", THEME.text)
    end

    local pad = 16
    local y = 48

    local function makeLabel(txt)
        local lbl = vgui.Create("DLabel", frame)
        lbl:SetPos(pad, y)
        lbl:SetFont("SCP_Entry_Label_Large")
        lbl:SetTextColor(THEME.text)
        lbl:SetText(txt)
        lbl:SizeToContents()
        y = y + 28
        return lbl
    end

    makeLabel("Reporting Psychologist:")
    local psych = vgui.Create("DTextEntry", frame)
    psych:SetPos(pad, y)
    psych:SetSize(frame:GetWide() - pad*2, 34)
    psych:SetFont("SCP_Entry_Input_Large")
    psych:SetText(isEdit and (entry.psychologist or "") or (LocalPlayer():Nick() or ""))
    StyleField(psych)
    y = y + 46

    makeLabel("Subject:")
    local subject = vgui.Create("DTextEntry", frame)
    subject:SetPos(pad, y)
    subject:SetSize(frame:GetWide() - pad*2, 34)
    subject:SetFont("SCP_Entry_Input_Large")
    subject:SetText(isEdit and (entry.subject or "") or "")
    StyleField(subject)
    y = y + 46

    makeLabel("Date:")
    local date = vgui.Create("DTextEntry", frame)
    date:SetPos(pad, y)
    date:SetSize(frame:GetWide() - pad*2, 34)
    date:SetFont("SCP_Entry_Input_Large")
    date:SetText(isEdit and (entry.date or "") or os.date("%Y-%m-%d"))
    StyleField(date)
    y = y + 46

    makeLabel("Mental State:")
    local state = vgui.Create("DComboBox", frame)
    state:SetPos(pad, y)
    state:SetSize(frame:GetWide() - pad*2, 34)
    state:SetFont("SCP_Entry_Input_Large")
    PsychEval_StyleComboBox(state, {
        font = "SCP_Entry_Input_Large",
        textColor = THEME.text,
        bgColor = Color(24, 26, 30),
        hoverColor = Color(31, 34, 40),
        borderColor = Color(255, 255, 255, 18),
        arrowColor = THEME.accent
    })
    state:AddChoice("Excellent")
    state:AddChoice("Stable")
    state:AddChoice("Unstable")
    state:AddChoice("Insane")
    if isEdit and entry.state then state:ChooseOption(entry.state) end
    y = y + 46

    makeLabel("Notes:")
    local notesY = y
    local notes = vgui.Create("DTextEntry", frame)
    notes:SetPos(pad, notesY)
    notes:SetMultiline(true)
    notes:SetFont("SCP_Entry_Input_Large")
    notes:SetText(isEdit and (entry.notes or "") or "")
    notes:SetVerticalScrollbarEnabled(true)
    StyleField(notes)

    -- Determine client access (set by menu before opening)
    local clientAccess = PsychEval_ClientAccess or 1
    local submitText = isEdit and "Save Changes" or "Submit Evaluation"
    if clientAccess < 3 then
        submitText = submitText .. " (View Only)"
    end

    local submit = CreateThemedButton(frame, pad, frame:GetTall() - 64, frame:GetWide() - pad*2, 48, submitText, function()
        local chosen = state:GetSelected()
        if not chosen or chosen == "" then
            Derma_Message("Please select a valid Mental State.", "Validation", "OK")
            return
        end

        local newEntry = {
            psychologist = psych:GetValue():Trim(),
            subject = subject:GetValue():Trim(),
            date = date:GetValue():Trim(),
            state = chosen,
            notes = notes:GetValue()
        }

        local allowed = PsychEval.AllowedStates or {"Excellent","Stable","Unstable","Insane"}
        local ok = false
        for _, s in ipairs(allowed) do if s == newEntry.state then ok = true break end end
        if not ok then
            Derma_Message("Invalid Mental State selected.", "Validation", "OK")
            return
        end

        -- If client lacks submit privileges, show message and do not send
        if clientAccess < 3 then
            Derma_Message("You do not have permission to submit entries. This is view-only.", "Permission", "OK")
            return
        end

        if isEdit and index then
            net.Start("PsychEval_EditEntry")
            net.WriteUInt(index, 16)
            net.WriteTable(newEntry)
            net.SendToServer()
        else
            net.Start("PsychEval_SubmitEntry")
            net.WriteTable(newEntry)
            net.SendToServer()
        end

        if isfunction(onComplete) then onComplete() end
        frame:Close()
    end)

    local function LayoutEntryFrame()
        local submitH = 48
        local submitY = frame:GetTall() - submitH - 16
        local notesH = math.max(160, submitY - notesY - 14)
        notes:SetPos(pad, notesY)
        notes:SetSize(frame:GetWide() - pad * 2, notesH)
        submit:SetPos(pad, submitY)
        submit:SetSize(frame:GetWide() - pad * 2, submitH)
        submit:MoveToFront()
    end

    frame:SetSizable(true)
    frame.OnSizeChanged = function()
        LayoutEntryFrame()
    end
    LayoutEntryFrame()
end