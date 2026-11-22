AddCSLuaFile()

breachList = breachList or {}

function AddSCP( params )
	breachList[ params.teamName ] = {
		breachTime = params.breachTime,
		coolDown = params.coolDown,
		maintMsg = params.maintMsg,
		breachMsg = params.breachMsg,
		halfWayMsg = params.halfWayMsg,
		cancelMsg = params.cancelMsg,
		announceBreach = params.announceBreach,
		announceMaint = params.announceMaint,
		announceStop = params.announceStop,
		breachAll = params.breachAll,
		breachPos = params.breachPos
	}
end






--[[

								█████████████████████████████████████████████████████████████████████████████████████████████████████████████████████
								█░░░░░░█████████░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█░░░░░░█████████░░░░░░░░░░█░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█
								█░░▄▀░░█████████░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀░░█████████░░▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█
								█░░▄▀░░█████████░░▄▀░░░░░░▄▀░░█░░▄▀░░░░░░░░░░█░░░░░░▄▀░░░░░░█░░▄▀░░█████████░░░░▄▀░░░░█░░▄▀░░░░░░░░░░█░░▄▀░░░░░░░░░░█
								█░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀░░█████████████░░▄▀░░█████░░▄▀░░███████████░░▄▀░░███░░▄▀░░█████████░░▄▀░░█████████
								█░░▄▀░░█████████░░▄▀░░░░░░▄▀░░█░░▄▀░░░░░░░░░░█████░░▄▀░░█████░░▄▀░░███████████░░▄▀░░███░░▄▀░░░░░░░░░░█░░▄▀░░░░░░░░░░█
								█░░▄▀░░█████████░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█████░░▄▀░░█████░░▄▀░░███████████░░▄▀░░███░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█
								█░░▄▀░░█████████░░▄▀░░░░░░▄▀░░█░░░░░░░░░░▄▀░░█████░░▄▀░░█████░░▄▀░░███████████░░▄▀░░███░░▄▀░░░░░░░░░░█░░▄▀░░░░░░░░░░█
								█░░▄▀░░█████████░░▄▀░░██░░▄▀░░█████████░░▄▀░░█████░░▄▀░░█████░░▄▀░░███████████░░▄▀░░███░░▄▀░░█████████░░▄▀░░█████████
								█░░▄▀░░░░░░░░░░█░░▄▀░░██░░▄▀░░█░░░░░░░░░░▄▀░░█████░░▄▀░░█████░░▄▀░░░░░░░░░░█░░░░▄▀░░░░█░░▄▀░░█████████░░▄▀░░░░░░░░░░█
								█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀░░██░░▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█████░░▄▀░░█████░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀░░█░░▄▀░░█████████░░▄▀▄▀▄▀▄▀▄▀░░█
								█░░░░░░░░░░░░░░█░░░░░░██░░░░░░█░░░░░░░░░░░░░░█████░░░░░░█████░░░░░░░░░░░░░░█░░░░░░░░░░█░░░░░░█████████░░░░░░░░░░░░░░█
								█████████████████████████████████████████████████████████████████████████████████████████████████████████████████████
]]
-- Config Starts here
announcerName = "[BREACH]" -- The name that shows up in chat when stuff is announced. example: [Breach-System] - SCP-106 is breaching containment
breachCMDPrefix = "!" -- The prefix of the breach command (!breach)
startCommand = "breach" -- The the breach command
stopCommand = "stopbreach" -- The the command that stops the breach
breachRadius = 128 -- The radius around the coordinates (in hammer units) that the SCP should be teleported to (Only applies to SCPs that have "breachAll" set to true)

