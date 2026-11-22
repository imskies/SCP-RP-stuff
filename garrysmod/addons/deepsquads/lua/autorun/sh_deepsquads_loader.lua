local string = string
local start = SysTime()

if SERVER then
    AddCSLuaFile("includes/modules/outline.lua")
    AddCSLuaFile("deepsquads/sh_init.lua")
else
    require("outline")
end
include("deepsquads/sh_init.lua")

assert(DeepSquads, "Deep Codes failed to initialize.")

local dir = "deepsquads"

DeepSquads.Files = {
    "sh_config",
    "sv_init",
    "sv_net",
    "cl_init",
    "cl_net",
    "material-avatar",
    "vgui-avatar"
}

for _,filename in ipairs(DeepSquads.Files) do
    print("DeepSquads:LoadingFile", filename)

    if string.StartWith(filename, "sh_") then
        if SERVER then
            AddCSLuaFile(dir .. "/" .. filename .. ".lua")
        end
        include(dir .. "/" .. filename .. ".lua")
        continue
    end

    if string.StartWith(filename, "sv_") then
        if SERVER then
            include(dir .. "/" .. filename .. ".lua")
        end
        continue
    end

    if SERVER then
        AddCSLuaFile(dir .. "/" .. filename .. ".lua")
    end
    if CLIENT then
        include(dir .. "/" .. filename .. ".lua")
    end
end


MsgC("[Deep Squads]", DeepSquads.Success, " Finished initializing in " .. math.Round(SysTime() - start, 3) .. " seconds.\n") -- EOF