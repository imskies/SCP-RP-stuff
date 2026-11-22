PsychEval = PsychEval or {}
PsychEval.Evals = PsychEval.Evals or {}

local dataFile = PsychEval.DataFile or "psych_eval_system/evals.json"

-- Load / Save
function PsychEval.LoadEvals()
    if not file.Exists("psych_eval_system", "DATA") then
        file.CreateDir("psych_eval_system")
    end

    if not file.Exists(dataFile, "DATA") then
        file.Write(dataFile, util.TableToJSON({}, true))
        PsychEval.Evals = {}
        return
    end

    local raw = file.Read(dataFile, "DATA") or "{}"
    local ok, tbl = pcall(util.JSONToTable, raw)
    if ok and type(tbl) == "table" then
        PsychEval.Evals = tbl
    else
        PsychEval.Evals = {}
        file.Write(dataFile, util.TableToJSON({}, true))
        print("[Research Computer] Warning: failed to parse eval data, resetting file.")
    end
end

function PsychEval.SaveEvals()
    if not file.Exists("psych_eval_system", "DATA") then
        file.CreateDir("psych_eval_system")
    end
    file.Write(dataFile, util.TableToJSON(PsychEval.Evals, true))
end

-- Robust helper: resolve a player's team name string in a consistent way
-- Returns: resolvedName (string), source (string: "team.GetName" or "fallback")
function PsychEval.ResolvePlayerTeamName(ply)
    if not IsValid(ply) or not ply:IsPlayer() then
        return tostring(ply and ply:Team() or "unknown"), "invalid-player"
    end

    if team and team.GetName then
        local tn = team.GetName(ply:Team())
        if tn and tn ~= "" then
            return tn, "team.GetName"
        end
    end

    return tostring(ply:Team()), "fallback"
end

