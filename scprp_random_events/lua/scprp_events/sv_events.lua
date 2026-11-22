util.AddNetworkString("SCPRPEvents_Announcement")
util.AddNetworkString("SCPRPEvents_State")

local E = SCPRPEvents
local C = E.Config

-- Rebuild the registry on every load. This prevents removed events from lingering
-- when Garry's Mod Lua auto-refresh reloads the addon.
E.Registered = {}
E.Active = nil
E.Recent = E.Recent or {}
E.NextEventAt = E.NextEventAt or (CurTime() + math.random(C.DelayMin, C.DelayMax))
E.TimerSerial = E.TimerSerial or 0

local function alivePlayers()
    local result = {}

    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() and ply:Team() ~= TEAM_SPECTATOR then
            result[#result + 1] = ply
        end
    end

    return result
end

local function announce(title, text, duration, style)
    net.Start("SCPRPEvents_Announcement")
        net.WriteString(title or "SITE EVENT")
        net.WriteString(text or "")
        net.WriteFloat(duration or 6)
        net.WriteString(style or "info")
    net.Broadcast()

    PrintMessage(HUD_PRINTCONSOLE, string.format("[SCPRP Events] %s: %s", title or "Event", text or ""))
end

local function syncState(target)
    net.Start("SCPRPEvents_State")
        net.WriteBool(E.Active ~= nil)

        if E.Active then
            net.WriteString(E.Active.Id)
            net.WriteString(E.Active.Data.Title)
            net.WriteString(E.Active.Data.Description)
            net.WriteString(E.Active.Data.Effect or "")
            net.WriteFloat(E.Active.EndTime or 0)
        end

    if IsValid(target) then net.Send(target) else net.Broadcast() end
end

local function eventTimer(delay, callback, repetitions)
    E.TimerSerial = E.TimerSerial + 1
    local name = "SCPRPEvents_" .. E.TimerSerial

    timer.Create(name, delay, repetitions or 1, function()
        if not E.Active then
            timer.Remove(name)
            return
        end

        callback(E.Active)
    end)

    E.Active.Timers[#E.Active.Timers + 1] = name
    return name
end

local function randomLivingPlayer()
    local candidates = alivePlayers()
    if #candidates == 0 then return nil end
    return candidates[math.random(#candidates)]
end

local function groundPositionNear(ply, distance)
    if not IsValid(ply) then return nil end

    local angle = math.Rand(0, math.pi * 2)
    local offset = Vector(math.cos(angle), math.sin(angle), 0) * math.Rand(90, distance or 260)
    local origin = ply:GetPos() + offset + Vector(0, 0, 96)
    local trace = util.TraceHull({
        start = origin,
        endpos = origin - Vector(0, 0, 220),
        mins = Vector(-18, -18, 0),
        maxs = Vector(18, 18, 48),
        filter = player.GetAll(),
        mask = MASK_SOLID
    })

    if not trace.Hit or trace.HitSky then return ply:GetPos() + ply:GetForward() * 70 end
    return trace.HitPos + trace.HitNormal * 4
end

E.AlivePlayers = alivePlayers
E.Announce = announce
E.EventTimer = eventTimer
E.RandomLivingPlayer = randomLivingPlayer
E.GroundPositionNear = groundPositionNear

function E.GetJobData(ply)
    if not IsValid(ply) then return nil end
    return RPExtraTeams and RPExtraTeams[ply:Team()] or nil
end

function E.GetJobName(ply)
    local data = E.GetJobData(ply)
    return data and data.name or team.GetName(ply:Team())
end

function E.GetJobCategory(ply)
    local data = E.GetJobData(ply)
    return data and data.category or nil
end

function E.IsRole(ply, role)
    if role == "Medical" and C.MedicalJobs and C.MedicalJobs[E.GetJobName(ply)] then
        return true
    end

    local categories = C.RoleCategories and C.RoleCategories[role]
    local category = E.GetJobCategory(ply)
    return categories ~= nil and category ~= nil and categories[category] == true
end

function E.RolePlayers(role, livingOnly)
    local result = {}

    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and E.IsRole(ply, role) and (not livingOnly or ply:Alive()) then
            result[#result + 1] = ply
        end
    end

    return result
end

function E.PayPlayer(ply, amount, reason)
    amount = math.floor(tonumber(amount) or 0)
    if not IsValid(ply) or amount <= 0 then return end

    if ply.addMoney then
        ply:addMoney(amount)
        ply:ChatPrint(string.format("%s Reward: $%s", reason or "Event", string.Comma(amount)))
    end
end

function E.HasActiveBreachTimer()
    if not RPExtraTeams then return false end

    for teamId in pairs(RPExtraTeams) do
        if timer.Exists("breachTimer" .. teamId) then return true end
    end

    return false
end

function E.Register(id, data)
    data.Id = id
    data.Weight = data.Weight or 1
    E.Registered[id] = data
end

function E.End(reason)
    if not E.Active then return false end

    local active = E.Active
    E.Active = nil

    for _, timerName in ipairs(active.Timers) do
        timer.Remove(timerName)
    end

    if active.Data.Stop then
        local ok, err = pcall(active.Data.Stop, active, reason or "finished")
        if not ok then ErrorNoHalt("[SCPRP Events] Stop error: " .. tostring(err) .. "\n") end
    end

    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent.SCPRPEventSerial == active.Serial then ent:Remove() end
    end

    hook.Run("SCPRPEventEnded", active.Id, active.Data, reason or "finished")
    local endMessage = active.EndMessage or active.Data.EndMessage or (active.Data.Title .. " has ended.")
    local endStyle = "success"
    if reason == "finished" and active.Data.TimeoutMessage then
        endMessage = active.Data.TimeoutMessage
        endStyle = "danger"
    end
    announce("EVENT CONCLUDED", endMessage, 6, endStyle)
    E.NextEventAt = CurTime() + math.random(C.DelayMin, C.DelayMax)
    syncState()
    return true
end

function E.Start(id, forced)
    if E.Active then return false, "Another event is already active." end

    local data = E.Registered[id]
    if not data then return false, "Unknown event: " .. tostring(id) end
    if not forced and #player.GetHumans() < C.MinimumPlayers then return false, "Not enough players." end
    if not C.IgnoreJobRequirements and data.CanRun and data.CanRun() == false then
        return false, "The required SCP-RP roles are not currently available."
    end
    if not forced and C.CanStartEvent(id, data) == false then return false, "Blocked by server rules." end

    E.Pending = nil
    E.TimerSerial = E.TimerSerial + 1
    local active = {
        Id = id,
        Data = data,
        Serial = E.TimerSerial,
        Timers = {},
        StartedAt = CurTime(),
        EndTime = CurTime() + (data.Duration or 90)
    }

    E.Active = active
    table.insert(E.Recent, 1, id)
    while #E.Recent > C.RecentEventMemory do table.remove(E.Recent) end

    local ok, result = pcall(data.Start, active)
    if not ok then
        if data.Stop then pcall(data.Stop, active, "start_error") end
        for _, ent in ipairs(ents.GetAll()) do
            if IsValid(ent) and ent.SCPRPEventSerial == active.Serial then ent:Remove() end
        end
        E.Active = nil
        ErrorNoHalt("[SCPRP Events] Start error in " .. id .. ": " .. tostring(result) .. "\n")
        return false, "The event encountered an error."
    end

    if isnumber(result) then
        active.EndTime = CurTime() + result
    end

    announce(data.Title, data.Description, 9, data.Style or "danger")
    syncState()
    hook.Run("SCPRPEventStarted", id, data, active.EndTime)

    eventTimer(math.max(1, active.EndTime - CurTime()), function()
        E.End("finished")
    end)

    return true
end

local function chooseEvent(ignoreRecent)
    local choices = {}
    local totalWeight = 0

    for id, data in pairs(E.Registered) do
        local recentlyUsed = not ignoreRecent and table.HasValue(E.Recent, id)
        local eligible = C.IgnoreJobRequirements or not data.CanRun or data.CanRun()

        if not recentlyUsed and eligible then
            totalWeight = totalWeight + data.Weight
            choices[#choices + 1] = { Id = id, Ceiling = totalWeight }
        end
    end

    if #choices == 0 then
        if ignoreRecent then return nil end
        return chooseEvent(true)
    end

    local roll = math.Rand(0, totalWeight)
    for _, choice in ipairs(choices) do
        if roll <= choice.Ceiling then return choice.Id end
    end

    return choices[#choices].Id
end

hook.Add("Think", "SCPRPEvents_AutoDirector", function()
    if not C.AutoEnabled or E.Active then return end

    if E.HasActiveBreachTimer() then
        E.Pending = nil
        E.NextEventAt = CurTime() + 60
        return
    end

    if #player.GetHumans() < C.MinimumPlayers then
        E.Pending = nil
        E.NextEventAt = CurTime() + 60
        return
    end

    if E.Pending then
        if CurTime() >= E.Pending.StartAt then
            local pendingId = E.Pending.Id
            E.Pending = nil
            local started = E.Start(pendingId, false)
            if not started then E.NextEventAt = CurTime() + 60 end
        end
        return
    end

    if CurTime() < E.NextEventAt then return end

    local selected = chooseEvent()
    if not selected then
        E.NextEventAt = CurTime() + 60
        return
    end

    E.Pending = {
        Id = selected,
        StartAt = CurTime() + C.WarningTime
    }
    announce("ANOMALOUS ACTIVITY DETECTED", "Site systems predict an event in " .. C.WarningTime .. " seconds.", 7, "danger")
end)

hook.Add("PlayerInitialSpawn", "SCPRPEvents_Sync", function(ply)
    timer.Simple(3, function() if IsValid(ply) then syncState(ply) end end)
end)

hook.Add("ShutDown", "SCPRPEvents_Cleanup", function()
    if E.Active and E.Active.Data.Stop then pcall(E.Active.Data.Stop, E.Active, "shutdown") end
end)

local function isAdmin(ply)
    return not IsValid(ply) or ply:IsAdmin()
end

concommand.Add("scprp_event_start", function(ply, _, args)
    if not isAdmin(ply) then return end
    local ok, message = E.Start(string.lower(args[1] or ""), true)
    if IsValid(ply) then ply:ChatPrint(ok and "Event started." or message) end
end)

concommand.Add("scprp_event_stop", function(ply)
    if not isAdmin(ply) then return end
    if not E.End("admin_stopped") and IsValid(ply) then ply:ChatPrint("No event is active.") end
end)

concommand.Add("scprp_event_next", function(ply)
    if not isAdmin(ply) then return end
    E.Pending = nil
    E.NextEventAt = CurTime()
    if IsValid(ply) then ply:ChatPrint("A random event warning has been triggered.") end
end)

concommand.Add("scprp_event_list", function(ply)
    if not isAdmin(ply) then return end
    local ids = {}
    for id in pairs(E.Registered) do ids[#ids + 1] = id end
    table.sort(ids)
    local message = "SCPRP Events " .. tostring(E.Version or "unknown") .. ": " .. table.concat(ids, ", ")
    if IsValid(ply) then ply:ChatPrint(message) else print(message) end
end)

concommand.Add("scprp_event_debug", function(ply)
    if not isAdmin(ply) then return end

    local ids = {}
    for id in pairs(E.Registered) do ids[#ids + 1] = id end
    table.sort(ids)

    local lines = {
        "Build: " .. tostring(E.Version or "unknown"),
        "Registered: " .. table.concat(ids, ", "),
        "Active: " .. (E.Active and E.Active.Id or "none"),
        "Pending: " .. (E.Pending and E.Pending.Id or "none"),
        "Testing mode: " .. tostring(C.IgnoreJobRequirements == true),
        "Active breach timer: " .. tostring(E.HasActiveBreachTimer()),
        "Map: " .. game.GetMap()
    }

    for _, line in ipairs(lines) do
        if IsValid(ply) then ply:ChatPrint("[SCPRP Events] " .. line) else print("[SCPRP Events] " .. line) end
    end
end)

concommand.Add("scprp_event_roles", function(ply)
    if not isAdmin(ply) then return end

    local counts = {}
    for role in pairs(C.RoleCategories or {}) do
        counts[#counts + 1] = role .. "=" .. #E.RolePlayers(role, true)
    end
    table.sort(counts)

    local message = "Living role counts: " .. table.concat(counts, ", ")
    if IsValid(ply) then ply:ChatPrint(message) else print(message) end
end)
