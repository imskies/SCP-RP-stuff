local function load()
    if not Nexus then return end

    Nexus.Battlepass = Nexus.Battlepass or {}
    Nexus.Battlepass.Rewards = Nexus.Rewards or {}
    Nexus.Battlepass.Challenges = Nexus.Challenges or {}
    Nexus.Battlepass.RewardChances = Nexus.Battlepass.RewardChances or {}
    Nexus.Battlepass.BattlepassIndex = Nexus.Battlepass.BattlepassIndex or 0

    Nexus:LoadDirectory("nexus_battlepass", {
        "nexus_battlepass/functions/battlepasses/sv_battlepass.lua",
        "nexus_battlepass/functions/rewards/sv_rewards.lua",
        "nexus_battlepass/functions/generation/sv_generation.lua",
        "nexus_battlepass/functions/switch_tokens/sv_switch_tokens.lua",
    })
end
load()

hook.Add("Nexus:Loaded", "Nexus:Battlepass:Loaded", function()
    load()
end)