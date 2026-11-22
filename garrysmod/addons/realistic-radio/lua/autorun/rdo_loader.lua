/*
    Addon id: 2bab5356-b4ae-4c4d-acb8-e199f204bd54
    Version: v1.3.8 (stable)
*/

include("realistic_radio/sh_config_rdo.lua")
include("realistic_radio/sh_materials_rdo.lua")
include("realistic_radio/languages/sh_language_en.lua")
include("realistic_radio/languages/sh_language_ru.lua")
include("realistic_radio/languages/sh_language_fr.lua")
include("realistic_radio/languages/sh_language_de.lua")
include("realistic_radio/languages/sh_language_pl.lua")
include("realistic_radio/languages/sh_language_tr.lua")
include("realistic_radio/languages/sh_language_cn.lua")
include("realistic_radio/shared/sh_functions.lua")
include("realistic_radio/sh_advanced_config.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 76561199123350968 */

if SERVER then 
    AddCSLuaFile("realistic_radio/sh_config_rdo.lua")
    AddCSLuaFile("realistic_radio/languages/sh_language_en.lua")
    AddCSLuaFile("realistic_radio/languages/sh_language_ru.lua")
    AddCSLuaFile("realistic_radio/languages/sh_language_fr.lua")
    AddCSLuaFile("realistic_radio/languages/sh_language_de.lua")
    AddCSLuaFile("realistic_radio/languages/sh_language_pl.lua")
    AddCSLuaFile("realistic_radio/languages/sh_language_tr.lua")
    AddCSLuaFile("realistic_radio/languages/sh_language_cn.lua")
    AddCSLuaFile("realistic_radio/shared/sh_functions.lua")
    AddCSLuaFile("realistic_radio/sh_materials_rdo.lua")
    AddCSLuaFile("realistic_radio/sh_advanced_config.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 1d139e0850450ff0c55cc5ad19568a0794d4d3bdce3fa3d34f714425a4e44079 */
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* c750873a37e0a75f99a502a9e5939b02f1b88b5df95e9c2b5c42581a8e324e05 */

    AddCSLuaFile("realistic_radio/client/cl_fonts.lua")
    AddCSLuaFile("realistic_radio/client/cl_main.lua")
    AddCSLuaFile("realistic_radio/client/cl_notify.lua")

    include("realistic_radio/server/sv_functions.lua")
    include("realistic_radio/server/sv_hook.lua")
    include("realistic_radio/server/sv_net.lua")
else 
    include("realistic_radio/client/cl_fonts.lua")
    include("realistic_radio/client/cl_main.lua")
    include("realistic_radio/client/cl_notify.lua")
end 
