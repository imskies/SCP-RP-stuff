function Nexus.Battlepass:IsSuperadmin(ply)
    return Nexus:GetValue("nbp-superadmin")[ply:GetUserGroup()]
end

function Nexus.Battlepass:GetSeasonsMaxTier(seasonDATA)
    local max = 1
    for tier, _ in pairs(seasonDATA.premiumTiers) do
        max = math.max(max, tier)
    end

    for tier, _ in pairs(seasonDATA.freeTiers) do
        max = math.max(max, tier)
    end

    return math.max(seasonDATA.tiersCount, max)
end

function Nexus.Battlepass:HasUnlockedBattlepass(id, ply)
    if CLIENT then
        for _, v in ipairs(Nexus.Battlepass.Battlepasses) do
            if v.id == id and v.hasUnlocked then
                return true
            end
        end

        return id == Nexus.Battlepass.ThisSeason.curSeason or false
    end

    if Nexus.Battlepass.BattlepassCache["Current SeasonID"] == id then
        return true
    end

    if ply.NBPCache and ply.NBPCache[id] then
        return true
    end

    return false
end