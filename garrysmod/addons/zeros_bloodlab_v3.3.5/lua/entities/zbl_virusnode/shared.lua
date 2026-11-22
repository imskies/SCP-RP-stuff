/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model =  "models/zerochain/props_bloodlab/zbl_virusknot.mdl"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PrintName = "Virus Node"
ENT.Category = "Zeros GenLab"
ENT.RenderGroup = RENDERGROUP_OPAQUE
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

function ENT:SetupDataTables()
    self:NetworkVar("Int", 1, "VHealth")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

    if (SERVER) then
        self:SetVHealth(zbl.config.VirusHotspots.node_health_default)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