AddSCP{
	teamName = "SCP-682", -- Team Name (Not the TEAM_ value, but the name itself) so if you have TEAM_SCP173, but the job name is "SCP-173 'Penut'", you would use the latter of the two.
	breachTime = 900, -- Timer for how long until the SCP breaches
	coolDown = 1800, -- Cooldown for after you stop your breach or when your timer is up.
	maintMsg = "A loud roar can be heard from SCP-682's chamber. He must be hungry. [15 Minutes]", -- Message Displayed when the Breach Timer starts
	breachMsg = "Monitors show SCP-682 breaking through his door. [BREACHED]", -- Message Displayed when the Breach Timer runs out
	halfWayMsg = "The sound of SCP-682 slamming against the doors can be heard. [7 Minutes]", -- Message Displayed when the Breach Timer is at its halfway mark.
	cancelMsg = "SCP-682 has fallen silent. [Breach Timer Stopped].", -- Message Displayed when the Breach Timer is canceled.
	announceBreach = true, -- Should it announce when the SCP has breached?
	announceMaint = true, -- Should it announce when the SCP starts their timer? 
	announceStop = true, -- Should it announce when the SCP stops their timer?
	breachAll = false, -- Should all players on this job breach or just one?
	breachPos = Vector( -1879.150757, 7746.541504, -297.968750 ) -- Position the SCP is teleported to.
}
AddSCP{
	teamName = "SCP-106", -- Team Name (Not the TEAM_ value, but the name itself) so if you have TEAM_SCP173, but the job name is "SCP-173 'Penut'", you would use the latter of the two.
	breachTime = 1200, -- Timer for how long until the SCP breaches
	coolDown = 1800, -- Cooldown for after you stop your breach or when your timer is up.
	maintMsg = "Monitors show SCP-106 becoming active. Prepare for the worst. [20 Minutes]", -- Message Displayed when the Breach Timer starts
	breachMsg = "Monitors show SCP-106 leaving through his sink hole. [BREACHED]", -- Message Displayed when the Breach Timer runs out
	halfWayMsg = "The sound of laughter can be heard from SCP-106's chamber. [10 Minutes]", -- Message Displayed when the Breach Timer is at its halfway mark.
	cancelMsg = "SCP-106 has returned to a dormant state. [Breach Timer Stopped]", -- Message Displayed when the Breach Timer is canceled.
	announceBreach = true, -- Should it announce when the SCP has breached?
	announceMaint = true, -- Should it announce when the SCP starts their timer? 
	announceStop = true, -- Should it announce when the SCP stops their timer?
	breachAll = false, -- Should all players on this job breach or just one?
	breachPos = Vector( -197.812515, 7690.088867, -446.468750 ) -- Position the SCP is teleported to.
}
AddSCP{
	teamName = "SCP-999", -- Team Name (Not the TEAM_ value, but the name itself) so if you have TEAM_SCP173, but the job name is "SCP-173 'Penut'", you would use the latter of the two.
	breachTime = 2, -- Timer for how long until the SCP breaches
	coolDown = 1800, -- Cooldown for after you stop your breach or when your timer is up.
	maintMsg = "", -- Message Displayed when the Breach Timer starts
	breachMsg = "SCP-999 is roaming the facility.", -- Message Displayed when the Breach Timer runs out
	halfWayMsg = "", -- Message Displayed when the Breach Timer is at its halfway mark.
	cancelMsg = "", -- Message Displayed when the Breach Timer is canceled.
	announceBreach = true, -- Should it announce when the SCP has breached?
	announceMaint = false, -- Should it announce when the SCP starts their timer? 
	announceStop = false, -- Should it announce when the SCP stops their timer?
	breachAll = false, -- Should all players on this job breach or just one?
	breachPos = Vector( -11428.234375, 10548.726562, -112.968750 ) -- Position the SCP is teleported to.
}
AddSCP{
	teamName = "SCP-131", -- Team Name (Not the TEAM_ value, but the name itself) so if you have TEAM_SCP173, but the job name is "SCP-173 'Penut'", you would use the latter of the two.
	breachTime = 2, -- Timer for how long until the SCP breaches
	coolDown = 1800, -- Cooldown for after you stop your breach or when your timer is up.
	maintMsg = "", -- Message Displayed when the Breach Timer starts
	breachMsg = "SCP-131 is roaming the facility.", -- Message Displayed when the Breach Timer runs out
	halfWayMsg = "", -- Message Displayed when the Breach Timer is at its halfway mark.
	cancelMsg = "", -- Message Displayed when the Breach Timer is canceled.
	announceBreach = true, -- Should it announce when the SCP has breached?
	announceMaint = false, -- Should it announce when the SCP starts their timer? 
	announceStop = false, -- Should it announce when the SCP stops their timer?
	breachAll = true, -- Should all players on this job breach or just one?
	breachPos = Vector( -11403.869141, 10697.424805, -63.968750 ) -- Position the SCP is teleported to.
}
AddSCP{
	teamName = "SCP-912 [Supporter]", -- Team Name (Not the TEAM_ value, but the name itself) so if you have TEAM_SCP173, but the job name is "SCP-173 'Penut'", you would use the latter of the two.
	breachTime = 2, -- Timer for how long until the SCP breaches
	coolDown = 1800, -- Cooldown for after you stop your breach or when your timer is up.
	maintMsg = "", -- Message Displayed when the Breach Timer starts
	breachMsg = "SCP-912 is roaming the facility.", -- Message Displayed when the Breach Timer runs out
	halfWayMsg = "", -- Message Displayed when the Breach Timer is at its halfway mark.
	cancelMsg = "", -- Message Displayed when the Breach Timer is canceled.
	announceBreach = true, -- Should it announce when the SCP has breached?
	announceMaint = false, -- Should it announce when the SCP starts their timer? 
	announceStop = false, -- Should it announce when the SCP stops their timer?
	breachAll = true, -- Should all players on this job breach or just one?
	breachPos = Vector( -11384.415039, 10914.045898, -63.968750 ) -- Position the SCP is teleported to.
}
AddSCP{
	teamName = "SCP-966", -- Team Name (Not the TEAM_ value, but the name itself) so if you have TEAM_SCP173, but the job name is "SCP-173 'Penut'", you would use the latter of the two.
	breachTime = 600, -- Timer for how long until the SCP breaches
	coolDown = 1800, -- Cooldown for after you stop your breach or when your timer is up.
	maintMsg = "Scratches can be heard from SCP-966s chamber. They must be hungry. [10 Minutes]", -- Message Displayed when the Breach Timer starts
	breachMsg = "IR sensors show SCP-966 breaking through their chamber door. [BREACHED]", -- Message Displayed when the Breach Timer runs out
	halfWayMsg = "SCP-966s scratches become louder. [5 Minutes]", -- Message Displayed when the Breach Timer is at its halfway mark.
	cancelMsg = "SCP-966s chamber falls silent. [Breach Timer Stopped]", -- Message Displayed when the Breach Timer is canceled.
	announceBreach = true, -- Should it announce when the SCP has breached?
	announceMaint = true, -- Should it announce when the SCP starts their timer? 
	announceStop = true, -- Should it announce when the SCP stops their timer?
	breachAll = true, -- Should all players on this job breach or just one?
	breachPos = Vector( -6396.848633, 12692.025391, -62.968750 ) -- Position the SCP is teleported to.
}
AddSCP{
	teamName = "SCP-049", -- Team Name (Not the TEAM_ value, but the name itself) so if you have TEAM_SCP173, but the job name is "SCP-173 'Penut'", you would use the latter of the two.
	breachTime = 600, -- Timer for how long until the SCP breaches
	coolDown = 1800, -- Cooldown for after you stop your breach or when your timer is up.
	maintMsg = "SCP-049 is requesting a test subject. [10 Minutes]", -- Message Displayed when the Breach Timer starts
	breachMsg = "Monitors show a -2 instance helping SCP-049 leave his chamber. [BREACHED]", -- Message Displayed when the Breach Timer runs out
	halfWayMsg = "SCP-049 is growing impatient. [5 Minutes]", -- Message Displayed when the Breach Timer is at its halfway mark.
	cancelMsg = "SCP-049 is content. [Breach Timer Stopped]", -- Message Displayed when the Breach Timer is canceled.
	announceBreach = true, -- Should it announce when the SCP has breached?
	announceMaint = true, -- Should it announce when the SCP starts their timer? 
	announceStop = true, -- Should it announce when the SCP stops their timer?
	breachAll = false, -- Should all players on this job breach or just one?
	breachPos = Vector( -6926.860352, 11350.541016, -62.013802 ) -- Position the SCP is teleported to.
}
AddSCP{
	teamName = "SCP-457 [Supporter]", -- Team Name (Not the TEAM_ value, but the name itself) so if you have TEAM_SCP173, but the job name is "SCP-173 'Penut'", you would use the latter of the two.
	breachTime = 600, -- Timer for how long until the SCP breaches
	coolDown = 1800, -- Cooldown for after you stop your breach or when your timer is up.
	maintMsg = "SCP-457s voice can be heard: FUEL GIVE ME FUEL! [10 Minutes]", -- Message Displayed when the Breach Timer starts
	breachMsg = "The fire alarms start blaring around SCP-457s chamber. [BREACHED]", -- Message Displayed when the Breach Timer runs out
	halfWayMsg = "SCP-457s demands for fuel grow louder. [5 Minutes]", -- Message Displayed when the Breach Timer is at its halfway mark.
	cancelMsg = "SCP-457s demands for fuel cease. [Breach Timer Stopped]", -- Message Displayed when the Breach Timer is canceled.
	announceBreach = true, -- Should it announce when the SCP has breached?
	announceMaint = true, -- Should it announce when the SCP starts their timer? 
	announceStop = true, -- Should it announce when the SCP stops their timer?
	breachAll = false, -- Should all players on this job breach or just one?
	breachPos = Vector( -8745.526367, 12430.473633, -62.968750 ) -- Position the SCP is teleported to.
}
AddSCP{
	teamName = "SCP-173", -- Team Name (Not the TEAM_ value, but the name itself) so if you have TEAM_SCP173, but the job name is "SCP-173 'Penut'", you would use the latter of the two.
	breachTime = 600, -- Timer for how long until the SCP breaches
	coolDown = 1800, -- Cooldown for after you stop your breach or when your timer is up.
	maintMsg = "A foul smell and violent scraping can be heard from SCP-173s chamber. It need cleaning. [10 Minutes]", -- Message Displayed when the Breach Timer starts
	breachMsg = "Monitors show SCP-173 leaving its containment chamber", -- Message Displayed when the Breach Timer runs out
	halfWayMsg = "SCP-173 begins pounding on its door. [5 Minutes]", -- Message Displayed when the Breach Timer is at its halfway mark.
	cancelMsg = "SCP-173 has fallen silent. [Breach Timer Stopped]", -- Message Displayed when the Breach Timer is canceled.
	announceBreach = true, -- Should it announce when the SCP has breached?
	announceMaint = true, -- Should it announce when the SCP starts their timer? 
	announceStop = true, -- Should it announce when the SCP stops their timer?
	breachAll = false, -- Should all players on this job breach or just one?
	breachPos = Vector( -8607.407227, 10377.031250, -62.968750 ) -- Position the SCP is teleported to.
}

