ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Research Event Device"
ENT.Category = "SCP-RP Events"
ENT.Spawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "Progress")
    self:NetworkVar("String", 0, "DeviceLabel")
    self:NetworkVar("String", 1, "ActionLabel")
end
