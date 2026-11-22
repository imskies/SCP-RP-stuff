local PANEL = {}
function PANEL:Init()
	self:SetDrawOnTop(true)
	self:MakePopup()
	self:MoveToFront()
	self:SetSize(ScrW(), ScrH())
end

PANEL.Paint = function() end

function PANEL:OnScreenSizeChanged()
	self:SetSize(ScrW(), ScrH())
end

function PANEL:OnSizeChanged(this)
	for k, v in ipairs(self:GetChildren()) do
		v:Center()
	end
end

/*
timer.Simple(2, function()
	vgui.GetHoveredPanel():Remove()
end)
*/

derma.DefineControl("DCONFIG2ModalContainer", "", PANEL, "EditablePanel")


local PANEL = {}
PANEL.Title = "Attention!"
PANEL.Message = "Are you sure?"
PANEL.ConfirmText = "Yes"
PANEL.ConfirmCallback = NOOP
PANEL.CancelText = "No"
PANEL.CancelCallback = NOOP

function PANEL:Modalize()
	if self.ModalContainer then return end

	self.ModalContainer = vgui.Create("DCONFIG2ModalContainer")
	if zpos then
		self.ModalContainer:SetZPos(zpos)
	end
	self:SetParent(self.ModalContainer)
	self.MakePopup = NOOP

	self._OnRemove = self._OnRemove or self.OnRemove

	self.OnRemove = function(this)
		if IsValid(this.ModalContainer) then
			this.ModalContainer:Remove()
		end

		if self._OnRemove then
			self:_OnRemove()
		end
	end

	if self.SetBackgroundBlur then
		self:SetBackgroundBlur(true)
	end
end


function PANEL:Init()
    local theme = DCONFIG2.GetTheme()
	self:Modalize()

	self:ShowCloseButton(false)
	self:SetSize(w, h)
	self:SetTitle("")
	self:Center()

    self:DockPadding(0,0,0,0)

	self.TitleText = self:Add("DLabel")
	self.TitleText:Dock(TOP)
	self.TitleText:SetText(self.Title)
	self.TitleText:SetContentAlignment(4)
	self.TitleText:SetWrap(true)
	self.TitleText:SetAutoStretchVertical(true)
	self.TitleText:SetZPos(2)
    self.TitleText:SetTextColor(theme.titletext)

	self.Text = self:Add("DLabel")
	self.Text:Dock(TOP)
	self.Text:SetText(self.Message)
	self.Text:SetContentAlignment(4)
	self.Text:SetWrap(true)
	self.Text:SetAutoStretchVertical(true)
	self.Text:SetZPos(3)
    self.Text:SetTextColor(theme.subtitletext)

    self.ButtonContainer = self:Add("DPanel")
    self.ButtonContainer:Dock(BOTTOM)
    self.ButtonContainer.Paint = nil

	self.Confirm = self.ButtonContainer:Add("DCONFIG2Button")
	self.Confirm:SetText(self.ConfirmText)
	self.Confirm:Dock(LEFT)
	--self.Confirm:SetZPos(1)
	self.Confirm:SetContentAlignment(5)
	self.Confirm.DoClick = function()
		self:Remove()
		self:CallConfirm()
	end

	self.Cancel = self.ButtonContainer:Add("DCONFIG2Button")
	self.Cancel:SetText(self.CancelText)
	self.Cancel:Dock(RIGHT)
	--self.Cancel:SetZPos(0)
	self.Cancel:SetContentAlignment(5)
	self.Cancel.DoClick = function()
		self:Remove()
		self:CallCancel()
	end
end

