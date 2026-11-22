/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

zbl = zbl or {}
zbl.config = zbl.config or {}

// Here we create all the viruses and the abillity boosts
zbl.config.Vaccines = {}

// For easier vaccine creation
local function AddVaccine(vaccine) return table.insert(zbl.config.Vaccines, vaccine) end

// Cold
VACCINE_COLD = AddVaccine({
    // Name of the Vaccine
    name = "Cold",
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

    // Description of the vaccine
    desc = "A regular cold.",

    // How much money is this vaccine worth?
    price = 1000,

    // Just to tell the script if this vaccine is a abillity boost or a virus
    isvirus = true,

    // Duration of the Vaccine / Virus per mutation stage
    // You can override the duration of each mutation stage individually bellow, then this value wont get used
    duration = 30,

    cure = {
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

        // If the player gets cured by the cure , how long will he be immun against this virus?
        immunity_time = 1200,

        // Should this vaccine/virus remove itself when the player dies?
        // Setting this to false will keep the player infected even after he respawns.
        ondeath = true,

        // How much money is the vaccine cure worth?
        price = 2000,
    },

    // This material gets applied on virus nodes and contaminated objects
    // If this vaccine is not a virus then just remove this part
    // The materials bellow come with the script but you can also use your own
    /*
        "zerochain/zblood/wounds/zbl_wound_braincells_diff"
        "zerochain/zblood/wounds/zbl_wound_flesh_diff"
        "zerochain/zblood/wounds/zbl_wound_inflorescence_diff"
        "zerochain/zblood/wounds/zbl_wound_mold_diff"
        "zerochain/zblood/wounds/zbl_wound_moss_diff"
        "zerochain/zblood/wounds/zbl_wound_mutant_diff"
        "zerochain/zblood/wounds/zbl_wound_rhizome_diff"
        "zerochain/zblood/wounds/zbl_wound_zombiemeat_diff"
    */
    mat = "zerochain/zblood/wounds/zbl_wound_moss_diff",

    // The research info for the Lab
    research = {
        // How much DNA points are needed to create this Vaccine
        vaccine_points = 15,

        // How long does it take to create this vaccine
        vaccine_time = 120,

        // How much DNA points are needed to create a cure for this vaccine? Set to -1 to disable the cure
        cure_points = 20,

        // How long does it take to create a cure this vaccine?
        cure_time = 200,

        // Those ranks are allowed to create this vaccine / cure
        ranks = {
            //["vip"] = true,
        },

		// Those jobs are allowed to create this vaccine / cure
		jobs = {
            //[TEAM_GUN] = true,
        },

		// Can be used to add a custom check for this vaccine
		/*
		customcheck = function(ply,VaccineID,IsCure,Notify)
			local result = ply:GetLevel() > 50
			if not result and Notify then zclib.Notify(ply, "You dont have the correct level for this!", 1) end
			return result
		end,
		*/
    },

    // Before the virus starts to develop any symptomes its gonna be in its occopation stage were it secretly infects other players arround the infected player every 10 seconds
    // Simple remove this block if you dont want your virus/vaccine to have a occopation stage
    // In the real world this would be called asymptomatic transmission
    occopation = {
      // How long does the occopation stage last?
      time = 5,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

      // How high is the chance for players near the infected player getting infected
      infection_chance = 25,

      // How close does a player need to be to the infected player in order to get infected
      infection_radius = 100,
    },
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

    // Should objects get contaminated with the virus if the player interacts with them
    // Simple remove this block if you dont want it
    contamination = {

        // How long will the object be contaminated?
        time = 100,

        // How high is the chance that players infected with this virus contaminate objects they interact with.
        chance = 50,
    },

    // Mutation Chance
    // The current Mutation Stage has ended this value defines if the vaccine stops or mutates which switches the mutation_stages to the next stage and restarts the vaccine timer
    // -1 Disables the mutation
    mutation_chance = 50,

    // Here you can define the diffrent stages of the vaccine/virus, effects,symptomes,perception and appearance
    mutation_stages = {
        [1] = {
            // This can be used to override the duration
            duration = 30,

            // How the vaccine affects the player
            // Here is a list of all effects
            /*
                ["movement_speed"] = 0.8, // (0.1 - 2)
                ["movement_distortion"] = 1, // (1 - 5)
                ["movement_invert"] = true, // true

                ["damage_modify"] = 1.1, // (0.1 - 2)
                ["damage_fall_modify"] = 1.1, // (0.1 - 2)
                ["damage_fire_modify"] = 1.1, // (0.1 - 2)
                ["damage_bullet_modify"] = 1.1, // (0.1 - 2)

                ["jump_modify"] = 180, // Default is 200
            */
            effects = {
                ["movement_speed"] = 0.8, // (0.1 - 2)
                ["damage_modify"] = 1.1, // (0.1 - 2)
                ["jump_modify"] = 180, // Default is 200
            },
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

            // Symptomes which can cause the vaccine to spread or to modify the player in some way (Usally just used for viruses)
            // Here is a list of all Symptomes
            /*
                ["coughing"] = {interval = 1, infect_distance = 100, infect_chance = 50, damage = 0},
                ["projectile_vomit"] = {interval = 5, damage = 0},
                ["explosive_diarrhea"] = {interval = 5, damage = 0},
                ["head_swelling"] = {scale = 2, damage = 0},
                ["legs_swelling"] = {scale = 1.75, damage = 0},
                ["explosive_head"] = {infect_distance = 300, infect_chance = 60},
            */
            symptomes = {
                // Coughing can infect other players in close proximity
                ["coughing"] = {interval = 10, infect_distance = 100, infect_chance = 50, damage = 0},
            },
        },
        [2] = {
            duration = 15,
            effects = {
                ["movement_speed"] = 0.5,
                ["damage_modify"] = 1.5,
                ["jump_modify"] = 100,
            },
            symptomes = {
                ["coughing"] = {interval = 5, infect_distance = 100, infect_chance = 90, damage = 15},
            },
            perception = "visual_distortion_strong",
        },
    },
})

