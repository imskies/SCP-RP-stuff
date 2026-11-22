--You can add your own tabs/values here or add checks for them, but if you are not going to change anything, use only ehud_config.lua
--You can add your own tabs/values here or add checks for them, but if you are not going to change anything, use only ehud_config.lua
--You can add your own tabs/values here or add checks for them, but if you are not going to change anything, use only ehud_config.lua

-------------------------------
/// Default client settings ///
-------------------------------
--All settings here controlled by esclib ( my library and settings addon )
--Here are the default settings used on the client.
--Players will be able to change these settings right in the game via esettings.
--These settings are stored in the file garrysmod/data/es_ehud/settings.json
--NOTE: Settings of players will not be overwritten if they have changed these values

--Basic information:
-- 1) Initializing settings, creating var with wrapper - local settings = esclib:InitSettings("ADDON NAME HERE")
-- 2) Tab creating - local tab = settings:AddTab("TAB UID HERE (any unique string)")
-- 	You can see available methods in esclib/lua/elib/essentials/esc_settings_wrapper.lua (you need to download and unzip esclib addon via workshop)
-- 3) Var create example
-- 	Available types: bool / float / numslider
-- 	You can see available types / methods in esclib/lua/elib/essentials/esc_settings_types.lua
-- 	local var = tab:AddVar("VAR UID HERE", "TYPE HERE(for example:bool)") --
-- 	var:SetNameTranslateKey("s_mainhud_name") --set key for translation from ehud_languages.lua / you can use :SetName("Any String Here")--will not be translated
-- 	var:SetValue(true) --(will be default value) -- value from type

-- 	Additional info:
-- 		You can hide setting from user, addon will use default value from this file or from server settings
-- 		To do this, use :CanChange(TYPE, VALUE) method
-- 		Types: "steamid" / "usergroup"
-- 		var:CanChange(false)
-- 		var:CanChange("steamid", "STEAM_0:1:81619963") -- check for steamid
-- 		var:CanChange("steamid", {"STEAM_0:1:81619963","STEAM_0:1:83559963","STEAM_0:1:22219963"}) -- this ok too

--Initialize settings
--Both on client and server
local settings = esclib:InitSettings("ehud")

--Players can change this settings through menu!
---------------
/// MODULES ///
---------------
--tab creating
local tab = settings:AddTab("modules") --uid
tab:SetNameTranslateKey("tab_modules") --key in language file
tab:SetPosition(1) --postion

--adding vars
local var = tab:AddVar("module_hud_leftbot", "bool")
var:SetNameTranslateKey("s_mainhud_name") --key in language file
var:SetValue(ehud.modules["MainHUD"])

local var = tab:AddVar("module_hud_gun", "bool")
var:SetNameTranslateKey("s_gunhud_name")
var:SetValue(ehud.modules["GunHUD"])

local var = tab:AddVar("module_hud_arrested", "bool")
var:SetNameTranslateKey("s_arrestedhud_name")
var:SetValue(ehud.modules["ArrestHUD"])

local var = tab:AddVar("module_hud_doors", "bool")
var:SetNameTranslateKey("s_doorshud_name")
var:SetValue(ehud.modules["DoorsHUD"])

local var = tab:AddVar("module_fpp", "bool")
var:SetNameTranslateKey("s_fpp_name")
var:SetDescTranslateKey("s_fpp_desc")
var:SetValue(ehud.modules["FPPHUD"])
var:CustomCheck(function(self,addon)
	return DarkRP ~= nil
end)

local var = tab:AddVar("module_ply_over", "bool")
var:SetNameTranslateKey("s_plyover_name")
var:SetValue(ehud.modules["PlayerOverheadHUD"])

local var = tab:AddVar("module_agenda", "bool")
var:SetNameTranslateKey("s_agenda_name")
var:SetValue(ehud.modules["AgendaHUD"])

--you can use checks for this
if ehud.config.hitmarkers then
	local var = tab:AddVar("module_hitmarker", "bool")
	var:SetNameTranslateKey("s_hitmark_name")
	var:SetDescTranslateKey("s_hitmark_desc")
	var:SetValue(ehud.modules["HitmarkHUD"])
end

local var = tab:AddVar("module_voice", "bool")
var:SetNameTranslateKey("s_voice_name")
var:SetValue(ehud.modules["VoiceHUD"])

local var = tab:AddVar("module_lockdown", "bool")
var:SetNameTranslateKey("s_lockdown_name")
var:SetValue(ehud.modules["LockdownHUD"])

local var = tab:AddVar("module_deathscreen", "bool")
var:SetNameTranslateKey("s_deathscreen_name")
var:SetValue(ehud.modules["DeathscreenHUD"])

local var = tab:AddVar("module_notify", "bool")
var:SetNameTranslateKey("s_notify_name")
var:SetValue(ehud.modules["NotifyHUD"])

local var = tab:AddVar("module_crashscreen", "bool")
var:SetNameTranslateKey("s_crash_name")
var:SetDescTranslateKey("s_crash_desc")
var:SetValue(ehud.modules["CrashscreenHUD"])

local var = tab:AddVar("module_vehicle_hud", "bool")
var:SetNameTranslateKey("s_vehicle_name")
var:SetValue(ehud.modules["VehicleHUD"])

