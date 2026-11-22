local color_zero = Color(0, 0, 0, 0)
local PANEL = {}
function PANEL:Init()
    self.SelectedDATA = {}

    self.TierInformation = self:Add("DPanel")
    self.TierInformation:Dock(RIGHT)
    self.TierInformation:SetWide(Nexus:GetScale(220))
    self.TierInformation.Paint = function(s, w, h)
        Nexus.RNDX.Draw(Nexus:GetMargin(), 0, 0, w, h, Nexus:GetColor("secondary"))
    end
    self.TierInformation.PerformLayout = function(s, w, h)
        self.TierInformation.ChangeBattlepass:SetPos(Nexus:GetMargin(), Nexus:GetMargin())
        self.TierInformation.ChangeBattlepass:SetWide(w - Nexus:GetMargin()*2)
        self.TierInformation.Spacer:SetSize(w, Nexus:GetScale(100))
        self.TierInformation.Reward:SetTall(w - Nexus:GetMargin()*2)
    end

    self.TierInformation.Spacer = self.TierInformation:Add("DPanel")
    self.TierInformation.Spacer:Dock(TOP)
    self.TierInformation.Spacer:DockMargin(0, Nexus:GetMargin(), 0, 0)
    self.TierInformation.Spacer.Paint = nil
    
    self.TierInformation.Reward = self.TierInformation:Add("Nexus:Battlepass:Reward")
    self.TierInformation.Reward:Dock(TOP)
    self.TierInformation.Reward:DockMargin(Nexus:GetMargin(), Nexus:GetMargin(), Nexus:GetMargin(), 0)
    self.TierInformation.Reward:SetShowBackground(true)

    local function loadReward()
        for teir, v in ipairs(Nexus.Battlepass.ThisSeason.freeTiers) do
            self.TierInformation.Reward:SetReward(v.rewardID, v.rewardValue)
            self.TierInformation.Reward:SetColor(Nexus:GetColor("blue"))
            self.SelectedDATA = {tier = tier, isPremium = false}
            return
        end

        for teir, v in ipairs(Nexus.Battlepass.ThisSeason.premiumTiers) do
            self.TierInformation.Reward:SetReward(v.rewardID, v.rewardValue)
            self.TierInformation.Reward:SetColor(Nexus:GetColor("primary"))
            self.SelectedDATA = {tier = tier, isPremium = true}
            return
        end
    end
    loadReward()

    local ratio = 343/1100
    self.TierInformation.ChangeBattlepass = self.TierInformation:Add("Nexus:V2:Button")
    self.TierInformation.ChangeBattlepass:DockPadding(0, Nexus:GetScale(100), 0, 0)
    self.TierInformation.ChangeBattlepass:SetTall(Nexus:GetScale(100))
    self.TierInformation.ChangeBattlepass:SetSecondary()
    self.TierInformation.ChangeBattlepass:HideText()
    self.TierInformation.ChangeBattlepass.IsOpen = false
    self.TierInformation.ChangeBattlepass.DoClick = function(s)
        s.IsOpen = not s.IsOpen
        self.TierInformation.ChangeBattlepass:SizeTo(-1, s.IsOpen and math.min(s.OldH + (Nexus:GetScale(25)*8), s.OldH + (#Nexus.Battlepass.Battlepasses)*Nexus:GetScale(25)) or s.OldH, 0.3, 0, -1, function() end)
        self.TierInformation.ChangeBattlepass:MoveToFront()
    end
    self.TierInformation.ChangeBattlepass.PaintOver = function(s, w, h)
        s.OldH = Nexus:GetScale(100)

        local font = Nexus:GetFont({size = 35})
        local tw, th = draw.SimpleText(Nexus.Battlepass.ThisSeason.name, font, w/2, s.OldH/2, Nexus:GetColor("green"), 1, 1)
    end

    self.TierInformation.ChangeBattlepass.Panel = self.TierInformation.ChangeBattlepass:Add("Nexus:V2:ScrollPanel")
    self.TierInformation.ChangeBattlepass.Panel:Dock(FILL)

    for _, v in ipairs(Nexus.Battlepass.Battlepasses) do
        local id = v.id
        local button = self.TierInformation.ChangeBattlepass.Panel:Add("Nexus:V2:Button")
        button:Dock(TOP)
        button:SetText(v.name)
        button:SetTall(Nexus:GetScale(25))
        button:SetColor(color_zero)
        if not Nexus.Battlepass:HasUnlockedBattlepass(id) then
            button:SetIcon("https://imgur.com/MXMOY6k")
        end
        button.DoClick = function()
            net.Start("Nexus:Battlepass:SwitchBP")
            Nexus:WriteUInt(v.id)
            net.SendToServer()
        end
    end

    self.TierInformation.AddButton = self.TierInformation:Add("Nexus:V2:Button")
    self.TierInformation.AddButton:Dock(TOP)
    self.TierInformation.AddButton:DockMargin(Nexus:GetMargin(), Nexus:GetMargin(), Nexus:GetMargin(), 0)
    self.TierInformation.AddButton:SetColor(Nexus:GetColor("green"))
    self.TierInformation.AddButton:SetText(Nexus:GetPhrase("Claim Tier", "nBattlepass"))
    self.TierInformation.AddButton.DoClick = function()
        net.Start("Nexus:Battlepass:ClaimTier")
        Nexus:WriteUInt(self.SelectedDATA.tier or 1)
        net.WriteBool(self.SelectedDATA.isPremium)
        net.SendToServer()
    end

    self.TierInformation.Title = self.TierInformation:Add("DLabel")
    self.TierInformation.Title:Dock(FILL)
    self.TierInformation.Title:DockMargin(Nexus:GetMargin(), 0, 0, 0)
    self.TierInformation.Title:SetFont(Nexus:GetFont({size = 15}))
    self.TierInformation.Title:SetText(Nexus:GetPhrase("Switch Tokens", "nBattlepass")..": "..Nexus.Battlepass:GetSwitchTokens())
    self.TierInformation.Title.Think = function()
        self.TierInformation.Title:SetText(Nexus:GetPhrase("Switch Tokens", "nBattlepass")..": "..Nexus.Battlepass:GetSwitchTokens())
    end

    self.BattlepassTiers = self:Add("Nexus:Battlepass:TierList")
    self.BattlepassTiers:Dock(FILL)
    self.BattlepassTiers:DockMargin(0, 0, Nexus:GetMargin(), 0)
    self.BattlepassTiers.DoClick = function(s, data)
        self.SelectedDATA = {tier = data.tier, isPremium = data.isPremium}
        self.TierInformation.Reward:SetReward(data.rewardID, data.rewardValue)
        self.TierInformation.Reward:SetColor(Nexus:GetColor(data.isPremium and "primary" or "blue"))
    end
end
vgui.Register("Nexus:Battlepass:Battlepass", PANEL, "EditablePanel")