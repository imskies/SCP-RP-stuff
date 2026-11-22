
local PANEL = {}

function PANEL:Init()
	hook.Add("OnTextEntryGetFocus", self, function(pnl) -- OnFocusChanged will not work as expected so hook is fallback.
		if pnl != self then
			self:ClearResults()
		end
	end)
end


function PANEL:SetSearchData(data)
	self.searchData = {}
	for k,v in pairs(data) do
		self.searchData[v.key] = v
	end
	self.results = {}
end

local haystacks = {
	name = true,
	description = true,
	key = true,
}
function PANEL:SearchFor(str)
	self.results = {}
	self:RemoveResultPanel()
	if self.resultPanels then
		for k,v in ipairs(self.resultPanels) do
			v:Remove()
		end
	end
	local body = DCONFIG2.GetBody()
	if not body then return end
	if not IsValid(body.editorPanel) then return end
	local options = body.editorPanel.options
	if not options then return end

	if string.len(str) > 1 then
		local str = string.lower(str)
		for optionKey,optionPanel in pairs(options) do
			local optionData = self.searchData[optionKey]
			local value = optionPanel:GetValue()
			if value == "" and optionPanel.GetDefaultText then
				value = optionPanel:GetDefaultText()
			end
			value = tostring(value)
			local lowerValue = string.lower(value)
			local foundInOption = false
			for haystack, _ in pairs(haystacks) do
				if string.find(string.lower(optionData[haystack]), str) then
					foundInOption = true
					break
				end
			end
			if foundInOption or string.find(string.lower(lowerValue), str) or string.find(string.lower(optionKey), str) then
				optionData.value = value
				self.results[optionKey] = optionData
			end

		end
		self:PopulateResults()
		return
	end
end

function PANEL:PopulateResults()
	self.resultPanels = {}
	local parentX, parentY = self:GetPos()
	local xPos,yPos = self:GetParent():LocalToScreen(parentX, parentY)
	local wide = self:GetWide()
	local pad = wide * .01
	local count = 0
	self.searchingNotice = vgui.Create("DPanel")
	self.searchingNotice:SetSize(wide, self:GetTall() * 1)
	self.searchingNotice:SetPos(xPos, yPos + self:GetTall() + self:GetTall() * 1.5 * count)
	self.searchingNotice:MakePopup()
	self.searchingNotice:SetDrawOnTop(true)
	self.searchingNotice:SetKeyBoardInputEnabled(false)
	self:SquareBottom(true)
	local theme = DCONFIG2.GetTheme()
	self.searchingNotice.Paint = function(me,w,h)
	draw.RoundedBoxEx(10, 0, 0, w, h, theme.theme, false, false, true, true)
	draw.RoundedBoxEx(10, 2, 2, w - 4, h - 4, theme.panel, false, false, true, true)
		surface.SetAlphaMultiplier(math.sin(CurTime() * 3) + .9)
		draw.SimpleText("Searching - Press Enter to Quick Finish/Select", DCONFIG2.Font(20), w * .5, h * .5, theme.titletext, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		surface.SetAlphaMultiplier(1)
	end
	table.insert(self.resultPanels, self.searchingNotice)
	timer.Create("searchKeyboardEnable", 1, 1, function()
		if not IsValid(self) then return end
		self:CreateResults()
	end)
end

function PANEL:OnEnter()
	self:CreateResults()
end

function PANEL:CreateResults()
	timer.Destroy("searchKeyboardEnable")
	local parentX, parentY = self:GetPos()
	local xPos,yPos = self:GetParent():LocalToScreen(parentX, parentY)
	local wide = self:GetWide()
	local count = 0
	local resultYPos =  yPos + self:GetTall()
	if table.Count(self.results) > 0 then 
		self.resultsPanel = vgui.Create("DPanel")
		self.resultsPanel:SetWide(wide)
		self.resultsPanel:SetDrawOnTop(true)
		--self.resultsPanel:MoveToFront()
		self.resultsPanel:SetPos(xPos, resultYPos)
		local theme = DCONFIG2.GetTheme()
		local yPad = self:GetTall() * .1
		local xPad = yPad
		self.resultsPanel.Paint = function(me,w,h)
			draw.RoundedBoxEx(10, 0, 0, w, h, theme.theme, false, false, true, true)
			draw.RoundedBoxEx(10, 2, 2, w -4, h -4, theme.body, false, false, true, true)
		end

		local resultsHeight = 0
		for k,optionData in pairs(self.results) do
			local result = self.resultsPanel:Add("DCONFIG2SearchResult")
			result:SetSize(wide - xPad * 2, self:GetTall() * 1.3)
			result:SetPos(xPos + xPad, resultYPos + yPad * count + 4)
			result:SetKeyBoardInputEnabled(false)
			result:SetZPos(3000)
			result:MoveToFront()
			result:SetDrawOnTop(true)
			result:SetHeaderText(optionData.name)
			result:SetSubText(optionData.description)
			if optionData.value and string.len(optionData.value) > 0 then
				result:SetValueText(optionData.value)
				result:SetTall(self:GetTall() * 1.8)
			end
			result.optionData = optionData
			result:SetTextEntry(self)
			result.DoClick = function()
				result:SelectResult()
			end
			resultYPos = resultYPos + result:GetTall()
			resultsHeight = resultsHeight + result:GetTall() + ( yPad )
			table.insert(self.resultPanels, result)
			count = count + 1
		end
		self.resultsPanel:SetTall(resultsHeight - yPad + 8)
	end
	self:SetResultKeyboard(true)
	self.resultTime = CurTime()
end

function PANEL:Think()
	if IsValid(self) and self.HandleFlash then
		self:HandleFlash()
	end 
	if input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT) then
		local hoverPanel = vgui.GetHoveredPanel()
		if not IsValid(hoverPanel) or hoverPanel:GetClassName() != "DCONFIG2SearchResult" then
			timer.Create("dconfig2_search_clear", .01, 1, function()
				if not IsValid(self) then return end
				self:ClearResults()
			end)
		end
	end
	if not self.resultTime or CurTime() < self.resultTime + .3 then return end

	if self.resultPanels and table.Count(self.resultPanels) > 0 and not IsValid(self.searchingNotice) then
		if input.IsKeyDown(KEY_ENTER) or input.IsKeyDown(KEY_PAD_ENTER) then
			for k,v in ipairs(self.resultPanels) do
				if not IsValid(v) then self.resultPanels[k] = nil continue end
				v:SelectResult()
				self:ClearResults()
				return
			end
		end
	end
