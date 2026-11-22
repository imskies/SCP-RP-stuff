if not PsychEval then PsychEval = {} end

-- Theme (matches mainmenu.lua)
local THEME = THEME or {
    bg = Color(8, 12, 18),
    panel = Color(16, 20, 27),
    panel_alt = Color(11, 15, 21),
    psych_accent = Color(126, 92, 255),
    test_accent = Color(190, 198, 212),
    bio_accent = Color(84, 176, 122),
    doc_accent = Color(80, 140, 232),
    schedule_accent = Color(232, 145, 70),
    text = Color(240, 244, 248),
    text_dark = Color(10, 12, 16),
    muted = Color(156, 166, 181),
    stroke = Color(255, 255, 255, 26)
}

-- Ensure fonts exist (safe to recreate)
surface.CreateFont("PsychMain_Title", {font="Roboto Mono", size=28, weight=900})
surface.CreateFont("PsychMain_Body", {font="Roboto Mono", size=18, weight=600})
surface.CreateFont("PsychMain_Button", {font="Roboto Mono", size=18, weight=800})

local BG_GRAD = Material("bg_grad.png", "smooth")

-- State
CurrentSchedule = CurrentSchedule or {}
CanCreateSchedule = CanCreateSchedule
local ActiveScheduleWindow = nil

-- Helpers
local function IsPanelValid(p) return p ~= nil and IsValid(p) end
local function SafeCreate(class, parent)
    if parent ~= nil and not IsPanelValid(parent) then return nil end
    local ok, pnl = pcall(function() return vgui.Create(class, parent) end)
    if not ok then return nil end
    return pnl
end
local function SafeCall(fn, ctx)
    local ok, err = xpcall(fn, debug.traceback)
    if not ok then print("[cl_psych_schedule] ERROR in " .. tostring(ctx or "unknown") .. ": " .. tostring(err)) end
end
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

-- Parsers
local function ParseDateString(s)
    return s and s:match("^%d%d%d%d%-%d%d%-%d%d$")
end
local function ParseTimeString(s)
    local h,m = s:match("^(%d%d):(%d%d)$")
    h = tonumber(h) m = tonumber(m)
    return h and m and h>=0 and h<24 and m>=0 and m<60
end

-- Sorting and populate (attaches _schedIndex to rows)
local StyleScheduleRow

local function SortSchedule(tbl)
    table.sort(tbl, function(a,b)
        return (tostring(a.date or "") .. " " .. tostring(a.time or "")) < (tostring(b.date or "") .. " " .. tostring(b.time or ""))
    end)
end

local function PopulateScheduleList(list, filter)
    if not IsPanelValid(list) then return end
    list:Clear()

    filter = (filter or ""):lower()
    SortSchedule(CurrentSchedule)

    if #CurrentSchedule == 0 then
        local row = list:AddLine("-", "No scheduled items", "", "", "")
        if StyleScheduleRow then
            StyleScheduleRow(row)
        end
        return
    end

    for i, v in ipairs(CurrentSchedule) do
        local combined = (tostring(v.activity) .. " " .. tostring(v.details or "") .. " " .. tostring(v.host) .. " " .. tostring(v.date) .. " " .. tostring(v.time)):lower()
        if filter == "" or combined:find(filter, 1, true) then
            local row = list:AddLine(i, v.date or "", v.time or "", v.activity or "", v.host or "")
            if IsPanelValid(row) then
                row._schedIndex = i
                if StyleScheduleRow then
                    StyleScheduleRow(row)
                end
                -- ensure row is not preselected
                if row.SetSelected then pcall(function() row:SetSelected(false) end) end
            end
        end
    end
end

