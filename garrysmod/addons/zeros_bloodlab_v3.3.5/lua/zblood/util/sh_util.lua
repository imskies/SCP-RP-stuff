/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

zbl = zbl or {}
zbl.util = zbl.util or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

/*
function zbl.Print(msg)
	print("[Zero´s GenLab] " .. msg)
end
*/

function zbl.Print(msg)
	MsgC(Color(190, 58, 80, 255), "[Zero´s GenLab] -> ", Color(255, 255, 255), msg .. "\n")
end


if (CLIENT) then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

	// Checks if the entity did not got drawn for certain amount of time and call update functions for visuals
	function zbl.util.UpdateEntityVisuals(ent)
		if zclib.util.InDistance(LocalPlayer():GetPos(), ent:GetPos(), 600) then

			local curDraw = CurTime()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

			if ent.LastDraw == nil then
				ent.LastDraw = CurTime()
			end

			if ent.LastDraw < (curDraw - 1) then
				ent:UpdateVisuals()
			end

			ent.LastDraw = curDraw
		end
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

// Adds a danger factor according to the virus config
local function GenerateDangerFactor()
	for key,vaccine in pairs(zbl.Vaccine.GetAll()) do
		if zbl.Vaccine.IsVirus(key) == false then continue end

		local danger = 0

		// Lets add 1 danger point per 1 minute of duration, dividide by mutation_chance
		local dur = 0
		for _,stage in pairs(vaccine.mutation_stages) do
			if stage.duration then
				dur = dur + stage.duration
			else
				dur = dur + vaccine.duration
			end
		end
		dur = dur * ((1 / 100) * vaccine.mutation_chance)
		danger = danger + math.Round(dur / 60)

		// If Occopation exists and is extremly infectios give points
		if vaccine.occopation then
			local occo_danger = math.Round(math.Clamp(vaccine.occopation.time / 30,1,100))
			occo_danger = occo_danger + math.Round(math.Clamp(vaccine.occopation.infection_radius / 100,0,100))

			occo_danger = occo_danger * ((1 / 100) * vaccine.occopation.infection_chance)

			danger = danger + occo_danger
		end

		// The more contagous the virus is the higher its danger factor becomes
		if vaccine.contamination then
			local conta_danger = math.Round(math.Clamp(vaccine.contamination.time / 60,1,100))
			conta_danger = conta_danger * ((1 / 100) * vaccine.contamination.chance)

			danger = danger + conta_danger
		end

		// If it doesent cure on death then its extremly dangerous
		if vaccine.cure.ondeath == false then
			danger = danger * 2
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

		vaccine.dangerfactor = math.Round(danger)
	end
end

// Generates a danger factor for each virus according to its config
GenerateDangerFactor()
////////////////////////////////////////////
////////////////////////////////////////////
