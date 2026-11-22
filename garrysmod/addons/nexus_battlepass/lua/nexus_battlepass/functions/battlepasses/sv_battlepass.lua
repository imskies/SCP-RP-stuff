util.AddNetworkString("Nexus:Battlepass:NetworkBattlepass")

local loadingBP = {}
local function loadBattlepassIntoCache(ply, battlepassID, callback)
    callback = callback or function() end
    if Nexus.Battlepass.BattlepassCache[battlepassID] then callback(Nexus.Battlepass.BattlepassCache[battlepassID], battlepassID) return end

    if battlepassID then
        if loadingBP[battlepassID] then
            table.insert(loadingBP[battlepassID], callback)
            return
        end
        loadingBP[battlepassID] = {callback}

        Nexus.Battlepass.Database:Query({"SELECT * FROM nexus_battlepass WHERE id = %u;", battlepassID}, function(data)
            if not data then return end
            local tbl = data[1]
            tbl.id = tonumber(tbl.id)
            tbl.tiersCount = tonumber(tbl.tiersCount)
            tbl.freeTiers = util.JSONToTable(tbl.freeTiers)
            tbl.premiumTiers = util.JSONToTable(tbl.premiumTiers)
            tbl.created_at = tonumber(tbl.created_at)
            Nexus.Battlepass.BattlepassCache[battlepassID] = tbl
            callback(tbl, battlepassID)

            for _, v in ipairs(loadingBP[battlepassID]) do
                v(tbl, battlepassID)
            end
            loadingBP[battlepassID] = nil
        end)
    else
        Nexus.Battlepass.Database:Query({"SELECT battlepassID FROM nexus_battlepass_activeBattlepass WHERE steamid64 = %s", ply:SteamID64()}, function(data)
            battlepassID = data and data[1] and tonumber(data[1].battlepassID) or Nexus.Battlepass.BattlepassCache["Current SeasonID"]

            if loadingBP[battlepassID] then
                table.insert(loadingBP[battlepassID], callback)
                return
            end
            loadingBP[battlepassID] = {callback}

            Nexus.Battlepass.Database:Query({"SELECT * FROM nexus_battlepass WHERE id = %u;", battlepassID}, function(data)
                if not data then return end
                local tbl = data[1]
                tbl.id = tonumber(tbl.id)
                tbl.tiersCount = tonumber(tbl.tiersCount)
                tbl.freeTiers = util.JSONToTable(tbl.freeTiers)
                tbl.premiumTiers = util.JSONToTable(tbl.premiumTiers)
                tbl.created_at = tonumber(tbl.created_at)
                Nexus.Battlepass.BattlepassCache[battlepassID] = tbl
                callback(tbl, battlepassID)

                for _, v in ipairs(loadingBP[battlepassID]) do
                    v(tbl, battlepassID)
                end
                loadingBP[battlepassID] = nil
            end)
        end)
    end
end

