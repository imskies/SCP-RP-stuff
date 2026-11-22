
DCONFIG2.IngameConfig = DCONFIG2.IngameConfig or {
	theme = "DConfig2",
	load_hardcoded = true,
	load_doorgroups = true,
	hints = true,
	sounds = true,
	stats_jobs = true,
	stats_shipments = true,
	stats_ammo = true,
	stats_entities = true,
	stat_save_time = 240,
	shipment_default_price = 5000,
	shipment_default_single_price = 500,
	ammo_default_price = 25,
	display_update_info = true,
}

DCONFIG2.Editor.OnSave("dconfig", function(saveData)
	local resultData = {success = true, msg = "Sucessfully Saved DConfig 2 Settings", icon = "dconfig/wrench.png", refresh = true}
	if CLIENT and IsValid(DCONFIG2.ScreenPanel) then
		if DCONFIG2.IngameConfig.theme != saveData.theme then
			DCONFIG2.Refresh(DCONFIG2.ScreenPanel.page)
		end
		DCONFIG2.IngameConfig = saveData
		return resultData
	end
	DCONFIG2.IngameConfig = saveData
	return resultData
end)

DCONFIG2.Editor.LoadKeys("dconfig", function(option)
	return DCONFIG2.IngameConfig[option.key]
end)

DCONFIG2.Editor.Options["dconfig"] = {}
DCONFIG2.Editor.AddOption("dconfig", {
	name = "Theme",
	description = "The color theme for this menu. *Warning* This will refresh the menu and apply for everyone.",
	key = "theme",
	default = "DConfig2",
	required = true,
	type = "list",
	getlist = function()
		local themes = {}
		for k,v in pairs(DCONFIG2.Config.Themes) do
			table.insert(themes, k)
		end 
		return themes
	end,
	shoulderror = function(editorOptions, val)
		local found = false
		local themes
		for theme,v in pairs(DCONFIG2.Config.Themes) do
			if not themes then
				themes = theme
			else
				themes = themes .. ", " .. theme
			end
			if theme == val then
				return false
			end
		end
		return true, "Invalid Theme! Please choose from the following: " .. themes
	end,
	loadFormat = function(val, editorData, contentData)
		return DCONFIG2.IngameConfig.theme
	end,
})

DCONFIG2.Editor.AddOption("dconfig", {
	name = "Stats Autosave Time",
	description = "How long in seconds between stats autosave time. Recommended around 5 minutes.",
	key = "stat_save_time",
	type = "number",
	default = DCONFIG2.IngameConfig.stat_save_time,
})

DCONFIG2.Editor.AddOption("dconfig", {
	name = "Default Shipment Single Price",
	description = "Sets the default single price DConfig will display for the shipment editor.",
	key = "shipment_default_single_price",
	type = "number",
	default = DCONFIG2.IngameConfig.shipment_default_single_price,
})

DCONFIG2.Editor.AddOption("dconfig", {
	name = "Default Shipment Price",
	description = "Sets the default price DConfig will display for the shipment editor.",
	key = "shipment_default_price",
	type = "number",
	default = DCONFIG2.IngameConfig.shipment_default_price,
})

DCONFIG2.Editor.AddOption("dconfig", {
	name = "Default Ammo Price",
	description = "Sets the default price DConfig will display for the ammo editor.",
	key = "ammo_default_price",
	type = "number",
	default = DCONFIG2.IngameConfig.ammo_default_price,
})

DCONFIG2.Editor.AddOption("dconfig", {
	name = "Track Job Stats",
	description = "Enable/Disable Tracking of Job Stats.",
	key = "stats_jobs",
	type = "boolean",
	default = DCONFIG2.IngameConfig.stats_jobs,
})

DCONFIG2.Editor.AddOption("dconfig", {
	name = "Track Shipment Stats",
	description = "Enable/Disable Tracking of Shipment Stats.",
	key = "stats_shipments",
	type = "boolean",
	default = DCONFIG2.IngameConfig.stats_shipments,
})

DCONFIG2.Editor.AddOption("dconfig", {
	name = "Track Entity Stats",
	description = "Enable/Disable Tracking of Entity Stats.",
	key = "stats_entities",
	type = "boolean",
	default = DCONFIG2.IngameConfig.stats_entities,
})

DCONFIG2.Editor.AddOption("dconfig", {
	name = "Track Ammo Stats",
	description = "Enable/Disable Tracking of Ammo Stats.",
	key = "stats_ammo",
	type = "boolean",
	default = DCONFIG2.IngameConfig.stats_ammo,
})

DCONFIG2.Editor.AddOption("dconfig", {
	name = "Display Update Info",
	description = "Enable/Disable displaying of info panel that shows last update time and who updated an entry.",
	key = "display_update_info",
	type = "boolean",
	default = DCONFIG2.IngameConfig.display_update_info,
})

DCONFIG2.Editor.AddOption("dconfig", {
	name = "Display Hardcoded Data",
	description = "Enable/Disable displaying of Hardcoded Jobs, Shipments, Categories, Entities, Ammo, and Door Groups.",
	key = "load_hardcoded",
	type = "boolean",
	default = DCONFIG2.IngameConfig.load_hardcoded,
})

DCONFIG2.Editor.AddOption("dconfig", {
	name = "Load DConfig Doorgroups",
	description = "Enable/Disable loading of DConfig Doorgroup data.",
	key = "load_doorgroups",
	type = "boolean",
	default = DCONFIG2.IngameConfig.load_doorgroups,
})

DCONFIG2.Editor.AddOption("dconfig", {
	name = "Show Hints",
	description = "Enable/Disable DConfig Hint Scroller that displays useful information regarding DConfig features.",
	key = "hints",
	type = "boolean",
	default = DCONFIG2.IngameConfig.hints,
})

DCONFIG2.Editor.AddOption("dconfig", {
	name = "Play UI Sounds",
	description = "Enable/Disable DConfig UI Sound Effects.",
	key = "sounds",
	type = "boolean",
	default = DCONFIG2.IngameConfig.sounds,
})
