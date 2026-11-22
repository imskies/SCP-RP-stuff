local PANEL = {}
function PANEL:Init()
    self.tier = -1
end

function PANEL:LoadSlot(isPremium, tier)
    self.isPremium = isPremium
    self.tier = tier

    self:Clear()

    local curDATA = Nexus.Battlepass.ThisSeason[isPremium and "premiumTiers" or "freeTiers"][tonumber(tier)]
    if not curDATA then return end

    self.Reward = self:Add("Nexus:Battlepass:Reward")
    self.Reward:Dock(FILL)
    self.Reward:SetReward(curDATA.rewardID, curDATA.rewardValue)
    self.Reward.DoClick = function(s, data)
        data.isPremium = isPremium
        self:DoClick(data)
    end
    self.Reward.Overlay.PaintOver = function(s, w, h)
        local size = Nexus:GetScale(24)
        if Nexus.Battlepass:HasClaimedTier(tier, isPremium) then return end

        if tier <= Nexus.Battlepass:GetCurrentTier() and (not isPremium or isPremium and Nexus.Battlepass:HasPremium()) then
            // unlock
            Nexus:DrawImgur("https://imgur.com/wEbYwyZ", w - size - Nexus:GetMargin(), Nexus:GetMargin(), size, size, Nexus:GetTextColor(self.tier<=(Nexus.Battlepass:GetCurrentTier()+1) and (self.isPremium and Nexus:GetColor("primary") or Nexus:GetColor("blue")) or Nexus:GetColor("secondary")))
        else
            Nexus:DrawImgur("https://imgur.com/IE7b4dv", w - size - Nexus:GetMargin(), Nexus:GetMargin(), size, size, Nexus:GetTextColor(self.tier<=(Nexus.Battlepass:GetCurrentTier()+1) and (self.isPremium and Nexus:GetColor("primary") or Nexus:GetColor("blue")) or Nexus:GetColor("secondary")))
        end
    end
end

function PANEL:DoClick(data)
    
end

function PANEL:Paint(w, h)
    Nexus.RNDX.Draw(Nexus:GetMargin(), 0, 0, w, h, self.tier<=(Nexus.Battlepass:GetCurrentTier()+1) and (self.isPremium and Nexus:GetColor("primary") or Nexus:GetColor("blue")) or Nexus:GetColor("secondary"))
end
vgui.Register("Nexus:Battlepass:Slot", PANEL, "EditablePanel")