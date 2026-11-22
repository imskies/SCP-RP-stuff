local function GenerateReward(isPremium)
    local totalWeight = 0
    for _, v in ipairs(Nexus.Battlepass.RewardChances) do
        if v.isPremium ~= isPremium then continue end
        totalWeight = totalWeight + v.weight
    end

    local neededNum = math.random()*totalWeight
    local curWeight = 0
    for _, v in ipairs(Nexus.Battlepass.RewardChances) do
        if v.isPremium ~= isPremium then continue end
        curWeight = curWeight + v.weight

        if curWeight > neededNum then
            return v.rewardID, v.rewardValue
        end
    end

    return nil
end

function Nexus.Battlepass:GenerateBattlepass(ply, callback)
    callback = callback or function() end

    local steamid64 = IsValid(ply) and ply:SteamID64() or ""
    if isstring(ply) then
        steamid64 = ply
        ply = player.GetBySteamID64(steamid64)
        if not ply then
            ply = steamid64
        end
    end

    local battlepass = {
        created_at = os.time(),
        id = false,
        tiersCount = Nexus:GetValue("nbp-tiersCount"),
        freeTiers = {},
        premiumTiers = {},
        steamid64 = steamid64,
    }

    local forceGenerate = {
        freeTiers = {},
        premiumTiers = {},
    }
    for _, v in ipairs(Nexus:GetValue("nbp-forceTierToGenerate")) do
        forceGenerate[v.IsPremiumSlot and "premiumTiers" or "freeTiers"][tonumber(v.Tier)] = true
    end

    local freeChance, premiumChance = Nexus:GetValue("nbp-generationChances")["Free"], Nexus:GetValue("nbp-generationChances")["Premium"]
    for tier = 1, Nexus:GetValue("nbp-tiersCount") do
        if (math.random() < freeChance/100) or forceGenerate.freeTiers[tier] then
            local rewardID, rewardValue = GenerateReward(false)
            if not rewardID or not rewardValue then continue end
            battlepass.freeTiers[tier] = {
                rewardID = rewardID,
                rewardValue = rewardValue,
            }
        end

        if (math.random() < premiumChance/100) or forceGenerate.premiumTiers[tier] then
            local rewardID, rewardValue = GenerateReward(true)
            if not rewardID or not rewardValue then continue end
            battlepass.premiumTiers[tier] = {
                rewardID = rewardID,
                rewardValue = rewardValue,
            }
        end
    end

    for _, v in ipairs(Nexus:GetValue("nbp-forceTierValue")) do
        battlepass[v.IsPremiumSlot and "premiumTiers" or "freeTiers"][tonumber(v.Tier)] = {
            rewardID = v.Reward,
            rewardValue = v.Value,
        }
    end

    local name = ""
    if not ply then
        Nexus.Battlepass.BattlepassIndex = Nexus.Battlepass.BattlepassIndex + 1
        name = string.format(Nexus:GetValue("nbp-name"), Nexus.Battlepass.BattlepassIndex)
    else
        name = "CUSTOM"
    end
    Nexus.Battlepass.Database:Query({
        "INSERT INTO nexus_battlepass (created_at, name, tiersCount, freeTiers, premiumTiers, steamid64) VALUES(%u, %s, %u, %s, %s, %s)",
        os.time(),
        name,
        battlepass.tiersCount,
        util.TableToJSON(battlepass.freeTiers),
        util.TableToJSON(battlepass.premiumTiers),
        steamid64
    }, function(_, insertID)
        battlepass.id = insertID
        battlepass.name = name

        Nexus.Battlepass.BattlepassCache[battlepass.id] = battlepass

        if steamid64 == "" then
            Nexus.Battlepass.BattlepassCache["Current SeasonID"] = battlepass.id

            for _, v in ipairs(player.GetAll()) do
                Nexus.Battlepass:NetworkBattlepass(v, battlepass.id)
            end
        elseif IsValid(ply) then
            Nexus.Battlepass:NetworkBattlepass(ply, battlepass.id)
        end

        callback(battlepass)
    end)
end

local hasLoaded = {}
hook.Add("Think", "Nexus:Battlepass:NextGeneration", function()
    local curID = Nexus.Battlepass.BattlepassCache["Current SeasonID"]
    if not curID then return end

    local data = Nexus.Battlepass.BattlepassCache[curID]
    if not data then return end

    local timeLeft = math.max(0, (data.created_at + Nexus:GetValue("nbp-seasonDuration")) - os.time())
    if timeLeft == 0 then
        if hasLoaded[curID] then return end
        hasLoaded[curID] = true
        Nexus.Battlepass:GenerateBattlepass()
    end
end)