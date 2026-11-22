util.AddNetworkString("DeepSquads:NotifyHealth") -- SV to CL
util.AddNetworkString("DeepSquads:NotifySquad")
util.AddNetworkString("DeepSquads:NotifyMessage")
util.AddNetworkString("DeepSquads:NotifySquadless")
util.AddNetworkString("DeepSquads:OpenMenu")
util.AddNetworkString("DeepSquads:StatusFail")
util.AddNetworkString("DeepSquads:SendSquad")

util.AddNetworkString("DeepSquads:LeaveSquad") -- CL to SV
util.AddNetworkString("DeepSquads:MakeLeader")
util.AddNetworkString("DeepSquads:KickPlayer")
util.AddNetworkString("DeepSquads:MakeSquad")
util.AddNetworkString("DeepSquads:JoinSquad")
util.AddNetworkString("DeepSquads:DeleteSquad")
util.AddNetworkString("DeepSquads:ChangeSquadName")
util.AddNetworkString("DeepSquads:RequestMasterList")

-- Lightweight net message that tells a player's squad that their health has changed
DeepSquads.UpdateHP = function(ply)
    if not DeepSquads.CachedPlayers[ply] then return end
    if not DeepSquads.Squads[DeepSquads.CachedPlayers[ply]] then
        DeepSquads.CachedPlayers[ply] = nil
        DeepSquads.SquadlessPlayers[ply] = true
        net.Start("DeepSquads:NotifySquadless")
        net.Send(ply)
        return
    end

    local squad = DeepSquads.Squads[DeepSquads.CachedPlayers[ply]]
    local squad_refs = {}
    for sid,plyinfo in pairs(squad.members) do
        if not plyinfo.plyref or not IsValid(plyinfo.plyref) or not IsEntity(plyinfo.plyref) or not plyinfo.plyref:IsPlayer() then
            squad.members[sid] = nil
            continue
        end
        DeepSquads.CachedPlayers[plyinfo.plyref] = squad.creator:SteamID()
        DeepSquads.SquadlessPlayers[plyinfo.plyref] = nil
        table.insert(squad_refs, plyinfo.plyref)
    end

    net.Start("DeepSquads:NotifyHealth")
    net.WriteString(ply:SteamID())
    net.WriteFloat(ply:Health())
    net.Send(squad_refs)
end

