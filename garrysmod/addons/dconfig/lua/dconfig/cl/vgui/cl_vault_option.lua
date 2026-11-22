

local PANEL = {}


function PANEL:Init()

end

function PANEL:SetTitle(title)
	local theme = DCONFIG2.GetTheme()
	local scrw,scrh = ScrW(), ScrH()
	local xPad = scrw * .01
	local yPad = scrh * .01
	self.title = title
	self.titleLabel = self:Add("DLabel")
	self.titleLabel:Dock(TOP)
	self.titleLabel:SetText(title)
	self.titleLabel:SetContentAlignment(4)
	self.titleLabel:SetFont(DCONFIG2.Font(24))
	self.titleLabel:SetTextColor(theme.theme)
	self.titleLabel:DockMargin(xPad, 0, 0, 0)

	self.body = self:Add("DPanel")
	self.body:Dock(TOP)
	self.body.Paint = function(me,w,h)
		draw.RoundedBox(20, 0, 0, w, h, theme.panel)
	end

	self.contentData = DCONFIG2.Vault[title]
	if not self.contentData then return end

	self.scroll = self.body:Add("DCONFIG2ScrollBar")
	self.scroll:Dock( FILL )
	DCONFIG2.PaintScrollBar(self.scroll)

	self.layoutList = vgui.Create("DIconLayout", self.scroll)
	self.layoutList:Dock(FILL)
	self.layoutList:SetSpaceY(xPad)
	self.layoutList:SetSpaceX(yPad)
	self.layoutList:DockMargin(xPad, yPad, xPad, 0)
	self.contentPosts = {}
	for k,downloadData in pairs(self.contentData) do
		local post = self.layoutList:Add("DCONFIG2VaultOptionContent")
		post:SetTitle(downloadData.name)
		post:SetData(downloadData, k)
		self.contentPosts[post] = true
	end
	self.layoutList.OnSizeChanged = function(list, w, h)
		for post,_ in pairs(self.contentPosts) do
			if not IsValid(post) then
				self.contentPosts[post] = nil
				continue
			end 
			local size = math.floor(w / 6 - xPad / 2)
			post:SetSize(size, size)
			self.body:SetTall(size + yPad * 2.5)
		end
	end

end

function PANEL:Paint(w,h)

end

function PANEL:OnSizeChanged(w,h)
	self.titleLabel:SetTall(h * .1)
	if self.contentPosts then
		for k,v in pairs(self.contentPosts) do
			k:SetWide(w * .15)
		end
	end
	if not IsValid(self.scroll) then return end
	self.scroll:SetTall(h * .9)
end

derma.DefineControl("DCONFIG2VaultOption", "DCONFIG2 Vault Option", PANEL, "DPanel")
