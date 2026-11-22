
local PANEL = {}


function PANEL:Init()
	local scrw,scrh = ScrW(), ScrH()
	local xPadding = scrw * .14
	local yPadding = scrh * .01
	local theme = DCONFIG2.GetTheme()
	local scrw, scrh = DCONFIG2.ScrW, DCONFIG2.ScrH
	self.contentPanels = {}
	self:SetDraggable(false)
	self:MakePopup()
	local frameW, frameH= scrw * .45, scrh * .85
	self:SetSize(frameW, frameH)
	self:Center()
	self:SetTitle("")
	self:ShowCloseButton(false)
	self.titlePanel = self:Add("DPanel")
	self.titlePanel:Dock(TOP)
	self.title = "Download Confirmation"
	self.titlePanel.Paint = function(me,w,h)
		local theme = DCONFIG2.GetTheme()
		draw.SimpleText(self.title, DCONFIG2.Font(36), w * .5, h * .2, theme.theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Templates require you to manually add workshop content to your server's collection/addon's folders.", DCONFIG2.Font(18), w * .5, h * .6, theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
		draw.SimpleText("Back", DCONFIG2.Font(22), w * .5, h * .5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.downloadButton = self:Add("DButton")
	self.downloadButton:SetText("")
	self.downloadButton:Dock(BOTTOM)
	self.downloadButton:DockMargin(xPadding,yPadding,xPadding,yPadding)
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
		draw.SimpleText("Confirm Download", DCONFIG2.Font(22), w * .5, h * .5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.closeButton.DoClick = function()
		DCONFIG2.PlaySound("click")
		self:Remove()
	end
	self.downloadButton.DoClick = function()
		DCONFIG2.PlaySound("click")
		if not self.downloadData then return end

		// TODO: Finish implementation
		for category, content in pairs(self.downloadData) do
			local fileManager = DCONFIG2.Data.FileManager[category]
			if not fileManager.loadEntry then continue end

			for k,data in pairs(content) do 
				fileManager.loadEntry(data)
			end
		end
	// TODO: Complete Implementation
	/*
		net.Start("dconfig2_downloadVault")
		net.WriteTable(self.ignoreTbl)
		net.WriteString(self.data.category)
		net.WriteUInt(self.dataID, 8)
		net.SendToServer()
		*/
		DCONFIG2.ShowPopup("Sucessfully Downloaded Vault Data", "dconfig/bank.png")
	end

end


function PANEL:Paint(w,h)
	local theme = DCONFIG2.GetTheme()
	draw.RoundedBox(20, 0, 0, w, h, theme.theme)
	draw.RoundedBox(20, 2, 2, w - 4, h - 4, theme.body)
end

function PANEL:SetData(data, dataID, ignoreTbl)
	local scrw,scrh = ScrW(), ScrH()
	local theme = DCONFIG2.GetTheme()
	local xPadding = scrw * .03
	local yPadding = scrh * .01
	self.data = data
	self.dataID = dataID
	self.ignoreTbl = ignoreTbl
	self.downloadData = table.Copy(data.data)
	// TODO: Finish implementation
	for category,ignoredOptions in pairs(self.ignoreTbl) do
		for id, _ in pairs(ignoredOptions) do 
			self.downloadData[category][id] = nil
		end
	end

	self.downloadInfo = self.scroll:Add("DLabel")
	self.downloadInfo:Dock(TOP)
	self.downloadInfo:SetTextColor(theme.text)
	self.downloadInfo:SetFont(DCONFIG2.Font(22))
	self.downloadInfo:SetText([[
		Before you complete your download you have to add the workshop content to your server's collection.
		If you are not using a collection, you have to add the workshop content into your server's addon folders. After adding the addon to your collection, please restart your Server.
		Do not worry about using resource.AddWorkshop for the content. DConfig will handle that for you.
		]])
	self.downloadInfo:SetWrap(true)
	self.downloadInfo:SetContentAlignment(5)
	self.downloadInfo:DockMargin(xPadding, 0, xPadding, 0)
	self.downloadInfo:SetAutoStretchVertical(true)
	self.workshopButtons = {}
	// TODO: Finish implementation, table structure is not concrete.
	for k,v in pairs(self.data.workshopid) do
		local xPadding = scrw * .08
		local workshopButton = self.scroll:Add("DButton")
		workshopButton:SetText("")
		workshopButton:Dock(TOP)
		local textColor
		workshopButton.Paint = function(me,w,h)
			draw.RoundedBox(16,0,0,w,h,theme.theme)
			draw.RoundedBox(16,2,2,w-4,h-4,theme.body)
			local isHovered = me:IsHovered()
			if isHovered then
				draw.RoundedBox(14,2,2,w-4,h-4,theme.hoverHighlight)
				textColor = theme.navtexthover
			else
				textColor = theme.navtext
			end
			draw.SimpleText("Requires Workshop Addon: " .. v, DCONFIG2.Font(22), w * .5, h * .5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		workshopButton.DoClick = function()
			DCONFIG2.PlaySound("click")
			gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=" .. v)
		end
		workshopButton:DockMargin(xPadding, 0, xPadding, 0)
		self.workshopButtons[workshopButton] = true
	end

	DCONFIG2.loadMaterial({imgurEnd = "wkZMbBp.png"}, function(material, matStr)
		self.image = vgui.Create("DImage", self.scroll)
		self.image:Dock(TOP)
		self.image:SetTall(self:GetTall() * .8)
		if not matStr then
			self.image.Paint = function(me,w,h)
				draw.RoundedBox(20,0,0,w,h,theme.theme)
			end
		else
			self.image:SetImage(matStr)
		end
		self.image:DockMargin(xPadding, yPadding, xPadding, 0)
	end)
	

end

function PANEL:PerformLayout(w,h)
	if self.workshopButtons then
		for panel,v in pairs(self.workshopButtons) do
			panel:SetTall(h * .05)
		end
	end
	if not IsValid(self.scroll) then return end

	self.titlePanel:SetTall(h * .1)
	self.scroll:SetTall(h * .7)
	self.closeButton:SetTall(h * .05)
	self.downloadButton:SetTall(h * .05)
	if self.downloadInfo then
		self.downloadInfo:SetTall(h * .18)
	end
	if self.image then
		self.image:SetTall(793) --1040- 793
	end
end

derma.DefineControl("DCONFIG2VaultDownloader", "DCONFIG2 Vault Downloader", PANEL, "DFrame")