-- Refreshes the squad, squad members, health, and names
DeepSquads.UpdateSquad = function(squad)
    -- If the squad creator is gone, appoint a new leader
    if table.Count(squad.members) == 0 or not squad.members[squad.sid] or not squad.creator or not IsValid(squad.creator) or not IsEntity(squad.creator) or not squad.creator:IsPlayer() then
        DeepSquads.Squads[squad.sid] = nil
        local new_leader = false
        for sid,plyinfo in pairs(squad.members) do
            if not plyinfo.plyref or not IsValid(plyinfo.plyref) or not IsEntity(plyinfo.plyref) or not plyinfo.plyref:IsPlayer() then continue end
            if not new_leader then
                DeepSquads.Squads[sid] = squad
                squad.sid = sid
                squad.creator = plyinfo.plyref
                new_leader = true
            end
            DeepSquads.CachedPlayers[plyinfo.plyref] = squad.sid
        end
        -- Now that there is a squad creator, retry the update
        if new_leader then DeepSquads.UpdateSquad(squad) end
        return -- If there was no one left in the group, that's fine, the squad was already dereferenced
    end

    local squad_refs = {}
    for sid,plyinfo in pairs(squad.members) do
        if not plyinfo.plyref or not IsValid(plyinfo.plyref) or not IsEntity(plyinfo.plyref) or not plyinfo.plyref:IsPlayer() then
            squad.members[sid] = nil
            continue
        end
        DeepSquads.CachedPlayers[plyinfo.plyref] = squad.creator:SteamID()
        DeepSquads.SquadlessPlayers[plyinfo.plyref] = nil
        table.insert(squad_refs, plyinfo.plyref)
    end

    net.Start("DeepSquads:NotifySquad")
    net.WriteString(squad.name)
    net.WriteString(squad.sid)
    net.WriteUInt(#squad_refs, 8) -- This tells the client how many squad members are incoming
    for key,ply in ipairs(squad_refs) do
        squad.members[ply:SteamID()] = {
            name = ply:Nick(),
            hp = ply:Health(),
            plyref = ply
        }
        net.WriteString(ply:SteamID())
        net.WriteString(ply:Nick())
        net.WriteFloat(ply:Health())
        net.WriteUInt(ply:UserID(), 8)
        local pos = ply:GetPos()
        pos.z = pos.z + 50
        net.WriteVector(pos)
    end
    net.Send(squad_refs)
end

DeepSquads.UpdateAllSquads = function()
    local iteration = 0
    for creatorsid,squad in pairs(DeepSquads.Squads) do
        iteration = iteration + 1
        timer.Simple(iteration * 0.1, function()
            DeepSquads.UpdateSquad(squad) -- Spread out the work to avoid potential stutter
        end)
    end
end

DeepSquads.SquadChat = function(ply, message)
    if not DeepSquads.CachedPlayers[ply] then return end
    if not DeepSquads.Squads[DeepSquads.CachedPlayers[ply]] then
        DeepSquads.CachedPlayers[ply] = nil
        DeepSquads.SquadlessPlayers[ply] = true
        net.Start("DeepSquads:NotifySquadless")
        net.Send(ply)
        return
    end

    local trimmed_message = string.Trim(string.Right(message, -7))
    if trimmed_message == "" then -- Empty message
        return
    end

    local squad = DeepSquads.Squads[DeepSquads.CachedPlayers[ply]]
    local squad_refs = {}
    for sid,plyinfo in pairs(squad.members) do
        if not plyinfo.plyref or not IsValid(plyinfo.plyref) or not IsEntity(plyinfo.plyref) or not plyinfo.plyref:IsPlayer() then
            squad.members[sid] = nil
            continue
        end
        DeepSquads.CachedPlayers[plyinfo.plyref] = squad.creator:SteamID()
        DeepSquads.SquadlessPlayers[plyinfo.plyref] = nil
        table.insert(squad_refs, plyinfo.plyref)
    end

    net.Start("DeepSquads:NotifyMessage")
    net.WriteBool(false)
    net.WriteString(ply:Nick())
    net.WriteString(trimmed_message)
    net.Send(squad_refs)

    local listen_refs = {}
    for loopply,squadsid in pairs(DeepSquads.CachedPlayers) do
        if table.HasValue(squad_refs, loopply) then continue end
        if table.HasValue(DeepSquads.Config.JobTags[team.GetName(loopply:Team())], "Spy") then
            table.insert(listen_refs, loopply)
        end
    end
    for loopply,bool in pairs(DeepSquads.SquadlessPlayers) do
        if table.HasValue(squad_refs, loopply) then continue end
        if table.HasValue(DeepSquads.Config.JobTags[team.GetName(loopply:Team())], "Spy") then
            table.insert(listen_refs, loopply)
        end
    end

    if #listen_refs <= 0 then return end
    net.Start("DeepSquads:NotifyMessage")
    net.WriteBool(true)
    net.WriteString(ply:Nick())
    net.WriteString(trimmed_message)
    net.Send(listen_refs)
end

DeepSquads.AddToSquad = function(ply, squad_sid, squad_name, tag)
    if DeepSquads.CachedPlayers[ply] and DeepSquads.Squads[DeepSquads.CachedPlayers[ply]] then
        DeepSquads.RemoveFromSquad(ply:SteamID(), DeepSquads.Squads[DeepSquads.CachedPlayers[ply]])
    end
    local squad
    if DeepSquads.Squads[squad_sid] then -- Already existing? Add them to the members list
        squad = DeepSquads.Squads[squad_sid]
        squad.members[ply:SteamID()] = {name = ply:Nick(), hp = ply:Health(), plyref = ply}
    else -- No squad? Make a new one
        local new_name = string.Trim(string.Left(squad_name or "New Squad", 36))
        if new_name == "" then
            new_name = "New Squad"
        end
        squad = {
            name = new_name,
            tag = tag or "Public",
            sid = ply:SteamID(),
            creator = ply,
            members = {
                [ply:SteamID()] = {name = ply:Nick(), hp = ply:Health(), plyref = ply}
            }
        }
        DeepSquads.Squads[squad.sid] = squad
    end
    DeepSquads.CachedPlayers[ply] = squad.sid
    DeepSquads.SquadlessPlayers[ply] = nil
    DeepSquads.UpdateSquad(squad)
end

DeepSquads.RemoveFromSquad = function(sid, squad)
    if not squad then return end
    if not squad.members then return end
    if not squad.members[sid] then return end
    squad.members[sid] = nil
    local plyref = player.GetBySteamID(sid)
    if plyref and IsValid(plyref) and IsEntity(plyref) and plyref:IsPlayer() then
        DeepSquads.CachedPlayers[plyref] = nil
        DeepSquads.SquadlessPlayers[plyref] = true
        net.Start("DeepSquads:NotifySquadless")
        net.Send(plyref)
    end
    DeepSquads.UpdateSquad(squad)
end

DeepSquads.DeleteSquad = function(squad)
    if not squad then return end
    for sid,plyinfo in pairs(squad.members) do
        if not plyinfo.plyref or not IsValid(plyinfo.plyref) or not IsEntity(plyinfo.plyref) or not plyinfo.plyref:IsPlayer() then continue end
        DeepSquads.CachedPlayers[plyinfo.plyref] = nil
        DeepSquads.SquadlessPlayers[plyinfo.plyref] = true
        net.Start("DeepSquads:NotifySquadless")
        net.Send(plyinfo.plyref)
    end
    DeepSquads.Squads[squad.sid] = nil
end

DeepSquads.PlayerCooldown = {}
net.Receive("DeepSquads:LeaveSquad", function(len, ply)
    if DeepSquads.PlayerCooldown[ply] and DeepSquads.PlayerCooldown[ply] > CurTime() then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You are doing that too fast! Please wait a second before retrying.")
        net.Send(ply)
        return
    end
    DeepSquads.PlayerCooldown[ply] = CurTime() + 1
    if DeepSquads.SquadlessPlayers[ply] or not DeepSquads.Squads[DeepSquads.CachedPlayers[ply]] then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You are not in a squad!")
        net.Send(ply)
        net.Start("DeepSquads:NotifySquadless")
        net.Send(ply)
        return
    end
    local squad = DeepSquads.Squads[DeepSquads.CachedPlayers[ply]]
    DeepSquads.RemoveFromSquad(ply:SteamID(), squad)
end)

net.Receive("DeepSquads:MakeLeader", function(len, ply)
    if DeepSquads.PlayerCooldown[ply] and DeepSquads.PlayerCooldown[ply] > CurTime() then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You are doing that too fast! Please wait a second before retrying.")
        net.Send(ply)
        return
    end
    DeepSquads.PlayerCooldown[ply] = CurTime() + 1
    if DeepSquads.SquadlessPlayers[ply] or not DeepSquads.Squads[DeepSquads.CachedPlayers[ply]] then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You are not in a squad!")
        net.Send(ply)
        net.Start("DeepSquads:NotifySquadless")
        net.Send(ply)
        return
    end
    -- I'd rather do this instead of searching for a stored squad with their steamID
    -- In the event that an empty squad was somehow created, it would enable players to force other players into that squad
    local squad = DeepSquads.Squads[DeepSquads.CachedPlayers[ply]]
    if squad.sid ~= ply:SteamID() then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You are not the leader of this squad!")
        net.Send(ply)
        return
    end
    local new_leader_sid = net.ReadString()
    local new_leader = player.GetBySteamID(new_leader_sid)
    if not new_leader or not IsValid(new_leader) or not IsEntity(new_leader) or not new_leader:IsPlayer() then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("That player is unavailable to make leader!")
        net.Send(ply)
        return
    end
    DeepSquads.Squads[DeepSquads.CachedPlayers[ply]] = nil
    squad.sid = new_leader_sid
    squad.creator = new_leader
    DeepSquads.Squads[new_leader_sid] = squad
    DeepSquads.UpdateSquad(squad)
end)

net.Receive("DeepSquads:KickPlayer", function(len, ply)
    if DeepSquads.PlayerCooldown[ply] and DeepSquads.PlayerCooldown[ply] > CurTime() then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You are doing that too fast! Please wait a second before retrying.")
        net.Send(ply)
        return
    end
    DeepSquads.PlayerCooldown[ply] = CurTime() + 1
    if DeepSquads.SquadlessPlayers[ply] or not DeepSquads.Squads[DeepSquads.CachedPlayers[ply]] then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You are not in a squad!")
        net.Send(ply)
        net.Start("DeepSquads:NotifySquadless")
        net.Send(ply)
        return
    end
    local squad = DeepSquads.Squads[DeepSquads.CachedPlayers[ply]]
    if squad.sid ~= ply:SteamID() then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You are not the leader of this squad!")
        net.Send(ply)
        return
    end
    local player_to_remove_sid = net.ReadString()
    DeepSquads.RemoveFromSquad(player_to_remove_sid, squad)
end)

net.Receive("DeepSquads:ChangeSquadName", function(len, ply)
    if DeepSquads.PlayerCooldown[ply] and DeepSquads.PlayerCooldown[ply] > CurTime() then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You are doing that too fast! Please wait a second before retrying.")
        net.Send(ply)
        return
    end
    DeepSquads.PlayerCooldown[ply] = CurTime() + 1
    if DeepSquads.SquadlessPlayers[ply] or not DeepSquads.Squads[DeepSquads.CachedPlayers[ply]] then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You are not in a squad!")
        net.Send(ply)
        net.Start("DeepSquads:NotifySquadless")
        net.Send(ply)
        return
    end
    local squad = DeepSquads.Squads[DeepSquads.CachedPlayers[ply]]
    if squad.sid ~= ply:SteamID() then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You are not the leader of this squad!")
        net.Send(ply)
        return
    end
    local new_squad_name = string.Trim(string.Left(net.ReadString(), 36))
    if new_squad_name ~= "" then
        squad.name = new_squad_name
    else
        squad.name = "New Squad"
    end
    DeepSquads.UpdateSquad(squad)
end)

net.Receive("DeepSquads:MakeSquad", function(len, ply)
    if DeepSquads.PlayerCooldown[ply] and DeepSquads.PlayerCooldown[ply] > CurTime() then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You are doing that too fast! Please wait a second before retrying.")
        net.Send(ply)
        return
    end
    DeepSquads.PlayerCooldown[ply] = CurTime() + 1
    local squad_name = string.Trim(string.Left(net.ReadString(), 36))
    local tag = net.ReadString()
    if tag == "Spy" then -- prevented client-side also
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You cannot make a squad of this type!")
        net.Send(ply)
        return
    end
    if not DeepSquads.Config.JobTags[team.GetName(ply:Team())] or #DeepSquads.Config.JobTags[team.GetName(ply:Team())] == 0 or (#DeepSquads.Config.JobTags[team.GetName(ply:Team())] == 1 and DeepSquads.Config.JobTags[team.GetName(ply:Team())][1] == "Spy") then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You are unable to create or join squads as this job!")
        net.Send(ply)
        return
    end
    if not table.HasValue(DeepSquads.Config.JobTags[team.GetName(ply:Team())], tag) then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You are unable to create or join " .. tag .. " squads!")
        net.Send(ply)
        return
    end
    DeepSquads.AddToSquad(ply, ply:SteamID(), squad_name, tag)
end)

net.Receive("DeepSquads:JoinSquad", function(len, ply)
    if DeepSquads.PlayerCooldown[ply] and DeepSquads.PlayerCooldown[ply] > CurTime() then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You are doing that too fast! Please wait a second before retrying.")
        net.Send(ply)
        return
    end
    DeepSquads.PlayerCooldown[ply] = CurTime() + 1
    local squad_sid = net.ReadString()
    if not DeepSquads.Squads[squad_sid] then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("That squad does not exist!")
        net.Send(ply)
        return
    end
    if squad_sid == DeepSquads.CachedPlayers[ply] then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You are already in this squad!")
        net.Send(ply)
        return
    end
    local squad = DeepSquads.Squads[squad_sid]
    if table.Count(squad.members) >= 12 then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("This squad is full!")
        net.Send(ply)
        return
    end
    if not DeepSquads.Config.JobTags[team.GetName(ply:Team())] or #DeepSquads.Config.JobTags[team.GetName(ply:Team())] == 0 then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You are unable to create or join squads as this job!")
        net.Send(ply)
        return
    end
    if not table.HasValue(DeepSquads.Config.JobTags[team.GetName(ply:Team())], squad.tag) then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You are unable to create or join " .. tag .. " squads!")
        net.Send(ply)
        return
    end
    DeepSquads.AddToSquad(ply, squad_sid)
end)

net.Receive("DeepSquads:DeleteSquad", function(len, ply)
    if DeepSquads.PlayerCooldown[ply] and DeepSquads.PlayerCooldown[ply] > CurTime() then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("You are doing that too fast! Please wait a second before retrying.")
        net.Send(ply)
        return
    end
    DeepSquads.PlayerCooldown[ply] = CurTime() + 1
    if not ply:IsAdmin() then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("Only admins can delete squads!")
        net.Send(ply)
        return
    end
    local squad_sid = net.ReadString()
    if not DeepSquads.Squads[squad_sid] then
        net.Start("DeepSquads:StatusFail")
        net.WriteString("That squad does not exist!")
        net.Send(ply)
        return
    end
    local squad = DeepSquads.Squads[squad_sid]
    DeepSquads.DeleteSquad(squad)
end)

-- Sends every squad that the player is allowed to view to the player
net.Receive("DeepSquads:RequestMasterList", function(len, ply)
    if not DeepSquads.Config.JobTags[team.GetName(ply:Team())] or #DeepSquads.Config.JobTags[team.GetName(ply:Team())] == 0 then return end
    for squadsid,squad in pairs(DeepSquads.Squads) do
        if not table.HasValue(DeepSquads.Config.JobTags[team.GetName(ply:Team())], squad.tag) then continue end
        net.Start("DeepSquads:SendSquad")
        net.WriteString(squad.name)
        net.WriteString(squad.tag)
        net.WriteString(squad.sid)
        net.WriteUInt(table.Count(squad.members), 8)
        for sid,plyinfo in pairs(squad.members) do
            net.WriteString(sid) -- Necessary for avatar preview
            net.WriteString(plyinfo.name)
        end
        net.Send(ply)
    end
end)

MsgC("[Deep Squads]", DeepSquads.Success, " Server networking initialized.\n") -- EOF
