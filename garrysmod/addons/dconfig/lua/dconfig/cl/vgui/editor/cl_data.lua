
net.Receive("dconfig2_requestBackups", function()
	local length = net.ReadUInt(32)
	local compressedData = net.ReadData(length)
	local backups = util.JSONToTable(util.Decompress(compressedData))
	local refresh = net.ReadBool()
	DCONFIG2.Data.Backups = backups
	if refresh then
		DCONFIG2.OpenData(true)
	end
end)

hook.Add("InitPostEntity", "DCONFIG2_RequestBackups", function()
	net.Start("dconfig2_requestBackups")
	net.SendToServer()
end)

function DCONFIG2.AttemptDeleteSave(dir)
    if not dir then return end

    net.Start("dconfig2_deleteSaveData")
    net.WriteString(dir)
    net.SendToServer()
end

function DCONFIG2.AttemptRestoreSave(dir)
    if not dir then return end

    net.Start("dconfig2_restoreSaveData")
    net.WriteString(dir)
    net.SendToServer()
end

function DCONFIG2.OpenData(refresh)
	if not DCONFIG2.IsBodyAvailable() then return end

	local body = DCONFIG2.GetBody()
	if not body then return end
	if refresh and IsValid(body.dataMenu) then
		body.dataMenu:Remove()
		body.dataMenu = body:Add("DCONFIG2Data")
		body.dataMenu:Dock(FILL)
	elseif not refresh then
		body.dataMenu = body:Add("DCONFIG2Data")
		body.dataMenu:Dock(FILL)
	end

end


