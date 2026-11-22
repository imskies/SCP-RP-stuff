if SERVER then
    util.AddNetworkString("BioLogs_RequestOpen")
    util.AddNetworkString("BioLogs_Send")
    util.AddNetworkString("BioLogs_Refresh")
    util.AddNetworkString("BioLogs_Denied")
    util.AddNetworkString("BioLogs_Notice")
    util.AddNetworkString("BioLogs_Submit")
    util.AddNetworkString("BioLogs_Edit")
    util.AddNetworkString("BioLogs_Delete")
    util.AddNetworkString("PsychEval_OpenChooser")
end

PsychEval = PsychEval or {}
PsychEval.BioLogs = PsychEval.BioLogs or {}

local function ResolvePlayerTeamName(ply)
    if not IsValid(ply) then return tostring(ply and ply:Team() or "unknown") end
    if PsychEval.ResolvePlayerTeamName then
        return PsychEval.ResolvePlayerTeamName(ply)
    end
    if team and team.GetName then
        local tn = team.GetName(ply:Team())
        if tn and tn ~= "" then return tn end
    end
    return tostring(ply:Team())
end

local function IsPlayerAllowedBioView(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    local teamName = ResolvePlayerTeamName(ply)
    if PsychEval.BioViewAllowedTeams and PsychEval.BioViewAllowedTeams[teamName] then
        return true
    end
    local teamID = ply:Team()
    if PsychEval.BioViewAllowedTeams and PsychEval.BioViewAllowedTeams[teamID] then
        return true
    end
    return false
end

local function IsPlayerAllowedBioCreate(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    local teamName = ResolvePlayerTeamName(ply)
    if PsychEval.BioCreateAllowedTeams and PsychEval.BioCreateAllowedTeams[teamName] then
        return true
    end
    local teamID = ply:Team()
    if PsychEval.BioCreateAllowedTeams and PsychEval.BioCreateAllowedTeams[teamID] then
        return true
    end
    return false
end

local function IsPlayerAllowedDelete(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    if ply:IsAdmin() then return true end
    local teamName = ResolvePlayerTeamName(ply)
    if PsychEval.DeleteAllowedTeams and PsychEval.DeleteAllowedTeams[teamName] then
        return true
    end
    local teamID = ply:Team()
    if PsychEval.DeleteAllowedTeams and PsychEval.DeleteAllowedTeams[teamID] then
        return true
    end
    return false
end

local function SendBioLogsToPlayer(ply, isRefresh)
    if not IsValid(ply) then return end
    if not IsPlayerAllowedBioView(ply) then
        if not isRefresh then
            net.Start("BioLogs_Denied"); net.Send(ply)
        end
        return
    end

    net.Start(isRefresh and "BioLogs_Refresh" or "BioLogs_Send")
        net.WriteTable(PsychEval.BioLogs or {})
    net.Send(ply)
end

net.Receive("BioLogs_RequestOpen", function(len, ply)
    if not IsPlayerAllowedBioView(ply) then
        net.Start("BioLogs_Denied"); net.Send(ply)
        print(string.format("[BioLogs] Denied open for %s (job not allowed). Resolved team name: %s", ply:Nick(), ResolvePlayerTeamName(ply)))
        return
    end

    SendBioLogsToPlayer(ply)
end)

net.Receive("BioLogs_Submit", function(len, ply)
    if not IsPlayerAllowedBioCreate(ply) then
        net.Start("BioLogs_Notice"); net.WriteString("You are not authorized to submit Bio Logs."); net.Send(ply)
        print("[BioLogs] Submit denied (job not allowed) for " .. ply:Nick())
        return
    end

    local entry = net.ReadTable()
    if not entry or type(entry) ~= "table" then
        net.Start("BioLogs_Notice"); net.WriteString("Malformed Bio Log submission."); net.Send(ply)
        return
    end

    -- Normalize and ignore any client-sent clearance; server controls clearance if needed.
    local newEntry = {
        author = ply:Nick(),
        subject = tostring(entry.subject or entry.title or "Untitled"):Trim(),
        incident_type = tostring(entry.incident_type or "Other"),
        date = tostring(entry.date or os.date("%Y-%m-%d")),
        notes = tostring(entry.notes or ""),
        -- keep clearance nil or 0 for bio logs (system uses its own access lists)
        clearance = 0
    }

    PsychEval.BioLogs = PsychEval.BioLogs or {}
    table.insert(PsychEval.BioLogs, newEntry)

    if PsychEval.SaveEvals then
        pcall(function() PsychEval.SaveEvals() end)
    end

    for _, target in ipairs(player.GetAll()) do
        if IsPlayerAllowedBioView(target) then
            SendBioLogsToPlayer(target, true)
        end
    end

    print("[BioLogs] New log submitted by " .. ply:Nick())
end)

net.Receive("BioLogs_Edit", function(len, ply)
    local idx = net.ReadUInt(16)
    local newEntry = net.ReadTable()
    if not newEntry or type(newEntry) ~= "table" then
        net.Start("BioLogs_Notice"); net.WriteString("Malformed Bio Log edit."); net.Send(ply)
        return
    end

    if not IsPlayerAllowedBioCreate(ply) then
        net.Start("BioLogs_Notice"); net.WriteString("You are not authorized to edit Bio Logs."); net.Send(ply)
        print("[BioLogs] Edit denied (job not allowed) for " .. ply:Nick())
        return
    end

    PsychEval.BioLogs = PsychEval.BioLogs or {}
    if not PsychEval.BioLogs[idx] then
        net.Start("BioLogs_Notice"); net.WriteString("Bio Log not found."); net.Send(ply)
        return
    end

    -- Normalize fields and ignore client clearance
    local updated = {
        author = PsychEval.BioLogs[idx].author or ply:Nick(),
        subject = tostring(newEntry.subject or newEntry.title or PsychEval.BioLogs[idx].subject):Trim(),
        incident_type = tostring(newEntry.incident_type or PsychEval.BioLogs[idx].incident_type or "Other"),
        date = tostring(newEntry.date or PsychEval.BioLogs[idx].date or os.date("%Y-%m-%d")),
        notes = tostring(newEntry.notes or PsychEval.BioLogs[idx].notes or "")
    }

    PsychEval.BioLogs[idx] = updated

    if PsychEval.SaveEvals then
        pcall(function() PsychEval.SaveEvals() end)
    end

    for _, target in ipairs(player.GetAll()) do
        if IsPlayerAllowedBioView(target) then
            SendBioLogsToPlayer(target, true)
        end
    end

    print("[BioLogs] Log edited by " .. ply:Nick())
end)

-- Delete handler for Bio Logs
net.Receive("BioLogs_Delete", function(len, ply)
    local idx = net.ReadUInt(16)
    if not IsPlayerAllowedDelete(ply) then
        net.Start("BioLogs_Notice"); net.WriteString("You are not authorized to delete Bio Logs."); net.Send(ply)
        print("[BioLogs] Delete denied for " .. ply:Nick())
        return
    end

    PsychEval.BioLogs = PsychEval.BioLogs or {}
    if not PsychEval.BioLogs[idx] then
        net.Start("BioLogs_Notice"); net.WriteString("Bio Log not found."); net.Send(ply)
        return
    end

    table.remove(PsychEval.BioLogs, idx)

    if PsychEval.SaveEvals then
        pcall(function() PsychEval.SaveEvals() end)
    end

    for _, target in ipairs(player.GetAll()) do
        if IsPlayerAllowedBioView(target) then
            SendBioLogsToPlayer(target, true)
        end
    end

    print("[BioLogs] Log deleted by " .. ply:Nick())
end)