AddSCP{
	teamName = "SCP-096", -- Team Name (Not the TEAM_ value, but the name itself) so if you have TEAM_SCP173, but the job name is "SCP-173 'Penut'", you would use the latter of the two.
	breachTime = 600, -- Timer for how long until the SCP breaches
	coolDown = 1800, -- Cooldown for after you stop your breach or when your timer is up.
	maintMsg = "The cries of SCP-096 can be heard from HCZ. His containment chamber needs cleaning [10 Minutes]", -- Message Displayed when the Breach Timer starts
	breachMsg = "Monitors show SCP-096 leaving its containment chamber [BREACHED]", -- Message Displayed when the Breach Timer runs out
	halfWayMsg = "SCP-096's cries grow louder. [5 Minutes]", -- Message Displayed when the Breach Timer is at its halfway mark.
	cancelMsg = "SCP-096 has stopped crying. [Breach Timer Stopped]", -- Message Displayed when the Breach Timer is canceled.
	announceBreach = true, -- Should it announce when the SCP has breached?
	announceMaint = true, -- Should it announce when the SCP starts their timer? 
	announceStop = true, -- Should it announce when the SCP stops their timer?
	breachAll = false, -- Should all players on this job breach or just one?
	breachPos = Vector( -7396.609863, 13295.885742, -62.968750 ) -- Position the SCP is teleported to.
}

