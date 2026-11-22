hook.Add("PlayerChangedTeam", "DG_DCLASSNames", function(ply, oldTeam, newTeam)
    if not IsValid(ply) then return end
    if newTeam ~= TEAM_DCLASS and newTeam ~= TEAM_MINER and newTeam ~= TEAM_ZPIZ_CHEF then return end

    local steamName = ply.SteamName and ply:SteamName() or ply:Nick()
    steamName = string.Trim(tostring(steamName or "Unknown"))

    if steamName == "" then
        steamName = "Unknown"
    end

    ply:setRPName("D-" .. string.format("%04d", math.random(0, 9999)) .. " (" .. steamName .. ")")
end)

hook.Add("PlayerInitialSpawn", "DG_DCLASSNames_Initial", function(ply)
    timer.Simple(1, function()
        if not IsValid(ply) then return end
        local teamId = ply:Team()
        if teamId ~= TEAM_DCLASS and teamId ~= TEAM_MINER and teamId ~= TEAM_ZPIZ_CHEF then return end

        local steamName = ply.SteamName and ply:SteamName() or ply:Nick()
        steamName = string.Trim(tostring(steamName or "Unknown"))

        if steamName == "" then
            steamName = "Unknown"
        end

        ply:setRPName("D-" .. string.format("%04d", math.random(0, 9999)) .. " (" .. steamName .. ")")
    end)
end)

hook.Add("canChangeRPName", "DG_DCLASSNames_BlockManualChange", function(ply)
    if not IsValid(ply) then return end
    local teamId = ply:Team()

    if teamId == TEAM_DCLASS or teamId == TEAM_MINER or teamId == TEAM_ZPIZ_CHEF then
        return false, "D-Class personnel cannot change their RP name."
    end
end)