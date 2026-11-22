
function DCONFIG2.OpenCredits()
	if not DCONFIG2.IsBodyAvailable() then return end

	local body = DCONFIG2.GetBody()
	if not body then return end

	local credits = body:Add("DCONFIG2Credits")
	credits:Dock(FILL)

end

local PANEL = {}

local buttons = {
	{name = "Youtube", link = "https://youtube.com/danfmn"},
	{name = "GmodStore", link = "https://www.gmodstore.com/users/dan"},
	{name = "Discord", link = "https://discord.gg/cC9KZUd"},
	{name = "YourDevTools", link = "https://yourdevtools.com/?ref=dconfig2"},
}

local petURLs = {
	{title = "Lythium's Cat 'Monty'", url = "3hMte9o.png"},
	{title = "Dan's Cat 'Sage'", url = "i5CPSFx.jpg"},
	{title = "Unkn0wn_F1R3's Dog 'Amber'", url = "87VJ0sA.jpg"},
	{title = "Lord Sugar's Dog", url = "HEXEyEp.png"},
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
		draw.SimpleText("DConfig 2 Credits", DCONFIG2.Font(36), w * .5, h * .3, theme.titletext, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("CHECK OUT SOME PETS AND READ ABOUT THE DEVELOPER", DCONFIG2.Font(22), w * .5, h * .6, theme.subtitletext, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.scroll = self:Add("DCONFIG2ScrollBar")
	self.scroll:Dock(FILL)
	DCONFIG2.PaintScrollBar(self.scroll)
    
    self.mainPanel = self.scroll:Add("DPanel")
    self.mainPanel:Dock(TOP)
    self.mainPanel:DockMargin(xPadding, 0, xPadding, 0)
	self.mainPanel.Paint = function(me,w,h)
		draw.RoundedBox(20, 0, 0, w, h, theme.panel)
	end 

    local imageSize
    DCONFIG2.loadMaterial({imgurEnd = "o4RE4bj.png"}, function(material, matStr)
        self.image = self.mainPanel:Add("DImage")
		self.image:Dock(LEFT)
		self.image:DockMargin(xPadding, yPadding, 0, yPadding)
		--self.image:SetTall(self:GetTall() * .8)

		if not matStr then
			self.image.Paint = function(me,w,h)
				draw.RoundedBox(20,0,0,w,h,theme.theme)
			end
		else
			self.image:SetImage(matStr)
		end
		self.image.OnSizeChanged = function(me,w,h)
			self.image:SetWide(h)
		end
    end)

	
    
	self.titleLabel = self.mainPanel:Add("DLabel")
	self.titleLabel:Dock(TOP)
	self.titleLabel:SetText("DanFMN")
	self.titleLabel:SetTextColor(theme.titletext)
	self.titleLabel:SetFont(DCONFIG2.Font(24))
	self.titleLabel:DockMargin(xPadding, yPadding, 0, 0)
	self.titleLabel:SetAutoStretchVertical(true)

	self.subLabel = self.mainPanel:Add("DLabel")
	self.subLabel:Dock(TOP)
	self.subLabel:SetText("Developed DConfig 1 and 2 from start to finish.")
	self.subLabel:SetTextColor(theme.subtitletext)
	self.subLabel:SetFont(DCONFIG2.Font(24))
	self.subLabel:DockMargin(xPadding, yPadding, 0, 0)
	self.subLabel:SetAutoStretchVertical(true)

	self.buttonPanel = self.mainPanel:Add("DPanel")
	self.buttonPanel:Dock(TOP)
	self.buttonPanel:DockMargin(0, yPadding, xPadding, 0)
	self.buttonPanel.Paint = nil

	self.buttons = {}
	for k,v in pairs(buttons) do
		local button = self.buttonPanel:Add("DButton")
		button:Dock(LEFT)
		button:SetText("")
		button:DockMargin(xPadding, 0, 0, 0)
		button.Paint = function(me,w,h)
			draw.RoundedBox(16,0,0,w,h,theme.theme)
			draw.RoundedBox(16,2,2,w-4,h-4,theme.body)
			local isHovered = me:IsHovered()
			if isHovered then
				draw.RoundedBox(14,2,2,w-4,h-4,theme.hoverHighlight)
				textColor = theme.navtexthover
			else
				textColor = theme.navtext
			end
			draw.SimpleText(v.name, DCONFIG2.Font(22), w * .5, h * .5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		button.DoClick = function()
			gui.OpenURL(v.link)
		end 
		self.buttons[button] = true
	end

	self.mainPanel.OnSizeChanged = function(me,w,h)
		self.buttonPanel:SetTall(h * .2)
		if not self.buttons then return end
	
		for button,v in pairs(self.buttons) do
			button:SetWide(w / 5)
		end 
	end 

	local paintControl = function(control, forward)
		control:SetText("")
		control.Paint = function(me,w,h)
			surface.SetDrawColor(0,0,0,200)
			surface.DrawRect(0,0,w,h)
			if me:IsHovered() then 
				surface.SetDrawColor(theme.hoverHighlight)
				surface.DrawRect(0,0,w,h)
			end
			draw.SimpleText(forward and ">" or "<", DCONFIG2.Font(24), w * .5, h * .5, theme.theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	
	local petID = math.random(1, #petURLs)
	local loadingPet = false
	local handleControl = function(forward)
		if loadingPet then return end

		if forward then
			petID = petID + 1
		else
			petID = petID - 1
		end 
		if petID < 1 then
			petID = #petURLs
		elseif petID > #petURLs then
			petID = 1
		end 
	end

	self.petPanel = self.scroll:Add("DPanel")
	self.petPanel:Dock(TOP)
	self.petPanel:DockMargin(xPadding, yPadding, xPadding, yPadding)
	self.petPanel.Paint = function(me,w,h)
		draw.RoundedBox(16,0,0,w,h,theme.panel)
	end

	self.petTitle = self.petPanel:Add("DLabel")
	self.petTitle:SetText("Big shout out to everyone in the discord! Several people have provided great feedback and overall moral support through out all the development I've done. Here is a few great photos of their personal pets. If you'd like your pet added at some point, please reach out in the discord PETS channel!")
	self.petTitle:SetFont(DCONFIG2.Font(20))
	self.petTitle:Dock(TOP)
	self.petTitle:DockMargin(xPadding, yPadding, xPadding, 0)
	self.petTitle:SetAutoStretchVertical(true)
	self.petTitle:SetWrap(true)

	local function loadPetImage(id)
		local petData = petURLs[id]
		loadingPet = true
		DCONFIG2.loadMaterial( {imgurEnd = petData.url}, function(material, matStr)
			loadingPet = false
			if IsValid(self.petControls) then 
				self.petControls:Remove()
			end
			self.petImage = self.petPanel:Add("DImage")
			self.petImage:Dock(FILL)
			self.petImage:DockMargin(xPadding, xPadding, xPadding, xPadding)
			self.petImage:SetMouseInputEnabled(true)
			if not matStr then
				self.petImage.Paint = function(me,w,h)
					draw.RoundedBox(20,0,0,w,h,theme.theme)
				end
			else
				self.petImage:SetImage(matStr)
			end
			
			self.petControls = self.petImage:Add("DPanel")
			self.petControls:Dock(BOTTOM)
			self.petControls.Paint = function(me,w,h)
				surface.SetDrawColor(0,0,0,200)
				surface.DrawRect(0,0,w,h)
				draw.SimpleText(petData.title, DCONFIG2.Font(24), w * .5, h * .5, theme.theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end 

			self.forwardButton = self.petControls:Add("DButton")
			self.forwardButton:Dock(RIGHT)
			self.forwardButton.DoClick = function()
				handleControl(true)
				loadPetImage(petID)
			end
		
			self.backButton = self.petControls:Add("DButton")
			self.backButton:Dock(LEFT)
			self.backButton.DoClick = function()
				handleControl(false)
				loadPetImage(petID)
			end
			paintControl(self.forwardButton, true)
			paintControl(self.backButton)
			if self.petControls then
				self.petControls:SetTall(self.petPanel:GetTall() * .08)
			end 
		end)
	end
 
	loadPetImage(petID)
end



function PANEL:OnSizeChanged(w,h)
	self.titlePanel:SetTall(h * .1)
    self.mainPanel:SetTall(h * .15)
	self.petPanel:SetTall(h * .7)
	if self.petControls then
		self.petControls:SetTall(self.petPanel:GetTall() * .08)
	end 
end


function PANEL:Paint(w,h)

end

derma.DefineControl("DCONFIG2Credits", "DCONFIG2 Stats", PANEL, "DPanel")
