

local PANEL = {}

local currentOption
function DCONFIG2.GetYPadding()
	local scrh = ScrH()
	return scrh * .01
end 

function PANEL:SetOption(option, contentData)
	self.option = option
	local scrw,scrh = ScrW(),ScrH()
	local xPad = scrw * .01
	local yPad = scrh * .02
	local theme = DCONFIG2.GetTheme()
	local body = DCONFIG2.GetBody()
	local titleText = not option.lowerstring and string.upper(option.name) or option.name
	self.titleLabel = self:Add("DLabel")
	self.titleLabel:Hide()
	self.titleLabel:Dock(TOP)
	self.titleLabel:SetText(option.required and "* " .. titleText or titleText)
	self.titleText = self.titleLabel:GetValue()
	self.titleLabel:SetContentAlignment(4)
	self.titleLabel:SetFont(DCONFIG2.Font(22))
	self.titleLabel:SetTextColor(theme.titletext)
	self.titleLabel:SetAutoStretchVertical(true)

	self.descriptionLabel = self:Add("DLabel")
	self.descriptionLabel:Hide()
	self.descriptionLabel:Dock(TOP)
	self.descriptionLabel:SetText(option.description or "")
	self.descriptionLabel:SetContentAlignment(4)
	self.descriptionLabel:SetFont(DCONFIG2.Font(16))
	self.descriptionLabel:SetTextColor(theme.subtitletext)
	self.descriptionLabel:DockMargin(0, 0, 0, 0)
	self.descriptionLabel:SetAutoStretchVertical(true)
	
	self.contentPanel = self:Add("DPanel")
	self.contentPanel:Hide()
	self.contentPanel:Dock(TOP)
	self.contentPanel.Paint = nil

	if option.type == "string" or option.type == "number" or option.type == "function" then
		self.textEntry = self.contentPanel:Add("DCONFIG2TextEntry")
		self.textEntry:SetDefaultText(type(option.default) == "function" and option.default() or option.default or "")
		self.textEntry:Dock(TOP)
		self.textEntry:SetTall(body:GetTall() * .045)
		self.textEntry.OnValueChange = function(me, val)
			if option.valuechange then
				option.valuechange(val, self.editorData)
			end
		end

		if option.multiLine then
			self.textEntry:SetMultiline(true)
			self.textEntry:SetTall(self.textEntry:GetTall() * 2.5)
		end 
		if option.type == "number" then
			self.textEntry:SetNumeric(true)
		end
		self.textEntry.OnEnter = function()
			local body = DCONFIG2.GetBody()
			if not body then return end
			
			if IsValid(body.editorPanel) then
				body.editorPanel:SaveData()
			end
		end
		self.textEntry.OnFocusChanged = function(me, gained)
			if gained then
				currentOption = self
			end
		end
	end

	if option.type == "info" then
		local listToIterate = option.getlist(contentData)
		if not listToIterate then self:Remove() return end

		self.infoPanel = self.contentPanel:Add("DPanel")
		self.infoPanel:Dock(TOP)
		self.infoPanel.Paint = function(me,w,h)
			DCONFIG2.DecoratePanel(me, w, h)
		end 
		self.infoPanel.listItems = {}
		for k,listItem in ipairs(listToIterate) do
			local listItemPanel = self.infoPanel:Add("DPanel")
			listItemPanel:Dock(TOP)
			local text = listItem.title and listItem.title .. ": " .. listItem.value or listItem.value 
			listItemPanel.Paint = function(me,w,h)
				draw.SimpleText(text, DCONFIG2.Font(18), 10, h * .5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
			table.insert(self.infoPanel.listItems, listItemPanel)
		end 
		self.infoPanel:SetTall(body:GetTall() * .045 * table.Count(self.infoPanel.listItems))
		self.infoPanel.OnSizeChanged = function(me,w,h)
			for k,v in pairs(me.listItems) do
				v:SetTall(body:GetTall() * .045)
			end 
		end 
	end 

	if option.type == "list" then
		self.comboBox = self.contentPanel:Add("DCONFIG2DComboBox")
		self.comboBox:Dock(TOP)
		self.comboBox:SetValue("Choose an Option")
		for k,title in ipairs(option.getlist()) do
			self.comboBox:AddChoice(title)
		end 
		self.comboBox:SetTall(body:GetTall() * .045)
		self.comboBox:SetFont(DCONFIG2.Font(16))
		self.comboBox:SetTextColor(color_white)
	end 

	if option.type == "boolean" then

		self.checkBoxPanel = self.contentPanel:Add("DPanel")
		self.checkBoxPanel:Dock(TOP)
		self.checkBoxPanel.Paint = nil

		self.checkBox = self.checkBoxPanel:Add("DCONFIG2Checkbox")
        self.checkBox:SetValue(option.default or false)
        local tall = body:GetTall() * .03
		self.checkBox:GetParent():SetTall(tall)
		self.checkBox:SetSize(ScrW() * .035, tall)
	end
	if option.type == "slider" then

		self.slider = self.contentPanel:Add("DCONFIG2Slider")
        self.slider:SetValue(option.default)
        local tall = body:GetTall() * .03
		self.slider:Dock(TOP)
		self.slider:SetTall(body:GetTall() * .045)
		self.slider:SetMin(option.min or 0)
		self.slider:SetMax(option.max or 100)
		self.slider:SetDecimals(0)
		self.slider.OnValueChanged = function(me, val)
			if val == 0 then return end

			local decimals = me:GetDecimals()
			if decimals == 0 then
				val = math.Round(val)
			end
			if option.valuechange then
				option.valuechange(val, self.editorData)
			end
		end
	end
	if option.type == "color" then
		self.colorMixer = self.contentPanel:Add("DColorMixer")
		self.colorMixer:Dock(TOP)
		self.colorMixer:SetPalette(true)
		self.colorMixer:SetAlphaBar(true)
		self.colorMixer:SetWangs(true)
		self.colorMixer:SetColor(option.default or color_white)
		self.colorMixer:SetTall(body:GetTall() * .2)

		local previewCol = color_white
		function self.colorMixer:ValueChanged(col)
			previewCol = col
		end
		local yPad = scrh * .01
		local xPad = body:GetWide() * .6
		local previewLabel = self.contentPanel:Add("DLabel")
		previewLabel:Dock(TOP)
		previewLabel:SetFont(DCONFIG2.Font(22))
		previewLabel:SetText("PREVIEW COLOR:")
		previewLabel:SetTextColor(theme.titletext)
		previewLabel:DockMargin(0, yPad, 0, 0)

		local colorPreview = self.contentPanel:Add("DPanel")
		colorPreview:Dock(TOP)
		colorPreview:DockMargin(0, yPad, xPad, 0)
		colorPreview.Paint = function(me,w,h)
			draw.RoundedBox(10, 0, 0, w, h, previewCol)
		end
	end
	if option.type == "bodygroup" then
		local bodyGroupOptions = {}
		local playerModelPanels = {}
		timer.Simple(0, function()
			self.rebuildResults()
		end)
		local fillPanel = self.contentPanel:Add("DPanel")
		fillPanel:Dock(TOP)
		fillPanel:SetTall(body:GetTall() * .35)
		fillPanel:DockMargin(0, yPad, 0, 0)
		fillPanel.Paint = function(me,w,h)
			draw.RoundedBox(10,0,0,w,h,theme.panel)
		end

		local scroll = fillPanel:Add("DCONFIG2ScrollBar")
		scroll:Dock(TOP)
		scroll:SetTall(body:GetTall() * .35)

		local function invalidateOptions()
			for k,v in ipairs(bodyGroupOptions) do
				if not IsValid(v) then
					bodyGroupOptions[k] = nil
					continue
				end
				v:InvalidateChildren(true)
				v:InvalidateLayout(true)
				v:SizeToChildren(false, true)
			end 
		end

		DCONFIG2.PaintScrollBar(scroll)

		self.rebuildResults = function()
			self.contentPanel.selectedOptions = option.bodyGroupTool.getSelected and option.bodyGroupTool.getSelected(body, self.editorData) or {}
			for k,v in pairs(playerModelPanels) do
				v:Remove()
			end
			playerModelPanels = {}
			LocalPlayer():ChatPrint("Rebulting results " .. CurTime())

			for model,_ in pairs(self.contentPanel.selectedOptions) do
				local playerModelPanel = scroll:Add("DPanel")
				playerModelPanel:Dock(TOP)
				playerModelPanel:SetTall(body:GetTall() * .3)
				playerModelPanel:DockMargin(xPad, yPad, xPad, 0)
				playerModelPanel.Paint = function(me,w,h)
					draw.RoundedBox(10,0,0,w,h,theme.body)
					draw.RoundedBox(10, 0, 0, w, h, color_white)
					draw.RoundedBox(10, 2, 2, w - 4, h -4, theme.body)
				end
				local panelID = table.insert(playerModelPanels, playerModelPanel)

				local modelPreview = playerModelPanel:Add("DModelPanel")
				modelPreview:Dock(LEFT)
				modelPreview:SetModel(model)
				modelPreview:SetFOV(80)
				function modelPreview:LayoutEntity( Entity ) return end 
				local bodyGroupData = modelPreview.Entity:GetBodyGroups()
				if table.Count(bodyGroupData) == 1 and table.Count(bodyGroupData[1].submodels) == 1 then
					playerModelPanels[panelID] = nil
					playerModelPanel:Remove()
					modelPreview:Remove()
					continue
				end

				local oldPaint = modelPreview.Paint
				modelPreview.Paint = function(me,w,h)
					oldPaint(me,w,h)
				end

				local bodyGroupInputScroll = playerModelPanel:Add("DCONFIG2ScrollBar")
				bodyGroupInputScroll:Dock(RIGHT)
				bodyGroupInputScroll:DockMargin(xPad, yPad, xPad, yPad)
				bodyGroupInputScroll.Paint = nil
				bodyGroupInputScroll.PerformLayout = function()
					invalidateOptions()
				end 


				DCONFIG2.PaintScrollBar(bodyGroupInputScroll)

				-- TODO: RESET BODYGROUP TO SAVED VALUE IF VALUE DOES NOT EXIST.
				for i = 0, #bodyGroupData - 1 do
					local subModels = bodyGroupData[i + 1].submodels
					if table.Count(subModels) <= 1 then continue end

					local optionData = {
						key = "bodygroup" .. i,
						name = bodyGroupData[i + 1].name,
						type = "slider",
						min = 0, 
						max = table.Count(subModels) - 1,
						valuechange = function(val, editorData)
							local numberVal = tonumber(val)
							if !numberVal then return end
							
							LocalPlayer():ChatPrint("BODY GROUP ".. i .. " IS BEING SET TO " .. numberVal)
							modelPreview.Entity:SetBodygroup(i, numberVal)
						end,
					}

					local option = bodyGroupInputScroll:Add("DCONFIG2EditorOption")
					option:SetOption(optionData)
					option:Dock(TOP)
					option:DockMargin(xPad, yPad * .5, xPad, yPad * .5)
					table.insert(bodyGroupOptions, option)
				end

				playerModelPanel.OnSizeChanged = function(me,w,h)
					modelPreview:SetWide(w * .5)
					bodyGroupInputScroll:SetWide(w * .5)
				end 
			end 
		end
	end
	if option.type == "searchlist" then
		self.contentPanel.selectedOptions = {}
		local foundCount = 0
		
		timer.Simple(0, function()
			local selected = option.searchList.getSelected and option.searchList.getSelected(body, self.editorData) or {}
			self.contentPanel.selectedOptions = selected
			self.contentPanel.searchContent = option.searchList.getList(body, self.contentPanel.selectedOptions)
			self.rebuildResults()

		end)

		local searchEntry = self.contentPanel:Add("DCONFIG2TextEntry")
		searchEntry:Dock(TOP)
		searchEntry:SetTall(body:GetTall() * .05)
		searchEntry:SetDefaultText("Search")

		local fillPanel = self.contentPanel:Add("DPanel")
		fillPanel:Dock(TOP)
		fillPanel:SetTall(body:GetTall() * .4)
		fillPanel:DockMargin(0, yPad, 0, 0)
		fillPanel.Paint = function(me,w,h)
			draw.RoundedBox(10,0,0,w,h,theme.panel)
		end
		
		local configOptionList
		local scroll = fillPanel:Add("DCONFIG2ScrollBar")
		scroll:Dock(TOP)
		scroll:SetTall(body:GetTall() * .4)
		scroll.Paint = function(me,w,h)
			if foundCount == 0 then
				draw.SimpleText("0 Results.", DCONFIG2.Font(30), w * .5, h * .5, theme.titletext, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			if IsValid(configOptionList) then return end
			draw.SimpleText("Loading...", DCONFIG2.Font(30), w * .5, h * .5, theme.titletext, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end 
		DCONFIG2.PaintScrollBar(scroll)
		self.contentPanel.modelPanels = {}

		self.rebuildResults = function(searchStr)
            if not IsValid(scroll) then return end
			foundCount = 0
			searchStr = string.lower(searchStr or "")
			if IsValid(configOptionList) then
				configOptionList:Remove()
				self.contentPanel.modelPanels = {}
			end
			configOptionList = vgui.Create("DIconLayout", scroll)
			configOptionList:Dock(TOP)
			configOptionList:SetTall(body:GetTall() * .4)
			configOptionList:SetSpaceY(xPad)
			configOptionList:SetSpaceX(yPad)
			configOptionList:DockMargin(xPad, yPad, xPad, 0)

			self.contentPanel.searchContent = option.searchList.getList(body, self.contentPanel.selectedOptions)
			local isPairs = not self.contentPanel.searchContent[1]
			local loopMethod = isPairs and pairs or ipairs
			for k,data in loopMethod(self.contentPanel.searchContent) do
				local k,v = k, data
				if option.searchList.isSorted then 
					k,v = data.key, data.value
				end
				local isHovered = false
				local found = true
				local isStringVal = type(v) == "string"
				local loweredStringVal = isStringVal and string.lower(v) or v
				found = searchStr and option.searchList.isSearchFound(searchStr, k, loweredStringVal) or false 
				if found then
					foundCount = foundCount + 1
					local modelPanel = configOptionList:Add("DPanel")
					local increase = 20
					local highlight = Color(theme.body.r + increase,theme.body.g + increase,theme.body.b + increase)
					modelPanel.Paint = function(me,w,h)
						local selected = option.searchList.isSelected and option.searchList.isSelected(v, self.contentPanel.selectedOptions) or self.contentPanel.selectedOptions[v]
						if selected then
							draw.RoundedBox(10, 0, 0, w, h, color_white)
							draw.RoundedBox(10, 2, 2, w - 4, h -4, theme.body)
							draw.RoundedBox(10, 2, 2, w - 4, h - 4, highlight)
						else
							draw.RoundedBox(10, 0, 0, w, h, theme.body)
						end
						if isHovered then
							draw.RoundedBox(10, 2, 2, w - 4, h - 4, theme.hoverHighlight)
						end
					end
					local generatedModel = option.searchList.generateModel and option.searchList.generateModel(v)
					modelPanel.model = vgui.Create("SpawnIcon", modelPanel)
					modelPanel.model.path = generatedModel or option.searchList.getModel(v) or "models/weapons/w_crowbar.mdl"
					modelPanel.model:SetSize(modelPanel:GetWide() * .9, modelPanel:GetTall() * .9)
					modelPanel.model:SetModel(modelPanel.model.path)
					modelPanel.model:SetColor(color_white)
					modelPanel.model.PaintOver = function(me,w,h)
						if me:IsHovered() then
							isHovered = true
						else
							isHovered = false
						end
					end
					local labelPad = scrh * .005
					local titleLabel = modelPanel:Add("DLabel")
					titleLabel:Dock(TOP)
					titleLabel:SetText(option.searchList.getTitleLabel(k,v))
					titleLabel:SetContentAlignment(5)
					titleLabel:SetFont(DCONFIG2.Font(18))
					titleLabel:SetTextColor(theme.titletext)
					titleLabel:DockMargin(modelPanel:GetWide() * .1, labelPad, modelPanel:GetWide() * .1, 0)
					if option.searchList.getTitleColor then
						titleLabel:SetTextColor(option.searchList.getTitleColor(v))
					end 

					local subLabel = modelPanel:Add("DLabel")
					subLabel:Dock(BOTTOM)
					subLabel:SetText(option.searchList.getSubLabel(k,v))
					subLabel:SetContentAlignment(5)
					subLabel:SetFont(DCONFIG2.Font(12))
					subLabel:SetTextColor(theme.subtitletext)
					subLabel:DockMargin(modelPanel:GetWide() * .1, 0, modelPanel:GetWide() * .1, labelPad)

					modelPanel.model.DoClick = function()
						option.searchList.click(v, body, self.contentPanel, self.editorData, self.option, modelPanel.model)
						DCONFIG2.PlaySound("click")
					end
					modelPanel.model.DoRightClick = function()
						if not option.searchList.rightClick then return end
						option.searchList.rightClick(v, body, self.contentPanel, self.editorData, self.option, modelPanel.model)
					end
					self.contentPanel.modelPanels[#self.contentPanel.modelPanels + 1 or 1] = modelPanel
				end
				if IsValid(self.contentPanel.modelPanels[1]) then
					scroll:ScrollToChild(self.contentPanel.modelPanels[1])
				end
			end
			configOptionList.OnSizeChanged = function(list, w, h)
				for k,pnl in pairs(self.contentPanel.modelPanels) do
					if not IsValid(pnl) then
						self.contentPanel.modelPanels[k] = nil
						continue
					end 
					local size = math.floor(w / 7)
					pnl:SetSize(size, size)
					if IsValid(pnl.model) then
						pnl.model:SetSize(size * .7, size *.7)
						pnl.model:SetPos(pnl:GetWide() * .5 - pnl.model:GetWide() * .5, pnl:GetTall() * .5 - pnl.model:GetTall() * .5)
					end
				end
			end
			self:Show()
		end
		searchEntry.OnValueChange = function(pnl, val)
			if IsValid(configOptionList) then
				configOptionList:Remove()
				configOptionList = nil
			end
			foundCount = -1
			timer.Create("dconfig2_option_searchlist_" ..option.key, .3, 1, function()
				if not IsValid(self) then return end

				self.rebuildResults(val)
			end)
		end
	end
	self:Hide()
end

function PANEL:GetValue()
	if self.textEntry then
		local val = self.textEntry:GetValue()
		return self.textEntry:GetNumeric() and tonumber(val) or val
	end
	if self.checkBox then
		return self.checkBox:GetValue()
	end
	if self.colorMixer then
		return self.colorMixer:GetColor()
	end
	if self.comboBox then
		local textValue, dataValue = self.comboBox:GetSelected()
		local returnVal = textValue or self.comboBox:GetValue()
		if returnVal == "Choose an Option" then
			return nil
		end
		return returnVal
	end 
end

function PANEL:GetDefaultText()
	if self.textEntry then
		return self.textEntry:GetDefaultText()
	end
end

local ignore = {
	["function"] = true,
	["table"] = true,
}

function PANEL:SetValue(val)
	if val == nil then return end

    if self.colorMixer then
		self.colorMixer:SetColor(val)
    end
    if ignore[type(val)] then return end

	if self.textEntry then
		self.textEntry:SetValue(val)
	elseif self.checkBox then
		self.checkBox:SetValue(val)
	elseif self.comboBox then
		self.comboBox:SetValue(val)
	end
end

function PANEL:SetErrorText(str)
	local theme = DCONFIG2.GetTheme()
	if not IsValid(self.errorLabel) then 
		self.errorLabel = self:Add("DLabel")
		self.errorLabel:Dock(TOP)
		self.errorLabel:SetContentAlignment(4)
		self.errorLabel:SetText("")
		self.errorLabel:SetFont(DCONFIG2.Font(16))
		self.errorLabel:SetTextColor(theme.red)
		self.errorLabel:DockMargin(0, 0, 0, 0)
		self.errorLabel:SetAutoStretchVertical(true)
		self:InvalidateLayout(true)
		self:SizeToChildren(false, true)
	end
	self.errorLabel:SetText("Error: " .. str)
end

function PANEL:ClearError()
	if not IsValid(self.errorLabel) then return end
	local theme = DCONFIG2.GetTheme()
	self.errorLabel:SetText("")
end

function PANEL:SetLocked(bool, msg)
	self.locked = bool
	if self.textEntry then
		self.textEntry:SetEnabled(!bool)
	elseif self.checkBox then
		self.checkBox:SetEnabled(!bool)
	end
	local theme = DCONFIG2.GetTheme()
	if bool then
		local str = msg and " - LOCKED - " .. msg or " - LOCKED"
		str = string.upper(str)
		self.titleLabel:SetText(self.titleText .. str)
		self.titleLabel:SetTextColor(theme.red)
	else
		self.titleLabel:SetText(self.titleText)
	end
end

function PANEL:SetEditorData(editorData, contentData, optionsLookup)
	if not self.option then return end
	self.editorData = editorData
	self.optionsLookup = optionsLookup
	local formattedLoad = false
	local hasLoadFormat = self.option.loadFormat
	if contentData then
		if self.option.hardcodelock and contentData.inLuaFile then
			self:SetLocked(true, self.option.lockmessage)
		end
		local key = self.option.key
		if key and contentData[key] then
			local val = contentData[key]
			if hasLoadFormat then
				val = self.option.loadFormat(val, self.editorData, contentData)
				formattedLoad = true
			end
			self:SetValue(val)
		end
		if not formattedLoad and hasLoadFormat then
			self:SetValue(self.option.loadFormat(val, self.editorData, contentData))
			formattedLoad = true
		end
	elseif DCONFIG2.Editor.LoadingKeys[self.editorType] then
		local loadedKey = DCONFIG2.Editor.LoadingKeys[self.editorType](self.option)
		self:SetValue(loadedKey)
		formattedLoad = true
	end
	if not formattedLoad and hasLoadFormat then
		self:SetValue(self.option.loadFormat(val, self.editorData, contentData))
		formattedLoad = true
	end
	if self.option.postbuild then
		local body = DCONFIG2.GetBody()
		if not body then return end
        self.option.postbuild(body, self, self.editorData, self.option, contentData)
	end
end

function PANEL:PerformLayout(w,h)
	if not IsValid(self.contentPanel) then return end
	self.contentPanel.performedLayout = self.contentPanel.performedLayout or false 
	if not self.contentPanel.performedLayout then 
		self.contentPanel:InvalidateChildren(true)
		self.contentPanel:InvalidateLayout(true)
		self.contentPanel:SizeToChildren(false, true)
		self.contentPanel:Show()
		self.titleLabel:Show()
		self.descriptionLabel:Show()
		timer.Simple(0, function()
			if not IsValid(self) then return end
			self:Show() 
		end)
		self.contentPanel.performedLayout = true
	end
end

function PANEL:GetFormattedData()
	if not self.option.key then return end

	local data = self:GetValue()
	local formattedData
	if data == "" or data == nil then
		data = nil
		if self.option.default then
			data = type(self.option.default) == "function" and self.option.default() or self.option.default
		end
	end
	if self.option.saveformat then
		formattedData = self.option.saveformat(data)
	end
	return formattedData or data, data
end

function PANEL:Paint(w,h)
	local theme = DCONFIG2.GetTheme()
	--draw.RoundedBox(10,0,0,w,h,theme.red)
	if self.flash and self.flash > 0 then
		self.flash = self.flash - .2 * FrameTime()
		surface.SetAlphaMultiplier(self.flash - .8)
		draw.RoundedBox(10, 0, 0, w, h, not self.flashError and theme.theme or theme.red)
		surface.SetAlphaMultiplier(1)
	end
end


function PANEL:Flash()
	self.flash = 1
	self.flashError = false
end

function PANEL:FlashError()
	self.flash = 1
	self.flashError = true
end


local tabUp = true
local tabbed = false
local isTabbing = false
function PANEL:Think()
	if IsValid(self.textEntry) and self.textEntry:IsEditing() then
		isTabbing = input.IsKeyDown(KEY_TAB)
		if isTabbing and tabUp then
			tabUp = false
			if not tabbed and not tabUp then
				self:OnTab()
				tabbed = true
			end
		elseif not isTabbing then
			timer.Destroy("dconfig2_tab_initiate")
			timer.Destroy("dconfig2_tab_hold")
			tabUp = true
			tabbed = false
		end
	end
end

function PANEL:RequestFocus()
	if IsValid(self.textEntry) then
		self.textEntry:RequestFocus()
	end
end

function PANEL:OnTab()
	local ctrlTab = input.IsKeyDown(KEY_LCONTROL)
	local direction = not ctrlTab and 1 or -1
	local id = self.ID
	local target = ctrlTab and 1 or #self.optionsLookup
	for i = id + direction, target, direction do
		local option = self.optionsLookup[i]
		if not option then continue end

		if IsValid(option.textEntry) then
			local body = DCONFIG2.GetBody()

			if body and IsValid(body.editorPanel) and IsValid(body.editorPanel.scroll) then
				local vBarScroll = body.editorPanel.scroll:GetVBar():GetScroll()
				local xPos, yPos = option:GetPos()
				yPos = yPos + option:GetTall() * 2.5 * direction
				local yDistance = yPos - vBarScroll
				if yDistance > body:GetTall() or yDistance < 0 then
					body.editorPanel.scroll:ScrollToChild(option)
				end
			end
			timer.Create("dconfig2_tab_initiate", .3, 1, function()
				if isTabbing then
					timer.Create("dconfig2_tab_hold", .1, 0, function()
						currentOption:OnTab()
					end)
				end
			end)
			option:RequestFocus()
			option:Flash()
			return
		end
	end
end

derma.DefineControl("DCONFIG2EditorOption", "DCONFIG2 Editor Option", PANEL, "DPanel")

