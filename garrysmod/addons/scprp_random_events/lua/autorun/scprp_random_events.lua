SCPRPEvents = SCPRPEvents or {}
SCPRPEvents.Version = "2.2.1-008-2"

if SERVER then
    AddCSLuaFile("scprp_events/sh_config.lua")
    AddCSLuaFile("scprp_events/cl_events.lua")
end

include("scprp_events/sh_config.lua")

if SERVER then
    include("scprp_events/sv_events.lua")
    include("scprp_events/sv_deepgaming_events.lua")
    print("[SCPRP Events] Loaded build " .. SCPRPEvents.Version)
else
    include("scprp_events/cl_events.lua")
end
