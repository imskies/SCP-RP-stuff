/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

zbl = zbl or {}
zbl.config = zbl.config or {}

// Here you can define perception effects for the player which changes how the player sees and hears.
zbl.config.PerceptionEffects = {
    ["visual_distortion_weak"] = {

        // What audio filter should be applied? (Changes how the player hears ingame)
        //https://developer.valvesoftware.com/wiki/Dsp_presets
        //audio_filter = 15,

        // A diffuse material which get layered over the players screen
        //mat = "zerochain/zblood/screeneffects/zbl_scfx_braincells",

        // A refract material which get layered over the players screen
        //warp_mat = "zerochain/zblood/screeneffects/zbl_scfx_braincells_warp",

        // The Bloom Color
        bloom = {0, 0, 0.1},

        // The blur effect
        m_blur = 0.5,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

        // The DrawColorModify data
        colormodify = {
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

            ["pp_colour_addr"] = 0,
            ["pp_colour_addg"] = 0,
            ["pp_colour_addb"] = 0.05,

            ["pp_colour_brightness"] = 0,
            ["pp_colour_contrast"] = 1,
            ["pp_colour_colour"] = 0.8,

            ["pp_colour_mulr"] = 0,
            ["pp_colour_mulg"] = 0,
            ["pp_colour_mulb"] = 0.5
        }
    },
    ["visual_distortion_strong"] = {

        // What audio filter should be applied? (Changes how the player hears ingame)
        //https://developer.valvesoftware.com/wiki/Dsp_presets
        audio_filter = 15,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

        // A diffuse material which get layered over the players screen
        mat = "zerochain/zblood/screeneffects/zbl_scfx_zombiemeat",

        // A refract material which get layered over the players screen
        warp_mat = "zerochain/zblood/screeneffects/zbl_scfx_zombiemeat_warp",

        // The Bloom Color
        bloom = {0.125, 0.125, 1},

        // The blur effect
        m_blur = 1,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

        // The DrawColorModify data
        colormodify = {

            ["pp_colour_addr"] = 0.5,
            ["pp_colour_addg"] = 0.1,
            ["pp_colour_addb"] = 0.1,

            ["pp_colour_brightness"] = -0.4,
            ["pp_colour_contrast"] = 1,
            ["pp_colour_colour"] = 1,

            ["pp_colour_mulr"] = 0,
            ["pp_colour_mulg"] = 0,
            ["pp_colour_mulb"] = 0.0
        }
    },
    ["visual_distortion_mutant"] = {
        audio_filter = 15,
        mat = "zerochain/zblood/screeneffects/zbl_scfx_mutant",
        warp_mat = "zerochain/zblood/screeneffects/zbl_scfx_mutant_warp",
        bloom = {1, 0.125, 1},
        m_blur = 1,
        colormodify = {

            ["pp_colour_addr"] = 0.2,
            ["pp_colour_addg"] = 0.5,
            ["pp_colour_addb"] = 0.2,

            ["pp_colour_brightness"] = -0.6,
            ["pp_colour_contrast"] = 1,
            ["pp_colour_colour"] = 1,

            ["pp_colour_mulr"] = 0,
            ["pp_colour_mulg"] = 0,
            ["pp_colour_mulb"] = 0.0
        }
    },
    ["visual_blindness_weak"] = {
        m_blur = 0.5,
        b_blur = 50,
        colormodify = {

            ["pp_colour_addr"] = 0,
            ["pp_colour_addg"] = 0,
            ["pp_colour_addb"] = 0,

            ["pp_colour_brightness"] = 0.1,
            ["pp_colour_contrast"] = 1,
            ["pp_colour_colour"] = 0.8,

            ["pp_colour_mulr"] = 0,
            ["pp_colour_mulg"] = 0,
            ["pp_colour_mulb"] = 0
        }
    },
    ["visual_blindness_medium"] = {
        m_blur = 1,
        b_blur = 200,
        colormodify = {

            ["pp_colour_addr"] = 0,
            ["pp_colour_addg"] = 0,
            ["pp_colour_addb"] = 0,

            ["pp_colour_brightness"] = 0.5,
            ["pp_colour_contrast"] = 1,
            ["pp_colour_colour"] = 0.8,

            ["pp_colour_mulr"] = 0,
            ["pp_colour_mulg"] = 0,
            ["pp_colour_mulb"] = 0
        }
    },
    ["visual_blindness_strong"] = {
        m_blur = 1.2,
        b_blur = 500,
        colormodify = {

            ["pp_colour_addr"] = 0,
            ["pp_colour_addg"] = 0,
            ["pp_colour_addb"] = 0,

            ["pp_colour_brightness"] = 0.5,
            ["pp_colour_contrast"] = 1,
            ["pp_colour_colour"] = 0.8,

            ["pp_colour_mulr"] = 0,
            ["pp_colour_mulg"] = 0,
            ["pp_colour_mulb"] = 0
        }
    },
    ["visual_headache_weak"] = {
        m_blur = 0.5,
        b_blur = 55,
        warp_mat = "zerochain/zblood/screeneffects/zbl_scfx_headache_warp",
        colormodify = {

            ["pp_colour_addr"] = 0.3,
            ["pp_colour_addg"] = 0.1,
            ["pp_colour_addb"] = 0.1,

            ["pp_colour_brightness"] = -0.1,
            ["pp_colour_contrast"] = 1,
            ["pp_colour_colour"] = 1,

            ["pp_colour_mulr"] = 0,
            ["pp_colour_mulg"] = 0,
            ["pp_colour_mulb"] = 0.0
        }
    },
    ["visual_headache_strong"] = {
        m_blur = 1,
        b_blur = 75,
        warp_mat = "zerochain/zblood/screeneffects/zbl_scfx_headache_warp",
        colormodify = {

            ["pp_colour_addr"] = 0.4,
            ["pp_colour_addg"] = 0.1,
            ["pp_colour_addb"] = 0.1,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

            ["pp_colour_brightness"] = -0.1,
            ["pp_colour_contrast"] = 1,
            ["pp_colour_colour"] = 1,

            ["pp_colour_mulr"] = 0,
            ["pp_colour_mulg"] = 0,
            ["pp_colour_mulb"] = 0.0
        }
    },
    ["visual_sars_strong"] = {
        m_blur = 1,
        b_blur = 15,
        warp_mat = "zerochain/zblood/screeneffects/zbl_scfx_sars_warp",
        colormodify = {

            ["pp_colour_addr"] = 0.2,
            ["pp_colour_addg"] = 0.2,
            ["pp_colour_addb"] = 0.2,

            ["pp_colour_brightness"] = -0.3,
            ["pp_colour_contrast"] = 1,
            ["pp_colour_colour"] = 0.1,

            ["pp_colour_mulr"] = 0,
            ["pp_colour_mulg"] = 1,
            ["pp_colour_mulb"] = 1
        }
    },
    ["visual_covid_strong"] = {
        audio_filter = 15,
        mat = "zerochain/zblood/screeneffects/zbl_scfx_covid",
        warp_mat = "zerochain/zblood/screeneffects/zbl_scfx_braincells_warp",
        bloom = {1, 0.125, 0},
        m_blur = 1,
        colormodify = {

            ["pp_colour_addr"] = 0.3,
            ["pp_colour_addg"] = 0.1,
            ["pp_colour_addb"] = 0.1,

            ["pp_colour_brightness"] = -0.5,
            ["pp_colour_contrast"] = 0.9,
            ["pp_colour_colour"] = 0.1,

            ["pp_colour_mulr"] = 2,
            ["pp_colour_mulg"] = 0,
            ["pp_colour_mulb"] = 0.0
        }
    },
}

// Here you can define diffrent appearances for the player
zbl.config.AppearanceEffects = {
    ["appearance_rhizome"] = {

        // What wound material should be applied to the infected player?
        /*
            "zerochain/zblood/wounds/zbl_wound_braincells_diff",
            "zerochain/zblood/wounds/zbl_wound_flesh_diff",
            "zerochain/zblood/wounds/zbl_wound_mutant_diff",
            "zerochain/zblood/wounds/zbl_wound_rhizome_diff",
            "zerochain/zblood/wounds/zbl_wound_zombiemeat_diff",
        */
        MaterialOverlay = "zerochain/zblood/wounds/zbl_wound_rhizome_diff",

        // What wound color should be applied to the infected player?
        //ColorOverlay = Color(178,48,32),

        // What player model should be applied to the infected player?
        //PlayerModel = "models/player/charple.mdl"
    },
    ["appearance_braincells"] = {
        MaterialOverlay = "zerochain/zblood/wounds/zbl_wound_braincells_diff",
        ColorOverlay = Color(178,48,32),
        PlayerModel = "models/player/charple.mdl"
    },
    ["appearance_armor"] = {
        MaterialOverlay = "zerochain/zblood/misc/zbl_armored_diff",
    },
}
