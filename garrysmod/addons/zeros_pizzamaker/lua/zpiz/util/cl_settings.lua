/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

if not CLIENT then return end

hook.Add("AddToolMenuCategories", "zpiz_CreateCategories", function()
	spawnmenu.AddToolCategory("Options", "zpiz_options", "PizzaMaker")
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 02d4e064402d16696deab5b093c9a34ae7a407e6165a08b9f87e1e597f153041
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

hook.Add("PopulateToolMenu", "zpiz_PopulateMenus", function()
	spawnmenu.AddToolMenuOption("Options", "zpiz_options", "zpiz_Admin_Settings", "Admin Settings", "", "", function(CPanel)
		zclib.Settings.OptionPanel("Public Setup", nil, Color(179, 135, 84, 255), zclib.colors["ui02"], CPanel, {
			[1] = {
				name = "Save",
				class = "DButton",
				cmd = "zpiz_save"
			},
			[2] = {
				name = "Remove",
				class = "DButton",
				cmd = "zpiz_remove"
			}
		})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

		zclib.Settings.OptionPanel("Pizza", nil, Color(179, 135, 84, 255), zclib.colors["ui02"], CPanel, {
			[1] = {
				name = "Spawn All",
				class = "DButton",
				cmd = "zpiz_pizza_all"
			},
		})
	end)

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350945
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 02d4e064402d16696deab5b093c9a34ae7a407e6165a08b9f87e1e597f153041

end)
