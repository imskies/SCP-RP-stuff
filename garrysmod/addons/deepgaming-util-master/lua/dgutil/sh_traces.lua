--[[----------------
Trace Abstractions |
--------------------

Trace functions that cut down on the amount of code you 
need to copy and paste by filling in the details you 
don't need for you.
]]

DGUtil.Trace = {}

function DGUtil.Trace:Weapon(owner, endposAdd)
    if not IsValid(owner) then return end
    endposAdd = endposAdd or owner:GetAimVector() * 75

    if owner:IsPlayer() then
        owner:LagCompensation(true)
    end

    local tr = util.TraceHull( {
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + endposAdd,
        filter = owner,
        mins = Vector(-10, -10, -10),
        maxs = Vector(10, 10, 10),
        mask = MASK_SHOT_HULL
    } )

    if owner:IsPlayer() then
        owner:LagCompensation(false)
    end

    return tr
end