-- Access level lookup (uses resolved team name)
function PsychEval.GetAccessLevel(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return PsychEval.DefaultAccess or 1 end

    local teamID = ply:Team()
    if PsychEval.AccessByTeamID and PsychEval.AccessByTeamID[teamID] then
        return PsychEval.AccessByTeamID[teamID]
    end

    local teamName = PsychEval.ResolvePlayerTeamName(ply)
    if PsychEval.AccessByTeamName and PsychEval.AccessByTeamName[teamName] then
        return PsychEval.AccessByTeamName[teamName]
    end

    return PsychEval.DefaultAccess or 1
end

-- Player clearance lookup (explicit, returns 0..6)
function PsychEval.GetPlayerClearance(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return PsychEval.DefaultClearance or 1 end

    local teamID = ply:Team()
    if PsychEval.ClearanceByTeamID and PsychEval.ClearanceByTeamID[teamID] then
        return PsychEval.ClearanceByTeamID[teamID]
    end

    local teamName = PsychEval.ResolvePlayerTeamName(ply)
    if PsychEval.ClearanceByTeamName and PsychEval.ClearanceByTeamName[teamName] then
        return PsychEval.ClearanceByTeamName[teamName]
    end

    return PsychEval.DefaultClearance or 1
end

-- Max assignable clearance for a player (server authoritative)
function PsychEval.GetPlayerMaxAssignableClearance(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return PsychEval.DefaultClearance or 1 end

    local teamName = PsychEval.ResolvePlayerTeamName(ply)

    if PsychEval.MaxAssignableClearanceByTeamName and PsychEval.MaxAssignableClearanceByTeamName[teamName] then
        return PsychEval.MaxAssignableClearanceByTeamName[teamName]
    end

    if PsychEval.ClearanceByTeamName and PsychEval.ClearanceByTeamName[teamName] then
        return PsychEval.ClearanceByTeamName[teamName]
    end

    return PsychEval.DefaultClearance or 1
end

-- Grade permission
function PsychEval.CanGrade(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end

    local teamName = PsychEval.ResolvePlayerTeamName(ply)
    for _, allowed in ipairs(PsychEval.GradeAllowedTeams or {}) do
        if allowed == teamName then return true end
    end

    return false
end

-- Return a shallow copy of the evals table (safe to send to clients)
function PsychEval.GetEvals()
    local copy = {}
    for i, v in ipairs(PsychEval.Evals or {}) do
        copy[i] = table.Copy(v)
    end
    return copy
end

-- Add a new evaluation entry
function PsychEval.AddEval(entry, ply)
    local valid, err = PsychEval.ValidateEntry(entry)
    if not valid then return nil, err end

    if entry.grade and not PsychEval.CanGrade(ply) then
        entry.grade = nil
    end

    entry.createdBy = IsValid(ply) and ply:SteamID() or "SERVER"
    entry.createdAt = os.time()

    table.insert(PsychEval.Evals, entry)
    PsychEval.SaveEvals()
    return #PsychEval.Evals
end

-- Edit an existing evaluation at index
function PsychEval.EditEval(index, newEntry, ply)
    if type(index) ~= "number" or index < 1 or index > #PsychEval.Evals then
        return false, "invalid index"
    end

    local valid, err = PsychEval.ValidateEntry(newEntry)
    if not valid then return false, err end

    if newEntry.grade and not PsychEval.CanGrade(ply) then
        local old = PsychEval.Evals[index] or {}
        newEntry.grade = old.grade
    end

    newEntry.modifiedBy = IsValid(ply) and ply:SteamID() or "SERVER"
    newEntry.modifiedAt = os.time()

    PsychEval.Evals[index] = newEntry
    PsychEval.SaveEvals()
    return true
end

-- Remove an entry
function PsychEval.RemoveEval(index)
    if type(index) ~= "number" or index < 1 or index > #PsychEval.Evals then
        return false
    end
    table.remove(PsychEval.Evals, index)
    PsychEval.SaveEvals()
    return true
end

-- Validate incoming entry structure and values
function PsychEval.ValidateEntry(entry)
    if type(entry) ~= "table" then return false, "entry must be a table" end

    local isTest = entry.clearance ~= nil or entry.scores ~= nil or entry.name ~= nil

    if isTest then
        if not entry.name or type(entry.name) ~= "string" or entry.name:Trim() == "" then
            return false, "missing Test Name"
        end

        if not entry.subject or type(entry.subject) ~= "string" or entry.subject:Trim() == "" then
            return false, "missing Subject"
        end

        if not entry.date or type(entry.date) ~= "string" or entry.date:Trim() == "" then
            return false, "missing Date"
        end

        local clearance = tonumber(entry.clearance) or nil
        if clearance == nil or clearance < 0 or clearance > 6 then
            return false, "invalid Clearance Level"
        end
        entry.clearance = math.floor(clearance)

        if entry.notes == nil then entry.notes = "" end
        if type(entry.notes) ~= "string" then entry.notes = tostring(entry.notes) end

        if entry.scores ~= nil then
            if type(entry.scores) ~= "table" then
                return false, "scores must be a table"
            end
            local cleaned = {}
            for _, s in ipairs(entry.scores) do
                local n = tonumber(s)
                if n then table.insert(cleaned, n) end
            end
            entry.scores = cleaned
        end

        if entry.grade ~= nil and entry.grade ~= "" then
            local g = tostring(entry.grade)
            local allowed = {}
            for _, gg in ipairs(PsychEval.AllowedGrades or {"A","B","C","D","E","F"}) do allowed[gg] = true end
            if not allowed[g] then
                return false, "invalid Grade"
            end
            entry.grade = g
        else
            entry.grade = nil
        end

        if not entry.psychologist or type(entry.psychologist) ~= "string" or entry.psychologist:Trim() == "" then
            entry.psychologist = "Unknown"
        end

        return true
    else
        if not entry.psychologist or type(entry.psychologist) ~= "string" or entry.psychologist:Trim() == "" then
            return false, "missing Reporting Psychologist"
        end

        if not entry.subject or type(entry.subject) ~= "string" or entry.subject:Trim() == "" then
            return false, "missing Subject"
        end

        if not entry.date or type(entry.date) ~= "string" or entry.date:Trim() == "" then
            return false, "missing Date"
        end

        if not entry.state or type(entry.state) ~= "string" or entry.state:Trim() == "" then
            return false, "missing Mental State"
        end

        local allowed = PsychEval.AllowedStates or {"Excellent", "Stable", "Unstable", "Insane"}
        local ok = false
        for _, s in ipairs(allowed) do
            if s == entry.state then ok = true break end
        end
        if not ok then
            return false, "invalid Mental State"
        end

        if entry.notes == nil then entry.notes = "" end
        if type(entry.notes) ~= "string" then entry.notes = tostring(entry.notes) end

        return true
    end
end

if SERVER then
    hook.Add("Initialize", "PsychEval_LoadData", function()
        PsychEval.LoadEvals()
    end)
end