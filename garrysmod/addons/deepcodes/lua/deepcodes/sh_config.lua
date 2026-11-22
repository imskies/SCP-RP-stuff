DeepCodes.Jobs = {
    ["SOD"] = true,
    ["Site Director"] = true,
    ["Site Deputy Director"] = true,
    ["Regional Inspector"] = true,
    ["Chief of Security"] = true,
    ["Deputy Chief"] = true,
    ["Captain"] = true,
    ["Lieutenant"] = true,
    ["Master Sergeant"] = true,
    ["Staff Sergeant"] = true,
    ["Sergeant"] = true,
    ["F.E. Grand Marshal"] = true,
    ["F.E. Field Marshal"] = true,
    ["F.E. Commissioned Officer"] = true,
    ["F.E. Non-Commissioned Officer"] = true,
    ["S.W.A.T"] = true,
    ["Director of Research"] = true,
    ["Deputy Director of Research"] = true,
    ["Research Overseer"] = true,
    ["Research Supervisor"] = true,
    ["Research Advisor"] = true,
    ["MTF Commander"] = true,
    ["MTF Vice Commander"] = true,
    ["MTF Commissioned Officer"] = true,
    ["MTF Non-Commissioned Officer"] = true,
}

DeepCodes.DBJobs = {
    ["SOD"] = true,
    ["Site Director"] = true,
    ["Site Deputy Director"] = true,
    ["Regional Inspector"] = true,
    ["Chief Of Security"] = true,
    ["Deputy Chief"] = true,
    ["Captain"] = true,
    ["Lieutenant"] = true,
    ["Master Sergeant"] = true,
    ["Staff Sergeant"] = true,
    ["Sergeant"] = true,
    ["Security Warden"] = true,
}

DeepCodes.AdminGroups = {
    ["superadmin"] = true,
	["admin"] = true,
	["junioradmin"] = true,
}

DeepCodes.Codes = {
    ["green"] = Color(42, 219, 22),
	["lime"] = Color(180, 245, 0),
    ["yellow"] = Color(216, 219, 18),
    ["orange"] = Color(219, 145, 18),
    ["red"] = Color(194, 35, 23),
    ["black"] = Color(187, 187, 187),
	["purple"] = Color(106,34,199),
	["white"] = Color(255,255,255),
	["briefing"] = Color(0,100,255),
	["compromised"] = Color(100,0,0),
	["a-d"] = Color(0,0,0),
	["brown"] = Color(129,85,47)
}

DeepCodes.DBlockCodes = {
    ["lockdown"] = {
		"Lockdown",
		Color(231, 33, 33)
	},
    ["freetime"] = {
		"Free Time",
		Color(33, 231, 92)
	},
	["meal"] = {
		"Meal Time",
		Color(128, 49, 3)
	},
	["exercise"] = {
		"Exercise Time",
		Color(0, 255, 255)
	},
	["shower"] = {
		"Shower Time",
		Color(0, 100, 255)
	},
	["work"] = {
		"Work Time",
		Color(255, 100, 0)
	},
	["sleep"] = {
		"Sleep Time",
		Color(220, 220, 220)
	},
	["headcount"] = {
		"Head Count",
		Color(90, 90, 90)
	},
	["evacuation"] = {
		"Evacuation",
		Color(100, 0, 0)
	},
}

MsgC("[Deep Codes]",DeepCodes.Success, " Config initialized.\n") -- EOF