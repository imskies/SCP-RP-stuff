
DCONFIG2.Editor = DCONFIG2.Editor or {}
DCONFIG2.Editor.Options = {}
DCONFIG2.Editor.Saving = DCONFIG2.Editor.Saving or {}
DCONFIG2.Editor.Exporting = DCONFIG2.Editor.Exporting or {}
DCONFIG2.Editor.Deleting = DCONFIG2.Editor.Deleting or {}
DCONFIG2.Editor.Resetting = DCONFIG2.Editor.Resetting or {}
DCONFIG2.Editor.Sorting = DCONFIG2.Editor.Sorting or {}
DCONFIG2.Editor.LoadingKeys = DCONFIG2.Editor.LoadingKeys or {}

function DCONFIG2.Editor.AddOption(editor, data)
	local key = data.key
	local ignore = data.ignore
	DCONFIG2.Editor.Options[editor] = DCONFIG2.Editor.Options[editor] or {}
	if not ignore then
		for k,v in ipairs(DCONFIG2.Editor.Options[editor]) do
			if v.key == key then
				DCONFIG2.Editor.Options[editor][k] = nil
			end
		end
	end
	table.insert(DCONFIG2.Editor.Options[editor], data)
end

function DCONFIG2.Editor.OnSave(editor, callback)
	DCONFIG2.Editor.Saving[editor] = callback
end

function DCONFIG2.Editor.OnDelete(editor, callback)
	DCONFIG2.Editor.Deleting[editor] = callback
end 

function DCONFIG2.Editor.OnReset(editor, callback)
	DCONFIG2.Editor.Resetting[editor] = callback
end 

function DCONFIG2.Editor.OnExport(editor, callback)
	DCONFIG2.Editor.Exporting[editor] = callback
end 

function DCONFIG2.Editor.LoadKeys(editor, callback)
	--Overwrites format load. Does not work on options that have content data
	DCONFIG2.Editor.LoadingKeys[editor] = callback
end

function DCONFIG2.Editor.Sort(editor, callback)
	DCONFIG2.Editor.Sorting[editor] = callback
end

function DCONFIG2.FormatKey(key)
	local keyType = type(key)
	if keyType == "number" then
		return "[" .. key .. "]"
	end
	return key
end


local TAB = "    "
local DOUBLE_TAB = TAB .. TAB
function DCONFIG2.FormatExport(exportData, ignoreVals, formatVals)
	ignoreVals = ignoreVals or {}
	formatVals = formatVals or {}
	formatVals.color = function(val)
		return {
			key = "color",
			val = "Color(" .. val.r .. ", " .. val.g .. ", " .. val.b .. ", " .. val.a .. ")",
		}
	end 
	local codeStr = ""
	for baseKey,baseVal in pairs(exportData) do
		if ignoreVals[baseKey] then continue end

		local printVal = baseVal
		local valType = type(baseVal)
		if valType == "function" then continue end

		printVal = formatVals[baseVal] or valType == "boolean" and tostring(baseVal) or valType == "string" and  '"' .. baseVal .. '"' or baseVal
		if valType != "table" then
			local newData = formatVals[baseKey] and formatVals[baseKey](baseVal) or {}
			newKey, newVal = newData.key, newData.val
			codeStr = codeStr .. TAB .. DCONFIG2.FormatKey(newKey or baseKey) .. " = " .. (newVal or printVal) .. ", \n"
		elseif valType == "table" then
			local newData = formatVals[baseKey] and formatVals[baseKey](baseVal) or nil
			if newData then
				codeStr = codeStr .. TAB .. DCONFIG2.FormatKey(baseKey) .. " = " .. (newData.val) .. ", \n"
				continue
			end
			codeStr = codeStr .. TAB .. baseKey .. " = { \n"
			for subKey,subVal in pairs(baseVal) do
				if ignoreVals[subKey] then continue end

				local valType = type(subVal)
				local printVal = formatVals[subVal] or valType == "boolean" and tostring(subVal) or valType == "string" and  '"' .. subVal .. '"' or subVal

				codeStr = codeStr .. DOUBLE_TAB .. DCONFIG2.FormatKey(subKey) .. " = " .. printVal .. ", \n"
			end
			codeStr = codeStr .. "    },\n"
		end
	end
	codeStr = codeStr .. "})"
	return codeStr
end



function DCONFIG2.FormatAllowedStrExport(value)
	local allowed = "{\n"
	local allowedJobs = string.Split(value, ",")
	for k,v in ipairs(allowedJobs) do
		allowed = allowed .. DOUBLE_TAB .. string.Trim(v) .. ",\n"
	end
	return allowed .. TAB .. "}"
end 
