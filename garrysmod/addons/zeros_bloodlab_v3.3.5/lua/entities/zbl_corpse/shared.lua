/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model =  "models/hunter/blocks/cube2x2x1.mdl"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PrintName = "Dummy"
ENT.Category = "Zeros GenLab"
ENT.RenderGroup = RENDERGROUP_BOTH
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

function ENT:SetupDataTables()
    self:NetworkVar("Int", 2, "PlayerID")
    self:NetworkVar("String", 0, "PlayerName")

    if (SERVER) then
        self:SetPlayerID(-1)
        self:SetPlayerName("")
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10