// SARS
VACCINE_SARS = AddVaccine({
    name = "SARS",
    desc = "A deadly virus which causes projectile vomit on its host.",
    price = 1000,
    isvirus = true,
    duration = 300,
    cure = {
        immunity_time = 1200,
        ondeath = true,
        price = 2000,
    },
    mat = "zerochain/zblood/wounds/zbl_wound_inflorescence_diff",
    research = {
        vaccine_points = 15,
        vaccine_time = 200,
        cure_points = 20,
        cure_time = 250,
        ranks = {
            //["superadmin"] = true,
            //["vip"] = true,
        }
    },
    occopation = {
      time = 60,
      infection_chance = 60,
      infection_radius = 100,
    },
    contamination = {
        time = 35,
        chance = 75,
    },
    mutation_chance = 90,
    mutation_stages = {
        [1] = {
            effects = {
                ["movement_speed"] = 0.8,
                ["damage_modify"] = 1.1,
                ["jump_modify"] = 180,
            },
            symptomes = {
                ["projectile_vomit"] = {interval = 5, damage = 0},
            },
            perception = "visual_distortion_weak",
        },
        [2] = {
            effects = {
                ["movement_speed"] = 0.5,
                ["damage_modify"] = 1.5,
                ["jump_modify"] = 100,
            },
            symptomes = {
                ["projectile_vomit"] = {interval = 1, damage = 5},
                ["explosive_diarrhea"] = {interval = 5, damage = 0},
            },
            perception = "visual_sars_strong",
            appearance = "appearance_rhizome",
        },
    },
})

