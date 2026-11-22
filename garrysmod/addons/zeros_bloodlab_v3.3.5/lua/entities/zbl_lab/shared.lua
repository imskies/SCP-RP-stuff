/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_bloodlab/zbl_lab.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Gen Lab"
ENT.Category = "Zeros GenLab"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()

    // What vaccine is selected for research
    self:NetworkVar("Int", 1, "SelectedVaccine")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

    // How many bloodsamples are inside the lab
    self:NetworkVar("Int", 2, "SampleCount")

    // How many diffrent bloodsamples are inside the lab
    self:NetworkVar("Int", 3, "SampleVariability")

    // What state is the lab currently in
    self:NetworkVar("Int", 4, "ActionState")
    /*
        0 = Idle
        1 = Analyzing Blood
        2 = Making Vaccine
        3 = Making Cure
    */


    // Used to tell the clients when the progress is finished
    self:NetworkVar("Int", 5, "ProgressEnd")

    self:NetworkVar("Int", 6, "ProgressDuration")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

    // This is the amount of DNA Points the player gets after all the samples got analyzed
    self:NetworkVar("Int", 7, "Reward")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

    // This will be a string of DNA Point values
    // This will never be longer then 12 values because we only have 12 flasks room
    self:NetworkVar("String", 0, "SampleSequence")

    self:NetworkVar("Bool", 0, "IsPublicEntity")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24


                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

    if (SERVER) then
        self:SetIsPublicEntity(false)

        self:SetSelectedVaccine(1)

        self:SetSampleCount(0)

        self:SetSampleVariability(0)

        self:SetActionState(0)

        self:SetProgressEnd(-1)
        self:SetProgressDuration(-1)

        self:SetReward(0)

        self:SetSampleSequence("")
    end
end
