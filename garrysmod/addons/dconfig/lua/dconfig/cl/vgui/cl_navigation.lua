
local PANEL = {}

DCONFIG2.Tabs = {
  
	/*
  Coming soon. Will eventually complete this.
  {
		title = "Hidden Feature",
		icon = Material("dconfig/bank.png"),
		callback = function()
			DCONFIG2.OpenVault()
		end,
	},
	{
		title = "Vault Admin",
		icon = Material("dconfig/bank.png"),
		shouldShow = function()
			return DCONFIG2.IsDan()
		end,
		callback = function()
			DCONFIG2.OpenEditor("vault")
		end,
	},*/
	{
		title = "Jobs",
		icon = Material("dconfig/job.png"),
		callback = function()
			DCONFIG2.OpenEditor("jobs")
		end,
	},
	{
		title = "Shipments",
		icon = Material("dconfig/shipment.png"),
		callback = function()
			DCONFIG2.OpenEditor("shipments")
		end,
	},
	{
		title = "Entities",
		icon = Material("dconfig/entity.png"),
		callback = function()
			DCONFIG2.OpenEditor("entities")
		end,
	},
	{
		title = "Ammo",
		icon = Material("dconfig/ammo.png", "smooth"),
		callback = function()
			DCONFIG2.OpenEditor("ammo")
		end,
	},
	{
		title = "Categories",
		icon = Material("dconfig/category.png"),
		callback = function()
			DCONFIG2.OpenEditor("categories")
		end,
	},
	{
		title = "Door Groups",
		icon = Material("dconfig/door.png"),
		callback = function()
			DCONFIG2.OpenEditor("doorgroups")
		end,
	},
	{
		title = "DarkRP Settings",
		icon = Material("dconfig/settings.png"),
		callback = function()
			DCONFIG2.OpenEditor("settings")
		end,
	},
	{
        title = "DConfig Settings",
		icon = Material("dconfig/wrench.png"),
		callback = function()
			DCONFIG2.OpenEditor("dconfig")
		end,
	},
    {
        title = "Statistics",
        icon = Material("dconfig/stats.png"),
        callback = function()
            DCONFIG2.OpenStats()
        end,
    },
	{
		title = "Data",
		icon = Material("dconfig/data.png"),
		callback = function()
			DCONFIG2.OpenData()
		end,
	},
	{
		title = "Credits",
		icon = Material("dconfig/credits.png"),
		callback = function()
            DCONFIG2.OpenCredits()
		end,
	},
	{
		title = "Close",
		icon = Material("dconfig/close.png"),
		callback = function()
			DCONFIG2.Close()
		end,
	},
}

local gradientMat = Material("csidarkrp/gradient6.png")
local danMat = Material("dconfig/dan.png")
function PANEL:Init()
	local ply = LocalPlayer()
	self.scroll = self:Add("DCONFIG2ScrollBar")
	self.scroll:Dock(FILL)

	self.playerPanel = self.scroll:Add("DPanel")
	self.playerPanel:Dock(TOP)
	local theme = DCONFIG2.GetTheme()
	self.playerPanel.Paint = function(me,w,h)
		surface.SetDrawColor(255,0,0,0)
		surface.DrawRect(0,0,w,h)

		--if DCONFIG2.ScreenPanel.isAnimating then return end
		surface.SetDrawColor(color_white)
		local iconSize = h * .3
		surface.SetMaterial(danMat)
		surface.SetFont(DCONFIG2.Font(36))
		local textW = surface.GetTextSize("DCONFIG 2")
		local spaceW = surface.GetTextSize("  ")
		draw.SimpleText("  DCONFIG 2", DCONFIG2.Font(36), w * .5 - iconSize, h * .3, theme.dconfigTitle or theme.titletext, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		surface.DrawTexturedRect(w * .5 - iconSize + textW * .5 + spaceW, h * .3 - iconSize * .5, iconSize, iconSize)
		draw.SimpleText("Developed by DanFMN", DCONFIG2.Font(24), w * .5, h * .6, theme.theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	self.tabs = {}
	self:GetParent().page = self:GetParent().page or 1
	for k, tabData in ipairs(DCONFIG2.Tabs) do
		if tabData.shouldShow and not tabData.shouldShow() then continue end

		local tab = self.scroll:Add("DButton")
		tab:Dock(TOP)
		tab:SetText("")
		local textColor = theme.navtext
		tab.Paint = function(me,w,h)
			local iconSize = h * .35
			local xPadding = w * .1
			local isHovered = me:IsHovered()
			if isHovered then
				surface.SetDrawColor(theme.hoverHighlight)
				surface.DrawRect(0,0,w,h)
				textColor = theme.navtexthover
			else
				textColor = theme.navtext
			end
			if me.fade and me.fade > 0 then
				me.fade = me.fade - 2 * FrameTime()
				surface.SetAlphaMultiplier(me.fade)
				surface.SetDrawColor(theme.body)
				surface.DrawRect(0,0,w,h)
				surface.SetAlphaMultiplier(1)
			end
			surface.SetDrawColor(textColor)
			if self:GetParent().page == k then
				surface.SetDrawColor(theme.selectedNav or theme.body)
				surface.DrawRect(0,0,w,h)
				surface.SetDrawColor(theme.selectedNavIcon or theme.theme)
				textColor = theme.selectedNavText or theme.theme
			end
			surface.SetMaterial(tabData.icon)
			surface.DrawTexturedRect(xPadding, h * .5 - iconSize * .5, iconSize, iconSize)
			draw.SimpleText(string.upper(tabData.title), DCONFIG2.Font(18), xPadding * 2 + iconSize, h * .5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
		tab.DoClick = function()
			if self:GetParent().page == k then return end

			self.tabs[self:GetParent().page].fade = 1
			DCONFIG2.ClearBody()
			tabData.callback()
			if tabData.title != "Close" then
				DCONFIG2.PlaySound("click")
			end
			self:GetParent().page = k
		end
		table.insert(self.tabs, tab)
	end
	timer.Simple(.5, function()
		DCONFIG2.Tabs[self:GetParent().page].callback()
	end)

end

function PANEL:OnMouseWheeled( scrollDelta )
	local curPage = self:GetParent().page
	local nextPage = curPage - scrollDelta
	if not DCONFIG2.Tabs[nextPage] or nextPage == table.Count(DCONFIG2.Tabs) then return end
	self.tabs[curPage].fade = 1
	self:GetParent().page = nextPage
	DCONFIG2.PlaySound("click")
	timer.Create("updatePage", .15, 1, function()
		DCONFIG2.ClearBody()
		DCONFIG2.Tabs[nextPage].callback()
	end)
end

function PANEL:OnSizeChanged(w,h)
	if not IsValid(self.playerPanel) then return end
	self.playerPanel:SetTall(h * .1)

	for k,tab in ipairs(self.tabs) do
		tab:SetTall(h * .06)
	end
end

function PANEL:Paint(w,h)
	DCONFIG2.BlurMenu( self, 16, 16, 255 )
	local theme = DCONFIG2.GetTheme()
	draw.RoundedBoxEx(20,0,0,w,h, theme.blur or theme.navigation,true,false,true,false)

end

derma.DefineControl("DCONFIG2Navigation", "DCONFIG2 Navigation", PANEL, "DPanel")

