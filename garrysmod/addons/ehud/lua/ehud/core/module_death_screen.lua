local floor = math.floor

local function on()
	local last_live = true
	local last_time = SysTime()
	if IsValid(LocalPlayer()) then
		last_live = LocalPlayer():Alive()
	end

	hook.Add("Think","ehud.player_alive_check",function()
		local ply = LocalPlayer()
		local alive = ply:Alive()
		if last_live ~= alive then
			last_live = alive
			hook.Run("ehud.on_alive_change", ply, alive)
		end
	end)

	hook.Add("ehud.on_alive_change","ehud.generate_death_panel",function(ply, alive)
		local bg = ehud.bg

		if alive then
			if IsValid(bg.deathscreen) then
				bg.deathscreen:Remove()
				last_time = SysTime()
			end
			return
		end

		if not IsValid(bg) then return end

		local clr = ehud.addon:GetColors()
		local animtime = 1

		local deathscreen = bg:Add("EditablePanel")
		deathscreen:SetMouseInputEnabled(false)
		bg.deathscreen = deathscreen
		deathscreen:SetSize(esclib.scrw,esclib.scrh)
		function deathscreen:Close()
			deathscreen:AlphaTo(0, 0.1, 0, function()
				if IsValid(deathscreen) then deathscreen:Remove() end
			end)
		end

		local text = ehud.addon:Translate("deathsc_maintext")
		local lived_text = ehud.addon:Translate("deathsc_lived").." "..esclib.util:NiceTime( SysTime() - last_time )

		local need_wait = false
		local respawntime = 1
		if GAMEMODE then
			if GAMEMODE.Config then
				respawntime = GAMEMODE.Config.respawntime
				need_wait = respawntime > 3
			end
		end

		local function PaintInfo(self,w,h,posx,posy)
			ehud:PaintBlur(self,0,0,w,h)

			draw.RoundedBox(0,0,0,w,h,clr.deathscreen.bg)

			draw.SimpleText(text,"es_ehud_60_500",posx,posy,clr.deathscreen.text,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
			draw.SimpleText(lived_text,"es_ehud_36_500",posx,posy,clr.deathscreen.text2,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
		end

		local up_panel = deathscreen:Add("DPanel")
		up_panel:SetSize(deathscreen:GetWide(),deathscreen:GetTall()*0.5)
		up_panel:SetY(-up_panel:GetTall())
		up_panel:MoveTo(0,0, animtime, 0, 4 )
		function up_panel:Paint(w,h)
			PaintInfo(self,w,h,w*0.5,h)
		end

		local down_panel = deathscreen:Add("DPanel")
		down_panel:SetSize(deathscreen:GetWide(),deathscreen:GetTall()*0.5)
		down_panel:SetY(deathscreen:GetTall())
		function down_panel:Paint(w,h)
			PaintInfo(self,w,h,w*0.5,0)
		end


		local start_time = CurTime()
		local phrase_wait = ehud.addon:Translate("deathsc_please_wait")
		down_panel:MoveTo(0,deathscreen:GetTall()*0.5, animtime, 0, 4 ,function()
			if IsValid(deathscreen) then
				up_panel:Hide()
				down_panel:Hide()

				local info_panel = deathscreen:Add("DPanel")
				info_panel:SetSize(deathscreen:GetWide(),deathscreen:GetTall())
				function info_panel:Paint(w,h)
					PaintInfo(self,w,h,w*0.5,h*0.5)
				end

				local press_key = ehud.addon:Translate("deathsc_respawn_phrase")

				-- local textw,texth = esclib.util:TextSize(text,"es_ehud_24_500")
				local button_info = info_panel:Add("DPanel")
				button_info:SetSize(down_panel:GetWide(), esclib.fonts.heights["es_ehud_24_500"]+10)
				button_info:SetY(info_panel:GetTall())
				button_info:CenterHorizontal()
				button_info:MoveTo(button_info:GetX(),info_panel:GetTall()-button_info:GetTall()-20, 0.3, 0, 2)
				function button_info:Paint(w,h)
					if need_wait then
						local estimated = CurTime() - start_time

						if respawntime < estimated then
							draw.SimpleText(press_key,"es_ehud_24_500",w*0.5,h*0.5,clr.main.text_gray,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
						else
							draw.SimpleText( string.format(phrase_wait, floor(respawntime - estimated)),"es_ehud_24_500",w*0.5,h*0.5,clr.main.text_gray,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
						end
					else
						draw.SimpleText(press_key,"es_ehud_24_500",w*0.5,h*0.5,clr.main.text_gray,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
					end
				end

				if ehud.TTT then
					timer.Simple(3, function()
						if IsValid(deathscreen) then
							deathscreen:Close()
						end
					end)
				end

			end
		end)

	end)
end

local function off()
	hook.Remove("Think","ehud.player_alive_check")
	hook.Remove("ehud.on_alive_change","ehud.generate_death_panel")
end

local function custom_check()
	return ehud.addon:GetVar("module_deathscreen")
end

ehud:Module("deathscreen",on,off,custom_check)