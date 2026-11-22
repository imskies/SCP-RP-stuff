/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

zbl = zbl or {}
zbl.config = zbl.config or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

/////////////////////////////////////////////////////////////////////////////

// Bought by 76561199022046337
// Version v3.3.5


///////////////////////////// Zeros GenLab //////////////////////////////////

// Developed by ZeroChain:
// http://steamcommunity.com/id/zerochain/
// https://www.gmodstore.com/users/view/76561198013322242
// https://www.artstation.com/zerochain

/////////////////////////////////////////////////////////////////////////////

///////////////////////// zclib Config //////////////////////////////////////
/*
	This config can be used to overwrite the main config of zeros libary
*/
//zclib.config.Debug = true

/*
// The Currency
zclib.config.Currency = "$"

// Should the Currency symbol be in front or after the money value?
zclib.config.CurrencyInvert = true

// These Ranks are admins
// If xAdmin, sAdmin or SAM is installed then this table can be ignored
zclib.config.AdminRanks = {
	["owner"] = true,
	["superadmin"] = true,
	["Super Admin"] = true,
}

zclib.config.CleanUp.SkipOnTeamChange[TEAM_STAFF] = true
*/
/////////////////////////////////////////////////////////////////////////////

/*

    Tool Gun:
        HotSpot Spawner - Spawns / Removes / Saves Virus Hotspots

    Console Commands:
        zbl_debug_VHS_AddPos - Adds a new position for a VirusHotSpot to grow at where you looking
        zbl_debug_VHS_SavePos - Saves all the HotSpot positions for the current map
        zbl_debug_VHS_RemovePos - Removes all the HotSpot positions for the current map

    For more debug console commands look at zeros_bloodlab\lua\zblood\sh\zbl_debug.lua

    Chat Commands:
        !zbl_save - Saves all the NPCs and VirusHotSpots for the Map (Admin Only)
        !dropmask - Drops the current Respirator if the player has any equipt

    Functions:
        zbl.DNASystem.AddPoints(ply,points) - Gives the specified Player the specified amount of DNA Points
        zbl.DNASystem.RemovePoints(ply,points) - Removes the specified Player the specified amount of DNA Points
*/

/*
	Switches between FastDl and Workshop
*/
zbl.config.FastDl = false

/*
	The language , en , de , fr , cn , ru , pl , ptbr , tr , es
*/
zbl.config.SelectedLanguage = "en"

/*
	If set to true then the inflictor of the coughing / self damage will be the player himself, otherwhise it will be the world entity.
*/
zbl.config.DamageInflictorSelf = false

/*
	This will stop players getting infected which are behind walls
	Since this uses a trace per player it will have more of a impact on the server performance
*/
zbl.config.PreciseInfection = {

    // If set to true then we check if the path between infection EPI-Center and player is free from any obstruction
    enabled = true,

    // What can be used as cover from infections?
    mask = 81931

    //https://wiki.facepunch.com/gmod/Enums/MASK
    // 4294967295 = MASK_ALL > Anything that is not empty space
    // 81931 = MASK_PLAYERSOLID_BRUSHONLY > World + Brushes + Player Clips
}

/*
	Those Jobs can use the Lab entities and sell to the npcs
*/
zbl.config.Jobs = {}
if TEAM_ZBL_RESEARCHER then zbl.config.Jobs[TEAM_ZBL_RESEARCHER] = true end

/*
	DNA Points can be used inside the lab to create new virus / vaccines
*/
zbl.config.DNA = {
	// Can the player drop his DNA Points using > !dropdna amount
    CanDrop = true,
}

/*
	Requires McPhone https://www.gmodstore.com/market/view/mcphone-advanced-phone-system-1
	The McPhone App can be used to tell the player if there are infected player or objects near by
	It also shows him if he currently is wearing a respirator
*/
zbl.config.McPhone = {
    scan_radius = 750,
    scan_duration = 1,
}

/*
	Report sign displays what virus is how often and in what form present in the world.
*/
zbl.config.Sign = {
    // How often do we update the statistic on the sign
    UpdateInterval = 30, // seconds
}

