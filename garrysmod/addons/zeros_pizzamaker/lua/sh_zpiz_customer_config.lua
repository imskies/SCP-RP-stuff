/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

zpiz = zpiz or {}
zpiz.config = zpiz.config or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

zpiz.config.Customer = {
    // How much does the player gets payed if he delivers a burned pizza
    BurnedPizzaPenalty = 0.2, //20%

    // The Interval at which new customers get spawned
    RespawnRate = 2,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- fde1005ae952a630057a2cc575fe1335e7c9809985c0483424501baa23d5a1ad

    // How many Customers can one Player have at once
    Limit = 3,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 02d4e064402d16696deab5b093c9a34ae7a407e6165a08b9f87e1e597f153041

    // Time in seconds we add to the bake time of the pizza for the Customer do wait.
    ExtraWaitTime = 100
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ee71cdadb4c1697a1f320cfc75c78c5f0135879a492afb53058e82fcefbc72f0


// Customers
///////////////////////
// Some Data for our customers
zpiz.config.Customers = {
    [1] = {
        Model = "models/Humans/Group01/male_07.mdl", // The Customer Model
        SitAnim = {"silo_sit"}, // The Customer Sit Animations
        ServAnim = {"cheer1", "cheer2"} // The Customer gets Pizza Animations
    },
    [2] = {
        Model = "models/Humans/Group01/male_08.mdl",
        SitAnim = {"sitchair1", "silo_sit"},
        ServAnim = {"cheer1", "cheer2"}
    },
    [3] = {
        Model = "models/Humans/Group01/male_09.mdl",
        SitAnim = {"silo_sit"},
        ServAnim = {"cheer1", "cheer2"}
    },
    [4] = {
        Model = "models/Humans/Group01/Female_01.mdl",
        SitAnim = {"sitchair1", "silo_sit"},
        ServAnim = {"cheer1", "heal"}
    },
    [5] = {
        Model = "models/Humans/Group01/Female_02.mdl",
        SitAnim = {"sitchair1", "silo_sit"},
        ServAnim = {"cheer1", "heal"}
    },
    [6] = {
        Model = "models/Humans/Group01/Female_03.mdl",
        SitAnim = {"sitchair1", "silo_sit"},
        ServAnim = {"cheer1", "heal"}
    },
    [7] = {
        Model = "models/Humans/Group01/Male_01.mdl",
        SitAnim = {"silo_sit"},
        ServAnim = {"cheer1", "cheer2"}
    },
    [8] = {
        Model = "models/alyx.mdl",
        SitAnim = {"d1_t03_sit_bed"},
        ServAnim = {"cheer1", "heal"}
    },
    [9] = {
        Model = "models/gman_high.mdl",
        SitAnim = {"silo_sit"},
        ServAnim = {"tiefidget", "lintpick"}
    },
    [10] = {
        Model = "models/Kleiner.mdl",
        SitAnim = {"silo_sit"},
        ServAnim = {"heal"}
    }
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968
