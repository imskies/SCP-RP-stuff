PsychEval = PsychEval or {}

-- Teams allowed to create schedule entries (Research command)
PsychEval.ScheduleCreateAllowedTeams = {
    ["Research Advisor"]                = true,
    ["Research Supervisor"]             = true,
    ["Research Overseer"]               = true,
    ["Deputy Director Of Research"]     = true,
    ["Deputy Director of Research"]     = true,
    ["Director Of Research"]            = true,
    ["Director of Research"]            = true,
    ["Site Deputy Director"]            = true,
    ["Site Director"]                   = true
}

-- Access levels for the Psych Eval UI (separate from test clearance)
PsychEval.AccessByTeamName = {
    ["Research Intern"]                 = 1,
    ["Apprentice Researcher"]           = 1,
    ["Junior Researcher"]               = 1,
    ["Researcher"]                      = 1,
    ["Senior Researcher"]               = 2,
    ["Psychologist"]                    = 3,
    ["Biologist"]                       = 1,
    ["Research Advisor"]                = 3,
    ["Research Supervisor"]             = 3,
    ["Research Overseer"]               = 3,
    ["Deputy Director Of Research"]     = 3,
    ["Deputy Director of Research"]     = 3,
    ["Director Of Research"]            = 3,
    ["Site Deputy Director"]            = 3,
    ["Site Director"]                   = 3,
}

PsychEval.AccessByTeamID = {}

PsychEval.DataFile = "psych_eval_system/evals.json"

PsychEval.ClearanceByTeamName = {
    ["Research Intern"]                 = 1,
    ["Apprentice Researcher"]           = 1,
    ["Junior Researcher"]               = 1,
    ["Researcher"]                      = 2,
    ["Senior Researcher"]               = 2,
    ["Biologist"]                       = 2,
    ["Psychologist"]                    = 2,
    ["Research Advisor"]                = 3,
    ["Research Supervisor"]             = 3,
    ["Research Overseer"]               = 4,
    ["Deputy Director Of Research"]     = 5,
    ["Deputy Director of Research"]     = 5,
    ["Director Of Research"]            = 6,
    ["Director of Research"]            = 6,
    ["Site Deputy Director"]            = 6,
    ["Site Director"]                   = 6,
}

PsychEval.ClearanceByTeamID = {}

PsychEval.MaxAssignableClearanceByTeamName = {
    ["Research Intern"]                 = 1,
    ["Apprentice Researcher"]           = 1,
    ["Junior Researcher"]               = 1,
    ["Researcher"]                      = 2,
    ["Senior Researcher"]               = 2,
    ["Biologist"]                       = 2,
    ["Psychologist"]                    = 2,
    ["Research Advisor"]                = 3,
    ["Research Supervisor"]             = 3,
    ["Research Overseer"]               = 4,
    ["Deputy Director Of Research"]     = 5,
    ["Deputy Director of Research"]     = 5,
    ["Director Of Research"]            = 6,
    ["Director of Research"]            = 6,
    ["Site Deputy Director"]            = 6,
    ["Site Director"]                   = 6,
}

PsychEval.GradeAllowedTeams = {
    "Research Advisor",
    "Research Supervisor",
    "Research Overseer",
    "Deputy Director Of Research",
    "Director of Research"
}

PsychEval.DefaultClearance = 1
PsychEval.DefaultAccess = 1

PsychEval.MinClearanceToOpenTests = 1
PsychEval.MinAccessToOpenEvals = 2

PsychEval.AllowedGrades = {"A","B","C","D","E","F"}

PsychEval.ClearanceNames = {
    [0] = "No Access",
    [1] = "Clearance 1",
    [2] = "Clearance 2",
    [3] = "Clearance 3",
    [4] = "Clearance 4",
    [5] = "Clearance 5",
    [6] = "Clearance 6"
}

PsychEval.RequireTeamListedToOpenPC = true
PsychEval.AllowPCOpenersToSubmitTests = true

-- Bio Logs permissions
PsychEval.BioCreateAllowedTeams = {
    ["Biologist"]                       = true,
    ["Research Advisor"]                = true,
    ["Research Supervisor"]             = true,
    ["Research Overseer"]               = true,
    ["Deputy Director Of Research"]     = true,
    ["Deputy Director of Research"]     = true,
    ["Director Of Research"]            = true,
    ["Director of Research"]            = true,
    ["Site Deputy Director"]            = true,
    ["Site Director"]                   = true,
}

PsychEval.BioViewAllowedTeams = {
    ["Senior Researcher"]               = true,
    ["Biologist"]                       = true,
    ["Research Advisor"]                = true,
    ["Research Supervisor"]             = true,
    ["Research Overseer"]               = true,
    ["Deputy Director Of Research"]     = true,
    ["Deputy Director of Research"]     = true,
    ["Director Of Research"]            = true,
    ["Director of Research"]            = true,
    ["Site Deputy Director"]            = true,
    ["Site Director"]                   = true,
}

-- New: teams allowed to delete entries (bio logs, psych evals, test logs).
-- Exact team name strings; server also allows server admins (ply:IsAdmin()).
PsychEval.DeleteAllowedTeams = {
    ["Research Advisor"]                = true,
    ["Research Supervisor"]             = true,
    ["Research Overseer"]               = true,
    ["Deputy Director Of Research"]     = true,
    ["Deputy Director of Research"]     = true,
    ["Director Of Research"]            = true,
    ["Director of Research"]            = true,
    ["Site Deputy Director"]            = true,
    ["Site Director"]                   = true,
}

function PsychEval.GetMaxAssignableClearanceForTeamName(teamName)
    if not teamName then return PsychEval.DefaultClearance end
    if PsychEval.MaxAssignableClearanceByTeamName[teamName] then
        return PsychEval.MaxAssignableClearanceByTeamName[teamName]
    end
    if PsychEval.ClearanceByTeamName[teamName] then
        return PsychEval.ClearanceByTeamName[teamName]
    end
    return PsychEval.DefaultClearance
end