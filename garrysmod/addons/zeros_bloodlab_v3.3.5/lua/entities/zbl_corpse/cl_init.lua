/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

function ENT:Initialize()
end

function ENT:DrawTranslucent()
	self:Draw()
end

local vec01 = Vector(1, 1, 1)
function ENT:Draw()
	self:DrawModel()

	if zbl.config.Corpse.ExplodeOnDespawn then
		local time = (self:GetCreationTime() + zbl.config.Corpse.life_time) - CurTime()
		local prc = (1 / zbl.config.Corpse.life_time) * time
		self:SetColor(zclib.util.LerpColor(prc, color_black, color_white))
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

		if zclib.Convar.Get("zbl_cl_corpsebloat") == 1 then
			local scale = (1 / zbl.config.Corpse.life_time) * math.Clamp(zbl.config.Corpse.life_time - time, 0, zbl.config.Corpse.life_time)
			scale = scale + 1
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

			for i = 0, self:GetBoneCount() - 1 do
				self:ManipulateBoneScale(i, vec01 * scale)
			end
		end
	end
end

function ENT:OnRemove()
	if zbl.config.Corpse.ExplodeOnDespawn and CurTime() >= ((self:GetCreationTime() + zbl.config.Corpse.life_time) - 1) then

		local pos = self:GetPos()
		zclib.Effect.ParticleEffect("zbl_explode_head", pos, Angle(0,0,0))
		zclib.Effect.ParticleEffect("zbl_infect_nodeexplode", pos, Angle(0,0,0))
		if zclib.Convar.Get("zbl_cl_decals") == 1 then zclib.Effect.RandomDecals(pos, "Blood", 100) end
		zbl.Sound.EmitFromPosition(pos,"VomitExplosion")
		zbl.Sound.EmitFromPosition(pos,"spore_explo")
	end
end