/*
	The Fence entity can be used to cut of certain parts of the city, it also scans any person which goes through the gate
*/
zbl.config.Fence = {
    // Can the fence be unfolded?
    unfold = true,

    // Does the fence have a door which can be opend / closed?
    door = true,

	// If set to true then the buttons will only show up on one side.
	onesideonly = false,

    LockPick = {
        // Can the fence gate be lockpicked?
        Enabled = true,

        // These Police jobs get informed if a player Lockpicks the fence
        // Leaving this empty means that Players can Lockpick fence entities even if no Police Job is on the Server.
        Police = {
            // [TEAM_POLICE] = true,
        },

        // What should get deactivated once the fence gate got lockpicked
        OnSuccess = {
            Door = true,
            Fence = true
        },

        // How long does it take to lockpick a fence
        Time = 5,

        // The Wanted Message
        Wanted_Message = "Lockpicked a Electric Fence!",

        // How long will the player be wanted?
        Wanted_Time = 120,
    },

    // Should we restrict the unfold action to certain player ranks? (Leave empty to allow any rank to unfold it)
    ranks = {
        //["vip"] = true,
    },

    // This is the max lenght the unfolded fence can have
    length = 1000,

    // How much damage does the player get if he touches the fence
    dmg_per_touch = 10,

    // Since vehicles cant collide with the custom generated physics mesh of the fence, should we kill the driver if he drives throug the fence?
    kill_driver = true,

    // How much damaged needs to be inflicted on the fence before he gets destroyed? (Set to -1 to disable the fence getting damaged)
    health = 1000,

    // Should we punish the player if he constantly goes through the scanner?
    AntiSpam = true,

    // Should we decontaminate the player if he has a occopating virus?
    contaminate = true,
}

/*
	Corpses get created when a player dies while being infected
*/
zbl.config.Corpse = {

    // Do we want corpses to get created when a player dies while being infected
    enabled = true,

    // How long till the corpse gets removed
    life_time = 60,

    // Should the virus material be visible on the corpse?
    infection_visible = true,

    // Should the corpse explode when it despawns, this will infect anyone near it
    ExplodeOnDespawn = true,

    // One of those animations will be used for the corpse
    anim = {"zombie_slump_idle_01"}
}

/*
	Here you can add custom protection checks against viruses
	Return a value between 0 - 100 , 0 = Not protected at all, 100 = Fully Protected
	This check goes both ways so if a player is infected but is protected by a respirator then the chance of him infecting other people is low aswell.
	This check doesent work if someone injects you with a virus
*/
zbl.config.ProtectionCheck = function(ply,vac_id,vac_stage)

    local chance = 0

    // If the Protection chance is higher or equal 100 then it prevents the player from picking up respirators

    // A Hazmat Suit, nothing goes in or out
    if ply:GetModel() == "models/zerochain/props_bloodlab/zbl_hazmat.mdl" then
        chance = 100
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

    // Technicly this model is wearing a respirator so he is fully protected from virus spores
    elseif ply:GetModel() == "models/player/police.mdl" then
        chance = 100

    // Does the player wear a respirator
    elseif zbl.GasMask.Has(ply) then

        // This should NEVER be higher then 99
        chance = 80
    end

    return chance
end

/*
	Protects the player with style :D
*/
zbl.config.Respirator = {
    // How often can the respirator be used before it gets used up and removed
    // The Repsirator gets used when protecting against viruses
    Uses = 15,

    // Should the player get a random respirator style assigned when opening a respirator box
    random_style = true,

    // If random_style = false then we can define which respirator style people gonna wear
    style = -1,

	// If set to true then we dont render the respirator models
	nodraw = false,

    // Here we define the styles
    styles = {
        // n95 Mask
        [1] = {
            // Model
            model = "models/zerochain/props_bloodlab/zbl_n95mask.mdl",
            // Skin
            skin = 0,
            // How often can this respirator be used before it gets removed, If not specified then this style will use the default use amount defined above
            use = 25,
        },

        // Blank Mask
        [2] = { model = "models/zerochain/props_bloodlab/zbl_mask.mdl", skin = 0},

        // Beard01
        [3] = { model = "models/zerochain/props_bloodlab/zbl_mask.mdl", skin = 1},

        // Beard02
        [4] = { model = "models/zerochain/props_bloodlab/zbl_mask.mdl", skin = 2},

        // Blushsmile
        [5] = { model = "models/zerochain/props_bloodlab/zbl_mask.mdl", skin = 3},

        // Cat
        [6] = {model = "models/zerochain/props_bloodlab/zbl_mask.mdl", skin = 4},

        // Kawai
        [7] = {model = "models/zerochain/props_bloodlab/zbl_mask.mdl", skin = 5},

        // Kiss
        [8] = {model = "models/zerochain/props_bloodlab/zbl_mask.mdl", skin = 6},

        // Panda
        [9] = {model = "models/zerochain/props_bloodlab/zbl_mask.mdl", skin = 7},

        // Smile
        [10] = {model = "models/zerochain/props_bloodlab/zbl_mask.mdl", skin = 8},

        // Vampire
        [11] = {model = "models/zerochain/props_bloodlab/zbl_mask.mdl", skin = 9},

        // Zipper
        [12] = {model = "models/zerochain/props_bloodlab/zbl_mask.mdl", skin = 10},
    }
}

