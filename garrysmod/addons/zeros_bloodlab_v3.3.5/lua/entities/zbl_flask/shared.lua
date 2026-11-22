/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_bloodlab/zbl_flask.mdl"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PrintName = "Gen Flask"
ENT.Category = "Zeros GenLab"
ENT.RenderGroup = RENDERGROUP_BOTH
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

function ENT:SetupDataTables()
    // 0 = Empty
    // 1 = Sample - From a Player
    // 2 = Vaccine - Either a Virus or a Ability Boost
    // 3 = Cure - Cures the Player sickness

    self:NetworkVar("Int", 0, "GenType")
    self:NetworkVar("Int", 1, "GenValue")
    self:NetworkVar("String", 0, "GenName")
    self:NetworkVar("Int", 2, "GenPoints")
    self:NetworkVar("String", 1, "GenClass")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

    if (SERVER) then
        self:SetGenType(0)
        self:SetGenValue(0)
        self:SetGenName("")
        self:SetGenPoints(0)
        self:SetGenClass("")
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
