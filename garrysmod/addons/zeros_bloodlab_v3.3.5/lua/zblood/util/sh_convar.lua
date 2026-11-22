/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/


if CLIENT then

    zclib.Convar.Create("zbl_cl_dynlight", "0", {FCVAR_ARCHIVE})
    zclib.Convar.Create("zbl_cl_decals", "1", {FCVAR_ARCHIVE})
    zclib.Convar.Create("zbl_cl_epilepsy", "1", {FCVAR_ARCHIVE})
    zclib.Convar.Create("zbl_cl_corpsebloat", "1", {FCVAR_ARCHIVE})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

    zclib.Convar.Create("zbl_cl_spray_pos_x", "50", {FCVAR_ARCHIVE})
    zclib.Convar.Create("zbl_cl_spray_pos_y", "95", {FCVAR_ARCHIVE})
    zclib.Convar.Create("zbl_cl_spray_scale", "1", {FCVAR_ARCHIVE})
    zclib.Convar.Create("zbl_cl_spray_enabled", "1", {FCVAR_ARCHIVE})

    zclib.Convar.Create("zbl_cl_mask_pos_x", "95", {FCVAR_ARCHIVE})
    zclib.Convar.Create("zbl_cl_mask_pos_y", "10", {FCVAR_ARCHIVE})
    zclib.Convar.Create("zbl_cl_mask_scale", "1", {FCVAR_ARCHIVE})
    zclib.Convar.Create("zbl_cl_mask_enabled", "1", {FCVAR_ARCHIVE})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

    zclib.Convar.Create("zbl_cl_fence_simplify", "0", {FCVAR_ARCHIVE})

    local function Reload_Soundlibary()
    	include("zblood/util/sh_sound.lua")
        zbl.Print("Soundlibary reloaded!")
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

    zclib.Convar.Create("zbl_cl_sfx_volume", "0.75", {FCVAR_ARCHIVE})
    cvars.AddChangeCallback("zbl_cl_sfx_volume", function(convar_name, value_old, value_new)
    	Reload_Soundlibary()
    end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

    zclib.Convar.Create("zbl_cl_symptome_volume", "0.75", {FCVAR_ARCHIVE})
    cvars.AddChangeCallback("zbl_cl_symptome_volume", function(convar_name, value_old, value_new)
    	Reload_Soundlibary()
    end)
end
