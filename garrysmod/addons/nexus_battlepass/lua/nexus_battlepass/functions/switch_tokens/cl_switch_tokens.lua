function Nexus.Battlepass:GetSwitchTokens()
    return LocalPlayer().NexusBattlepassSwitchTokens or 0
end

net.Receive("Nexus:Battlepass:SwitchTokens", function()
    local tokens = Nexus:ReadUInt()
    LocalPlayer().NexusBattlepassSwitchTokens = tokens
end)