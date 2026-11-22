DeepSquads.CachedPlayers = DeepSquads.CachedPlayers or {} -- DeepSquads.CachedPlayers[ply] = STEAMID_CREATOR
DeepSquads.SquadlessPlayers = DeepSquads.SquadlessPlayers or {} -- DeepSquads.SquadlessPlayers[ply] = true

gameevent.Listen( "player_connect" )
hook.Add("player_connect", "DeepSquads:Connect", function( data )
    if data.bot == 1 then return end
    DeepSquads.SquadlessPlayers[Player(data.userid)] = true
end)

hook.Add("PlayerDisconnected", "DeepSquads:Disconnect", function(ply)
    if DeepSquads.CachedPlayers[ply] and DeepSquads.Squads[DeepSquads.CachedPlayers[ply]] then
        local squad = DeepSquads.Squads[DeepSquads.CachedPlayers[ply]]
        timer.Simple(0, function()
            DeepSquads.UpdateSquad(squad)
        end)
    end
    DeepSquads.CachedPlayers[ply] = nil
    DeepSquads.SquadlessPlayers[ply] = nil
end)

local meta = FindMetaTable("Entity")
meta.oldSetHealth = meta.oldSetHealth or meta.SetHealth
function meta:SetHealth(newHealth)
    local oldHealth = self:Health()
    self:oldSetHealth(newHealth)
    hook.Run("OnHealthChanged", self, oldHealth, newHealth)
end

hook.Add("PlayerLoadout", "DeepSquads:Spawned", function(ply)
    DeepSquads.UpdateHP(ply)
end)

hook.Add("OnHealthChanged", "DeepSquads:Healing", function(ent, old_hp, new_hp)
    if not ent:IsPlayer() then return end
    if old_hp == new_hp then return end
    DeepSquads.UpdateHP(ent)
end)

hook.Add("PostEntityTakeDamage", "DeepSquads:Damage", function(ent, dmg, took)
    if not took then return end
    if not ent:IsPlayer() then return end
    if dmg:GetDamage() <= 0 then return end
    DeepSquads.UpdateHP(ent)
end)

hook.Add("PlayerSay", "DeepSquads:MenuCommand", function(sender, text, teamChat)
    print("DeepSquads:MenuCommand", text)
    if not string.StartWith(text, "/squads") then return end
    net.Start("DeepSquads:OpenMenu")
    net.Send(sender)
    return ""
end)

hook.Add("PlayerSay", "DeepSquads:ChatCommand", function(sender, text, teamChat)
    if string.StartWith(text, "/squads") then return end -- Don't want to interfere with the Menu command
    if not string.StartWith(text, "/squad") then return end
    if DeepSquads.SquadlessPlayers[sender] then
        net.Start("DeepSquads:NoSquad")
        net.Send(sender)
        return ""
    end
    DeepSquads.SquadChat(sender, text)
    return ""
end)

timer.Create("DeepSquads:GeneralPing", 3, 0, function()
    DeepSquads.UpdateAllSquads()
end)

timer.Create("DeepSquads:CleanUp", 10, 0, function()
    for ply,status in pairs(DeepSquads.SquadlessPlayers) do
        if not ply or not IsValid(ply) then
            DeepSquads.SquadlessPlayers[ply] = nil
            continue
        end
        DeepSquads.CachedPlayers[ply] = nil
        net.Start("DeepSquads:NotifySquadless")
        net.Send(ply)
    end
    for ply,status in pairs(DeepSquads.CachedPlayers) do
        if not ply or not IsValid(ply) then
            DeepSquads.CachedPlayers[ply] = nil
            continue
        end
        DeepSquads.SquadlessPlayers[ply] = nil
    end
end)

MsgC("[Deep Squads]", DeepSquads.Success, " Server functionality initialized.\n") -- EOF
