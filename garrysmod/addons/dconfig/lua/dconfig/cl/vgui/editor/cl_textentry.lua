
local PANEL = {}


local lockColor = Color(0,0,0,200)

function DCONFIG2.DecoratePanel(panel, w, h, squareBottom)
	local squareBottom = squareBottom or false 
	local theme = DCONFIG2.GetTheme()
	draw.RoundedBoxEx(10, 0, 0, w, h, theme.panel, true, true, !squareBottom, !squareBottom)
	if panel.flash and panel.flash > 0 then
		surface.SetAlphaMultiplier(panel.flash - .8)
		draw.RoundedBoxEx(10, 0, 0, w, h, theme.theme, true, true, !squareBottom, !squareBottom)
		surface.SetAlphaMultiplier(1)
	end
end

function PANEL:Init()
	local theme = DCONFIG2.GetTheme()
	self.squareBottom = false
	self.textEntry = self:Add("DTextEntry")
	self.textEntry:SetFont(DCONFIG2.Font(18))
	self.textEntry:Dock(FILL)
	self.textEntry.highlightColor = Color(theme.theme.r, theme.theme.g, theme.theme.b, 130)
	self.textEntry.defaultColor = theme.subtitletext
	self.textEntry.defaultText = "Please type here."
	self.textEntry.Paint = function(me,w,h)
		local theme = DCONFIG2.GetTheme()
		DCONFIG2.DecoratePanel(me, w, h, self.squareBottom)
		me:DrawTextEntryText(color_white, me.highlightColor, me.highlightColor)
		if string.len(me:GetText()) <= 0 then
			local yPos = self.textEntry:IsMultiline() and h * .1 or h * .5
			draw.SimpleText(me.defaultText, DCONFIG2.Font(18), 5, yPos, me.defaultColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
		if not me:IsEnabled() then
			draw.RoundedBoxEx(10, 0, 0, w, h, lockColor, true, true, !self.squareBottom, !self.squareBottom)
			me:DrawTextEntryText(theme.subtitletext, me.highlightColor, me.highlightColor)
		else
			me:DrawTextEntryText(color_white, me.highlightColor, me.highlightColor)
		end
	end
	self.textEntry:SetUpdateOnType(true)
	self.textEntry:SetTabbingDisabled( true )
	self.textEntry.OnValueChange = function(me, val)
		self.input = value
		self.textEntry.input = value
        if not self.OnValueChange then return end
        
		self:OnValueChange(val)
	end
	self.textEntry.OnFocusChanged = function(me, gained)
		self:OnFocusChanged(gained)
	end
	self.textEntry.OnEnter = function()
		self:OnEnter()
	end
	self.textEntry.SetValue = function(me, strValue)

		local CaretPos = me:GetCaretPos()
		me:SetText( strValue )
		me:OnValueChange( strValue )

		me:SetCaretPos( CaretPos )
	end

end

function PANEL:SetMultiline(bool)
	self.textEntry:SetMultiline(bool)
end


function PANEL:SetFont(font)
	self.textEntry:SetFont(font)
end

function PANEL:SetText(txt)
	self.textEntry:SetText(txt)
end

function PANEL:GetValue()
	return self.textEntry:GetValue()
end

function PANEL:SetNumeric(bool)
	self.textEntry:SetNumeric(bool)
end

function PANEL:IsEditing()
	return self.textEntry:IsEditing()
end

function PANEL:GetNumeric()
	return self.textEntry:GetNumeric()
end

function PANEL:SetDefaultText(value)
	self.defaultText = value
	value = string.gsub(value, "\n", " ")
	value = string.gsub(value, "    ", " ")
	self.textEntry.defaultText = value
end

function PANEL:GetDefaultText()
	return self.defaultText
end

function PANEL:SquareBottom(bool)
	self.squareBottom = bool
end 


function PANEL:Paint(w,h)
	local theme = DCONFIG2.GetTheme()
	draw.RoundedBoxEx(10, 0, 0, w, h, theme.panel, true, true, !self.squareBottom, !self.squareBottom)
	if self.flash and self.flash > 0 then
		surface.SetAlphaMultiplier(self.flash - .8)
		draw.RoundedBoxEx(10, 0, 0, w, h, theme.theme, true, true, !self.squareBottom, !self.squareBottom)
		surface.SetAlphaMultiplier(1)
	end
end


function PANEL:Think()
	self:HandleFlash()
end 

function PANEL:HandleFlash()
	if self.flash and self.flash > 0 then
		self.flash = self.flash - .2 * FrameTime()
	end
	if self.textEntry.flash and self.textEntry.flash > 0 then
		self.textEntry.flash = self.textEntry.flash - .2 * FrameTime()
	end
end

function PANEL:SetValue(val)
	if not val then
		val = ""
	end
	if self.textEntry:GetValue() == val then return end
	self.textEntry:SetValue(val)
	self.flash = 1
	self.textEntry.flash = 1
end

function PANEL:OnEnter()

end

function PANEL:OnFocusChanged(gained)

end

function PANEL:RequestFocus()
	self.textEntry:RequestFocus()
end

function PANEL:OnSizeChanged(w,h)
	self.textEntry:DockMargin(w * .005, 0, 0, 0)
end

derma.DefineControl("DCONFIG2TextEntry", "DCONFIG2 Text Entry", PANEL, "DPanel")

