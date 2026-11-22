if SERVER then
    util.AddNetworkString("PsychEval_RequestOpen")
    util.AddNetworkString("PsychEval_SendEvals")
    util.AddNetworkString("PsychEval_SendTests")
    util.AddNetworkString("PsychEval_Denied")
    util.AddNetworkString("PsychEval_Notice")
    util.AddNetworkString("PsychEval_SubmitEntry")
    util.AddNetworkString("PsychEval_EditEntry")
    util.AddNetworkString("PsychEval_Refresh")
    util.AddNetworkString("PsychEval_OpenChooser")
end

local function SendEvalsToPlayer(ply)
    if not IsValid(ply) then return end
    local level = PsychEval.GetAccessLevel and PsychEval.GetAccessLevel(ply) or PsychEval.DefaultAccess or 1
    local canGrade = PsychEval.CanGrade and PsychEval.CanGrade(ply) or false

    net.Start("PsychEval_SendEvals")
        net.WriteUInt(level, 3)
        net.WriteBool(canGrade)
        net.WriteTable(PsychEval.GetEvals and PsychEval.GetEvals() or {})
    net.Send(ply)
end

local function SendTestsToPlayer(ply)
    if not IsValid(ply) then return end
    local level = PsychEval.GetAccessLevel and PsychEval.GetAccessLevel(ply) or PsychEval.DefaultAccess or 1
    local canGrade = PsychEval.CanGrade and PsychEval.CanGrade(ply) or false

    local all = PsychEval.GetEvals and PsychEval.GetEvals() or {}
    local tests = {}
    local playerClearance = PsychEval.GetPlayerClearance and PsychEval.GetPlayerClearance(ply) or PsychEval.DefaultClearance or 1

    for _, v in ipairs(all or {}) do
        if v.clearance ~= nil or v.name ~= nil then
            local testClear = tonumber(v.clearance) or 1
            if testClear <= playerClearance then
                table.insert(tests, v)
            end
        end
    end

    net.Start("PsychEval_SendTests")
        net.WriteUInt(level, 3)
        net.WriteBool(canGrade)
        net.WriteTable(tests)
    net.Send(ply)
end

PsychEval.SendEvalsToPlayer = SendEvalsToPlayer
PsychEval.SendTestsToPlayer = SendTestsToPlayer

-- Helper: resolve player's team name (server-side)
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

