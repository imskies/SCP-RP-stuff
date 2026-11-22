/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

include("shared.lua")
SWEP.PrintName = "Disinfectant  Spray"
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true -- Do you want the SWEP to have a crosshair?

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self.LastSprayAmount = -1
	self.AmountLevel = -1
end

function SWEP:SecondaryAttack()
end

function SWEP:PrimaryAttack()
end

function SWEP:Deploy()
end

function SWEP:Holster(swep)
end

function SWEP:Reload()
end

function SWEP:DrawHUD()
	if zclib.Convar.Get("zclib_cl_drawui") ~= 1 then return end
	if zclib.Convar.Get("zbl_cl_spray_enabled") == 0 then return end
	local spray_amount = self:GetSprayAmount()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

	if self.LastSprayAmount ~= spray_amount then
		self.LastSprayAmount = spray_amount
	end

	self.AmountLevel = self.AmountLevel - (10 * FrameTime())
	self.AmountLevel = math.Clamp(self.AmountLevel, self.LastSprayAmount, zbl.config.DisinfectantSpray.Amount)


	local pos_x = (1920 / 100) * zclib.Convar.Get("zbl_cl_spray_pos_x")
	local pos_y = (1080 / 100) * zclib.Convar.Get("zbl_cl_spray_pos_y")

	local scale = zclib.Convar.Get("zbl_cl_spray_scale")

	local width, height = 320 * scale, 50 * scale

	local bar_width = (width / zbl.config.DisinfectantSpray.Amount) * self.AmountLevel
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c


	pos_x = pos_x - (width / 2)
	pos_y = pos_y - (height / 2)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

	local sub_val = 10 * scale
	local brd_val = 5 * scale
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

	draw.RoundedBox(5, pos_x * zclib.wM, pos_y * zclib.hM, width * zclib.wM, height * zclib.hM, zbl.colors["disinfect_blue_dark"])
	draw.RoundedBox(5, (pos_x + brd_val) * zclib.wM, (pos_y + brd_val) * zclib.hM, (width - sub_val) * zclib.wM, (height - sub_val) * zclib.hM, zbl.colors["black03"])
	draw.RoundedBox(5, (pos_x + brd_val) * zclib.wM, (pos_y + brd_val) * zclib.hM, (bar_width - sub_val) * zclib.wM, (height - sub_val) * zclib.hM, zbl.colors["disinfect_blue_light"])
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

function SWEP:Think()
end
