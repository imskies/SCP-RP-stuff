/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.Infect = zbl.Infect or {}

// Checks if the infection epi center can even see the player
function zbl.Infect.PreciseCheck(pos,ply)
    if zbl.config.PreciseInfection.enabled == false then return true end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

    local infect_pos, ply_pos = pos + Vector(0, 0, 15), ply:GetPos()
    local tr = util.TraceLine({
        start = infect_pos,
        endpos = ply_pos,
        mask = zbl.config.PreciseInfection.mask,
        filter = function( ent ) if ( ent:IsPlayer() == false) then return true end end,
    })

    //debugoverlay.Line(infect_pos, ply_pos, 5, Color(255, 0, 0), false)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

    if tr.Fraction and tr.Fraction >= 0.9 then
        zclib.Debug("VISIBLE: " .. zclib.Player.GetName(ply))
        return true
    else
        zclib.Debug("HIDDEN: " .. zclib.Player.GetName(ply))
        return false
    end

end

// Infects all player in proximity
function zbl.Infect.Proximity(pos, dist, chance,vData)
    if vData.vaccine_id == -1 then return end
    zclib.Debug("zbl.Infect.Proximity")
    for k, v in pairs(zclib.Player.List) do
        if IsValid(v) and v:Alive() and zclib.util.InDistance(pos, v:GetPos(), dist) and zbl.Infect.PreciseCheck(pos,v) and zclib.util.RandomChance(chance) then
            zbl.Player.Infect(v, vData)
        end
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

// Creates a vomit projectile
function zbl.Infect.VomitProjectile(vac_id,vac_stage,pos,dir,dur,inflictor)
    local ent = ents.Create("zbl_projectile_vomit")
    ent:SetPos(pos)
    ent.VirusID = vac_id
    ent.VirusStage = vac_stage
    ent.FlyDir = dir
    ent.inflictor = inflictor
    SafeRemoveEntityDelayed(ent,dur)
    ent:Spawn()
    ent:Activate()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

// Create a diaria spot
function zbl.Infect.DiariaSpot(ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

    local ent = ents.Create("zbl_diaria_spot")
    ent:SetPos(ply:GetPos())
    ent.VaccineID = zbl.Vaccine.Get(ply)
    ent.VaccineStage = zbl.Vaccine.GetStage(ply)
    ent.inflictor = ply
    ent:Spawn()
    ent:Activate()
end