AddSCP{
	teamName = "SCP-610", -- Team Name (Not the TEAM_ value, but the name itself) so if you have TEAM_SCP173, but the job name is "SCP-173 'Penut'", you would use the latter of the two.
	breachTime = 900, -- Timer for how long until the SCP breaches
	coolDown = 1800, -- Cooldown for after you stop your breach or when your timer is up.
	maintMsg = "SCP-610 containment failure in progress, maintain immediately. [15 minutes]", -- Message Displayed when the Breach Timer starts
	breachMsg = "SCP-610 has undergone a containment failure.", -- Message Displayed when the Breach Timer runs out
	halfWayMsg = "SCP-610 containment failure imminent. [7 minutes]", -- Message Displayed when the Breach Timer is at its halfway mark.
	cancelMsg = "SCP-610 containment stabilized.", -- Message Displayed when the Breach Timer is canceled.
	announceBreach = true, -- Should it announce when the SCP has breached?
	announceMaint = true, -- Should it announce when the SCP starts their timer? 
	announceStop = true, -- Should it announce when the SCP stops their timer?
	breachAll = false, -- Should all players on this job breach or just one?
	breachPos = Vector( -1892.255615, 8061.558594, -63.968750 ) -- Position the SCP is teleported to.
}

AddSCP{
	teamName = "SCP-076-2", -- Team Name (Not the TEAM_ value, but the name itself) so if you have TEAM_SCP173, but the job name is "SCP-173 'Penut'", you would use the latter of the two.
	breachTime = 900, -- Timer for how long until the SCP breaches
	coolDown = 1800, -- Cooldown for after you stop your breach or when your timer is up.
	maintMsg = "SCP-076-1 begins to groan. It will open any time now. [15 Minutes]", -- Message Displayed when the Breach Timer starts
	breachMsg = "Monitors show SCP-076-1 opening and Able exiting. [BREACHED]", -- Message Displayed when the Breach Timer runs out
	halfWayMsg = "Shouts can be heard from inside SCP-076-1. [7 Minutes]", -- Message Displayed when the Breach Timer is at its halfway mark.
	cancelMsg = "SCP-076 falls silent. [Breach Timer Cancelled]", -- Message Displayed when the Breach Timer is canceled.
	announceBreach = true, -- Should it announce when the SCP has breached?
	announceMaint = true, -- Should it announce when the SCP starts their timer? 
	announceStop = true, -- Should it announce when the SCP stops their timer?
	breachAll = false, -- Should all players on this job breach or just one?
	breachPos = Vector( -4380.669922, 8816.686523, -63.862000 ) -- Position the SCP is teleported to.
}

