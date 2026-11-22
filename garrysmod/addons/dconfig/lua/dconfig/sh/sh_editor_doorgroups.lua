DCONFIG2.Editor.OnSave("doorgroups", function(saveData)
	local success =  DCONFIG2.AddCustomDoorgroup(saveData)
	local msg = "Successfully Saved " .. saveData.name
	if not success then
		return {success = false, msg = "Failed to create doorgroup"}
	end
	return {success = true, msg = msg, icon = "dconfig/door.png", refresh = true}
end)

DCONFIG2.Editor.OnDelete("doorgroups", function(contentData)
	local success =  DCONFIG2.RemoveDoorGroup(contentData)
	local msg = "Successfully Removed " .. contentData.name
	if not success then
		return {success = false, msg = "Failed to delete doorgroup"}
	end
	return {success = true, msg = msg, icon = "dconfig/door.png", refresh = true}
end)

DCONFIG2.Editor.OnReset("doorgroups", function(contentData)
	local success = DCONFIG2.ResetDoorGroup(contentData)
	local msg = "Successfully Reset " .. contentData.name
	if not success then
		return {success = false, msg = "Failed to reset doorgroup."}
	end
	return {success = true, msg = msg, icon = "dconfig/door.png", refresh = true}
end)

local ignoreVals = {
	["dconfig"] = true,
	["updateTime"] = true,
}

DCONFIG2.Editor.OnExport("doorgroups", function(contentData)
	local codeStr = 'AddDoorGroup("' .. contentData.name ..'", ' .. contentData.allowedStr .. ")"
	print(codeStr)
	SetClipboardText(codeStr)
	return {success = true, msg = "Successfully copied doorgroup code to clipboard.", icon = "dconfig/door.png", refresh = true}
end)

DCONFIG2.Editor.Options["doorgroups"] = {}

DCONFIG2.Editor.AddOption("doorgroups", {
	name = "Name",
	description = "The name of the doorgroup.  Names act as a unique identifier for Door Groups.",
	key = "name",
	type = "string",
	default = "MISSING NAME",
	required = true,
})


DCONFIG2.Editor.AddOption("doorgroups", {
	name = "Allowed Jobs",
	description = "Which teams have access to this door group. Example: TEAM_GUN, TEAM_BLACKMARKET",
	key = "allowed",
	type = "string",
	required = true,
	loadFormat = function(val, editorData, contentData)
		if editorData["allowedStr"] then
			return editorData["allowedStr"]
		end
        if not contentData then return end

        local tempTbl = table.Copy(contentData)
        tempTbl["name"] = nil
		return DCONFIG2.ConvertToAllowedStr( tempTbl )
	end,
	saveformat = function(val)
		return DCONFIG2.ConvertToAllowedTable( val )
	end,
	presave = function(option, saveData, formattedVal, rawVal)
		saveData["allowedStr"] = rawVal
	end,
	shoulderror = function(editorOptions, formattedVal, rawVal)
		if not rawVal or table.Count(formattedVal) < 1 then
			return true, "The team variable listed is invalid or no longer exists."
		end
		return false
	end,
})

DCONFIG2.AddAllowedSearch("doorgroups")