// COVID19
VACCINE_COVID = AddVaccine({
    name = "COVID-19",
    desc = "Highly infectious virus which causes heavy coughing followed by death.",
    price = 1000,
    isvirus = true,
    duration = 500,
    cure = {
        immunity_time = 1200,
        ondeath = true,
        price = 2000,
    },
    mat = "zerochain/zblood/wounds/zbl_wound_braincells_diff",
    research = {
        vaccine_points = 30,
        vaccine_time = 250,
        cure_points = 40,
        cure_time = 300,
        ranks = {
            //["superadmin"] = true,
            //["vip"] = true,
        }
    },
    occopation = {
      time = 100,
      infection_chance = 80,
      infection_radius = 100,
    },
    contamination = {
        time = 500,
        chance = 75,
    },
    mutation_chance = 90,
    mutation_stages = {
        [1] = {
            effects = {
                ["movement_speed"] = 1.2,
                ["damage_modify"] = 1.1,
            },
            symptomes = {
                ["coughing"] = {interval = 6, infect_distance = 200, infect_chance = 75, damage = 0},
            },
            perception = "visual_distortion_weak",
        },
        [2] = {
            effects = {
                ["movement_speed"] = 2,
                ["damage_modify"] = 1.5,
            },
            symptomes = {
                ["coughing"] = {interval = 3, infect_distance = 300, infect_chance = 90, damage = 15},
            },
            perception = "visual_covid_strong",
            appearance = "appearance_braincells",
        },
    },
})

// Eye Cancer
VACCINE_EYECANCER = AddVaccine({
    name = "Eye Cancer",
    desc = "Causes the host to gradully lose their eye sight.",
    price = 1000,
    isvirus = true,
    duration = 60,
    cure = {
        immunity_time = 1200,
        ondeath = true,
        price = 2000,
    },
    mat = "zerochain/zblood/wounds/zbl_wound_rhizome_diff",
    research = {
        vaccine_points = 25,
        vaccine_time = 150,
        cure_points = 25,
        cure_time = 200,
        ranks = {
            //["superadmin"] = true,
            //["vip"] = true,
        }
    },
    occopation = {
      time = 60,
      infection_chance = 50,
      infection_radius = 100,
    },
    contamination = {
        time = 60,
        chance = 60,
    },
    mutation_chance = 35,
    mutation_stages = {
        [1] = {
            perception = "visual_blindness_weak",
        },
        [2] = {
            perception = "visual_blindness_medium",
        },
        [3] = {
            perception = "visual_blindness_strong",
        },
    },
})

// Ebola
VACCINE_EBOLA = AddVaccine({
    name = "Ebola",
    desc = "Causes explosive diarrhea on its host which creates contaminated areas!",
    price = 1000,
    isvirus = true,
    duration = 60,
    cure = {
        immunity_time = 1200,
        ondeath = true,
        price = 2000,
    },
    mat = "zerochain/zblood/wounds/zbl_wound_mold_diff",
    research = {
        vaccine_points = 30,
        vaccine_time = 200,
        cure_points = 25,
        cure_time = 250,
        ranks = {
            //["superadmin"] = true,
            //["vip"] = true,
        }
    },
    occopation = {
      time = 100,
      infection_chance = 80,
      infection_radius = 100,
    },
    contamination = {
        time = 500,
        chance = 75,
    },
    mutation_chance = 90,
    mutation_stages = {
        [1] = {
            effects = {
                ["movement_speed"] = 1.2,
                ["damage_modify"] = 1.1,
            },
            symptomes = {
                ["explosive_diarrhea"] = {interval = 5, damage = 0},
            },
            perception = "visual_distortion_weak",
        },
        [2] = {
            effects = {
                ["movement_speed"] = 2,
                ["damage_modify"] = 1.5,
            },
            symptomes = {
                ["explosive_diarrhea"] = {interval = 2, damage = 10},
            },
            perception = "visual_distortion_mutant",
            appearance = "appearance_braincells",
        },
    },
})

