/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if not CLIENT then return end

hook.Add("AddToolMenuCategories", "zbl_CreateCategories", function()
	spawnmenu.AddToolCategory("Options", "zbl_options", "GenLab")
end)

hook.Add("PopulateToolMenu", "zbl_PopulateMenus", function()
	spawnmenu.AddToolMenuOption("Options", "zbl_options", "zbl_Admin_Settings", "Admin Settings", "", "", function(CPanel)
		zclib.Settings.OptionPanel("NPC", nil, Color(190, 58, 80, 255), Color(55, 55, 55, 255), CPanel, {
			[1] = {
				name = "Save",
				class = "DButton",
				cmd = "zbl_save_npc"
			},
			[2] = {
				name = "Remove",
				class = "DButton",
				cmd = "zbl_remove_npc"
			}
		})

		zclib.Settings.OptionPanel("Virus HotSpots", nil, Color(190, 58, 80, 255), Color(55, 55, 55, 255), CPanel, {
			[1] = {
				name = "Save",
				class = "DButton",
				cmd = "zbl_debug_VHS_SavePos"
			},
			[2] = {
				name = "Remove",
				class = "DButton",
				cmd = "zbl_debug_VHS_RemovePos"
			}
		})

		zclib.Settings.OptionPanel("Anti Infection Zone", nil, Color(190, 58, 80, 255), Color(55, 55, 55, 255), CPanel, {
			[1] = {
				name = "Save",
				class = "DButton",
				cmd = "zbl_aiz_save"
			},
			[2] = {
				name = "Remove",
				class = "DButton",
				cmd = "zbl_aiz_remove"
			}
		})

		zclib.Settings.OptionPanel("Electric Fence", nil, Color(190, 58, 80, 255), Color(55, 55, 55, 255), CPanel, {
			[1] = {
				name = "Save",
				class = "DButton",
				cmd = "zbl_fence_save"
			},
			[2] = {
				name = "Remove",
				class = "DButton",
				cmd = "zbl_fence_remove"
			}
		})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

		zclib.Settings.OptionPanel("Info Sign", nil, Color(190, 58, 80, 255), Color(55, 55, 55, 255), CPanel, {
			[1] = {
				name = "Save",
				class = "DButton",
				cmd = "zbl_sign_save"
			},
			[2] = {
				name = "Remove",
				class = "DButton",
				cmd = "zbl_sign_remove"
			}
		})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

		zclib.Settings.OptionPanel("Lab", nil, Color(190, 58, 80, 255), Color(55, 55, 55, 255), CPanel, {
			[1] = {
				name = "Save",
				class = "DButton",
				cmd = "zbl_lab_save"
			},
			[2] = {
				name = "Remove",
				class = "DButton",
				cmd = "zbl_lab_remove"
			}
		})

		zclib.Settings.OptionPanel("Stationary Medical Unit", nil, Color(190, 58, 80, 255), Color(55, 55, 55, 255), CPanel, {
			[1] = {
				name = "Save",
				class = "DButton",
				cmd = "zbl_medicalunit_save"
			},
			[2] = {
				name = "Remove",
				class = "DButton",
				cmd = "zbl_medicalunit_remove"
			}
		})

		zclib.Settings.OptionPanel("Node Position Cache", nil, Color(190, 58, 80, 255), Color(55, 55, 55, 255), CPanel, {
			[1] = {
				name = "Save",
				class = "DButton",
				cmd = "zbl_CNP_save"
			},
			[2] = {
				name = "Remove",
				class = "DButton",
				cmd = "zbl_CNP_remove"
			},
		})

		zclib.Settings.OptionPanel("Flask", nil, Color(190, 58, 80, 255), Color(55, 55, 55, 255), CPanel, {
			[1] = {
				name = "Spawn Blood Sample",
				class = "DButton",
				cmd = "zbl_debug_flask_blood_unique"
			},
			[2] = {
				name = "Spawn Vaccines",
				class = "DButton",
				cmd = "zbl_debug_flask_vaccines"
			},
			[3] = {
				name = "Spawn Cures",
				class = "DButton",
				cmd = "zbl_debug_flask_cures"
			},
			[4] = {
				name = "Spawn Random",
				class = "DButton",
				cmd = "zbl_debug_flask_random"
			}
		})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

		zclib.Settings.OptionPanel("Contaminated Objects", nil, Color(190, 58, 80, 255), Color(55, 55, 55, 255), CPanel, {
			[1] = {
				name = "Show",
				class = "DButton",
				cmd = "zbl_debug_Ctmn_Show"
			},
			[2] = {
				name = "Clear",
				class = "DButton",
				cmd = "zbl_debug_Ctmn_ClearObjects",
				notify = "Contaminated Objects cleared!"
			}
		})

		zclib.Settings.OptionPanel("Usefull Commands", nil, Color(190, 58, 80, 255), Color(55, 55, 55, 255), CPanel, {
			[1] = {
				name = "Cure All",
				class = "DButton",
				cmd = "zbl_debug_ForceCure",
				notify = "Everyone got cured!"
			},
			[2] = {
				name = "Cure Self",
				class = "DButton",
				cmd = "zbl_debug_Cure_Self",
				notify = "You got cured!"
			},
			[3] = {
				name = "Cure Near",
				class = "DButton",
				cmd = "zbl_debug_Cure_Near",
				notify = "People close by got cured!"
			},
			[4] = {
				name = "Remove all VirusNodes",
				class = "DButton",
				cmd = "zbl_debug_VN_removeall",
				notify = "Virusnodes removed!"
			},
			[5] = {
				name = "Remove all Corpses",
				class = "DButton",
				cmd = "zbl_debug_corpse_removeall",
				notify = "Corpses removed!"
			},
			[6] = {
				name = "Toggle Respirator Random",
				class = "DButton",
				cmd = "zbl_debug_GasMask_switch"
			},
			[7] = {
				name = "Show Infected Players",
				class = "DButton",
				cmd = "zbl_debug_infection_Show"
			},
		})
	end)

	spawnmenu.AddToolMenuOption("Options", "zbl_options", "zbl_Client_Settings", "Client Settings", "", "", function(CPanel)
		zclib.Settings.OptionPanel("VFX", nil, Color(190, 58, 80, 255), Color(55, 55, 55, 255), CPanel, {
			[1] = {
				name = "Dynamiclight",
				class = "DCheckBoxLabel",
				cmd = "zbl_cl_dynlight"
			},
			[2] = {
				name = "Decals",
				class = "DCheckBoxLabel",
				cmd = "zbl_cl_decals"
			},
			[3] = {
				name = "Epilepsy SafeMode",
				class = "DCheckBoxLabel",
				cmd = "zbl_cl_epilepsy"
			},
			[4] = {
				name = "Simplify Fence",
				class = "DCheckBoxLabel",
				cmd = "zbl_cl_fence_simplify"
			},
			[5] = {
				name = "Corpse Bloating",
				class = "DCheckBoxLabel",
				cmd = "zbl_cl_corpsebloat"
			}
		})

		zclib.Settings.OptionPanel("SFX", nil, Color(190, 58, 80, 255), Color(55, 55, 55, 255), CPanel, {
			[1] = {
				name = "Effects Volume",
				class = "DNumSlider",
				cmd = "zbl_cl_sfx_volume",
				min = 0,
				max = 1,
				decimal = 1
			},
			[2] = {
				name = "Symptomes Volume",
				class = "DNumSlider",
				cmd = "zbl_cl_symptome_volume",
				min = 0,
				max = 1,
				decimal = 1
			}
		})

		zclib.Settings.OptionPanel("Disinfectant - UI", nil, Color(190, 58, 80, 255), Color(55, 55, 55, 255), CPanel, {
			[1] = {
				name = "Show",
				class = "DCheckBoxLabel",
				cmd = "zbl_cl_spray_enabled"
			},
			[2] = {
				name = "Pos X",
				class = "DNumSlider",
				cmd = "zbl_cl_spray_pos_x",
				min = 0,
				max = 100,
				decimal = 0
			},
			[3] = {
				name = "Pos Y",
				class = "DNumSlider",
				cmd = "zbl_cl_spray_pos_y",
				min = 0,
				max = 100,
				decimal = 0
			},
			[4] = {
				name = "Scale",
				class = "DNumSlider",
				cmd = "zbl_cl_spray_scale",
				min = 0.5,
				max = 2,
				decimal = 1
			}
		})

		zclib.Settings.OptionPanel("Respirator - UI", nil, Color(190, 58, 80, 255), Color(55, 55, 55, 255), CPanel, {
			[1] = {
				name = "Show",
				class = "DCheckBoxLabel",
				cmd = "zbl_cl_mask_enabled"
			},
			[2] = {
				name = "Pos X",
				class = "DNumSlider",
				cmd = "zbl_cl_mask_pos_x",
				min = 0,
				max = 100,
				decimal = 0
			},
			[3] = {
				name = "Pos Y",
				class = "DNumSlider",
				cmd = "zbl_cl_mask_pos_y",
				min = 0,
				max = 100,
				decimal = 0
			},
			[4] = {
				name = "Scale",
				class = "DNumSlider",
				cmd = "zbl_cl_mask_scale",
				min = 0.5,
				max = 2,
				decimal = 1
			}
		})
	end)
end)
