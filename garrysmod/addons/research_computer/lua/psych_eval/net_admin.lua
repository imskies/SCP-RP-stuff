if SERVER then
    util.AddNetworkString("PsychEval_Delete")
    util.AddNetworkString("TestLogs_Delete")
    util.AddNetworkString("PsychEval_Notice")
    util.AddNetworkString("TestLogs_Notice")
end

PsychEval = PsychEval or {}

-- Candidate tables to search for test logs / evals (order matters: index removal tries these first)
local TEST_TABLE_CANDIDATES = {
    "TestLogs",
    "Tests",
    "Logs",
    "Evals",
    "Entries"
}

local EVAL_TABLE_CANDIDATES = {
    "Evals",
    "Evaluations",
    "PsychEvals",
    "Entries"
}

local function ResolvePlayerTeamName(ply)
    if not IsValid(ply) then return tostring(ply and ply:Team() or "unknown") end
    if PsychEval.ResolvePlayerTeamName then return PsychEval.ResolvePlayerTeamName(ply) end
    if team and team.GetName then
        local tn = team.GetName(ply:Team())
        if tn and tn ~= "" then return tn end
    end
    return tostring(ply:Team())
end

local function IsPlayerAllowedDelete(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    if ply:IsAdmin() then return true end
    local teamName = ResolvePlayerTeamName(ply)
    if PsychEval.DeleteAllowedTeams and PsychEval.DeleteAllowedTeams[teamName] then return true end
    local teamID = ply:Team()
    if PsychEval.DeleteAllowedTeams and PsychEval.DeleteAllowedTeams[teamID] then return true end
    return false
end

local function getTableByName(name)
    if not name then return nil end
    return PsychEval[name]
end

local function tryRemoveByIndex(tbl, idx)
    if not tbl or type(tbl) ~= "table" then return false end
    if idx and tbl[idx] then
        table.remove(tbl, idx)
        return true
    end
    return false
end

local function fieldsMatchEntry(entry, subject, date, author)
    if not entry or type(entry) ~= "table" then return false end
    local function norm(s) return tostring(s or ""):lower():Trim() end
    local ssub = norm(subject)
    local sdate = norm(date)
    local sauth = norm(author)

    -- collect candidate fields from the entry to compare
    local candidates = {
        entry.subject, entry.name, entry.title,
        entry.date, entry.dt,
        entry.author, entry.psychologist, entry.tester, entry.creator
    }

    -- quick subject match if provided
    if ssub ~= "" then
        local found = false
        for _, v in ipairs(candidates) do
            if tostring(v or "") ~= "" and norm(v) == ssub then found = true break end
        end
        if not found then return false end
    end

    -- optional date match (if provided)
    if sdate ~= "" then
        local found = false
        for _, v in ipairs(candidates) do
            if tostring(v or "") ~= "" and norm(v) == sdate then found = true break end
        end
        if not found then return false end
    end

    -- optional author match (if provided)
    if sauth ~= "" then
        local found = false
        for _, v in ipairs(candidates) do
            if tostring(v or "") ~= "" and norm(v) == sauth then found = true break end
        end
        if not found then return false end
    end

    return true
end

local function tryRemoveByMatch(tbl, subject, date, author)
    if not tbl or type(tbl) ~= "table" then return false end
    subject = tostring(subject or "")
    date = tostring(date or "")
    author = tostring(author or "")

    for i = 1, #tbl do
        local v = tbl[i]
        if fieldsMatchEntry(v, subject, date, author) then
            table.remove(tbl, i)
            return true
        end
    end
    return false
end

local function saveIfPossible()
    if PsychEval.SaveEvals and type(PsychEval.SaveEvals) == "function" then
        pcall(function() PsychEval.SaveEvals() end)
    end
end

local function attemptDeleteFromCandidates(ply, idx, subject, date, author, candidates, label)
    -- Try index removal first on each candidate table
    for _, tname in ipairs(candidates) do
        local tbl = getTableByName(tname)
        if tbl and type(tbl) == "table" then
            if tryRemoveByIndex(tbl, idx) then
                saveIfPossible()
                print(string.format("[Delete] Removed by index from %s (table=%s) idx=%d by %s", label, tname, idx, ply:Nick()))
                return true
            end
        end
    end

    -- Fallback: try matching by fields across candidate tables
    for _, tname in ipairs(candidates) do
        local tbl = getTableByName(tname)
        if tbl and type(tbl) == "table" then
            if tryRemoveByMatch(tbl, subject, date, author) then
                saveIfPossible()
                print(string.format("[Delete] Removed by match from %s (table=%s) subject='%s' date='%s' author='%s' by %s",
                    label, tname, tostring(subject), tostring(date), tostring(author), ply:Nick()))
                return true
            end
        end
    end

    -- nothing removed
    print(string.format("[Delete] No match found in candidate tables for %s. idx=%s subject='%s' date='%s' author='%s' (caller=%s)",
        label, tostring(idx), tostring(subject), tostring(date), tostring(author), ply:Nick()))
    return false
end

-- Psych Eval delete handler
net.Receive("PsychEval_Delete", function(len, ply)
    local idx = net.ReadUInt(16)
    local subject = net.ReadString() or ""
    local date = net.ReadString() or ""
    local author = net.ReadString() or ""

    if not IsPlayerAllowedDelete(ply) then
        net.Start("PsychEval_Notice"); net.WriteString("You are not authorized to delete Psych Evals."); net.Send(ply)
        print("[Research Computer] Delete denied for " .. ply:Nick())
        return
    end

    -- Try to delete from eval candidate tables
    local ok = attemptDeleteFromCandidates(ply, idx, subject, date, author, EVAL_TABLE_CANDIDATES, "PsychEval")
    if not ok then
        net.Start("PsychEval_Notice"); net.WriteString("Could not find the requested Psych Eval to delete."); net.Send(ply)
        return
    end

    if PsychEval.BroadcastPanelData then
        PsychEval.BroadcastPanelData()
    else
        for _, target in ipairs(player.GetAll()) do
            if PsychEval.GetAccessLevel and PsychEval.GetAccessLevel(target) >= (PsychEval.MinAccessToOpenEvals or 2) then
                if PsychEval.SendEvalsToPlayer then PsychEval.SendEvalsToPlayer(target) end
                if PsychEval.SendTestsToPlayer then PsychEval.SendTestsToPlayer(target) end
            end
        end
    end
end)

-- Test Logs delete handler
net.Receive("TestLogs_Delete", function(len, ply)
    local idx = net.ReadUInt(16)
    local subject = net.ReadString() or ""
    local date = net.ReadString() or ""
    local author = net.ReadString() or ""

    if not IsPlayerAllowedDelete(ply) then
        net.Start("TestLogs_Notice"); net.WriteString("You are not authorized to delete Test Logs."); net.Send(ply)
        print("[TestLogs] Delete denied for " .. ply:Nick())
        return
    end

    local ok = attemptDeleteFromCandidates(ply, idx, subject, date, author, TEST_TABLE_CANDIDATES, "TestLogs")
    if not ok then
        net.Start("TestLogs_Notice"); net.WriteString("Could not find the requested Test Log to delete."); net.Send(ply)
        return
    end

    if PsychEval.BroadcastPanelData then
        PsychEval.BroadcastPanelData()
    else
        for _, target in ipairs(player.GetAll()) do
            if PsychEval.GetAccessLevel and PsychEval.GetAccessLevel(target) >= (PsychEval.MinAccessToOpenEvals or 2) then
                if PsychEval.SendEvalsToPlayer then PsychEval.SendEvalsToPlayer(target) end
                if PsychEval.SendTestsToPlayer then PsychEval.SendTestsToPlayer(target) end
            end
        end
    end
end)