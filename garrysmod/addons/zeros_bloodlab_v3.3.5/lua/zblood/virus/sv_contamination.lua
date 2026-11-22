/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.Contamination = zbl.Contamination or {}



////////////////////////////////////////////
////////// Object Contamination  ///////////
////////////////////////////////////////////

// The contamination system handels the infection of player by objects and the contamination of objects by players
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

zbl.ContaminatedObjects = zbl.ContaminatedObjects or {}
zbl.SterilizedObjects = zbl.SterilizedObjects or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

if zbl.config.Contamination.enabled then
    timer.Simple(5,function()
        zbl.Contamination.SetupTimer()
    end)
end

// Creates the global contamination timer
function zbl.Contamination.SetupTimer()
    local timerid = "zbl_ctmn_timer"
    zclib.Timer.Remove(timerid)

    zclib.Timer.Create(timerid,1,0,function()
        for k,v in pairs(zbl.ContaminatedObjects) do

            if IsValid(v) then

                if CurTime() > v.zbl_InfectionTime then
                    zbl.Contamination.ObjectSanitise(v)
                end
            else
                zbl.ContaminatedObjects[k] = nil
            end
        end

        for k,v in pairs(zbl.SterilizedObjects) do

            if IsValid(v) and v.zbl_SterilizedTime then

                if CurTime() > v.zbl_SterilizedTime then
                    zbl.Vaccine.Set(v, -1,-1)
                    zbl.SterilizedObjects[v:EntIndex()] = nil
                end
            else
                zbl.SterilizedObjects[k] = nil
            end
        end
    end)
end

// Sterilizes the object from any contamination and makes it steril for certain amount of time
function zbl.Contamination.ObjectSterilize(Object)
    if not IsValid(Object) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

    // If the object was infected then lets clear it first
    zbl.Contamination.ObjectSanitise(Object)

    zclib.Debug("zbl.Contamination.ObjectSterilize")
    // Change vaccine val to be -2 for clear time
    // zbl.config.DisinfectantSpray.Clear_Time
    // So the objects is not also clean but also steril
    // Which causes no object to infect it

    zbl.Vaccine.Set(Object, -2,-1)

    Object.zbl_SterilizedTime = CurTime() + (zbl.config.DisinfectantSpray.Clear_Time or 100)

    zbl.SterilizedObjects[Object:EntIndex()] = Object
end

function zbl.Contamination.IsSterilized(Object)
    return zbl.Vaccine.Get(Object) == -2
end

// Clears the object from any contamination
function zbl.Contamination.ObjectSanitise(Object)
    if not IsValid(Object) then return end

    zclib.Debug("zbl.Contamination.ObjectSanitise")

    if zbl.Contamination.IsObjectContaminated(Object) == false then
        return
    end

    zbl.Vaccine.Set(Object, -1,-1)

    table.RemoveByValue(zbl.ContaminatedObjects,Object)

    //Reset Virus material
    Object:SetMaterial( "", true )
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

// Contaminates the object
function zbl.Contamination.ObjectContaminate(Object,virus_id)
    if not IsValid(Object) then return end

    if zbl.AIZ.NearZone(Object:GetPos()) then
        zclib.Debug("AIZ: Contamination Failed")
        return
    end

    if zbl.Contamination.IsSterilized(Object) then return end

    // Make sure object is not contaminated yet
    if zbl.Contamination.IsObjectContaminated(Object) then return end

    // If we allready reached the contaminated object limit then lets stop for now
    if zbl.ContaminatedObjects and table.Count(zbl.ContaminatedObjects) >= zbl.config.Contamination.limit then
        return
    end

    zbl.Vaccine.Set(Object, virus_id,1)

    Object.zbl_InfectionTime = CurTime() + zbl.Vaccine.GetContamination_Time(virus_id)

    table.insert(zbl.ContaminatedObjects,Object)

    //Set Virus material
    if zbl.config.Contamination.visible == true then
        Object:SetMaterial(zbl.Vaccine.GetMaterial(virus_id), true)
    end
end

// Contaminates all object in proximity
function zbl.Contamination.ProximityContaminate(pos, dist, virus_id)
	zclib.Debug("zbl.Contamination.ProximityContaminate")
    for a, w in pairs(ents.FindInSphere(pos, dist)) do
        if IsValid(w) and zbl.config.Contamination.ents[w:GetClass()] then
            zbl.Contamination.ObjectContaminate(w, virus_id)
        end
    end
end

// Checks if the object can be contaminated
function zbl.Contamination.CanBeContaminated(Object)
    return zbl.config.Contamination.ents[Object:GetClass()] and zbl.Vaccine.Get(Object) ~= -2
end

// Checks if the object is contaminated
function zbl.Contamination.IsObjectContaminated(Object)
    return zbl.Vaccine.Has(Object)
end

// Clears all the Objects it can find
function zbl.Contamination.ClearAll(ply)
    for k, v in pairs(zbl.ContaminatedObjects) do
        if IsValid(v) and zbl.Contamination.IsObjectContaminated(v) then
            zbl.Contamination.ObjectSanitise(v)
        end
    end

    zbl.ContaminatedObjects = {}

    zbl.Sign.Reset(2)
