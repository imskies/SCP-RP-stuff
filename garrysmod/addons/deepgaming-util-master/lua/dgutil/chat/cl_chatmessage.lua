--[[-----------
Chat Messages  |
---------------

Easily allows you to send chat messages to any player that are formatted nicely.
]]

net.Receive("DGUtil:ChatMessage", function()
    local sig = net.ReadString()
    local msg = net.ReadString()
    local color = net.ReadColor()

    chat.AddText(color_white, "[", color, sig, color_white, "] ", msg)
end )