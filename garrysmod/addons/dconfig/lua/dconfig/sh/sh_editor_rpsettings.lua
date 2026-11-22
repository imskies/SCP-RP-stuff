DCONFIG2.Editor.OnSave("settings", function(saveData)
	local success = DCONFIG2.UpdateDarkRPSettings(saveData)
	local msg = "Successfully Saved DarkRP Settings"
	if not success then
		return {success = false, msg = "Failed to save settings."}
	end
	return {success = true, msg = msg, icon = "dconfig/settings.png", refresh = true}
end)

DCONFIG2.Editor.Sort("settings", function(loopTable)
	table.sort(loopTable, function(a,b)
		local inTableA = DCONFIG2.ChangedSettings[a.key]
		local inTableB = DCONFIG2.ChangedSettings[b.key]
		if inTableA and not inTableB then
			return true
		elseif not inTableA and inTableB then
			return false
		else
			return string.lower(a.name) < string.lower(b.name)
		end 

		return false
	end)
	return loopTable
end)

DCONFIG2.Editor.LoadKeys("settings", function(option)
	return (GM or GAMEMODE).Config[option.key]
end)


DCONFIG2.Editor.Options["settings"] = {}

local descriptions = {
	["voice3D"] = "Enable/disable 3DVoice is enabled.",
	["AdminsCopWeapons"] = "Enable/disable admins spawning with cop weapons.",
	["adminBypassJobRestrictions"] = "Enable/disable whether an admin can force set a job with whenever customCheck returns false.",
	["allowjobswitch"] = "Allow people getting their own custom jobs.",
	["allowrpnames"] = "Allow Players to Set their RP names using the /rpname command.",
	["allowsprays"] = "Enable/disable the use of sprays on the server.",
	["allowvehicleowning"] = "Enable/disable whether people can own vehicles.",
	["allowvnocollide"] = "Enable/disable the ability to no-collide a vehicle (for security).",
	["alltalk"] = "Enable for global chat, disable for local chat.",
	["antimultirun"] = "Disallow people joining your server(s) twice on the same account.",
	["autovehiclelock"] = "Enable/Disable automatic locking of a vehicle when a player exits it.",
	["babygod"] = "People spawn godded (prevent spawn killing)",
	["canforcedooropen"] = "Whether players can force an unownable door open with lockpick or battering ram or w/e.",
	["chatsounds"] = "Sounds are played when some things are said in chat.",
	["chiefjailpos"] = "Allow the Chief to set the jail positions.",
	["cit_propertytax"] = "Enable/disable property tax that is exclusive only for citizens.",
	["copscanunfreeze"] = "Enable/disable the ability of cops to unfreeze other people's props.",
	["copscanunweld"] = "Enable/disable the ability of cops to unweld other people's props.",
	["cpcanarrestcp"] = "Allow/Disallow CPs to arrest other CPs.",
	["currencyLeft"] = "The position of the currency symbol. true for left, false for right.",
	["customjobs"] = "Enable/disable the /job command (personalized job names).",
	["customspawns"] = "Enable/disable whether custom spawns should be used.",
	["deathblack"] = "Whether or not a player sees black on death.",
	["showdeaths"] = "Display kill information in the upper right corner of everyone's screen.",
	["deadtalk"] = "Enable/disable whether people talk and use commands while dead.",
	["deadvoice"] = "Enable/disable whether people talk through the microphone while dead.",
	["deathpov"] = "Enable/disable whether people see their death in first person view.",
	["decalcleaner"] = "Enable/Disable clearing every player's decals.",
	["disallowClientsideScripts"] = "Clientside scripts can be very useful for customizing the HUD or to aid in building. This option bans those scripts.",
	["doorwarrants"] = "Enable/disable Warrant requirement to enter property.",
	["dropmoneyondeath"] = "Enable/disable whether people drop money on death.",
	["droppocketarrest"] = "Enable/disable whether people drop the stuff in their pockets when they get arrested.",
	["droppocketdeath"] = "Enable/disable whether people drop the stuff in their pockets when they die.",
	["dropweapondeath"] = "Enable/disable whether people drop their current weapon when they die.",
	["dropspawnedweapons"] = "Players can drop the weapons they spawn with.",
	["dynamicvoice"] = "Enable/disable whether only people in the same room as you can hear your mic.",
	["earthquakes"] = "Enable/disable earthquakes.",
	["enablebuypistol"] = "Turn /buy on of off.",
	["enforceplayermodel"] = "Whether or not to force players to use their role-defined character models.",
	["globalshow"] = "Whether or not to display player info above players' heads in-game.",
	["ironshoot"] = "Enable/disable whether people need iron sights to shoot.",
	["showjob"] = "Whether or not to display a player's job above their head in-game.",
	["letters"] = "Enable/disable letter writing / typing.",
	["license"] = "Enable/disable People need a license to be able to pick up guns.",
	["lockdown"] = "Enable/Disable initiating lockdowns for mayors.",
	["lockpickfading"] = "Enable/disable the lockpicking of fading doors.",
	["logging"] = "Enable/disable logging everything that happens.",
	["lottery"] = "Enable/disable creating lotteries for mayors.",
	["showname"] = "Whether or not to display a player's name above their head in-game.",
	["showhealth"] = "Whether or not to display a player's health above their head in-game.",
	["needwantedforarrest"] = "Enable/disable Cops can only arrest wanted people.",
	["noguns"] = "Enabling this feature bans Guns and Gun Dealers",
	["norespawn"] = "Enable/Disable that people don't have to respawn when they change job.",
	["npcarrest"] = "Enable/disable arresting npc's.",
	["ooc"] = "Whether or not OOC tags are enabled.",
	["propertytax"] = "Enable/disable property tax.",
	["proppaying"] = "Whether or not players should pay for spawning props.",
	["propspawning"] = "Enable/disable props spawning. Applies to admins too.",
	["removeclassitems"] = "Enable/disable shipments/microwaves/etc. removal when someone changes team.",
	["removeondisconnect"] = "Enable/disable shipments/microwaves/etc. removal when someone disconnects.",
	["respawninjail"] = "Enable/disable whether people can respawn in jail when they die.",
	["restrictallteams"] = "Enable/disable Players can only be citizen until an admin allows them.",
	["restrictbuypistol"] = "Enabling this feature makes /buy available only to Gun Dealers. This will also disallow non allowed jobs to purchase single weapons.",
	["restrictdrop"] = "Enable/disable restricting the weapons players can drop. Setting this to true disallows weapons from shipments from being dropped.",
	["revokeLicenseOnJobChange"] = "Whether licenses are revoked when a player changes jobs.",
	["shouldResetLaws"] = "Enable/Disable resetting the laws back to the default law set when the mayor changes.",
	["strictsuicide"] = "Whether or not players should spawn where they suicided.",
	["telefromjail"] = "Enable/disable teleporting from jail.",
	["teletojail"] = "Enable/disable teleporting to jail.",
	["unlockdoorsonstart"] = "Enable/Disable unlocking all doors on map start.",
	["voiceradius"] = "Enable/disable local voice chat.",
	["wallettax"] = "Whether players pay taxes on their wallets.",
	["wantedsuicide"] = "Enable/Disable suiciding while you are wanted by the police.",
	["realisticfalldamage"] = "Enable/Disable dynamic fall damage. Setting mp_falldamage to 1 will over-ride this.",
	["printeroverheat"] = "Whether the default money printer can overheat on its own.",
	["weaponCheckerHideDefault"] = "Hide default weapons when checking weapons.",
	["weaponCheckerHideNoLicense"] = "Hide weapons that do not require a license.",

	--Non boolean
	["adminnpcs"] = "Whether or not NPCs should be admin only. 0 = everyone, 1 = admin or higher, 2 = superadmin or higher, 3 = rcon only",
	["adminsents"] = "Whether or not SENTs should be admin only. 0 = everyone, 1 = admin or higher, 2 = superadmin or higher, 3 = rcon only",
	["adminvehicles"] = "Whether or not vehicles should be admin only. 0 = everyone, 1 = admin or higher, 2 = superadmin or higher, 3 = rcon only",
	["adminweapons"] = "Who can spawn weapons: 0: admins only, 1: supadmins only, 2: no one, 3: everyone",
	["arrestspeed"] = "Sets the max arrest speed.",
	["babygodtime"] = "How long the babygod lasts.",
	["chatsoundsdelay"] = "How long to wait before letting a player emit a sound from their chat again.",
	["deathfee"] = "The amount of money someone drops when dead.",
	["decaltimer"] = "Sets the time to clear clientside decals (in seconds)",
	["demotetime"] = "Number of seconds before a player can rejoin a team after demotion from that team.",
	["doorcost"] = "Sets the cost of a door",
	["entremovedelay"] = "How long to wait before removing a bought entity after disconnect.",
	["gunlabweapon"] = "The weapon that the gunlab spawns.",
	["jailtimer"] = "Sets the jailtimer (in seconds).",
	["lockdowndelay"] = "The amount of time a mayor must wait before starting the next lockdown.",
	["maxadvertbillboards"] = "The maximum number of /advert billboards a player can place.",
	["maxCheques"] = "The maximum number of cheques someone can write.",
	["maxdoors"] = "Sets the max amount of doors one can own.",
	["maxdrugs"] = "Sets max drugs.",
	["maxfoods"] = "Sets the max food cartons per Microwave owner.",
	["maxfooditems"] = "Sets the max amount of food items a player can buy from the F4 menu.",
	["maxlawboards"] = "The maximum number of law boards the mayor can place.",
	["maxletters"] = "Sets max letters.",
	["maxlotterycost"] = "Maximum payment the mayor can set to join a lottery.",
	["maxvehicles"] = "Sets how many vehicles one can buy.",
	["microwavefoodcost"] = "Sets the sale price of Microwave Food.",
	["minlotterycost"] = "Minimum payment the mayor can set to join a lottery.",
	["moneyRemoveTime"] = "Money packets will get removed if they don't get picked up after a while. Set to 0 to disable.",
	["mprintamount"] = "Value of the money printed by the money printer.",
	["normalsalary"] = "Sets the starting salary for newly joined players.",
	["npckillpay"] = "Sets the money given for each NPC kill.",
	["paydelay"] = "Sets how long it takes before people get salary.",
	["pocketitems"] = "Sets the amount of objects the pocket can carry.",
	["pricecap"] = "The maximum price of items (using /price).",
	["pricemin"] = "The minimum price of items (using /price).",
	["propcost"] = "How much prop spawning should cost (prop paying must be enabled for this to have an effect).",
	["quakechance"] = "Chance of an earthquake happening.",
	["respawntime"] = "Minimum amount of seconds a player has to wait before respawning.",
	["changejobtime"] = "Minimum amount of seconds a player has to wait before changing job.",
	["runspeed"] = "Sets the max running speed.",
	["runspeedcp"] = "Sets the max running speed for CP teams.",
	["searchtime"] = "Number of seconds for which a search warrant is valid.",
	["ShipmentSpamTime"] = "Antispam time between spawning shipments.",
	["shipmentspawntime"] = "The number of seconds it takes for a shipment to spawn.",
	["startinghealth"] = "The health when you spawn.",
	["startingmoney"] = "Your wallet when you join for the first time.",
	["vehiclecost"] = "Sets the cost of a vehicle (To own it).",
	["wallettaxmax"] = "Maximum percentage of tax to be paid.",
	["wallettaxmin"] = "Minimum percentage of tax to be paid.",
	["wallettaxtime"] = "Time in seconds between taxing players. Requires server restart.",
	["wantedtime"] = "Number of seconds for which a player is wanted for.",
	["walkspeed"] = "Sets the max walking speed.",
	["falldamagedamper"] = "The damper on realistic fall damage. Default is 15. Decrease this for more damage.",
	["falldamageamount"] = "The base damage taken from falling for static fall damage. Default is 10.",
	["printeroverheatchance"] = "The likelyhood of a printer overheating. The higher this number, the less likely (minimum 3, default 22).",
	["printerreward"] = "Reward for destroying a money printer.",

	--Extras
	["talkDistance"] = "Talk Distance in source units. (similar to inches)",
	["whisperDistance"] = "Talk Distance in source units. (similar to inches)",
	["yellDistance"] = "Yell Distance in source units. (similar to inches)",
	["meDistance"] = "/me Distance in source units. (similar to inches)",
	["voiceDistance"] = "Voice Distance in source units. (similar to inches)",

	["MoneyClass"] = "The classname of money packets. Use this to create your own money entity!",
	["moneyModel"] = "In case you do wish to keep the default money, but change the model, this option is the way to go.",
	["lockdownsound"] = "Custom sound to be played for all players whenever a lockdown is initiated.",

	["currency"] = "Currency Symbol",
	["chatCommandPrefix"] = "The Chat Command Prefix.",
	["F1MenuHelpPage"] = "The URL that is opened when pressing F1.",
	["F1MenuHelpPageTitle"] = "The Page Title of the F1 Menu.",

	["hideNonBuyable"] = "Hide the items that you can't buy and the jobs you can't get (instead of graying them out).",
	["hideTeamUnbuyable"] = "Hide only the items that you have the wrong job. ( Can't see gundealer shipments when you have the citizen job. )",
	["afkdemotetime"] = "The time of inactivity before being demoted.",
	["AFKDelay"] = "Prevent people from spamming AFK.",

	["minHitPrice"] = "The minimum price for a hit.",
	["maxHitPrice"] = "The maximum price for a hit.",
	["minHitDistance"] = "The minimum distance between a hitman and his customer when they make the deal.",
	["hudText"] = "The text that tells the player he can press use on the hitman to request a hit.",
	["hitmanText"] = "The text above a hitman when he's got a hit.",
	["hitTargetCooldown"] = "The cooldown time for a hit target (so they aren't spam killed).",
	["hitCustomerCooldown"] = "How long a customer has to wait to be able to buy another hit (from the moment the hit is accepted).",

	["hungerspeed"] = "Set the rate at which players will become hungry.",
	["starverate"] = "How much health that is taken away every second the player is starving.",


}

