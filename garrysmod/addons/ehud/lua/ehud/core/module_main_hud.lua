local min = math.min
local max = math.max
local sin = math.sin
local cos = math.sin
local abs = math.abs
local interp = string.Interp

local function on()

	local bg = ehud.bg
	if not IsValid(bg) then return end
	local clr = ehud.addon:GetColors()

	local ply = LocalPlayer()

	local left_bottom = bg:Add("EditablePanel")
	left_bottom:SetSize(bg:GetWide()*0.5,bg:GetTall()*0.5)
	left_bottom:SetPos(0,bg:GetTall()-left_bottom:GetTall())

	local pnl_bars = left_bottom:Add("DPanel")


	local totalw = 0
	local min_width = 10
	local font = "es_ehud_16_500"
	local text_font = "es_ehud_24_500"
	local sub_font = "es_ehud_28_500"
	local draw_bg = ehud.addon:GetVar("drawbg")


	local texts = {}
	texts["health"] = ehud.addon:Translate("health")
	texts["armor"] = ehud.addon:Translate("armor")
	texts["hunger"] = ehud.addon:Translate("hunger")

	surface.SetFont(font)
	for k,v in pairs(texts) do
		local size = surface.GetTextSize(v)
		if size > min_width then min_width = size end
	end


	local totalh = draw.GetFontHeight(font) + draw.GetFontHeight(sub_font)+ 6
	local icon_size = totalh*0.45

	pnl_bars:SetSize(left_bottom:GetWide()-10,totalh)
	pnl_bars:SetPos(5,left_bottom:GetTall())
	pnl_bars:MoveTo(5,left_bottom:GetTall()-pnl_bars:GetTall()-5, ehud.addon:GetVar("animtime"))

	--------------
	/// WANTED ///
	--------------
	if DarkRP then
		local wanted_label = left_bottom:Add("DPanel")
		wanted_label:SetSize(esclib.scrw, 40)
		wanted_label:SetPos(pnl_bars:GetX(),pnl_bars:GetY()-pnl_bars:GetTall()-wanted_label:GetTall()-10)
		local wanted_base_clr = Color(255,0,0)
		function wanted_label:Paint(w,h)
			if not DarkRP then return end

			if ply:getDarkRPVar("wanted") then
				local sins = sin(CurTime()*3)*255
				wanted_base_clr.r = sins+255
				wanted_base_clr.b = -sins

				local phrase_wanted = ehud.addon:Translate("phrase_wanted")
				local reason = ply:getDarkRPVar("wantedReason")
				reason = reason and " ("..reason..")" or ""
				local text = phrase_wanted..reason
				local textw, texth = esclib.util:TextSize(text,"es_ehud_20_500")
				esclib.draw:ShadowText(text,"es_ehud_24_500",20,h*0.5, wanted_base_clr, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		end
	end
	
	local offset = 6
	local avatar = pnl_bars:Add("esclib.circle_avatar")
	avatar:SetSize(pnl_bars:GetTall()-offset*2, pnl_bars:GetTall()-offset*2)
	avatar:CenterVertical()
	avatar:SetX(5)
	avatar:SetPlayer(ply, 64)
	-- avatar:SetVertices(36)
	
	local jobclr = clr.main.accent
	local armor_lerp
	local hp_pulse_time = 0
	local hp_pulse = 0
	local hp_lerped = 100
	local ap_lerped = 0

	local ttt_health_label = GetConVar("ttt_health_label")
	local TTT = ttt_health_label ~= nil
	local GetLang = LANG and LANG.GetUnsafeLanguageTable or nil

	local roundstate = -1
	local roundstate_string = {}
	local bg_colors = {}
	if TTT then
		roundstate_string = {
		   [ROUND_WAIT]   = "round_wait",
		   [ROUND_PREP]   = "round_prep",
		   [ROUND_ACTIVE] = "round_active",
		   [ROUND_POST]   = "round_post"
		};
		bg_colors = {
			background_main = Color(0, 0, 10, 200),

			noround = Color(100,100,100,255),
			traitor = Color(255, 45, 45, 255),
			innocent = Color(45, 255, 45, 255),
			detective = Color(45, 45, 255, 255)
		};
		ehud.TTT = true
	end

	function pnl_bars:Paint(w,h)
		if not hook.Run("HUDShouldDraw", "CHudGMod") then 
			avatar:SetAlpha(0)
			return 
		else
			if avatar:GetAlpha() < 255 then
				avatar:SetAlpha(255)
			end
		end

		local alive = ply:Alive()
		if not alive and not TTT then return end
		
		if draw_bg then
			local poly = nil
			esclib.draw:Mask(function()
				if not poly then
					poly = esclib.util:PrecacheRoundedPoly(0, 0, totalw, h, 8, 3)
				end
				draw.NoTexture();
				surface.SetDrawColor( color_white )
				surface.DrawPoly( poly )
			end, 
			function()
				surface.SetDrawColor(jobclr.r,jobclr.g,jobclr.b,jobclr.a)
				surface.SetMaterial(ehud.Materials["gradient"])
				surface.DrawTexturedRectRotated(totalw*0.5,h,h,totalw,90)

				surface.SetDrawColor(clr.main.bg)
				surface.DrawRect(0,0,totalw,h)

				surface.SetDrawColor(jobclr.r,jobclr.g,jobclr.b,jobclr.a)
				surface.DrawRect(0,h-2,totalw,2,jobclr)
			end,false)
		end
	end


	function pnl_bars:PaintOver(w,h)
		if not hook.Run("HUDShouldDraw", "CHudGMod") then return end
		local alive = ply:Alive()
		if not alive and not TTT then return end
		local ox = 10
		if IsValid(avatar) then
			ox = ox + avatar:GetWide()
		end
		local ct = CurTime()

		local half_w = w*0.5
		local half_h = h*0.5
		local half_icon = icon_size*0.5
		local pl_team = ply:Team()

		-------------------
		/// JOB / STATE ///
		-------------------
		if DarkRP then
			jobclr = table.Copy(team.GetColor(pl_team) or clr.main.accent)
			jobclr.r = jobclr.r * 2
			jobclr.g = jobclr.g * 2
			jobclr.b = jobclr.b * 2
		elseif TTT then
			jobclr = bg_colors.innocent
			if GAMEMODE.round_state ~= ROUND_ACTIVE then
				jobclr = bg_colors.noround
			elseif ply:GetTraitor() then
				jobclr = bg_colors.traitor
			elseif ply:GetDetective() then
				jobclr = bg_colors.detective
			end
		end


		if DarkRP then
			local val = (ply:getDarkRPVar("job") or "?")
			local textw,texth = esclib.util:TextSize(val,text_font)
			esclib.draw:ShadowText(val,text_font, ox+textw*0.5+5, half_h, jobclr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			ox = ox + textw + 20
		elseif (TTT and isfunction(GetLang)) then
			if not ((not ply:Alive()) or ply:Team() == TEAM_SPEC) then
				local L = GetLang()
				round_state = GAMEMODE.round_state
				
				local text = "?"
				if round_state == ROUND_ACTIVE then
					text = L[ ply:GetRoleStringRaw() ]
				else
					text = L[ roundstate_string[round_state] ]
				end

				local textw,texth = esclib.util:TextSize(text,text_font)
				textw = max(textw+40,min_width)

				esclib.draw:ShadowText(text,text_font, ox+textw*0.5, half_h, jobclr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				ox = ox + textw + 10
			end
		end

		--------------
		/// HEALTH ///
		--------------
		if alive then
			if (TTT and (round_state == (ROUND_WAIT or 421))) then return end
			hp_lerped = Lerp(0.05, hp_lerped, ply:Health() or 0)

			local text = texts["health"]
			local text_cut = esclib.util:NumberLimit(esclib.util:Round(hp_lerped), 0, 100000)
			local textw,texth = esclib.util:TextSize(text_cut,font)
			textw = max(textw+40,min_width)
			esclib.draw:ShadowText(text,font, ox+textw*0.5, half_h+3-hp_pulse, clr.main.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

			esclib.draw:ShadowText(text_cut,sub_font, ox+textw*0.5, half_h+7-hp_pulse, clr.main.health, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

			--heartbeat
			if (hp_lerped <= ehud.config.heartbeat_minhp) and (hp_pulse_time < ct) and (ehud.config.heartbeat) then
				if ehud.DoImpactBlur then ehud:DoImpactBlur(4) end
				hp_pulse_time = ct + 2*(hp_lerped/ehud.config.heartbeat_minhp+0.5)
				surface.PlaySound( "ehud_heart.wav" )
				hp_pulse = hp_pulse + 10
			else
				hp_pulse = Lerp(0.05, hp_pulse, 0)
			end

			ox = ox + textw + 10
		end

		if not armor_lerp then armor_lerp = ox end

		-------------
		/// ARMOR ///
		-------------
		ap_lerped = Lerp(0.05, ap_lerped, ply:Armor() or 0)
		if ap_lerped ~= 0 then
			local text = texts["armor"]
			local text_cut = esclib.util:NumberLimit(esclib.util:Round(ap_lerped), 0, 100000)
			local textw,texth = esclib.util:TextSize(text_cut,font)
			textw = max(textw+40,min_width)
			esclib.draw:ShadowText(text,font, ox+textw*0.5, half_h+3, clr.main.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

			esclib.draw:ShadowText(text_cut,sub_font, ox+textw*0.5, half_h+7, clr.main.armor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

			armor_lerp = Lerp(0.05, armor_lerp, ox + textw + 10) --smooth
			ox = armor_lerp
		else
			if armor_lerp ~= nil then armor_lerp = nil end
		end

		----------------
		/// TTT TIME ///
		----------------
		if TTT then

			if round_state ~= ROUND_WAIT then
				local text = util.SimpleTime(max(0, GetGlobalFloat("ttt_round_end", 0) - CurTime()), "%02i:%02i")
				local text_bot = ehud.addon:Translate("phrase_time_left")

				local textw,texth = esclib.util:TextSize(text,sub_font)
				textw = max(textw+40,min_width, esclib.util:TextSize(text_bot,font))

				esclib.draw:ShadowText(text_bot,font, ox+textw*0.5, half_h+3, clr.main.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

				esclib.draw:ShadowText(text,sub_font, ox+textw*0.5, half_h+7, val == 0 and clr.default.red or clr.main.hunger, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
				ox = ox + textw + 10
			end
		end


		--------------
		/// HUNGER ///
		--------------
		if DarkRP then

			if DarkRP.disabledDefaults["modules"] then
				if not DarkRP.disabledDefaults["modules"]["hungermod"] then

					local val = ply:getDarkRPVar("Energy") or 0

					local text = texts["hunger"]
					local text_cut = esclib.util:NumberLimit( esclib.util:Round(val), 0, 100000)
					local textw,texth = esclib.util:TextSize(text_cut,font)
					textw = max(textw+40,min_width)
					esclib.draw:ShadowText(text,font, ox+textw*0.5, half_h+3, clr.main.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

					esclib.draw:ShadowText(text_cut,sub_font, ox+textw*0.5, half_h+7, val == 0 and clr.default.red or clr.main.hunger, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					ox = ox + textw + 10
				end
			end


		-------------
		/// MONEY ///
		-------------

			local val = DarkRP.formatMoney(ply:getDarkRPVar("money"))
			local textw,texth = esclib.util:TextSize(val,text_font)
			esclib.draw:ShadowText(val,text_font, ox+textw*0.5, half_h, clr.main.money_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			ox = ox + textw + 10

		-------------------
		/// GUN LICENSE ///
		-------------------
			if ply:getDarkRPVar("HasGunlicense") then
				esclib.draw:MaterialCentered(ox + icon_size+2, half_h+2, half_icon, clr.default.shadow, ehud.Materials["license.png"] )
				esclib.draw:MaterialCentered(ox + icon_size, half_h, half_icon, clr.main.text, ehud.Materials["license.png"] )
				ox = ox + icon_size+20
			end
		end

		------------------
		/// FLASHLIGHT ///
		------------------
		if ply:FlashlightIsOn() then
			esclib.draw:MaterialCentered(ox + icon_size+2, half_h+2, half_icon, clr.default.shadow, ehud.Materials["flashlight.png"] )
			esclib.draw:MaterialCentered(ox + icon_size, half_h, half_icon, clr.main.text, ehud.Materials["flashlight.png"] )
			ox = ox + icon_size + 20
		end

		totalw = Lerp(0.1, totalw, ox)

	end

	TTTSpecHUDPaint = nil
	PunchPaint = nil
	if TTT then

		local bg_colors = {
			background_main = Color(0, 0, 10, 200),
		 
			noround = Color(100,100,100,200),
			traitor = Color(200, 25, 25, 200),
			innocent = Color(25, 200, 25, 200),
			detective = Color(25, 25, 200, 200)
		};

		local health_colors = {
			border = COLOR_WHITE,
			background = Color(100, 25, 25, 222),
			fill = Color(200, 50, 50, 250)
		 };
		 
		 local ammo_colors = {
			border = COLOR_WHITE,
			background = Color(20, 20, 5, 222),
			fill = Color(205, 155, 0, 255)
		 };

		local margin = 10
		local key_params = { usekey = Key("+use", "USE") }

		local Tex_Corner8 = surface.GetTextureID( "gui/corner8" )
		local function RoundedMeter( bs, x, y, w, h, color)
			surface.SetDrawColor(color.r, color.g, color.b, color.a)

			surface.DrawRect( x+bs, y, w-bs*2, h )
			surface.DrawRect( x, y+bs, bs, h-bs*2 )

			surface.SetTexture( Tex_Corner8 )
			surface.DrawTexturedRectRotated( x + bs/2 , y + bs/2, bs, bs, 0 )
			surface.DrawTexturedRectRotated( x + bs/2 , y + h -bs/2, bs, bs, 90 )

			if w > 14 then
				surface.DrawRect( x+w-bs, y+bs, bs, h-bs*2 )
				surface.DrawTexturedRectRotated( x + w - bs/2 , y + bs/2, bs, bs, 270 )
				surface.DrawTexturedRectRotated( x + w - bs/2 , y + h - bs/2, bs, bs, 180 )
			else
				surface.DrawRect( x + math.max(w-bs, bs), y, bs/2, h )
			end
		end

		local function PaintBar(x, y, w, h, colors, value)
			-- Background
			-- slightly enlarged to make a subtle border
			draw.RoundedBox(8, x-1, y-1, w+2, h+2, colors.background)
		 
			-- Fill
			local width = w * math.Clamp(value, 0, 1)
		 
			if width > 0 then
			   RoundedMeter(8, x, y, width, h, colors.fill)
			end
		 end

		function PunchPaint(client)
			local L = GetLang()
			local punch = client:GetNWFloat("specpunches", 0)
		 
			local width, height = 200, 25
			local x = ScrW() / 2 - width/2
			local y = margin/2 + height
		 
			PaintBar(x, y, width, height, ammo_colors, punch)
		 
			local color = bg_colors.background_main
		 
			draw.SimpleText(L.punch_title, "HealthAmmo", ScrW() / 2, y, color, TEXT_ALIGN_CENTER)
		 
			esclib.draw:ShadowText(L.punch_help, "es_ehud_16_500", ScrW() / 2, margin, COLOR_WHITE, TEXT_ALIGN_CENTER)
		 
			local bonus = client:GetNWInt("bonuspunches", 0)
			if bonus != 0 then
			   local text
			   if bonus < 0 then
				  text = interp(L.punch_bonus, {num = bonus})
			   else
				  text = interp(L.punch_malus, {num = bonus})
			   end
		 
			   draw.SimpleText(text, "TabLarge", ScrW() / 2, y * 2, COLOR_WHITE, TEXT_ALIGN_CENTER)
			end
		end



		function TTTSpecHUDPaint(client)
			local L = GetLang() -- for fast direct table lookups
		
			-- Draw round state
			local x       = margin
			local height  = 32
			local width   = 250
		

			local tgt = client:GetObserverTarget()
			if IsValid(tgt) and tgt:IsPlayer() then
				esclib.draw:ShadowText(tgt:Nick(), "TimeLeft", ScrW() / 2, margin, COLOR_WHITE, TEXT_ALIGN_CENTER)
			elseif IsValid(tgt) and tgt:GetNWEntity("spec_owner", nil) == client then
				PunchPaint(client)
			else
				esclib.draw:ShadowText(interp(L.spec_help, key_params), "es_ehud_16_500", ScrW() / 2, margin, COLOR_WHITE, TEXT_ALIGN_CENTER)
			end
		end


	end




	function bg:Paint(w,h)
		if TTT then
			if (not ply:Alive()) or ply:Team() == TEAM_SPEC then
				TTTSpecHUDPaint(ply)
			end
		end
	end

end

local function off()
	--nothing to do
end

local function custom_check()
	return ehud.addon:GetVar("module_hud_leftbot")
end

ehud:Module("main_hud",on,off,custom_check)

----------------
/// VIGNETTE ///
----------------
local function on()
	local vignette_clr = Color(0, 0, 0, 255)
	local vignette_strength = 0

	local w = esclib.scrw
	local h = esclib.scrh

	local ply = LocalPlayer()
	local clr = ehud.addon:GetColors()
	hook.Add("HUDPaint", "ehud.vignette_paint",function()
		--vignette
		vignette_strength = ehud.addon:GetVar("vignette") or 0
		if (vignette_strength > 0) and ply:Alive() then
			if ply:Crouching() and ply:OnGround() then
				vignette_strength = max(0.7, vignette_strength)
			end

			vignette_clr.a = Lerp(0.05, vignette_clr.a, 255*vignette_strength)
			local res = (1-(ply:Health() or 0) / (ehud.config.heartbeat_minhp*2))
			if (res <= 1 and res >= 0) then
				vignette_clr.r = 255*res
			else
				if vignette_clr.r > 0 then
					vignette_clr.r = Lerp(0.005, vignette_clr.r, 0)
				end
			end

			esclib.draw:Material(0,0,w,h, vignette_clr, ehud.Materials["vignette.png"])
		end
	end)
end

local function off()
	hook.Remove("HUDPaint", "ehud.vignette_paint")
end

local function custom_check()
	return (ehud.addon:GetVar("vignette") or 0) ~= 0
end


----------------
/// FPS DRAW ///
----------------
local function on()
	local bg = ehud.bg
	if not IsValid(bg) then return end
	local fps_panel = bg:Add("DPanel")
	fps_panel:SetSize(150,40)
	fps_panel:SetX(bg:GetWide()-fps_panel:GetWide())

	local clr = ehud.addon:GetColors()
	local updateTime = 0
	local fps = 0
	local oldfps = 0
	function fps_panel:Paint(w,h)
		if updateTime < CurTime() then
			fps = 1/FrameTime()
			updateTime = CurTime()+0.4
		end

		oldfps = Lerp(0.5, fps, oldfps)
		esclib.draw:ShadowText( "FPS "..esclib.util:Round(oldfps) , "es_ehud_24_500", w - 5, 0 , clr.main.text,TEXT_ALIGN_RIGHT)
	end
end

local function off()
	--nothing to do
end

local function custom_check()
	return ehud.addon:GetVar("draw_fps")
end

ehud:Module("draw_fps",on,off,custom_check)



----------------
/// LOCKDOWN ///
----------------
local function on()
	if not DarkRP then return end

	local bg = ehud.bg
	if not IsValid(bg) then return end

	local cur_value
	local pnl = bg:Add("DPanel")

	local text = ehud.addon:Translate("phrase_lockdown")
	local font = "es_ehud_24_500"
	local multiline = esclib.text:Multiline(text,font, bg:GetWide()*0.7)

	local clr = ehud.addon:GetColors()
	local ply = LocalPlayer()

	function pnl:Update(state)

		if state then

			self:SetY(10)
			self:SetSize(multiline.width+10,multiline.height)
			self:CenterHorizontal()

			function self:Paint(w,h)
				if not ply:getDarkRPVar("Arrested") then 
					esclib.text:DrawMultiline(multiline,w*0.5+1,1,clr.default.shadow, TEXT_ALIGN_CENTER)
					esclib.text:DrawMultiline(multiline,w*0.5,0,clr.default.red, TEXT_ALIGN_CENTER)
				end
			end

		else
			self.Paint = function() end
		end

	end

	function pnl:Think()
		local lockdown_s = GetGlobalBool("DarkRP_LockDown",false)
		if (lockdown_s ~= cur_value) then
			cur_value = lockdown_s
			self:Update(cur_value)
		end
	end
end

local function off()

end

local function custom_check()
	return ehud.addon:GetVar("module_lockdown")
end

ehud:Module("lockdown_hud",on,off,custom_check)
