ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "SCP-610 Biomass"
ENT.Category = "SCP-RP Events"
ENT.Spawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "Integrity")
end
