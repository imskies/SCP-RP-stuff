pcall(function() include("psych_eval/cl_shared.lua") end)

if not PsychEval then PsychEval = {} end

local PendingTestOpen = false

if CLIENT then
    local function ResolvePlayerTeamName()
        if not IsValid(LocalPlayer()) then return tostring(LocalPlayer() and LocalPlayer():Team() or "unknown") end
        if PsychEval.ResolvePlayerTeamName then
            return PsychEval.ResolvePlayerTeamName(LocalPlayer())
        end
        if team and team.GetName then
            local tn = team.GetName(LocalPlayer():Team())
            if tn and tn ~= "" then return tn end
        end
        return tostring(LocalPlayer():Team())
    end

    local function IsMyJobListed()
        local teamID = LocalPlayer():Team()
        if PsychEval and PsychEval.AccessByTeamID and PsychEval.AccessByTeamID[teamID] ~= nil then
            return true
        end
        local teamName = ResolvePlayerTeamName()
        if PsychEval and PsychEval.AccessByTeamName and PsychEval.AccessByTeamName[teamName] ~= nil then
            return true
        end
        if PsychEval and PsychEval.ClearanceByTeamID and PsychEval.ClearanceByTeamID[teamID] ~= nil then
            return true
        end
        if PsychEval and PsychEval.ClearanceByTeamName and PsychEval.ClearanceByTeamName[teamName] ~= nil then
            return true
        end
        return false
    end

    local function ShowDenied(reason)
        reason = reason or "You are not authorized to open the Research PC."
        Derma_Message(reason, "Research PC", "OK")
    end

    local function OpenPsychPC(desired)
        desired = desired or ""
        PendingTestOpen = (desired == "tests")

        if desired == "" and isfunction(PsychEval_OpenMainMenu) then
            PsychEval_OpenMainMenu()
            return
        end

        if PsychEval and PsychEval.RequireTeamListedToOpenPC and not IsMyJobListed() then
            ShowDenied("Your job is not listed in the Research PC configuration. You cannot open the terminal.")
            return
        end

        if desired == "tests" and PsychEval then
            local playerClearance = (PsychEval.GetPlayerClearance and PsychEval.GetPlayerClearance(LocalPlayer())) or PsychEval.DefaultClearance or 1
            local canOpenByClearance = playerClearance >= (PsychEval.MinClearanceToOpenTests or 1)
            local canOpenByPC = PsychEval.AllowPCOpenersToSubmitTests and IsMyJobListed()

            if not (canOpenByClearance or canOpenByPC) then
                ShowDenied("You do not have sufficient clearance to view Test Logs.")
                return
            end
        end

        net.Start("PsychEval_RequestOpen")
            net.WriteString(desired or "")
        net.SendToServer()
    end

    concommand.Add("psychpc_mainmenu", function()
        if isfunction(PsychEval_OpenMainMenu) then
            PsychEval_OpenMainMenu()
        else
            OpenPsychPC("")
        end
    end)
    concommand.Add("psychpc_tests", function() OpenPsychPC("tests") end)
    function PsychEval_RequestOpen(desired) OpenPsychPC(desired) end
    function PsychEval_RequestOpenTests() OpenPsychPC("tests") end
end
-- =========================
-- End client-side guard
-- =========================

local DEFAULT_SCALE = 0.80
local THEME = {
    bg = Color(8, 12, 18),
    panel = Color(16, 20, 27),
    panel_alt = Color(11, 15, 21),
    accent = Color(190, 198, 212),
    text = Color(240, 244, 248),
    muted = Color(156, 166, 181),
    stroke = Color(255, 255, 255, 26)
}

surface.CreateFont("SCP_Test_Title_LG", {font="Roboto Mono", size=28, weight=900})
surface.CreateFont("SCP_Test_Body", {font="Roboto Mono", size=18, weight=600})
surface.CreateFont("SCP_Test_Button", {font="Roboto Mono", size=18, weight=800})

local BG_GRAD = Material("bg_grad.png", "smooth")