/*
	Disinfectant Spray is used to decontaminate objects/players and fight virus nodes
*/
zbl.config.DisinfectantSpray = {
    // How much liquid does the spray have?
    Amount = 70,

    // How much liquid get used per click
    UsagePerClick = 1,

    // How much damage gets inflicted on the virus node if you spray on him
    VirusNode_Damage = 10,

    // How long will a object be clear from any virus contamination, Set to -1 to disable it
    Clear_Time = 300, // seconds
}

/*
	The Injector gun is used to inject/extract liquid from players and entities
*/
zbl.config.InjectorGun = {

    //https://wiki.facepunch.com/gmod/Enums/KEY
    Keys = {
        // Open Help menu
        Help = KEY_H,

        // Injects the selected vaccine in to yourself
        SelfInject = KEY_B,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

        // Emptys the gun of any substance
        EmptyFlask = KEY_DELETE,

        // Switches to the next flask
        SwitchFlask = KEY_R,

        // Extracts the substance of the gun in to a flask and drops it
        ExtractFlask = MOUSE_MIDDLE,

        // Scan the area arround you
        ScanArea = KEY_T,
    },

    // This defines how many chambers the gun has
    // Should not be smaller then 3 or bigger then 12
    // This also defines how many flasks the player can drop on the floor
    flask_capacity = {
        ["default"] = 6,
        ["vip"] = 8,
        ["superadmin"] = 12,
    },

    // The scan can be used to detect infected objects/players
    Scan = {

        // How long will the scanned objects show their infection status
        duration = 3,

        // The scan radius arround the player
        radius = 500,

        // How long does the player need to wait before he can scan again
        interval = {
            ["default"] = 3,
            ["vip"] = 2,
            ["superadmin"] = 0.1,
        },

        // Should we display what virus has infected the scanned object/player and at which stage it is
        show_info = true
    }
}

/*
	The flask entity is a storage container for DNA Samples, Viruses, Cures and Abillity Boosts
*/
zbl.config.Flask = {
    // Can it be destroyed?
    Breakable = true,

    // How fast does the flask have to be on colliion in order to break?
    Break_speed = 400,

    // Should the flask infect/cure players in proximity with the vaccine it holds?
    InfectOnDestruction = true,

    // How close does a player needs to be in order to get infected?
    Infect_Radius = 200,

    // Should the flask create virus nodes on destruction if the liquid is a virus
    // It will only create virus nodes if it finds a valid position
    NodeOnDestruction = true,
}

/*
	Here we can define which entities can be used to get DNA samples from
*/
zbl.config.SampleTypes = {
    // Entity Class
    ["player"] = {
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

        // How many DNA points do we get when analyzing this sample
        dna_points = 5,

        // This defines the name of the sample
        name = function(ent)

            if zbl.Player.IsInfected(ent) then
                return zclib.Player.GetName(ent) .. " (Infected)"
            else
                return zclib.Player.GetName(ent)
            end
        end,

        // This can be used to modify DNA points generated from this sample
        // ply = Swep Owner , ent = Target , points = dna_points
        points_modify = function(ply,ent,points)

            // If the (blood) sample is from a infected player then we get double the DNA points
            if zbl.Player.IsInfected(ent) then
                points = points * 2
            end
            return points
        end,

        // How do samples of this type differentiate? (Needs to be a int)
        identifier = function(ent)
            return ent:AccountID()
        end,

        // This will be called on the entity we are harvesting the sample from
        OnCollect = function(ply,ent)

            // Damage the Player we are collecting the sample from
            local d = DamageInfo()
            d:SetDamage( 5 )
            d:SetAttacker( ply )
            d:SetDamageType( DMG_SLASH )
            ent:TakeDamageInfo( d )

            zbl.Player.HurtSound(ent)
        end,
    },
    ["zbl_virusnode"] = {
        dna_points = 3,
        name = function(ent)
            return zbl.Vaccine.GetName(ent.Virus_ID)
        end,
        points_modify = function(ply,ent,points)

            // Lets output the dangerfactor of the virus a DNA Points
            // The more Dangerous the virus is , the more DNA Points it gives
            local virusID = ent:GetNWInt("zbl_Vaccine", 1)
            if zbl.config.Vaccines[virusID] then
                points = zbl.config.Vaccines[virusID].dangerfactor
            end

            return points
        end,
        identifier = function(ent)
            return ent.Virus_ID
        end,
        OnCollect = function(ply,ent)
            zbl.Node.TakeDamage(ent,50,ply)
        end,
    },
    ["npc_headcrab"] = {
        dna_points = 10,
        name = function(ent)
            return ent:GetClass()
        end,
        points_modify = function(ply,ent,points)
            return points
        end,
        identifier = function(ent)
            // Creates a unique id using the entities model path
            return zclib.util.StringToUniqueID(ent:GetModel())
        end,
        OnCollect = function(ply,ent)
            ent:TakeDamage( ent:Health(), ply, ply:GetActiveWeapon() )
        end,
    },
    ["zbl_corpse"] = {
        dna_points = 10,
        name = function(ent)
            return ent:GetPlayerName()
        end,
        points_modify = function(ply,ent,points)
            return points
        end,
        identifier = function(ent)
            return ent:GetPlayerID()
        end,
        OnCollect = function(ply,ent)
            SafeRemoveEntity(ent)
        end,
    },
    ["contaminated_objects"] = {
        dna_points = 5,
        name = function(ent)
            return zbl.Vaccine.GetName(ent:GetNWInt("zbl_Vaccine",1))
        end,
        points_modify = function(ply,ent,points)
            return points
        end,
        identifier = function(ent)
            return ent:GetNWInt("zbl_Vaccine",1)
        end,
        OnCollect = function(ply,ent)
        end,
    },
}

