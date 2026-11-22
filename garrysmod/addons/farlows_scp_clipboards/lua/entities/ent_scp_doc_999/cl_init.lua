include("shared.lua")

--========================================================--
--   CUSTOM SCP FONTS
--========================================================--
surface.CreateFont("SCP_TitleFont", {
    font = "Trebuchet MS",
    size = 32,
    weight = 800
})

surface.CreateFont("SCP_HeaderFont", {
    font = "Trebuchet MS",
    size = 28,
    weight = 700
})

surface.CreateFont("SCP_BodyFont", {
    font = "Trebuchet MS",
    size = 22,
    weight = 500
})

surface.CreateFont("SCP_CloseButtonFont", {
    font = "Trebuchet MS",
    size = 32,
    weight = 900
})

print("[SCP DEBUG] CLIENT FILE LOADED for", ENT.ClassName or "UNKNOWN_ENTITY")

--========================================================--
--   3D2D HEADER DRAW
--========================================================--
function ENT:Draw()
    self:DrawModel()

    local ang = self:GetAngles()
    local pos = self:GetPos() + ang:Up() * 9.5

    ang:RotateAroundAxis(ang:Right(), -90)
    ang:RotateAroundAxis(ang:Up(), 90)

    cam.Start3D2D(pos, ang, 0.1)
        draw.SimpleText(self.SCP_ID or "UNKNOWN", "SCP_Header", 0, 0, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

--========================================================--
--   UI OPEN HANDLER (NO TYPEWRITER)
--========================================================--
net.Receive("SCP_OpenClipboard", function()
    local id = net.ReadString()
    local file = SCP_Files and SCP_Files[id]
    if not file then return end

    print("[SCP DEBUG] Opening UI for:", id)

    --========================--
    --   CUSTOM FRAME
    --========================--
    local frame = vgui.Create("DFrame")
    frame:SetSize(820, 950)
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame:SetTitle("")

    frame.Paint = function(self, w, h)
        surface.SetDrawColor(18, 18, 18)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(35, 35, 35)
        surface.DrawRect(0, 0, w, 90)

        draw.SimpleText(
            "SCP FOUNDATION — SECURE FILE TERMINAL",
            "SCP_TitleFont",
            30, 28,
            Color(230, 230, 230)
        )
    end

    -- Close button
    local close = vgui.Create("DButton", frame)
    close:SetText("✕")
    close:SetFont("SCP_CloseButtonFont")
    close:SetSize(55, 55)
    close:SetPos(frame:GetWide() - 70, 18)
    close:SetTextColor(Color(200, 200, 200))
    close.Paint = function() end
    close.DoClick = function() frame:Close() end

    --========================--
    --   SCROLL PANEL
    --========================--
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(35, 100, 35, 35)

    -- Section Header Helper
    local function AddHeader(text)
        local lbl = vgui.Create("DLabel", scroll)
        lbl:SetFont("SCP_HeaderFont")
        lbl:SetText(text)
        lbl:SetTextColor(Color(255, 255, 255))
        lbl:SetWrap(true)
        lbl:SetAutoStretchVertical(true)
        lbl:Dock(TOP)
        lbl:DockMargin(0, 30, 0, 10)
    end

    -- Body Text Helper
    local function AddBody(text)
        local lbl = vgui.Create("DLabel", scroll)
        lbl:SetFont("SCP_BodyFont")
        lbl:SetText(text)
        lbl:SetTextColor(Color(210, 210, 210))
        lbl:SetWrap(true)
        lbl:SetAutoStretchVertical(true)
        lbl:Dock(TOP)
        lbl:DockMargin(0, 0, 0, 14)
    end

    --========================--
    --   CONTENT (INSTANT TEXT)
    --========================--

    AddHeader(file.title or id)

    AddHeader("Object Class")
    AddBody(file.class or "Unknown")

    AddHeader("Designation")
    AddBody(file.designation or id)

    AddHeader("Description")
    AddBody(file.description or "No description available.")

    AddHeader("Special Containment Procedures")
    AddBody(file.procedures or "No procedures available.")
end)