-- lua/autorun/psych_eval_autorun.lua
-- Server autorun for PsychEval: includes, netstrings, permission checks, create/delete handlers,
-- and simple broadcast helpers. Drop in and restart server.

PsychEval = PsychEval or {}

if SERVER then
    -- Safe includes (keep your existing files if present)
    pcall(function()
        include("psych_eval/config.lua")
        include("psych_eval/core.lua")
        include("psych_eval/net.lua")
        include("psych_eval/data.lua")
        include("psych_eval/net_admin.lua")
        include("psych_eval/net_bio.lua")
    end)

    -- Ensure clients get the VGUI and shared files
    AddCSLuaFile("psych_eval/config.lua")
    AddCSLuaFile("psych_eval/cl_shared.lua")
    AddCSLuaFile("vgui/cl_psych_mainmenu.lua")
    AddCSLuaFile("vgui/cl_psych_schedule.lua")
    AddCSLuaFile("vgui/cl_psych_menu.lua")
    AddCSLuaFile("vgui/cl_psych_testmenu.lua")
    AddCSLuaFile("vgui/cl_psych_entry.lua")
    AddCSLuaFile("vgui/cl_psych_test.lua")
    AddCSLuaFile("vgui/cl_bio_menu.lua")

    -- Netstrings
    util.AddNetworkString("Schedule_RequestOpen")
    util.AddNetworkString("Schedule_Send")
    util.AddNetworkString("Schedule_Create")
    util.AddNetworkString("Schedule_Delete")
    util.AddNetworkString("Schedule_Notice")
    util.AddNetworkString("PsychEval_OpenChooser")

    -- Ensure schedule table exists
    PsychEval.Schedule = PsychEval.Schedule or {}

    -- Default allowed teams by name (edit to match your exact team names)
    PsychEval.ScheduleCreateAllowedTeams = PsychEval.ScheduleCreateAllowedTeams or {
        ["Research Advisor"] = true,
        ["Research Supervisor"] = true,
        ["Research Overseer"] = true,
        ["Deputy Director of Research"] = true,
        ["Director of Research"] = true,
        ["Site Director"] = true,
        ["Site Deputy Director"] = true
    }

    -- Optional admin override
    PsychEval.AllowAdminsToCreate = PsychEval.AllowAdminsToCreate or false

    print("[Research Computer] autorun loaded - Schedule handlers active")

    local function PlayerCanCreateSchedule(ply)
        if not IsValid(ply) then return false end
        local teamName = (team.GetName and team.GetName(ply:Team())) or tostring(ply:Team())
        if teamName and PsychEval.ScheduleCreateAllowedTeams[teamName] then return true end
        if PsychEval.ScheduleCreateAllowedTeams[ply:Team()] then return true end
        if ply:IsAdmin() and PsychEval.AllowAdminsToCreate then return true end
        return false
    end

    local function BroadcastScheduleTo(targets)
        PsychEval.Schedule = PsychEval.Schedule or {}
        targets = targets or player.GetAll()
        for _, target in ipairs(targets) do
            local canCreate = PlayerCanCreateSchedule(target)
            net.Start("Schedule_Send")
                net.WriteTable(PsychEval.Schedule or {})
                net.WriteBool(canCreate)
            net.Send(target)
        end
        print("[Research Computer] Broadcasted Schedule_Send to " .. tostring(#targets) .. " players (entries=" .. tostring(#(PsychEval.Schedule or {})) .. ")")
    end

    -- Reply to open requests with schedule and per-player permission
    net.Receive("Schedule_RequestOpen", function(len, ply)
        local canCreate = PlayerCanCreateSchedule(ply)
        net.Start("Schedule_Send")
            net.WriteTable(PsychEval.Schedule or {})
            net.WriteBool(canCreate)
        net.Send(ply)
        print(string.format("[Research Computer] Schedule_RequestOpen from %s team=%s can_create=%s", ply:Nick(), (team.GetName and team.GetName(ply:Team()) or tostring(ply:Team())), tostring(canCreate)))
    end)

    -- Create handler
    net.Receive("Schedule_Create", function(len, ply)
        local ok, entry = pcall(net.ReadTable)
        print(string.format("[Research Computer] Schedule_Create received from %s ok=%s team=%s", ply:Nick(), tostring(ok), (team.GetName and team.GetName(ply:Team()) or tostring(ply:Team()))))
        if not ok or type(entry) ~= "table" then
            net.Start("Schedule_Notice"); net.WriteString("Invalid schedule entry data."); net.Send(ply)
            return
        end

        if not PlayerCanCreateSchedule(ply) then
            net.Start("Schedule_Notice"); net.WriteString("You are not authorized to create schedule entries."); net.Send(ply)
            print(string.format("[Research Computer] Schedule_Create denied for %s (not allowed)", ply:Nick()))
            return
        end

        -- Sanitize and add metadata
        entry.host = tostring(entry.host or ply:Nick())
        entry.author = tostring(ply:Nick())
        entry.created_at = os.date("%Y-%m-%d %H:%M:%S")
        entry.date = tostring(entry.date or os.date("%Y-%m-%d"))
        entry.time = tostring(entry.time or os.date("%H:%M"))
        entry.activity = tostring(entry.activity or "Scheduled")
        entry.details = tostring(entry.details or "")

        PsychEval.Schedule = PsychEval.Schedule or {}
        table.insert(PsychEval.Schedule, entry)
        print(string.format("[Research Computer] Schedule entry added by %s (total=%d)", ply:Nick(), #PsychEval.Schedule))

        -- Broadcast updated schedule to all players (each client will get its own can_create flag)
        BroadcastScheduleTo()
    end)

    -- Delete handler (index-based)
    net.Receive("Schedule_Delete", function(len, ply)
        local idx = net.ReadUInt(16)
        local host = net.ReadString()
        local date = net.ReadString()
        local time = net.ReadString()
        local activity = net.ReadString()
        print(string.format("[Research Computer] Schedule_Delete request from %s idx=%s host=%s", ply:Nick(), tostring(idx), tostring(host)))
        if not PlayerCanCreateSchedule(ply) then
            net.Start("Schedule_Notice"); net.WriteString("You are not authorized to delete schedule entries."); net.Send(ply)
            return
        end
        PsychEval.Schedule = PsychEval.Schedule or {}
        if idx and PsychEval.Schedule[idx] then
            table.remove(PsychEval.Schedule, idx)
            print(string.format("[Research Computer] Removed schedule entry at index %d", idx))
            BroadcastScheduleTo()
        else
            net.Start("Schedule_Notice"); net.WriteString("Selected schedule entry not found."); net.Send(ply)
        end
    end)

    -- Optional console commands for testing (server console only)
    concommand.Add("sm_broadcast_schedule", function(ply, cmd, args)
        if IsValid(ply) then print("[Research Computer] sm_broadcast_schedule called by " .. ply:Nick()) else print("[Research Computer] sm_broadcast_schedule called from server console") end
        BroadcastScheduleTo()
    end)

    concommand.Add("sm_insert_schedule_test", function(ply, cmd, args)
        if IsValid(ply) then print("[Research Computer] sm_insert_schedule_test called by " .. ply:Nick()) else print("[Research Computer] sm_insert_schedule_test called from server console") end
        PsychEval.Schedule = PsychEval.Schedule or {}
        table.insert(PsychEval.Schedule, {
            host = (IsValid(ply) and ply:Nick()) or "SERVER_TEST",
            date = os.date("%Y-%m-%d"),
            time = os.date("%H:%M"),
            activity = "ServerTest",
            details = "Inserted via sm_insert_schedule_test",
            author = (IsValid(ply) and ply:Nick()) or "CONSOLE",
            created_at = os.date("%Y-%m-%d %H:%M:%S")
        })
        BroadcastScheduleTo()
    end)
end

if CLIENT then
    pcall(function() include("psych_eval/cl_shared.lua") end)
    pcall(function() include("vgui/cl_psych_schedule.lua") end)
    pcall(function() include("vgui/cl_psych_mainmenu.lua") end)
    pcall(function() include("vgui/cl_psych_menu.lua") end)
    pcall(function() include("vgui/cl_psych_testmenu.lua") end)
    pcall(function() include("vgui/cl_psych_entry.lua") end)
    pcall(function() include("vgui/cl_psych_test.lua") end)
    pcall(function() include("vgui/cl_bio_menu.lua") end)
end