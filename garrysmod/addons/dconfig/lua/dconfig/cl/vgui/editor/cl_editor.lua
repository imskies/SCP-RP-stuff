
function DCONFIG2.OpenEditor(editor, contentData)
	if not DCONFIG2.IsBodyAvailable() then return end

	local body = DCONFIG2.GetBody()
	if not body then return end

	if IsValid(body.editorPanel) then
		body.editorPanel:RefreshEditor(editor, contentData)
		return
	end
	body.editorPanel = body:Add("DCONFIG2Editor")
	body.editorPanel:Dock(FILL)
	body.editorPanel:SetEditor(editor, contentData)
end

local PANEL = {}

function PANEL:Init()

	local scrw, scrh = ScrW(),ScrH()
	local theme = DCONFIG2.GetTheme()
	local body = DCONFIG2.GetBody()

	self.navigation = self:Add("DPanel")
	self.navigation:Dock(LEFT)
	self.navigation:SetWide(body:GetWide() * .25)
	self.navigation.Paint = function(me,w,h)
		surface.SetDrawColor(theme.body)
		surface.DrawRect(0,0,w,h)
	end

	self.editorBody = self:Add("DPanel")
	self.editorBody:Dock(RIGHT)
	self.editorBody:SetWide(body:GetWide() * .75)
	self.editorBody.Paint = function() end

	self.buttonPanel = self.editorBody:Add("DPanel")
	self.buttonPanel:Dock(TOP)
	self.buttonPanel.Paint = function() end
	self.buttonPanel:DockMargin(scrw * .01, scrh * .02, scrw * .01, scrh * .02)

	self.saveButton = self.buttonPanel:Add("DCONFIG2Button")
	self.saveButton:Dock(RIGHT)
	self.saveButton:SetText("Save")

	self.exportButton = self.buttonPanel:Add("DCONFIG2Button")
	self.exportButton:Dock(RIGHT)
	self.exportButton:SetText("Copy Lua")
	self.exportButton:DockMargin(0, 0, scrw * .005, 0)
	self.exportButton.DoClick = function()
		local saveData = self:SaveData(true)
		self:ExportData(saveData)
	end 
	self.saveButton.DoClick = function()
		self:SaveData()
	end

	self.searchEntry = self.buttonPanel:Add("DCONFIG2TextEntrySearch")
	self.searchEntry:SetDefaultText("Search")
	self.searchEntry:Dock(FILL)
	self.searchEntry:DockMargin(0, 0, scrw * .005, 0)
	self.searchEntry.OnValueChange = function(me, val)
		me:SearchFor(val)
	end
	self.scroll = self.editorBody:Add("DCONFIG2ScrollBar")
	self.scroll:Dock(FILL)
	DCONFIG2.PaintScrollBar(self.scroll)
	self.options = {}
end

local noExport = {
	dconfig = true,
	settings = true,
}

function PANEL:SetEditor(editor, contentData, noNav)

	if noExport[editor] and IsValid(self.exportButton) then
		self.exportButton:Remove()
	end
	local scrw, scrh = ScrW(),ScrH()
	local theme = DCONFIG2.GetTheme()
	self.contentData = contentData
	self.editor = DCONFIG2.Editor.Options[editor]
	self.editorType = editor
	if not self.editor then return end
	self.optionsOrderLookup = {}
	local loopTable = self.editor
	if DCONFIG2.Editor.Sorting[editor] then
		loopTable = DCONFIG2.Editor.Sorting[editor](loopTable)
	end
	local body = DCONFIG2.GetBody()
	for k,optionData in ipairs(loopTable) do
		local option = self.scroll:Add("DCONFIG2EditorOption")
		option:SetOption(optionData, contentData)
		option:Dock(TOP)
		option:DockMargin(scrw * .01, 0, scrw * .01, DCONFIG2.GetYPadding())
		option.editorType = editor
		option.ID = k
		self.options[optionData.key] = option
		self.optionsOrderLookup[k] = option
	end
	self.scroll.PerformLayout = function()
		for k,v in pairs(self.options) do
			if not IsValid(v) then self.options[k] = nil continue end
			
			v:InvalidateChildren(true)
			v:InvalidateLayout(true)
			v:SizeToChildren(false, true)
		end 
	end 
    if not noNav then
        DCONFIG2.PopulateEditorNavigation(self.navigation, editor, self)
    end

	for k,v in pairs(self.options) do
		v:SetEditorData(self.options, self.contentData, self.optionsOrderLookup)
	end
	self.searchEntry:SetSearchData(self.editor)

