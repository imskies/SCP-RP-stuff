local function on()
	local bg = ehud.bg
	if not IsValid(bg) then return end
	local w = bg:GetWide()
	local h = bg:GetTall()
	local clr = ehud.addon:GetColors()

	local ply = LocalPlayer()

	local right_bot = bg:Add("EditablePanel")
	right_bot:SetSize(bg:GetWide()*0.5,bg:GetTall()*0.5)
	right_bot:SetPos(bg:GetWide()*0.5,bg:GetTall()*0.5)

	local font = "es_ehud_24_500"

	local info_height = 40
	local bars_maxw = right_bot:GetWide()*0.6
	local bar_spacing = 3

	local old_ammo = 0
	local losingTime = 0 --used internally
	local loseTime = 0.1

	local guns_with_prop_count = {
		["weapon_physcannon"] = true,
		["weapon_physgun"] = true,
		["gmod_tool"] = true,
	}

	--TTT name support
	local function internal_try_translate(name) 
		local TryTranslation = false
		if LANG then
		  TryTranslation = LANG.TryTranslation
		end
		if isfunction(TryTranslation) then
		  return TryTranslation(name)
		end
		return name
	end

	local prop_phrase = ehud.addon:Translate("props")
	local ammo_types = game.GetAmmoTypes()
	local function draw_gun_hud(w,h)

		if ply:InVehicle() then
			if ply.GetAllowWeaponsInVehicle then
				if not ply:GetAllowWeaponsInVehicle() then
					return
				end
			end
		end

		local weapon = ply:GetActiveWeapon()
		if not IsValid(weapon) then return end

		local ct = CurTime()

		if not guns_with_prop_count[weapon:GetClass()] then

			local no_clip = false
			local secondary_is_primary = false
			local ammo_icon = ehud.Materials["ammo_normal.png"]

			local ammo1_type = weapon:GetPrimaryAmmoType()
			if ammo1_type < 0 then
				ammo1_type = weapon:GetSecondaryAmmoType()
				if ammo1_type < 0 then
					return
				end
				secondary_is_primary = true
			end



			if ammo1_type == 7 then
				ammo_icon = ehud.Materials["ammo_buckshot.png"]
			elseif (ammo1_type == 3) or (ammo1_type == 4) or (ammo1_type == 12) then
				ammo_icon = ehud.Materials["ammo_pistol.png"]
			elseif (ammo1_type == 8) or (ammo1_type == 10) or (ammo1_type == 11) then
				ammo_icon = ehud.Materials["ammo_explosive.png"]
			elseif (ammo1_type == 1) or (ammo1_type == 2) or (ammo1_type == 14) or (ammo1_type == 13) then
				ammo_icon = ehud.Materials["ammo_normal.png"]
			end
				

			local ammo1 = weapon:Clip1()
			if ((not ammo1) or (ammo1<0)) then 
				ammo1 = ply:GetAmmoCount(ammo1_type)

				if ((not ammo1) or ((ammo1<0) and weapon:HasAmmo() )) then --no clip check
					return
				end
				no_clip = true
			end

			local max1 = weapon:GetMaxClip1()
			if no_clip then
				max1 = ammo1
				ammo1 = max1
			end
			if secondary_is_primary then max1 = 1 end
			if max1 == 0 then return end

			local ammocount1 = ply:GetAmmoCount(ammo1_type)

			local barw = math.ceil((w*0.3) / max1)
			local max_size = (barw+bar_spacing)*max1

			local ammo_clr = clr.ammo.normal
			local ammo_ratio = ammo1/max1
			if (ammo_ratio <= 0.5 and ammo_ratio > 0.18) then
				ammo_clr = clr.ammo.medium
			elseif (ammo_ratio <= 0.18) then
				ammo_clr = clr.ammo.low
			end

			if (old_ammo > ammo1) then
				losingTime = ct + loseTime
				ehud.vars.lerp_y = 5
			end

			if (bars_maxw >= max_size) then

				for i = 1, max1 do

					if (i <= ammo1) then
						draw.RoundedBox(0, w-(barw+bar_spacing)*i-18, h-18, barw, 5, clr.main.bg )
						draw.RoundedBox(0, w-(barw+bar_spacing)*i-20, h-20, barw, 5, ammo_clr )
					else
						draw.RoundedBox(0, w-(barw+bar_spacing)*i-20, h-20, barw, 5, clr.ammo.bg )
					end

				end

				if (losingTime > ct) then
					
					local fraction = (1-(losingTime - ct) / loseTime)
					local clr = table.Copy(ammo_clr)
					clr.a = clr.a * (1-fraction)

					draw.RoundedBox(0, w-(barw+bar_spacing)*(ammo1+1)-20-20 * fraction, h-20 + 10 * fraction, barw, 5, clr)
				end

			else 
				local bars_maxw_relative = bars_maxw*0.8*ammo_ratio
				draw.RoundedBox(0, w-bars_maxw*0.8-18, h-18, bars_maxw*0.8, 5, clr.main.bg )
				draw.RoundedBox(0, w-bars_maxw_relative-20, h-20, bars_maxw_relative, 5, ammo_clr )

				if (losingTime > ct) then
					
					local fraction = (1-(losingTime - ct) / loseTime)
					local clr = table.Copy(ammo_clr)
					clr.a = clr.a * (1-fraction)

					draw.RoundedBox(0, w-bars_maxw_relative-22, h-20 + 40 * fraction, 5, 5, clr)
				end

				max_size = bars_maxw*0.8
			end

			old_ammo = ammo1


			--PRIMARY
			local text_size = esclib.util.GetTextSize("/"..ammocount1,"es_ehud_20_500")
			local ammotype_cut = ""..(ammo_types[ammo1_type] or "Unknown")..""
			if no_clip or secondary_is_primary then
				esclib.draw:MaterialCentered(w-max_size-15, h-52, 7, clr.default.black, ammo_icon)
				esclib.draw:MaterialCentered(w-max_size-16, h-53, 7, clr.default.white, ammo_icon)
				esclib.draw:ShadowText(ammotype_cut,"es_ehud_16_500", w-4-max_size, h-45, clr.ammo.normal, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				esclib.draw:ShadowText(ammocount1, "es_ehud_36_500", w-24, h-25, ammo_clr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
			else
				esclib.draw:MaterialCentered(w-max_size-15, h-52, 7, clr.default.black, ammo_icon)
				esclib.draw:MaterialCentered(w-max_size-16, h-53, 7, clr.default.white, ammo_icon)
				esclib.draw:ShadowText(ammotype_cut,"es_ehud_16_500", w-max_size-4, h-45, clr.ammo.normal, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
				esclib.draw:ShadowText(ammo1, "es_ehud_36_500", w-text_size.w-20, h-25, ammo_clr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
				esclib.draw:ShadowText("/"..ammocount1, "es_ehud_20_500", w-20, h-25, ammocount1 < 1 and clr.ammo.low or clr.ammo.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
			end


			--Weapon name
			local text_size2 = esclib.util.GetTextSize(ammo1,"es_ehud_36_500")

			local weap_name = internal_try_translate(weapon:GetPrintName() or weapon.PrintName or "...")
			if string.StartWith(weap_name, "#HL2") then weap_name = language.GetPhrase(weap_name) end

			local name = string.Trim(esclib.util:TextCut(weap_name,"es_ehud_20_500", max_size-(text_size.w + text_size2.w +5)))
			local cutted = string.len(weap_name) ~= string.len(name)
			esclib.draw:ShadowText(cutted and (name.."...") or (name), "es_ehud_20_500", w-22-max_size, h-25, clr.ammo.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)



			--SECONDARY
			local ammotype2 = weapon:GetSecondaryAmmoType()
			if ammotype2 < 0 then return end
			local ammo2 = ply:GetAmmoCount(ammotype2)
			if ((not ammo2) or (ammo2<0)) then return end

			local text_pos = w-20-max_size-w*0.05
			local text = "["..ehud.addon:Translate("ammotype_secondary").."]"
			local font = "es_ehud_16_500"
			local text_size3 = esclib.util.GetTextSize(text,font)
			esclib.draw:ShadowText(text,font,text_pos,h-5,clr.ammo.text,TEXT_ALIGN_RIGHT,TEXT_ALIGN_BOTTOM)

			esclib.draw:ShadowText(ammo2,"es_ehud_30_500",text_pos-text_size3.w*0.5,h-text_size3.h-5,clr.ammo.text,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
		else -- if weapong with counter
			local props = 0
			local max_props = 0
			if ply.GetCount then
				props = ply:GetCount("props") or 0 
			end

			if sam then
				max_props = sam.ranks.get_limit( ply:GetUserGroup(), "props")
			else
				local props_convar = GetConVar("sbox_maxprops")
				if props_convar then
					if props_convar.GetInt then
						max_props = props_convar:GetInt() or 0
					end
				end
			end

			if max_props > 0 then
				--prop count
				esclib.draw:ShadowText(prop_phrase.." ["..props.." / "..max_props.."]", "es_ehud_24_500",w-5,h-5, clr.main.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
			end
		end
	end

	function right_bot:Paint(w,h)
		draw_gun_hud(w,h)
	end
end

local function off()
	--nothing to do
end

local function custom_check()
	return ehud.addon:GetVar("module_hud_gun")
end

ehud:Module("ammo_hud",on,off,custom_check)