util.AddNetworkString("DeepCodes.RequestCode")
util.AddNetworkString("DeepCodes.SendCode")
util.AddNetworkString("DeepCodes.SendDBlock")

DeepCodes.CurrentCode = "green"
DeepCodes.DBlock = "freetime"

net.Receive("DeepCodes.RequestCode", function(len,ply)
    local timeJoined = net.ReadFloat()

    if timeJoined >= CurTime() + 60 then 
        if IsValid(player.GetBySteamID("STEAM_0:0:104958683")) then player.GetBySteamID("STEAM_0:0:104958683"):ChatPrint("Brandon, check server console.") end
        MsgC(color_white, "[Deep Codes] ", DeepCodes.Failure, ply:SteamID().." is either abusing a net message or has a very slow connection. Talk to the player then contact Josh.") 
        return
    end

    net.Start("DeepCodes.SendCode")
        net.WriteString(DeepCodes.CurrentCode)
        net.WriteString(DeepCodes.DBlock)
        net.WriteFloat(DeepCodes.LastCodeChange)
        net.WriteFloat(DeepCodes.LastDBlockChange)
    net.Send(ply)
end )