--Thank you for purchasing my addon. 
--If you enjoy my work please leave a nice review, it truly is appreciated and does help.
--If you have any suggestions please feel free to send them my way, I am always looking for ways to improve my craft.

--[Damage Stuff]--
DPROP.NoDamage = {
	["prop_physics"] = true, 
	["prop_physics_multiplayer"] = true,
	["prop_physics_override"] = true,
	["prop_physics_respawnable"] = true,
} 
DPROP.VehicleDamage = true -- Enable/Disable Vehicle Damage.

--[[Prop Ghosts]]--
DPROP.GhostedEnts = {
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true,
	["prop_physics_override"] = true,
	["prop_physics_respawnable"] = true,
	["dxans_pillpress"] = true, -- Buy DXans now.
}
DPROP.GhostEnabled = true -- Enable/Disable entity ghosting.
DPROP.GhostColor = Color(26,116,219,100)
DPROP.VehicleGhost = true -- Enable/Disable vehicle ghosting. GhostEnabled has to be true.
DPROP.GhostInsidePlayers = true --Enable/Disable ghosting of a prop when inside a player.
DPROP.GhostDistanceCheck = true --Enable/Disable attempt fix at prop launching / prop climbing via one prop.

--[[Timer Stuff]]--
DPROP.TimerUpdate = 15 -- The time between each timer execution. Requires restart of map or server to update. Time in seconds.
DPROP.AutoFreeze = true -- Automatically freezes player's props. It's recommended that the auto freeze is disabled if FreezeOnDrop is enabled. Helps with crashes related to collisions!
DPROP.OutsidePropRemover = true -- Will loop over every ent to check if it's out

--[Physgun Stuff]--
DPROP.FreezeOnDrop = false -- Enable/Disable Freezes ent automatically when a prop is dropped with the physgun. VERY USEFUL.
DPROP.CanReloadPhysgun = false -- Enable/Disable Unfreezing via Reload.
DPROP.KillVelocity = true --Enable/Disable Killing velocity on drop. Useful for countering prop kills.


--[[Grav Gun Stuff]]--
DPROP.CanGravGunPunt = false -- Enable/Disable Gravity Gun Punting.

--[[Decals]]--
DPROP.AutoClearDecals = true -- Automatically clear client decals.
DPROP.ClearDecalsTime = 120 -- How often in seconds decals are cleared.


--[[Prop Size Stuff]]--
DPROP.MaxCubicUnits = 0 -- Maximum cubic units size of prop allowed to be spawned. Set to 0 to disable.

--[[Outside Props]]-- 
DPROP.OutsideProps = true -- Enable/Disable props being placed outside. True: All Access False: Team/Group Access.
local function ConfigureTeams()
	DPROP.OutsideAccessTeams = {-- If DPROP.OutsideProps = false then these teams/jobs can spawn props outside.
		[TEAM_HOBO] = true,
	}
end

--[[Prop Blacklist]]--
DPROP.BlacklistedModels = {
	["models/xqm/jetbody3.mdl"] = true,
	["models/xqm/jetbody3_s2.mdl"] = true,
	["models/xqm/jetbody3_s3.mdl"] = true,
	["models/xqm/jetbody3_s4.mdl"] = true,
	["models/xqm/jetbody3_s5.mdl"] = true,
}
  
--[[Rank Stuff]]--
DPROP.OutsideAccessGroups = { -- If DPROP.OutsideProps = false then these groups can spawn props outside.
	["admin"] = true,
	["superadmin"] = true,
	["founder"] = true,
}

DPROP.CantSpawnProps = { -- These groups do not have access to spawning props.
	--["user"] = true,
}

DPROP.PropLimits = true -- Enable/Disable PropLimits via usergroup
DPROP.DefaultPropLimit = 150 -- Default prop limit if a usergroup isn't defined.
DPROP.PropLimitRanks = {
	["user"] = 20,
    ["VIP"] = 255,
	["Trusted"] = 150,
	["Supporter"] = 300,
    ["Trial GM"] = 500,
    ["Junior Gamemaster"] = 500,
    ["Gamemaster"] = 500,
    ["Trusted Gamemaster"] = 500,
    ["Senior Gamemaster"] = 500,
	["superadmin"] = 500,
	["founder"] = 50,
}

DPROP.AdminRankHierchy = { -- These groups have access to all the commands in !dprops 
	["admin"] = 1, -- 1 can only target 1
	["superadmin"] = 2, -- 2 can target 2 and 1
	["founder"] = 3, -- 3 Can target 3, 2 and 1
}

DPROP.Debugging = false
if DCONFIG then -- Support for DCONFIG. https://www.gmodstore.com/dashboard/addons/5262
	hook.Add("DConfigDataLoaded", "DPROP_SetupAccessTeams", ConfigureTeams)
else
	hook.Add("loadCustomDarkRPItems", "DPROP_SetupAccessTeams", ConfigureTeams)
end
