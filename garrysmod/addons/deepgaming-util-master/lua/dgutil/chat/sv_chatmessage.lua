--[[-----------
Chat Messages  |
---------------

Easily allows you to send chat messages to any player that are formatted nicely.

"sig" is your addon signature. It will show up before the message in [Brackets]

color is optional. It will set the color of the signature ONLY. Default blue.
]]

util.AddNetworkString("DGUtil:ChatMessage")

local defColor = Color(13,98,226)

function DGUtil:MessagePlayer(ply, sig, message, color)
    net.Start("DGUtil:ChatMessage")
        net.WriteString(sig)
        net.WriteString(message)
        net.WriteColor(color or defColor)
    net.Send(ply)
end