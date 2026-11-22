Nexus.Battlepass.Challenges["Props:Placed"] = {
    Category = function() return Nexus:GetPhrase("Props Placed", "nBattlepass") end,
    Format = function(amount, amountNeeded)
        return amount.." / "..amountNeeded
    end,
    Challenges = {
        // Amount: How many (total) is required to complete
        // Reward: How many tiers you get from completeing 
        {Amount = 1, Reward = 1},
        {Amount = 3, Reward = 1},
        {Amount = 6, Reward = 1},
        {Amount = 8, Reward = 2},
    },
}

if SERVER then
    hook.Add("PlayerSpawnProp", "Nexus:Battlepass:Challenges:PlacedProps", function(ply)
        Nexus.Battlepass:AdvanceQuest(ply, "Props:Placed", 1)
    end)
end