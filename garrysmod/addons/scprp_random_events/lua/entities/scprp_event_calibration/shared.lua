ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Containment Calibration Station"
ENT.Category = "SCP-RP Events"
ENT.Spawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "Progress")
    self:NetworkVar("Int", 0, "Stage")
end
