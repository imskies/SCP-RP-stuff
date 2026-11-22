/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.Player = zbl.Player or {}
zbl.Vaccine = zbl.Vaccine or {}

function zbl.Vaccine.Set(ent, id, stage)
    ent:SetNWInt("zbl_Vaccine", id)
    ent:SetNWInt("zbl_VaccineStage", stage)
end


////////////////////////////////////////////
///////// Player Vaccinate / Cure //////////
////////////////////////////////////////////

// This list keeps track on which player is infected by which virus and at what stage
zbl.ActiveVaccines = zbl.ActiveVaccines or {}

function zbl.Player.SetActiveVaccine(steamID,vaccine_id,vaccine_stage)
    zbl.ActiveVaccines[steamID] = {id = vaccine_id,stage = vaccine_stage}
end

function zbl.Player.RemoveActiveVaccine(steamID)
    zbl.ActiveVaccines[steamID] = nil
end

function zbl.Player.GetActiveVaccine(steamID)
    local data = zbl.ActiveVaccines[steamID]
    if data then
        return data.id,data.stage
    end
end



// Returns the Protection Chance
function zbl.Player.GetProtectionChance(ply, vaccineID, vaccinestage)
    return math.Clamp(zbl.config.ProtectionCheck(ply, vaccineID, vaccinestage),0,100)
end

// Tests the player Protection and removes a gasmask use if he has any
function zbl.Player.ProtectionTest(ply, vaccineID, vaccinestage)
	if not IsValid(ply) then return end
    local chance = zbl.Player.GetProtectionChance(ply, vaccineID, vaccinestage)
    local immun =  zclib.util.RandomChance(chance)

    // Just to be sure if 100% protection chance then lets set him to immun
    if chance >= 100 then
        immun = true
    end

    // Removes a use from the respirator
    if zbl.GasMask.Has(ply) then zbl.GasMask.Use(ply) end

    zclib.Debug("Protection chance: " .. chance .. " %")

    zclib.Debug("zbl.Player.ProtectionTest: " .. zclib.Player.GetName(ply) .. " IsImmun: " .. tostring(immun))
    return chance , immun
end

// Same as Player_Vaccinate but its called only by viruses to diffrenciate it better
function zbl.Player.Infect(ply,vData)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

    /*
        vData will have information about:
            VaccineID
            VaccineStage
            Inflictor
            InfectionType

        vData = {
            vaccine_id = id,
            vaccine_stage = stage,
            inflictor = inflictor,
            infect_type = "cough"
        }
    */

    // This is a simple version of ProtectionCheck to block anything
    local InfectionBlock = hook.Run("zbl_BlockInfection" ,ply,vData.vaccine_id)
    if InfectionBlock then
        return
    end

    // We dont allow player to get infected near the Anti Infection zones
    if zbl.AIZ.NearZone(ply:GetPos()) then
        zclib.Debug("AIZ: Infection prevented")
        zclib.Notify(ply, zbl.language.General["Infectionprevented"], 2)
        return
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

    // Check if the player is immun/protected against the virus
    local _ , immun = zbl.Player.ProtectionTest(ply, vData.vaccine_id, vData.vaccine_stage)
    if immun then
        zclib.Debug("Infection Failed")
        zclib.Debug(zclib.Player.GetName(ply) .. " is well protected against any virus.")
        return
    end

    // If the player got cured from this virus then lets check if he is still immun against it
    if zbl.Player.IsImmun(ply,vData.vaccine_id) then
        zclib.Debug("Infection Failed")
        zclib.Debug(zclib.Player.GetName(ply) .. " is still immun against this virus!")
        return
    end

    zbl.Player.StartVaccine(ply,vData)
end

// Applys a Vaccine/Virus to a Player
// This gets only called by a player
function zbl.Player.Vaccinate(ply,vaccineID,vaccinestage,inflictor)
    zclib.Debug("zbl.Player.Vaccinate")

    // This is a simple version of ProtectionCheck to block anything
    local InfectionBlock = hook.Run("zbl_BlockInfection" ,ply,vaccineID)
    if InfectionBlock then
        return
    end

    // We dont allow player to get infected near the Anti Infection zones
    if zbl.AIZ.NearZone(ply:GetPos()) then
        zclib.Debug("AIZ: Infection prevented")
        zclib.Notify(ply, zbl.language.General["Infectionprevented"], 2)
        return
    end

    // Custom Hook
    hook.Run("zbl_OnPlayerInject" ,ply, vaccineID,inflictor)

    local vData = {
        vaccine_id = vaccineID,
        vaccine_stage = 1,
        inflictor = inflictor,
        infect_type = "injection"
    }

    zbl.Player.StartVaccine(ply,vData)
