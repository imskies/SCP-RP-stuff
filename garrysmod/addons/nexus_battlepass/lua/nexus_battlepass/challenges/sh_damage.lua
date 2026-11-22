Nexus.Battlepass.Challenges["Damage:Dealt"] = {
    Category = function() return Nexus:GetPhrase("Damage Dealt", "nBattlepass") end,
    Format = function(amount, amountNeeded)
        return amount.." / "..amountNeeded
    end,
    Challenges = {
        // Amount: How many (total) is required to complete
        // Reward: How many tiers you get from completeing 
        {Amount = 100, Reward = 1},
        {Amount = 300, Reward = 1},
        {Amount = 600, Reward = 1},
        {Amount = 800, Reward = 2},
    },
}

if SERVER then
    hook.Add("EntityTakeDamage", "Nexus:Battlepass:Challenges:DamageDealt", function(target, dmginfo)
        if not IsValid(target) or not target:IsPlayer() then return end

        local attacker = dmginfo:GetAttacker()
        if not IsValid(attacker) or not attacker:IsPlayer() then return end
        local dmg = dmginfo:GetDamage()
        Nexus.Battlepass:AdvanceQuest(attacker, "Damage:Dealt", dmg)
    end)
end

Nexus.Battlepass.Challenges["Damage:Taken"] = {
    Category = function() return Nexus:GetPhrase("Damage Taken", "nBattlepass") end,
    Format = function(amount, amountNeeded)
        return amount.." / "..amountNeeded
    end,
    Challenges = {
        // Amount: How many (total) is required to complete
        // Reward: How many tiers you get from completeing 
        {Amount = 100, Reward = 1},
        {Amount = 300, Reward = 1},
        {Amount = 600, Reward = 1},
        {Amount = 800, Reward = 2},
    },
}

if SERVER then
    hook.Add("EntityTakeDamage", "Nexus:Battlepass:Challenges:DamageTaken", function(target, dmginfo)
        if not IsValid(target) or not target:IsPlayer() then return end

        local dmg = dmginfo:GetDamage()
        Nexus.Battlepass:AdvanceQuest(attacker, "Damage:Taken", dmg)
    end)
end
