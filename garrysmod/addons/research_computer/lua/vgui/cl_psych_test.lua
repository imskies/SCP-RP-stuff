-- lua/vgui/cl_psych_test.lua
-- Test creation/edit UI — removed Scores field, expanded Notes area.

pcall(function() include("psych_eval/cl_shared.lua") end)

if not PsychEval then PsychEval = {} end

surface.CreateFont("SCP_Test_Title", {font = "Roboto Mono", size = 24, weight = 800})
surface.CreateFont("SCP_Test_Label", {font = "Roboto Mono", size = 16, weight = 600})
surface.CreateFont("SCP_Test_Input", {font = "Roboto Mono", size = 16, weight = 400})
surface.CreateFont("SCP_Test_Button", {font = "Roboto Mono", size = 16, weight = 700})

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
    draw.SimpleText(string.upper(text or "BUTTON"), "SCP_Test_Button", w * 0.5, h * 0.5, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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

local function MakeLabel(parent, x, y, text)
    local lbl = vgui.Create("DLabel", parent)
    lbl:SetPos(x, y)
    lbl:SetFont("SCP_Test_Label")
    lbl:SetTextColor(THEME.text)
    lbl:SetText(text)
    lbl:SizeToContents()
    return lbl
end

local function StyleField(entry)
    if PsychEval_StyleTextEntry then
        PsychEval_StyleTextEntry(entry, {
            font = "SCP_Test_Input",
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

function OpenPsychTest(test, index, onComplete)
    local isEdit = test ~= nil
    local frameW, frameH = 980, 820
    local pad = 18
    local rowH = 36

    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame:SetSizable(true)
    frame.Paint = function(s, w, h)
        DrawGradientShell(8, w, h, THEME.panel, THEME.accent, 16)
        draw.SimpleText(isEdit and "EDIT TEST" or "NEW TEST", "SCP_Test_Title", 16, 12, THEME.accent)
    end
    if PsychEval_AddWindowCloseButton then
        PsychEval_AddWindowCloseButton(frame, "SCP_Test_Label", THEME.text)
    end

    local y = 52
    local colW = frameW - pad * 2

    -- Name
    MakeLabel(frame, pad, y, "Name:")
    local nameEntry = vgui.Create("DTextEntry", frame)
    nameEntry:SetPos(pad, y + 26)
    nameEntry:SetSize(colW, rowH)
    nameEntry:SetFont("SCP_Test_Input")
    nameEntry:SetText(isEdit and (test.name or "") or "")
    StyleField(nameEntry)
    y = y + 26 + rowH + 12

    -- Subject
    MakeLabel(frame, pad, y, "Subject:")
    local subjectEntry = vgui.Create("DTextEntry", frame)
    subjectEntry:SetPos(pad, y + 26)
    subjectEntry:SetSize(colW, rowH)
    subjectEntry:SetFont("SCP_Test_Input")
    subjectEntry:SetText(isEdit and (test.subject or "") or "")
    StyleField(subjectEntry)
    y = y + 26 + rowH + 12

    -- Clearance and Grade row
    MakeLabel(frame, pad, y, "Clearance Level (0-6) and Grade (A-F):")
    local gap = 16
    local halfW = math.floor((colW - gap) * 0.5)

    local clearanceCombo = vgui.Create("DComboBox", frame)
    clearanceCombo:SetPos(pad, y + 26)
    clearanceCombo:SetSize(halfW, rowH)
    clearanceCombo:SetFont("SCP_Test_Input")
    PsychEval_StyleComboBox(clearanceCombo, {
        font = "SCP_Test_Input",
        textColor = THEME.text,
        bgColor = Color(24, 26, 30),
        hoverColor = Color(31, 34, 40),
        borderColor = Color(255, 255, 255, 18),
        arrowColor = THEME.accent
    })
    for i = 0, 6 do clearanceCombo:AddChoice(tostring(i)) end
    if isEdit and test.clearance ~= nil then clearanceCombo:ChooseOption(tostring(test.clearance)) end

    local gradeCombo = vgui.Create("DComboBox", frame)
    gradeCombo:SetPos(pad + halfW + gap, y + 26)
    gradeCombo:SetSize(halfW, rowH)
    gradeCombo:SetFont("SCP_Test_Input")
    PsychEval_StyleComboBox(gradeCombo, {
        font = "SCP_Test_Input",
        textColor = THEME.text,
        bgColor = Color(24, 26, 30),
        hoverColor = Color(31, 34, 40),
        borderColor = Color(255, 255, 255, 18),
        arrowColor = THEME.accent
    })
    local grades = {"A","B","C","D","E","F"}
    for _, g in ipairs(grades) do gradeCombo:AddChoice(g) end
    if isEdit and test.grade then gradeCombo:ChooseOption(test.grade) end

    y = y + 26 + rowH + 12

    -- Date
    MakeLabel(frame, pad, y, "Date:")
    local dateEntry = vgui.Create("DTextEntry", frame)
    dateEntry:SetPos(pad, y + 26)
    dateEntry:SetSize(colW, rowH)
    dateEntry:SetFont("SCP_Test_Input")
    dateEntry:SetText(isEdit and (test.date or "") or os.date("%Y-%m-%d"))
    StyleField(dateEntry)
    y = y + 26 + rowH + 12

    -- Notes (expanded, with reserved space below for the submit button)
    MakeLabel(frame, pad, y, "Test Notes:")
    local notesTop = y + 26
    local notesWrap = vgui.Create("DScrollPanel", frame)
    notesWrap:SetPos(pad, notesTop)
    notesWrap.Paint = function(_, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(9, 12, 18, 220))
    end

    local notesEntry = vgui.Create("DTextEntry", notesWrap)
    notesEntry:SetPos(4, 4)
    notesEntry:SetMultiline(true)
    notesEntry:SetFont("SCP_Test_Input")
    notesEntry:SetText(isEdit and (test.notes or "") or "")
    notesEntry:SetVerticalScrollbarEnabled(true)
    StyleField(notesEntry)

    -- Permissions from caller
    local clientAccess = PsychEval_ClientAccess or 1
    local clientCanGrade = PsychEval_ClientCanGrade or false

    if not clientCanGrade then
        gradeCombo:SetEnabled(false)
        gradeCombo:SetText("View Only")
    end

    local submitText = isEdit and "Save Changes" or "Submit Test"
    if clientAccess < 3 then
        submitText = submitText .. " (Requires Editor or Clearance)"
    end

    local submit = CreateThemedButton(frame, pad, frame:GetTall() - 72, frame:GetWide() - pad * 2, 52, submitText, function()
        local chosenClear = clearanceCombo:GetSelected()
        if not chosenClear or chosenClear == "" then
            Derma_Message("Please select a Clearance Level (0-6).", "Validation", "OK")
            return
        end

        local newEntry = {
            name = nameEntry:GetValue():Trim(),
            subject = subjectEntry:GetValue():Trim(),
            clearance = tonumber(chosenClear) or 0,
            date = dateEntry:GetValue():Trim(),
            notes = notesEntry:GetValue() or "",
            psychologist = LocalPlayer():Nick() or "Unknown"
        }

        if clientCanGrade then
            local chosenGrade = gradeCombo:GetSelected()
            if chosenGrade and chosenGrade ~= "" then newEntry.grade = chosenGrade end
        end

        -- Client-side guard: allow submit if player's job is listed or clearance meets minimum
        local playerClear = (PsychEval.GetPlayerClearance and PsychEval.GetPlayerClearance(LocalPlayer())) or PsychEval.DefaultClearance or 1
        local jobListed = false
        local teamID = LocalPlayer():Team()
        if PsychEval.AccessByTeamID and PsychEval.AccessByTeamID[teamID] ~= nil then jobListed = true end
        local teamName = ResolvePlayerTeamName and ResolvePlayerTeamName() or tostring(teamID)
        if not jobListed and PsychEval.AccessByTeamName and PsychEval.AccessByTeamName[teamName] ~= nil then jobListed = true end
        if not jobListed and PsychEval.ClearanceByTeamName and PsychEval.ClearanceByTeamName[teamName] ~= nil then jobListed = true end

        if not jobListed and playerClear < (PsychEval.MinClearanceToOpenTests or 1) then
            Derma_Message("You do not have permission to submit test logs.", "Permission", "OK")
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

    local function LayoutTestFrame(nw, nh)
        nw = nw or frame:GetWide()
        nh = nh or frame:GetTall()

        local newColW = nw - pad * 2
        local newHalfW = math.floor((newColW - gap) * 0.5)
        local submitH = 52
        local submitY = nh - submitH - 20
        local newNotesH = math.max(200, submitY - notesTop - 14)

        nameEntry:SetSize(newColW, rowH)
        subjectEntry:SetSize(newColW, rowH)
        clearanceCombo:SetSize(newHalfW, rowH)
        gradeCombo:SetPos(pad + newHalfW + gap, gradeCombo:GetY())
        gradeCombo:SetSize(newHalfW, rowH)
        dateEntry:SetSize(newColW, rowH)

        notesWrap:SetPos(pad, notesTop)
        notesWrap:SetSize(newColW, newNotesH)
        notesEntry:SetSize(notesWrap:GetWide() - 12, notesWrap:GetTall() - 12)

        submit:SetPos(pad, submitY)
        submit:SetSize(newColW, submitH)
        submit:MoveToFront()
    end

    frame.OnSizeChanged = function(_, nw, nh)
        LayoutTestFrame(nw, nh)
    end

    LayoutTestFrame()
end