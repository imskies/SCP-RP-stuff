-- Main configuration file
-- If you have some problems or questions, please open ticket or write me in dm <3


----------------------------------------------------------
/// Settings that players CANNOT change with interface ///
----------------------------------------------------------
ehud.config.blur_on_damage = true

ehud.config.hitmarkers = true

ehud.config.heartbeat = true
ehud.config.heartbeat_minhp = 15   -- Minimum hp for start animation
ehud.config.heartbeat_strength = 4 -- Blur strength
ehud.config.heartbeat_speed = 10   -- Lower = slower

ehud.config.reconnect_time = 90 --time in seconds, before player reconnect after server crash



-------------------------------------------------------
/// Settings that players CAN change with interface ///
-------------------------------------------------------
--Who can change player overhead settings
if (CLIENT) then -- No need to store this data on server
--Note: settings in interface not overriding whi

--Main settings:
ehud.config.AnimationSpeed = 0.15 -- [0.01,3] less = faster
ehud.config.DrawBackground = true
ehud.config.DrawBackgroundBlur = true
ehud.config.DrawFPS = false
ehud.config.VignetteStrength = 0.5 -- [0,1] -- 0 to disable
ehud.config.DrawDistance = 400 -- [10, 1000] -- overhead / doors 3d2d
ehud.config.ShakingEffect = true -- when jumping, mouse movements
ehud.config.UseKMH = false -- Use KMH instead of MPH
ehud.config.FastWeaponSwitch = false --Immediately change weapons without pressing the LMB button
ehud.config.PlayerOverheadSize = 0.13
ehud.config.SelectorWidth = 0.7 -- Weapon selector (0, 1] - 0 - nothing 1 --full screen

ehud.config.HaveVCMod = true
ehud.config.VCDrawDurability = true --Enable or disable vehicle durability drawing (VCMOD required)

--requires https://github.com/uen/Leveling-System
ehud.config.XPBarPosition = "top" -- top / bottom

ehud.overhead_access = { --it just hide this tab from players and prevents players from changing the vars
	["superadmin"] = true, --or who have admin access. if you wanted all players to be able to see that tab, set here "user"=true,
}

--you can disable / enable modules by default here
--Note: Settings of players will not be overwritten if they have changed these values before
ehud.modules = {
	["MainHUD"] = true, --health, hunger, money etc
	["GunHUD"] = true,
	["ArrestHUD"] = true,
	["DoorsHUD"] = true,
	["FPPHUD"] = true,
	["PlayerOverheadHUD"] = true,
	["AgendaHUD"] = true,
	["HitmarkHUD"] = true,
	["VoiceHUD"] = true,
	["LockdownHUD"] = true,
	["DeathscreenHUD"] = true,
	["NotifyHUD"] = true,
	["CrashscreenHUD"] = true,
	["VehicleHUD"] = true,
	["WeaponSelectorHUD"] = true,
	["XPHud"] = true, --https://github.com/uen/Leveling-System
}

--Player overhead config
ehud.PlayerOverCFG = {
	["DrawNickname"] = true,
	["DrawJobs"] = true,
	["DrawLicense"] = true,
	["DrawArrestStatus"] = true,
	["DrawWantedStatus"] = true,
}

end --end of client block


-----------------------------
--# Access to admin panel #--
-----------------------------
--Input: (usergroup),(has access)
esclib:ChangeAdminAccess("superadmin",true)
--esclib:ChangeAdminAccess("owner",true)