// Explosive Headache
VACCINE_EXPLOHEADACHE = AddVaccine({
    name = "Explosive Headache",
    desc = "Causes a strong Headache which untreated can cause the patients head to explode.",
    price = 1000,
    isvirus = true,
    duration = 60,
    cure = {
        immunity_time = 1200,
        ondeath = true,
        price = 2000,
    },
    mat = "zerochain/zblood/wounds/zbl_wound_zombiemeat_diff",
    research = {
        vaccine_points = 40,
        vaccine_time = 215,
        cure_points = 25,
        cure_time = 250,
        ranks = {
            //["superadmin"] = true,
            //["vip"] = true,
        }
    },
    occopation = {
      time = 60,
      infection_chance = 50,
      infection_radius = 100,
    },
    contamination = {
        time = 300,
        chance = 60,
    },
    mutation_chance = 100,
    mutation_stages = {
        [1] = {
            effects = {
                ["jump_modify"] = 300,
                ["damage_fall_modify"] = 0
            },
            symptomes = {
                ["head_swelling"] = {scale = 1.5, damage = 0},
            },
            perception = "visual_headache_weak"
        },
        [2] = {
            effects = {
                ["jump_modify"] = 400,
                ["damage_fall_modify"] = 0
            },
            symptomes = {
                ["head_swelling"] = {scale = 2, damage = 0},
            },
            perception = "visual_headache_weak"
        },
        [3] = {
            effects = {
                ["jump_modify"] = 500,
                ["damage_fall_modify"] = 0
            },
            symptomes = {
                ["head_swelling"] = {scale = 2.5, damage = 0},
            },
            perception = "visual_headache_strong"
        },
        [4] = {
            effects = {
                ["jump_modify"] = 600,
                ["damage_fall_modify"] = 0
            },
            symptomes = {
                ["head_swelling"] = {scale = 3, damage = 0},
            },
            perception = "visual_headache_strong"
        },
        [5] = {
            symptomes = {
                ["explosive_head"] = {infect_distance = 300, infect_chance = 60},
            },
        },
    },
})

// Fire Resistance
VACCINE_FIRERESISTANCE = AddVaccine({
    name = "Fire Resistance",
    desc = "Makes the patient Immune against fire.",
    price = 1000,
    isvirus = false,
    duration = 60,
    cure = {
        immunity_time = 200,
        ondeath = true,
        price = 2000,
    },
    research = {
        vaccine_points = 10,
        vaccine_time = 100,
        cure_points = 20,
        cure_time = 100,
        ranks = {
            //["superadmin"] = true,
        }
    },
    mutation_chance = -1,
    mutation_stages = {
        [1] = {
            effects = {
                ["damage_fire_modify"] = 0,
            },
        },
    },
})

// Mobility Boost
VACCINE_MOBILITYBOOST = AddVaccine({
    name = "Mobility Boost",
    desc = "Increases the patients move speed.",
    price = 1000,
    isvirus = false,
    duration = 60,
    cure = {
        immunity_time = 200,
        ondeath = true,
        price = 2000,
    },
    research = {
        vaccine_points = 10,
        vaccine_time = 35,
        cure_points = 20,
        cure_time = 50,
        ranks = {
            //["superadmin"] = true,
        }
    },
    mutation_chance = -1,
    mutation_stages = {
        [1] = {
            effects = {
                ["movement_speed"] = 2,
            },
        },
    },
})

// Super Legs
VACCINE_SUPERLEGS = AddVaccine({
    name = "Super Legs",
    desc = "Increases the patients jump height.",
    price = 1000,
    isvirus = false,
    duration = 60,
    cure = {
        immunity_time = 200,
        ondeath = true,
        price = 2000,
    },
    research = {
        vaccine_points = 10,
        vaccine_time = 35,
        cure_points = 20,
        cure_time = 40,
        ranks = {
            //["superadmin"] = true,
        }
    },
    mutation_chance = -1,
    mutation_stages = {
        [1] = {
            effects = {
                ["damage_fall_modify"] = 0,
                ["jump_modify"] = 500,
            },

            symptomes = {
                ["legs_swelling"] = {scale = 1.75, damage = 0},
            },
        },
    },
})

// Invinsibility
VACCINE_INVINSIBILITY = AddVaccine({
    name = "Invincibility",
    desc = "Makes the player Immune against any damage.",
    price = 1000,
    isvirus = false,
    duration = 60,
    cure = {
        immunity_time = 200,
        ondeath = true,
        price = 2000,
    },
    research = {
        vaccine_points = 75,
        vaccine_time = 60,
        cure_points = 25,
        cure_time = 60,
        ranks = {
            //["superadmin"] = true,
            //["vip"] = true,
        }
    },
    mutation_chance = -1,
    mutation_stages = {
        [1] = {
            effects = {
                ["damage_modify"] = 0.05,
            },
            appearance = "appearance_armor",
        },
    },
})
