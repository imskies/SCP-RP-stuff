/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

include("shared.lua")

function ENT:Initialize()
	zclib.EntityTracker.Add(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:DrawStat(virus_id,i_types,itm_count,pos)

	local data = zbl.Vaccine.GetData(virus_id)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

	if data == nil then return end

	local box_h = 120
	local icon_size = 80

	local x,y = 0,0

	// virus_red
	if itm_count > 6 then
		box_h = 70

		// Offset from the top
		y = y + 20

		// Distance between Virus Box
		y = y + 120 * pos

		icon_size = 50
	else
		// Offset from the top
		y = y - 30

		// Distance between Virus Box
		y = y + 180 * pos
	end

	draw.RoundedBox(5, -250, -30 + y, 500, box_h, zbl.colors["black06"])

	local txt = zbl.Vaccine.GetName(virus_id)
	local tw, _ = zclib.util.GetTextSize(txt, zclib.GetFont("zbl_sign_item"))
	draw.RoundedBox(5, -250, -65 + y, tw + 10, 30, zbl.colors["black06"])
	draw.SimpleText(txt, zclib.GetFont("zbl_sign_item"), x - 245, y -50, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

	if itm_count > 6 then
		y = y -5
	else
		y = y + 10
	end

	if table.Count(i_types) <= 0 then

		draw.SimpleText("NA", zclib.GetFont("zbl_sign_count"), x, y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		local font
		if itm_count > 6 then
			x = x - 275
			font = zclib.GetFont("zbl_sign_count_small")
		else
			x = x - 250
			font = zclib.GetFont("zbl_sign_count")
		end


		for i_type, _count in pairs(i_types) do

			if itm_count > 6 then
				x = x + icon_size + 60
			else
				x = x + icon_size + 20
			end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

			surface.SetDrawColor(color_white)
			surface.SetMaterial(zbl.materials["zbl_hexagon_outline"])
			surface.DrawTexturedRect(x- icon_size / 2, y - icon_size / 2, icon_size, icon_size)

			surface.SetDrawColor(color_white)
			if i_type == 1 then
				surface.SetMaterial(zbl.materials["zbl_icon_stat_infected"])
			elseif i_type == 2 then
				surface.SetMaterial(zbl.materials["zbl_icon_stat_contamination"])
			elseif i_type == 3 then
				surface.SetMaterial(zbl.materials["zbl_icon_stat_virusnode"])
			elseif i_type == 4 then
				surface.SetMaterial(zbl.materials["zbl_icon_stat_corpse"])
			end
			surface.DrawTexturedRect(x- icon_size / 2, y - icon_size / 2, icon_size, icon_size)

			if _count > 0 then
				draw.SimpleText(_count, font, x, y + icon_size / 1.5, zbl.colors["virus_red_light"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText("-", font, x, y + icon_size / 1.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
end

local pos_offset = Vector(0,1,73)
local ang_offset = Angle(180, 0, -90)

function ENT:DrawReport()
	cam.Start3D2D(self:LocalToWorld(pos_offset), self:LocalToWorldAngles(ang_offset), 0.05)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360


		draw.RoundedBox(5, -295, -85, 590, 1265, zbl.colors["virus_red_alpha"])

		draw.RoundedBox(5, -300, -40, 600, 5, zbl.colors["black03"])
		draw.RoundedBox(5, -300, 45, 600, 5, zbl.colors["black03"])
		draw.RoundedBox(5, -300, -40, 600, 90, zbl.colors["black06"])
		draw.SimpleText(zbl.language.General["InfectionReport"], zclib.GetFont("zbl_sign_title_bg"), 0,0, zbl.colors["virus_red"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(zbl.language.General["InfectionReport"], zclib.GetFont("zbl_sign_title"), 2,2, zbl.colors["black02"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(zbl.language.General["InfectionReport"], zclib.GetFont("zbl_sign_title"), 0,0, zbl.colors["virus_red"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(zbl.language.General["InfectionReport"], zclib.GetFont("zbl_sign_title_fg"), 0,0, zbl.colors["virus_red"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		if zbl.VirusStatistics then
			local itm_count = table.Count(zbl.VirusStatistics)
			local pos = 1

			for k, v in pairs(zbl.VirusStatistics) do
				self:DrawStat(v.vac_id, v.types, itm_count, pos)
				pos = pos + 1
			end
		end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955


		if zclib.util.InDistance(LocalPlayer():GetPos(), self:GetPos(), 150) then
			surface.SetDrawColor(zbl.colors["black03"])
			surface.SetMaterial(zbl.materials["zbl_scanlines"])
			surface.DrawTexturedRect(-295, -85, 590, 1265)
		end

	cam.End3D2D()
end

function ENT:Draw()
	self:DrawModel()

	if zclib.util.InDistance(LocalPlayer():GetPos(), self:GetPos(), 250) then
		self:DrawReport()

	end

	if zclib.Convar.Get("zbl_cl_dynlight") == 1  and zclib.util.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then

		self:ScreenLight()
	end
end

local lpos_light = Vector(0,20,55)
function ENT:ScreenLight()
	local dlight01 = DynamicLight(self:EntIndex())
	local pos = self:LocalToWorld(lpos_light)

	if dlight01 then
		dlight01.pos = pos
		dlight01.r = zbl.colors["lab_blue"].r
		dlight01.g = zbl.colors["lab_blue"].g
		dlight01.b = zbl.colors["lab_blue"].b
		dlight01.brightness = 2
		dlight01.Decay = 1000
		dlight01.Size = 200
		dlight01.DieTime = CurTime() + 1
	end
end
