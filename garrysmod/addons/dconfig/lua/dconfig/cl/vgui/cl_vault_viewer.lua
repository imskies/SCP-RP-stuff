

local PANEL = {}

function DCONFIG2.OpenVaultOption(data, dataID)
	if IsValid(DCONFIG2.VaultViewer) then
		DCONFIG2.VaultViewer:Remove()
	end
	DCONFIG2.VaultViewer = vgui.Create("DCONFIG2VaultViewer")
	DCONFIG2.VaultViewer:SetData(data, dataID)

end

local missingContent = false
local ignoreTbl = {}
function PANEL:Init()
	ignoreTbl = {}
	local scrw,scrh = ScrW(), ScrH()
	local xPadding = scrw * .14
	local yPadding = scrh * .01
	local theme = DCONFIG2.GetTheme()
	local scrw, scrh = DCONFIG2.ScrW, DCONFIG2.ScrH
	missingContent = false
	self.contentPanels = {}
	self:SetDraggable(false)
	self:MakePopup()
	local frameW, frameH, animTime, animDelay, animEase = scrw * .45, scrh * .85, 1, 0, .1
	self:SetSize(0, 0)
	self.isAnimating = true
	self:SizeTo(frameW, frameH, animTime, animDelay, animEase, function()
		self.isAnimating = false
	end)
	self:SetTitle("")
	self:ShowCloseButton(false)
	self.titlePanel = self:Add("DPanel")
	self.titlePanel:Dock(TOP)
	self.title = "BLANK TEMPLATE"
	self.titlePanel.Paint = function(me,w,h)
		local theme = DCONFIG2.GetTheme()
		draw.SimpleText(self.title, DCONFIG2.Font(36), w * .5, h * .2, theme.theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Templates require you to manually add workshop content to your server's collection or adddons folder.", DCONFIG2.Font(18), w * .5, h * .6, theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.scroll = self:Add("DCONFIG2ScrollBar")
	self.scroll:Dock(TOP)
	DCONFIG2.PaintScrollBar(self.scroll)

	self.closeButton = self:Add("DButton")
	self.closeButton:SetText("")
	self.closeButton:Dock(BOTTOM)
	self.closeButton:DockMargin(xPadding,0,xPadding,yPadding)
	local textColor
	self.closeButton.Paint = function(me,w,h)
		draw.RoundedBox(16,0,0,w,h,theme.theme)
		draw.RoundedBox(16,2,2,w-4,h-4,theme.body)
		local isHovered = me:IsHovered()
		if isHovered then
			draw.RoundedBox(14,2,2,w-4,h-4,theme.hoverHighlight)
			textColor = theme.navtexthover
		else
			textColor = theme.navtext
		end
		draw.SimpleText("Close", DCONFIG2.Font(22), w * .5, h * .5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.downloadButton = self:Add("DButton")
	self.downloadButton:SetText("")
	self.downloadButton:Dock(BOTTOM)
	self.downloadButton:DockMargin(xPadding,0,xPadding,yPadding)
	local textColor
	self.downloadButton.Paint = function(me,w,h)
		draw.RoundedBox(16,0,0,w,h,theme.theme)
		draw.RoundedBox(16,2,2,w-4,h-4,theme.body)
		local isHovered = me:IsHovered()
		if isHovered then
			draw.RoundedBox(14,2,2,w-4,h-4,theme.hoverHighlight)
			textColor = theme.navtexthover
		else
			textColor = theme.navtext
		end
		draw.SimpleText("Next", DCONFIG2.Font(22), w * .5, h * .5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.workshopContent = self:Add("DButton")
	self.workshopContent:SetText("")
	self.workshopContent:Dock(BOTTOM)
	self.workshopContent:DockMargin(xPadding,0,xPadding,yPadding)
	local textColor
	self.workshopContent.Paint = function(me,w,h)
		draw.RoundedBox(16,0,0,w,h,theme.theme)
		draw.RoundedBox(16,2,2,w-4,h-4,theme.body)
		local isHovered = me:IsHovered()
		if isHovered then
			draw.RoundedBox(14,2,2,w-4,h-4,theme.hoverHighlight)
			textColor = theme.navtexthover
		else
			textColor = theme.navtext
		end
		draw.SimpleText("Preview Workshop Content", DCONFIG2.Font(22), w * .5, h * .5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	self.closeButton.DoClick = function()
		DCONFIG2.PlaySound("click")
		self:Remove()
	end
	self.downloadButton.DoClick = function()
		DCONFIG2.PlaySound("click")
		if IsValid(DCONFIG2.DownloadMenu) then
			DCONFIG2.DownloadMenu:Remove()
		end
		DCONFIG2.DownloadMenu = vgui.Create("DCONFIG2VaultDownloader")
		DCONFIG2.DownloadMenu:SetData(self.data, self.dataID, ignoreTbl)
	end
	self.workshopContent.DoClick = function()
		DCONFIG2.PlaySound("click")
		if not self.data or not self.data.workshopid then return end

		local downloadNotice = vgui.Create("DCONFIG2DownloadNotice")
		downloadNotice:SetData(self.data, self.dataID)
		self:Remove()
	end
end


function PANEL:SetData(data, dataID)

	self.title = data.name
	self.data = data
	self.dataID = dataID
	ignoreTbl = {}
	self:PopulateContent(self.data.data)

end

function PANEL:PopulateContent(contentData)
	local scrw, scrh = DCONFIG2.ScrW, DCONFIG2.ScrH
	local xPadding = scrw * .01
	local yPadding = scrh * .01
	for category,categoryData in pairs(contentData) do
		for k,data in pairs(categoryData) do
			local contentPanel = self.scroll:Add("DCONFIG2VaultContentPanel")
			contentPanel:Dock(TOP)
			contentPanel:DockMargin(xPadding, yPadding, xPadding, 0)
			contentPanel:SetContent(category, k, data)
			self.contentPanels[contentPanel] = true			
		end
	end
	timer.Simple(0, function()
		if not missingContent and IsValid(self.workshopContent) then
			self.workshopContent:Remove()
		end
	end)
end

function PANEL:Paint(w,h)
	local theme = DCONFIG2.GetTheme()
	draw.RoundedBox(20, 0, 0, w, h, theme.theme)
	draw.RoundedBox(20, 2, 2, w - 4, h - 4, theme.body)
end

function PANEL:OnSizeChanged(w,h)
	local yPadding = ScrH() * .01
	if self.isAnimating then
		self:Center()
	end
	for panel,v in pairs(self.contentPanels) do
		panel:SetTall(h * .08)
	end
	if not IsValid(self.scroll) then return end

	self.titlePanel:SetTall(h * .1)
	self.scroll:SetTall(missingContent and h * .65 or h * .7 + yPadding * 2)
	self.downloadButton:SetTall(h * .05)
	self.closeButton:SetTall(h * .05)
	if not IsValid(self.workshopContent) then return end

	self.workshopContent:SetTall(h * .05)
end

derma.DefineControl("DCONFIG2VaultViewer", "DCONFIG2 Vault", PANEL, "DFrame")



local CONTENTPANEL = {}

function CONTENTPANEL:Init()

end


function CONTENTPANEL:SetContent(category, id, data, dataID)
	ignoreTbl[category] = ignoreTbl[category] or {} 
	local scrw,scrh = ScrW(),ScrH()
	local yPadding = scrh * .01
	local xPadding = scrw * .01
	local theme = DCONFIG2.GetTheme()
	self.title = data.name
	self.missingContent = false
	local model = type(data.model) == "string" and string.lower(data.model) or data.model and data.model[1]

	local modelPanel = vgui.Create("DModelPanel")
	modelPanel:SetModel(model)
	local mats = modelPanel.Entity:GetMaterials()
	modelPanel:Remove()

	if not DCONFIG2.HasMaterialError(mats) then
		self.icon = self:Add("SpawnIcon")
		self.icon:SetModel(model)
		self.icon:SetColor(color_white)
	else
		missingContent = true
		self.missingContent = true
		self.icon = self:Add("DButton")
		self.icon:SetText("")
		self.icon.Paint = function(me,w,h)
			surface.SetMaterial(DCONFIG2.VaultMaterials[category])
			surface.SetDrawColor(color_white)
			local iconSize = h * .5
			surface.DrawTexturedRect(w * .5 - iconSize * .5,h * .5 - iconSize * .5,iconSize,iconSize)
		end
	end
	self.icon:DockMargin(xPadding, yPadding, 0, yPadding)
	self.icon:Dock(LEFT)

	self.subPanel = self:Add("DPanel")
	self.subPanel:Dock(LEFT)
	self.subPanel:DockMargin(xPadding, 0, 0, 0)
	self.subPanel.Paint = nil
	
	self.mainLabelPanel = self.subPanel:Add("DPanel")
	self.mainLabelPanel:Dock(TOP)
	self.mainLabelPanel:DockMargin(0, yPadding, 0, 0)
	self.mainLabelPanel.Paint = nil

	self.titleLabel = self.mainLabelPanel:Add("DLabel")
	self.titleLabel:SetText(self.title)
	self.titleLabel:SetFont(DCONFIG2.Font(22))
	self.titleLabel:SetContentAlignment(4)
	self.titleLabel:SetTextColor(data.color or theme.titletext)
	self.titleLabel:Dock(LEFT)
	self.titleLabel:DockMargin(0, 0, 0, 0)

	if data.description or data.price then
		local desc = data.description or DarkRP.formatMoney(data.price)
		if string.find(desc, "\n") then
			desc = string.Split(desc, "\n")[1]
		end
		self.descLabel = self.subPanel:Add("DLabel")
		self.descLabel:SetText(desc)
		self.descLabel:SetFont(DCONFIG2.Font(16))
		self.descLabel:SetContentAlignment(7)
		self.descLabel:SetTextColor(theme.subtitletext)
		self.descLabel:Dock(TOP)
		self.descLabel:DockMargin(0, 0, 0, yPadding)
	end

	if self.missingContent then
		self.contentLabel = self.mainLabelPanel:Add("DLabel")
		self.contentLabel:SetText(" - Missing Workshop Content")
		self.contentLabel:SetFont(DCONFIG2.Font(14))
		self.contentLabel:SetContentAlignment(4)
		self.contentLabel:SetTextColor(theme.red)
		self.contentLabel:Dock(LEFT)
		self.contentLabel:DockMargin(0, 0,0,0)
	end

	self.togglePanel = self:Add("DPanel")
	self.togglePanel:Dock(RIGHT)
	self.togglePanel:DockMargin(0, yPadding, scrw * .01, yPadding)
	self.togglePanel.Paint = function() end

	self.checkBox = self.togglePanel:Add("DCONFIG2Checkbox")
	self.checkBox:SetValue(true)
	self.checkBox:SetDisabledColor(theme.body)
	self.checkBox:ShowLabel(false)
	self.enabled = true

	self.checkBox.DoClick = function()
		self.enabled = not self.enabled
		self.checkBox:SetValue(self.enabled)
		ignoreTbl[category][id] = not self.enabled and true or nil
	end 
end

function CONTENTPANEL:OnSizeChanged(w,h)
	if IsValid(self.icon) then
		self.icon:SetWide(self.icon:GetTall())
	end
	if self.subPanel then
		self.subPanel:SetWide(w * .5)
	end 
	if self.mainLabelPanel then
		self.mainLabelPanel:SetTall(h * .3)
	end
	local titleLabelW
	if self.descLabel then
		self.descLabel:SetTall(h * .3)
	end
	if self.titleLabel then
		surface.SetFont(DCONFIG2.Font(22))
		titleLabelW = surface.GetTextSize(self.titleLabel:GetText())
		self.titleLabel:SetWide(titleLabelW)
	end
	if self.contentLabel and titleLabelW then
		self.contentLabel:SetWide(w - titleLabelW)
	end
	if self.togglePanel then
		self.togglePanel:SetWide(w * .06)
		if self.checkBox then
			local checkW, checkH = self.togglePanel:GetWide(), self.togglePanel:GetTall() * .4
			self.checkBox:SetSize(checkW, checkH)
			self.checkBox:SetPos(self.togglePanel:GetWide() * .5 - checkW * .5, self.togglePanel:GetTall() * .5 - checkH * .5)
		end
	end
end


function CONTENTPANEL:Paint(w,h)
	local theme = DCONFIG2.GetTheme()
	draw.RoundedBox(10, 0, 0, w, h, theme.panel)
end

derma.DefineControl("DCONFIG2VaultContentPanel", "DCONFIG2 Vault Content Panel", CONTENTPANEL, "DPanel")




local CONTENTPANEL = {}

function CONTENTPANEL:Init()
	local scrw,scrh = ScrW(), ScrH()
	local xPadding = scrw * .08
	local yPadding = scrh * .01
	local theme = DCONFIG2.GetTheme()
	local scrw, scrh = DCONFIG2.ScrW, DCONFIG2.ScrH
	missingContent = false
	self.contentPanels = {}
	self:SetDraggable(false)
	self:MakePopup()
	local frameW, frameH, animTime, animDelay, animEase = scrw * .4, scrh * .2, 1, 0, .1
	self:SetSize(0, 0)
	self.isAnimating = true
	self:SizeTo(frameW, frameH, animTime, animDelay, animEase, function()
		self.isAnimating = false
	end)
	self:SetTitle("")
	self:ShowCloseButton(false)

	self.closeButton = self:Add("DButton")
	self.closeButton:SetText("")
	self.closeButton:Dock(BOTTOM)
	self.closeButton:DockMargin(xPadding,0,xPadding,yPadding)
	local textColor
	self.closeButton.Paint = function(me,w,h)
		draw.RoundedBox(16,0,0,w,h,theme.theme)
		draw.RoundedBox(16,2,2,w-4,h-4,theme.body)
		local isHovered = me:IsHovered()
		if isHovered then
			draw.RoundedBox(14,2,2,w-4,h-4,theme.hoverHighlight)
			textColor = theme.navtexthover
		else
			textColor = theme.navtext
		end
		draw.SimpleText("Cancel Download", DCONFIG2.Font(22), w * .5, h * .5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	self.closeButton.DoClick = function()
		timer.Destroy("DConfig2_workshopDownload")
		self:Remove()
	end
end

function CONTENTPANEL:SetData(data, dataID)
	local downloadIDs = data.workshopid
	self.workshopIDs = downloadIDs
	timer.Create("DConfig2_workshopDownload", 6, 1, function()
		DCONFIG2.PreviewWorkshopContent(downloadIDs, function()
			if IsValid(self) then
				self:Remove()
			end
			timer.Simple(.5, function()
				DCONFIG2.OpenVaultOption(data, dataID)
				surface.PlaySound("garrysmod/content_downloaded.wav")
			end)
		end)
	end)
end


function CONTENTPANEL:OnSizeChanged(w,h)
	if self.isAnimating then
		self:Center()
	end
	if self.closeButton then
		self.closeButton:SetTall(h * .2)
	end
end


function CONTENTPANEL:Paint(w,h)
	local theme = DCONFIG2.GetTheme()
	draw.RoundedBox(10, 0, 0, w, h, theme.theme)
	draw.RoundedBox(16,2,2,w-4,h-4,theme.body)
	if not self.workshopIDs then return end

	draw.SimpleText("Preparing to Download Workshop Content", DCONFIG2.Font(22), w * .5, h * .2, theme.theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("Your game may freeze, however it will unfreeze after the download is complete.", DCONFIG2.Font(22), w * .5, h * .4, theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	if not timer.Exists("DConfig2_workshopDownload") then
		draw.SimpleText("Downloading...", DCONFIG2.Font(22), w * .5, h * .6, theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		return
	end
	draw.SimpleText("Download begins in: (" .. math.Round(timer.TimeLeft("DConfig2_workshopDownload")) .. "s)", DCONFIG2.Font(22), w * .5, h * .6, theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

end

derma.DefineControl("DCONFIG2DownloadNotice", "DCONFIG2 Download Notice", CONTENTPANEL, "DFrame")