-- Local button painter (dock-friendly)
local function CreateAccentButtonDock(parent, dock, w, text, accent, textColor, cb)
    local b = vgui.Create("DButton", parent)
    b:SetText("")
    if dock == "LEFT" then b:Dock(LEFT) elseif dock == "RIGHT" then b:Dock(RIGHT) elseif dock == "TOP" then b:Dock(TOP) elseif dock == "BOTTOM" then b:Dock(BOTTOM) else b:Dock(FILL) end
    if w then b:SetWide(w) end
    b.DoClick = function() if isfunction(cb) then cb() end end
    b.Paint = function(s, pw, ph)
        local col = accent or THEME.psych_accent
        if type(col) == "string" and THEME[col] then col = THEME[col] end
        local bg = THEME.panel_alt or THEME.panel
        if s:IsDown() then
            bg = Color(18, 24, 32)
        elseif s:IsHovered() then
            bg = Color(22, 28, 38)
        end

        draw.RoundedBox(8, 0, 0, pw, ph, bg)
        if THEME.stroke then
            surface.SetDrawColor(THEME.stroke)
            surface.DrawOutlinedRect(0, 0, pw, ph, 1)
        end
        surface.SetDrawColor(col.r, col.g, col.b, 235)
        surface.DrawRect(0, 0, pw, 4)
        draw.SimpleText(string.upper(text or "BUTTON"), "PsychMain_Button", pw * 0.5, ph * 0.5, textColor or THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    return AttachHoverSound(b)
end

local function AddWindowCloseButton(frame)
    if not IsPanelValid(frame) then return end
    if IsPanelValid(frame._PsychScheduleCloseButton) then
        frame._PsychScheduleCloseButton:Remove()
    end

    local closeButton = vgui.Create("DButton", frame)
    closeButton:SetSize(30, 30)
    closeButton:SetText("")
    closeButton.Think = function(s)
        if not IsPanelValid(frame) then return end
        s:SetPos(frame:GetWide() - 42, 14)
    end
    closeButton.DoClick = function()
        if IsPanelValid(frame) then
            frame:Close()
        end
    end
    closeButton.Paint = function(s, w, h)
        local col = s:IsHovered() and Color(220, 70, 70) or THEME.text
        draw.SimpleText("✕", "PsychMain_Body", w * 0.5, h * 0.5 - 1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    frame._PsychScheduleCloseButton = AttachHoverSound(closeButton)
    return frame._PsychScheduleCloseButton
end

local function StyleScheduleList(list)
    if not IsPanelValid(list) then return end

    list.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, THEME.panel_alt or THEME.panel)
    end

    local vbar = list.VBar or (list.GetVBar and list:GetVBar())
    if IsValid(vbar) then
        vbar.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, THEME.panel_alt or THEME.panel)
        end
        vbar.btnUp.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, THEME.panel)
        end
        vbar.btnDown.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, THEME.panel)
        end
        vbar.btnGrip.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(THEME.schedule_accent.r, THEME.schedule_accent.g, THEME.schedule_accent.b, 120))
        end
    end

    for _, column in ipairs(list.Columns or {}) do
        if IsValid(column.Header) then
            column.Header:SetFont("PsychMain_Body")
            column.Header:SetTextColor(THEME.text)
            column.Header:SetContentAlignment(5)
            column.Header.Paint = function(_, w, h)
                draw.RoundedBox(6, 0, 0, w, h, THEME.panel)
                surface.SetDrawColor(THEME.schedule_accent.r, THEME.schedule_accent.g, THEME.schedule_accent.b, 200)
                surface.DrawRect(0, h - 2, w, 2)
            end
        end
    end

    pcall(function()
        if list.Columns and list.Columns[1] and list.Columns[1].SetFixedWidth then
            list.Columns[1]:SetFixedWidth(48)
            list.Columns[2]:SetFixedWidth(110)
            list.Columns[3]:SetFixedWidth(80)
            list.Columns[5]:SetFixedWidth(120)
        end
    end)
end

StyleScheduleRow = function(row)
    if not IsPanelValid(row) then return end
    for _, label in ipairs(row.Columns or {}) do
        if IsValid(label) then
            label:SetTextColor(THEME.text)
            label:SetFont("PsychMain_Body")
        end
    end

    row.Paint = function(self, w, h)
        local selected = self:IsSelected()
        local hovered = self:IsHovered()
        local bg = selected and Color(THEME.schedule_accent.r, THEME.schedule_accent.g, THEME.schedule_accent.b, 34) or (hovered and Color(255, 255, 255, 14) or Color(255, 255, 255, 6))
        draw.RoundedBox(6, 4, 2, w - 8, h - 4, bg)
        if selected then
            surface.SetDrawColor(THEME.schedule_accent.r, THEME.schedule_accent.g, THEME.schedule_accent.b, 220)
            surface.DrawRect(4, 2, 3, h - 4)
        end
    end
