Nexus.Battlepass.ThisSeason = Nexus.Battlepass.ThisSeason or {}
Nexus.Battlepass.Battlepasses = Nexus.Battlepass.Battlepasses or {}
net.Receive("Nexus:Battlepass:NetworkBattlepass", function()
    local isPremium = net.ReadBool()
    local currentSeasonID = Nexus:ReadUInt()
    local int = Nexus:ReadUInt()
    local data = net.ReadData(int)
    local curTier = Nexus:ReadUInt()

    local quests = {}
    local questsCount = Nexus:ReadUInt()
    for i = 1, questsCount do
        local questID = net.ReadString()
        local progress = Nexus:ReadUInt()
        quests[questID] = progress
    end

    local formattedClaimed = {}
    local claimedCount = Nexus:ReadUInt()
    for i = 1, claimedCount do
        local tier = Nexus:ReadUInt()
        local isPremium = net.ReadBool()
        formattedClaimed[(isPremium and "1" or "0")..tier] = true
    end

    data = util.Decompress(data)
    data = util.JSONToTable(data)

    if Nexus.Battlepass.ThisSeason.curSeason ~= data.curSeason then
        for _, v in ipairs(Nexus.Battlepass.Battlepasses) do
            if v.id == Nexus.Battlepass.ThisSeason.curSeason then
                v.hasUnlocked = false
                break
            end
        end
    end

    Nexus.Battlepass.ThisSeason = data
    Nexus.Battlepass.ThisSeason.curSeason = currentSeasonID
    Nexus.Battlepass.ThisSeason.curTier = curTier
    Nexus.Battlepass.ThisSeason.challenges = quests
    Nexus.Battlepass.ThisSeason.hasPremium = isPremium
    Nexus.Battlepass.ThisSeason.rewardsClaimed = formattedClaimed

    local hasFound = false
    for _, v in ipairs(Nexus.Battlepass.Battlepasses) do
        if v.id == data.id then
            hasFound = true
            v.hasUnlocked = true
            break
        end
    end

    if not hasFound then
        table.Add(Nexus.Battlepass.Battlepasses, {{id = data.id, name = data.name, hasUnlocked = true}})
    end

    if IsValid(Nexus.Battlepass.Frame) then Nexus.Battlepass:OpenMenu() end
end)

net.Receive("Nexus:Battlepass:NetworkBattlepasses", function()
    local count = Nexus:ReadUInt()
    local tbl = {}
    for i = 1, count do
        local id = Nexus:ReadUInt()
        local name = net.ReadString()
        local hasUnlocked = net.ReadBool()
        table.Add(tbl, {{id = id, name = name, hasUnlocked = hasUnlocked}})
    end

    Nexus.Battlepass.Battlepasses = tbl

    if IsValid(Nexus.Battlepass.Frame) then Nexus.Battlepass:OpenMenu() end
end)

net.Receive("Nexus:Battlepass:TiersGiven", function()
    local amount = Nexus:ReadUInt()
    Nexus.Battlepass.ThisSeason.curTier = Nexus.Battlepass.ThisSeason.curTier + amount
end)

net.Receive("Nexus:Battlepass:PremiumGiven", function()
    Nexus.Battlepass.ThisSeason.hasPremium = true
end)

net.Receive("Nexus:Battlepass:ClaimTier", function()
    local tier = Nexus:ReadUInt()
    local isPremium = net.ReadBool()

    Nexus.Battlepass.ThisSeason.rewardsClaimed[(isPremium and "1" or "0")..tier] = true
end)