net.Receive("dconfig2_sendRestart", function()
    local restartTime = net.ReadUInt(32)
    local ply = net.ReadEntity()
    local name = string.upper(ply:Name())
    local text = name .. " IS RESTARTING THE SERVER"
    hook.Add("HUDPaint", "DConfig2_RestartNotice", function()
        local theme = DCONFIG2.GetTheme()
        local scrw, scrh = DCONFIG2.ScrW, DCONFIG2.ScrH
        local h = scrh * .09
        surface.SetFont(DCONFIG2.Font(32))
        local w = surface.GetTextSize(text) + scrw * .02
        local x,y = scrw * .5 - w * .5, scrh * .02
        draw.RoundedBox(10, x, y, w, h, theme.body)
        surface.SetAlphaMultiplier(math.sin(CurTime() * 3) + 1)
        draw.SimpleText(text, DCONFIG2.Font(32), scrw * .5, y + h * .3, theme.titletext, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetAlphaMultiplier(1)
        draw.SimpleText(math.Round(restartTime - CurTime()) .. "s", DCONFIG2.Font(32), scrw * .5, y + h * .6, theme.subtitletext, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end)
end)


local function StartRestore(dir)
    local saveDir = "data/" .. DCONFIG2.Data.SaveDir .. "/saves/" .. dir
    local prompt = DCONFIG2.ConfirmationPrompt {
        title = "Are you sure you want to restore this save?",
        message = "Your server will require a restart / map change immediately after. This action is irreversible. Your current jobs, shipments, ammo, etc will be overwritten and replaced with this save data. Location: " .. saveDir,
        confirmCallback = function(amt)
            local finalPrompt = DCONFIG2.ConfirmationPrompt {
                title = "Are you ready to restart your server?",
                message = "The following save data will be restored after a map restart. Location: " .. saveDir,
                confirmCallback = function(amt)
                    DCONFIG2.AttemptRestoreSave(dir)
                end,
                cancelCallback = function()
                    
                end,
                confirm = "Restart & Restore.",
                cancel = "Cancel Restore",
            }
        end,
        cancelCallback = function()

        end,
    }
end

local PANEL = {}



function PANEL:Init()
	self.backupCount = table.Count(DCONFIG2.Data.Backups)
	local scrw,scrh = ScrW(), ScrH()
	local xPadding = scrw * .01
	local yPadding = scrh * .01
	local theme = DCONFIG2.GetTheme()
	self.titlePanel = self:Add("DPanel")
	self.titlePanel:Dock(TOP)
	self.titlePanel.Paint = function(me,w,h)
		draw.SimpleText("Data Management", DCONFIG2.Font(36), w * .5, h * .3, theme.titletext, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Here you can create Backups, Restore and Delete Data.", DCONFIG2.Font(22), w * .5, h * .6, theme.subtitletext, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.scroll = self:Add("DCONFIG2ScrollBar")
	self.scroll:Dock(TOP)
	self.buttonPanel = self.scroll:Add("DPanel")
	self.buttonPanel:Dock(TOP)
	self.buttonPanel:DockMargin(xPadding, yPadding, xPadding, 0)
	self.buttonPanel.Paint = nil

	self.createBackup = self.buttonPanel:Add("DCONFIG2Button")
	self.createBackup:Dock(LEFT)
	self.createBackup:SetText("Create Backup")

	self.importDConfig = self.buttonPanel:Add("DCONFIG2Button")
	self.importDConfig:Dock(LEFT)
	self.importDConfig:SetText("Import DConfig 1 Data")
	self.importDConfig:DockMargin(xPadding, 0, 0, 0)

	self.deleteActiveData = self.buttonPanel:Add("DCONFIG2Button")
	self.deleteActiveData:Dock(RIGHT)
	self.deleteActiveData:SetText("Delete Current Data")
	self.deleteActiveData:DockMargin(xPadding, 0, 0, 0)

	if self.backupCount < 1 then
		self.noBackups = self.scroll:Add("DPanel")
		self.noBackups:Dock(TOP)
		self.noBackups:DockMargin(xPadding, yPadding, xPadding, 0)
		self.noBackups.Paint = function(me,w,h)
			draw.RoundedBox(20, 0, 0, w, h, theme.panel)
			draw.SimpleText("The server has no back ups. Try creating one now.", DCONFIG2.Font(20), xPadding, h * .5, theme.subtitletext, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end
	DCONFIG2.PaintScrollBar(self.scroll)

	self.options = {}
	local count = 1

	for directory, _ in pairs(DCONFIG2.Data.Backups) do
		local optionPanel = self.scroll:Add("DCONFIG2DataOption")
		optionPanel:Dock(TOP)
		optionPanel:SetDirectory(directory)
		optionPanel:DockMargin(xPadding, yPadding, xPadding, 0)
		self.options[count] = optionPanel
		count = count + 1
	end
	self.createBackup.DoClick = function()
        local prompt = DCONFIG2.StringPrompt {
            title = "Name This Backup.",
            message = "Back up names must be unique.",
            confirmCallback = function(str)
                self:CreateBackup(str)
            end,
            cancelCallback = function()

            end,
            defaultText = DCONFIG2.GetDefaultBackupTitle(),
        }
		--self:CreateBackup()
	end
	self.importDConfig.DoClick = function()
		self:ImportDConfig()
	end
	self.deleteActiveData.DoClick = function()
		self:DeleteActiveData()
	end
end

function PANEL:OnSizeChanged(w,h)
	local scrw,scrh = ScrW(), ScrH()
	self.titlePanel:SetTall(h * .1)
	self.scroll:SetTall(h * .9)
	for k,v in ipairs(self.options) do
		v:SetTall(h * .04)
	end
	if IsValid(self.importDConfig) then
		self.buttonPanel:SetTall(h * .04)
		self.createBackup:SetWide(w * .15)
		self.importDConfig:SetWide(w * .21)
		self.deleteActiveData:SetWide(w * .2)
	end
	if IsValid(self.noBackups) then
		self.noBackups:SetTall(h * .04)
	end
end

function PANEL:CreateBackup(title)
	net.Start("dconfig2_createBackup")
    net.WriteString(title)
	net.SendToServer()
end

function PANEL:ImportDConfig()
	net.Start("dconfig2_importDConfig")
	net.SendToServer()
end

function PANEL:DeleteActiveData()
    local targetDirectory = "active"
    local saveDir = "data/" .. DCONFIG2.Data.SaveDir .. "/saves/" .. targetDirectory
    local prompt = DCONFIG2.ConfirmationPrompt {
        title = "Attention! Are you sure you want to delete your current data?",
        message = "This action is irreversible. The data will be deleted from your local storage. Location: " .. saveDir,
        confirmCallback = function()
            local finalPrompt = DCONFIG2.ConfirmationPrompt {
                title = "Are you ready to restart your server?",
                message = "The current save data for DConfig will be wiped and your server will restart. This will not impact anything hardcoded. Location: " .. saveDir,
                confirmCallback = function(amt)
                    DCONFIG2.AttemptDeleteSave(targetDirectory)
                end,
                cancelCallback = function() end,
                confirm = "Restart & Restore.",
                cancel = "Cancel Restore",
            }

        end,
        cancelCallback = function() end,
    }
end

function PANEL:Paint(w,h)
end


derma.DefineControl("DCONFIG2Data", "DCONFIG2 Data", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	self:SetText("")
	self.restore = self:Add("DButton")
	local theme = DCONFIG2.GetTheme()
	self.restore:SetText("Restore")
	self.restore:SetTextColor(theme.navtext)
	self.restore:SetFont(DCONFIG2.Font(20))
	self.restore.Paint = nil
    self.restore.DoClick = function()
        DCONFIG2.PlaySound("click")

        if not self.directory then return end
        StartRestore(self.directory)
    end 

	self.delete = self:Add("DButton")
	self.delete:SetText("Delete")
	self.delete:SetTextColor(theme.red)
	self.delete:SetFont(DCONFIG2.Font(20))
	self.delete.Paint = nil
    self.delete.DoClick = function()
        DCONFIG2.PlaySound("click")
        if not self.directory then return end

        local saveDir = "data/" .. DCONFIG2.Data.SaveDir .. "/saves/" .. self.directory
        local prompt = DCONFIG2.ConfirmationPrompt {
            title = "Attention! Are you sure you want to delete this data?",
            message = "This action is irreversible. The data will be deleted from your local storage. Location: " .. saveDir,
            confirmCallback = function(amt)
                DCONFIG2.AttemptDeleteSave(self.directory)
            end,
            cancelCallback = function()

            end,
        }
    end
end

function PANEL:OnSizeChanged(w,h)
	if IsValid(self.restore) then
		local pad = w * .025
		surface.SetFont(DCONFIG2.Font(20))
		local restoreWide = surface.GetTextSize("Restore")
		local deleteWide = surface.GetTextSize("Delete")
		self.restore:SetSize(restoreWide, h)
		self.restore:SetPos(w - restoreWide - deleteWide - pad * 1.5, 0)
		self.delete:SetSize(deleteWide, h)
		self.delete:SetPos(w - deleteWide - pad,0)
	end
end

function PANEL:SetDirectory(dir)
	self.directory = dir
end

local dataMat = Material("dconfig/data.png")
function PANEL:Paint(w,h)
	local theme = DCONFIG2.GetTheme()
	draw.RoundedBox(20, 0, 0, w, h, theme.panel)
    local iconColor = theme.theme
    local textColor = theme.titletext
	if self:IsHovered() then
		draw.RoundedBox(20, 0, 0, w, h, theme.hoverHighlight)
        iconColor = theme.selectedNavIcon or theme.theme 
        textColor = theme.selectedNavText or theme.titletext
	end
	surface.SetDrawColor(iconColor)
	surface.SetMaterial(dataMat)
	local iconSize = h * .7
	local pad = w * .025
	surface.DrawTexturedRect(pad, h * .5 - iconSize * .5, iconSize, iconSize)
	draw.SimpleText(self.directory, DCONFIG2.Font(20), pad * 1.5 + iconSize, h * .5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

local targetDirectory
function PANEL:DoClick()
    net.Start("dconfig2_viewSaveData")
    net.WriteString(self.directory)
    net.SendToServer()
    DCONFIG2.PlaySound("click")
    targetDirectory = self.directory
end 

function PANEL:OnRemove()
    if IsValid(DCONFIG2.DataViewerUI) then
        DCONFIG2.DataViewerUI:Remove()
    end
end 

bignet.receive("sendDConfig2SaveData", function(saveData)
    if IsValid(DCONFIG2.DataViewerUI) then
        DCONFIG2.DataViewerUI:Remove()
    end 
    DCONFIG2.DataViewerUI = vgui.Create("DCONFIG2DataViewer")
    local scrw,scrh = ScrW(),ScrH()
    local frameW, frameH, animTime, animDelay, animEase = scrw * .3, scrh * .6, 1, 0, .1
    DCONFIG2.DataViewerUI.isAnimating = true
    DCONFIG2.DataViewerUI:SetSize(0, 0)
    DCONFIG2.DataViewerUI:SizeTo(frameW, frameH, animTime, animDelay, animEase, function()
        DCONFIG2.DataViewerUI.isAnimating = false
    end)
    DCONFIG2.DataViewerUI:SetDirectory(targetDirectory)
    DCONFIG2.DataViewerUI:SetData(saveData)
end)

derma.DefineControl("DCONFIG2DataOption", "DCONFIG2 DataOption", PANEL, "DButton")

local PANEL = {}

function PANEL:Init()
    self.yPadding = ScrH() * .01
    self.xPadding = ScrW() * .02
    self:SetTitle("")
    self:MakePopup()
    self:SetSize(0,0)
    self:DockPadding(0,0,0,0)
    self:ShowCloseButton(false)
    
    self.title = self:Add("DPanel")
    self.title:Dock(TOP)
    self.title.Paint = function(me,w,h)
        local theme = DCONFIG2.GetTheme()
        draw.SimpleText(string.upper(self.directory), DCONFIG2.Font(20), w * .5, h * .5, theme.titletext, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    self.title:DockMargin(self.xPadding, self.yPadding, self.xPadding, self.yPadding)
    self.scroll = self:Add("DCONFIG2ScrollBar")
    self.scroll:Dock(FILL)
    self.scroll:DockMargin(0, 0, 0, self.yPadding)
    DCONFIG2.PaintScrollBar(self.scroll)

    local buttonXPad =  ScrW() * .02
    self.close = self:Add("DCONFIG2Button")
    self.close:Dock(BOTTOM)
    self.close:DockMargin(buttonXPad, 0, buttonXPad, self.yPadding)
    self.close:SetText("Close")
    self.close.DoClick = function()
        self:Remove()
    end 
    
    self.delete = self:Add("DCONFIG2Button")
    self.delete:Dock(BOTTOM)
    self.delete:DockMargin(buttonXPad, 0, buttonXPad, self.yPadding)
    self.delete:SetText("Delete Data")
    self.delete.DoClick = function()
        local saveDir = "data/" .. DCONFIG2.Data.SaveDir .. "/saves/" .. targetDirectory
        local prompt = DCONFIG2.ConfirmationPrompt {
            title = "Attention! Are you sure you want to delete this data?",
            message = "This action is irreversible. The data will be deleted from your local storage. Location: " .. saveDir,
            confirmCallback = function(amt)
                DCONFIG2.AttemptDeleteSave(targetDirectory)
                self:Remove()
            end,
            cancelCallback = function()

            end,
        }
    end


    self.restore = self:Add("DCONFIG2Button")
    self.restore:Dock(BOTTOM)
    self.restore:DockMargin(buttonXPad, 0, buttonXPad, self.yPadding)
    self.restore:SetText("Restore Data")
    self.restore.DoClick = function()
        StartRestore(targetDirectory)
    end

end

function PANEL:OnSizeChanged(w,h)
    if self.isAnimating then
        self:Center()
    end 
    if self.dataTypes then
        for k,v in pairs(self.dataTypes) do
            v:SetTall(h * .05)
        end 
    end 
    if self.restore then
        self.restore:SetTall(h * .05)
    end 
    if self.delete then
        self.delete:SetTall(h * .05)
    end 
    if self.close then
        self.close:SetTall(h * .05)
    end 
end 

function PANEL:SetDirectory(dir)
    self.directory = dir or "Unknown Directory"
end 

local orderedTypes = {
    "jobs",
    "entities",
    "shipments",
    "ammo",
    "categories",
    "doorgroups",
}

function PANEL:SetData(data)
    self.data = data
    self.dataTypes = {}

    for _,dataType in ipairs(orderedTypes) do
        local dataContent = self.data[dataType]

        if not dataContent or dataType == "settings" then continue end

        self.dataTypes[dataType] = self.scroll:Add("DPanel")
        local titlePanel = self.dataTypes[dataType]
        titlePanel:Dock(TOP)
        titlePanel.Paint = function(me,w,h)
            local theme = DCONFIG2.GetTheme()
            --draw.RoundedBox(20, 0, 0, w, h, theme.panel)        
            draw.SimpleText(string.upper(dataType), DCONFIG2.Font(20), 0, h * .5, theme.titletext, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("" .. table.Count(dataContent) .. "", DCONFIG2.Font(20), w, h * .5, theme.titletext, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            surface.SetDrawColor(theme.titletext)
            surface.DrawRect(0, h - 1, w, 1)
        end
        titlePanel:DockMargin(self.xPadding, 0, self.xPadding, self.yPadding)
        for k, v in ipairs(dataContent) do
            self.dataTypes[dataType][k] = self.scroll:Add("DPanel")
            local contentPanel = self.dataTypes[dataType][k]
            contentPanel:Dock(TOP)
            contentPanel:DockMargin(self.xPadding, 0, self.xPadding, self.yPadding)
            if dataType != "doorgroups" and type(v) == "table" then
                v = v[1] or v
            end
            local extraInfo = v.price and DarkRP.formatMoney(v.price) or v.category or v.categorises or "none"
            if dataType == "doorgroups" then
                local count = 0
                for k,v in pairs(v) do
                    if type(v) == "number" then
                        count = count + 1
                    end 
                end 
                extraInfo = count .. " Job" .. (count > 1 and "s." or ".")
            end 
            contentPanel.Paint = function(me,w,h)
                local theme = DCONFIG2.GetTheme()
                --draw.RoundedBox(20, 0, 0, w, h, theme.panel)        
                draw.SimpleText( (v.name or "none") .. " - " .. extraInfo, DCONFIG2.Font(18), 0, h * .5, theme.subtitletext, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end 
    end
end 

function PANEL:Paint(w,h)
	local theme = DCONFIG2.GetTheme()
    --surface.SetAlphaMultiplier(.9)
	--draw.RoundedBox(20, 0, 0, w, h, theme.body)
    --surface.SetAlphaMultiplier(1)
	draw.RoundedBox(20, 0, 0, w, h, theme.theme)
	draw.RoundedBox(20, 2, 2, w - 4, h - 4, theme.body)
    if table.Count(self.dataTypes) < 1 then
        draw.SimpleText("No Data Found.", DCONFIG2.Font(24), w * .5, h * .1, theme.red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end 
end


function PANEL:OnFocusChanged()
	--self:MoveToFront()
	--timer.Simple(0, function()
	--	if IsValid(self) then
	--		self:MoveToFront()
	--	end
	--end)
end


derma.DefineControl("DCONFIG2DataViewer", "DCONFIG2 Data Viewer", PANEL, "DFrame")

