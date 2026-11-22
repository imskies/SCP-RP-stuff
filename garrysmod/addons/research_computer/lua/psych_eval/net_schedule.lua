if SERVER then
    util.AddNetworkString("Schedule_RequestOpen")
    util.AddNetworkString("Schedule_Send")
    util.AddNetworkString("Schedule_Create")
    util.AddNetworkString("Schedule_Delete")
    util.AddNetworkString("Schedule_Notice")
end

PsychEval = PsychEval or {}
PsychEval.Schedule = PsychEval.Schedule or {}

-- Default Research command teams (names). Admins can override PsychEval.ScheduleCreateAllowedTeams in config.
if not PsychEval.ScheduleCreateAllowedTeams then
    PsychEval.ScheduleCreateAllowedTeams = {
        ["Research Advisor"] = true,
        ["Research Supervisor"] = true,
        ["Research Overseer"] = true,
        ["Deputy Director of Research"] = true,
        ["Director of Research"] = true
    }
end

local function ResolvePlayerTeamName(ply)
    if not IsValid(ply) then return tostring(ply and ply:Team() or "unknown") end
    if PsychEval.ResolvePlayerTeamName then return PsychEval.ResolvePlayerTeamName(ply) end
    if team and team.GetName then
        local tn = team.GetName(ply:Team())
        if tn and tn ~= "" then return tn end
    end
    return tostring(ply:Team())
end

local function teamAllowedByNameOrID(ply)
    local teamName = tostring(ResolvePlayerTeamName(ply) or "")
    local teamID = ply:Team()
    for k, v in pairs(PsychEval.ScheduleCreateAllowedTeams or {}) do
        if not v then continue end
        if type(k) == "string" then
            if string.lower(k) == string.lower(teamName) then
                return true
            end
        elseif type(k) == "number" then
            if k == teamID then
                return true
            end
        end
    end
    return false
end

