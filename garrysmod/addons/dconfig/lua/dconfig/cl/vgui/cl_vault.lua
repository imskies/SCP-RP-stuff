
function DCONFIG2.OpenVault()
	if not DCONFIG2.IsBodyAvailable() then return end

	local body = DCONFIG2.GetBody()
	if not body then return end

	local vault = body:Add("DCONFIG2Vault")
	vault:Dock(FILL)

end

function DCONFIG2.SaveContentToVault(saveData)
	// TODO: Complete Implementation
	/*
	net.Start("dconfig2_saveToVault")
	net.WriteString(self.editorType)
	net.WriteTable(saveData)
	net.SendToServer()
*/
end


local PANEL = {}

function PANEL:Init()

	local scrw,scrh = ScrW(), ScrH()
	local xPadding = scrw * .01
	local yPadding = scrh * .01
	local theme = DCONFIG2.GetTheme()
	self.titlePanel = self:Add("DPanel")
	self.titlePanel:Dock(TOP)
	self.titlePanel.Paint = function(me,w,h)
		local theme = DCONFIG2.GetTheme()
		draw.SimpleText("Welcome to The Vault", DCONFIG2.Font(36), w * .5, h * .3, theme.titletext, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Here you can download DConfig templates for popular addons to get your server running within minutes!", DCONFIG2.Font(22), w * .5, h * .6, theme.subtitletext, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.scroll = self:Add("DCONFIG2ScrollBar")
	self.scroll:Dock(TOP)
	DCONFIG2.PaintScrollBar(self.scroll)

	self.options = {}
	local sortedVault = {}
	for k,v in pairs(DCONFIG2.Vault) do
		table.insert(sortedVault, k)
	end
	table.sort(sortedVault, function(a,b) return a < b end)
	for k, optionTitle in ipairs(sortedVault) do
		if table.Count(DCONFIG2.Vault[optionTitle]) <= 0 then continue end
		local optionPanel = self.scroll:Add("DCONFIG2VaultOption")
		optionPanel:Dock(TOP)
		optionPanel:SetTitle(optionTitle)
		optionPanel:DockMargin(xPadding, yPadding, xPadding, 0)
		self.options[k] = optionPanel
	end
end

function PANEL:OnSizeChanged(w,h)
	self.titlePanel:SetTall(h * .1)
	self.scroll:SetTall(h * .9)
	for k,v in pairs(self.options) do
		v:SetTall(h * .3)
	end
end

function PANEL:Paint(w,h) end

derma.DefineControl("DCONFIG2Vault", "DCONFIG2 Vault", PANEL, "DPanel")