AddSCP{
	teamName = "SCP-1048", -- Team Name (Not the TEAM_ value, but the name itself) so if you have TEAM_SCP173, but the job name is "SCP-173 'Penut'", you would use the latter of the two.
	breachTime = 900, -- Timer for how long until the SCP breaches
	coolDown = 1800, -- Cooldown for after you stop your breach or when your timer is up.
	maintMsg = "SCP-1048 wants a playmate. [15 Minutes]", -- Message Displayed when the Breach Timer starts
	breachMsg = "Monitors show SCP-1048 building a ladder out of paper and climbing out of its chamber. [BREACHED]", -- Message Displayed when the Breach Timer runs out
	halfWayMsg = "SCP-1048 is getting impatient, it wants to play now! [7 Minutes]", -- Message Displayed when the Breach Timer is at its halfway mark.
	cancelMsg = "SCP-1048 found something to do. [Breach Timer Cancelled]", -- Message Displayed when the Breach Timer is canceled.
	announceBreach = true, -- Should it announce when the SCP has breached?
	announceMaint = true, -- Should it announce when the SCP starts their timer? 
	announceStop = true, -- Should it announce when the SCP stops their timer?
	breachAll = false, -- Should all players on this job breach or just one?
	breachPos = Vector( -6361.997070, 9284.278320, -63.968750 ) -- Position the SCP is teleported to.
}

