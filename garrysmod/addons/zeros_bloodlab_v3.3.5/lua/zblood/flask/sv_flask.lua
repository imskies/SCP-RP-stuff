/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.Flask = zbl.Flask or {}

// Tells us if we can drop another flask
function zbl.Flask.DropLimitReached(ply,SupressNotify)
    if ply.zbl_FlaskList == nil then
        ply.zbl_FlaskList = {}
    end

    local capacity = zbl.config.InjectorGun.flask_capacity[zclib.Player.GetRank(ply)]
    if capacity == nil then
        capacity = zbl.config.InjectorGun.flask_capacity["default"]
    end

    if #ply.zbl_FlaskList >= capacity then

        if SupressNotify == nil then
            local str = string.Replace(zbl.language.Gun["FlaskDropLimit"],"$FlaskCount",capacity)
            zclib.Notify(ply, str, 1)
        end

        return true
    else
        return false
    end
end

// Adds a flask to the players internal list to keep track
function zbl.Flask.Add(ply,flask)
    if ply.zbl_FlaskList == nil then
        ply.zbl_FlaskList = {}
    end

    table.insert(ply.zbl_FlaskList,flask)
end

function zbl.Flask.Remove(flask)
    if IsValid(flask.FlaskOwner) and flask.FlaskOwner.zbl_FlaskList then
        // Remove yourself from the flasklist of the owner so he can spawn more flask again
        table.RemoveByValue(flask.FlaskOwner.zbl_FlaskList,flask)
    end
end

function zbl.Flask.Spawn(_owner,_pos,_gentype,_genval,_genname,_genpoints,_genclass)
    local ent = ents.Create("zbl_flask")
    ent:SetPos(_pos)
    ent:Spawn()
    ent:Activate()

    ent:SetGenType(_gentype)
    ent:SetGenValue(_genval)
    ent:SetGenName(_genname)
    ent:SetGenPoints(_genpoints)
    ent:SetGenClass(_genclass)

    if IsValid(_owner) then
        zclib.Player.SetOwner(ent, _owner)

        ent.FlaskOwner = _owner
    end

    return ent
end


function zbl.Flask.Initialize(flask)
    zclib.EntityTracker.Add(flask)
    flask.zbl_Collided = false

    timer.Simple(0,function()
        if IsValid(flask) then
            zbl.Flask.UpdateVisuals(flask)
        end
    end)
end

function zbl.Flask.UpdateVisuals(flask)
    local _gentype = flask:GetGenType()
    local _genval = flask:GetGenValue()
    local _genclass = flask:GetGenClass()

    if _gentype ~= 0 then
        flask:SetBodygroup(0,1)
    end

    if _gentype == 1 then
        // Check if sample is from player and color the liquid red
        if _genclass and _genclass == "player" then
            flask:SetSubMaterial(0, "zerochain/props_bloodlab/flask/zbl_flask_liquid_bloodsample")
        end
    elseif _gentype == 2 then
        if zbl.Vaccine.IsVirus(_genval) then
            flask:SetSubMaterial(0, zbl.Vaccine.GetMaterial(_genval))
        else
            flask:SetSubMaterial(0, "zerochain/props_bloodlab/flask/zbl_flask_liquid_abillity_diff")
        end
    elseif _gentype == 3 then
        flask:SetSubMaterial(0, "zerochain/props_bloodlab/flask/zbl_flask_liquid_cure_diff")
    end
end

function zbl.Flask.OnPhysicsCollide(flask,data)
    if zbl.config.Flask.Breakable == false then return end

    if IsValid(data.HitEntity) and data.HitEntity:GetClass() == "zbl_lab" then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

    if (data.Speed > zbl.config.Flask.Break_speed) then
        zbl.Flask.Explode(flask)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

function zbl.Flask.OnDamage(flask,dmginfo)
    if zbl.config.Flask.Breakable == false then return end
    if dmginfo:GetDamage() >= 5 then
        zbl.Flask.Explode(flask)
    end
end

function zbl.Flask.Explode(flask)
    zclib.Debug("zbl.Flask.Explode")

    if flask.zbl_Collided == true then return end

    local gen_type = flask:GetGenType()
    local gen_val = flask:GetGenValue()

    local pos = flask:GetPos()
    local ang = flask:GetAngles()
    if gen_type == 1 then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

        // Check if sample is from player or not
        if flask:GetGenClass() == "player" then
            zclib.NetEvent.Create("zbl_jar_break_blood", {pos})
        else
            zclib.NetEvent.Create("zbl_jar_break_sample", {pos})
        end
    elseif gen_type == 2 then
        if zbl.Vaccine.IsVirus(gen_val) then

			// Contaminate your surounding
			zbl.Contamination.ProximityContaminate(pos, 75, gen_val)

            if zbl.config.Flask.InfectOnDestruction then

                local inflictor = zclib.Player.GetOwner(flask)

                if inflictor == false then
                    inflictor = flask
                end

                local vData = {
                    vaccine_id = gen_val,
                    vaccine_stage = 1,
                    inflictor = inflictor,
                    infect_type = "flask_explosion"
                }

                zbl.Infect.Proximity(pos, zbl.config.Flask.Infect_Radius, 75,vData)
            end

            // Creates a virus node somewhere near it
            if zbl.config.Flask.NodeOnDestruction then
                timer.Simple(0,function()
                    if pos and ang and gen_val then
                        zbl.Node.CreateNodeRandom(pos, Angle(0,0,0), gen_val, 1)
                    end
                end)
            end

            zclib.NetEvent.Create("zbl_jar_break_virus", {pos})
        else

            if zbl.config.Flask.InfectOnDestruction then

                local inflictor = zclib.Player.GetOwner(flask)

                if inflictor == false then
                    inflictor = flask
                end

                local vData = {
                    vaccine_id = gen_val,
                    vaccine_stage = 1,
                    inflictor = inflictor,
                    infect_type = "flask_explosion"
                }

                zbl.Infect.Proximity(pos, zbl.config.Flask.Infect_Radius, 99,vData)
            end

            zclib.NetEvent.Create("zbl_jar_break_abillity", {pos})
        end
    elseif gen_type == 3 then

        if zbl.config.Flask.InfectOnDestruction then
            zbl.Player.CureProximity(gen_val, pos, zbl.config.Flask.Infect_Radius)
        end

        zclib.NetEvent.Create("zbl_jar_break_cure", {pos})

        // Kill any virus nodes in proximity of flask explosion which have the same vaccine id
        // This wont create any infection cloud on death
        local flask_owner = zclib.Player.GetOwner(flask)
        for k,v in pairs(zbl.Node.List) do
            if IsValid(v) and v.Virus_ID == gen_val and zclib.util.InDistance(v:GetPos(), pos, zbl.config.Flask.Infect_Radius) then
                zbl.Node.ChangeHealth(v,0,flask_owner)
            end
        end
    end

    local deltime = FrameTime() * 2
    if not game.SinglePlayer() then deltime = FrameTime() * 6 end
    SafeRemoveEntityDelayed(flask,deltime)

    flask.zbl_Collided = true
end

function zbl.Flask.OnRemove(flask)
    zbl.Flask.Remove(flask)
end
