/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

// THIS MODULE REQUIRES bLOGS https://www.gmodstore.com/market/view/6016
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

/*
	Logs when a player infects another player
*/
local MODULE = GAS.Logging:MODULE()
MODULE.Category = "GenLab"
MODULE.Name = "Infection"
MODULE.Colour = Color(190, 58, 80, 255)
MODULE:Setup(function()
	MODULE:Hook("zbl_OnPlayerInfect", "zbl_OnPlayerInfect_blogs", function(target, vData)
		if IsValid(target) and vData and IsValid(vData.inflictor) and vData.inflictor:IsPlayer() then
			local virus = zbl.Vaccine.GetName(vData.vaccine_id)
			MODULE:Log("{1} infected {2} with " .. virus .. " via " .. vData.infect_type, GAS.Logging:FormatPlayer(vData.inflictor), GAS.Logging:FormatPlayer(target))
		end
	end)
end)
GAS.Logging:AddModule(MODULE)


/*
	Logs when a player cures another player
*/
local MODULE = GAS.Logging:MODULE()
MODULE.Category = "GenLab"
MODULE.Name = "Cured"
MODULE.Colour = Color(190, 58, 80, 255)
MODULE:Setup(function()
	MODULE:Hook("zbl_OnPlayerCurePlayer", "zbl_OnPlayerCurePlayer_blogs", function(target, vaccine_id, inflictor)
		local virus = zbl.Vaccine.GetName(vaccine_id)

		MODULE:Log("{1} cured {2} from " .. virus, GAS.Logging:FormatPlayer(inflictor), GAS.Logging:FormatPlayer(target))
	end)
end)
GAS.Logging:AddModule(MODULE)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

/*
	Logs when a player collects a sample
*/
local MODULE = GAS.Logging:MODULE()
MODULE.Category = "GenLab"
MODULE.Name = "DNA Sample"
MODULE.Colour = Color(190, 58, 80, 255)
MODULE:Setup(function()
	MODULE:Hook("zbl_OnPlayerGetSample", "zbl_OnPlayerGetSample_blogs", function(target, inflictor, sample_name, sample_identifier, sample_points)
		if IsValid(target) and target:IsPlayer() and IsValid(inflictor) then
			MODULE:Log("{1} harvested a DNA Sample from {2}", GAS.Logging:FormatPlayer(inflictor), GAS.Logging:FormatPlayer(target))
		end
	end)
end)
GAS.Logging:AddModule(MODULE)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

/*
	Logs when a player destroys a virusnode
*/
local MODULE = GAS.Logging:MODULE()
MODULE.Category = "GenLab"
MODULE.Name = "VirusNodes"
MODULE.Colour = Color(190, 58, 80, 255)
MODULE:Setup(function()
	MODULE:Hook("zbl_OnVirusNodeDeath", "zbl_OnVirusNodeDeath_blogs", function(inflictor, virus_id)
		if IsValid(inflictor) and inflictor:IsPlayer() then
			local virus = zbl.Vaccine.GetName(virus_id)
			MODULE:Log("{1} destroyed a " .. virus .. " virusnode", GAS.Logging:FormatPlayer(inflictor))
		end
	end)
end)
GAS.Logging:AddModule(MODULE)
