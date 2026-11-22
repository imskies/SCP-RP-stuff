Nexus.Battlepass.Challenges["Distance:Moved"] = {
    Category = function() return Nexus:GetPhrase("Distance Moved", "nBattlepass") end,
    Format = function(amount, amountNeeded)
        return amount.." / "..amountNeeded
    end,
    Challenges = {
        // Amount: How many (total) is required to complete
        // Reward: How many tiers you get from completeing 
        {Amount = 1000, Reward = 1},
        {Amount = 2000, Reward = 1},
        {Amount = 3000, Reward = 1},
        {Amount = 4000, Reward = 2},
    },
}

if SERVER then
    local cache = {}
    local unitToMeter = 0.01905
    timer.Create("Nexus:Battlepass:DistanceQuest", 5, 0, function()
        local newCache = {}
        for _, ply in ipairs(player.GetAll()) do
            local curPos = ply:GetPos()
            if not cache[ply] then cache[ply] = curPos end
            local distance = cache[ply]:Distance(curPos)
            distance = distance * unitToMeter

            newCache[ply] = ply:GetPos()

            if distance == 0 then continue end
            Nexus.Battlepass:AdvanceQuest(ply, "Distance:Moved", distance)
        end

        cache = newCache
    end)
end