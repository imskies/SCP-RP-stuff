/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

zbl = zbl or {}
zbl.config = zbl.config or {}
zbl.config.NPC = zbl.config.NPC or {}

// Create the table
zbl.config.NPC.quests = {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

// Bring 3  unique blood samples (collected from 3 diffrent players) to the npc
zbl.Quest.CreateConfig({
    // The Type of Quest
    q_type = ZBL_SUPPLY_UNIQUE_PLAYER_SAMPLES,

    // The Name of the Quest
    name = "Blood Thief",
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

    // The Description of the Quest
    desc = "I need you to get me 3 unique blood samples.",

    // Count of items
    count = 3,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

    // Money Reward
    money_reward = 5000,

    // DNA Points Reward (Remove this if you dont want to give the player DNA Points)
    dna_reward = 20,

    // Quest Time
    time = 1000,
})

// Bring 3 samples of the specified virus (which were harvested from a virus node) to the npc
zbl.Quest.CreateConfig({
    q_type = ZBL_SUPPLY_VIRUS_SAMPLES,
    name = "Virus Sample Delivery",
    desc = "I need you to get me 3 samples from the Cold virus.",
    virus_id = VACCINE_COLD,
    sample_class = "zbl_virusnode",
    count = 3,
    money_reward = 4000,
    dna_reward = 10,
    time = 1000,
})



// Bring 1 fire resistance vaccine to the npc
zbl.Quest.CreateConfig({
    q_type = ZBL_SUPPLY_VACCINE,
    name = "Vaccine Delivery",
    desc = "I need you to get me 1 Fire Resistance vaccine.",
    virus_id = VACCINE_FIRERESISTANCE,
    count = 1,
    money_reward = 3000,
    dna_reward = 10,
    time = 1000
})

// Bring 3 Cold Cures to the npc
zbl.Quest.CreateConfig({
    q_type = ZBL_SUPPLY_CURE,
    name = "Cure Delivery",
    desc = "I need you to get me 3 Cold cures.",
    virus_id = VACCINE_COLD,
    count = 3,
    money_reward = 8000,
    time = 1000
})

// Bring 2 Sars Cures to the npc
zbl.Quest.CreateConfig({
    q_type = ZBL_SUPPLY_CURE,
    name = "Cure Delivery",
    desc = "I need you to get me 2 SARS cures.",
    virus_id = VACCINE_SARS,
    count = 2,
    money_reward = 8000,
    dna_reward = 10,
    time = 1000
})


                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

/*
This only is usefull if you have headcrabs on the server
// Bring 3 samples from a headcrab to the npc
zbl.Quest.CreateConfig({
    q_type = ZBL_SUPPLY_SAMPLES,
    name = "Sample Delivery",
    desc = "I need you to get me 3 samples from a Headcrab.",
    virus_id = nil,
    sample_class = "npc_headcrab",
    count = 3,
    money_reward = 5000,
    time = 1000
})
*/
