DCONFIG2.Editor.OnSave("categories", function(saveData)
	local success = DCONFIG2.AddCustomCategory(saveData)
	local msg = "Successfully Saved " .. saveData.name .. " - Categorises " .. saveData.categorises .. ""
	if not success then
		return {success = false, msg = "Failed to create category."}
	end
	return {success = true, msg = msg, icon = "dconfig/category.png", refresh = true}
end)

DCONFIG2.Editor.OnDelete("categories", function(contentData)
	local success = DCONFIG2.RemoveCategory(contentData)
	// print(success)
	local msg = "Successfully Deleted " .. contentData.name .. " - Categorises " .. contentData.categorises .. ""
	if not success then
		return {success = false, msg = "Failed to delete category."}
	end
	return {success = true, msg = msg, icon = "dconfig/category.png", refresh = true}
end)

DCONFIG2.Editor.OnReset("categories", function(contentData)
	local success = DCONFIG2.ResetCategory(contentData)
	local msg = "Successfully Reset " .. contentData.name
	if not success then
		return {success = false, msg = "Failed to reset category."}
	end
	return {success = true, msg = msg, icon = "dconfig/category.png", refresh = true}
end)

local ignoreVals = {
	["dconfig"] = true,
	["updateTime"] = true,
}

DCONFIG2.Editor.OnExport("categories", function(contentData)
	local codeStr = DCONFIG2.FormatExport(contentData)
	codeStr = 'DarkRP.createCategory({ \n'.. codeStr
	print(codeStr)
	SetClipboardText(codeStr)
	return {success = true, msg = "Successfully copied category code to clipboard.", icon = "dconfig/category.png", refresh = true}
end)

DCONFIG2.Editor.Options["categories"] = {}

DCONFIG2.AddUpdateInfo("categories")

DCONFIG2.Editor.AddOption("categories", {
	name = "Category Name",
	description = "The name of the category.",
	key = "name",
	type = "string",
	required = true,
})

DCONFIG2.Editor.AddOption("categories", {
	name = "Categorises",
	description = "Select a category to categorise.",
	key = "categorises",
	type = "list",
	required = true,
	getlist = function()
		return {"jobs", "shipments", "ammo", "entities", "vehicles"}
	end,
})


DCONFIG2.Editor.AddOption("categories", {
	name = "Color",
	description = "The color of the category. ( Some F4 menus do not support this feature )",
	key = "color",
	type = "color",
	required = false,
	default = Color(255,255,255),
})


DCONFIG2.Editor.AddOption("categories", {
	name = "Sort Order",
	description = "The position of the category in relation to other categories. The lower the number, the higher the position.",
	key = "sortOrder",
	type = "number",
	required = false,
	default = 1,
})

DCONFIG2.Editor.AddOption("categories", {
	name = "Start Expanded",
	description = "Should this category start expanded? ( Some F4 menus do not support this feature )",
	key = "startExpanded",
	type = "boolean",
	required = false,
	default = true,
})


