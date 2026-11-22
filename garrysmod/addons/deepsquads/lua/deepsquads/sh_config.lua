DeepSquads.Config = {}

DeepSquads.Config.DefaultColor = Color(41,152,237)
DeepSquads.Config.SquadChatColor = Color(35,121,187)
DeepSquads.Config.MenuBG = Color(30,30,30,150)
DeepSquads.Config.MenuBGDark = Color(20,20,20,200)
DeepSquads.Config.MenuBGLight = Color(50,50,50,75)
DeepSquads.Config.MenuBGLighter = Color(75,75,75,150)
DeepSquads.Config.MenuBGLighterAlt = Color(90,90,90,150)
DeepSquads.Config.LeaderColor = Color(112,231,82)
DeepSquads.Config.ListenColor = Color(209,114,114) -- Spy comms will appear as this color

DeepSquads.Config.JobTags = {
    -- "Spy" can hear ALL squad comms at all times, useful for staff or 079 or a CI comms spy or something
    -- "Spy" does not count as a squad tag (but can be used with other tags), it is only for being able to spy on all comms
    -- Any job without an entry here will be barred from creating or joining any squads
    ["SOD"] = {"Spy"},
    ["SCP-079"] = {"Spy", "SCPs"},

    ["Site Director"] = {"Foundation", "Security", "FE", "Research", "MTF"},
    ["Site Deputy Director"] = {"Foundation", "Security", "FE", "Research", "MTF"},
    ["Regional Inspector"] = {"Foundation", "Security", "FE", "Research", "MTF"},
    ["MTF E-11 'Nine Tailed Fox'"] = {"Foundation", "MTF"},
    ["Foundation Media Specialist"] = {"Foundation"},
  

    ["Quick Response Unit"] = {"Foundation", "Security"},
    ["Security Medical Team"] = {"Foundation", "Security"},
    ["Security Warden"] = {"Foundation", "Security"},
    ["Security Heavy Unit"] = {"Foundation", "Security"},
    ["Riot Team Unit [VIP]"] = {"Foundation", "Security"},
    ["Security Quartermaster [Supporter]"] = {"Foundation", "Security"},
    ["Security Recruit"] = {"Foundation", "Security"},
    ["Cadet"] = {"Foundation", "Security"},
    ["Officer"] = {"Foundation", "Security"},
    ["Junior Specialist"] = {"Foundation", "Security"},
    ["Specialist"] = {"Foundation", "Security"},
    ["Lance Corporal"] = {"Foundation", "Security"},
    ["Corporal"] = {"Foundation", "Security"},
    ["Sergeant"] = {"Foundation", "Security"},
    ["Staff Sergeant"] = {"Foundation", "Security"},
    ["Master Sergeant"] = {"Foundation", "Security"},
    ["Lieutenant"] = {"Foundation", "Security"},
    ["Captain"] = {"Foundation", "Security"},
    ["Deputy Chief"] = {"Foundation", "Security"},
    ["Chief Of Security"] = {"Foundation", "Security"},

    ["Probationary Officer"] = {"Foundation", "FE"},
    ["F.E. Rifleman"] = {"Foundation", "FE"},
    ["F.E. CQC Specialist"] = {"Foundation", "FE"},
    ["F.E. Enforcer (Supporter)"] = {"Foundation", "FE"},
    ["F.E. Field Marshal"] = {"Foundation", "FE"},
    ["S.W.A.T"] = {"Foundation", "FE"},
    ["F.E. Non-Commissioned Officer"] = {"Foundation", "FE"},
    ["F.E. Commissioned Officer"] = {"Foundation", "FE"},
    ["F.E. Grand Marshal"] = {"Foundation", "FE"},
    ["F.E. Courier (VIP)"] = {"Foundation", "FE"},
    ["F.E. Investigator"] = {"Foundation", "FE"},

    ["Research Intern"] = {"Foundation", "Research"},
    ["Apprentice Researcher"] = {"Foundation", "Research"},
    ["Junior Researcher"] = {"Foundation", "Research"},
    ["Researcher"] = {"Foundation", "Research"},
    ["Senior Researcher"] = {"Foundation", "Research"},
    ["Research Advisor"] = {"Foundation", "Research"},
    ["Research Supervisor"] = {"Foundation", "Research"},
    ["Research Overseer"] = {"Foundation", "Research"},
    ["Deputy Director Of Research"] = {"Foundation", "Research"},
    ["Director Of Research"] = {"Foundation", "Research"},

    ["Delta-5 Combat Engineer"] = {"Foundation", "MTF"},
    ["Delta-5 Containment Specialist"] = {"Foundation", "MTF"},
    ["Delta-5 Lancer"] = {"Foundation", "MTF"},
    ["Delta-5 Medic"] = {"Foundation", "MTF"},
    ["Delta-5 Overwatch"] = {"Foundation", "MTF"},
    ["Epsilon-6 Rifleman"] = {"Foundation", "MTF"},
    ["Nu-7 Commando"] = {"Foundation", "MTF"},
    ["Nu-7 Grenadier"] = {"Foundation", "MTF"},
    ["Nu-7 Heavy Weapons Operator"] = {"Foundation", "MTF"},
    ["Nu-7 Motor Transport Specialist"] = {"Foundation", "MTF"},
    ["MTF Vice Commander"] = {"Foundation", "MTF"},
    ["MTF Commander"] = {"Foundation", "MTF"},
    ["MTF Non-Commissioned Officer"] = {"Foundation", "MTF"},
    ["MTF Commissioned Officer"] = {"Foundation", "MTF"},

    ["D-Class Miner"] = {"D-Class"},
    ["Class-D Personnel"] = {"D-Class"},
    ["Janitor"] = {"D-Class"},
    ["Big Rich [Euclid VIP]"] = {"D-Class"},
    ["Class-D Commander [Thaumiel VIP]"] = {"D-Class"},
    ["D-Class Pizza Chef"] = {"D-Class"},
    ["Little Ricky [Keter VIP]"] = {"D-Class"},

    ["C.I. Conscript"] = {"CI"},
    ["C.I. Pyromaniac"] = {"CI"},
    ["C.I. Hammer Unit"] = {"CI"},
    ["C.I. Corpsman"] = {"CI"},
    ["C.I. Invader"] = {"CI"},
    ["C.I. Demolisher"] = {"CI"},
    ["C.I. Raider"] = {"CI"},
    ["C.I. Sharpshooter"] = {"CI"},
    ["C.I. Elite"] = {"CI"},
    ["C.I. Researcher"] = {"CI"},
    ["C.I. War Rig Operator"] = {"CI"},
    ["C.I. Vice Commander"] = {"CI"},
    ["C.I. Commander"] = {"CI"},

    ["SCP-610"] = {"SCPs"},
    ["SCP-173"] = {"SCPs"},
    ["SCP-049"] = {"SCPs"},
    ["SCP-076-2"] = {"SCPs"},
    ["SCP-999"] = {"SCPs"},
    ["SCP-035"] = {"SCPs"},
    ["SCP-106"] = {"SCPs"},
    ["SCP-682"] = {"SCPs"},
    ["SCP-096"] = {"SCPs"},
    ["SCP-912 [Euclid Rank]"] = {"SCPs"},
    ["SCP-066 [Euclid Rank]"] = {"SCPs"},
    ["SCP-343 [Euclid Rank]"] = {"SCPs"},
    ["SCP-966"] = {"SCPs"},
    ["SCP-939"] = {"SCPs"},
    ["SCP-131-A"] = {"SCPs"},
    ["SCP-131-B"] = {"SCPs"},
    ["SCP-457"] = {"SCPs"},
    ["SCP-1048"] = {"SCPs"},
    ["SCP-1048-A"] = {"SCPs"},
    ["SCP-372"] = {"SCPs"},
    ["SCP-280"] = {"SCPs"},
    ["SCP-053"] = {"SCPs"},

    ["Emergency Response Unit [Keter VIP]"] = {"Foundation", "MTF"},
  
    ["Citizen"] = {"Citizens"},
}

MsgC("[Deep Squads]", DeepSquads.Success, " Config initialized.\n") -- EOF