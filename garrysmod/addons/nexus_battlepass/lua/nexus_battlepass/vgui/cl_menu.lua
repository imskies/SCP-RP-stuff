local PANEL = {}
function PANEL:Init()
    self:DockPadding(Nexus:GetMargin(), Nexus:GetMargin(), Nexus:GetMargin(), Nexus:GetMargin())
    self.Navbar = self:Add("Nexus:V2:Navbar")
    self.Navbar:Dock(TOP)
    self.Navbar.OnChange = function(s, panel, panelStr)
        if panelStr == "Nexus:Config:MenuV2" then
            panel:SetCategory("Nexus Battlepass")
        end
    end
    self.Navbar.PaintOver = function(s, w, h)
        draw.SimpleText(Nexus:GetPhrase("Next Battlepass In", "nBattlepass")..":", Nexus:GetFont({size = 15}), w - Nexus:GetMargin(), h/2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(string.NiceTime(Nexus.Battlepass:GetTimeUntilNext()), Nexus:GetFont({size = 15}), w - Nexus:GetMargin(), h/2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    end

    self.Body = self:Add("Panel")
    self.Body:Dock(FILL)
    self.Body:DockMargin(0, Nexus:GetMargin(), 0, 0)

    self.Navbar:SetBody(self.Body)
    self.Navbar:AddItem(Nexus:GetPhrase("Battlepass", "nBattlepass"), "Nexus:Battlepass:Battlepass")
    self.Navbar:AddItem(Nexus:GetPhrase("Challenges", "nBattlepass"), "Nexus:Battlepass:Challenges")
    if Nexus.Battlepass:IsSuperadmin(LocalPlayer()) then
        self.Navbar:AddItem(Nexus:GetPhrase("Admin", "nBattlepass"), "Nexus:Config:MenuV2")
    end
end
vgui.Register("Nexus:Battlepass:Menu", PANEL, "EditablePanel")