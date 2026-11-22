Nexus.Battlepass.BattlepassCache = Nexus.Battlepass.BattlepassCache or {}

local queries = {
    [[CREATE TABLE IF NOT EXISTS nexus_battlepass_reward_chances (
        id INTEGER PRIMARY KEY %auto_increment% NOT NULL,
        rewardID VARCHAR(32) NOT NULL,
        rewardValue VARCHAR(1024) NOT NULL,
        isPremium BOOLEAN NOT NULL,
        weight INTEGER UNSIGNED NOT NULL
    );]],
    [[CREATE TABLE IF NOT EXISTS nexus_battlepass (
        id INTEGER PRIMARY KEY %auto_increment% NOT NULL,
        created_at INTEGER UNSIGNED NOT NULL,
        name VARCHAR(64),
        tiersCount INTEGER UNSIGNED NOT NULL,
        freeTiers JSON NOT NULL,
        premiumTiers JSON NOT NULL,
        steamid64 VARCHAR(17)
    );]],
    [[CREATE TABLE IF NOT EXISTS nexus_battlepass_switchTokens (
        steamid64 VARCHAR(17) PRIMARY KEY NOT NULL,
        tokens INTEGER NOT NULL
    );]],
    [[CREATE TABLE IF NOT EXISTS nexus_battlepass_ownedBattlepasses (
        id INTEGER PRIMARY KEY %auto_increment% NOT NULL,
        steamid64 VARCHAR(17) NOT NULL,
        battlepassID INTEGER UNSIGNED NOT NULL
    );]],
    [[CREATE TABLE IF NOT EXISTS nexus_battlepass_tiersClaimed (
        steamid64 VARCHAR(17) NOT NULL,
        battlepassID INTEGER UNSIGNED NOT NULL,
        tier INTEGER UNSIGNED NOT NULL,
        premium BOOLEAN NOT NULL,
        PRIMARY KEY (steamid64, battlepassID, tier, premium)
    )]],
    [[CREATE TABLE IF NOT EXISTS nexus_battlepass_currentTier (
        id INTEGER PRIMARY KEY %auto_increment% NOT NULL,
        steamid64 VARCHAR(17) NOT NULL,
        battlepassID INTEGER UNSIGNED NOT NULL,
        tier INTEGER UNSIGNED NOT NULL
    )]],
    [[CREATE TABLE IF NOT EXISTS nexus_battlepass_questProgress (
        steamid64 VARCHAR(17) NOT NULL,
        battlepassID INTEGER UNSIGNED NOT NULL,
        questID VARCHAR(32) NOT NULL,
        progress INTEGER UNSIGNED NOT NULL,
        PRIMARY KEY (steamid64, battlepassID, questID)
    )]],
    [[CREATE TABLE IF NOT EXISTS nexus_battlepass_activeBattlepass (
        steamid64 VARCHAR(17) PRIMARY KEY NOT NULL,
        battlepassID INTEGER UNSIGNED NOT NULL
    )]],
    [[CREATE TABLE IF NOT EXISTS nexus_battlepass_premium (
        steamid64 VARCHAR(17) NOT NULL,
        battlepassID INTEGER UNSIGNED NOT NULL,
        PRIMARY KEY (steamid64, battlepassID)
    );]],
}

