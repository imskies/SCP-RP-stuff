/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

include("shared.lua")

function ENT:Initialize()
	self.m_scale = -1
	self:DrawShadow(false)
	self.HasEffect = false
end

function ENT:DrawTranslucent()
	self:Draw()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

function ENT:Draw()
	self:DrawModel()
	zbl.util.UpdateEntityVisuals(self)


                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

	if zclib.util.InDistance(self:GetPos(), LocalPlayer():GetPos(), 1000) then
		if self.HasEffect == nil or self.HasEffect == false then

			// Check if virus node is straight up
			local up = self:GetAngles()
			if up then
				up = up:Up()
				if up.z > 0.9 and up.z < 1.1 then
					zclib.Effect.ParticleEffectAttach("zbl_infect_sporecloud",PATTACH_POINT_FOLLOW, self, 0)
				else
					zclib.Effect.ParticleEffectAttach("zbl_infect_sporecloud_walled",PATTACH_POINT_FOLLOW, self, 0)
				end
			end

			self.HasEffect = true
		end
	else
		if self.HasEffect == true then
			self:StopParticles()
			self.HasEffect = false
		end
	end

	if zclib.util.InDistance(self:GetPos(), LocalPlayer():GetPos(), 2000) then
		self:ScaleModel()
	end
end

function ENT:UpdateVisuals()
	self.m_scale = math.Clamp((zbl.config.VirusNodes.max_scale / zbl.config.VirusHotspots.node_health_max) * self:GetVHealth(), 0.5, zbl.config.VirusNodes.max_scale)
	self:SetModelScale(self.m_scale, 0)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

function ENT:ScaleModel()
	local current_Scale = math.Clamp(self.m_scale, 0.5, zbl.config.VirusNodes.max_scale)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

	local goal = math.Clamp((zbl.config.VirusNodes.max_scale / zbl.config.VirusHotspots.node_health_max) * self:GetVHealth(), 0.5, zbl.config.VirusNodes.max_scale)

	if current_Scale < goal then
		current_Scale = current_Scale + 0.5 * FrameTime()
	elseif current_Scale > goal then
		current_Scale = current_Scale - 0.5 * FrameTime()
	end

	self.m_scale = math.Clamp(current_Scale, 0.3, zbl.config.VirusNodes.max_scale)
	self:SetModelScale(self.m_scale, 0)
end

function ENT:OnRemove()
	self:StopParticles()
end
