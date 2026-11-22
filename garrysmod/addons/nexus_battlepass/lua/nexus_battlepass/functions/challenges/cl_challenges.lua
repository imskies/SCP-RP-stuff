function Nexus.Battlepass:GetChallengeProgress(id)
    if not Nexus.Battlepass.ThisSeason.challenges then return 0 end
    return Nexus.Battlepass.ThisSeason.challenges[id] or 0
end

net.Receive("Nexus:Battlepass:NetworkQuestProgress", function()
    local questID = net.ReadString()
    local progress = Nexus:ReadUInt()

    if not Nexus.Battlepass.ThisSeason then return end
    Nexus.Battlepass.ThisSeason.challenges = Nexus.Battlepass.ThisSeason.challenges or {}
    Nexus.Battlepass.ThisSeason.challenges[questID] = progress
end)