function Nexus.Battlepass:OpenMenu()
    if not IsValid(LocalPlayer()) then return end
    if IsValid(self.Frame) then self.Frame:Remove() end

    self.Frame = vgui.Create("Nexus:V2:Frame")
    self.Frame:SetSize(Nexus:GetScale(1000), Nexus:GetScale(500))
    self.Frame:MakePopup()
    self.Frame:Center()
    self.Frame:AddHeaderButton("https://imgur.com/bdvQ3aq", function()
        gui.OpenURL(Nexus:GetValue("nbp-storeURL"))
    end)

    self.Frame.Panel = self.Frame:Add("Nexus:Battlepass:Menu")
    self.Frame.Panel:Dock(FILL)
end

function Nexus.Battlepass:GetCurrentTier()
    if not Nexus.Battlepass.ThisSeason.curTier then return 0 end

    return Nexus.Battlepass.ThisSeason.curTier
end

function Nexus.Battlepass:HasPremium()
    if not Nexus.Battlepass.ThisSeason then return false end
    return Nexus.Battlepass.ThisSeason.hasPremium
end

function Nexus.Battlepass:HasClaimedTier(tier, isPremium)
    if not Nexus.Battlepass.ThisSeason then
        return false
    end

    return Nexus.Battlepass.ThisSeason.rewardsClaimed[(isPremium and "1" or "0")..tier]
end

function Nexus.Battlepass:GetTimeUntilNext()
    if not Nexus.Battlepass.ThisSeason then return end

    return math.max(0, (Nexus.Battlepass.ThisSeason.created_at + Nexus:GetValue("nbp-seasonDuration")) - os.time())
end

net.Receive("Nexus:Battlepass:DatabaseConnected", function()
    Nexus.Battlepass.RewardChances = {}
    Nexus.Battlepass.Battlepasses = {}
    Nexus.Battlepass.ThisSeason = {}
    LocalPlayer().NexusBattlepassSwitchTokens = 0
end)

net.Receive("Nexus:Battlepass:OpenMenu", function()
    Nexus.Battlepass:OpenMenu()
end)

concommand.Add("battlepass", function()
    Nexus.Battlepass:OpenMenu()
end)