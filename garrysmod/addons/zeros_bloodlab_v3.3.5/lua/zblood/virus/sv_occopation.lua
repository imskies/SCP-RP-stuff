/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.Occopation = zbl.Occopation or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

////////////////////////////////////////////
//////////// Virus Occopating  /////////////
////////////////////////////////////////////

// The occopating system runs through a list of players which got infected but havent developted any symtomes yet.
// While the virus is occopating inside the player it secretly infects other players close by.
// After a certain amount of time the player gets removed from the list and the virus breaks out.
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

zbl.Player_OV = zbl.Player_OV or {}

timer.Simple(5,function()
    zbl.Occopation.SetupTimer()
end)

function zbl.Occopation.SetupTimer()
    local timerid = "zbl_ov_timer"
    zclib.Timer.Remove(timerid)

    zclib.Timer.Create(timerid,10,0,function()

        if zbl.Player_OV == nil or table.Count(zbl.Player_OV) <= 0 then return end

        for k,v in pairs(zbl.Player_OV) do
            if not IsValid(v) then continue end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

            local vac_id = zbl.Vaccine.Get(v)
            local ov_data = zbl.Vaccine.GetOccopationData(vac_id)
            if ov_data == nil then continue end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

            local vData = {
                vaccine_id = vac_id,
                vaccine_stage = 1,
                inflictor = v,
                infect_type = "asymptomatic_transmission"
            }

            zbl.Infect.Proximity(v:GetPos(),  ov_data.infection_radius, ov_data.infection_chance,vData)
        end
    end)
end

// Tells us if a player is infected by virus in its occopating phase
function zbl.Occopation.IsContaminated(ply)
    return IsValid(zbl.Player_OV[zclib.Player.GetID(ply)])
end

function zbl.Occopation.AddPlayer(ply)
    zclib.Debug("zbl.Occopation.AddPlayer: " .. tostring(ply))
    zbl.Player_OV[zclib.Player.GetID(ply)] = ply
end

function zbl.Occopation.RemovePlayer(steamid)
    zclib.Debug("zbl.Occopation.RemovePlayer: " .. tostring(steamid))
    zbl.Player_OV[steamid] = nil
end

////////////////////////////////////////////
////////////////////////////////////////////