AddSCP{
	teamName = "SCP-3199", -- Team Name (Not the TEAM_ value, but the name itself) so if you have TEAM_SCP173, but the job name is "SCP-173 'Penut'", you would use the latter of the two.
	breachTime = 900, -- Timer for how long until the SCP breaches
	coolDown = 1800, -- Cooldown for after you stop your breach or when your timer is up.
	maintMsg = "SCP-3199 containment failure in progress, maintain immediately. [15 minutes]", -- Message Displayed when the Breach Timer starts
	breachMsg = "SCP-3199 has undergone a containment failure [BREACHED]", -- Message Displayed when the Breach Timer runs out
	halfWayMsg = "SCP-3199 containment failure imminent. [7 minutes]", -- Message Displayed when the Breach Timer is at its halfway mark.
	cancelMsg = "SCP-3199 containment stabilized.[Breach Timer Cancelled]", -- Message Displayed when the Breach Timer is canceled.
	announceBreach = true, -- Should it announce when the SCP has breached?
	announceMaint = true, -- Should it announce when the SCP starts their timer? 
	announceStop = true, -- Should it announce when the SCP stops their timer?
	breachAll = true, -- Should all players on this job breach or just one?
	breachPos = Vector( -5795.434082, 6824.346191, -63.968750 ) -- Position the SCP is teleported to.
}

AddSCP{
	teamName = "SCP-082", -- Team Name (Not the TEAM_ value, but the name itself) so if you have TEAM_SCP173, but the job name is "SCP-173 'Penut'", you would use the latter of the two.
	breachTime = 600, -- Timer for how long until the SCP breaches
	coolDown = 1800, -- Cooldown for after you stop your breach or when your timer is up.
	maintMsg = "SCP-082 containment failure in progress, maintain immediately. [10 minutes]", -- Message Displayed when the Breach Timer starts
	breachMsg = "SCP-082 has undergone a containment failure [BREACHED]", -- Message Displayed when the Breach Timer runs out
	halfWayMsg = "SCP-082 containment failure imminent. [5 minutes]", -- Message Displayed when the Breach Timer is at its halfway mark.
	cancelMsg = "SCP-082 containment stabilized.[Breach Timer Cancelled]", -- Message Displayed when the Breach Timer is canceled.
	announceBreach = true, -- Should it announce when the SCP has breached?
	announceMaint = true, -- Should it announce when the SCP starts their timer? 
	announceStop = true, -- Should it announce when the SCP stops their timer?
	breachAll = false, -- Should all players on this job breach or just one?
	breachPos = Vector( -6219.217773, 12411.179688, -62.968750 ) -- Position the SCP is teleported to.

}
-- Config ends here