end

function PANEL:RefreshEditor(editor, contentData)
	for k,v in pairs(self.options) do
		v:Remove()
		self.options[k] = nil
	end
	self:SetEditor(editor, contentData, true)
end

function PANEL:OnSizeChanged(w,h)
	if not self.scroll then return end

	self.buttonPanel:SetTall(h * .04)
	--self.scroll:SetTall(h * .9)
	if self.saveButton then
		self.saveButton:SetWide(w * .15)
	end
	if IsValid(self.exportButton) then
		self.exportButton:SetWide(w * .15)
	end
	if IsValid(self.searchEntry) then
		self.searchEntry:SetWide(w * .4)
	end
end

function PANEL:SaveData(shouldExport)
	self.saveData = {}
	local failed = {}
	for key,option in pairs(self.options) do
		option:ClearError()
		local optionData = option.option
		if optionData.nokey then continue end

		local formattedVal,rawVal = option:GetFormattedData()
		if optionData.presave then
			optionData.presave(option, self.saveData, formattedVal, rawVal)
		end
		self.saveData[key] = formattedVal
		if optionData.required and not self.saveData[key] then
			failed[#failed + 1 or 1] = {option = option, msg = "This field is required. Please fill it in with the appropriate information."}
			continue
		end
		if optionData.shoulderror then
			local shouldError, errorMsg = optionData.shoulderror(self.options, formattedVal, rawVal)
			if shouldError then
				failed[#failed + 1 or 1] = {option = option, msg = errorMsg}
				continue
			end
		end
	end
	local targetFail
	for k,failedData in ipairs(failed) do
		failedData.option:SetErrorText(failedData.msg)
		failedData.option:FlashError()
		targetFail = failedData.option
	end
	local failCount = table.Count(failed)
	if targetFail then
		local single = failCount == 1 and true or false
		DCONFIG2.ShowPopup("There " ..(single and "is " or "are ") .. failCount .. (single and " problem" or " problems") .. " that " .. (single and "needs" or "need") .. " to be fixed!", "dconfig/close.png", 5, true)
		self.scroll:ScrollToChild(targetFail)
	end
	if failCount > 0 then return end
	
	self.saveData.updateTime = os.time()
	self.saveData.updateBy = LocalPlayer():Name()
	self.saveData.updateByID = LocalPlayer():SteamID()
	local saveMethod = DCONFIG2.Editor.Saving[self.editorType]
	if saveMethod then
		local saveData = table.Copy(self.saveData)
		if not shouldExport then 
			local data = saveMethod(self.saveData)
			if not data.success then
				DCONFIG2.ShowPopup(data.msg, "dconfig/close.png", 5, true)
				return 
			end
			-- Properties included in the data are dynamic.
			local networkData = util.Compress(util.TableToJSON(saveData))
			local length = networkData:len()
			net.Start("dconfig2_saveEditor")
			net.WriteString(self.editorType)
			net.WriteUInt(length, 32)
			net.WriteData(networkData, length)
			net.SendToServer()
			if data.success and IsValid(DCONFIG2.ScreenPanel) and IsValid(self) then
				DCONFIG2.ClearBody()
				DCONFIG2.OpenEditor(self.editorType)
			end
		end
		return saveData
	end

end

function PANEL:ExportData(saveData)
	local exportMethod = DCONFIG2.Editor.Exporting[self.editorType]
	if exportMethod and saveData then
		local data = exportMethod(saveData)
		if data.success then
			DCONFIG2.ShowPopup(data.msg, data.icon, 5, false)
			return 
		end
	end 
end

function PANEL:Paint(w,h)
	local theme = DCONFIG2.GetTheme()
	draw.RoundedBoxEx(20,0,0,w,h,theme.body,false,true,false,true)
end

derma.DefineControl("DCONFIG2Editor", "DCONFIG2 Editor", PANEL, "DPanel")