/*
	The GenLab is used to create DNA Points from Samples and create Vaccines/Viruses from DNA Points
*/
zbl.config.GenLab = {

    // How many dna points will the lab entity have once it spawns. (This value will be overwriten for private labs if save data from the player is found)
    start_points = 25,

    // How long does it take to analyze one sample
    time_per_sample = 25, // seconds

    // Once a sample got used on the lab , how long does the player need to wait til the same sample gives full points again
    sample_cooldown = 300, // seconds

    // How much value does a sample has which was previous researched in this lab, aka a sample with a cooldown
    cooldown_penalty = 0.1, // 0 - 1

    // How much value does a sample has which is multiple times in the lab
    duplicate_penalty = 0, // 0 - 1

    // Changes the analyze/create speed according to what rank the player has
    // 1 = NoChange, 2 = Double duration , 0.5 = Half duration
    time_modify = {
        // Dont remove the default value
        ["default"] = 1,
        ["vip"] = 0.9,
        ["superadmin"] = 0.5,
    },

    Data = {
        // Should the DNA Points be saved on the server?
        // This only applys to private lab entities
        Save = true,

        // How often should we auto save the data of players. Set to -1 to disable the autosave.
        // The data will also get saved when the player disconnects from the Server so the autosave is just a safety measure.
        Save_Interval = 600,

        // If specified then only data for Players with these Ranks get saved. Leave empty to save the data for every player.
        Whitelist = {
            /*
            ["superadmin"] = true,
            ["vip"] = true
            */
        }
    }
}

/*
	Here you can define what objects can be contaminated with a virus
*/
zbl.config.Contamination = {

    // Should objects get contaminated when used by a infected player?
    enabled = true,

    // If set to true then the contaminated objects will have the virus material applied which makes it easier to identify them
    // Setting this to false means only the scan function of the injector gun will show if entities/players are infected
    visible = true,

    // Those entities can be contaminated with a virus
    // Only entities which can be interacted via USE can be used
    ents = {
        ["func_door"] = true,
        ["func_door_rotating"] = true,
        ["prop_door_rotating"] = true,
        ["prop_vehicle_jeep"] = true,
        ["money_printer"] = true,
        ["func_button"] = true,
        ["prop_vehicle_prisoner_pod"] = true,
        ["darkrp_tip_jar"] = true,
        ["spawned_shipment"] = true,
        ["spawned_weapon"] = true,
        ["spawned_money"] = true,
        ["spawned_food"] = true,
        ["spawned_ammo"] = true,
        ["gunlab"] = true,
        ["gmod_button"] = true,
        ["keypad"] = true,
        ["keypad_wire"] = true,
    },

    // Here you can limit how many objects can be contaminated at once
    limit = 50,

    // Can the contamination be collected? This gives the player a sample of the virus
    collectable = true,

    // This system automaticly contaminates a object on the server which matches the entity class above
    AutoContaminate = {

        enabled = false,

        // How often should we try to contaminate a object
        interval = 60, // seconds

        // Should Objects which gets used a lot be prioritised when choosing what entity to contaminate?
        // Setting this to true will reduce the list of possible contaminated entities from all to only those which got touched since the last interval.
        HeavyUsePriority = true,

        // Defines which virus should be used
        virus_chance = {
            [VACCINE_COLD] = 50, // %
            [VACCINE_SARS] = 10,
            [VACCINE_COVID] = 10,
            [VACCINE_EYECANCER] = 10,
            [VACCINE_EBOLA] = 10,
            [VACCINE_EXPLOHEADACHE] = 10,
        },
    }
}

