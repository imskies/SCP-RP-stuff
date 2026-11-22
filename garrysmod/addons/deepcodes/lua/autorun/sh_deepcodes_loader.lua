local string = string

if SERVER then
    AddCSLuaFile("deepcodes/sh_init.lua")
end
include("deepcodes/sh_init.lua")

assert(DeepCodes, "Deep Codes failed to initialize.")

local dir = "deepcodes"

DeepCodes.Files = {
    "sh_config",
    "sv_net",
    "sv_init",
    "cl_init",
    "cl_recievecode"
}

for _,file in ipairs(DeepCodes.Files) do
    
    if string.StartWith(file, "sh_") then
        if SERVER then
            AddCSLuaFile(dir.."/"..file..".lua")
        end
        include(dir.."/"..file..".lua")
        continue
    end

    if string.StartWith(file, "sv_") then
        if SERVER then
            include(dir.."/"..file..".lua")
        end
        continue
    end

    if SERVER then
        AddCSLuaFile(dir.."/"..file..".lua")
    end
    if CLIENT then
        include(dir.."/"..file..".lua")
    end
end