/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

zbl = zbl or {}
zbl.Vaccine = zbl.Vaccine or {}


// Returns the currently active vaccine
function zbl.Vaccine.Get(ent)
    return ent:GetNWInt("zbl_Vaccine", -1)
end

function zbl.Vaccine.GetStage(ent)
    return ent:GetNWInt("zbl_VaccineStage", 1)
end

// Checks if the player has any vaccine currently in his system
function zbl.Vaccine.Has(ent)
    return zbl.Vaccine.Get(ent) ~= -1
end




function zbl.Vaccine.GetAll()
    return zbl.config.Vaccines
end

function zbl.Vaccine.IsValid(id)
    if id == nil then return false end
    return zbl.config.Vaccines[id] ~= nil
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

function zbl.Vaccine.GetData(id)
    if zbl.Vaccine.IsValid(id) then
        return zbl.config.Vaccines[id]
    end
end

function zbl.Vaccine.GetName(id)
    if id == nil then return "Unkown" end
    local data = zbl.Vaccine.GetData(id)
    if data and data.name then
        return data.name
    else
        return "Unkown"
    end
end

function zbl.Vaccine.GetPrice(id)
    if id == nil then return 1000 end
    local data = zbl.Vaccine.GetData(id)
    if data and data.price then
        return data.price
    else
        return 1000
    end
end

function zbl.Vaccine.GetDuration(id)
    if id == nil then return 100 end
    local data = zbl.Vaccine.GetData(id)
    if data and data.duration then
        return data.duration
    else
        return 100
    end
end

function zbl.Vaccine.GetDescription(id)
    if id == nil then return "" end
    local data = zbl.Vaccine.GetData(id)
    if data and data.desc then
        return data.desc
    else
        return ""
    end
end

function zbl.Vaccine.IsVirus(id)
    if id == nil then return false end
    local data = zbl.Vaccine.GetData(id)
    if data and data.isvirus ~= nil then
        return data.isvirus
    else
        return false
    end
end

function zbl.Vaccine.GetCount()
    return table.Count(zbl.Vaccine.GetAll())
end

function zbl.Vaccine.GetMaterial(id)
    if id == nil then return "" end
    local data = zbl.Vaccine.GetData(id)
    if data and data.mat then
        return data.mat
    else
        return ""
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c




function zbl.Vaccine.GetOccopationData(id)
    if id == nil then return end
    local data = zbl.Vaccine.GetData(id)
    if data and data.occopation then
        return data.occopation
    end
end

function zbl.Vaccine.GetOccopationTime(id)
    local odata = zbl.Vaccine.GetOccopationData(id)
    if odata and odata.time then
        return odata.time
    end
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337


                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337



function zbl.Vaccine.CanContaminate(id)
    if id == nil then return false end
    local data = zbl.Vaccine.GetData(id)
    if data and data.contamination then
        return true
    else
        return false
    end
end

function zbl.Vaccine.GetContamination_Time(id)
    if id == nil then return 100 end
    local data = zbl.Vaccine.GetData(id)
    if data and data.contamination and data.contamination.time then
        return data.contamination.time
    else
        return 100
    end
end

function zbl.Vaccine.GetContamination_Chance(id)
    if id == nil then return 75 end
    local data = zbl.Vaccine.GetData(id)
    if data and data.contamination and data.contamination.chance then
        return data.contamination.chance
    else
        return 75
    end
end


function zbl.Vaccine.GetCure_Time(id)
    if id == nil then return 1200 end
    local data = zbl.Vaccine.GetData(id)
    if data and data.cure and data.cure.immunity_time then
        return data.cure.immunity_time
    else
        return 1200
    end
end

function zbl.Vaccine.GetCure_Price(id)
    if id == nil then return 1000 end
    local data = zbl.Vaccine.GetData(id)
    if data and data.cure and data.cure.price then
        return data.cure.price
    else
        return 1000
    end
end

function zbl.Vaccine.GetCure_OnDeath(id)
    if id == nil then return false end
    local data = zbl.Vaccine.GetData(id)
    if data and data.cure and data.cure.ondeath then
        return data.cure.ondeath
    else
        return false
    end
end