-- vvvvvvvvvvvvvvvvvvvvvv Don't touch this if you don't know what you're doing vvvvvvvvvvvvvvvvvvvvvv
hook.Add( "PlayerSay", "BreachCommands", function( talker, text )
	
	local playerTeam = team.GetName( talker:Team() )
	local teamTable = breachList[ playerTeam ]
	
	if ( string.lower( text ) == breachCMDPrefix .. startCommand ) then -- Checks if the player did the command
		
		
		if teamTable then
			breachingTeam = talker:Team()
			
			if timer.Exists( "breachTimer"..breachingTeam ) then
				talker:ChatPrint( "You are already breaching! You will breach in " .. math.ceil( timer.TimeLeft( "breachTimer"..breachingTeam ) ) .. " seconds!" )
				return ""
			elseif timer.Exists( "breachCooldown"..breachingTeam ) then
				talker:ChatPrint( "You are on cooldown! You must wait " .. math.ceil( timer.TimeLeft( "breachCooldown"..breachingTeam ) ) .. " seconds!" )
				return ""
			else
				if teamTable.announceMaint == true then
					for _, ply in pairs( player.GetAll() ) do -- Prints a server-wide message telling everybody about the timer starting
						ply:ChatPrint( "[ " .. announcerName .. " ] - " .. teamTable.maintMsg )
					end
				end
				talker:ChatPrint( "Breach Timer Started." )
	
				timer.Create( "breachCooldown"..breachingTeam, teamTable.breachTime + teamTable.coolDown, 1, function() -- Creates the cooldown timer
					talker:ChatPrint( "You may use the breach command again." )
					timer.Remove( "breachCooldown"..breachingTeam ) -- Destroys the timer so you don't have 20 of them created at once.
				end )
	
				timer.Create( "breachTimer"..breachingTeam, teamTable.breachTime, 1, function() -- Creates the breach timer
					if teamTable.announceBreach == true then
						for _, ply in pairs( player.GetAll( )) do
							ply:ChatPrint( "[ " .. announcerName .. " ] - " .. teamTable.breachMsg )
						end
					end
	
					if teamTable.breachAll == true then -- Checks if this is an SCP with multiple players
						for _, ply in pairs( player.GetAll() ) do
							local radius = Vector( math.random(-breachRadius, breachRadius), math.random( -breachRadius, breachRadius ), 0 )
							if ply:Team() == breachingTeam then
								ply:SetPos( teamTable.breachPos + radius ) -- Teleports the player
								ply:ChatPrint( "You have breached containment!" )
							end
						end
						
					else
						talker:SetPos( teamTable.breachPos )
						talker:ChatPrint( "You have breached containment!" )
					end
	
					timer.Start( "breachCooldown"..breachingTeam )
					timer.Remove( "breachTimer"..breachingTeam )
				end )
				
				timer.Create( "breachTimerHalf"..breachingTeam, teamTable.breachTime / 2, 1, function() -- Creates the breach timer
					if teamTable.announceMaint == true then
						for _, ply in pairs( player.GetAll( )) do
							ply:ChatPrint( "[ " .. announcerName .. " ] - " .. teamTable.halfWayMsg )
						end
					end

					timer.Remove( "breachTimerHalf"..breachingTeam )
				end )
	
				--timer.Start( "breachTimerHalf"..breachingTeam ) 
				--timer.Start( "breachTimer"..breachingTeam ) 
	
			end
				
		else
				talker:ChatPrint( "You don't have access to this command!" )
			return ""
		end
		
		return ""

	elseif ( string.lower( text ) == breachCMDPrefix .. stopCommand ) then
		if teamTable then
			if timer.Exists( "breachTimer"..breachingTeam ) then -- Checks if the timer is even running
				timer.Stop( "breachTimer"..breachingTeam )
				timer.Remove( "breachTimer"..breachingTeam )
				if timer.Exists( "breachTimerHalf"..breachingTeam ) then
					timer.Stop( "breachTimerHalf"..breachingTeam )
					timer.Remove( "breachTimerHalf"..breachingTeam )
				end
				if not timer.Exists( "breachCooldown"..breachingTeam ) then
					timer.Start( "breachCooldown"..breachingTeam )
				end
				talker:ChatPrint( "You have stopped your breach timer!" )
				if teamTable.announceStop == true then
					for _, ply in pairs( player.GetAll() ) do -- Prints a server-wide message talling everybody about the timer starting
						ply:ChatPrint( "[ " .. announcerName .. " ] - " .. teamTable.cancelMsg )
					end
				end
			else
				talker:ChatPrint( "You aren't currently breaching!" )
			end
			return ""
		else
			talker:ChatPrint( "You do not have access to this command!" )
			return ""
		end
	end
	
end )

