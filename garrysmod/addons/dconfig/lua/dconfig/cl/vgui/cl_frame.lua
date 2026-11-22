function DCONFIG2.Open()
	DCONFIG2.ScreenPanel = vgui.Create("DCONFIG2DFrame")
	DCONFIG2.PlaySound("open")
end

local refreshing = false
local refreshPage
function DCONFIG2.Refresh(page)
	DCONFIG2.Close(true)

	if not DCONFIG2.Tabs[page] then DCONFIG2.Open() return end

	refreshing = true
	refreshPage = page
	timer.Simple(0, function()
		DCONFIG2.Open()
	end)
end

hook.Add("DCONFIG2_MenuReady", "HandlePageRefreshing", function()
	if refreshing and refreshPage then
		DCONFIG2.ClearBody()
		DCONFIG2.ScreenPanel.page = refreshPage
		DCONFIG2.Tabs[refreshPage].callback()
		refreshing = false
		refreshPage = nil
	end
end)

function DCONFIG2.Close(noAnim)
	if not IsValid(DCONFIG2.ScreenPanel) then return end
	if IsValid(DCONFIG2.VaultViewer) then
		DCONFIG2.VaultViewer:Remove()
	end
	if IsValid(DCONFIG2.DownloadMenu) then
		DCONFIG2.DownloadMenu:Remove()
	end
	if IsValid(DCONFIG2.ScreenPanel.infoFrame) then
		DCONFIG2.ScreenPanel.infoFrame:Remove()
	end
	if IsValid(DCONFIG2.ScreenPanel.popupPanel) then
		DCONFIG2.ScreenPanel.popupPanel:Remove()
	end
	if noAnim then
		DCONFIG2.ScreenPanel:Remove()
		return
	end
	DCONFIG2.PlaySound("close")
	DCONFIG2.ScreenPanel.isAnimating = true
	DCONFIG2.ScreenPanel:SizeTo(0, 0, .6, 0, .1, function()
		DCONFIG2.ScreenPanel.isAnimating = false
		DCONFIG2.ScreenPanel:Remove()
	end)

end

concommand.Add("DCONFIG2", function()
	if not DCONFIG2.CanDConfig(LocalPlayer()) then LocalPlayer():ChatPrint("No access! Please configure in sh_config.lua") return end
	DCONFIG2.Open()
end)

function DCONFIG2.IsAnimating()
	if not IsValid(DCONFIG2.ScreenPanel) then return false end

	return DCONFIG2.ScreenPanel.isAnimating
end


local PANEL = {}


