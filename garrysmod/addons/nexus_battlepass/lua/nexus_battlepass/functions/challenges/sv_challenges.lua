util.AddNetworkString("Nexus:Battlepass:NetworkQuestProgress")
function Nexus.Battlepass:AdvanceQuest(ply, questID, progressInt)
    if not IsValid(ply) then return end
    if not ply.NBPCurrentBattlepass then return end
    if not Nexus.Battlepass.Challenges[questID] then return end

    local exists = ply.NBPCurrentBattlepass.challenges[questID]
    local oldProgress = exists or 0
    local max = Nexus.Battlepass.Challenges[questID].Challenges[#Nexus.Battlepass.Challenges[questID].Challenges].Amount
    if exists and exists >= max then return end

    local newProgress = exists and exists + progressInt or progressInt
    newProgress = math.min(newProgress, max)

    for _, v in ipairs(Nexus.Battlepass.Challenges[questID].Challenges) do
        if v.Amount <= oldProgress then continue end
        if v.Amount > newProgress then continue end
        Nexus.Battlepass:GiveTiers(ply:SteamID64(), v.Reward)
        Nexus:ChatMessage(ply, {Nexus:GetColor("red"), "[ Battlepass ] ", color_white, string.format(Nexus:GetPhrase("Challenge Complete", "nBattlepass", ply), v.Reward)})
    end

    if newProgress == exists then return end

    Nexus.Battlepass.Database:Query({
        "REPLACE INTO nexus_battlepass_questProgress (steamid64, battlepassID, questID, progress) VALUES (%s, %u, %s, %u);",
        ply:SteamID64(),
        ply.NBPCurrentBattlepass.battlepassID,
        questID,
        newProgress
    })

    ply.NBPCurrentBattlepass.challenges[questID] = newProgress

    net.Start("Nexus:Battlepass:NetworkQuestProgress")
        net.WriteString(questID)
        Nexus:WriteUInt(newProgress)
    net.Send(ply)
end