end

// Starts the specified vaccine
function zbl.Player.StartVaccine(ply,vData)

    // If the vaccine id is a virus then we stop any active abillity and infect the player
    if zbl.Player.VaccineOverride(ply) == true then
        zbl.Player.ForceCure(ply)
    end

    // Cant infect the player if he is allready infected
    if zbl.Vaccine.Has(ply) then
        zclib.Debug(zclib.Player.GetName(ply) .. " is allready infected " .. zbl.Vaccine.GetName(zbl.Vaccine.Get(ply)))

        return
    end

    // Called to infom that a player just infected
    hook.Run("zbl_OnPlayerInfect" ,ply, vData)

    // Is this a virus
    if zbl.Vaccine.IsVirus(vData.vaccine_id) then

        zclib.Debug(zclib.Player.GetName(ply) .. " got infected with " .. zbl.Vaccine.GetName(vData.vaccine_id))

        // Has it occopation period?
        if zbl.Vaccine.GetOccopationData(vData.vaccine_id) == nil then

            zbl.Player.ApplyVaccineStage(ply,vData.vaccine_id,vData.vaccine_stage)
            return
        end

        // This tells that the players virus is still in its occopation stage
        zbl.Vaccine.Set(ply, vData.vaccine_id,0)

        // Start occopation Timer
        local timerid = "zbl_vaccine_occopation_timer_" .. zclib.Player.GetID(ply)
        zclib.Timer.Remove(timerid)

        // Add player to occopation list
        zbl.Occopation.AddPlayer(ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

        local occopationTime = zbl.Vaccine.GetOccopationTime(vData.vaccine_id)
        zclib.Timer.Create(timerid,occopationTime,1,function()
            zclib.Timer.Remove(timerid)

            // Remove Player from Occopation list
            zbl.Occopation.RemovePlayer(zclib.Player.GetID(ply))

            zbl.Player.ApplyVaccineStage(ply,vData.vaccine_id,vData.vaccine_stage)
        end)
        zclib.Debug(zclib.Player.GetName(ply) .. " Occopation Timer started with " .. occopationTime .. " seconds!")
    else

        zclib.Debug(zclib.Player.GetName(ply) .. " got vaccined with " .. zbl.Vaccine.GetName(vData.vaccine_id))

        // Notify the player that his ability has started
        zclib.Notify(ply, string.Replace(zbl.language.General["AbilityStart"],"$AbilityName",zbl.Vaccine.GetName(vData.vaccine_id)), 4)

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

        zbl.Player.ApplyVaccineStage(ply,vData.vaccine_id,vData.vaccine_stage)
    end
end

function zbl.Player.ApplyVaccineStage(ply,vaccineID,vaccinestage)
    zclib.Debug("zbl.Player.ApplyVaccineStage")

    // Stores which steamid got vaccined by which vaccine
    zbl.Player.SetActiveVaccine(zclib.Player.GetID(ply),vaccineID,vaccinestage)

    // Changes the Visual Appearance of the Player
    zbl.Player.ChangeAppearance(ply, vaccineID, vaccinestage or 1)

    // Start Symptomes
    zbl.Symptome.OnStart(ply,vaccineID,vaccinestage)

    // Start Vaccine Timer
    local timerid = "zbl_vaccinetimer_" .. zclib.Player.GetID(ply)
    zclib.Timer.Remove(timerid)

    local stage_duration = zbl.Vaccine.GetDuration(vaccineID)

    // If there is a duration value defined in the mutation stage then we override the default vaccine duration
    local mData = zbl.Vaccine.GetMutationStage_Data(vaccineID,vaccinestage)
    if mData and mData.duration then stage_duration = mData.duration end

    zclib.Timer.Create(timerid,stage_duration,1,function()

        zclib.Timer.Remove(timerid)

        zbl.Symptome.OnEnd(ply)

        local nextStage = zbl.Vaccine.GetStage(ply) + 1

        local mChance = zbl.Vaccine.GetMutationChance(vaccineID)
        mData = zbl.Vaccine.GetMutationStage_Data(vaccineID,nextStage)

        // Here we gonna check if the vaccine has more stages and if so then we check if it can mutate
        if mChance > 1 and mData and zclib.util.RandomChance(mChance) then

            //zclib.Debug("Vaccine: " .. zbl.Vaccine.GetName(vaccineID) .. " just mutated to stage " .. nextStage .. "!")
			hook.Run("zbl_OnVirusMutate", ply, vaccineID, nextStage)

            // Lets mutate the vaccine to the next stage
            zbl.Player.ApplyVaccineStage(ply,zbl.Vaccine.Get(ply),nextStage)
        else
            if zbl.Vaccine.IsVirus(vaccineID) == false then
                zclib.Notify(ply, string.Replace(zbl.language.General["AbilityStop"],"$AbilityName",zbl.Vaccine.GetName(vaccineID)), 4)
            end
            zbl.Player.ForceCure(ply)
        end
    end)

    zbl.Vaccine.Set(ply, vaccineID, vaccinestage or 1)
end



// Makes the player immun against this virus id for a certain amount of time
function zbl.Player.MakeImmun(ply,virus_id,time)
    if ply.zbl_Immuinty == nil then ply.zbl_Immuinty = {} end
    ply.zbl_Immuinty[virus_id] = CurTime() + time
end

// Returns true if the player is currently immun against this virus
function zbl.Player.IsImmun(ply,id)
    if ply.zbl_Immuinty and ply.zbl_Immuinty[id] and CurTime() < ply.zbl_Immuinty[id] then
        return true
    else
        return false
    end
end



// Cures all the players in proximity if the vaccine id matches
function zbl.Player.CureProximity(vac_id, pos, dist)
    if vac_id == -1 then return end
    zclib.Debug("zbl.Player.CureProximity")

    for k, v in pairs(zclib.Player.List) do

        if IsValid(v) and v:Alive() and zclib.util.InDistance(pos, v:GetPos(), dist) then

            local vaccindID = zbl.Vaccine.Get(v)

            // Check if player is even infected
            if vaccindID ~= -1 and vaccindID == vac_id then
                zbl.Player.MakeImmun(v, vac_id, zbl.Vaccine.GetCure_Time(vac_id))
                zbl.Player.Cure(v)
            end
        end
    end
end

// Called when the player gets cured/vaccine removed
function zbl.Player.Cure(ply)
    zclib.Debug("zbl.Player.Cure")
    if not IsValid(ply) then return end

    local vac_id = zbl.Vaccine.Get(ply)

    // Custom Hook
    hook.Run("zbl_OnPlayerCured" ,ply, vac_id)

    zbl.Symptome.OnEnd(ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

    local timerid_vac = "zbl_vaccinetimer_" .. zclib.Player.GetID(ply)
    zclib.Timer.Remove(timerid_vac)

    local timerid_ov = "zbl_vaccine_occopation_timer_" .. zclib.Player.GetID(ply)
    zclib.Timer.Remove(timerid_ov)


    // Removes the activevaccine id from the list
    zbl.Player.RemoveActiveVaccine(zclib.Player.GetID(ply))

    // Resets the Visual Appearance of the Player
    zbl.Player.ResetAppearance(ply)

    // Remove Player from Occopation list
    zbl.Occopation.RemovePlayer(zclib.Player.GetID(ply))

    zbl.Vaccine.Set(ply, -1, -1)

    zclib.Debug(zclib.Player.GetName(ply) .. " got cured from " .. zbl.Vaccine.GetName(vac_id))
end

// This gets called by the script when the player dies or the vaccine run out of mutation stages
function zbl.Player.ForceCure(ply)
    zclib.Debug("zbl.Player.ForceCure")
    if not IsValid(ply) then return end

    local vac_id = zbl.Vaccine.Get(ply)

    // Lets make the player immun against any virus for the next 10 seconds
    zbl.Player.MakeImmun(ply,vac_id,10)

    zbl.Player.Cure(ply)
end

// Tells us if the players current infection can be overriden by another vaccine
// Return true to allow the current vaccine to be overriden
function zbl.Player.VaccineOverride(ply)
    local active_vac_id = zbl.Vaccine.Get(ply)
    if zbl.Vaccine.IsValid(active_vac_id) then
        if zbl.Vaccine.IsVirus(active_vac_id) == false then
            return true
        else
            return false
        end
    else
        return nil
    end
end
////////////////////////////////////////////
////////////////////////////////////////////
