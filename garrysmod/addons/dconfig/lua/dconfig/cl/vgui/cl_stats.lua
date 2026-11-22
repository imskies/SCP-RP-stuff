
net.Receive("dconfig2_increaseStat", function()
    local stat = net.ReadString()
    local header = net.ReadString()
    local value = net.ReadUInt(32)
    DCONFIG2.Stats.Data[stat][header] = value
end)

function DCONFIG2.OpenStats()
	if not DCONFIG2.IsBodyAvailable() then return end

	local body = DCONFIG2.GetBody()
	if not body then return end

	local stats = body:Add("DCONFIG2Stats")
	stats:Dock(FILL)

end

local PANEL = {}

local sortedOrder = {
    "jobs",
    "shipments",
    "weapons",
    "entities",
    "ammo",
}
function PANEL:Init()

	local scrw,scrh = ScrW(), ScrH()
	local xPadding = scrw * .01
	local yPadding = scrh * .01
	local theme = DCONFIG2.GetTheme()
	self.titlePanel = self:Add("DPanel")
	self.titlePanel:Dock(TOP)
	self.titlePanel.Paint = function(me,w,h)
		local theme = DCONFIG2.GetTheme()
		draw.SimpleText("DarkRP Stats", DCONFIG2.Font(36), w * .5, h * .3, theme.titletext, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Here you can gain some insight on how your Jobs, Shipments, Ammo and Entities are performing.", DCONFIG2.Font(22), w * .5, h * .6, theme.subtitletext, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.scroll = self:Add("DCONFIG2ScrollBar")
	self.scroll:Dock(FILL)
	DCONFIG2.PaintScrollBar(self.scroll)

    self:CreateStatBar()
    
	self.options = {}
	for _, stat in ipairs(sortedOrder) do
        local statData = DCONFIG2.Stats.Data[stat]
        if not statData then continue end 
		local optionPanel = self.scroll:Add("DCONFIG2StatPanel")
		optionPanel:Dock(TOP)
		optionPanel:SetStat(stat, statData)
		optionPanel:DockMargin(xPadding, yPadding, xPadding, 0)
		table.insert(self.options, optionPanel)
	end
end

local statInfo = {
    {
        stat = "Popular Job", 
        getTitle = function()
            local sortedData = table.SortByKey( DCONFIG2.Stats.Data.jobs )
            local jobVar = sortedData[1]
            return jobVar
        end,
        getSubTitle = function(title)
            local mins = DCONFIG2.Stats.Data.jobs[title]
            if not mins then return "No Data." end 
            local hours = math.Round(mins / 60, 2)
            return hours .. " Hours Played"
        end,
    },
    {
        stat = "Popular Shipment", 
        getTitle = function()
            local sortedData = table.SortByKey( DCONFIG2.Stats.Data.shipments )
            local title = sortedData[1]
            return title
        end,
        getSubTitle = function(title)
            local purchases = DCONFIG2.Stats.Data.shipments[title]
            if not purchases then return "No Data." end
            return purchases .. " Purchases"
        end,
    },
    {
        stat = "Popular Weapon", 
        getTitle = function()
            local sortedData = table.SortByKey( DCONFIG2.Stats.Data.weapons )
            local title = sortedData[1]
            return title
        end,
        getSubTitle = function(title)
            local purchases = DCONFIG2.Stats.Data.weapons[title]
            if not purchases then return "No Data." end
            return purchases .. " Purchases"
        end,
    },
    {
        stat = "Popular Entity", 
        getTitle = function()
            local sortedData = table.SortByKey( DCONFIG2.Stats.Data.entities )
            local title = sortedData[1]
            return title
        end,
        getSubTitle = function(title)
            local purchases = DCONFIG2.Stats.Data.entities[title]
            if not purchases then return "No Data." end
            return purchases .. " Purchases"
        end,
    },
    {
        stat = "Popular Ammo", 
        getTitle = function()
            local sortedData = table.SortByKey( DCONFIG2.Stats.Data.ammo )
            local title = sortedData[1]
            return title
        end,
        getSubTitle = function(title)
            local purchases = DCONFIG2.Stats.Data.ammo[title]
            if not purchases then return "No Data." end
            return purchases .. " Purchases"
        end,
    },
}

function PANEL:CreateStatBar()
	local scrw,scrh = ScrW(), ScrH()
	local xPadding = scrw * .01
	local yPadding = scrh * .01
    local theme = DCONFIG2.GetTheme()
    self.statBar = self.scroll:Add("DPanel")
    self.statBar:Dock(TOP)
    self.statBar:DockMargin(xPadding, 0, xPadding, yPadding)
    self.statBar.Paint = function(me,w,h)
        draw.RoundedBox(20, 0, 0, w, h, theme.panel)
    end 
    self.statBar.Panels = {}
    local contentContainer = self.statBar:Add("DPanel")
    contentContainer:Dock(FILL)
    contentContainer:DockMargin(xPadding, yPadding, xPadding, yPadding)
    contentContainer.Paint = nil
    for k, v in ipairs(statInfo) do
        local statPanel = contentContainer:Add("DPanel")
        statPanel:Dock(LEFT)
        statPanel:DockMargin(xPadding, 0, 0, 0)
        statPanel.Paint = nil

        statPanel.stat = statPanel:Add("DLabel")
        statPanel.stat:Dock(TOP)
        statPanel.stat:SetText(v.stat)
        statPanel.stat:SetContentAlignment(5)
        statPanel.stat:SetFont(DCONFIG2.Font(24))
        statPanel.stat:SetTextColor(theme.theme)
        statPanel.stat.Paint = function(me,w,h)
            surface.SetDrawColor(theme.theme)
            surface.DrawRect(0, h - 1, w, 1)
        end
        
        local title = v.getTitle() or "No Data."
        local subTitle = v.getSubTitle(title) or "No Data."
        statPanel.title = statPanel:Add("DLabel")
        statPanel.title:Dock(FILL)
        statPanel.title:SetText(title)
        statPanel.title:SetContentAlignment(5)
        statPanel.title:SetFont(DCONFIG2.Font(22))
        statPanel.title:SetTextColor(theme.titletext)
        statPanel.title:DockMargin(0, 0, 0, 0)
        
        statPanel.subTitle = statPanel:Add("DLabel")
        statPanel.subTitle:Dock(BOTTOM)
        statPanel.subTitle:SetText(subTitle)
        statPanel.subTitle:SetContentAlignment(5)
        statPanel.subTitle:SetFont(DCONFIG2.Font(20))
        statPanel.subTitle:SetTextColor(theme.subtitletext)
        --statPanel.subTitle:DockMargin(0, 0, 0, 0)

        table.insert(self.statBar.Panels, statPanel)
    end 
end

function PANEL:OnSizeChanged(w,h)
	self.titlePanel:SetTall(h * .1)
    local statBarH = h * .15
    self.statBar:SetTall(statBarH)
    if self.statBar.Panels then
        local xPadding = ScrW() * .02
        for k,v in pairs(self.statBar.Panels) do
            v:SetWide( (w / #statInfo + 1) - xPadding * 1)
            local labelH = statBarH * .2
            v.stat:SetTall(labelH)
            v.title:SetTall(labelH)
            v.subTitle:SetTall(labelH)
        end 
    end 
	for k,v in ipairs(self.options) do
		v:SetTall(h * .3)
	end
end


function PANEL:Paint(w,h)

end

derma.DefineControl("DCONFIG2Stats", "DCONFIG2 Stats", PANEL, "DPanel")

local PANEL = {}

function PANEL:SetStat(stat, statData)
	local theme = DCONFIG2.GetTheme()
	local scrw,scrh = ScrW(), ScrH()
	self.stat = stat
	self.titleLabel = self:Add("DLabel")
	self.titleLabel:Dock(TOP)
	self.titleLabel:SetText(string.upper(stat))
	self.titleLabel:SetContentAlignment(5)
	self.titleLabel:SetFont(DCONFIG2.Font(26))
	self.titleLabel:SetTextColor(theme.titletext)
	local xPadding = scrw * .01
	local yPadding = scrh * .01
	self.titleLabel:DockMargin(0, 0, 0, 0)

	self.body = self:Add("DPanel")
	self.body:Dock(TOP)
	self.body.Paint = function(me,w,h)
        draw.RoundedBox(20, 0, 0, w, h, theme.panel)
        --draw.RoundedBox(20, 1, 1, w - 2, h - 2, theme.panel)
        surface.SetDrawColor(theme.theme)
        --surface.DrawRect(w * .5 - 2, h * .15, 1, h)
	end

    self.headerPanel = self.body:Add("DPanel")
    self.headerPanel:Dock(TOP)
    self.headerPanel.Paint = function(me,w,h)
        surface.SetDrawColor(theme.theme)
        surface.DrawRect(xPadding, h - 1, w - xPadding * 2, 1)
    end

    local title1 = DCONFIG2.Stats.DataLabels[stat][1]
    local title2 = DCONFIG2.Stats.DataLabels[stat][2]

    self.label1 = self.headerPanel:Add("DLabel")
    self.label1:Dock(LEFT)
    self.label1:SetText(title1)
    self.label1:SetContentAlignment(5)
    self.label1:SetFont(DCONFIG2.Font(24))
    self.label1:SetTextColor(theme.titletext)
    
    self.label2 = self.headerPanel:Add("DLabel")
    self.label2:Dock(LEFT)
    self.label2:SetText(title2)
    self.label2:SetContentAlignment(5)
    self.label2:SetFont(DCONFIG2.Font(24))
    self.label2:SetTextColor(theme.titletext)
    
    self.scroll = self.body:Add("DCONFIG2ScrollBar")
    self.scroll:Dock(FILL)
    DCONFIG2.PaintScrollBar(self.scroll)
    
    self.entries = {}
    local count = 1
    local sortOrder = table.SortByKey( statData )
    for k,v in ipairs(sortOrder) do
        local indentifier = v
        local statValue = statData[indentifier]
        if stat == "jobs" then
            statValue = math.Round(statValue / 60,2)
        end 
        local backgroundColor = theme.body
        if count % 2 == 0 then
            backgroundColor = theme.panel
        end 
        local entry = self.scroll:Add("DPanel")
        entry:Dock(TOP)
        entry.Paint = function(me,w,h)
            surface.SetDrawColor(backgroundColor)
            surface.DrawRect(xPadding,0,w - xPadding * 2,h)
        end
        count = count + 1
        entry.leftContainer = entry:Add("DPanel")
        entry.leftContainer:Dock(LEFT)
        entry.leftContainer.Paint = nil
        
        entry.rightContainer = entry:Add("DPanel")
        entry.rightContainer:Dock(LEFT)
        entry.rightContainer.Paint = nil

        entry.label1 = entry.leftContainer:Add("DLabel")
        entry.label1:Dock(FILL)
        entry.label1:SetText(indentifier)
        entry.label1:SetContentAlignment(5)
        entry.label1:SetFont(DCONFIG2.Font(18))
        entry.label1:SetTextColor(theme.subtitletext)
        entry.label1:DockMargin(0, 0, 0, 0)
        
        entry.label2 = entry.rightContainer:Add("DLabel")
        entry.label2:Dock(FILL)
        entry.label2:SetText(statValue)
        entry.label2:SetContentAlignment(5)
        entry.label2:SetFont(DCONFIG2.Font(18))
        entry.label2:SetTextColor(theme.subtitletext)
        entry.label2:DockMargin(0, 0, 0, 0)
        table.insert(self.entries, entry)
    end 

end

function PANEL:Paint(w,h)

end

function PANEL:OnSizeChanged(w,h)
	self.titleLabel:SetTall(h * .1)
    local bodyH = h * .85
	self.body:SetTall(h * .85)
    self.headerPanel:SetTall(bodyH * .15)
    if self.entries then
        for k,v in ipairs(self.entries) do
            v:SetTall(h * .12)
            v.leftContainer:SetWide(w * .5)
            v.rightContainer:SetWide(w * .5)
        end 
    end 
    self.label1:SetWide(w * .5)
    self.label2:SetWide(w * .5)
end

derma.DefineControl("DCONFIG2StatPanel", "DCONFIG2 Stat Panel", PANEL, "DPanel")