/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end

/*

	This module will prevent any infections if no player on the server has the Genetic Researcher job

*/
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

local enabled = false

if not enabled then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

// Every 300 seconds we will check if there is a research job on the server
local UpdateInterval = 300
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

local NoResearcherJob = false
local NextCheck = 0
hook.Add("zbl_BlockInfection", "zbl_BlockInfection_job", function(corpse, virus_id)

	if CurTime() > NextCheck then
		NoResearcherJob = true
		for k,v in pairs(zclib.Player.GetAll()) do
			if not IsValid(v) then continue end
			if zbl.config.Jobs[v:Team()] then
				NoResearcherJob = false
				break
			end
		end
		NextCheck = CurTime() + UpdateInterval
	end
	return NoResearcherJob
end)
