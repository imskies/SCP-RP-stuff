
local PANEL = {}

function PANEL:Init()

end

function PANEL:SetTitle(title)
	local scrw,scrh = ScrW(), ScrH()
	local theme = DCONFIG2.GetTheme()
	self.title = title
	self.titleLabel = self:Add("DLabel")
	self.titleLabel:Dock(TOP)
	self.titleLabel:SetText(title)
	self.titleLabel:SetContentAlignment(5)
	self.titleLabel:SetFont(DCONFIG2.Font(22))
	self.titleLabel:SetTextColor(theme.text)
	local xPadding = scrw * .01
	local yPadding = scrh * .01
end

function PANEL:SetData(data, dataID)
	local scrw,scrh = ScrW(), ScrH()
	local xPadding = scrw * .01
	local yPadding = scrh * .01
	local theme = DCONFIG2.GetTheme()
  //PrintTable(data)
  DCONFIG2.loadMaterial({imgurEnd = data.img, steamURL = data.steamImg, name = data.name}, function(material, matStr)
		self.image = vgui.Create("DImage", self)
		self.image:Dock(TOP)
		self.image:SetTall(self:GetTall() * .8)
		if not matStr then
			self.image.Paint = function(me,w,h)
				draw.RoundedBox(20,0,0,w,h,theme.theme)
			end
		else
			self.image:SetImage(matStr)
		end
		self.viewButton = self:Add("DButton")
		self.viewButton:SetText("")
		self.viewButton:Dock(TOP)
		self.viewButton:DockMargin(0,yPadding,0,0)
		local textColor
		self.viewButton.Paint = function(me,w,h)
			draw.RoundedBox(16,0,0,w,h,theme.theme)
			draw.RoundedBox(16,2,2,w-5,h-5,theme.body)
			local isHovered = me:IsHovered()
			if isHovered then
				draw.RoundedBox(16,2,2,w-5,h-5,theme.hoverHighlight)
				textColor = theme.navtexthover
			else
				textColor = theme.navtext
			end
			draw.SimpleText("Download", DCONFIG2.Font(24), w * .5, h * .5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		self.viewButton.DoClick = function()
			DCONFIG2.PlaySound("click")
			DCONFIG2.OpenVaultOption(data, dataID)
		end
	end)

end

function PANEL:Paint(w,h)

end

function PANEL:OnSizeChanged(w,h)
	self.titleLabel:SetTall(h * .1)
	if IsValid(self.image) then
		self.image:SetTall(h * .7)
	end
	if IsValid(self.viewButton) then
		self.viewButton:SetTall(h * .15)
	end
end

derma.DefineControl("DCONFIG2VaultOptionContent", "DCONFIG2 Vault Option Content", PANEL, "DPanel")
