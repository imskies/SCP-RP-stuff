/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_bloodlab/zbl_medicalunit.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Stationary Medical Unit"
ENT.Category = "Zeros GenLab"
ENT.RenderGroup = RENDERGROUP_OPAQUE
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

function ENT:SetupDataTables()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

	self:NetworkVar("Bool", 3, "ThreatDetected")

	self:NetworkVar("Int", 0, "ScannedOjbects")
	self:NetworkVar("Int", 1, "FoundInfections")
	self:NetworkVar("Int", 2, "SoldVaccines")
	self:NetworkVar("Int", 3, "BoughtVaccines")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

    if (SERVER) then
		self:SetThreatDetected(false)

		self:SetScannedOjbects(0)
		self:SetFoundInfections(0)
		self:SetSoldVaccines(0)
		self:SetBoughtVaccines(0)
    end
end
