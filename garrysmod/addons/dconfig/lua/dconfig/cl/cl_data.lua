bignet.receive("sendDConfig2Data", function(sentData)
    local dataType = sentData.dataType
    local data = sentData.data
    local fileInfo = DCONFIG2.Data.FileManager[dataType]
	if not fileInfo then
		DCONFIG2.MsgC("An Internal Loading Error has occured. Please create a support ticket. Load Key: " .. dataType, true)
		return
    end
    if fileInfo.loadEntry then 
        for k,v in pairs(data) do
            fileInfo.loadEntry(v, true)
            hook.Run("DConfig2PostLoadDataEntry", dataType, dataEntry)
        end
    elseif fileInfo.loadBulk then
        fileInfo.loadBulk(data)
    end 
end)

bignet.receive("sendDConfig2FullData", function(sentData)
    for dataType,bulkData in pairs(sentData) do 
        local fileInfo = DCONFIG2.Data.FileManager[dataType]
        if not fileInfo then
            DCONFIG2.MsgC("An Internal Loading Error has occured. Please create a support ticket. Load Key: " .. dataType, true)
            continue
        end
        if fileInfo.loadEntry then 

            for k,dataEntry in pairs(bulkData) do
                if fileInfo.shouldLoadEntry and not fileInfo.shouldLoadEntry(dataEntry) then
                    DCONFIG2.MsgC("Skipping loading of a data entry: " .. DCONFIG2.GetEntryName(dataEntry))
                    continue
                end
                fileInfo.loadEntry(dataEntry, true)
                hook.Run("DConfig2PostLoadDataEntry", dataType, dataEntry)
            end
        elseif fileInfo.loadBulk then
            fileInfo.loadBulk(bulkData)
        end 
        hook.Run("DConfig2PostLoadDataType", dataType)
    end
end)

net.Receive("dconfig2_saveEditor", function()
	local editorType = net.ReadString()
	local length = net.ReadUInt(32)
	local compressedData = net.ReadData(length)
    local saveData = util.JSONToTable(util.Decompress(compressedData))
    if LocalPlayer() == fromPly then return end

	local saveMethod = DCONFIG2.Editor.Saving[editorType]
    local fromPly = net.ReadEntity()

	if saveMethod then
		local data = saveMethod(saveData)
		if not data.success then
            DCONFIG2.MsgC("An Internal Networking Error has occured.")
		end
        hook.Run("DConfig2ContentSaved", editorType, saveData, data.success)
    else
        DCONFIG2.MsgC("A Logic Error has occured.")
	end
end)


net.Receive("dconfig2_deleteContent", function()
	local editorType = net.ReadString()
	local length = net.ReadUInt(32)
	local compressedData = net.ReadData(length)
    local fromPly = net.ReadEntity()

    local contentData = util.JSONToTable(util.Decompress(compressedData))
	local deleteMethod = DCONFIG2.Editor.Deleting[editorType]

    if deleteMethod then
        hook.Run("DConfig2ContentDeleted", editorType, contentData)
        if LocalPlayer() == fromPly then return end
        deleteMethod(contentData)
	end
end)

net.Receive("dconfig2_resetContent", function()
	local editorType = net.ReadString()
	local length = net.ReadUInt(32)
	local compressedData = net.ReadData(length)
    
    local contentData = util.JSONToTable(util.Decompress(compressedData))
	local resetMethod = DCONFIG2.Editor.Resetting[editorType]

    if resetMethod then
        hook.Run("DConfig2ContentReset", editorType, contentData)
        if LocalPlayer() == fromPly then return end
		resetMethod(contentData)
	end
end)

net.Receive("dconfig2_downloadVault", function()
	local ignoreTbl = net.ReadTable()
	local category = net.ReadString()
	local dataID = net.ReadUInt(8)
	DCONFIG2.DownloadVaultFromNetwork(ignoreTbl, category, dataID)
end)

hook.Add("InitPostEntity", "RequestDConfig2Data", function()
    net.Start("dconfig2_requestData")
    net.SendToServer()
end)

hook.Add("DConfig2PostLoadDataType", "RequestDoorGroups", function(dataType)
    if dataType == "doorgroups" then
        net.Start("dconfig2_syncDoorgroups")
        net.SendToServer()
    end 
end)



local function RefreshF4Menus()
    if emenu then
        if IsValid(emenu.bg) then
            DCONFIG2.MsgC("DCONFIG2 REFRESHED EMENU F4 MENU!")
            emenu:Remove()
        end
    end
    if F4menu and F4menu.frame then
        F4menu.frame:SetMouseInputEnabled( false )
        F4menu.frame:SetKeyboardInputEnabled( false )
        F4menu.frame:Remove()
        F4menu.frame = nil
        DCONFIG2.MsgC("DCONFIG2 REFRESHED PARALAX F4 MENU!")
    end
    if arivia and arivia.pnl and arivia.pnl.root then
        arivia.pnl.root:UpdateTabs()
        DCONFIG2.MsgC("DCONFIG2 REFRESHED ARIVIA F4 MENU!")
    end
    if F4Menu and F4Menu.Frame and F4Menu.Config and F4Menu.Config.RebuildJobsOnOpen then
        F4Menu.Frame:Remove()
        DCONFIG2.MsgC("DCONFIG2 REFRESHED XENIN F4 MENU!")
    end 
end

hook.Add("DConfig2ContentSaved", "UnsupportedF4MenuRefresh", RefreshF4Menus)
hook.Add("DConfig2ContentDeleted", "UnsupportedF4MenuRefresh", RefreshF4Menus)
hook.Add("DConfig2ContentReset", "UnsupportedF4MenuRefresh", RefreshF4Menus)
