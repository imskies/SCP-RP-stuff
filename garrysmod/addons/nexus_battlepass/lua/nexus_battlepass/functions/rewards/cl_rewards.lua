net.Receive("Nexus:Battlepass:RewardChances:SaveReward", function()
    local count = Nexus:ReadUInt()
    for i = 1, count do
        local tbl = {
            id = Nexus:ReadUInt(),
            rewardID = net.ReadString(),
            rewardValue = net.ReadString(),
            isPremium = net.ReadBool(),
            weight = net.ReadFloat(),
        }

        for index, v in ipairs(Nexus.Battlepass.RewardChances) do
            if v.id == tbl.id then
                Nexus.Battlepass.RewardChances[index].rewardID = tbl.rewardID
                Nexus.Battlepass.RewardChances[index].rewardValue = tbl.rewardValue
                Nexus.Battlepass.RewardChances[index].weight = tbl.weight
                return
            end
        end

        table.Add(Nexus.Battlepass.RewardChances, {tbl})
        hook.Run("Nexus:Battlepass:RewardChances:AddReward", tbl)
    end
end)

net.Receive("Nexus:Battlepass:RewardChances:DeleteReward", function(len, ply)
    local id = Nexus:ReadUInt()

    for index, v in ipairs(Nexus.Battlepass.RewardChances) do
        if v.id == id then
            table.remove(Nexus.Battlepass.RewardChances, index)
            break
        end
    end

    hook.Run("Nexus:Battlepass:RewardChances:DeleteReward", id)
end)