local function PrepareRPSettingsEditor()
	local count = 1
	local ty
	local gm = (GM or GAMEMODE)
	for k,v in pairs(gm.Config) do
		if type(v) != "table" then
			if k == "doorcost" then
				ty = "number"
			else
				ty = type(v)
			end
			local desc = descriptions[k] or "General Setting"
			DCONFIG2.Editor.AddOption("settings", {
				name = k,
				description = desc,
				key = k,
				type = ty,
				lowerstring = true,
				default = DCONFIG2.OriginalSettings[k],
				postbuild = function(body, panel, editorOptions, data)
					local theme = DCONFIG2.GetTheme()
					local title = panel.titleLabel:GetText()
					if DCONFIG2.ChangedSettings[data.key] != nil then  
						DCONFIG2.MsgC("Overwriting " .. data.key)
						panel.titleLabel:SetText(title .. " - DConfig 2 Load Priority")
						panel.titleLabel:SetTextColor(theme.theme)
						local revertButton = panel:Add("DCONFIG2Button")
						revertButton:Dock(TOP)
						revertButton:SetFontSize(14)
						revertButton:SetTall(body:GetTall() * .025)
						revertButton:SetText("Revert to Hardcoded Value")
						revertButton:DockMargin(0, DCONFIG2.GetYPadding(), body:GetWide() * .8, 0)
						revertButton.DoClick = function()
							panel:SetValue(DCONFIG2.GetOriginalDarkRPSetting(data.key))
							DCONFIG2.MsgC("Setting value to " .. DCONFIG2.GetOriginalDarkRPSetting(data.key))
						end
					end
				end,
			})
		end
	end

end

hook.Add("InitPostEntity", "DCONFIG2_PrepareDarkRPSettings", function()
	PrepareRPSettingsEditor()
end)