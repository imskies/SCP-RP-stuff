local color_zero = Color(0, 0, 0, 0)
local PANEL = {}
function PANEL:Init()
end

function PANEL:SetReward(id, value)
    self:Clear()
    self.RewardID = id

    self.Overlay = self:Add("Nexus:V2:Button")
    self.Overlay:Dock(FILL)
    self.Overlay:SetText("")
    self.Overlay:SetColor(color_zero)

    print(id)
    if not Nexus.Battlepass.Rewards[id] then return end
    Nexus.Battlepass.Rewards[id].Display(self, value)

    self.Overlay = self:Add("Nexus:V2:Button")
    self.Overlay:Dock(FILL)
    self.Overlay:SetText("")
    self.Overlay:SetColor(color_zero)
    local old = self.Overlay.DoClick
    self.Overlay.DoClick = function(s)
        old(s)
        self:DoClick({rewardID = id, rewardValue = value})
    end

    return self.Overlay
end

function PANEL:DoClick()
end

function PANEL:GetReward()
    return self.RewardID
end

function PANEL:SetShowBackground(bool)
    self.ShouldDrawBackground = bool
end

function PANEL:SetColor(col)
    self.bgCol = col
end

function PANEL:Paint(w, h)
    if self.ShouldDrawBackground then
        Nexus.RNDX.Draw(Nexus:GetMargin(), 0, 0, w, h, self.bgCol or Nexus:GetColor("background"))
    end
end
vgui.Register("Nexus:Battlepass:Reward", PANEL, "EditablePanel")