local function IsPlayerAllowedCreate(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    if ply:IsAdmin() then return true end
    return teamAllowedByNameOrID(ply)
end

local function IsPlayerAllowedView(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    if ply:IsAdmin() then return true end
    if PsychEval.RequireTeamListedToOpenPC then
        if PsychEval.AccessByTeamID and PsychEval.AccessByTeamID[ply:Team()] ~= nil then return true end
        local tn = ResolvePlayerTeamName(ply)
        if PsychEval.AccessByTeamName and PsychEval.AccessByTeamName[tn] ~= nil then return true end
        if PsychEval.ClearanceByTeamID and PsychEval.ClearanceByTeamID[ply:Team()] ~= nil then return true end
        if PsychEval.ClearanceByTeamName and PsychEval.ClearanceByTeamName[tn] ~= nil then return true end
        return false
    end
    return true
end

local function broadcastSchedule()
    PsychEval.Schedule = PsychEval.Schedule or {}
    for _, target in ipairs(player.GetAll()) do
        if IsPlayerAllowedView(target) then
            net.Start("Schedule_Send")
                net.WriteTable(PsychEval.Schedule or {})
                net.WriteBool(IsPlayerAllowedCreate(target))
            net.Send(target)
        end
    end
end

-- Request open: send schedule to requester if allowed
net.Receive("Schedule_RequestOpen", function(len, ply)
    print(string.format("[Schedule] RequestOpen from %s (team=%s id=%s)", ply:Nick(), ResolvePlayerTeamName(ply), tostring(ply:Team())))
    if not IsPlayerAllowedView(ply) then
        net.Start("Schedule_Notice"); net.WriteString("You are not authorized to view the schedule."); net.Send(ply)
        print("[Schedule] View denied for " .. ply:Nick())
        return
    end

    net.Start("Schedule_Send")
        net.WriteTable(PsychEval.Schedule or {})
        net.WriteBool(IsPlayerAllowedCreate(ply))
    net.Send(ply)
end)

-- Create schedule entry
net.Receive("Schedule_Create", function(len, ply)
    local ok, entry = pcall(net.ReadTable)
    if not ok or type(entry) ~= "table" then
        net.Start("Schedule_Notice"); net.WriteString("Malformed schedule entry."); net.Send(ply)
        print("[Schedule] Malformed create from " .. ply:Nick())
        return
    end

    print(string.format("[Schedule] Create attempt by %s (team=%s id=%s). Entry:", ply:Nick(), ResolvePlayerTeamName(ply), tostring(ply:Team())))
    PrintTable(entry)

    if not IsPlayerAllowedCreate(ply) then
        net.Start("Schedule_Notice"); net.WriteString("You are not authorized to create schedule entries."); net.Send(ply)
        print("[Schedule] Create denied for " .. ply:Nick())
        return
    end

    local newEntry = {
        host = tostring(entry.host or ply:Nick()),
        date = tostring(entry.date or ""),
        time = tostring(entry.time or ""),
        activity = tostring(entry.activity or "Other"),
        details = tostring(entry.details or ""),
        author = ply:Nick(),
        created_at = os.date("%Y-%m-%d %H:%M:%S")
    }

    PsychEval.Schedule = PsychEval.Schedule or {}
    table.insert(PsychEval.Schedule, newEntry)

    if PsychEval.SaveEvals then
        pcall(function() PsychEval.SaveEvals() end)
    end

    broadcastSchedule()
    print(string.format("[Schedule] New entry created by %s: %s %s (%s) host=%s", ply:Nick(), newEntry.date, newEntry.time, newEntry.activity, newEntry.host))
end)

-- Delete schedule entry (index + identifying fields)
local function tryRemoveByIndex(tbl, idx)
    if not tbl or type(tbl) ~= "table" then return false end
    if idx and tbl[idx] then
        table.remove(tbl, idx)
        return true
    end
    return false
end

local function tryRemoveByMatch(tbl, host, date, time, activity)
    if not tbl or type(tbl) ~= "table" then return false end
    host = tostring(host or ""):lower()
    date = tostring(date or ""):lower()
    time = tostring(time or ""):lower()
    activity = tostring(activity or ""):lower()

    for i = 1, #tbl do
        local v = tbl[i]
        local vh = tostring(v.host or ""):lower()
        local vd = tostring(v.date or ""):lower()
        local vt = tostring(v.time or ""):lower()
        local va = tostring(v.activity or ""):lower()
        if (host == "" or vh == host) and (date == "" or vd == date) and (time == "" or vt == time) and (activity == "" or va == activity) then
            table.remove(tbl, i)
            return true
        end
    end
    return false
end

net.Receive("Schedule_Delete", function(len, ply)
    local idx = net.ReadUInt(16)
    local host = net.ReadString() or ""
    local date = net.ReadString() or ""
    local time = net.ReadString() or ""
    local activity = net.ReadString() or ""

    print(string.format("[Schedule] Delete request from %s (team=%s id=%s) idx=%s host=%s date=%s time=%s activity=%s",
        ply:Nick(), ResolvePlayerTeamName(ply), tostring(ply:Team()), tostring(idx), host, date, time, activity))

    if not IsPlayerAllowedCreate(ply) then
        net.Start("Schedule_Notice"); net.WriteString("You are not authorized to delete schedule entries."); net.Send(ply)
        print("[Schedule] Delete denied for " .. ply:Nick())
        return
    end

    PsychEval.Schedule = PsychEval.Schedule or {}

    if tryRemoveByIndex(PsychEval.Schedule, idx) then
        if PsychEval.SaveEvals then pcall(function() PsychEval.SaveEvals() end) end
        broadcastSchedule()
        print(string.format("[Schedule] Entry removed by index %d by %s", idx, ply:Nick()))
        return
    end

    if tryRemoveByMatch(PsychEval.Schedule, host, date, time, activity) then
        if PsychEval.SaveEvals then pcall(function() PsychEval.SaveEvals() end) end
        broadcastSchedule()
        print(string.format("[Schedule] Entry removed by match (host=%s date=%s time=%s activity=%s) by %s", host, date, time, activity, ply:Nick()))
        return
    end

    net.Start("Schedule_Notice"); net.WriteString("Could not find the requested schedule entry to delete."); net.Send(ply)
    print(string.format("[Schedule] Delete request failed for %s. idx=%s host=%s date=%s time=%s activity=%s (count=%d)",
        ply:Nick(), tostring(idx), host, date, time, activity, #(PsychEval.Schedule or {})))
end)