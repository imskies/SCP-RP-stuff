pcall(function() include("psych_eval/cl_shared.lua") end)

if not PsychEval then PsychEval = {} end

local THEME = {
    bg = Color(8, 12, 18),
    panel = Color(16, 20, 27),
    panel_alt = Color(11, 15, 21),
    accent = Color(84, 176, 122),
    text = Color(240, 244, 248),
    muted = Color(156, 166, 181),
    stroke = Color(255, 255, 255, 26)
}

surface.CreateFont("BioLogs_Title", {font="Roboto Mono", size=24, weight=800})
surface.CreateFont("BioLogs_Body", {font="Roboto Mono", size=16, weight=600})
surface.CreateFont("BioLogs_Button", {font="Roboto Mono", size=16, weight=700})

local BG_GRAD = Material("bg_grad.png", "smooth")

local Frame = nil
local CurrentLogs = {}
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

local INCIDENT_OPTIONS = {
    "Virus Outbreak",
    "Virus Test",
    "Other"
}

local function ResolvePlayerTeamName()
    if PsychEval.ResolvePlayerTeamName then
        return PsychEval.ResolvePlayerTeamName(LocalPlayer())
    end
    if team and team.GetName then
        local tn = team.GetName(LocalPlayer():Team())
        if tn and tn ~= "" then return tn end
    end
    return tostring(LocalPlayer():Team())
end

local function IsMyJobListedForBioView()
    local teamName = ResolvePlayerTeamName()
    if PsychEval and PsychEval.BioViewAllowedTeams and PsychEval.BioViewAllowedTeams[teamName] then
        return true
    end
    if PsychEval and PsychEval.BioViewAllowedTeams and PsychEval.BioViewAllowedTeams[LocalPlayer():Team()] then
        return true
    end
    return false
end

local function IsMyJobAllowedToCreateBio()
    local teamName = ResolvePlayerTeamName()
    if PsychEval and PsychEval.BioCreateAllowedTeams and PsychEval.BioCreateAllowedTeams[teamName] then
        return true
    end
    if PsychEval and PsychEval.BioCreateAllowedTeams and PsychEval.BioCreateAllowedTeams[LocalPlayer():Team()] then
        return true
    end
    return false
end

local function IsMyJobAllowedToDelete()
    -- client-side hint: allow delete button if client is admin or in DeleteAllowedTeams
    if LocalPlayer():IsAdmin() then return true end
    local teamName = ResolvePlayerTeamName()
    if PsychEval and PsychEval.DeleteAllowedTeams and PsychEval.DeleteAllowedTeams[teamName] then
        return true
    end
    if PsychEval and PsychEval.DeleteAllowedTeams and PsychEval.DeleteAllowedTeams[LocalPlayer():Team()] then
        return true
    end
    return false
end

