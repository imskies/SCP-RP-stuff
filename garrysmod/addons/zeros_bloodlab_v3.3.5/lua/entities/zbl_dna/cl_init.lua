/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

include("shared.lua")

function ENT:Initialize()
	zclib.EntityTracker.Add(self)


	timer.Simple(0.1,function()
		if IsValid(self) then
			zclib.Animation.Play(self,"idle", 1)
		end
	end)
	self.HasEffect = false
end

function ENT:Think()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

	if zclib.util.InDistance(LocalPlayer():GetPos(), self:GetPos(), 300) then
		if self.HasEffect == false then
			zclib.Effect.ParticleEffectAttach("zbl_dna",PATTACH_POINT_FOLLOW, self, 0)
			self.HasEffect = true
		end
	else
		if self.HasEffect == true then
			self:StopParticles()
			self.HasEffect = false
		end
	end

	self:SetNextClientThink(CurTime())
	return true
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

function ENT:DrawTranslucent()
	self:Draw()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

function ENT:Draw()
	self:DrawModel()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

	if zclib.util.InDistance(LocalPlayer():GetPos(), self:GetPos(), 500) then
		cam.Start3D2D(self:GetPos() + Vector(0, 0, 20 + (1 * math.abs(math.sin(CurTime()) * 5))), zclib.HUD.GetLookAngles(), 0.1)
		surface.SetDrawColor(zbl.colors["lab_blue_dark"])
		surface.SetMaterial(zbl.materials["zbl_hexagon_icon"])
		surface.DrawTexturedRect(-80, -80, 160, 160)
		surface.SetDrawColor(color_white)
		surface.SetMaterial(zbl.materials["zbl_dna_icon"])
		surface.DrawTexturedRect(-70, -70, 140, 140)
		draw.SimpleText("+" .. self:GetDNAPoints(), zclib.GetFont("zbl_gun_font04"), 0, 100, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end
end