end

function PANEL:SetResultKeyboard(active)
	if not self.resultPanels then return end

	for k,v in ipairs(self.resultPanels) do
		if not IsValid(v) then continue end
		v:SetKeyBoardInputEnabled(active)
		if active then
			v:MakePopup()
		end
	end
	if active and IsValid(self.searchingNotice) then
		self.searchingNotice:Remove()
	end
end

function PANEL:OnRemove()
	self:ClearResults()
end

function PANEL:ClearResults()
	self:SquareBottom(false)
	self:RemoveResultPanel()
	if IsValid(self.searchingNotice) then
		self.searchingNotice:Remove()
	end
	if self.resultPanels then
		for k,v in ipairs(self.resultPanels) do
			v:Remove()
			self.resultPanels[k] = nil
		end
	end
end

function PANEL:RemoveResultPanel()
	if IsValid(self.resultsPanel) then
		self.resultsPanel:Remove()
	end 
end

derma.DefineControl("DCONFIG2TextEntrySearch", "DCONFIG2 SearchTextEntry", PANEL, "DCONFIG2TextEntry")

local PANEL = {}

function PANEL:Init()
	self.theme = DCONFIG2.GetTheme()
	self:SetText("")
	self.header = "Result"
	self.sub = "Additional Info"
	self.value = ""
end

function PANEL:SetTextEntry(entry)
	self.entry = entry
end

function PANEL:SetHeaderText(str)
	self.header = str
end

function PANEL:SetSubText(str)
	self.sub = str
end

function PANEL:SetValueText(str)
	str = string.gsub(str, "\n", "")
	str = string.gsub(str, "    ", " ")
	self.value = str
end

function PANEL:SelectResult()
	local body = DCONFIG2.GetBody()
	if not body then return end
	if not IsValid(body.editorPanel) then return end
	if IsValid(body.editorPanel.scroll) then
		DCONFIG2.PlaySound("click")
		local option = body.editorPanel.options[self.optionData.key]
		body.editorPanel.scroll:ScrollToChild(option)
		option:Flash()
		if option.locked then return end
		option:RequestFocus()
		self.entry:ClearResults()
		self.entry:SetValue("")
	end
end

local infoMaterial = Material("dconfig/info.png")
function PANEL:Paint(w,h)
	--surface.SetDrawColor(self.theme.theme)
	--surface.DrawRect(0,0,w,h)
	--surface.SetDrawColor(self.theme.panel)
	--surface.DrawRect(1,1,w - 2,h - 2)
	draw.RoundedBox(0, 0, 0, w, h, self.theme.panel)
	if self:IsHovered() then
		draw.RoundedBox(0, 2, 2, w - 4, h - 4, self.theme.hoverHighlight)
	end
	local iconSize = ScrH() * .02
	surface.SetMaterial(infoMaterial)
	surface.SetDrawColor(self.theme.subtitletext)
	surface.DrawTexturedRect(w * .02, h * .5 - iconSize * .5, iconSize, iconSize)
	local titleY = h * .3
	local subY = h * .7
	local subFont = DCONFIG2.Font(14)
	if self.value != "" then
		titleY = h * .25
		subY = h * .75
		surface.SetFont(subFont)
		local textW = surface.GetTextSize("Value: ")
		draw.SimpleText("Value: ", subFont, w * .04 + iconSize, h * .5, self.theme.subtitletext, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText(self.value, DCONFIG2.Font(14), w * .04 + iconSize + textW, h * .5, self.theme.theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	draw.SimpleText(self.header, DCONFIG2.Font(22), w * .04 + iconSize, titleY, self.theme.titletext, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText(self.sub, subFont, w * .04 + iconSize, subY, self.theme.subtitletext, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

derma.DefineControl("DCONFIG2SearchResult", "DCONFIG2 Result", PANEL, "DButton")
