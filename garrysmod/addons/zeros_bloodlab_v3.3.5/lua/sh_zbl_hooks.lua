/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

// Here are some Hooks you can use for Custom Code
// If you need any more hooks just open a ticket or write me on steam

if SERVER then

	/*
		Can be used to overwrite if the player is allowed to create the specified vaccine
	*/
	hook.Add("zbl_LabCanCreate", "zbl_LabCanCreate_Test", function(ply, VaccineID, IsVirus, IsCure, Notify) 
		// if ply:IsSuperAdmin() then return true end
	end)

	/*
		Return false to prevent the player from using the injector gun (Left Click)
	*/
	hook.Add("zbl_CanInjectorGun_Primary", "zbl_CanInjectorGun_Primary_test", function(swep, ply)

	end)

	/*
		Return false to prevent the player from using the injector gun (Right Click)
	*/
	hook.Add("zbl_CanInjectorGun_Secondary", "zbl_CanInjectorGun_Secondary_test", function(swep, ply)

	end)

	/*
		Called when a Virus on a player Mutates to the next stage
	*/
	hook.Add("zbl_OnVirusMutate", "zbl_OnVirusMutate_Test", function(ply, virus_id,next_stage)

	end)

	/*
		Gets called when a corpse explodes
	*/
	hook.Add("zbl_OnCorpseExplosion", "zbl_OnCorpseExplosion_Test", function(corpse, virus_id)

	end)

    /*
		Gets called when a virus node dies
	*/
    hook.Add("zbl_OnVirusNodeDeath", "zbl_OnVirusNodeDeath_Test", function(inflictor, virus_id)
        /*
        // If the entity who killed the virus node is valid and a player then lets give him some cash
        if IsValid(inflictor) and inflictor:IsPlayer() and inflictor:Alive() then
            local money = 25
            zclib.Notify(inflictor, zclib.Money.Display(money) .. " for killing a virusnode!", 0)
            zclib.Money.Give(inflictor, money)
        end
        */
    end)

    /*
		This hook gets called before anything else and can be used to prevent a player from getting infected, no matter what
		Its a simpler version of ProtectionCheck
	*/
    hook.Add("zbl_BlockInfection", "zbl_BlockInfection_Test", function(ply, vaccine_id)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

        /*
        // Return true to block the player getting infected
        if ply:IsSuperAdmin() then
            return true
        end
        */
    end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

    /*
		Called when a player gets infected
	*/
    hook.Add("zbl_OnPlayerInfect", "zbl_OnPlayerInfect_Test", function(ply, iData)
        /*

        // Infection Data
        iData = {
            vaccine_id = id,
            vaccine_stage = stage,
            inflictor = inflictor,
            infect_type = "cough"
        }

        Infection Types:
            "debug_InfectProximity"
            "corpse_explosion"
            "vomit_projectile"
            "diaria_spot"
            "asymptomatic_transmission"
            "flask_explosion"
            "virusnode_explosion"
            "explosive_head"
            "explosive_diarrhea"
            "coughing"
        */

        /*
        print("zbl_OnPlayerInfect")
        print("Player: " .. tostring(ply))
        print("VaccineID: " .. iData.vaccine_id)
        print("Inflictor: " .. tostring(iData.inflictor)) // <- The Inflictor can be a player but also a contaminated entity like a door,virus_node, vomit projectile, diaria_spot
        print("Infection Type: " .. tostring(iData.infect_type))
        print("-----------------------------")
        */
    end)

    /*
		Called when a player injects another player
	*/
    hook.Add("zbl_OnPlayerInject", "zbl_OnPlayerInject_Test", function(target, vaccine_id, inflictor)
        /*
        print("zbl_OnPlayerInject")
        print("Target: " .. tostring(target))
        print("Inflictor: " .. tostring(inflictor))
        print("VaccineID: " .. vaccine_id)
        print("-----------------------------")
        */
    end)


    /*
		Called when a player cures another player
	*/
    hook.Add("zbl_OnPlayerCurePlayer", "zbl_OnPlayerCurePlayer_Test", function(target, vaccine_id, inflictor)
        /*
        print("zbl_OnPlayerCurePlayer")
        print("Target: " .. tostring(target))
        print("Inflictor: " .. tostring(inflictor))
        print("VaccineID: " .. vaccine_id)
        print("-----------------------------")
        */
    end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

    /*
		Called when a player gets a sample from a other player or entity
	*/
    hook.Add("zbl_OnPlayerGetSample", "zbl_OnPlayerGetSample_Test", function(target, inflictor, sample_name, sample_identifier, sample_points)
        /*
        print("zbl_OnPlayerGetSample")
        print("Target: " .. tostring(target))
        print("Inflictor: " .. tostring(inflictor))
        print("Sample_name: " .. sample_name)
        print("Sample_identifier: " .. sample_identifier)
        print("Sample_points: " .. sample_points)
        print("-----------------------------")
        */
    end)

    /*
		Called when a player gets cured
	*/
    hook.Add("zbl_OnPlayerCured", "zbl_OnPlayerCured_Test", function(ply, vaccine_id)
        /*
        print("zbl_OnPlayerCured")
        print("Player: " .. tostring(ply))
        print("VaccineID: " .. vaccine_id)
        print("-----------------------------")
        */
    end)

    /*
		Called when a player gets scanned by a fence
	*/
    hook.Add("zbl_OnPlayerFenceScanned", "zbl_OnPlayerFenceScanned_Test", function(ply, fence_entity)
    end)
end

if CLIENT then
    /*
		Return true to block this objects from being scanned
	*/
    hook.Add("zbl_BlockObjectScan", "zbl_BlockObjectScan_Test", function(ent)
        // If the player is cloaked then we dont want to show him on the scan
        if ent:IsPlayer() and ent:Alive() and ent:GetColor() and ent:GetColor().a == 0 then
            return true
        end
    end)
end