function Nexus.Battlepass:NetworkBattlepass(ply, battlepassID)
    loadBattlepassIntoCache(ply, battlepassID, function(data, battlepassID)
        local hasPly = ply and true or false

        local function NetworkBP(data, ply)
            local data = table.Copy(data)
            data = util.TableToJSON(data)
            data = util.Compress(data)

            Nexus.Battlepass.Database:Query({
                "SELECT * FROM nexus_battlepass_currentTier WHERE steamid64 = %s AND battlepassID = %u;",
                ply:SteamID64(),
                battlepassID
            }, function(curTier)
                if not IsValid(ply) then return end

                if not curTier or #curTier == 0 then
                    Nexus.Battlepass.Database:Query({
                        "INSERT INTO nexus_battlepass_currentTier (steamid64, battlepassID, tier) VALUES(%s, %u, 0);",
                        ply:SteamID64(),
                        battlepassID
                    })
                end

                curTier = curTier and curTier[1] and curTier[1].tier or 0
                curTier = tonumber(curTier) or 0

                local questDATA, isPremium, rewardsClaimed = nil, nil, nil
                local function load()
                    if questDATA == nil or isPremium == nil or rewardsClaimed == nil then return end
                    if not IsValid(ply) then return end
                    ply.NBPCurrentBattlepass = {
                        battlepassID = battlepassID,
                        curTier = curTier,
                        challenges = {},
                        hasPremium = false,
                        rewardsClaimed = rewardsClaimed,
                    }

                    Nexus.Battlepass.Database:Query({
                        "REPLACE INTO nexus_battlepass_activeBattlepass (steamid64, battlepassID) VALUES(%s, %u);",
                        ply:SteamID64(),
                        battlepassID
                    })

                    net.Start("Nexus:Battlepass:NetworkBattlepass")
                    net.WriteBool(isPremium)
                    Nexus:WriteUInt(Nexus.Battlepass.BattlepassCache["Current SeasonID"])
                    Nexus:WriteUInt(#data)
                    net.WriteData(data, #data)
                    Nexus:WriteUInt(curTier)

                    Nexus:WriteUInt(#(questDATA))
                    for _, v in ipairs(questDATA) do
                        ply.NBPCurrentBattlepass.challenges[v.questID] = tonumber(v.progress) or 0
                        net.WriteString(v.questID)
                        Nexus:WriteUInt(tonumber(v.progress) or 0)
                    end

                    local formattedClaimed = {}
                    for id, _ in pairs(rewardsClaimed) do
                        local isPremium = string.Left(id, 1) == "1"
                        local id = tonumber(string.Right(id, #id-1)) or 0
                        table.insert(formattedClaimed, {id, isPremium})
                    end

                    Nexus:WriteUInt(#(formattedClaimed))
                    for _, v in ipairs(formattedClaimed) do
                        Nexus:WriteUInt(v[1])
                        net.WriteBool(v[2])
                    end

                    net.Send(ply)

                    ply.NBPLoading = false
                end

                Nexus.Battlepass.Database:Query({
                    "SELECT * FROM nexus_battlepass_questProgress WHERE steamid64 = %s AND battlepassID = %u;",
                    ply:SteamID64(),
                    battlepassID
                }, function(ourDATA)
                    questDATA = ourDATA or {}
                    load()
                end)

                Nexus.Battlepass.Database:Query({
                    "SELECT steamid64 FROM nexus_battlepass_premium WHERE steamid64 = %s AND battlepassID = %u;",
                    ply:SteamID64(),
                    battlepassID
                }, function(ourDATA)
                    isPremium = ourDATA and #ourDATA > 0 or false
                    load()
                end)

                Nexus.Battlepass.Database:Query({
                    "SELECT tier, premium FROM nexus_battlepass_tiersClaimed WHERE steamid64 = %s AND battlepassID = %u;",
                    ply:SteamID64(),
                    battlepassID
                }, function(ourDATA)
                    ourDATA = ourDATA or {}

                    rewardsClaimed = {}
                    for _, v in ipairs(ourDATA) do
                        rewardsClaimed[tostring(v.premium)..v.tier] = true
                    end

                    load()
                end)
            end)
        end

        if data then
            if hasPly then
                NetworkBP(data, ply)
            else
                for _, v in ipairs(player.GetAll()) do
                    NetworkBP(data, v)
                end
            end

            return
        end

        if IsValid(ply) then
            if ply.NBPLoading then
                Nexus:Notify(ply, 1, 3, "Cooldown", "nBattlepass")
                return
            end

            ply.NBPLoading = true
        else
            for _, v in ipairs(player.GetAll()) do
                v.NBPLoading = true
            end
        end

        Nexus.Battlepass.Database:Query({"SELECT * FROM nexus_battlepass WHERE id = %u;", battlepassID}, function(data)
            if not data then return end
            local tbl = data[1]
            tbl.id = tonumber(tbl.id)
            tbl.tiersCount = tonumber(tbl.tiersCount)
            tbl.freeTiers = util.JSONToTable(tbl.freeTiers)
            tbl.premiumTiers = util.JSONToTable(tbl.premiumTiers)
            tbl.created_at = tonumber(tbl.created_at)
            Nexus.Battlepass.BattlepassCache[battlepassID] = tbl

            if hasPly and IsValid(ply) then
                NetworkBP(tbl, ply)
            elseif not hasPly then
                for _, v in ipairs(player.GetAll()) do
                    NetworkBP(tbl, v)
                end
            end
        end)
    end)
end

function Nexus.Battlepass:DeleteLast()
    if self.IsDeleting then return end
    self.IsDeleting = true
    Nexus.Battlepass.BattlepassIndex = Nexus.Battlepass.BattlepassIndex - 1
    Nexus.Battlepass.Database:Query("DELETE FROM nexus_battlepass WHERE id = "..Nexus.Battlepass.BattlepassCache["Current SeasonID"]..";", function()
        Nexus.Battlepass:GenerateBattlepass(false, function()
            for _, v in ipairs(player.GetAll()) do
                Nexus.Battlepass:NetworkBattlepasses(v)
            end
            self.IsDeleting = false
        end)
    end)
end

util.AddNetworkString("Nexus:Battlepass:NetworkBattlepasses")
function Nexus.Battlepass:NetworkBattlepasses(ply)
    Nexus.Battlepass.Database:Query({
        [[SELECT 
            BP.id,
            BP.name,
            BP.steamid64,
            CASE 
                WHEN BP.steamid64 != '' OR CBP.steamid64 IS NOT NULL THEN 1 
                ELSE 0 
            END AS is_owned
        FROM nexus_battlepass BP
        LEFT JOIN nexus_battlepass_ownedBattlepasses CBP 
            ON CBP.battlepassID = BP.id AND CBP.steamid64 = %s
        WHERE BP.steamid64 = '' OR BP.steamid64 = %s;
        ]],
        ply:SteamID64(),
        ply:SteamID64(),
        ply:SteamID64()
    }, function(data)
        data = data or {}
        if not IsValid(ply) then return end
        ply.NBPCache = ply.NBPCache or {}

        net.Start("Nexus:Battlepass:NetworkBattlepasses")
        Nexus:WriteUInt(#data)
        for _, v in ipairs(data) do
            ply.NBPCache[tonumber(v.id)] = tonumber(v.is_owned) == 1

            Nexus:WriteUInt(tonumber(v.id))
            net.WriteString(v.name)
            net.WriteBool(ply.NBPCache[tonumber(v.id)])
        end
        net.Send(ply)
    end)
end

util.AddNetworkString("Nexus:Battlepass:TiersGiven")
function Nexus.Battlepass:GiveTiers(steamid64, amount)
    local ply = player.GetBySteamID64(steamid64)
    if IsValid(ply) then
        ply.NBPCurrentBattlepass.curTier = ply.NBPCurrentBattlepass.curTier + amount

        net.Start("Nexus:Battlepass:TiersGiven")
        Nexus:WriteUInt(amount)
        net.Send(ply)
    end

    Nexus.Battlepass.Database:Query({
        [[UPDATE nexus_battlepass_currentTier
        SET tier = tier + %u
        WHERE steamid64 = %s
        AND battlepassID = (
            SELECT battlepassID
            FROM nexus_battlepass_activeBattlepass
            WHERE steamid64 = %s
        );]],
        amount,
        steamid64,
        steamid64
    })
end

util.AddNetworkString("Nexus:Battlepass:PremiumGiven")
function Nexus.Battlepass:GivePremium(steamid64)
    local ply = player.GetBySteamID64(steamid64)
    if IsValid(ply) then
        ply.NBPCurrentBattlepass.hasPremium = true

        net.Start("Nexus:Battlepass:PremiumGiven")
        net.Send(ply)
    end

    Nexus.Battlepass.Database:Query({
        [[INSERT INTO nexus_battlepass_premium 
        (steamid64, battlepassID)
        VALUES(%s, (
            SELECT battlepassID
            FROM nexus_battlepass_activeBattlepass
            WHERE steamid64 = %s
        ));]],
        steamid64,
        steamid64,
    })
end

util.AddNetworkString("Nexus:Battlepass:SwitchBP")
net.Receive("Nexus:Battlepass:SwitchBP", function(len, ply)
    local id = Nexus:ReadUInt()

    ply.NBPCache = ply.NBPCache or {}

    if Nexus.Battlepass:HasUnlockedBattlepass(id, ply) then
        Nexus.Battlepass:NetworkBattlepass(ply, id)
        return
    end

    Nexus:PopupAsk(ply, Nexus:GetPhrase("Purchase for 1 Switch Token", "nBattlepass", ply), function()
        if Nexus.Battlepass:GetSwitchTokens(ply) < 1 then
            Nexus:Notify(ply, 1, 4, "Not enough switch tokens", "nBattlepass")
            return
        end

        Nexus.Battlepass:AddSwitchTokens(ply:SteamID64(), -1)

        local function LoadedDATA(data)
            if not IsValid(ply) then return end
            ply.NBPCache[data.id] = true
            Nexus.Battlepass:NetworkBattlepass(ply, data.id)

            Nexus.Battlepass.Database:Query({
                "INSERT INTO nexus_battlepass_ownedBattlepasses (steamid64, battlepassID) VALUES(%s, %u);",
                ply:SteamID64(),
                data.id
            })
        end

        local data = Nexus.Battlepass.BattlepassCache[id]
        if data then
            LoadedDATA(data)
            return
        end

        ply.NBPLoading = true
        Nexus.Battlepass.Database:Query({"SELECT * FROM nexus_battlepass WHERE id = %u;", id}, function(data)
            if not IsValid(ply) then return end
            ply.NBPLoading = false

            if not data then return end

            local tbl = data[1]
            tbl.id = tonumber(tbl.id)
            tbl.tiersCount = tonumber(tbl.tiersCount)
            tbl.freeTiers = util.JSONToTable(tbl.freeTiers)
            tbl.premiumTiers = util.JSONToTable(tbl.premiumTiers)
            tbl.created_at = tonumber(tbl.created_at)

            if tbl.steamid64 ~= "" and tbl.steamid64 ~= ply:SteamID64() then
                Nexus:Notify(ply, 1, 4, "Not your battlepass", "nBattlepass")
                return
            end

            LoadedDATA(tbl)
        end)
    end)
end)

util.AddNetworkString("Nexus:Battlepass:ClaimTier")
net.Receive("Nexus:Battlepass:ClaimTier", function(len, ply)
    local tier = Nexus:ReadUInt()
    local isPremium = net.ReadBool()

    if not ply.NBPCurrentBattlepass then return end
    if ply.NBPCurrentBattlepass.curTier < tier then
        Nexus:Notify(ply, 1, 3, "Havent Unlocked Tier", "nBattlepass")
        return
    end

    if isPremium and not ply.NBPCurrentBattlepass.hasPremium then
        Nexus:Notify(ply, 1, 3, "Not got premium", "nBattlepass")
        return
    end

    local tierID = (isPremium and "1" or "0")..tier
    if ply.NBPCurrentBattlepass.rewardsClaimed[tierID] then
        Nexus:Notify(ply, 1, 3, "Already claimed reward", "nBattlepass")
        return
    end

    local data = Nexus.Battlepass.BattlepassCache[ply.NBPCurrentBattlepass.battlepassID]
    if not data then return end

    local reward = isPremium and data.premiumTiers[tier] or data.freeTiers[tier]
    if not reward then return end

    local success, message = Nexus.Battlepass.Rewards[reward.rewardID].OnClaim(ply, reward.rewardValue)
    if success then
        ply.NBPCurrentBattlepass.rewardsClaimed[tierID] = true
        Nexus:Notify(ply, 0, 3, "Successfully Claimed Tier", "nBattlepass")

        Nexus.Battlepass.Database:Query({
            "REPLACE INTO nexus_battlepass_tiersClaimed (steamid64, battlepassID, tier, premium) VALUES(%s, %u, %u, %u);",
            ply:SteamID64(),
            ply.NBPCurrentBattlepass.battlepassID,
            tier,
            isPremium and 1 or 0
        })

        net.Start("Nexus:Battlepass:ClaimTier")
        Nexus:WriteUInt(tier)
        net.WriteBool(isPremium)
        net.Send(ply)
    else
        Nexus:Notify(ply, 1, 3, message)
    end
end)