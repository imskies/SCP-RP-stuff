local PANEL = {}
function PANEL:Init()
    self:DockPadding(Nexus:GetMargin(), Nexus:GetMargin(), Nexus:GetMargin(), Nexus:GetMargin())

    self.Reward = self:Add("Nexus:Battlepass:Reward")
    self.Reward:Dock(LEFT)
    self.Reward:SetShowBackground(true)

    local rewardID = false
    self.RewardType = self:Add("Nexus:V2:ComboBox")
    self.RewardType:Dock(TOP)
    self.RewardType:DockMargin(Nexus:GetMargin(), 0, 0, 0)

    self.RewardValue = self:Add("Nexus:V2:TextEntry")
    self.RewardValue:Dock(TOP)
    self.RewardValue:DockMargin(Nexus:GetMargin(), Nexus:GetMargin(), 0, 0)
    self.RewardValue:SetPlaceholder(Nexus:GetPhrase("Reward", "nBattlepass"))
    self.RewardValue.OnChange = function(s)
        self.Reward:SetReward(rewardID, self.RewardValue:GetText())
    end

    self.Insert = self:Add("Nexus:V2:Button")
    self.Insert:Dock(TOP)
    self.Insert:DockMargin(Nexus:GetMargin(), Nexus:GetMargin(), 0, 0)
    self.Insert:SetText(Nexus:GetPhrase("Insert", "nexus_lib"))
    self.Insert.DoClick = function(s)
        if not rewardID then return end
        self:OnInsert(rewardID, self.RewardValue:GetText())
    end

    for id, v in pairs(Nexus.Battlepass.Rewards) do
        if not v.ShouldShow() then continue end
        if not self.Reward:GetReward() then
            rewardID = id
            self.Reward:SetReward(id)
            self.RewardType:SetText(v.Name)
        end

        self.RewardType:AddChoice(v.Name, function()
            rewardID = id
            self.Reward:SetReward(id)
        end)
    end
end

function PANEL:PerformLayout(w, h)
    self.Reward:SetWide(h - Nexus:GetMargin())
end
vgui.Register("Nexus:Battlepass:AddItem", PANEL, "EditablePanel")

local function GetPercentage(panels, ourWeight)
    local total = 0
    for _, panel in ipairs(panels) do
        if IsValid(panel) then
            total = total + (tonumber(panel:GetText()) or 0)
        end
    end

    if total == 0 then return 0 end
    return math.Round((ourWeight / total) * 100, 2)
end

