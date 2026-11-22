pcall(function() include("psych_eval/cl_shared.lua") end)

if not PsychEval then PsychEval = {} end

local FRAME_W, FRAME_H = 1100, 760
local THEME = {
    bg = Color(8, 12, 18),
    panel = Color(16, 20, 27),
    panel_alt = Color(11, 15, 21),
    accent = Color(206, 82, 82),
    accent_dark = Color(148, 52, 52),
    text = Color(240, 244, 248),
    muted = Color(156, 166, 181),
    glow = Color(206, 82, 82, 70),
    button_hover = Color(226, 102, 102),
    button_pressed = Color(150, 56, 56),
    stroke = Color(255, 255, 255, 26)
}

-- Fonts
surface.CreateFont("SCP_Terminal_Title_XXL", {font = "Roboto Mono", size = 36, weight = 900, antialias = true})
surface.CreateFont("SCP_Terminal_Header_XL", {font = "Roboto Mono", size = 24, weight = 800, antialias = true})
surface.CreateFont("SCP_Terminal_Body_XL", {font = "Roboto Mono", size = 20, weight = 600, antialias = true})
surface.CreateFont("SCP_Terminal_Small_XL", {font = "Roboto Mono", size = 18, weight = 500, antialias = true})
surface.CreateFont("SCP_Terminal_Button_XL", {font = "Roboto Mono", size = 20, weight = 800, antialias = true})
surface.CreateFont("SCP_Terminal_List_XL", {font = "Roboto Mono", size = 18, weight = 700, antialias = true})

local BG_GRAD = Material("bg_grad.png", "smooth")

