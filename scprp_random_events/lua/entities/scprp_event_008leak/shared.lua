ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Ruptured SCP-008 Canister"
ENT.Category = "SCP-RP Events"
ENT.Spawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "Neutralization")
end