local var = tab:AddVar("module_selector_hud", "bool")
var:SetNameTranslateKey("s_selector_name")
var:SetValue(ehud.modules["WeaponSelectorHUD"])

local var = tab:AddVar("module_xp_hud", "bool")
var:SetNameTranslateKey("s_xp_name")
var:SetValue(ehud.modules["XPHud"])

---------------------------
/// PLAYEROVER SETTINGS ///
---------------------------
local tab = settings:AddTab("plyover")
tab:SetNameTranslateKey("tab_plyover")
tab:SetPosition(3)
tab:CustomCheck(function() --you can set up own customcheck (for tabs it only for visibility)
	return ehud.overhead_access[LocalPlayer():GetUserGroup()] or esclib:HasAdminAccess(LocalPlayer())
end)

local var = tab:AddVar("drawnickname", "bool")
var:SetNameTranslateKey("s_drawname_name")
var:SetValue(ehud.PlayerOverCFG["DrawNickname"])
var:CanChange("usergroup",ehud.overhead_access) --different built-in checks (usergroup, steamid)

local var = tab:AddVar("drawjobs", "bool")
var:SetNameTranslateKey("s_drawjobs_name")
var:SetValue(ehud.PlayerOverCFG["DrawJobs"])
var:CanChange("usergroup",ehud.overhead_access) --you can delete this line, if you wanted all players to be able to turn off the visibility of nicknames

local var = tab:AddVar("drawlicense", "bool")
var:SetNameTranslateKey("s_drawlicense_name")
var:SetValue(ehud.PlayerOverCFG["DrawLicense"])
var:CanChange("usergroup",ehud.overhead_access)

local var = tab:AddVar("drawarrested", "bool")
var:SetNameTranslateKey("s_drawarrested_name")
var:SetValue(ehud.PlayerOverCFG["DrawArrestStatus"])
var:CanChange("usergroup",ehud.overhead_access)

local var = tab:AddVar("drawwanted", "bool")
var:SetNameTranslateKey("s_drawwanted_name")
var:SetValue(ehud.PlayerOverCFG["DrawWantedStatus"])
var:CanChange("usergroup",ehud.overhead_access)


------------------------
/// GENERAL SETTINGS ///
------------------------
--New tab creating
local tab = settings:AddTab("general")
tab:SetNameTranslateKey("tab_general")
tab:SetPosition(2)

--Animation time slider
local var = tab:AddVar("animtime", "numslider")
var:SetNameTranslateKey("s_animspeed_name")
var:SetValue(ehud.config.AnimationSpeed)
var:SetMin(0.01)
var:SetMax(3)
var:SetDecimals(2)
var:SetStep(0.1)

--Draw Background?
local var = tab:AddVar("drawbg", "bool")
var:SetNameTranslateKey("s_drawbg_name")
var:SetDescTranslateKey("s_drawbg_desc")
var:SetValue(ehud.config.DrawBackground)

--Blur
local var = tab:AddVar("paintblur", "bool")
var:SetNameTranslateKey("s_blur_name")
var:SetDescTranslateKey("s_blur_desc")
var:SetValue(ehud.config.DrawBackgroundBlur)

--Draw fps
local var = tab:AddVar("draw_fps", "bool")
var:SetNameTranslateKey("s_fps_name")
var:SetValue(ehud.config.DrawFPS)

--Use KMH instead MPH
local var = tab:AddVar("use_kmh", "bool")
var:SetNameTranslateKey("s_usekmh_name")
var:SetDescTranslateKey("s_usekmh_desc")
var:SetValue(ehud.config.UseKMH)

if ehud.config.HaveVCMod then
	--Draw vcmod durability panel
	local var = tab:AddVar("vc_draw_durability", "bool")
	var:SetNameTranslateKey("s_drawdurability_name")
	var:SetDescTranslateKey("s_drawdurability_desc")
	var:SetValue(ehud.config.VCDrawDurability)
end

--Vignette
local var = tab:AddVar("vignette", "numslider")
var:SetNameTranslateKey("s_vignette_name")
var:SetDescTranslateKey("s_vignette_desc")
var:SetValue(ehud.config.VignetteStrength)
var:SetMin(0)
var:SetMax(1)
var:SetDecimals(2)
var:SetStep(0.1)

--Draw distance slider
local var = tab:AddVar("draw_dist", "numslider")
var:SetNameTranslateKey("s_draw_dist_name")
var:SetDescTranslateKey("s_draw_dist_desc")
var:SetValue(ehud.config.DrawDistance)
var:SetMin(10)
var:SetMax(1000)
var:SetDecimals(0)
var:SetPosition(1)
var:SetStep(50)

--------------
/// CLIENT ///
--------------
if CLIENT then

--Dynamic hud
local var = tab:AddVar("dynamic_hud", "bool")
var:SetNameTranslateKey("s_dynamic_name")
var:SetValue(ehud.config.ShakingEffect)

--Fast Switch
local var = tab:AddVar("fast_switch", "bool")
var:SetNameTranslateKey("s_fast_switch_name")
var:SetValue(ehud.config.FastWeaponSwitch)


end

-- perform settings
settings:End()