/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

include("shared.lua")

function ENT:Initialize()
	zclib.EntityTracker.Add(self)
	self:DestroyShadow()
	self.LastEffect = - 1
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

function ENT:DrawTranslucent()
	self:Draw()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

function ENT:Draw()
end

local zbl_LastEffect = 0

function ENT:Think()
	if zbl.config.Fence.dmg_per_touch > 0 and (self.LastEffect or 0) < CurTime() and (zbl_LastEffect < CurTime()) then
		local min,max = self:GetCollisionBounds()
		//debugoverlay.BoxAngles( self:GetPos(), min,max, self:LocalToWorldAngles(Angle(0,0,0)), 0.1, Color( 0, 255, 255,10 ) )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

		local mid = math.random(min.y,max.y)
		local vPoint = self:GetPos() + self:GetUp() * 70 - self:GetRight() * mid
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

		//debugoverlay.Sphere(vPoint,5,1,Color( 255, 255, 255 ,100),true)

		local effectdata = EffectData()
		effectdata:SetOrigin( vPoint )

		effectdata:SetMagnitude( 1 )
		effectdata:SetScale(1)
		effectdata:SetRadius( 1 )

		util.Effect( "cball_bounce", effectdata )

		zbl.Sound.EmitFromPosition(vPoint,"zbl_fence_zap")

		if zbl.config.Fence.health > 0 and self:GetMain():Health() < (zbl.config.Fence.health * 0.2) then
			self.LastEffect = CurTime() + math.Rand(0.2,1)
			zbl_LastEffect = CurTime() + 0.25
		else
			self.LastEffect = CurTime() + math.Rand(5,10)
			zbl_LastEffect = CurTime() + 2
		end
	end
end
