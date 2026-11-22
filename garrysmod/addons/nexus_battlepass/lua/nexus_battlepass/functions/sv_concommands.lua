concommand.Add("battlepass_buytier", function(ply, cmd, args)
    if IsValid(ply) and not Nexus.Battlepass:IsSuperadmin(ply) then
        Nexus:Notify(ply, 1, 3, "Incorrect Usergroup", "nBattlepass")
        return
    end

    local steamid64 = tostring(args[1])
    local amount = tonumber(args[2])

    if (not steamid64 or not amount) or string.lower(string.Left(steamid64, 5)) == "steam" or (#steamid64 ~= 17) then
        print("Incorrect usage of battlepass_buytier (battlepass_buytier steamid64 amount)")
        return
    end

    Nexus.Battlepass:GiveTiers(steamid64, amount)
end)


concommand.Add("battlepass_buypremium", function(ply, cmd, args)
    if IsValid(ply) and not Nexus.Battlepass:IsSuperadmin(ply) then
        Nexus:Notify(ply, 1, 3, "Incorrect Usergroup", "nBattlepass")
        return
    end

    local steamid64 = tostring(args[1])

    if (not steamid64) or string.lower(string.Left(steamid64, 5)) == "steam" or (#steamid64 ~= 17) then
        print("Incorrect usage of battlepass_buytier (battlepass_buypremium steamid64)")
        return
    end

    Nexus.Battlepass:GivePremium(steamid64)
end)

concommand.Add("battlepass_generatebattlepass", function(ply, cmd, args)
    if IsValid(ply) and not Nexus.Battlepass:IsSuperadmin(ply) then
        Nexus:Notify(ply, 1, 3, "Incorrect Usergroup", "nBattlepass")
        return
    end

    local steamid64 = tostring(args[1])

    if (not steamid64) or string.lower(string.Left(steamid64, 5)) == "steam" or (#steamid64 ~= 17) then
        print("Incorrect usage of battlepass_buytier (battlepass_buypremium steamid64)")
        return
    end

    Nexus.Battlepass:GenerateBattlepass(steamid64)
end)

concommand.Add("battlepass_givetokens", function(ply, cmd, args)
    if IsValid(ply) and not Nexus.Battlepass:IsSuperadmin(ply) then
        Nexus:Notify(ply, 1, 3, "Incorrect Usergroup", "nBattlepass")
        return
    end

    local steamid64 = tostring(args[1])
    local amount = tonumber(args[2])

    if (not steamid64 or not amount) or string.lower(string.Left(steamid64, 5)) == "steam" or (#steamid64 ~= 17) then
        print("Incorrect usage of battlepass_buytier (battlepass_buytier steamid64 amount)")
        return
    end

    Nexus.Battlepass:AddSwitchTokens(steamid64, amount)
end)

concommand.Add("battlepass_resetdatabase", function(ply, cmd, args)
    Nexus.Battlepass.Database:StartTransaction()

    Nexus.Battlepass.Database:AddTransaction("DROP TABLE nexus_battlepass_premium")
    Nexus.Battlepass.Database:AddTransaction("DROP TABLE nexus_battlepass_activeBattlepass")
    Nexus.Battlepass.Database:AddTransaction("DROP TABLE nexus_battlepass_questProgress")
    Nexus.Battlepass.Database:AddTransaction("DROP TABLE nexus_battlepass_currentTier")
    Nexus.Battlepass.Database:AddTransaction("DROP TABLE nexus_battlepass_tiersClaimed")
    Nexus.Battlepass.Database:AddTransaction("DROP TABLE nexus_battlepass_ownedBattlepasses")
    Nexus.Battlepass.Database:AddTransaction("DROP TABLE nexus_battlepass")

    Nexus.Battlepass.Database:EndTransaction(function()
        Nexus.Battlepass:ConnectDatabase()
    end)
end)