-- Helper: determine whether a player's job is explicitly listed in config
-- Accept a job as "listed" if it appears in AccessByTeamName/ID OR ClearanceByTeamName/ID
local function IsPlayerJobListed(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end

    local teamID = ply:Team()
    if PsychEval.AccessByTeamID and PsychEval.AccessByTeamID[teamID] ~= nil then
        return true
    end

    local teamName = ResolvePlayerTeamName(ply)
    if PsychEval.AccessByTeamName and teamName and PsychEval.AccessByTeamName[teamName] ~= nil then
        return true
    end

    if PsychEval.ClearanceByTeamID and PsychEval.ClearanceByTeamID[teamID] ~= nil then
        return true
    end
    if PsychEval.ClearanceByTeamName and teamName and PsychEval.ClearanceByTeamName[teamName] ~= nil then
        return true
    end

    return false
end

local function CanPlayerReceiveEvalData(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    if PsychEval.RequireTeamListedToOpenPC and not IsPlayerJobListed(ply) then return false end

    local level = PsychEval.GetAccessLevel and PsychEval.GetAccessLevel(ply) or PsychEval.DefaultAccess or 1
    return level >= (PsychEval.MinAccessToOpenEvals or 2)
end

local function CanPlayerReceiveTestData(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    if PsychEval.RequireTeamListedToOpenPC and not IsPlayerJobListed(ply) then return false end

    local playerClearance = PsychEval.GetPlayerClearance and PsychEval.GetPlayerClearance(ply) or PsychEval.DefaultClearance or 1
    local canOpenByClearance = playerClearance >= (PsychEval.MinClearanceToOpenTests or 1)
    local canOpenByPC = PsychEval.AllowPCOpenersToSubmitTests and IsPlayerJobListed(ply)

    return canOpenByClearance or canOpenByPC
end

local function BroadcastPanelData()
    for _, target in ipairs(player.GetAll()) do
        if CanPlayerReceiveEvalData(target) and SendEvalsToPlayer then
            SendEvalsToPlayer(target)
        end

        if CanPlayerReceiveTestData(target) and SendTestsToPlayer then
            SendTestsToPlayer(target)
        end
    end
end

PsychEval.BroadcastPanelData = BroadcastPanelData

-- Player requests to open UI (client writes desired submenu string)
net.Receive("PsychEval_RequestOpen", function(len, ply)
    local desired = ""
    if len > 0 then
        desired = net.ReadString() or ""
    end

    -- Enforce "job must be listed" if configured
    if PsychEval.RequireTeamListedToOpenPC then
        if not IsPlayerJobListed(ply) then
            local teamName = ResolvePlayerTeamName(ply)
            net.Start("PsychEval_Denied"); net.Send(ply)
            print(string.format("[Research Computer] Denied PC open for %s (job not listed). Resolved team name: %s", ply:Nick(), tostring(teamName)))
            return
        end
    end

    -- If client asked for tests, allow only if job is listed OR clearance meets minimum
    if desired == "tests" then
        local playerClearance = PsychEval.GetPlayerClearance and PsychEval.GetPlayerClearance(ply) or PsychEval.DefaultClearance or 1
        local canOpenByClearance = playerClearance >= (PsychEval.MinClearanceToOpenTests or 1)
        local canOpenByPC = PsychEval.AllowPCOpenersToSubmitTests and IsPlayerJobListed(ply)

        if not (canOpenByClearance or canOpenByPC) then
            net.Start("PsychEval_Denied"); net.Send(ply)
            print("[Research Computer] Denied tests open for " .. ply:Nick() .. " (clearance " .. tostring(playerClearance) .. ")")
            return
        end

        SendTestsToPlayer(ply)
        return
    end

    -- For evals, require access >= MinAccessToOpenEvals
    local level = PsychEval.GetAccessLevel and PsychEval.GetAccessLevel(ply) or PsychEval.DefaultAccess or 1
    if level < (PsychEval.MinAccessToOpenEvals or 2) then
        net.Start("PsychEval_Denied"); net.Send(ply)
        print("[Research Computer] Denied evals open for " .. ply:Nick() .. " (access " .. tostring(level) .. ")")
        return
    end

    if desired == "evals" then
        SendEvalsToPlayer(ply)
    else
        net.Start("PsychEval_OpenChooser")
        net.Send(ply)
    end
end)

-- Helper to send a short notice string to a player
local function SendNotice(ply, text)
    if not IsValid(ply) then return end
    net.Start("PsychEval_Notice")
        net.WriteString(text or "")
    net.Send(ply)
end

-- Submit new entry (client -> server)
net.Receive("PsychEval_SubmitEntry", function(len, ply)
    local entry = net.ReadTable()
    if not entry then
        SendNotice(ply, "Submission failed: malformed data.")
        print("[Research Computer] SubmitEntry: malformed data from " .. ply:Nick())
        return
    end

    local isTest = entry.clearance ~= nil or entry.name ~= nil

    if isTest then
        -- Enforce job listed if configured
        if PsychEval.RequireTeamListedToOpenPC and not IsPlayerJobListed(ply) then
            SendNotice(ply, "You are not authorized to submit test logs (job not listed).")
            print("[Research Computer] Submit denied (job not listed) for " .. ply:Nick())
            return
        end

        local playerClearance = PsychEval.GetPlayerClearance and PsychEval.GetPlayerClearance(ply) or PsychEval.DefaultClearance or 1
        local canSubmitByClearance = playerClearance >= (PsychEval.MinClearanceToOpenTests or 1)
        local canSubmitByPC = PsychEval.AllowPCOpenersToSubmitTests and IsPlayerJobListed(ply)

        if not (canSubmitByClearance or canSubmitByPC) then
            SendNotice(ply, "You do not have sufficient clearance to submit test logs.")
            print("[Research Computer] Submit denied (clearance) for " .. ply:Nick() .. " (clearance " .. tostring(playerClearance) .. ")")
            return
        end

        -- Clamp requested clearance to player's max assignable clearance
        local requested = tonumber(entry.clearance) or playerClearance
        local maxAssign = PsychEval.GetMaxAssignableClearanceForTeamName and PsychEval.GetMaxAssignableClearanceForTeamName(ResolvePlayerTeamName(ply)) or playerClearance
        if requested > maxAssign then
            local old = requested
            entry.clearance = maxAssign
            SendNotice(ply, "Requested clearance " .. tostring(old) .. " reduced to " .. tostring(maxAssign) .. ".")
            print("[Research Computer] Clearance clamped for " .. ply:Nick() .. " from " .. tostring(old) .. " to " .. tostring(maxAssign))
        else
            entry.clearance = math.max(0, math.floor(requested))
        end

        if entry.grade and PsychEval.CanGrade and not PsychEval.CanGrade(ply) then
            entry.grade = nil
        end

        local valid, err = PsychEval.ValidateEntry and PsychEval.ValidateEntry(entry) or true, nil
        if not valid then
            SendNotice(ply, "Submission failed: " .. tostring(err))
            print("[Research Computer] Submit failed validation for " .. ply:Nick() .. " : " .. tostring(err))
            return
        end

        if PsychEval.AddEval then PsychEval.AddEval(entry, ply) end
        print("[Research Computer] Test submitted by " .. ply:Nick() .. " (clearance " .. tostring(entry.clearance) .. ")")
    else
        if PsychEval.GetAccessLevel and PsychEval.GetAccessLevel(ply) < 3 then
            SendNotice(ply, "You do not have permission to submit psych evals.")
            print("[Research Computer] Eval submit denied for " .. ply:Nick() .. " (access " .. tostring(PsychEval.GetAccessLevel(ply)) .. ")")
            return
        end

        local valid, err = PsychEval.ValidateEntry and PsychEval.ValidateEntry(entry) or true, nil
        if not valid then
            SendNotice(ply, "Submission failed: " .. tostring(err))
            print("[Research Computer] Eval submit failed validation for " .. ply:Nick() .. " : " .. tostring(err))
            return
        end

        if PsychEval.AddEval then PsychEval.AddEval(entry, ply) end
        print("[Research Computer] Eval submitted by " .. ply:Nick())
    end

    BroadcastPanelData()
end)

-- Edit existing entry (client -> server)
net.Receive("PsychEval_EditEntry", function(len, ply)
    local index = net.ReadUInt(16)
    local newEntry = net.ReadTable()
    if not newEntry then
        SendNotice(ply, "Edit failed: malformed data.")
        print("[Research Computer] EditEntry: malformed data from " .. ply:Nick())
        return
    end

    local isTest = newEntry.clearance ~= nil or newEntry.name ~= nil

    if isTest then
        if PsychEval.RequireTeamListedToOpenPC and not IsPlayerJobListed(ply) then
            SendNotice(ply, "You are not authorized to edit test logs (job not listed).")
            print("[Research Computer] Edit denied (job not listed) for " .. ply:Nick())
            return
        end

        local playerClearance = PsychEval.GetPlayerClearance and PsychEval.GetPlayerClearance(ply) or PsychEval.DefaultClearance or 1
        local canEditByClearance = playerClearance >= (PsychEval.MinClearanceToOpenTests or 1)
        local canEditByPC = PsychEval.AllowPCOpenersToSubmitTests and IsPlayerJobListed(ply)

        if not (canEditByClearance or canEditByPC) then
            SendNotice(ply, "You do not have sufficient clearance to edit test logs.")
            print("[Research Computer] Edit denied (clearance) for " .. ply:Nick())
            return
        end

        local requested = tonumber(newEntry.clearance) or playerClearance
        local maxAssign = PsychEval.GetMaxAssignableClearanceForTeamName and PsychEval.GetMaxAssignableClearanceForTeamName(ResolvePlayerTeamName(ply)) or playerClearance
        if requested > maxAssign then
            newEntry.clearance = maxAssign
            SendNotice(ply, "Requested clearance reduced to " .. tostring(maxAssign) .. ".")
            print("[Research Computer] Clearance clamped on edit for " .. ply:Nick())
        else
            newEntry.clearance = math.max(0, math.floor(requested))
        end

        if newEntry.grade and PsychEval.CanGrade and not PsychEval.CanGrade(ply) then
            local old = (PsychEval.Evals and PsychEval.Evals[index]) or {}
            newEntry.grade = old.grade
        end

        local valid, err = PsychEval.ValidateEntry and PsychEval.ValidateEntry(newEntry) or true, nil
        if not valid then
            SendNotice(ply, "Edit failed: " .. tostring(err))
            print("[Research Computer] Edit failed validation for " .. ply:Nick() .. " : " .. tostring(err))
            return
        end

        if PsychEval.EditEval and PsychEval.EditEval(index, newEntry, ply) then
            BroadcastPanelData()
        end
    else
        if PsychEval.GetAccessLevel and PsychEval.GetAccessLevel(ply) < 3 then
            SendNotice(ply, "You do not have permission to edit psych evals.")
            print("[Research Computer] Eval edit denied for " .. ply:Nick())
            return
        end

        local valid, err = PsychEval.ValidateEntry and PsychEval.ValidateEntry(newEntry) or true, nil
        if not valid then
            SendNotice(ply, "Edit failed: " .. tostring(err))
            print("[Research Computer] Eval edit failed validation for " .. ply:Nick() .. " : " .. tostring(err))
            return
        end

        if PsychEval.EditEval and PsychEval.EditEval(index, newEntry, ply) then
            BroadcastPanelData()
        end
    end
end)