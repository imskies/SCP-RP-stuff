/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.Corpse = zbl.Corpse or {}

zbl.Corpse.List = zbl.Corpse.List or {}

// Adds a flask to the players internal list to keep track
function zbl.Corpse.Add(corpse)
    table.insert(zbl.Corpse.List,corpse)
end

function zbl.Corpse.Remove(corpse)
    table.RemoveByValue(zbl.Corpse.List,corpse)
end

function zbl.Corpse.Spawn(ply,vac_id,vac_stage)

    if not IsValid(ply) then return end

    local pos = ply:GetPos()
    local ang = ply:GetAngles()
    local model = ply:GetModel()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

    local tr = util.TraceLine( {
        start = pos + Vector(0,0,50),
        endpos = pos - Vector(0,0,10000),
        mask = 81931, // Hit only the world + brushes please
    } )

    if tr and tr.Hit and tr.HitPos then
        pos = tr.HitPos
        ang = tr.HitNormal:Angle()
        ang:RotateAroundAxis(ang:Right(),-90)
        ang:RotateAroundAxis(ang:Up(),math.random(0,360))
    end

    local ent = ents.Create("zbl_corpse")
    ent:Spawn()
    ent:SetPos(pos)
    ent:SetAngles(ang)
    ent:Activate()

    ent:SetModel(model)

    // Play death animation
    local death_anims = {"death_01","death_02","death_03","death_04"}
    local sequence = death_anims[math.random(#death_anims)]
    zclib.Animation.Play(ent,sequence, 1)

    // Play death idle animation delayed
    local seq_dur = ent:SequenceDuration(sequence)
    timer.Simple(seq_dur,function()
        if IsValid(ent) then
            sequence = zbl.config.Corpse.anim[math.random(#zbl.config.Corpse.anim)]
            zclib.Animation.Play(ent,sequence, 1)
        end
    end)

    // Apply virus material if defined
    if zbl.config.Corpse.infection_visible then
        ent:SetMaterial(zbl.Vaccine.GetMaterial(vac_id))
    end

    zbl.Corpse.Add(ent)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

    zbl.Vaccine.Set(ent, vac_id,vac_stage)

    ent:SetPlayerID(ply:AccountID())
    ent:SetPlayerName(ply:Nick())

    SafeRemoveEntityDelayed(ent,zbl.config.Corpse.life_time)

    return ent
end

function zbl.Corpse.SpawnAtPos(ply,pos,vac_id,vac_stage)

    if not IsValid(ply) then return end

    local ang = ply:GetAngles()
    local model = ply:GetModel()

    local tr = util.TraceLine( {
        start = pos + Vector(0,0,50),
        endpos = pos - Vector(0,0,10000),
        mask = 81931, // Hit only the world + brushes please
    } )


    if tr and tr.Hit and tr.HitPos then

        //debugoverlay.Line(pos + Vector(0,0,50), tr.HitPos, 5, Color(0, 255, 0), false)

        pos = tr.HitPos
        ang = tr.HitNormal:Angle()
        ang:RotateAroundAxis(ang:Right(),-90)

        ang:RotateAroundAxis(ang:Up(),math.random(0,360))
    end

    local ent = ents.Create("zbl_corpse")
    ent:Spawn()
    ent:SetPos(pos)
    ent:SetAngles(ang)
    ent:Activate()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

    ent:SetModel(model)

    // Play death animation
    local death_anims = {"death_01","death_02","death_03","death_04"}
    local sequence = death_anims[math.random(#death_anims)]
    zclib.Animation.Play(ent,sequence, 1)

    // Play death idle animation delayed
    local seq_dur = ent:SequenceDuration(sequence)
    timer.Simple(seq_dur,function()
        if IsValid(ent) then
            sequence = zbl.config.Corpse.anim[math.random(#zbl.config.Corpse.anim)]
            zclib.Animation.Play(ent,sequence, 1)
        end
    end)

    // Apply virus material if defined
    if zbl.config.Corpse.infection_visible then
        ent:SetMaterial(zbl.Vaccine.GetMaterial(vac_id))
    end

    zbl.Corpse.Add(ent)

    zbl.Vaccine.Set(ent, vac_id,vac_stage)

    ent:SetPlayerID(ply:AccountID())
    ent:SetPlayerName(ply:Nick())

    SafeRemoveEntityDelayed(ent,zbl.config.Corpse.life_time)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

    return ent
end

function zbl.Corpse.OnRemove(corpse)
    if zbl.config.Corpse.ExplodeOnDespawn and CurTime() >= ((corpse:GetCreationTime() + zbl.config.Corpse.life_time) - 1) then

        local virus_id = zbl.Vaccine.Get(corpse)
        local vData = {
            vaccine_id = virus_id,
            vaccine_stage = zbl.Vaccine.GetStage(corpse),
            inflictor = corpse,
            infect_type = "corpse_explosion"
        }

		hook.Run("zbl_OnCorpseExplosion",corpse,virus_id)

        zbl.Infect.Proximity(corpse:GetPos(), 200, 35,vData)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

        zbl.Contamination.ProximityContaminate(corpse:GetPos(), 200, virus_id)
    end

    zbl.Corpse.Remove(corpse)
end
