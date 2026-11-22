--[[-----------
SCP Detection |
---------------

Redesigned from Pabz' implementation.

For use in SWEPs/Addons where detection of whether someone is an SCP or not is necessary.

Not transmitted to the client.
]]

local nextPlyThink = {}

hook.Add("PlayerPostThink", "DGUtil:SCPNum", function(ply)
    local thinkTime = nextPlyThink[ply:UserID()] or 0

    if thinkTime > CurTime() then return end

    nextPlyThink[ply:UserID()] = CurTime() + 5 -- 5 second refresh, necessary for SWEP-based detection e.g. 049-2

    if !ply:Alive() or !IsValid(ply:GetActiveWeapon()) then return end

    if RPExtraTeams[ply:Team()].category == "SCPs" or string.find(ply:GetActiveWeapon():GetPrintName(), "SCP") then
        ply.SCPNum = true
    else
        ply.SCPNum = false
    end
end)