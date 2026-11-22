local floor = math.floor
local clamp = math.Clamp
local min = math.min
local max = math.max
local cos = math.cos
local sin = math.sin
local deg2rad = math.pi / 180

net.Receive("ehud.vehicle_informer", function()
	max_speed = net.ReadFloat()
	hook.Run("ehud.vehicle_event",max_speed)
end)


local function check_is_photon(ent)
	if not istable(Photon) then return end
	if not IsValid(ent) then return false end
	if ent.Photon_SetupWheels ~= nil then return true end
	return false
end

local function check_is_vcmod(ent)
	if not IsValid(ent) then return false end
	if ent.VC_fuelGet ~= nil then return true end
	return false
end

local function check_is_simfphys(ply)
	if ply.IsDrivingSimfphys then
		return ply:IsDrivingSimfphys()
	end
	return false
end

local function generate_dial(cx,cy,start_angle,end_angle,rotates,radius,radius2, sub_arc)
	ehud.unknown_fuel = ehud.addon:Translate("VC_fuel_Unknown")
	ehud.fuel_types = {
		ehud.addon:Translate("VC_fuel_Petrol"),
		ehud.addon:Translate("VC_fuel_Diesel"),
		ehud.addon:Translate("VC_fuel_Electricity"),
	}


	local line_start_rad = radius*0.6
	local line_size = 3
	local int_radius = radius-radius2*1.5
	local int_radius_sec = int_radius*0.98

	local bg_line_size = 2
	local clr = ehud.addon:GetColors()

	local arc = esclib.util.PrecacheArc(cx, cy,radius, radius2, start_angle, end_angle, 10, rotates)

	local function dial(value,max_value,speed_step,speed_secondary_step)
		local difs = clamp(value/max_value,0,1)

		--speedometer bar
		for k,v in ipairs(arc) do
			surface.SetDrawColor( clr.vehicle.bg )
			draw.NoTexture()
			surface.DrawPoly(v)
		end

		if sub_arc then
			local arc2 = esclib.util.PrecacheArc(cx, cy, radius, radius2*1.1, start_angle, end_angle*difs, 3, rotates)
			--speedometer bar
			for k,v in ipairs(arc2) do
				surface.SetDrawColor( clr.vehicle.bg_speed )
				draw.NoTexture()
				surface.DrawPoly(v)
			end
		end

		--secondary speed lines
		local num = 1
		for k = 0, max_value, max(speed_secondary_step,1)  do
			local max_relative = k/max_value

			local ang = end_angle*max_relative+rotates
			local rad1 = deg2rad * ang
			local rad2 = deg2rad * (ang+bg_line_size*0.5)
			local cos_rad1 = cos(rad1)
			local sin_rad1 = sin(rad1)
			local cos_rad2 = cos(rad2)
			local sin_rad2 = sin(rad2)
			local poly_line = {
				{x = cx+(cos_rad1*int_radius), y = cy+(sin_rad1*int_radius)},
				{x = cx+(cos_rad1*radius), y = cy+(sin_rad1*radius)},
				{x = cx+(cos_rad2*radius), y = cy+(sin_rad2*radius)},
				{x = cx+(cos_rad2*int_radius), y = cy+(sin_rad2*int_radius)},
			}

			surface.SetDrawColor( clr.vehicle.bg_lines )
			draw.NoTexture()
			surface.DrawPoly(poly_line)

			num = num+1
		end


		local num = 1
		for k = 0, max_value, max(speed_step,1)  do
			local max_relative = k/max_value

			local ang = end_angle*max_relative+rotates
			local rad1 = deg2rad * ang
			local rad2 = deg2rad * (ang+bg_line_size)
			local cos_rad1 = cos(rad1)
			local sin_rad1 = sin(rad1)
			local cos_rad2 = cos(rad2)
			local sin_rad2 = sin(rad2)
			local poly_line = {
				{x = cx+(cos_rad1*int_radius_sec), y = cy+(sin_rad1*int_radius_sec)},
				{x = cx+(cos_rad1*radius), y = cy+(sin_rad1*radius)},
				{x = cx+(cos_rad2*radius), y = cy+(sin_rad2*radius)},
				{x = cx+(cos_rad2*int_radius_sec), y = cy+(sin_rad2*int_radius_sec)},
			}

			surface.SetDrawColor( clr.vehicle.text_secondary )
			draw.NoTexture()
			surface.DrawPoly(poly_line)

			esclib.draw:ShadowText(k,"es_ehud_16_500",cx+cos_rad1*radius*0.8,cy+sin_rad1*radius*0.8,clr.vehicle.text_secondary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			num = num+1
		end

		--speedometer line
		local ang = end_angle*difs+rotates
		local rad1 = deg2rad * ang
		local rad2 = deg2rad * (ang+line_size)
		local poly_line = {
			{x = cx+(cos(rad1)*line_start_rad), y = cy+(sin(rad1)*line_start_rad)},
			{x = cx+(cos(rad1)*radius), y = cy+(sin(rad1)*radius)},
			{x = cx+(cos(rad2)*radius), y = cy+(sin(rad2)*radius)},
			{x = cx+(cos(rad2)*line_start_rad), y = cy+(sin(rad2)*line_start_rad)},
		}

		surface.SetDrawColor( clr.vehicle.line )
		draw.NoTexture()
		surface.DrawPoly(poly_line)
	end
	return dial
end

--value [0,1]
local function draw_segmented_bar(x,y,w,h, value, segments, clr, clr2)
	local beetween = 5
	local totalw = w-(beetween*segments)
	local bar_width = totalw/segments

	local x_off = 0
	local cost = 1/segments
	for k = 1, segments do
		draw.RoundedBox(0,x+x_off, y, bar_width, h, clr)

		--local val_int = clamp( value/(k/segments), 0,1)
		local val_int = cost*k
		if value >= val_int then

			draw.RoundedBox(0,x+x_off-2, y-2, bar_width, h, clr2)
		end

		x_off = x_off+bar_width+beetween
	end
end


local function on()
	local bg = ehud.bg
	local ply = LocalPlayer()
	if not IsValid(bg) then return end
	local w = esclib.scrw
	local h = esclib.scrh
	local clr = ehud.addon:GetColors()

	--local jobclr = clr.main.accent

	if IsValid(ehud.vars.veh_pnl) then
		ehud.vars.veh_pnl:Remove()
	end
	ehud.vars.veh_pnl = vgui.Create("DPanel")
	local pnl = ehud.vars.veh_pnl
	pnl:SetSize(w*0.25, h*0.35)
	pnl:SetPos(w-pnl:GetWide()-10, h-pnl:GetTall()-5)
	pnl:SetVisible(false)
	pnl.Paint = nil
	local speedType = "MPH"
	local speed_lerp = 0

	if ehud.addon:GetVar("use_kmh") then
		speedType = "KMH"
	end

	local speed_pnl = pnl:Add("DPanel")
	speed_pnl:SetSize(pnl:GetTall()*0.9,pnl:GetTall()*0.9)
	speed_pnl:SetPos(pnl:GetWide()-speed_pnl:GetWide(),pnl:GetTall()-speed_pnl:GetTall())
	speed_pnl.max_speed = 1
	speed_pnl.vehicle = nil -- just initialize

	local start_angle = 0
	local end_angle = 270
	local rotates = 135

	local radius = speed_pnl:GetTall()*0.45
	local radius2 = radius*0.05

	local cx = speed_pnl:GetWide()*0.5
	local cy = speed_pnl:GetTall()*0.6

	local dial = generate_dial(cx,cy,start_angle,end_angle,rotates,radius,radius2, true)

	--local arc = esclib.util.PrecacheArc(cx, cy,radius, radius2, start_angle, end_angle, 10, rotates)
	function speed_pnl:Paint(w,h)
		if not ply:Alive() or not ply:InVehicle() then
			if IsValid(pnl) then
				pnl:SetVisible(false)
			end
			return
		end
		if check_is_simfphys(ply) then return end

		--do it once
		if not IsValid(self.vehicle) then
			self.vehicle = ply:GetVehicle()
			return
		end
		local veh = self.vehicle
		local max_speed = self.max_speed
		if max_speed < 1 then
			return
		end
		local count = math.ceil(max_speed *0.02)
		local speed = 1

		if speedType == "MPH" then
			speed = veh:GetVelocity():Length() / 17.6
		else
			speed = veh:GetVelocity():Length() / 10.936
			max_speed = max_speed*1.609
		end
		speed_lerp = Lerp(0.1, speed_lerp, speed)


		dial(speed_lerp,max_speed,10*count,count)

		if check_is_vcmod(veh) then
			local fuel = veh:VC_fuelGet()
			local fuel_max = veh:VC_fuelGetMax()
			local fuel_type = veh:VC_fuelGetType()
			
			local difs =  clamp(fuel/fuel_max,0,1)
			
			local xw = radius*0.3
			local yw = 10
			local x = cx-xw
			local y = cy+xw*1.8

			draw.RoundedBox(4,x,y,xw*2,yw,clr.vehicle.bg)
			draw.RoundedBox(4,x+2,y+2,xw*2*difs-4,yw-4,clr.vehicle.bg_speed)
			if fuel_type >= #ehud.fuel_types then
				esclib.draw:ShadowText(ehud.unknown_fuel,"es_ehud_16_500", x+xw, y, clr.vehicle.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			else
				esclib.draw:ShadowText(ehud.fuel_types[fuel_type+1],"es_ehud_16_500", x+xw, y, clr.vehicle.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			end
		end

		--text
		local speed_text = floor(speed_lerp)
		local tw, th = esclib.util:TextSize(speed_text,"es_ehud_60_500")

		esclib.draw:ShadowText(speed_text,"es_ehud_60_500", cx, cy+th*0.45, clr.vehicle.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		esclib.draw:ShadowText(speedType,"es_ehud_16_500", cx, cy+th*0.35, clr.vehicle.text_secondary, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

	end

	local info_panel = pnl:Add("DPanel")
	info_panel:SetSize(pnl:GetWide()-speed_pnl:GetWide(), pnl:GetTall())
	surface.SetFont("es_ehud_16_500")

	local primary_lights = ehud.addon:Translate("Photon_Primary")
	local warning_lights_text = ehud.addon:Translate("Photon_WarningLights")
	local siren_text = ehud.addon:Translate("Photon_Siren")
	local illum_text = ehud.addon:Translate("Photon_Illumination")
	function info_panel:Paint(w,h)
		if not ply:Alive() or not ply:InVehicle() then
			return
		end
		if check_is_simfphys(ply) then return end

		local veh = speed_pnl.vehicle
		if not IsValid(veh) then return end

		if speed_pnl.max_speed < 1 then
			return
		end

		local clr = ehud.addon:GetColors()
		if check_is_photon(veh) then

			--draw.RoundedBox(0,0,0,w,h,clr.vehicle.bg)

			local states = Photon.HUD:GetCurrentState()
			-- print("\n\n\n====================================")
			-- PrintTable(states)

			local offset_y = h-5

			if states then
				--Primary Lights
				local state = states['PrimaryLights']
				if state then
					local max_state = state["Max"]
					local index = state['SelectedIndex']
					local num_states = max(max_state,1)
					if not state["Enabled"] then index = 0 end

					esclib.draw:ShadowText( esclib.util:TextCut(state["Name"] or "?", "es_ehud_14_500", w-10, "..."), "es_ehud_14_500", w*0.5, offset_y, clr.vehicle.text_secondary, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					offset_y = offset_y-esclib.fonts.heights["es_ehud_14_500"]

					offset_y = offset_y-8
					draw_segmented_bar(5,offset_y,w-5, 5, index/num_states, num_states, clr.vehicle.bg, clr.vehicle.text)

					offset_y = offset_y-8
					esclib.draw:ShadowText(esclib.util:TextCut(primary_lights, "es_ehud_14_500", w-10, "..."), "es_ehud_14_500", w*0.5, offset_y, state["Enabled"] and clr.default.green or clr.default.red, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					offset_y = offset_y-esclib.fonts.heights["es_ehud_14_500"]

					offset_y = offset_y-8
					esclib.draw:ShadowText(esclib.util:TextCut(warning_lights_text, "es_ehud_14_500", w-10, "..."), "es_ehud_14_500", w*0.5, offset_y, clr.vehicle.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					offset_y = offset_y-esclib.fonts.heights["es_ehud_14_500"]-20
				end



				state = states['Siren']
				if state then
					local enabled = state["Enabled"]
					local cur_active = state["Active"]
					local siren_states = state["SirenTable"]
					if istable(siren_states) then
						local siren_cur_state = siren_states[cur_active]
						local num_states = max(#siren_states,1)

						offset_y = offset_y-8
						esclib.draw:ShadowText(esclib.util:TextCut(siren_cur_state["Name"] or "?", "es_ehud_14_500", w-10, "..."), "es_ehud_14_500", w*0.5, offset_y, clr.vehicle.text_secondary, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
						offset_y = offset_y-esclib.fonts.heights["es_ehud_14_500"]

						offset_y = offset_y-8
						draw_segmented_bar(5,offset_y,w-5, 5, cur_active/num_states, num_states, clr.vehicle.bg, clr.vehicle.text)

						offset_y = offset_y-8
						esclib.draw:ShadowText(esclib.util:TextCut(siren_text, "es_ehud_14_500", w-10, "..."), "es_ehud_14_500", w*0.5, offset_y, enabled and clr.default.green or clr.default.red, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
						offset_y = offset_y-esclib.fonts.heights["es_ehud_14_500"]

					end

					offset_y = offset_y-20
				end

				state = states['Illumination']
				if state then
					local enabled = state["Enabled"]
					local cur_active = state["Active"]
					local light_states = state["LightTable"]
					if istable(light_states) then
						local light_cur_state = light_states[cur_active]
						local num_states = max(#light_states,1)

						offset_y = offset_y-8
						esclib.draw:ShadowText(esclib.util:TextCut(light_cur_state["Name"] or "?", "es_ehud_14_500", w-10, "..."), "es_ehud_14_500", w*0.5, offset_y, clr.vehicle.text_secondary, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
						offset_y = offset_y-esclib.fonts.heights["es_ehud_14_500"]

						offset_y = offset_y-8
						draw_segmented_bar(5,offset_y,w-5, 5, cur_active/num_states, num_states, clr.vehicle.bg, clr.vehicle.text)

						offset_y = offset_y-8
						esclib.draw:ShadowText(esclib.util:TextCut(illum_text, "es_ehud_14_500", w-10, "..."), "es_ehud_14_500", w*0.5, offset_y, enabled and clr.default.green or clr.default.red, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
						offset_y = offset_y-esclib.fonts.heights["es_ehud_14_500"]

					end

					offset_y = offset_y-20
				end

			end
		end

	end

	hook.Remove("HUDPaint", "Photon.NewHUDPaint")

	hook.Add("ehud.vehicle_event","ehud.vehice_event_handler",function(max_speed)
		if IsValid(pnl) then
			pnl:SetVisible(true)
		end
		if IsValid(speed_pnl) then
			speed_pnl.max_speed = max_speed
			speed_pnl.vehicle = nil
		end
	end)


	local draw_durability = ehud.addon:GetVar("vc_draw_durability")
	hook.Remove("HUDShouldDraw", "vcmod_remove")
	hook.Add("HUDShouldDraw", "vcmod_remove",function(name)
		if name == "VCMod_Damage" or name == "VCMod_Health" then return draw_durability end
		if name == "VCMod_Fuel" then return false end

	end)
end

local function off()
	hook.Remove("ehud.vehicle_event","ehud.vehice_event_handler")
	hook.Remove("HUDShouldDraw", "vcmod_remove")
end

local function custom_check()
	return ehud.addon:GetVar("module_vehicle_hud")
end

ehud:Module("module_vehicle_hud",on,off,custom_check)