net.Receive("DeepSquads:NotifyHealth", function()
    local sid = net.ReadString()
    local hp = net.ReadFloat()
    if not DeepSquads.MySquad.members or not DeepSquads.MySquad.members[sid] then return end
    DeepSquads.MySquad.members[sid].hp = hp
end)

net.Receive("DeepSquads:NotifySquad", function()
    local name = net.ReadString()
    local creator_sid = net.ReadString()
    local squad_members = net.ReadUInt(8)
    DeepSquads.MySquad.name = name
    DeepSquads.MySquad.sid = creator_sid -- We will deduce the creator by his steamid on HUD instead of using player.GetBySteamID
    DeepSquads.MySquad.members = {}
    for i = 1, squad_members do
        local new_member_sid = net.ReadString()
        local new_member = {}
        new_member.name = net.ReadString()
        new_member.hp = net.ReadFloat()
        new_member.plyref = Player(net.ReadUInt(8))
        new_member.vec = net.ReadVector()
        DeepSquads.MySquad.members[new_member_sid] = new_member
    end
end)

net.Receive("DeepSquads:NotifySquadless", function()
    DeepSquads.MySquad = {members = {}} -- Return MySquad to its original state
end)

net.Receive("DeepSquads:OpenMenu", function()
    DeepSquads.OpenMenu()
end)

net.Receive("DeepSquads:NotifyMessage", function()
    local spying = net.ReadBool()
    local color = color_white
    if spying then
        color = DeepSquads.Config.ListenColor
    end
    local name = net.ReadString()
    local message = net.ReadString()
    DeepSquads.SquadText(name .. ": " .. message, color)
end)

net.Receive("DeepSquads:StatusFail", function()
    DeepSquads.StatusText(net.ReadString(), DeepSquads.Failure)
end)

MsgC("[Deep Squads]", DeepSquads.Success, " Client networking initialized.\n") -- EOF