hook.Add( "PlayerChangedTeam", "RemoveTimersOnFlag", function( ply, oldTeam, newTeam )
	local oldTeamName = team.GetName( oldTeam )
	local newTeamName = team.GetName( newTeam )
	
	local oldTable = breachList[ oldTeamName ]
	local teamTable = breachList[ newTeamName ]
	local count = 0
	
	if oldTable then
		if timer.Exists( "breachTimer"..oldTeam ) or timer.Exists( "breachTimerHalf"..oldTeam ) then
			if oldTable.breachAll == true then -- Checks if this is an SCP with multiple players
				for _, players in pairs( player.GetAll() ) do
					local playerTable = breachList[ team.GetName( players:Team() ) ]
					if playerTable then
						count = count + 1
					end
				end
				if count > 1 then
					return
				end
			end			
			
			if oldTable.announceStop == true then
				for _, ply in pairs( player.GetAll() ) do -- Prints a server-wide message talling everybody about the timer starting
					ply:ChatPrint( "[ " .. announcerName .. " ] - " .. oldTable.cancelMsg .. " (Changed Jobs)" )
				end
			end
			
			timer.Stop( "breachTimer"..oldTeam )
			timer.Remove( "breachTimer"..oldTeam )
			timer.Stop( "breachTimerHalf"..oldTeam )
			timer.Remove( "breachTimerHalf"..oldTeam )
			timer.Start( "breachCooldown"..oldTeam )
		end
		
	elseif teamTable then
	
		ply:ChatPrint( "Use " .. breachCMDPrefix .. startCommand .. " to breach." )
		ply:ChatPrint( "Use " .. breachCMDPrefix .. stopCommand .. " to stop your breach timer." )
		
	else
		return
	end
	
end )

hook.Add( "PlayerDisconnected", "RemoveTimersOnLeave", function( ply )
	local teamName = team.GetName( ply:Team() )
	local teamTable = breachList[ teamName ]
	local count = 0
	
	if teamTable then
		if timer.Exists( "breachTimer" .. ply:Team() ) or timer.Exists( "breachTimerHalf" .. ply:Team() ) then
			if teamTable.breachAll == true then -- Checks if this is an SCP with multiple players
				for _, players in pairs( player.GetAll() ) do
					local playerTable = breachList[ team.GetName( players:Team() ) ]
					if playerTable then
						count = count + 1
					end
				end
				if count > 1 then
					return
				end
			end			
			
			if teamTable.announceStop == true then
				for _, ply in pairs( player.GetAll() ) do -- Prints a server-wide message talling everybody about the timer starting
					ply:ChatPrint( "[ " .. announcerName .. " ] - " .. teamTable.cancelMsg .. " (Disconnected)" )
				end
			end
			
			timer.Stop( "breachTimer" .. ply:Team() )
			timer.Remove( "breachTimer" .. ply:Team() )
			timer.Stop( "breachTimerHalf" .. ply:Team() )
			timer.Remove( "breachTimerHalf" .. ply:Team() )
			timer.Start( "breachCooldown" .. ply:Team() )
		end
		
	else
		return
	end
	
end )