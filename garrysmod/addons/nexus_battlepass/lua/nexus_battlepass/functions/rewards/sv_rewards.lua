function Nexus.Battlepass:NetworkRewardChance(ply, data)
    data = data or Nexus.Battlepass.RewardChances

    net.Start("Nexus:Battlepass:RewardChances:SaveReward")
    Nexus:WriteUInt(#data)
    for _, v in ipairs(data) do
        Nexus:WriteUInt(v.id)
        net.WriteString(v.rewardID)
        net.WriteString(v.rewardValue)
        net.WriteBool(v.isPremium)
        net.WriteFloat(v.weight)
    end

    if ply and IsValid(ply) then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

util.AddNetworkString("Nexus:Battlepass:RewardChances:SaveReward")
net.Receive("Nexus:Battlepass:RewardChances:SaveReward", function(len, ply)
    if not Nexus.Battlepass:IsSuperadmin(ply) then
        Nexus:Notify(ply, 1, 3, "Incorrect Usergroup", "nBattlepass")
        return
    end

    local isSave = net.ReadBool()
    if isSave then
        local id = Nexus:ReadUInt()
        local rewardID = net.ReadString()
        local rewardValue = net.ReadString()
        local isPremium = net.ReadBool()
        local weight = net.ReadFloat()

        local tbl = {
            id = id,
            rewardID = rewardID,
            rewardValue = rewardValue,
            isPremium = isPremium,
            weight = weight,
        }

        for index, v in ipairs(Nexus.Battlepass.RewardChances) do
            if v.id == id then
                Nexus.Battlepass.RewardChances[index] = tbl
                break
            end
        end

        Nexus.Battlepass.Database:Query({
            [[
                UPDATE nexus_battlepass_reward_chances
                SET rewardID = %s, rewardValue = %s, isPremium = %u, weight = %u
                WHERE id = %u
            ]], 
            rewardID,
            rewardValue,
            isPremium and 1 or 0,
            weight,
            id
        }, function(_, insertID) end)

        Nexus.Battlepass:NetworkRewardChance(false, {tbl})

        return
    end

    local rewardID = net.ReadString()
    local rewardValue = net.ReadString()
    local isPremium = net.ReadBool()

    Nexus.Battlepass.Database:Query({
        [[
            INSERT INTO nexus_battlepass_reward_chances
            (rewardID, rewardValue, isPremium, weight)
            VALUES(%s, %s, %u, %u)
        ]], 
        rewardID,
        rewardValue,
        isPremium and 1 or 0,
        100
    }, function(_, insertID)
        table.Add(Nexus.Battlepass.RewardChances, {{
            id = insertID,
            rewardID = rewardID,
            rewardValue = rewardValue,
            isPremium = isPremium,
            weight = 100,
        }})

        Nexus.Battlepass:NetworkRewardChance(false, {Nexus.Battlepass.RewardChances[#Nexus.Battlepass.RewardChances]})
    end)

    Nexus:Notify(ply, 0, 3, "Success", "nBattlepass")
end)

util.AddNetworkString("Nexus:Battlepass:RewardChances:DeleteReward")
net.Receive("Nexus:Battlepass:RewardChances:DeleteReward", function(len, ply)
    if not Nexus.Battlepass:IsSuperadmin(ply) then
        Nexus:Notify(ply, 1, 3, "Incorrect Usergroup", "nBattlepass")
        return
    end

    local id = Nexus:ReadUInt()

    for index, v in ipairs(Nexus.Battlepass.RewardChances) do
        if v.id == id then
            table.remove(Nexus.Battlepass.RewardChances, index)
            break
        end
    end

    Nexus.Battlepass.Database:Query("DELETE FROM nexus_battlepass_reward_chances WHERE id = "..id..";")
    net.Start("Nexus:Battlepass:RewardChances:DeleteReward")
    Nexus:WriteUInt(id)
    net.Broadcast()
end)