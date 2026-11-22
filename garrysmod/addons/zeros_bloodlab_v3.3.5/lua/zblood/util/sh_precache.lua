/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

AddCSLuaFile()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

game.AddParticles("particles/zbl_effects.pcf")
PrecacheParticleSystem("zbl_cough_infect")
PrecacheParticleSystem("zbl_dna")
PrecacheParticleSystem("zbl_vomit_explosion")
PrecacheParticleSystem("zbl_vomit_trail")
PrecacheParticleSystem("zbl_diaria_explosion")
PrecacheParticleSystem("zbl_diaria_spot")
PrecacheParticleSystem("zbl_explode_head")
PrecacheParticleSystem("zbl_infect_sporecloud")
PrecacheParticleSystem("zbl_infect_sporecloud_walled")
PrecacheParticleSystem("zbl_disinfect")
PrecacheParticleSystem("zbl_infect_nodeexplode")
PrecacheParticleSystem("zbl_jar_explode_blue")
PrecacheParticleSystem("zbl_jar_explode_green")
PrecacheParticleSystem("zbl_jar_explode_yellow")
PrecacheParticleSystem("zbl_jar_explode_blood")
PrecacheParticleSystem("zbl_scan")
PrecacheParticleSystem("zbl_scan_small")
PrecacheParticleSystem("zbl_scan_effect01")
PrecacheParticleSystem("zbl_scan_effect02")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

util.PrecacheModel("models/zerochain/props_bloodlab/zbl_n95mask_worn.mdl")
util.PrecacheModel("models/zerochain/props_bloodlab/zbl_fence.mdl")

for k, v in pairs(zbl.config.Respirator.styles) do
    util.PrecacheModel(v.model)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10