local function DrawBtn(s, w, h, txt)
    local bg = THEME.panel_alt or THEME.panel
    if s:IsDown() then
        bg = Color(18, 24, 32)
    elseif s:IsHovered() then
        bg = Color(22, 28, 38)
    end
    draw.RoundedBox(8, 0, 0, w, h, bg)
    surface.SetDrawColor(THEME.stroke or Color(255, 255, 255, 20))
    surface.DrawOutlinedRect(0, 0, w, h, 1)
    surface.SetDrawColor(THEME.accent.r, THEME.accent.g, THEME.accent.b, 235)
    surface.DrawRect(0, 0, w, 4)
    draw.SimpleText(string.upper(txt or "BUTTON"), "BioLogs_Button", w * 0.5, h * 0.5, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function CreateBtn(parent, x, y, w, h, txt, cb)
    local b = vgui.Create("DButton", parent)
    b:SetPos(x,y); b:SetSize(w,h); b:SetText("")
    b.DoClick = function() if isfunction(cb) then cb() end end
    b.Paint = function(s,w,h) DrawBtn(s,w,h,txt) end
    return AttachHoverSound(b)
end

local function StyleField(entry)
    if PsychEval_StyleTextEntry then
        PsychEval_StyleTextEntry(entry, {
            font = "BioLogs_Body",
            textColor = THEME.text,
            accentColor = THEME.accent,
            bgColor = THEME.panel_alt or THEME.panel,
            focusColor = Color(18, 24, 32),
            borderColor = Color(THEME.accent.r, THEME.accent.g, THEME.accent.b, 110),
            focusBorderColor = Color(THEME.accent.r, THEME.accent.g, THEME.accent.b, 220),
            placeholderColor = THEME.muted
        })
    end
    return entry
end

local function AddWindowCloseButton(frame)
    if not IsValid(frame) then return end
    local closeButton = vgui.Create("DButton", frame)
    closeButton:SetSize(30, 30)
    closeButton:SetText("")
    closeButton.Think = function(s)
        if not IsValid(frame) then return end
        s:SetPos(frame:GetWide() - 42, 14)
    end
    closeButton.DoClick = function()
        frame:Close()
    end
    closeButton.Paint = function(s, w, h)
        local col = s:IsHovered() and Color(220, 70, 70) or THEME.text
        draw.SimpleText("✕", "BioLogs_Body", w * 0.5, h * 0.5 - 1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    return AttachHoverSound(closeButton)
end

local function StyleSearchEntry(entry)
    if not IsValid(entry) then return end
    entry:SetDrawBackground(false)
    entry:SetTextColor(THEME.text)
    entry.Paint = function(self, w, h)
        local focused = self:HasFocus()
        local bg = focused and Color(18, 24, 32) or (THEME.panel_alt or THEME.panel)
        draw.RoundedBox(8, 0, 0, w, h, bg)
        surface.SetDrawColor(THEME.accent.r, THEME.accent.g, THEME.accent.b, focused and 220 or 110)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        self:DrawTextEntryText(THEME.text, THEME.accent, THEME.text)
        if self:GetValue() == "" and not focused then
            draw.SimpleText(self:GetPlaceholderText() or "", "BioLogs_Body", 12, h * 0.5, THEME.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
end

local function StyleScrollPanel(panel)
    if not IsValid(panel) or not panel.GetVBar then return end
    local vbar = panel:GetVBar()
    if not IsValid(vbar) then return end

    vbar.Paint = function(_, w, h)
        draw.RoundedBox(6, 0, 0, w, h, THEME.panel_alt or THEME.panel)
    end

    if IsValid(vbar.btnUp) then
        vbar.btnUp.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, THEME.panel)
            draw.SimpleText("▲", "BioLogs_Body", w * 0.5, h * 0.5 - 1, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    if IsValid(vbar.btnDown) then
        vbar.btnDown.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, THEME.panel)
            draw.SimpleText("▼", "BioLogs_Body", w * 0.5, h * 0.5 - 1, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    if IsValid(vbar.btnGrip) then
        vbar.btnGrip.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(THEME.accent.r, THEME.accent.g, THEME.accent.b, 140))
        end
    end
end

local function StyleBioList(list)
    if not IsValid(list) then return end

    list:SetHeaderHeight(30)
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
            draw.RoundedBox(6, 0, 0, w, h, Color(THEME.accent.r, THEME.accent.g, THEME.accent.b, 120))
        end
    end

    for _, column in ipairs(list.Columns or {}) do
        if IsValid(column.Header) then
            column.Header:SetFont("BioLogs_Body")
            column.Header:SetTextColor(THEME.text)
            column.Header:SetContentAlignment(5)
            column.Header.Paint = function(_, w, h)
                draw.RoundedBox(6, 0, 0, w, h, THEME.panel)
                surface.SetDrawColor(THEME.accent.r, THEME.accent.g, THEME.accent.b, 200)
                surface.DrawRect(0, h - 2, w, 2)
            end
        end
    end

    pcall(function()
        if list.Columns and list.Columns[1] and list.Columns[1].SetFixedWidth then
            list.Columns[1]:SetFixedWidth(48)
            list.Columns[2]:SetFixedWidth(108)
            list.Columns[3]:SetFixedWidth(175)
            list.Columns[4]:SetFixedWidth(135)
            list.Columns[5]:SetFixedWidth(85)
        end
    end)
end

local function StyleBioRow(row)
    if not IsValid(row) then return end
    for _, label in ipairs(row.Columns or {}) do
        if IsValid(label) then
            label:SetTextColor(THEME.text)
            label:SetFont("BioLogs_Body")
        end
    end

    row.Paint = function(self, w, h)
        local selected = self:IsSelected()
        local hovered = self:IsHovered()
        local bg = selected and Color(THEME.accent.r, THEME.accent.g, THEME.accent.b, 34) or (hovered and Color(255, 255, 255, 14) or Color(255, 255, 255, 6))
        draw.RoundedBox(6, 4, 2, w - 8, h - 4, bg)
        if selected then
            surface.SetDrawColor(THEME.accent.r, THEME.accent.g, THEME.accent.b, 220)
            surface.DrawRect(4, 2, 3, h - 4)
        end
    end
end

local function OpenLogDetail(entry, idx)
    local d = vgui.Create("DFrame")
    d:SetSize(math.min(780, ScrW() - 32), math.min(600, ScrH() - 32))
    d:Center()
    d:SetTitle("")
    d:MakePopup()
    d:ShowCloseButton(false)
    d.Paint = function(s, w, h)
        DrawGradientShell(10, w, h, THEME.bg, THEME.accent, 16)
        draw.RoundedBoxEx(10, 0, 0, w, 82, THEME.panel, true, true, false, false)
        surface.SetDrawColor(THEME.accent.r, THEME.accent.g, THEME.accent.b, 235)
        surface.DrawRect(0, 80, w, 2)
        draw.SimpleText("BIO LOG // " .. string.upper(entry.subject or "UNKNOWN"), "BioLogs_Title", 16, 14, THEME.accent)
        draw.SimpleText("Review selected biology record", "BioLogs_Body", 16, 48, THEME.muted)
    end
    AddWindowCloseButton(d)

    local margin = 16
    local fieldRows = {}

    local function addField(title, value)
        local titleLbl = vgui.Create("DLabel", d)
        titleLbl:SetFont("BioLogs_Body")
        titleLbl:SetTextColor(THEME.muted)
        titleLbl:SetText(string.upper(title or "FIELD"))
        titleLbl:SizeToContents()

        local valueBox = vgui.Create("DPanel", d)
        valueBox.Paint = function(_, w, h)
            draw.RoundedBox(8, 0, 0, w, h, THEME.panel_alt or THEME.panel)
        end

        local valueLbl = vgui.Create("DLabel", valueBox)
        valueLbl:SetFont("BioLogs_Body")
        valueLbl:SetTextColor(THEME.text)
        valueLbl:SetText(tostring(value or ""))
        valueLbl:SetContentAlignment(4)

        table.insert(fieldRows, {
            title = titleLbl,
            box = valueBox,
            value = valueLbl
        })
    end

    addField("Title", entry.subject or "")
    addField("Incident Type", entry.incident_type or "Unknown")
    addField("Date", entry.date or "")

    local notesTitle = vgui.Create("DLabel", d)
    notesTitle:SetFont("BioLogs_Body")
    notesTitle:SetTextColor(THEME.muted)
    notesTitle:SetText("NOTES")
    notesTitle:SizeToContents()

    local notesShell = vgui.Create("DPanel", d)
    notesShell.Paint = function(_, w, h)
        draw.RoundedBox(8, 0, 0, w, h, THEME.panel_alt or THEME.panel)
    end

    local scroll = vgui.Create("DScrollPanel", notesShell)
    scroll:Dock(FILL)
    scroll:DockMargin(8, 8, 8, 8)
    StyleScrollPanel(scroll)

    local notesLabel = vgui.Create("DLabel", scroll)
    notesLabel:SetFont("BioLogs_Body")
    notesLabel:SetTextColor(THEME.text)
    notesLabel:SetText(entry.notes or "")
    notesLabel:SetWrap(true)
    notesLabel:SetAutoStretchVertical(true)
    notesLabel:SetPos(6, 6)

    local btnX = 16
    local editBtn = nil
    if IsMyJobAllowedToCreateBio() then
        editBtn = CreateBtn(d, btnX, d:GetTall() - 72, 220, 56, "Edit Log", function()
            local ed = vgui.Create("DFrame")
            ed:SetSize(640,520); ed:Center(); ed:SetTitle(""); ed:MakePopup(); ed:ShowCloseButton(false)
            ed.Paint = function(s,w,h)
                DrawGradientShell(8, w, h, THEME.panel, THEME.accent, 16)
                draw.SimpleText("Edit Bio Log", "BioLogs_Title", 16, 10, THEME.accent)
            end
            AddWindowCloseButton(ed)

            local y2 = 56
            local titleLabel = vgui.Create("DLabel", ed)
            titleLabel:SetFont("BioLogs_Body"); titleLabel:SetTextColor(THEME.muted); titleLabel:SetText("Title:"); titleLabel:SizeToContents(); titleLabel:SetPos(16, y2)
            local titleEntry = vgui.Create("DTextEntry", ed)
            titleEntry:SetPos(16, y2 + 22); titleEntry:SetSize(ed:GetWide() - 32, 28); titleEntry:SetFont("BioLogs_Body")
            titleEntry:SetText(entry.subject or "")
            StyleField(titleEntry)
            y2 = y2 + 22 + 36

            local itLabel = vgui.Create("DLabel", ed)
            itLabel:SetFont("BioLogs_Body"); itLabel:SetTextColor(THEME.muted); itLabel:SetText("Incident Type:"); itLabel:SizeToContents(); itLabel:SetPos(16, y2)
            local incidentCombo = vgui.Create("DComboBox", ed)
            incidentCombo:SetPos(16, y2 + 22); incidentCombo:SetSize(ed:GetWide() - 32, 28)
            incidentCombo:SetFont("BioLogs_Body")
            PsychEval_StyleComboBox(incidentCombo, {
                font = "BioLogs_Body",
                textColor = THEME.text,
                bgColor = Color(22, 24, 28),
                hoverColor = Color(30, 33, 38),
                borderColor = Color(255, 255, 255, 18),
                arrowColor = THEME.accent
            })
            for _, opt in ipairs(INCIDENT_OPTIONS) do incidentCombo:AddChoice(opt) end
            incidentCombo:SetValue(entry.incident_type or INCIDENT_OPTIONS[1])
            y2 = y2 + 22 + 36

            local dateLabel = vgui.Create("DLabel", ed)
            dateLabel:SetFont("BioLogs_Body"); dateLabel:SetTextColor(THEME.muted); dateLabel:SetText("Date:"); dateLabel:SizeToContents(); dateLabel:SetPos(16, y2)
            local dateEntry = vgui.Create("DTextEntry", ed)
            dateEntry:SetPos(16, y2 + 22); dateEntry:SetSize(ed:GetWide() - 32, 28); dateEntry:SetFont("BioLogs_Body")
            dateEntry:SetText(entry.date or os.date("%Y-%m-%d"))
            StyleField(dateEntry)
            y2 = y2 + 22 + 36

            local notesWrap = vgui.Create("DScrollPanel", ed)
            notesWrap:SetPos(16, y2); notesWrap:SetSize(ed:GetWide() - 32, ed:GetTall() - y2 - 96)

            notesWrap.Paint = function(_, w, h)
                draw.RoundedBox(8, 0, 0, w, h, THEME.panel_alt or THEME.panel)
            end

            local notesEntry = vgui.Create("DTextEntry", notesWrap)
            notesEntry:SetPos(4,4); notesEntry:SetSize(notesWrap:GetWide() - 12, notesWrap:GetTall() - 12)
            notesEntry:SetMultiline(true); notesEntry:SetFont("BioLogs_Body")
            notesEntry:SetText(entry.notes or "")
            notesEntry:SetVerticalScrollbarEnabled(true)
            StyleField(notesEntry)

            CreateBtn(ed, 16, ed:GetTall() - 72, 220, 56, "Save Changes", function()
                local newEntry = {
                    subject = titleEntry:GetValue():Trim(),
                    incident_type = incidentCombo:GetValue(),
                    date = dateEntry:GetValue():Trim(),
                    notes = notesEntry:GetValue() or ""
                }
                net.Start("BioLogs_Edit")
                    net.WriteUInt(idx, 16)
                    net.WriteTable(newEntry)
                net.SendToServer()
                ed:Close()
                d:Close()
            end)
        end)
        btnX = btnX + 220 + 12
    end

    local delBtn = nil
    if IsMyJobAllowedToDelete() then
        delBtn = vgui.Create("DButton", d)
        delBtn:SetSize(220,56)
        delBtn:SetText("")
        AttachHoverSound(delBtn)
        delBtn.Paint = function(s,w,h)
            draw.RoundedBox(6,0,0,w,h,Color(180,40,40))
            draw.SimpleText("Delete Log", "BioLogs_Button", w*0.5, h*0.5, Color(240,240,240), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        delBtn.DoClick = function()
            Derma_Query("Delete this Bio Log? This action cannot be undone.", "Confirm Delete",
                "Delete", function()
                    net.Start("BioLogs_Delete")
                        net.WriteUInt(idx, 16)
                    net.SendToServer()
                    d:Close()
                end,
                "Cancel", function() end
            )
        end
    end

    local function LayoutBioDetail()
        local y = 96
        for _, row in ipairs(fieldRows) do
            row.title:SetPos(margin, y)
            row.box:SetPos(margin, y + row.title:GetTall() + 4)
            row.box:SetSize(d:GetWide() - margin * 2, 36)
            row.value:SetPos(12, 0)
            row.value:SetSize(row.box:GetWide() - 24, row.box:GetTall())
            y = y + row.title:GetTall() + row.box:GetTall() + 14
        end

        notesTitle:SetPos(margin, y)
        local notesTop = y + notesTitle:GetTall() + 6
        local actionY = d:GetTall() - 72
        local newNotesH = math.max(1, actionY - notesTop - 12)

        notesShell:SetPos(margin, notesTop)
        notesShell:SetSize(d:GetWide() - margin * 2, newNotesH)
        notesLabel:SetSize(notesShell:GetWide() - 28, 0)
        notesLabel:SizeToContentsY()

        local nextX = 16
        if IsValid(editBtn) then
            editBtn:SetPos(nextX, actionY)
            nextX = nextX + 220 + 12
        end
        if IsValid(delBtn) then
            delBtn:SetPos(nextX, actionY)
        end
    end

    d:SetSizable(true)
    d.OnSizeChanged = function()
        LayoutBioDetail()
    end
    LayoutBioDetail()
end

local function BuildUI(logs)
    CurrentLogs = logs or {}

    if IsValid(Frame) then
        local populate = Frame.PopulateList
        local search = Frame.SearchBox

        if isfunction(populate) and IsValid(search) then
            populate(search:GetValue() or "")
            return
        end

        Frame:Close()
        Frame = nil
    end

    Frame = vgui.Create("DFrame")
    Frame:SetSize(math.min(980, ScrW() - 24), math.min(720, ScrH() - 24)); Frame:Center(); Frame:SetTitle(""); Frame:MakePopup(); Frame:ShowCloseButton(false)
    Frame.Paint = function(s, w, h)
        DrawGradientShell(10, w, h, THEME.bg, THEME.accent, 16)
        draw.RoundedBoxEx(10, 0, 0, w, 84, THEME.panel, true, true, false, false)
        surface.SetDrawColor(THEME.accent.r, THEME.accent.g, THEME.accent.b, 235)
        surface.DrawRect(0, 82, w, 2)
        draw.SimpleText("RESEARCH TERMINAL // BIO LOGS", "BioLogs_Title", 18, 16, THEME.accent)
        draw.SimpleText("View and maintain biology records", "BioLogs_Body", 18, 50, THEME.muted)
    end
    AddWindowCloseButton(Frame)

    local leftW = math.floor(Frame:GetWide() * 0.66)
    local topY = 92
    local panelH = Frame:GetTall() - 132
    local left = vgui.Create("DPanel", Frame)
    left:SetPos(20, topY); left:SetSize(leftW, panelH)
    left.Paint = function(s, w, h)
        draw.RoundedBox(10, 0, 0, w, h, THEME.panel)
    end

    local right = vgui.Create("DPanel", Frame)
    right:SetPos(left:GetWide() + 40, topY); right:SetSize(Frame:GetWide() - left:GetWide() - 60, panelH)
    right.Paint = function(s, w, h)
        draw.RoundedBox(10, 0, 0, w, h, THEME.panel)
    end

    local search = vgui.Create("DTextEntry", left)
    search:SetPos(12,14); search:SetSize(left:GetWide() - 24, 40); search:SetFont("BioLogs_Body")
    search:SetPlaceholderText("Search by Title or Author...")
    StyleSearchEntry(search)
    Frame.SearchBox = search

    local list = vgui.Create("DListView", left)
    list:SetPos(12, 66); list:SetSize(left:GetWide() - 24, left:GetTall() - 78)
    list:SetMultiSelect(false)
    list:SetDataHeight(44)
    list:AddColumn("Index")
    list:AddColumn("Date")
    list:AddColumn("Title")
    list:AddColumn("Author")
    list:AddColumn("Clearance")
    StyleBioList(list)
    Frame.ListView = list

    local function Populate(filter)
        list:Clear()
        filter = filter or ""
        local f = string.lower(filter)
        for i, v in ipairs(CurrentLogs or {}) do
            local subject = v.subject or ""
            local author = v.author or ""
            local date = v.date or ""
            local clearance = tostring(v.clearance or "")
            local combined = string.lower(subject .. " " .. author)
            if f == "" or string.find(combined, f, 1, true) then
                local row = list:AddLine(i, date, subject, author, clearance)
                StyleBioRow(row)
            end
        end
    end

    Frame.PopulateList = Populate
    Populate("")
    search.OnChange = function() Populate(search:GetValue() or "") end

    list.DoDoubleClick = function(_, line)
        local idx = nil
        if type(line) == "table" or type(line) == "userdata" then
            local ok, val = pcall(function() return line:GetValue(1) end)
            if ok then idx = tonumber(val) end
        end
        if not idx then idx = tonumber(line) end
        if not idx or not CurrentLogs[idx] then Derma_Message("Selected log not found.","Error","OK") return end
        OpenLogDetail(CurrentLogs[idx], idx)
    end

    local btnW = math.min(260, right:GetWide() - 32)
    if IsMyJobAllowedToCreateBio() then
        CreateBtn(right, 16, 16, btnW, 56, "New Bio Log", function()
            local ed = vgui.Create("DFrame")
            ed:SetSize(640,520); ed:Center(); ed:SetTitle(""); ed:MakePopup(); ed:ShowCloseButton(false)
            ed.Paint = function(s,w,h)
                DrawGradientShell(8, w, h, THEME.panel, THEME.accent, 16)
                draw.SimpleText("New Bio Log", "BioLogs_Title", 16, 10, THEME.accent)
            end
            AddWindowCloseButton(ed)

            local y2 = 56
            -- Title field
            local titleLabel = vgui.Create("DLabel", ed)
            titleLabel:SetFont("BioLogs_Body"); titleLabel:SetTextColor(THEME.muted); titleLabel:SetText("Title:"); titleLabel:SizeToContents(); titleLabel:SetPos(16, y2)
            local titleEntry = vgui.Create("DTextEntry", ed)
            titleEntry:SetPos(16, y2 + 22); titleEntry:SetSize(ed:GetWide() - 32, 28); titleEntry:SetFont("BioLogs_Body")
            titleEntry:SetText("")
            StyleField(titleEntry)
            y2 = y2 + 22 + 36

            -- Incident Type combo
            local itLabel = vgui.Create("DLabel", ed)
            itLabel:SetFont("BioLogs_Body"); itLabel:SetTextColor(THEME.muted); itLabel:SetText("Incident Type:"); itLabel:SizeToContents(); itLabel:SetPos(16, y2)
            local incidentCombo = vgui.Create("DComboBox", ed)
            incidentCombo:SetPos(16, y2 + 22); incidentCombo:SetSize(ed:GetWide() - 32, 28)
            incidentCombo:SetFont("BioLogs_Body")
            PsychEval_StyleComboBox(incidentCombo, {
                font = "BioLogs_Body",
                textColor = THEME.text,
                bgColor = Color(22, 24, 28),
                hoverColor = Color(30, 33, 38),
                borderColor = Color(255, 255, 255, 18),
                arrowColor = THEME.accent
            })
            for _, opt in ipairs(INCIDENT_OPTIONS) do incidentCombo:AddChoice(opt) end
            incidentCombo:SetValue(INCIDENT_OPTIONS[1])
            y2 = y2 + 22 + 36

            -- Date field
            local dateLabel = vgui.Create("DLabel", ed)
            dateLabel:SetFont("BioLogs_Body"); dateLabel:SetTextColor(THEME.muted); dateLabel:SetText("Date:"); dateLabel:SizeToContents(); dateLabel:SetPos(16, y2)
            local dateEntry = vgui.Create("DTextEntry", ed)
            dateEntry:SetPos(16, y2 + 22); dateEntry:SetSize(ed:GetWide() - 32, 28); dateEntry:SetFont("BioLogs_Body")
            dateEntry:SetText(os.date("%Y-%m-%d"))
            StyleField(dateEntry)
            y2 = y2 + 22 + 36

            -- Notes
            local notesWrap = vgui.Create("DScrollPanel", ed)
            notesWrap:SetPos(16, y2); notesWrap:SetSize(ed:GetWide() - 32, ed:GetTall() - y2 - 96)

            notesWrap.Paint = function(_, w, h)
                draw.RoundedBox(8, 0, 0, w, h, THEME.panel_alt or THEME.panel)
            end

            local notesEntry = vgui.Create("DTextEntry", notesWrap)
            notesEntry:SetPos(4,4); notesEntry:SetSize(notesWrap:GetWide() - 12, notesWrap:GetTall() - 12)
            notesEntry:SetMultiline(true); notesEntry:SetFont("BioLogs_Body")
            notesEntry:SetText("")
            notesEntry:SetVerticalScrollbarEnabled(true)
            StyleField(notesEntry)

            CreateBtn(ed, 16, ed:GetTall() - 72, 220, 56, "Submit Log", function()
                local newEntry = {
                    subject = titleEntry:GetValue():Trim(),
                    incident_type = incidentCombo:GetValue(),
                    date = dateEntry:GetValue():Trim(),
                    notes = notesEntry:GetValue() or ""
                }
                net.Start("BioLogs_Submit")
                    net.WriteTable(newEntry)
                net.SendToServer()
                ed:Close()
            end)
        end)
    end

    CreateBtn(right, 16, 16 + (IsMyJobAllowedToCreateBio() and (56 + 12) or 0), btnW, 56, "Exit", function()
        Frame:Close()
        Frame = nil
    end)

    local infoY = 16 + 56 + 12 + 56 + 16
end

net.Receive("BioLogs_Send", function()
    local logs = net.ReadTable() or {}
    CurrentLogs = logs or CurrentLogs
    BuildUI(CurrentLogs)
end)

net.Receive("BioLogs_Refresh", function()
    local logs = net.ReadTable() or {}
    CurrentLogs = logs or CurrentLogs

    if not IsValid(Frame) then
        return
    end

    BuildUI(CurrentLogs)
end)

net.Receive("BioLogs_Denied", function()
    Derma_Message("You are not authorized to open Bio Logs.", "Bio Logs", "OK")
end)

net.Receive("BioLogs_Notice", function()
    local msg = net.ReadString() or "Notice"
    Derma_Message(msg, "Bio Logs", "OK")
end)