end

// Used for detecting Object interfactions
zclib.Hook.Add( "PlayerUse", "zbl_PlayerUse", function( ply, ent )
    if zbl.config.Contamination.enabled and IsValid(ent) and IsValid(ply) and (ply.zbl_NextObjectUse == nil or ply.zbl_NextObjectUse < CurTime()) and zbl.Contamination.CanBeContaminated(ent) then

        ply.zbl_NextObjectUse = CurTime() + 1

        // Is the player allready infected?
        if zbl.Vaccine.Has(ply) then
            // Player is allready sick!

            // Does the player contaminate the object?
            local virus_id = zbl.Vaccine.Get(ply)
            if zbl.Vaccine.IsVirus(virus_id) and zbl.Vaccine.CanContaminate(virus_id) and zclib.util.RandomChance(zbl.Vaccine.GetContamination_Chance(virus_id)) then

                // Object contaminated!
                zbl.Contamination.ObjectContaminate(ent,virus_id)
            end
        else
            // Player is not infected!

            // Is the object contaminated?
            if zbl.Contamination.IsObjectContaminated(ent) then

                local vData = {
                    vaccine_id = zbl.Vaccine.Get(ent),
                    vaccine_stage = 1,
                    inflictor = ent,
                    infect_type = "contamination"
                }

                // Player infected!
                zbl.Player.Infect(ply,vData)
            end
        end


        if zbl.config.Contamination.AutoContaminate.enabled and zbl.config.Contamination.AutoContaminate.HeavyUsePriority then
            if zbl.InteractedObjects[ent] == nil then
                zbl.InteractedObjects[ent] = 1
            else
                zbl.InteractedObjects[ent] = math.Clamp(zbl.InteractedObjects[ent] + 1,1,25)
            end
            zclib.Debug("InteractedObjects[" .. tostring(ent) .. "] Count: " .. zbl.InteractedObjects[ent])
        end
    end
end )

util.AddNetworkString("zbl_CtmnObjects_Show")
function zbl.Contamination.DebugShow(ply)
    local new_tbl = {}

    for k,v in pairs(zbl.ContaminatedObjects) do
        if IsValid(v) then
            table.insert(new_tbl,v:GetPos())
        end
    end

    // Send position table to client
    local dataString = util.TableToJSON(new_tbl)
    local dataCompressed = util.Compress(dataString)

    net.Start("zbl_CtmnObjects_Show")
    net.WriteUInt(#dataCompressed, 16)
    net.WriteData(dataCompressed, #dataCompressed)
    net.Send(ply)
end
////////////////////////////////////////////
////////////////////////////////////////////






////////////////////////////////////////////
//////////// Auto Contamination  ///////////
////////////////////////////////////////////

// This system automaticly contaminates objects every interval

if zbl.config.Contamination.AutoContaminate.enabled then
    timer.Simple(5,function()
        zbl.Contamination.Auto_SetupTimer()
    end)
end

zbl.InteractedObjects = zbl.InteractedObjects or {}

// Creates the global contamination timer
function zbl.Contamination.Auto_SetupTimer()
    zclib.Debug("zbl.Contamination.Auto_SetupTimer")

    local timerid = "zbl_ctmn_auto_timer"
    zclib.Timer.Remove(timerid)

    zclib.Timer.Create(timerid,zbl.config.Contamination.AutoContaminate.interval,0,function()

        // If we allready reached the contaminated object limit then lets stop for now
        if zbl.ContaminatedObjects and table.Count(zbl.ContaminatedObjects) >= zbl.config.Contamination.limit then
            return
        end

        local ent_pool = {}
        // Get All the entities which can be contaminated on the server
        if zbl.config.Contamination.AutoContaminate.HeavyUsePriority and table.Count(zbl.InteractedObjects) > 0 then
            for ent, count in pairs(zbl.InteractedObjects) do
                if IsValid(ent) and zbl.Contamination.IsObjectContaminated(ent) == false then
                    for i = 1, (count or 1) do
                        table.insert(ent_pool, ent)
                    end
                end
            end

            // Lets reset the interacted table
            zbl.InteractedObjects = {}
        else

            for k, v in pairs(ents.GetAll()) do
                if IsValid(v) and zbl.Contamination.CanBeContaminated(v) and zbl.Contamination.IsObjectContaminated(v) == false then
                    table.insert(ent_pool, v)
                end
            end
        end

        ent_pool = zclib.table.randomize(ent_pool)
        local winner_ent = ent_pool[math.random(#ent_pool)]
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

        // Generate a random virus id according to the spawn chance
        local pool = {}
        for k, v in pairs(zbl.config.Contamination.AutoContaminate.virus_chance) do
            for i = 1, v do
                table.insert(pool, k)
            end
        end
        pool = zclib.table.randomize(pool)
        local virus_id = pool[math.random(#pool)]

        zbl.Contamination.ObjectContaminate(winner_ent,virus_id)
    end)
end

////////////////////////////////////////////
////////////////////////////////////////////