util.AddNetworkString("Nexus:Battlepass:DatabaseConnected")
function Nexus.Battlepass:ConnectDatabase()
    if Nexus.Battlepass.Database then
        Nexus.Battlepass.Database:Disconnect()
    end

    Nexus.Battlepass.RewardChances = {}
    Nexus.Battlepass.BattlepassCache = {}
    Nexus.Battlepass.BattlepassIndex = 0

    Nexus.Battlepass.Database = Nexus:InitializeDatabase("NBattlepass", Nexus:GetValue("nbp-db"), {
        login = Nexus:GetValue("nbp-mysql"),
        queries = queries,
    }, function(MODULE)
        Nexus.Battlepass.Database = MODULE

        print("[ Nexus Battlepass ] ✅ Database")

        net.Start("Nexus:Battlepass:DatabaseConnected")
        net.Broadcast()

        local isDone = 0
        local function onFinished()
            if isDone < 2 then return end
            Nexus.Battlepass:ConvertOldToNew()
        end

        Nexus.Battlepass.Database:Query({"SELECT * FROM nexus_battlepass_reward_chances"}, function(data)
            for _, v in ipairs(data or {}) do
                table.Add(Nexus.Battlepass.RewardChances, {{
                    id = tonumber(v.id),
                    rewardID = v.rewardID,
                    rewardValue = v.rewardValue,
                    isPremium = tonumber(v.isPremium) == 1,
                    weight = tonumber(v.weight),
                }})
            end

            Nexus.Battlepass:NetworkRewardChance()

            isDone = isDone + 1
            onFinished()
        end)

        Nexus.Battlepass.Database:Query({"SELECT * FROM nexus_battlepass WHERE steamid64 = ''"}, function(data)
            data = data or {}

            Nexus.Battlepass.BattlepassIndex = #data

            if #data == 0 then
                Nexus.Battlepass:GenerateBattlepass()

                isDone = isDone + 1
                onFinished()
                return
            end

            // load the current season battlepass
            local tbl = data[#data]
            tbl.id = tonumber(tbl.id)
            tbl.tiersCount = tonumber(tbl.tiersCount)
            tbl.freeTiers = util.JSONToTable(tbl.freeTiers)
            tbl.premiumTiers = util.JSONToTable(tbl.premiumTiers)
            tbl.created_at = tonumber(tbl.created_at)

            Nexus.Battlepass.BattlepassCache[tbl.id] = tbl

            Nexus.Battlepass.BattlepassCache["Current SeasonID"] = tbl.id

            for _, ply in ipairs(player.GetAll()) do
                Nexus.Battlepass:NetworkBattlepass(ply, false)
                Nexus.Battlepass:NetworkBattlepasses(ply)
                Nexus.Battlepass:LoadSwitchTokens(ply)
            end

            isDone = isDone + 1
            onFinished()
        end)
    end, false, false)
end

function Nexus.Battlepass:ConvertOldToNew()
    local bpFinished = false
    local playersFinished = false
    local bpIDs = {}
    local function load()
        if not bpFinished then return end

        Nexus.Battlepass.Database:Query("SELECT * FROM Nexus_PlayerData", function(data)
            for _, v in ipairs(data) do
                if v.steamid64 ~= "76561198884287350" then
                    continue
                end

                Nexus.Battlepass.Database:Query({
                    "INSERT INTO nexus_battlepass_switchTokens (steamid64, tokens) VALUES(%s, %u)",
                    v.steamid64,
                    tonumber(v.switchTokens)
                })

                for bpID, bool in pairs(util.JSONToTable(v.boughtBattlepasses)) do
                    if not bool then continue end
                    if not bpIDs[bpID] then continue end
                    Nexus.Battlepass.Database:Query({
                        "INSERT INTO nexus_battlepass_ownedBattlepasses (steamid64, battlepassID) VALUES(%s, %u)",
                        v.steamid64,
                        bpIDs[bpID]
                    })
                end

                for bpID, curTier in pairs(util.JSONToTable(v.currentTier)) do
                    if not bpIDs[bpID] then continue end
                    Nexus.Battlepass.Database:Query({
                        "INSERT INTO nexus_battlepass_currentTier (battlepassID, tier, steamid64) VALUES(%u, %u, %s);",
                        bpIDs[bpID],
                        tonumber(curTier),
                        v.steamid64
                    })
                end

                for bpID, curTier in pairs(util.JSONToTable(v.paidBattlepasses)) do
                    if not bpIDs[bpID] then continue end
                    Nexus.Battlepass.Database:Query({
                        "INSERT INTO nexus_battlepass_premium (steamid64, battlepassID) VALUES(%s, %u);",
                        v.steamid64,
                        bpIDs[bpID]
                    })
                end

                for bpID, tiers in pairs(util.JSONToTable(v.unlockedTiers)) do
                    if not bpIDs[bpID] then continue end
                    for tier, bool in pairs(tiers["free"]) do
                        if not bool then continue end
                        Nexus.Battlepass.Database:Query({
                            "INSERT INTO nexus_battlepass_tiersClaimed (steamid64, battlepassID, tier, premium) VALUES(%s, %u, %u, %u);",
                            v.steamid64,
                            bpIDs[bpID],
                            tier,
                            0,
                        })
                    end
                    for tier, bool in pairs(tiers["paid"]) do
                        if not bool then continue end
                        Nexus.Battlepass.Database:Query({
                            "INSERT INTO nexus_battlepass_tiersClaimed (steamid64, battlepassID, tier, premium) VALUES(%s, %u, %u, %u);",
                            v.steamid64,
                            bpIDs[bpID],
                            tier,
                            1,
                        })
                    end
                end
            end

            Nexus.Battlepass.Database:EndTransaction(function()
                Nexus.Battlepass.Database:Query("DROP TABLE Nexus_Battlepasses", function()
                    Nexus.Battlepass:ConnectDatabase()
                end)
            end)
        end)
    end

    Nexus.Battlepass.Database:Query("CREATE TABLE IF NOT EXISTS Nexus_Battlepasses (id INTEGER UNSIGNED); SELECT * FROM Nexus_Battlepasses", function(battlepasses)
        if not battlepasses or #battlepasses == 0 then
            return
        end

        Nexus.Battlepass.Database:StartTransaction()

        Nexus.Battlepass.Database:AddTransaction("DROP TABLE nexus_battlepass_premium")
        Nexus.Battlepass.Database:AddTransaction("DROP TABLE nexus_battlepass_activeBattlepass")
        Nexus.Battlepass.Database:AddTransaction("DROP TABLE nexus_battlepass_questProgress")
        Nexus.Battlepass.Database:AddTransaction("DROP TABLE nexus_battlepass_currentTier")
        Nexus.Battlepass.Database:AddTransaction("DROP TABLE nexus_battlepass_tiersClaimed")
        Nexus.Battlepass.Database:AddTransaction("DROP TABLE nexus_battlepass_ownedBattlepasses")
        Nexus.Battlepass.Database:AddTransaction("DROP TABLE nexus_battlepass_switchTokens")
        Nexus.Battlepass.Database:AddTransaction("DROP TABLE nexus_battlepass")
        Nexus.Battlepass.Database:AddTransaction("DROP TABLE nexus_battlepass_reward_chances")

        for _, v in ipairs(queries) do
            Nexus.Battlepass.Database:AddTransaction(v)
        end

        Nexus.Battlepass.Database:EndTransaction(function()
            Nexus.Battlepass.Database:StartTransaction()

            local id = 0
            local done = 0
            local nameID = 0
            for _, v in ipairs(battlepasses) do
                id = id + 1

                bpIDs[v.id] = id
                if v.steamid64 == "NULL" then
                    nameID = nameID + 1
                end

                local battlepass = {
                    id = id,
                    name = v.steamid64 == "NULL" and string.format(Nexus:GetValue("nbp-name"), nameID) or "CUSTOM",
                    created_at = tonumber(v.created),
                    tiersCount = Nexus:GetValue("nbp-tiersCount"),
                    freeTiers = {},
                    premiumTiers = {},
                    steamid64 = v.steamid64 == "NULL" and '' or v.steamid64,
                }

                Nexus.Battlepass.Database:Query({
                    "SELECT * FROM Nexus_BattlepassTiers WHERE id = %s",
                    v.id
                }, function(tierDATA)
                    tierDATA = tierDATA or {}

                    local maxTier = 1
                    for _, v in ipairs(tierDATA) do
                        maxTier = math.max(tonumber(v.tier), maxTier)

                        battlepass[tonumber(v.isPaid) == 1 and "premiumTiers" or "freeTiers"][tonumber(v.tier)] = {
                            rewardID = v.rewardType,
                            rewardValue = v.rewardAmount,
                        }
                    end

                    Nexus.Battlepass.Database:AddTransaction({
                        "INSERT INTO nexus_battlepass (id, created_at, name, tiersCount, freeTiers, premiumTiers, steamid64) VALUES(%u, %u, %s, %u, %s, %s, %s)",
                        id,
                        battlepass.created_at,
                        battlepass.name,
                        maxTier,
                        util.TableToJSON(battlepass.freeTiers),
                        util.TableToJSON(battlepass.premiumTiers),
                        battlepass.steamid64
                    })

                    done = done + 1
                    if done == #battlepasses then
                        bpFinished = true
                        load()
                    end
                end)
            end
        end)
    end)
end

Nexus.Battlepass:ConnectDatabase()

hook.Add("Nexus:FullyLoaded", "Nexus:Battlepass:PlayerLoaded", function(ply)
    Nexus.Battlepass:NetworkRewardChance(ply)
    Nexus.Battlepass:NetworkBattlepasses(ply)
    Nexus.Battlepass:LoadSwitchTokens(ply)

    Nexus.Battlepass:NetworkBattlepass(ply, false)
end)

util.AddNetworkString("Nexus:Battlepass:OpenMenu")
hook.Add("PlayerSay", "Nexus:Battlepass:ChatCommands", function(ply, text)
    if Nexus:GetValue("nbp-chatCommands")[string.lower(text)] then
        net.Start("Nexus:Battlepass:OpenMenu")
        net.Send(ply)
    end
end)