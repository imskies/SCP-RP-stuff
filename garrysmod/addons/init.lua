/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

local APP = {}
APP.name = "Genetic Surprise™"
APP.color = Color(255, 255, 255)
APP.icon = "zerochain/zblood/mcphone/zbl_mcphone_app_icon.png"

// Returns how high the chance is to get infected
local function InfectionDanger()

	local closest_treat
	local lastDist = 99999999
	local pos = LocalPlayer():GetPos()
	for k, v in pairs(ents.FindInSphere(LocalPlayer():GetPos(), zbl.config.McPhone.scan_radius)) do
		if IsValid(v) and (v:IsPlayer() and v:Alive() and v ~= LocalPlayer()) or zbl.config.Contamination.ents[v:GetClass()] or v:GetClass() == "zbl_virusnode" then
			if v:GetClass() == "zbl_virusnode" then
				local dist = v:GetPos():DistToSqr(pos)

				if dist < lastDist then
					closest_treat = v
					lastDist = dist
				end
			else
				local vac = zbl.Vaccine.Get(v)

				if vac ~= -1 and vac > 0 and zbl.Vaccine.IsVirus(vac) then
					local dist = v:GetPos():DistToSqr(pos)

					if dist < lastDist then
						closest_treat = v
						lastDist = dist
					end
				end
			end
		end
	end

	local final = 0
	if IsValid(closest_treat) then
		local dist_sqr = closest_treat:GetPos():DistToSqr(pos)
		final = (100 / (300 * 300)) * dist_sqr
		final = math.Clamp(100 - final, 0, 100)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24


	return math.Round(final)
end

function APP:Open(main, main_x, main_y)

	main.InfectChance = 0
	main.IsScanning = false
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

	function main:Paint(w, h)
		draw.RoundedBox(1, 0, 0, w, h, zbl.colors["black04"])

		if self.IsScanning == false then
			draw.RoundedBox(1, 0, h/1.2, w, h * 0.1, zbl.colors["black03"])
			draw.SimpleText(zbl.language.Gun["Scan"], zclib.GetFont("zbl_gun_dna"), w / 2, h/1.143, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		draw.SimpleText("Infection risk: " .. self.InfectChance .. "%", zclib.GetFont("zbl_gun_dna"), w/2, h / 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		surface.SetDrawColor(zbl.colors[ "white06" ])
		surface.SetMaterial(zbl.materials[ "zbl_mask_off" ])
		surface.DrawTexturedRect(0, h / 4, w, w, 0)

		if IsValid(LocalPlayer().zbl_GasMask_model) then
			surface.SetDrawColor(zbl.colors["cure_green"])
			surface.SetMaterial(zbl.materials["zbl_mask_on"])
			surface.DrawTexturedRect(0, h / 4, w, w, 0)

			local max_uses = zbl.GasMask.GetMaxUses(LocalPlayer().zbl_MaskID)
			draw.SimpleText(math.Round((100 / max_uses) * zbl.GasMask.GetUses(LocalPlayer())) .. "%", zclib.GetFont("zbl_gun_dna"), w/2, h / 1.4, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

	local but = vgui.Create("DButton", main)
	but:Dock(FILL)
	but:SetText("")

	function but:Paint(w, h)

	end

	function but:DoClick()
		if main.zbl_scanner then return end

		local scan_start = CurTime()
		main.zbl_scanner = vgui.Create("DPanel", main)
		main.zbl_scanner:Dock(FILL)
		main.zbl_scanner.Paint = function(self, w, h)

			draw.RoundedBox(1, 0, h / 1.2, w, h * 0.1, zbl.colors[ "black03" ])
			draw.RoundedBox(1, 0, h / 1.2, (w / zbl.config.McPhone.scan_duration) * (CurTime() - scan_start), h * 0.1, zbl.colors[ "cure_green" ])
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

		LocalPlayer():EmitSound("zbl_ui_click")
		main.IsScanning = true

		timer.Simple(zbl.config.McPhone.scan_duration, function()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

			if IsValid(main.zbl_scanner) then
				main.zbl_scanner:Remove()
				main.zbl_scanner = nil
			end

			if IsValid(main) then
				main.IsScanning = false

				if main:IsVisible() then
					LocalPlayer():EmitSound("zbl_scan_action")
					main.InfectChance = InfectionDanger()
				end
			end
		end)
	end

	main:aphone_RemoveCursor()
end
function APP:Open2D(main, main_x, main_y)
    self:Open(main, main_x, main_y, true)
end
aphone.RegisterApp(APP)