local Frame = nil
local CurrentTests = {}
local CurrentAccess = 1
local CurrentCanGrade = false
local lastDenied = 0
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
    draw.SimpleText(string.upper(txt or "BUTTON"), "SCP_Test_Button", w * 0.5, h * 0.5, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function CreateBtn(parent, x, y, w, h, txt, cb)
    local b = vgui.Create("DButton", parent)
    b:SetPos(x,y); b:SetSize(w,h); b:SetText("")
    b.DoClick = function() if isfunction(cb) then cb() end end
    b.Paint = function(s,w,h) DrawBtn(s,w,h,txt) end
    return AttachHoverSound(b)
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
        draw.SimpleText("✕", "SCP_Test_Body", w * 0.5, h * 0.5 - 1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
            draw.SimpleText(self:GetPlaceholderText() or "", "SCP_Test_Body", 12, h * 0.5, THEME.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
            draw.SimpleText("▲", "SCP_Test_Body", w * 0.5, h * 0.5 - 1, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    if IsValid(vbar.btnDown) then
        vbar.btnDown.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, THEME.panel)
            draw.SimpleText("▼", "SCP_Test_Body", w * 0.5, h * 0.5 - 1, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    if IsValid(vbar.btnGrip) then
        vbar.btnGrip.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(THEME.accent.r, THEME.accent.g, THEME.accent.b, 140))
        end
    end
end

local function StyleTestList(list)
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
            column.Header:SetFont("SCP_Test_Body")
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
            list.Columns[2]:SetFixedWidth(110)
            list.Columns[3]:SetFixedWidth(165)
            list.Columns[4]:SetFixedWidth(85)
            list.Columns[5]:SetFixedWidth(70)
        end
    end)
end

local function StyleTestRow(row)
    if not IsValid(row) then return end
    for _, label in ipairs(row.Columns or {}) do
        if IsValid(label) then
            label:SetTextColor(THEME.text)
            label:SetFont("SCP_Test_Body")
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

local function BuildList(list, tests, filter)
    if not IsValid(list) then return end
    list:Clear()
    filter = filter or ""
    local f = string.lower(filter)
    for i, v in ipairs(tests or {}) do
        local subject = v.subject or ""
        local psych = v.psychologist or ""
        local date = v.date or ""
        local clearance = tostring(v.clearance or "")
        local grade = tostring(v.grade or "")
        local combined = string.lower(subject .. " " .. psych)
        if f == "" or string.find(combined, f, 1, true) then
            local row = list:AddLine(i, date, subject, clearance, grade, psych)
            StyleTestRow(row)
        end
    end
end

local function EnsureColumnsOnce(list)
    if not IsValid(list) then return end
    if list._psych_columns_added then return end

    pcall(function() list:AddColumn("Index") end)
    pcall(function() list:AddColumn("Date") end)
    pcall(function() list:AddColumn("Subject") end)
    pcall(function() list:AddColumn("Clearance") end)
    pcall(function() list:AddColumn("Grade") end)
    pcall(function() list:AddColumn("Tester") end)

    list._psych_columns_added = true
end

local function CreateScaledFrame(scale)
    local sw, sh = ScrW(), ScrH()
    local w = math.floor(sw * (scale or DEFAULT_SCALE))
    local h = math.floor(sh * (scale or DEFAULT_SCALE))
    local frame = vgui.Create("DFrame")
    frame:SetSize(w, h)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame.Paint = function(s, ww, hh)
        DrawGradientShell(10, ww, hh, THEME.bg, THEME.accent, 16)
        draw.RoundedBoxEx(10, 0, 0, ww, 84, THEME.panel, true, true, false, false)
        surface.SetDrawColor(THEME.accent.r, THEME.accent.g, THEME.accent.b, 235)
        surface.DrawRect(0, 82, ww, 2)
        draw.SimpleText("RESEARCH TERMINAL // TEST LOGS", "SCP_Test_Title_LG", 22, 18, THEME.accent)
        draw.SimpleText("Browse and submit testing records", "SCP_Test_Body", 22, 50, THEME.muted)
    end
    AddWindowCloseButton(frame)
    return frame
end

-- Local helpers for delete permission check (client-side hint)
local function ResolvePlayerTeamNameLocal()
    if PsychEval.ResolvePlayerTeamName then
        return PsychEval.ResolvePlayerTeamName(LocalPlayer())
    end
    if team and team.GetName then
        local tn = team.GetName(LocalPlayer():Team())
        if tn and tn ~= "" then return tn end
    end
    return tostring(LocalPlayer():Team())
end

local function IsPlayerAllowedDeleteClient()
    if LocalPlayer():IsAdmin() then return true end
    local teamName = ResolvePlayerTeamNameLocal()
    if PsychEval.DeleteAllowedTeams and PsychEval.DeleteAllowedTeams[teamName] then return true end
    if PsychEval.DeleteAllowedTeams and PsychEval.DeleteAllowedTeams[LocalPlayer():Team()] then return true end
    return false
end

local function RequestTestPanelOpen()
    PendingTestOpen = true

    if isfunction(PsychEval_RequestOpenTests) then
        PsychEval_RequestOpenTests()
        return
    end

    net.Start("PsychEval_RequestOpen")
        net.WriteString("tests")
    net.SendToServer()
end

local function OpenTestDetail(entry, index, access)
    local d = vgui.Create("DFrame")
    d:SetSize(math.min(900, ScrW() - 32), math.min(760, ScrH() - 32))
    d:Center()
    d:SetTitle("")
    d:MakePopup()
    d:ShowCloseButton(false)

    d.Paint = function(s, w, h)
        DrawGradientShell(10, w, h, THEME.bg, THEME.accent, 16)
        draw.RoundedBoxEx(10, 0, 0, w, 82, THEME.panel, true, true, false, false)
        surface.SetDrawColor(THEME.accent.r, THEME.accent.g, THEME.accent.b, 235)
        surface.DrawRect(0, 80, w, 2)
        draw.SimpleText("TEST LOG // " .. string.upper(entry.subject or "UNKNOWN"), "SCP_Test_Title_LG", 18, 14, THEME.accent)
        draw.SimpleText("Review selected testing record", "SCP_Test_Body", 18, 48, THEME.muted)
    end
    AddWindowCloseButton(d)

    local margin = 18
    local fieldRows = {}

    local function addStaticField(title, value)
        local titleLbl = vgui.Create("DLabel", d)
        titleLbl:SetFont("SCP_Test_Body")
        titleLbl:SetTextColor(THEME.muted)
        titleLbl:SetText(string.upper(title or "FIELD"))
        titleLbl:SizeToContents()

        local valueBox = vgui.Create("DPanel", d)
        valueBox.Paint = function(_, w, h)
            draw.RoundedBox(8, 0, 0, w, h, THEME.panel_alt or THEME.panel)
        end

        local valueLbl = vgui.Create("DLabel", valueBox)
        valueLbl:SetFont("SCP_Test_Body")
        valueLbl:SetTextColor(THEME.text)
        valueLbl:SetText(tostring(value or ""))
        valueLbl:SetContentAlignment(4)

        table.insert(fieldRows, {
            title = titleLbl,
            box = valueBox,
            value = valueLbl
        })
    end

    addStaticField("Tester", entry.psychologist or "")
    addStaticField("Name", entry.name or "")
    addStaticField("Subject", entry.subject or "")
    addStaticField("Date", entry.date or "")
    addStaticField("Clearance Level", tostring(entry.clearance or "1"))
    addStaticField("Grade", tostring(entry.grade or "Unassigned"))

    local notesTitle = vgui.Create("DLabel", d)
    notesTitle:SetFont("SCP_Test_Body")
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
    notesLabel:SetFont("SCP_Test_Body")
    notesLabel:SetTextColor(THEME.text)
    notesLabel:SetText(entry.notes or "")
    notesLabel:SetWrap(true)
    notesLabel:SetAutoStretchVertical(true)
    notesLabel:SetPos(6, 6)

    local editBtn = nil
    if access >= 3 and CurrentCanGrade then
        editBtn = CreateBtn(d, margin, d:GetTall() - 72, 220, 56, "Edit Test / Grade", function()
            include("vgui/cl_psych_test.lua")
            PsychEval_ClientAccess = access
            PsychEval_ClientCanGrade = CurrentCanGrade
            OpenPsychTest(entry, index, function()
                RequestTestPanelOpen()
            end)
            d:Close()
        end)
    end

    local delBtn = nil
    if IsPlayerAllowedDeleteClient() then
        delBtn = vgui.Create("DButton", d)
        delBtn:SetSize(220, 56)
        delBtn:SetText("")
        AttachHoverSound(delBtn)
        delBtn.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(180, 40, 40))
            draw.SimpleText("Delete Test Log", "SCP_Test_Button", w * 0.5, h * 0.5, Color(240,240,240), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        delBtn.DoClick = function()
            Derma_Query("Delete this Test Log? This action cannot be undone.", "Confirm Delete",
                "Delete", function()
                    net.Start("TestLogs_Delete")
                        net.WriteUInt(index, 16)
                        net.WriteString(tostring(entry.subject or ""))
                        net.WriteString(tostring(entry.date or ""))
                        net.WriteString(tostring(entry.author or entry.psychologist or ""))
                    net.SendToServer()
                    d:Close()
                end,
                "Cancel", function() end
            )
        end
    end

    local function LayoutDetailWindow()
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

        local nextX = margin
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
        LayoutDetailWindow()
    end
    LayoutDetailWindow()
end

local function BuildUI(tests, access, canGrade)
    CurrentTests = tests or {}
    CurrentAccess = access or 1
    CurrentCanGrade = canGrade or false

    if IsValid(Frame) then
        local list = Frame.ListView
        local search = Frame.SearchBox
        if IsValid(list) and IsValid(search) then
            BuildList(list, CurrentTests, search:GetValue() or "")
            return
        else
            Frame:Close()
            Frame = nil
        end
    end

    Frame = CreateScaledFrame(DEFAULT_SCALE)

    local leftW = math.floor(Frame:GetWide() * 0.66)
    local left = vgui.Create("DPanel", Frame)
    left:SetPos(20, 92); left:SetSize(leftW, Frame:GetTall() - 132)
    left.Paint = function(s,w,h) draw.RoundedBox(8,0,0,w,h,THEME.panel) end

    local search = vgui.Create("DTextEntry", left)
    search:SetPos(12,12); search:SetSize(left:GetWide() - 24, 40); search:SetFont("SCP_Test_Body")
    search:SetPlaceholderText("Search by Subject or Tester...")
    StyleSearchEntry(search)
    Frame.SearchBox = search

    local scrollWrap = vgui.Create("DScrollPanel", left)
    scrollWrap:SetPos(12, 64)
    scrollWrap:SetSize(left:GetWide() - 24, left:GetTall() - 84)
    StyleScrollPanel(scrollWrap)

    local list = vgui.Create("DListView", scrollWrap)
    list:SetPos(0, 0)
    list:SetSize(scrollWrap:GetWide(), scrollWrap:GetTall())
    list:SetDataHeight(48)
    list:SetMultiSelect(false)
    Frame.ListView = list

    EnsureColumnsOnce(list)
    StyleTestList(list)
    BuildList(list, CurrentTests, "")

    search.OnChange = function() BuildList(list, CurrentTests, search:GetValue()) end

    list.DoDoubleClick = function(a,b)
        local line = nil
        if type(b) == "table" and IsValid(b) then line = b end
        if not line and type(a) == "table" and IsValid(a) then line = a end
        if not line then
            local idxNum = tonumber(a) or tonumber(b)
            if idxNum then line = list:GetLine(idxNum) end
        end
        if not IsValid(line) then Derma_Message("Could not determine selected entry.","Error","OK") return end
        local idx = tonumber(line:GetValue(1))
        if not idx or not CurrentTests[idx] then Derma_Message("Selected entry not found.","Error","OK") return end
        OpenTestDetail(CurrentTests[idx], idx, CurrentAccess)
    end

    local right = vgui.Create("DPanel", Frame)
    right:SetPos(left:GetWide() + 40, 92)
    right:SetSize(Frame:GetWide() - left:GetWide() - 60, Frame:GetTall() - 132)
    right.Paint = function(s,w,h) draw.RoundedBox(8,0,0,w,h,THEME.panel) end

    local btnW = math.min(260, right:GetWide() - 32)
    CreateBtn(right, 16, 16, btnW, 56, "Log Test", function()
        include("vgui/cl_psych_test.lua")
        PsychEval_ClientAccess = CurrentAccess
        PsychEval_ClientCanGrade = CurrentCanGrade
        OpenPsychTest(nil, nil, function()
            RequestTestPanelOpen()
        end)
    end)

    CreateBtn(right, 16, 16 + 56 + 12, btnW, 56, "Exit", function()
        Frame:Close()
        Frame = nil
    end)

    local info = vgui.Create("DLabel", right)
    info:SetFont("SCP_Test_Body"); info:SetTextColor(THEME.muted)
    info:SetText("")
    info:SizeToContents(); info:SetPos(16, 16 + 56 + 12 + 56 + 16)
end

-- Receive tests data (server -> client)
net.Receive("PsychEval_SendTests", function()
    local access = net.ReadUInt(3) or 1
    local canGrade = net.ReadBool() or false
    local tests = net.ReadTable() or {}

    if not PendingTestOpen and not IsValid(Frame) then
        return
    end

    PendingTestOpen = false
    BuildUI(tests, access, canGrade)
end)

-- Refresh broadcast
net.Receive("PsychEval_Refresh", function()
    local access = net.ReadUInt(3) or 1
    local evals = net.ReadTable() or {}

    if not IsValid(Frame) then
        return
    end

    local tests = {}
    for i, v in ipairs(evals or {}) do
        if v.clearance ~= nil or v.name ~= nil or v.grade ~= nil then table.insert(tests, v) end
    end
    BuildUI(tests, access, CurrentCanGrade)
end)

-- Denied message (rate-limited)
net.Receive("PsychEval_Denied", function()
    local now = CurTime()
    if now - lastDenied < 1.5 then return end
    lastDenied = now
    chat.AddText(Color(200,50,50), "[Research Computer] ", Color(255,255,255), "You do not have access to this system.")
end)