local MainFrame = nil
local CurrentEvals = {}
local CurrentAccess = 1
local CurrentCanGrade = false
local PendingEvalOpen = false
local lastDeniedTime = 0
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
    local col = THEME.accent
    local bg = THEME.panel_alt or THEME.panel
    if isDown then
        bg = Color(18, 24, 32)
    elseif isHovered then
        bg = Color(22, 28, 38)
    end

    draw.RoundedBox(8, 0, 0, w, h, bg)
    surface.SetDrawColor(THEME.stroke or Color(255, 255, 255, 20))
    surface.DrawOutlinedRect(0, 0, w, h, 1)
    surface.SetDrawColor(col.r, col.g, col.b, 235)
    surface.DrawRect(0, 0, w, 4)
    draw.SimpleText(string.upper(text or "BUTTON"), "SCP_Terminal_Button_XL", w * 0.5, h * 0.5, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
        draw.SimpleText("✕", "SCP_Terminal_Body_XL", w * 0.5, h * 0.5 - 1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    return AttachHoverSound(closeButton)
end

local function CreateRoundedPanel(parent, x, y, w, h, color)
    local pnl = vgui.Create("DPanel", parent)
    pnl:SetPos(x, y)
    pnl:SetSize(w, h)
    pnl.Paint = function(s, pw, ph)
        draw.RoundedBox(10, 0, 0, pw, ph, color or THEME.panel)
    end
    return pnl
end

local function StyleScrollPanel(panel, accent)
    if not IsValid(panel) or not panel.GetVBar then return end
    local stripe = accent or THEME.accent
    local vbar = panel:GetVBar()
    if not IsValid(vbar) then return end

    vbar.Paint = function(_, w, h)
        draw.RoundedBox(6, 0, 0, w, h, THEME.panel_alt or THEME.panel)
    end

    if IsValid(vbar.btnUp) then
        vbar.btnUp.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, THEME.panel)
            draw.SimpleText("▲", "SCP_Terminal_Small_XL", w * 0.5, h * 0.5 - 1, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    if IsValid(vbar.btnDown) then
        vbar.btnDown.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, THEME.panel)
            draw.SimpleText("▼", "SCP_Terminal_Small_XL", w * 0.5, h * 0.5 - 1, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    if IsValid(vbar.btnGrip) then
        vbar.btnGrip.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(stripe.r, stripe.g, stripe.b, 140))
        end
    end
end

local function StyleTerminalList(list, accent)
    if not IsValid(list) then return end
    local stripe = accent or THEME.accent

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
            draw.RoundedBox(6, 0, 0, w, h, Color(stripe.r, stripe.g, stripe.b, 120))
        end
    end

    for _, column in ipairs(list.Columns or {}) do
        if IsValid(column.Header) then
            column.Header:SetFont("SCP_Terminal_Small_XL")
            column.Header:SetTextColor(THEME.text)
            column.Header:SetContentAlignment(5)
            column.Header.Paint = function(_, w, h)
                draw.RoundedBox(6, 0, 0, w, h, THEME.panel)
                surface.SetDrawColor(stripe.r, stripe.g, stripe.b, 200)
                surface.DrawRect(0, h - 2, w, 2)
            end
        end
    end

    pcall(function()
        if list.Columns and list.Columns[1] and list.Columns[1].SetFixedWidth then
            list.Columns[1]:SetFixedWidth(52)
            list.Columns[2]:SetFixedWidth(110)
            list.Columns[3]:SetFixedWidth(160)
            list.Columns[4]:SetFixedWidth(120)
        end
    end)
end

local function StyleTerminalRow(row, accent)
    if not IsValid(row) then return end
    local stripe = accent or THEME.accent

    for _, label in ipairs(row.Columns or {}) do
        if IsValid(label) then
            label:SetTextColor(THEME.text)
            label:SetFont("SCP_Terminal_Small_XL")
        end
    end

    row.Paint = function(self, w, h)
        local selected = self:IsSelected()
        local hovered = self:IsHovered()
        local bg = selected and Color(stripe.r, stripe.g, stripe.b, 34) or (hovered and Color(255, 255, 255, 14) or Color(255, 255, 255, 6))
        draw.RoundedBox(6, 4, 2, w - 8, h - 4, bg)
        if selected then
            surface.SetDrawColor(stripe.r, stripe.g, stripe.b, 220)
            surface.DrawRect(4, 2, 3, h - 4)
        end
    end
end

local function StyleTerminalSearchEntry(entry, accent)
    if not IsValid(entry) then return end
    local stripe = accent or THEME.accent
    entry:SetDrawBackground(false)
    entry:SetTextColor(THEME.text)
    entry.Paint = function(self, w, h)
        local focused = self:HasFocus()
        local bg = focused and Color(18, 24, 32) or (THEME.panel_alt or THEME.panel)
        draw.RoundedBox(8, 0, 0, w, h, bg)
        surface.SetDrawColor(stripe.r, stripe.g, stripe.b, focused and 220 or 110)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        self:DrawTextEntryText(THEME.text, stripe, THEME.text)
        if self:GetValue() == "" and not focused then
            draw.SimpleText(self:GetPlaceholderText() or "", "SCP_Terminal_Small_XL", 12, h * 0.5, THEME.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
end

local function BuildList(list, evals, filter)
    if not IsValid(list) then return end
    list:Clear()
    filter = filter or ""
    local f = string.lower(filter)

    for i, v in ipairs(evals or {}) do
        local subject = v.subject or ""
        local psych = v.psychologist or ""
        local date = v.date or ""
        local state = v.state or ""
        local combined = string.lower(subject .. " " .. psych)
        if f == "" or string.find(combined, f, 1, true) then
            local row = list:AddLine(i, date, subject, state, psych)
            StyleTerminalRow(row, THEME.accent)
        end
    end
end

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

local function RequestEvalPanelOpen()
    PendingEvalOpen = true
    net.Start("PsychEval_RequestOpen")
    net.WriteString("evals")
    net.SendToServer()
end

PsychEval_RequestOpenEvals = RequestEvalPanelOpen

local function OpenDetailWindow(entry, index, access, parentFrame)
    local detail = vgui.Create("DFrame")
    detail:SetSize(math.min(760, ScrW() - 32), math.min(600, ScrH() - 32))
    detail:Center()
    detail:SetTitle("")
    detail:MakePopup()
    detail:ShowCloseButton(false)
    detail.Paint = function(s, w, h)
        DrawGradientShell(10, w, h, THEME.bg, THEME.accent, 16)
        draw.RoundedBoxEx(10, 0, 0, w, 82, THEME.panel, true, true, false, false)
        surface.SetDrawColor(THEME.accent.r, THEME.accent.g, THEME.accent.b, 235)
        surface.DrawRect(0, 80, w, 2)
        draw.SimpleText("EVALUATION // " .. string.upper(entry.subject or "UNKNOWN"), "SCP_Terminal_Header_XL", 18, 14, THEME.accent)
        draw.SimpleText("Review selected psychological record", "SCP_Terminal_Small_XL", 18, 48, THEME.muted)
    end
    AddWindowCloseButton(detail)

    local margin = 20
    local fieldRows = {}

    local function addField(title, value)
        local titleLbl = vgui.Create("DLabel", detail)
        titleLbl:SetFont("SCP_Terminal_Small_XL")
        titleLbl:SetTextColor(THEME.muted)
        titleLbl:SetText(string.upper(title or "FIELD"))
        titleLbl:SizeToContents()

        local valueBox = vgui.Create("DPanel", detail)
        valueBox.Paint = function(_, w, h)
            draw.RoundedBox(8, 0, 0, w, h, THEME.panel_alt or THEME.panel)
        end

        local valueLbl = vgui.Create("DLabel", valueBox)
        valueLbl:SetFont("SCP_Terminal_Body_XL")
        valueLbl:SetTextColor(THEME.text)
        valueLbl:SetText(tostring(value or ""))
        valueLbl:SetContentAlignment(4)

        table.insert(fieldRows, {
            title = titleLbl,
            box = valueBox,
            value = valueLbl
        })
    end

    addField("Psychologist", entry.psychologist or "")
    addField("Subject", entry.subject or "")
    addField("Date", entry.date or "")
    addField("Mental State", entry.state or "")

    local notesTitle = vgui.Create("DLabel", detail)
    notesTitle:SetFont("SCP_Terminal_Small_XL")
    notesTitle:SetTextColor(THEME.muted)
    notesTitle:SetText("NOTES")
    notesTitle:SizeToContents()

    local notesShell = vgui.Create("DPanel", detail)
    notesShell.Paint = function(_, w, h)
        draw.RoundedBox(8, 0, 0, w, h, THEME.panel_alt or THEME.panel)
    end

    local scroll = vgui.Create("DScrollPanel", notesShell)
    scroll:Dock(FILL)
    scroll:DockMargin(8, 8, 8, 8)
    StyleScrollPanel(scroll, THEME.accent)

    local notesBody = vgui.Create("DLabel", scroll)
    notesBody:SetFont("SCP_Terminal_Body_XL")
    notesBody:SetTextColor(THEME.text)
    notesBody:SetText(entry.notes or "")
    notesBody:SetWrap(true)
    notesBody:SetAutoStretchVertical(true)
    notesBody:SetPos(6, 6)

    local editBtn = nil
    local delBtn = nil
    local btnW = 220
    local btnH = 56

    if access >= 3 and CurrentCanGrade then
        editBtn = CreateThemedButton(detail, margin, detail:GetTall() - 72, btnW, btnH, "Edit Entry", function()
            include("vgui/cl_psych_entry.lua")
            PsychEval_ClientAccess = access
            PsychEval_ClientCanGrade = CurrentCanGrade
            OpenPsychEntry(entry, index, function()
                RequestEvalPanelOpen()
            end)
            detail:Close()
            if IsValid(parentFrame) then parentFrame:Close() end
        end)
    end

    if IsPlayerAllowedDeleteClient() then
        delBtn = vgui.Create("DButton", detail)
        delBtn:SetSize(btnW, btnH)
        delBtn:SetText("")
        AttachHoverSound(delBtn)
        delBtn.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(180, 40, 40))
            draw.SimpleText("Delete Eval", "SCP_Terminal_Button_XL", w * 0.5, h * 0.5, Color(240,240,240), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        delBtn.DoClick = function()
            Derma_Query("Delete this Psych Eval? This action cannot be undone.", "Confirm Delete",
                "Delete", function()
                    net.Start("PsychEval_Delete")
                        net.WriteUInt(index, 16)
                    net.SendToServer()
                    detail:Close()
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
            row.box:SetSize(detail:GetWide() - margin * 2, 38)
            row.value:SetPos(12, 0)
            row.value:SetSize(row.box:GetWide() - 24, row.box:GetTall())
            y = y + row.title:GetTall() + row.box:GetTall() + 14
        end

        notesTitle:SetPos(margin, y)
        local notesTop = y + notesTitle:GetTall() + 6
        local actionY = detail:GetTall() - 72
        local notesH = math.max(1, actionY - notesTop - 12)

        notesShell:SetPos(margin, notesTop)
        notesShell:SetSize(detail:GetWide() - margin * 2, notesH)
        notesBody:SetSize(notesShell:GetWide() - 28, 0)
        notesBody:SizeToContentsY()

        local btnX = margin
        if IsValid(editBtn) then
            editBtn:SetPos(btnX, actionY)
            btnX = btnX + btnW + 12
        end
        if IsValid(delBtn) then
            delBtn:SetPos(btnX, actionY)
        end
    end

    detail:SetSizable(true)
    detail.OnSizeChanged = function()
        LayoutDetailWindow()
    end
    LayoutDetailWindow()
end

local function BuildMainUI(evals, access, canGrade)
    CurrentEvals = evals or {}
    CurrentAccess = access or 1
    CurrentCanGrade = canGrade or false

    if IsValid(MainFrame) then
        local list = MainFrame.ListView
        local searchBox = MainFrame.SearchBox

        if IsValid(list) and IsValid(searchBox) then
            local search = searchBox:GetValue() or ""
            BuildList(list, CurrentEvals, search)
            return
        else
            MainFrame:Close()
            MainFrame = nil
        end
    end

    MainFrame = vgui.Create("DFrame")
    MainFrame:SetSize(math.min(FRAME_W, ScrW() - 24), math.min(FRAME_H, ScrH() - 24))
    MainFrame:Center()
    MainFrame:SetTitle("")
    MainFrame:MakePopup()
    MainFrame:SetDraggable(true)
    MainFrame:ShowCloseButton(false)
    MainFrame.Paint = function(s, w, h)
        DrawGradientShell(10, w, h, THEME.bg, THEME.accent, 16)
        draw.RoundedBoxEx(10, 0, 0, w, 84, THEME.panel, true, true, false, false)
        draw.SimpleText("RESEARCH TERMINAL // PSYCH EVALUATION LOGS", "SCP_Terminal_Title_XXL", 22, 18, THEME.accent)
        draw.SimpleText("Review, search, and log evaluation records", "SCP_Terminal_Small_XL", 22, 54, THEME.muted)
        surface.SetDrawColor(THEME.glow)
        surface.DrawRect(0, 82, w, 2)
    end
    AddWindowCloseButton(MainFrame)

    local frameW, frameH = MainFrame:GetWide(), MainFrame:GetTall()
    local leftW = math.min(560, math.floor((frameW - 60) * 0.58))
    local rightX = 20 + leftW + 20
    local rightW = frameW - rightX - 20

    local left = CreateRoundedPanel(MainFrame, 20, 92, leftW, frameH - 132, THEME.panel)

    local searchBox = vgui.Create("DTextEntry", left)
    searchBox:SetPos(16, 14)
    searchBox:SetSize(left:GetWide() - 140, 40)
    searchBox:SetFont("SCP_Terminal_Body_XL")
    searchBox:SetTextColor(THEME.text)
    searchBox:SetPlaceholderText("Search by Subject or Psychologist...")
    StyleTerminalSearchEntry(searchBox, THEME.accent)
    searchBox.OnChange = function()
        BuildList(left.ListView, CurrentEvals, searchBox:GetValue())
    end
    MainFrame.SearchBox = searchBox

    CreateThemedButton(left, left:GetWide() - 112, 14, 96, 40, "Clear", function()
        searchBox:SetText("")
        BuildList(left.ListView, CurrentEvals, "")
    end)

    local list = vgui.Create("DListView", left)
    list:SetPos(12, 68)
    list:SetSize(left:GetWide() - 24, left:GetTall() - 84)
    list:AddColumn("Index")
    list:AddColumn("Date")
    list:AddColumn("Subject")
    list:AddColumn("State")
    list:AddColumn("Psychologist")
    list:SetMultiSelect(false)
    list:SetDataHeight(44)
    StyleTerminalList(list, THEME.accent)
    left.ListView = list
    MainFrame.ListView = list

    BuildList(list, CurrentEvals, "")

    local right = CreateRoundedPanel(MainFrame, rightX, 92, rightW, frameH - 132, THEME.panel)

    local panelPadding = 16
    local actionH = 48
    local actionGap = 12
    local bottomRowY = right:GetTall() - actionH - panelPadding
    local infoBoxBottom = bottomRowY - 14

    local infoTitle = vgui.Create("DLabel", right)
    infoTitle:SetPos(panelPadding, 14)
    infoTitle:SetFont("SCP_Terminal_Header_XL")
    infoTitle:SetTextColor(THEME.accent)
    infoTitle:SetText("Selected Entry")
    infoTitle:SizeToContents()

    local infoBox = vgui.Create("DPanel", right)
    infoBox:SetPos(panelPadding, 52)
    infoBox:SetSize(right:GetWide() - (panelPadding * 2), math.max(160, infoBoxBottom - 52))
    infoBox.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(8, 10, 14, 220))
    end

    local infoLabel = vgui.Create("DLabel", infoBox)
    infoLabel:SetPos(16, 12)
    infoLabel:SetSize(infoBox:GetWide() - 32, infoBox:GetTall() - 24)
    infoLabel:SetFont("SCP_Terminal_Body_XL")
    infoLabel:SetTextColor(THEME.muted)
    infoLabel:SetWrap(true)
    infoLabel:SetAutoStretchVertical(true)
    infoLabel:SetText("Select an entry from the list to view details here. Double-click an entry to open it.")

    list.OnRowSelected = function(_, rowIndex, rowPanel)
        if not IsValid(rowPanel) then return end
        local idxStr = rowPanel:GetValue(1)
        local idx = tonumber(idxStr)
        local entry = CurrentEvals[idx]
        if not entry then
            infoLabel:SetText("Selected entry not found.")
            return
        end

        local txt = ""
        txt = txt .. "Psychologist: " .. (entry.psychologist or "") .. "\n"
        txt = txt .. "Subject: " .. (entry.subject or "") .. "\n"
        txt = txt .. "Date: " .. (entry.date or "") .. "\n"
        txt = txt .. "Mental State: " .. (entry.state or "") .. "\n\n"
        txt = txt .. "Notes:\n" .. (entry.notes or "")
        infoLabel:SetText(txt)
    end

    list.DoDoubleClick = function(a, b)
        local linePanel = nil

        if type(b) == "table" and IsValid(b) then
            linePanel = b
        end

        if not linePanel and type(a) == "table" and IsValid(a) then
            linePanel = a
        end

        if not linePanel then
            local idxNum = tonumber(a) or tonumber(b)
            if idxNum then
                local fetched = list:GetLine(idxNum)
                if IsValid(fetched) then
                    linePanel = fetched
                end
            end
        end

        if not IsValid(linePanel) then
            Derma_Message("Could not determine selected entry.", "Error", "OK")
            return
        end

        local idx = tonumber(linePanel:GetValue(1))
        if not idx or not CurrentEvals[idx] then
            Derma_Message("Selected entry not found.", "Error", "OK")
            return
        end

        OpenDetailWindow(CurrentEvals[idx], idx, CurrentAccess, MainFrame)
    end

    local actionW = math.floor((right:GetWide() - (panelPadding * 2) - actionGap) * 0.5)

    if CurrentAccess >= 2 then
        CreateThemedButton(right, panelPadding, bottomRowY, actionW, actionH, "Exit", function()
            if IsValid(MainFrame) then
                MainFrame:Close()
                MainFrame = nil
            end
        end)

        CreateThemedButton(right, panelPadding + actionW + actionGap, bottomRowY, actionW, actionH, "New Evaluation", function()
            include("vgui/cl_psych_entry.lua")
            PsychEval_ClientAccess = CurrentAccess
            PsychEval_ClientCanGrade = CurrentCanGrade
            OpenPsychEntry(nil, nil, function()
                RequestEvalPanelOpen()
            end)
            MainFrame:Close()
            MainFrame = nil
        end)
    end

end

-- Receive evals data (server -> client)
net.Receive("PsychEval_SendEvals", function()
    local access = net.ReadUInt(3) or 1
    local canGrade = net.ReadBool() or false
    local evals = net.ReadTable() or {}

    CurrentEvals = evals or CurrentEvals
    CurrentAccess = access or CurrentAccess
    CurrentCanGrade = canGrade or false

    if not PendingEvalOpen and not IsValid(MainFrame) then
        return
    end

    PendingEvalOpen = false
    BuildMainUI(evals, access, canGrade)
end)

-- Refresh broadcast (server sends updated data + access per recipient)
net.Receive("PsychEval_Refresh", function()
    local access = net.ReadUInt(3) or 1
    local evals = net.ReadTable() or {}

    CurrentEvals = evals or CurrentEvals
    CurrentAccess = access or CurrentAccess

    if not IsValid(MainFrame) then
        return
    end

    BuildMainUI(evals, access, CurrentCanGrade)
end)

-- Denied message (rate-limited)
net.Receive("PsychEval_Denied", function()
    local now = CurTime()
    if now - lastDeniedTime < 1.5 then return end
    lastDeniedTime = now
    chat.AddText(Color(200, 50, 50), "[Research Computer] ", Color(255,255,255), "You do not have access to this system.")
end)