end

local function StyleScheduleSearch(entry)
    if not IsPanelValid(entry) then return end
    entry:SetDrawBackground(false)
    entry:SetTextColor(THEME.text)
    entry.Paint = function(self, w, h)
        local focused = self:HasFocus()
        local bg = focused and Color(18, 24, 32) or (THEME.panel_alt or THEME.panel)
        draw.RoundedBox(8, 0, 0, w, h, bg)
        surface.SetDrawColor(THEME.schedule_accent.r, THEME.schedule_accent.g, THEME.schedule_accent.b, focused and 220 or 110)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        self:DrawTextEntryText(THEME.text, THEME.schedule_accent, THEME.text)
        if self:GetValue() == "" and not focused then
            draw.SimpleText(self:GetPlaceholderText() or "", "PsychMain_Body", 12, h * 0.5, THEME.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
end

-- Create event dialog
local function OpenCreateScheduleWindow()
    if not CanCreateSchedule then
        Derma_Message("You are not authorized to create schedule entries.", "Schedule", "OK")
        return
    end

    local frame = vgui.Create("DFrame")
    frame:SetSize(520, 420)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame.Paint = function(s,w,h)
        DrawGradientShell(8, w, h, THEME.panel, THEME.schedule_accent, 16)
        draw.SimpleText("Create Schedule Event", "PsychMain_Body", 18, 12, THEME.text)
    end
    if PsychEval_AddWindowCloseButton then
        PsychEval_AddWindowCloseButton(frame, "PsychMain_Body", THEME.text)
    else
        AddWindowCloseButton(frame)
    end

    local content = vgui.Create("DPanel", frame)
    content:Dock(FILL)
    content:DockPadding(16,48,16,16)
    content.Paint = function() end

    local function AddLabel(text)
        local lbl = vgui.Create("DLabel", content)
        lbl:SetText(text)
        lbl:SetFont("PsychMain_Body")
        lbl:SetTextColor(THEME.muted)
        lbl:Dock(TOP)
        lbl:DockMargin(0,0,0,4)
        return lbl
    end

    local function AddEntry(default)
        local e = vgui.Create("DTextEntry", content)
        e:SetFont("PsychMain_Body")
        e:SetText(default or "")
        e:Dock(TOP)
        e:SetTall(28)
        e:DockMargin(0,0,0,12)
        if PsychEval_StyleTextEntry then
            PsychEval_StyleTextEntry(e, {
                font = "PsychMain_Body",
                textColor = THEME.text,
                accentColor = THEME.schedule_accent,
                bgColor = THEME.panel_alt,
                focusColor = Color(18, 24, 32),
                borderColor = Color(THEME.schedule_accent.r, THEME.schedule_accent.g, THEME.schedule_accent.b, 110),
                focusBorderColor = Color(THEME.schedule_accent.r, THEME.schedule_accent.g, THEME.schedule_accent.b, 220),
                placeholderColor = THEME.muted
            })
        end
        return e
    end

    AddLabel("Host:")
    local hostEntry = AddEntry(LocalPlayer():Nick())

    AddLabel("Date (YYYY-MM-DD):")
    local dateEntry = AddEntry(os.date("%Y-%m-%d"))

    AddLabel("Time (HH:MM):")
    local timeEntry = AddEntry("09:00")

    AddLabel("Activity:")
    local activityCombo = vgui.Create("DComboBox", content)
    activityCombo:Dock(TOP)
    activityCombo:SetTall(28)
    activityCombo:SetFont("PsychMain_Body")
    PsychEval_StyleComboBox(activityCombo, {
        font = "PsychMain_Body",
        textColor = THEME.text,
        bgColor = THEME.panel_alt,
        hoverColor = Color(18, 22, 30),
        borderColor = THEME.stroke,
        arrowColor = THEME.schedule_accent
    })
    activityCombo:AddChoice("Lecture")
    activityCombo:AddChoice("Group Project")
    activityCombo:AddChoice("Debriefing")
    activityCombo:AddChoice("Other")
    activityCombo:SetValue("Lecture")
    activityCombo:DockMargin(0,0,0,12)

    AddLabel("Details:")
    local detailsEntry = vgui.Create("DTextEntry", content)
    detailsEntry:Dock(TOP)
    detailsEntry:SetTall(100)
    detailsEntry:SetMultiline(true)
    detailsEntry:SetFont("PsychMain_Body")
    if PsychEval_StyleTextEntry then
        PsychEval_StyleTextEntry(detailsEntry, {
            font = "PsychMain_Body",
            textColor = THEME.text,
            accentColor = THEME.schedule_accent,
            bgColor = THEME.panel_alt,
            focusColor = Color(18, 24, 32),
            borderColor = Color(THEME.schedule_accent.r, THEME.schedule_accent.g, THEME.schedule_accent.b, 110),
            focusBorderColor = Color(THEME.schedule_accent.r, THEME.schedule_accent.g, THEME.schedule_accent.b, 220),
            placeholderColor = THEME.muted
        })
    end

    local bottom = vgui.Create("DPanel", frame)
    bottom:Dock(BOTTOM)
    bottom:SetTall(64)
    bottom:DockPadding(16,12,16,12)
    bottom.Paint = function() end

    CreateAccentButtonDock(bottom, "RIGHT", 160, "Create", THEME.schedule_accent, nil, function()
        local host = hostEntry:GetValue():Trim()
        local date = dateEntry:GetValue():Trim()
        local time = timeEntry:GetValue():Trim()
        local activity = activityCombo:GetValue()
        local details = detailsEntry:GetValue()

        if host == "" then return Derma_Message("Host cannot be empty.", "Schedule", "OK") end
        if not ParseDateString(date) then return Derma_Message("Invalid date format.", "Schedule", "OK") end
        if not ParseTimeString(time) then return Derma_Message("Invalid time format.", "Schedule", "OK") end

        net.Start("Schedule_Create")
        net.WriteTable({
            host = host,
            date = date,
            time = time,
            activity = activity,
            details = details
        })
        net.SendToServer()

        frame:Close()
    end)

    CreateAccentButtonDock(bottom, "RIGHT", 160, "Cancel", Color(60,60,60), nil, function()
        frame:Close()
    end)
end

-- Build UI
local function BuildScheduleUI(frame)
    if not IsPanelValid(frame) then return end

    if IsPanelValid(frame._PsychScheduleContainer) then
        frame._PsychScheduleContainer:Remove()
    end

    frame.Paint = function(s,w,h)
        DrawGradientShell(10, w, h, THEME.bg, THEME.schedule_accent, 42)
        draw.RoundedBoxEx(10, 0, 0, w, 84, THEME.panel, true, true, false, false)
        surface.SetDrawColor(THEME.schedule_accent.r, THEME.schedule_accent.g, THEME.schedule_accent.b, 24)
        surface.DrawRect(0, 84, w, h - 84)
        draw.SimpleText("Research Schedule", "PsychMain_Title", 22, 20, THEME.schedule_accent)
        draw.SimpleText("View, create, and manage scheduled research events", "PsychMain_Body", 22, 56, THEME.muted)
    end
    AddWindowCloseButton(frame)

    local container = vgui.Create("DPanel", frame)
    frame._PsychScheduleContainer = container
    container:Dock(FILL)
    container:DockPadding(16,100,16,16)
    container.Paint = function() end

    -- Left panel
    local left = vgui.Create("DPanel", container)
    left:Dock(LEFT)
    left:SetWide(560)
    left:DockMargin(0,12,16,0)
    left:DockPadding(12,12,12,12)
    left.Paint = function(s,w,h)
        DrawGradientShell(8, w, h, Color(12, 12, 12), THEME.schedule_accent, 30)
    end

    local search = vgui.Create("DTextEntry", left)
    search:Dock(TOP)
    search:SetTall(32)
    search:DockMargin(0, 0, 0, 12)
    search:SetFont("PsychMain_Body")
    search:SetPlaceholderText("Search...")
    StyleScheduleSearch(search)

    local list = vgui.Create("DListView", left)
    list:Dock(FILL)
    list:SetMultiSelect(false)
    list:SetSortable(false)
    list:SetDataHeight(28)
    list:SetHeaderHeight(28)
    list:SetSelectable(true)
    list:AddColumn("Index")
    list:AddColumn("Date")
    list:AddColumn("Time")
    list:AddColumn("Activity")
    list:AddColumn("Host")
    StyleScheduleList(list)

    -- Right panel
    local right = vgui.Create("DPanel", container)
    right:Dock(FILL)
    right:DockMargin(0,12,0,0)
    right:DockPadding(12,12,12,12)
    right.Paint = function(s,w,h)
        DrawGradientShell(8, w, h, Color(12, 12, 12), THEME.schedule_accent, 30)
    end

    local detailBox = vgui.Create("DPanel", right)
    detailBox:Dock(TOP)
    detailBox:SetTall(240)
    detailBox:DockMargin(0, 0, 0, 12)
    detailBox:DockPadding(12,12,12,12)
    detailBox.Paint = function(s,w,h)
        DrawGradientShell(8, w, h, Color(18, 18, 18), THEME.schedule_accent, 26)
    end

    local detailText = vgui.Create("DLabel", detailBox)
    detailText:Dock(FILL)
    detailText:SetWrap(true)
    detailText:SetFont("PsychMain_Body")
    detailText:SetText("No entry selected.")

    local closeBtn = CreateAccentButtonDock(right, "BOTTOM", 200, "Exit", Color(60,60,60), nil, function()
        frame:Close()
    end)
    if IsPanelValid(closeBtn) then
        closeBtn:DockMargin(0,0,0,8)
        closeBtn:SetTall(44)
    end

    local btnBar = vgui.Create("DPanel", right)
    btnBar:Dock(BOTTOM)
    btnBar:SetTall(64)
    btnBar:DockPadding(12,12,12,12)
    btnBar.Paint = function() end

    CreateAccentButtonDock(btnBar, "LEFT", 200, "Schedule Event", THEME.schedule_accent, nil, function()
        OpenCreateScheduleWindow()
    end)

    CreateAccentButtonDock(btnBar, "LEFT", 200, "Delete Selected", Color(120,20,20), nil, function()
        local sel = list:GetSelectedLine()
        if not sel then return Derma_Message("Select an entry first.", "Schedule", "OK") end
        local row = list:GetLine(sel)
        local idx = row._schedIndex
        local entry = CurrentSchedule[idx]
        if not entry then return end

        Derma_Query("Delete this entry?", "Confirm",
            "Delete", function()
                net.Start("Schedule_Delete")
                net.WriteUInt(idx, 16)
                net.SendToServer()
            end,
            "Cancel"
        )
    end)

    -- Selection handler (reads _schedIndex)
    function list:OnRowSelected(rowIndex, rowPanel)
        if not IsPanelValid(rowPanel) then return end
        local idx = rowPanel._schedIndex or tonumber(rowPanel:GetValue(1))
        if not idx then return end
        local entry = CurrentSchedule[idx]
        if not entry then
            detailText:SetText("Selected entry not found.")
            return
        end

        detailText:SetText(
            "Host: " .. (entry.host or "") ..
            "\nDate: " .. (entry.date or "") ..
            "\nTime: " .. (entry.time or "") ..
            "\nActivity: " .. (entry.activity or "") ..
            "\n\nDetails:\n" .. (entry.details or "")
        )
    end

    -- Search handler
    search.OnChange = function()
        PopulateScheduleList(list, search:GetValue())
    end

    PopulateScheduleList(list, "")
end

-- Public opener
function PsychEval_OpenScheduleWindow()
    net.Start("Schedule_RequestOpen")
    net.SendToServer()

    local frame = vgui.Create("DFrame")
    frame:SetSize(1080, 560)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)

    ActiveScheduleWindow = frame
    frame.OnRemove = function(s)
        if ActiveScheduleWindow == s then
            ActiveScheduleWindow = nil
        end
    end

    frame.UpdateFromServer = function()
        BuildScheduleUI(frame)
    end

    BuildScheduleUI(frame)
end

-- Net handlers
net.Receive("Schedule_Send", function()
    CurrentSchedule = net.ReadTable() or {}
    CanCreateSchedule = net.ReadBool()

    if IsPanelValid(ActiveScheduleWindow) and ActiveScheduleWindow.UpdateFromServer then
        ActiveScheduleWindow:UpdateFromServer()
    end
end)

net.Receive("Schedule_Notice", function()
    Derma_Message(net.ReadString(), "Schedule", "OK")
end)