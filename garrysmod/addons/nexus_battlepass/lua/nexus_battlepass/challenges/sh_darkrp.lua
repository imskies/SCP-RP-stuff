hook.Add("DarkRPFinishedLoading", "Nexus:Battlepass:DarkRPLoaded", function()
    Nexus.Battlepass.Challenges["DarkRP:BoughtAmmo"] = {
        Category = function() return "DarkRP: "..Nexus:GetPhrase("Ammo Bought", "nBattlepass") end,
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

    hook.Add("playerBoughtAmmo", "Nexus:Battlepass:Challenges:BoughtAmmo", function(ply)
        if CLIENT then return end
        Nexus.Battlepass:AdvanceQuest(ply, "DarkRP:BoughtAmmo", 1)
    end)

    Nexus.Battlepass.Challenges["DarkRP:BoughtEntity"] = {
        Category = function() return "DarkRP: "..Nexus:GetPhrase("Entity Bought", "nBattlepass") end,
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

    hook.Add("playerBoughtCustomEntity", "Nexus:Battlepass:Challenges:BoughtEntity", function(ply)
        if CLIENT then return end
        Nexus.Battlepass:AdvanceQuest(ply, "DarkRP:BoughtEntity", 1)
    end)

    Nexus.Battlepass.Challenges["DarkRP:BoughtDoor"] = {
        Category = function() return "DarkRP: "..Nexus:GetPhrase("Door Bought", "nBattlepass") end,
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

    hook.Add("playerBoughtDoor", "Nexus:Battlepass:Challenges:BoughtDoor", function(ply)
        if CLIENT then return end
        Nexus.Battlepass:AdvanceQuest(ply, "DarkRP:BoughtDoor", 1)
    end)

    Nexus.Battlepass.Challenges["DarkRP:BoughtFood"] = {
        Category = function() return "DarkRP: "..Nexus:GetPhrase("Food Bought", "nBattlepass") end,
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

    hook.Add("playerBoughtFood", "Nexus:Battlepass:Challenges:BoughtFood", function(ply)
        if CLIENT then return end
        Nexus.Battlepass:AdvanceQuest(ply, "DarkRP:BoughtFood", 1)
    end)

    Nexus.Battlepass.Challenges["DarkRP:BoughtPistol"] = {
        Category = function() return "DarkRP: "..Nexus:GetPhrase("Weapon Bought", "nBattlepass") end,
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

    hook.Add("playerBoughtPistol", "Nexus:Battlepass:Challenges:BoughtPistol", function(ply)
        if CLIENT then return end
        Nexus.Battlepass:AdvanceQuest(ply, "DarkRP:BoughtPistol", 1)
    end)

    Nexus.Battlepass.Challenges["DarkRP:BoughtShipment"] = {
        Category = function() return "DarkRP: "..Nexus:GetPhrase("Shipment Bought", "nBattlepass") end,
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

    hook.Add("playerBoughtShipment", "Nexus:Battlepass:Challenges:BoughtShipment", function(ply)
        if CLIENT then return end
        Nexus.Battlepass:AdvanceQuest(ply, "DarkRP:BoughtShipment", 1)
    end)

    Nexus.Battlepass.Challenges["DarkRP:Arrests"] = {
        Category = function() return "DarkRP: "..Nexus:GetPhrase("Arrests", "nBattlepass") end,
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

    hook.Add("playerArrested", "Nexus:Battlepass:Challenges:Arrests", function(criminal, time, actor)
        if CLIENT then return end
        if not IsValid(actor) or not actor:IsPlayer() then return end
        Nexus.Battlepass:AdvanceQuest(actor, "DarkRP:Arrests", 1)
    end)

    Nexus.Battlepass.Challenges["DarkRP:Jobs"] = {
        Category = function() return "DarkRP: "..Nexus:GetPhrase("Change Jobs", "nBattlepass") end,
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

    hook.Add("PlayerChangedTeam", "Nexus:Battlepass:Challenges:Jobs", function(ply)
        if CLIENT then return end
        if not IsValid(actor) or not actor:IsPlayer() then return end
        Nexus.Battlepass:AdvanceQuest(ply, "DarkRP:Jobs", 1)
    end)

    Nexus.Battlepass.Challenges["DarkRP:GiveMoney"] = {
        Category = function() return "DarkRP: "..Nexus:GetPhrase("Give Money", "nBattlepass") end,
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

    hook.Add("playerGaveMoney", "Nexus:Battlepass:Challenges:GiveMoney", function(ply, receiver, amount)
        if CLIENT then return end
        Nexus.Battlepass:AdvanceQuest(ply, "DarkRP:GiveMoney", amount)
    end)

    Nexus.Battlepass.Challenges["DarkRP:Lockpick"] = {
        Category = function() return "DarkRP: "..Nexus:GetPhrase("Lockpick Doors", "nBattlepass") end,
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

    hook.Add("onLockpickCompleted", "Nexus:Battlepass:Challenges:Lockpicks", function(ply)
        if CLIENT then return end
        Nexus.Battlepass:AdvanceQuest(ply, "DarkRP:Lockpick", 1)
    end)
end)