function PANEL:Init()
	local scrw, scrh = DCONFIG2.ScrW, DCONFIG2.ScrH
	self:SetDraggable(false)
	self:SetTitle("")
	self:ShowCloseButton(false)
	self:MakePopup()
	self.navPanel = self:Add("DCONFIG2Navigation")
	self.navPanel:Dock(LEFT)
	self.bodyPanel = self:Add("DCONFIG2Body")
	self.bodyPanel:Dock(RIGHT)
	local frameW, frameH, animTime, animDelay, animEase = scrw * .8, scrh * .88, 1, 0, .1
	if not refreshing then
		self.isAnimating = true
		self:SetSize(0, 0)
		self:SizeTo(frameW, frameH, animTime, animDelay, animEase, function()
			self.isAnimating = false
			timer.Simple(0, function()
				hook.Run("DCONFIG2_MenuReady")
			end)
		end)
	else
		self:SetSize(frameW, frameH)
		self:Center()
		self.navPanel:SetWide(math.Round(frameW * .18))
		self.bodyPanel:SetWide(frameW * .82)
		timer.Simple(0, function()
			hook.Run("DCONFIG2_MenuReady")
		end)
	end

	if DCONFIG2.IngameConfig.hints then
		local width, height = frameW * .8, scrh * .045
		local xPos, yPos = scrw * .5 - width * .5, scrh - height * 1.1
		self.infoFrame = vgui.Create("DPanel")
		self.infoFrame:SetSize(width, height)
		self.infoFrame:SetPos(xPos, yPos)
		local theme = DCONFIG2.GetTheme()
		local maxHints = #DCONFIG2.Hints
		local hintID = math.random(1, maxHints)
		local hintX = width * 1.2
		local moveSpeed = width * .1
		local r = 0
		local fadeSpeed = .5
		self.infoFrame.Paint = function(me,w,h)
			if IsValid(self.popupPanel) or not DCONFIG2.IngameConfig.hints then return end
			hintX = hintX - FrameTime() * moveSpeed
			local font = DCONFIG2.Font(20)
			local hintText = DCONFIG2.Hints[hintID]
			surface.SetFont(font)
			local textW = surface.GetTextSize(hintText)
			if hintX < -textW * 1.25 then
				r = math.Clamp(r - FrameTime() * fadeSpeed, 0, 1)
			else
				r = math.Clamp(r + FrameTime() * fadeSpeed, 0, 1)
			end
			surface.SetAlphaMultiplier(r)
			DCONFIG2.BlurMenu( me, 16, 16, 255 )
			local theme = DCONFIG2.GetTheme()
			draw.RoundedBox(20,0,0,w,h,theme.navigation)
			draw.SimpleText(hintText, font, hintX, h * .5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			surface.SetAlphaMultiplier(1)
			if hintX < -textW - w * 4 then
				hintX = width * 1.2
				hintID = hintID + 1
				if hintID > maxHints then
					hintID = 1
				end
			end
			if not IsValid(DCONFIG2.ScreenPanel) then
				me:Remove()
			end
		end
	end
end

function PANEL:ShowPopup(msg, icon, seconds, isError)
	seconds = seconds or 5
	if IsValid(self.popupPanel) then
		self.popupPanel:Remove()
	end
	local scrw, scrh = DCONFIG2.ScrW, DCONFIG2.ScrH
	local frameW = scrw * .8
	surface.SetFont(DCONFIG2.Font(20))
	local height = scrh * .045
	local textW = surface.GetTextSize(msg)
	local iconSize = height * .5
	local width = (textW + iconSize) * 1.35
	local yPos = scrh - height * 1.1
	self.popupPanel = vgui.Create("DPanel")
	self.popupPanel:SetSize(0, height)
	self.popupPanel:SetPos(scrw * .5, yPos)
	self.popupPanel.isAnimating = true
	local animTime, animDelay, animEase = .7, 0, .3
	if not isError then
		DCONFIG2.PlaySound("popup")
	else
		DCONFIG2.PlaySound("fail")
	end
	self.popupPanel:SizeTo(width, height, animTime, animDelay, animEase, function()
		self.popupPanel.isAnimating = false
	end)
	self.popupPanel.OnSizeChanged = function(me,w,h)
		if me.isAnimating then
			me:SetPos(scrw * .5 - w * .5, yPos)
		end
	end
	local mat = Material(icon)
	local dieTime = CurTime() + seconds
	local theme = DCONFIG2.GetTheme()
	self.popupPanel.Paint = function(me,w,h)
		local r = (dieTime - CurTime()) / seconds
		if r < -.5 then
			me:Remove()
			return
		end
		surface.SetAlphaMultiplier(r + .5)
		DCONFIG2.BlurMenu( me, 16, 16, 255 )
		draw.RoundedBox(20,0,0,w,h, theme.blur or theme.navigation)
		draw.SimpleText(msg, DCONFIG2.Font(20), w * .15 + iconSize, h * .5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		local matColor = isError and theme.red or theme.theme
		surface.SetDrawColor(matColor)
		surface.SetMaterial(mat)
		local iconSize = h * .5
		surface.DrawTexturedRect(w * .1, h * .5 - iconSize * .5, iconSize, iconSize)
		surface.SetAlphaMultiplier(1)
	end
end

function DCONFIG2.ShowPopup(msg, icon, seconds, isError)
	if not IsValid(DCONFIG2.ScreenPanel) then return end
	DCONFIG2.ScreenPanel:ShowPopup(msg, icon, seconds, isError)
end

function PANEL:OnSizeChanged(w,h)
	if self.isAnimating then
		self:Center()
	end
	if IsValid(self.navPanel) then
		self.bodyPanel:SetWide(w * .82)
		self.navPanel:SetWide(math.Round(w * .18))
	end
end

function PANEL:Paint(w,h)

end

derma.DefineControl("DCONFIG2DFrame", "DConfig DFrame", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
	self:SetText("")
	self.text = ""
	self.fontSize = 22
end

function PANEL:SetText(text)
	self.BaseClass.SetText(self, "")
	self.text = text
end

function PANEL:SetFontSize(size)
	self.fontSize = size
end

function PANEL:Paint(w,h)
	local theme = DCONFIG2.GetTheme()
	draw.RoundedBox(16,0,0,w,h,theme.theme)
	draw.RoundedBox(14,2,2,w-4,h-4,theme.body)
	local isHovered = self:IsHovered()
	if isHovered then
		draw.RoundedBox(14,2,2,w-4,h-4,theme.hoverHighlight)
		textColor = theme.navtexthover
	else
		textColor = theme.navtext
	end
	draw.SimpleText(self.text, DCONFIG2.Font(self.fontSize), w * .5, h * .5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function PANEL:DoClickInternal()
	DCONFIG2.PlaySound("click")
end

derma.DefineControl("DCONFIG2Button", "DCONFIG2 Button", PANEL, "DButton")