/*
	This system creates a virus outbreak on predefind locations and grows over time.
	There can only be one active virus hotspot at a time, if the master node dies then the system will search for a new area to setup a new hotspot but any virusnode still alive will stay
*/
zbl.config.VirusHotspots = {

    // Should we create virus outbreaks on predefind locations?
    enabled = true,

    // Should the virus hotspots grow only if one of the players has one of those jobs zbl.config.Jobs
    GrowOnJobOnly = false,

    // The growth interval in seconds
    // Keep in mind that finding grow positions for the nodes according to the world geometry is a expensive progress, short interval = more expensive
    growth_interval = 60,

    // Here you can define spawn chances for diffrent virus ids
    // The higher the percentage, the higher the chance of this virus getting used for the virus hotspot
    virus_chance = {
        [VACCINE_COLD] = 50, // %
        [VACCINE_SARS] = 10,
        [VACCINE_COVID] = 10,
        [VACCINE_EYECANCER] = 10,
        [VACCINE_EBOLA] = 10,
        [VACCINE_EXPLOHEADACHE] = 10,
    },

    // How many core nodes are allowed to exist at the same time (Setting this too high will impact the Performance a lot)
    core_limit = 3,

    // How many virus nodes (entities) is a core node allowed to create?
    node_limit = 15,

    // Can virus nodes be damaged with normal weapons?
    node_damage = true,

    // Default health of a node
    node_health_default = 100,

    // How much health can a virus node have total
    node_health_max = 200,

    // How much health does a virus node gain over time.
    node_health_increment = 10,

    // If a node has more then this amount of health then it can spread to a new location
    node_health_spread = 50,

    // The Cache will store node positions and save them for the map to use them again if needed before generating new ones
    cache = {
        // Shoud we save valid node positions on the map to be used again before generating new one
        enabled = true,

        // How many positions are allowed to be stored
        limit = 500,
    }
}

/*
	Virus nodes can spawn randomly arround the map or get created when a infected player dies
	A virus node stores the virus data in it and can be harvested to generate new DNA points in the lab.
	It also explodes and infects everyone near it if you touch it!
*/
zbl.config.VirusNodes = {

    // How long does a virus node exist before it gets removed
    // This is the default value but can be overriden in the Vaccine Config
    // This only affects virus nodes created by exploding flasks and doesent affect virus nodes created by virus hotspots
    life_time = 5000,

    // Defines the maximal model scale of a virus node if it reaches max health
    max_scale = 3,

    // Should the virus node explode on touch?
    KillOnTouch = false
}

/*
	The NPC buys your Viruses/Cures/Abillity Boosts and also has quests for you
*/
zbl.config.NPC = {

    // Name of the npc
    name = "Kane - Genetic Engineer",

    // Color of the NPC/Interface
    SkinColor = Color(190,58,64,255),

    // How long till the player can do another quest / a new quest gets offered
    quest_cooldown = 300,
}

/*
	The Stationary Medical Unit (SMU) scans for infections nearby and highlights them, it also provides vaccines
	NOTE Players can buy and sell vaccines here
*/
zbl.config.StationaryMedicalUnit = {

	// Should the machine scan for infections?
	Scan = {
		enabled = true,

		// How far does the machine scan
		radius = 300,

		// How often should the machine scan for infection
		default_interval = 10,

		// How often should we scan if we found a infected entity
		threat_interval = 1,

		// How long will the scan be visible
		duration = 3,
	},

	// Should the unit automaticly refill its vaccine storage
	// NOTE Set to -1 to disable
	AutoRefillInterval = 600,

	// Can be used to modify the sell price for the vaccines (How much money the player gets when selling to the machine)
	// NOTE 1 = OriginalVaccinePrice, 2 = DoublePrice, 0.5 = HalfPrice
	sell_mod = 1,

	// Can be used to modify the buy price for the vaccines (How much players have to pay)
	// NOTE 1 = OriginalVaccinePrice, 2 = DoublePrice, 0.5 = HalfPrice
	buy_mod = 1.5,

}