hook.Add("Nexus:Config:LoadedContent", "Nexus:Battlepass:AddToConfig", function(addonName, menu, panel, search)
    if addonName ~= "Nexus Battlepass" then return end

    local addons = {
        {
            text = Nexus:GetPhrase("Free Tier Item Chances", "nBattlepass"),
            isPremium = false,
        },
        {
            text = Nexus:GetPhrase("Premium Tier Item Chances", "nBattlepass"),
            isPremium = true,
        },
    }

    local items = {}
    local premiumMenu, normalMenu
    for _, v in ipairs(addons) do
        local start, _ = string.find(string.lower(v.text), search)
        if not start then continue end

        menu:AddLabel(v.text)

        local itemTable = {}
        local panel = panel:Add("DPanel")
        panel:Dock(TOP)
        panel:DockMargin(0, 0, Nexus:GetMargin(), 0)
        panel:SetTall(Nexus:GetScale(200))
        panel.Paint = function(s, w, h)
            Nexus.RNDX.Draw(Nexus:GetMargin(), 0, 0, w, h, Nexus:GetColor("secondary"))
        end

        local scrollPanel = panel:Add("Nexus:V2:ScrollPanel")
        scrollPanel:Dock(FILL)
        local old = scrollPanel:GetCanvas().PerformLayout
        scrollPanel:GetCanvas().PerformLayout = function(s, w, h)
            old(s, w, h)

            local actualW = w - Nexus:GetMargin()*2
            local count = math.floor(actualW / Nexus:GetScale(110))
            local wide = (actualW - (Nexus:GetMargin() * (count-1)))/count
            local x, y = Nexus:GetMargin(), Nexus:GetMargin()
            for _, v in ipairs(s:GetChildren()) do
                v:SetSize(wide, wide)
                v:SetPos(x, y)
                x = x + wide + Nexus:GetMargin()
                if x + wide > w then
                    x = Nexus:GetMargin()
                    y = y + wide + Nexus:GetMargin()
                end
            end
        end
        
        if v.isPremium then
            premiumMenu = panel
        else
            normalMenu = panel
        end

        local addItem = scrollPanel:Add("Nexus:V2:Button")
        addItem:SetColor(Nexus:GetColor(v.isPremium and "primary" or "blue"))
        addItem:HideText()
        addItem:SetIcon("https://imgur.com/3Qo1D6B", function(h) return h*.25 end, color_black)
        addItem.DoClick = function(s)
            local screenCover = vgui.Create("DPanel")
            screenCover:SetSize(ScrW(), ScrH())
            screenCover:SetPos(0, 0)
            screenCover:MakePopup()
            screenCover.Paint = function(s, w, h)
                Nexus.RNDX.Draw(0, 0, 0, w, h, Nexus:GetColor("overlay"), Nexus.RNDX.BLUR)
                Nexus.RNDX.Draw(0, 0, 0, w, h, Nexus:GetColor("overlay"), Nexus.RNDX.BLUR)
            end
            screenCover.OnRemove = function()
                if IsValid(screenCover.Frame) then
                    screenCover.Frame:Remove()
                end
            end
            s.screenCover = screenCover

            screenCover.Frame = vgui.Create("Nexus:V2:Frame")
            screenCover.Frame:SetSize(Nexus:GetScale(350), Nexus:GetScale(200))
            screenCover.Frame:MakePopup()
            screenCover.Frame:Center()
            screenCover.Frame.Think = function(s)
                s:MoveToFront()
            end
            screenCover.Frame.OnRemove = function()
                if IsValid(screenCover) then
                    screenCover:Remove()
                end
            end

            screenCover.Frame.Panel = screenCover.Frame:Add("Nexus:Battlepass:AddItem")
            screenCover.Frame.Panel:Dock(FILL)
            screenCover.Frame.Panel.OnInsert = function(s, rewardID, rewardValue)
                screenCover:Remove()

                net.Start("Nexus:Battlepass:RewardChances:SaveReward")
                net.WriteBool(false)
                net.WriteString(rewardID)
                net.WriteString(rewardValue)
                net.WriteBool(v.isPremium)
                net.SendToServer()
            end
        end
        addItem.OnRemove = function(s)
            if IsValid(s.screenCover) then
                s.screenCover:Remove()
            end
        end

        panel.AddItem = function(s, item)
            local reward = scrollPanel:Add("Nexus:Battlepass:Reward")
            local cover = reward:SetReward(item.rewardID, item.rewardValue)
            reward:SetShowBackground(true)
            reward.id = item.id
            reward.DoClick = function(s)
                Nexus:DermaMenu({
                    Nexus:GetPhrase("Delete", "nBattlepass")
                }, function()
                    net.Start("Nexus:Battlepass:RewardChances:DeleteReward")
                    Nexus:WriteUInt(item.id)
                    net.SendToServer()
                end)
            end

            reward.Percentage = cover:Add("Nexus:V2:TextEntry")
            reward.Percentage:Dock(TOP)
            reward.Percentage:SetTall(Nexus:GetScale(30))
            reward.Percentage:DockMargin(Nexus:GetMargin("small"), Nexus:GetMargin("small"), Nexus:GetMargin("small"), 0)
            reward.Percentage:SetPlaceholder("%")
            reward.Percentage:SetText(item.weight)
            reward.Percentage:SetNumeric(true)
            reward.Percentage.PaintOver = function(s, w, h)
                surface.SetFont(s:GetFont())
                local tw, _ = surface.GetTextSize(s:GetText())

                draw.SimpleText("• "..GetPercentage(itemTable, tonumber(reward.Percentage:GetText()) or 0).."%", s:GetFont(), Nexus:GetMargin()*2 + tw, h/2, Nexus:GetColor("secondary-text"), 0, 1)
            end
            reward.Percentage.OnLoseFocus = function(s)
                net.Start("Nexus:Battlepass:RewardChances:SaveReward")
                net.WriteBool(true)
                Nexus:WriteUInt(item.id)
                net.WriteString(item.rewardID)
                net.WriteString(item.rewardValue)
                net.WriteBool(item.isPremium)
                net.WriteFloat(tonumber(reward.Percentage:GetText()) or 0)
                net.SendToServer()
            end

            table.insert(itemTable, reward.Percentage)
            table.insert(items, reward)
        end

        for _, item in ipairs(Nexus.Battlepass.RewardChances) do
            if v.isPremium ~= item.isPremium then continue end
            panel:AddItem(item)
        end

        menu:AddLabel("")
    end

    hook.Add("Nexus:Battlepass:RewardChances:DeleteReward", "Nexus:Battlepass:RewardChances:DeleteReward", function(id)
        if not IsValid(panel) then return end
        for _, v in ipairs(items) do
            if v.id and v.id == id then
                v:Remove()
            end
        end
    end)

    hook.Add("Nexus:Battlepass:RewardChances:AddReward", "Nexus:Battlepass:RewardChances:AddReward", function(data)
        if not IsValid(panel) then return end
        (data.isPremium and premiumMenu or normalMenu):AddItem(data)
    end)
end)