/*
	Checks if the player is allowed to create the specified vaccine
*/
function zbl.Vaccine.CanResearch(ply,id,IsCure,Notify)
    if not id then return false end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

    local data = zbl.Vaccine.GetData(id)
	if not data then return false end

	if data.research.ranks and not zclib.Player.RankCheck(ply, data.research.ranks) then
		if Notify then
			zclib.Notify(ply, zbl.language.General["WrongRank"], 1)
			zclib.Notify(ply, zclib.table.ToString(data.research.ranks), 1)
		end
		return false
	end

	if data.research.jobs and table.Count(data.research.jobs) > 0 and not data.research.jobs[zclib.Player.GetJob(ply)] then
		if Notify then
			zclib.Notify(ply, zbl.language.General["WrongJob"], 1)
			zclib.Notify(ply, zclib.table.JobToString(data.research.jobs), 1)
		end
		return false
	end

	local result = hook.Run("zbl_LabCanCreate", ply, id, IsCure,Notify)
	if result ~= nil then
		return result
	end

	if data.research.customcheck then
		return data.research.customcheck(ply,id,IsCure,Notify)
	else
		return true
	end
end

function zbl.Vaccine.GetResearch_Data(id)
    if id == nil then return {} end
    local data = zbl.Vaccine.GetData(id)
    if data and data.research then
        return data.research
    else
        return {}
    end
end

function zbl.Vaccine.GetResearch_VaccinePoints(id)
    if id == nil then return 0 end
    local rdata = zbl.Vaccine.GetResearch_Data(id)
    if rdata and rdata["vaccine_points"] then
        return rdata["vaccine_points"]
    else
        return 0
    end
end

function zbl.Vaccine.GetResearch_VaccineTime(id)
    if id == nil then return 10 end
    local rdata = zbl.Vaccine.GetResearch_Data(id)
    if rdata and rdata["vaccine_time"] then
        return rdata["vaccine_time"]
    else
        return 10
    end
end

function zbl.Vaccine.GetResearch_CurePoints(id)
    if id == nil then return -1 end
    local rdata = zbl.Vaccine.GetResearch_Data(id)
    if rdata and rdata["cure_points"] then
        return rdata["cure_points"]
    else
        return -1
    end
end

function zbl.Vaccine.GetResearch_CureTime(id)
    if id == nil then return 10 end
    local rdata = zbl.Vaccine.GetResearch_Data(id)
    if rdata and rdata["cure_time"] then
        return rdata["cure_time"]
    else
        return 10
    end
end


function zbl.Vaccine.GetMutationChance(id)
    if id == nil then return -1 end
    local data = zbl.Vaccine.GetData(id)
    if data and data.mutation_chance then
        return data.mutation_chance
    else
        return -1
    end
end

function zbl.Vaccine.IsValidMutationStage(id,stage)
    local stageData = zbl.Vaccine.GetMutationStage_Data(id,stage)
    if stageData then
        return true
    else
        return false
    end
end

function zbl.Vaccine.GetMutationStages(id)
    local data = zbl.Vaccine.GetData(id)
    if data == nil then return end
    if data.mutation_stages == nil then return end
    return data.mutation_stages
end

function zbl.Vaccine.GetMutationStage_Data(id,stage)
    local data = zbl.Vaccine.GetData(id)
    if data == nil then return end
    if data.mutation_stages == nil then return end
    local mutation_stage = data.mutation_stages[stage]
    if mutation_stage == nil then return end
    return mutation_stage
end

function zbl.Vaccine.GetMutationStage_Symptomes(id,stage)
    local mutation_stage = zbl.Vaccine.GetMutationStage_Data(id,stage)
    if mutation_stage == nil then return end
    if mutation_stage.symptomes == nil then return end
    if table.Count(mutation_stage.symptomes) <= 0 then return end
    return mutation_stage.symptomes
end

function zbl.Vaccine.GetMutationStage_Effects(id,stage)
    local mutation_stage = zbl.Vaccine.GetMutationStage_Data(id,stage)
    if mutation_stage == nil then return end
    if mutation_stage.effects == nil then return end
    if table.Count(mutation_stage.effects) <= 0 then return end
    return mutation_stage.effects
end

function zbl.Vaccine.GetMutationStage_Duration(id,stage)
    local mutation_stage = zbl.Vaccine.GetMutationStage_Data(id,stage)
    if mutation_stage == nil then return end
    if mutation_stage.duration == nil then return end

    return mutation_stage.duration
end



function zbl.Vaccine.GetPerception_Data(id,stage)
    local data = zbl.Vaccine.GetMutationStage_Data(id,stage)
    if data and data.perception and zbl.config.PerceptionEffects[data.perception] then
        return zbl.config.PerceptionEffects[data.perception]
    end
end
