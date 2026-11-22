local PANEL = {}
function PANEL:Init()
    self.Tiers = {}

    local chipTall = Nexus:GetScale(35)
    local totalTiers = Nexus.Battlepass:GetSeasonsMaxTier(Nexus.Battlepass.ThisSeason)

    self.HorizontalScroller = self:Add("Nexus:V2:HorizontalScrollPanel")
    self.HorizontalScroller:Dock(FILL)
    local old = self.HorizontalScroller:GetCanvas().PerformLayout
    self.HorizontalScroller:GetCanvas().PerformLayout = function(s, w, h)
        old(s, w, h)

        local barVisible = self.HorizontalScroller:GetVBar():GetTall() > 0

        local actualH = (h - (barVisible and Nexus:GetMargin() or 0))
        local slotTall = (actualH - chipTall - Nexus:GetMargin()*2)/2

        self.HorizontalScroller.LeftPanel:SetPos(0, 0)
        self.HorizontalScroller.LeftPanel:SetSize(Nexus:GetScale(15), actualH)

        local x, y = self.HorizontalScroller.LeftPanel:GetWide() + Nexus:GetMargin(), 0
        for _, v in ipairs(self.Tiers) do
            v.chip:SetSize(slotTall/1, chipTall)
            v.freeTier:SetSize(slotTall/1, slotTall)
            v.premiumTier:SetSize(slotTall/1, slotTall)

            v.chip:SetPos(x, y)
            v.freeTier:SetPos(x, y + chipTall + Nexus:GetMargin())
            v.premiumTier:SetPos(x, v.freeTier:GetY() + slotTall + Nexus:GetMargin())

            x = x + slotTall/1 + Nexus:GetMargin()
        end
    end

    self.HorizontalScroller.LeftPanel = self.HorizontalScroller:Add("DPanel")
    self.HorizontalScroller.LeftPanel.Paint = function(s, w, h)
        local actualH = (h - (barVisible and Nexus:GetMargin() or 0))
        local slotTall = (actualH - chipTall - Nexus:GetMargin()*2)/2
        Nexus.RNDX.Draw(Nexus:GetMargin(), 0, chipTall + Nexus:GetMargin(), w, slotTall, Nexus:GetColor("blue"))
        Nexus.RNDX.Draw(Nexus:GetMargin(), 0, chipTall + Nexus:GetMargin()*2 + slotTall, w, slotTall, Nexus:GetColor("primary"))
    end

    for i = 1, totalTiers do
        local tier = i

        local chip = self.HorizontalScroller:Add("DPanel")
        chip.Paint = function(s, w, h)
            local col = tier<=(Nexus.Battlepass:GetCurrentTier()+1) and Nexus:GetColor("blue") or Nexus:GetColor("secondary")
            Nexus.RNDX.Draw(Nexus:GetMargin(), 0, 0, w, h, col)
            draw.SimpleText(tier, Nexus:GetFont({size = 15, bold = true}), Nexus:GetMargin("large"), h/2, Nexus:GetTextColor(col), 0, 1)
        end

        local freeTier = self.HorizontalScroller:Add("Nexus:Battlepass:Slot")
        freeTier:LoadSlot(false, tier)
        freeTier.DoClick = function(s, data)
            data.tier = tier
            self:DoClick(data)
        end

        local premiumTier = self.HorizontalScroller:Add("Nexus:Battlepass:Slot")
        premiumTier:LoadSlot(true, tier)
        premiumTier.DoClick = function(s, data)
            data.tier = tier
            self:DoClick(data)
        end

        table.Add(self.Tiers, {{
            tier = tier,
            chip = chip,
            freeTier = freeTier,
            premiumTier = premiumTier,
        }})
    end
end

function PANEL:DoClick(data)

end
vgui.Register("Nexus:Battlepass:TierList", PANEL, "EditablePanel")