function PANEL:Paint(w,h)
    local theme = DCONFIG2.GetTheme()
	draw.RoundedBox(20, 0, 0, w, h, theme.theme)
	draw.RoundedBox(20, 2, 2, w - 4, h - 4, theme.body)
    --draw.SimpleText(self.Title, DCONFIG2.Font(20), w * .02, h * .05, theme.titletext, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:OnScreenSizeChanged(w,h)
	local scrw, scrh = DCONFIG2.ScrW, DCONFIG2.ScrH
    local xPad = scrw * .01
	self.TitleText:SetFont(DCONFIG2.Font(20))
	self.Text:SetFont(DCONFIG2.Font(16))
	self:SetSize(scrw * .25, scrh * .16)
	self.ButtonContainer:SetTall(scrh * .03)
    self.ButtonContainer:DockMargin(xPad, scrh * .01, xPad, scrh * .01)
	self.TitleText:DockMargin(xPad, scrh * .01, xPad, 0)
	self.Text:DockMargin(xPad, 0, xPad, 0)
	self.Confirm:SetWide(scrw * .1)
	self.Cancel:SetWide(scrw * .1)
	self:Center()
end

function PANEL:UpdateLabels()
	self.Text:SetText(self.Message)
	self.Confirm:SetText(self.ConfirmText)
	self.Cancel:SetText(self.CancelText)
	self.TitleText:SetText(self.Title)
	self:OnScreenSizeChanged()
end

function PANEL:OnClose()
	if self.CloseCallback then
		self.CloseCallback()
	end
end

function PANEL:OnFocusChanged()
	self:MoveToFront()
	timer.Simple(0, function()
		if IsValid(self) then
			self:MoveToFront()
		end
	end)
end

function PANEL:OnRemove()
	self.BackPanel:Remove()
	self.TitleText:SetText(self.Title)
end

function PANEL:PopulateTop()
end

function PANEL:CallConfirm()
	self.ConfirmCallback()
end

function PANEL:CallCancel()
	self.CancelCallback()
end


function PANEL.Create(class, data)
	local parent = vgui.GetWorldPanel()
	if IsValid(parent.ConfirmDialog) then
		parent.ConfirmDialog:Remove()
	end

	local confirmDialog = vgui.Create("DPanel", parent)
	confirmDialog.OnScreenSizeChanged = function(self)
		self:SetSize(ScrW(), ScrH())
	end
    confirmDialog.Paint = function(me,w,h)
        surface.SetDrawColor(0,0,0,240)
        surface.DrawRect(0,0,w,h)
    end 
	confirmDialog:OnScreenSizeChanged()
	confirmDialog:SetZPos(1000)
	confirmDialog:MoveToFront()

	parent.ConfirmDialog = confirmDialog

	local confirm = confirmDialog:Add(class)
	confirm.BackPanel = confirmDialog
	confirm:MoveToFront()
	confirm.ConfirmText = data.confirm or confirm.ConfirmText
	confirm.ConfirmCallback = data.confirmCallback or confirm.ConfirmCallback

	confirm.CancelText = data.cancel or confirm.CancelText
	confirm.CancelCallback = data.cancelCallback or confirm.CancelCallback

	confirm.Title = data.title or confirm.Title
	confirm.Message = data.message or confirm.Message

	confirm.Request = data

	confirm:UpdateLabels()
	confirm:PopulateTop()

	return confirm
end
derma.DefineControl("DCONFIG2ConfirmationPrompt", "", PANEL, "DFrame")
function DCONFIG2.ConfirmationPrompt(data)
	return DCONFIG2ConfirmationPrompt.Create("DCONFIG2ConfirmationPrompt", data)
end


local PANEL = {}
PANEL.Title = "Select an amount"
PANEL.ConfirmText = "OK"
PANEL.CancelText = "Cancel"

function PANEL:PopulateTop()
    local scrw, scrh = DCONFIG2.ScrW, DCONFIG2.ScrH
	self.TextEntry = self:Add("DCONFIG2DTextEntry")
	self.TextEntry:Dock(TOP)
	self.TextEntry:SetTall(0)
	self.TextEntry:SetZPos(4)
	self.TextEntry:SetFont(DCONFIG2.Font(28))
	local xPad = scrw * .01
	self.TextEntry:DockMargin(xPad, 0, xPad, 0)
	self.TextEntry.OnEnter = function()
		self:CallConfirm()
		self:Remove()
	end

	local mul = {
		k = "1000",
		m = "1000000",
	}

	self.TextEntry.AllowInput = function(this, char)
		if mul[char] then
			local cur = tonumber(this:GetValue())
			if not cur then return true end

			cur = math.min((2^31-1), cur * mul[char])
			local s = tostring(math.floor(cur))
			this:SetValue(s)
			this:SetText(s)
			this:SetCaretPos(#s)

			return true
		end
		return tonumber(char) == nil and char != "."
	end
	self.TextEntry:RequestFocus()
end

function PANEL:CallConfirm()
	if tonumber(self.TextEntry:GetValue()) then
		self.ConfirmCallback(tonumber(self.TextEntry:GetValue()))
	else
		self:CallCancel()
	end
end

derma.DefineControl("DCONFIG2AmountPrompt", "", PANEL, "DCONFIG2ConfirmationPrompt")
function DCONFIG2.AmountPrompt(data)
	return DCONFIG2ConfirmationPrompt.Create("DCONFIG2AmountPrompt", data)
end



local PANEL = {}
PANEL.Title = "Enter your answer"
PANEL.ConfirmText = "OK"
PANEL.CancelText = "Cancel"

function PANEL:PopulateTop()
    local scrw, scrh = DCONFIG2.ScrW, DCONFIG2.ScrH
	self.TextEntry = self:Add("DCONFIG2TextEntry")
	self.TextEntry:Dock(BOTTOM)
	self.TextEntry:SetTall(scrh * .03)
	self.TextEntry:SetZPos(3)
	self.TextEntry:SetFont(DCONFIG2.Font(28))
	self.TextEntry:SetNumeric(false)
    self.TextEntry:SetDefaultText(self.Request.defaultText)
	local xPad = scrw * .01
	self.TextEntry:DockMargin(xPad, 0, xPad, 0)
	self.TextEntry.OnEnter = function()
		self:CallConfirm()
		self:Remove()
	end

	if self.Request.enableText then
		self.Confirm:SetEnabled(false)
		self:SetTall(self:GetTall() * 1.25)
		self.TextEntry:SetUpdateOnType(true)
		self.TextEntry.OnValueChange = function(this, txt)
			self.Confirm:SetEnabled(txt:lower() == self.Request.enableText)
		end
	end

	self.TextEntry:RequestFocus()
end

function PANEL:CallConfirm()
	self.ConfirmCallback(self.TextEntry:GetValue())
end

derma.DefineControl("DCONFIG2StringPrompt", "", PANEL, "DCONFIG2ConfirmationPrompt")
function DCONFIG2.StringPrompt(data)
	return DCONFIG2ConfirmationPrompt.Create("DCONFIG2StringPrompt", data)
end

local PANEL = {}
PANEL.Title = "Error"
PANEL.ConfirmText = "OK"
PANEL.CancelText = ""

function PANEL:Init()
	self.Cancel:Remove()
end

derma.DefineControl("DCONFIG2ErrorPrompt", "", PANEL, "DCONFIG2ConfirmationPrompt")
function ErrorPrompt(data)
	return DCONFIG2.DCONFIG2ConfirmationPrompt.Create("DCONFIG2ErrorPrompt", data)
end
