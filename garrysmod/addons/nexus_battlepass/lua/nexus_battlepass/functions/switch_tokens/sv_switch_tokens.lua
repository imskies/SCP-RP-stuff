function Nexus.Battlepass:LoadSwitchTokens(ply)
    Nexus.Battlepass.Database:Query({
        "SELECT * FROM nexus_battlepass_switchTokens WHERE steamid64 = %s;",
        ply:SteamID64()
    }, function(data)
        if not IsValid(ply) then return end
        if data then
            local tokens = tonumber(data[1] and data[1].tokens or 0) or 0
            ply.NexusBattlepassSwitchTokens = tokens
        else
            Nexus.Battlepass.Database:Query({
                "INSERT INTO nexus_battlepass_switchTokens (steamid64, tokens) VALUES(%s, %u);",
                ply:SteamID64(),
                0
            })

            ply.NexusBattlepassSwitchTokens = 0
        end

        Nexus.Battlepass:NetworkSwitchTokens(ply)
    end)
end

util.AddNetworkString("Nexus:Battlepass:SwitchTokens")
function Nexus.Battlepass:NetworkSwitchTokens(ply)
    net.Start("Nexus:Battlepass:SwitchTokens")
        Nexus:WriteUInt(Nexus.Battlepass:GetSwitchTokens(ply))
    net.Send(ply)
end

function Nexus.Battlepass:AddSwitchTokens(steamid64, amount)
    Nexus.Battlepass.Database:Query({
        "UPDATE nexus_battlepass_switchTokens SET tokens = tokens + %i WHERE steamid64 = %s;",
        amount,
        steamid64
    })

    local ply = player.GetBySteamID64(steamid64)
    if not IsValid(ply) then return end
    ply.NexusBattlepassSwitchTokens = Nexus.Battlepass:GetSwitchTokens(ply) + amount

    Nexus.Battlepass:NetworkSwitchTokens(ply)
end

function Nexus.Battlepass:GetSwitchTokens(ply)
    return ply.NexusBattlepassSwitchTokens or 0
end