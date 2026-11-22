/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

include("shared.lua")

function ENT:Initialize()
	zbl.Lab.Initialize(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360
	
	zbl.Labs[self:EntIndex()] = self
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

function ENT:OnRemove()
	zbl.Lab.OnRemove(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

function ENT:Think()
	zbl.Lab.Think(self)
	self:SetNextClientThink(CurTime())
	return true
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

function ENT:UpdateVisuals()
	zbl.Lab.UpdateVisuals(self)
end
