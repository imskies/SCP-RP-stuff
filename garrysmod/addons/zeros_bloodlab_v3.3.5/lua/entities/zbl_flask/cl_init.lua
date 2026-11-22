/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

function ENT:Initialize()
	zclib.EntityTracker.Add(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:DrawInfo(txt01,txt02,icon,color)
	surface.SetDrawColor(color)
	surface.SetMaterial(zbl.materials["zbl_hexagon_icon"])
	surface.DrawTexturedRect(-80,-80,160,160)

	surface.SetDrawColor(color_white)
	surface.SetMaterial(icon)
	surface.DrawTexturedRect(-70,-70,140,140)

	draw.SimpleText(txt01, zclib.GetFont("zbl_gun_font04"), 0, 100, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if txt02 then
		draw.SimpleText(txt02, zclib.GetFont("zbl_flask_font02"), 0, 130, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

local lpos_offset = Vector(0, 0, 25)

function ENT:Draw()
	self:DrawModel()

	if zclib.Convar.Get("zclib_cl_drawui") == 1 and zclib.util.InDistance(LocalPlayer():GetPos(), self:GetPos(), 500) then
		cam.Start3D2D(self:GetPos() + lpos_offset, zclib.HUD.GetLookAngles(), 0.1)

			local _type = self:GetGenType()
			local _val = self:GetGenValue()
			local _vacdata = zbl.Vaccine.GetData(_val)

			if _type == 1 then
				self:DrawInfo(self:GetGenName(), zbl.language.General["DNA"] .. ": " .. self:GetGenPoints(), zbl.materials["zbl_dna_icon"], zbl.colors["sample_blue"])
			elseif _type == 2 then
				if _vacdata then
					if zbl.Vaccine.IsVirus(_val) then
						self:DrawInfo(zbl.Vaccine.GetName(_val), nil, zbl.materials["zbl_virus_icon"], zbl.colors["virus_red"])
					else
						self:DrawInfo(zbl.Vaccine.GetName(_val), nil, zbl.materials["zbl_abillity_icon"], zbl.colors["abillity_yellow"])
					end
				end
			elseif _type == 3 then
				self:DrawInfo(zbl.Vaccine.GetName(_val), nil, zbl.materials["zbl_cure_icon"], zbl.colors["cure_green"])
			end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

		cam.End3D2D()
	end
end
