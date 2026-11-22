local sin = math.sin
local cos = math.cos
local abs = math.abs

ehud.voiceActors = ehud.voiceActors or {}

hook.Add("PlayerStartVoice","ehud.player_startvoice_nickname",function(ply)
	ehud.voiceActors[ply:UserID()] = true
end)

hook.Add("PlayerEndVoice","ehud.player_endvoice_nickname",function(ply)
	ehud.voiceActors[ply:UserID()] = nil
end)

-------------------
/// PLAYER OVER ///
-------------------
local function on()

	--remove chat indicator
	hook.Remove("PostPlayerDraw", "DarkRP_ChatIndicator")

	local ply = LocalPlayer()
	local icon_size = 40
	local half_icon = icon_size*0.5
	local max_dist = ehud.addon:GetVar("draw_dist")*1500

	local clr = ehud.addon:GetColors()

	local fov = 180
	local fov_off = Vector(fov,fov,fov)
	local fov_neg = fov_off * -2

	local phrase_arrested = ehud.addon:Translate("phrase_arrested")
	local phrase_wanted = ehud.addon:Translate("phrase_wanted")

	local siren_color = table.Copy(clr.default.red)

	hook.Add("PostDrawTranslucentRenderables","ehud.render_nicknames",function()

		if not ehud.addon then return end

		local ct = CurTime()
		local local_pos = EyePos()

		for k,v in ipairs(ents.FindAlongRay(local_pos, ply:GetAimVector()*5000, fov_neg, fov_off)) do
			if IsValid(v) then

				if not v:IsPlayer() then continue end
				if not v:Alive() then continue end
				if (v == ply) then continue end
				if (v:GetRenderMode() == RENDERMODE_TRANSALPHA) or (v:GetNoDraw()) then continue end --cloak check
				if (v:InVehicle()) then continue end

				local nick_offset = 0

				local pl_pos = v:GetPos()
				local dist = local_pos:DistToSqr(pl_pos)
				if dist >= max_dist then continue end --distance check

				--nickname
				local name = ""
				if ehud.addon:GetVar("drawnickname") then
					name = v:Nick() or ""
				end
				local isVoicing = ehud.voiceActors[v:UserID()]
				local isArrested = false
				local isWanted = false

				--license / job
				local have_license = false
				local job = ""
				if DarkRP then
					if ehud.addon:GetVar("drawjobs") then
						job = v:getDarkRPVar("job")
					end
					if ehud.addon:GetVar("drawlicense") then
						have_license = v:getDarkRPVar("HasGunlicense")
					end
					if ehud.addon:GetVar("drawarrested") then
						isArrested = v:getDarkRPVar("Arrested")
					end
					if ehud.addon:GetVar("drawwanted") then
						isWanted = v:getDarkRPVar("wanted")
					end
					if isArrested or isWanted then
						siren_color.r = 255 * abs(sin(ct))
						siren_color.b = 255 * abs(cos(ct))
					end
				end


				--Bone position. Useful for custom skins
				local bone = v:LookupBone("ValveBiped.Bip01_Head1")
				local bone_pos, bone_angle
				if bone then
					bone_pos, bone_angle = v:GetBonePosition( bone )
				end
				local pos = bone_pos or pl_pos
				if pos == pl_pos then
					pos = pos+Vector(0,0,80)
				else
					if have_license then
						pos = pos+Vector(0,0,23)
					else
						pos = pos+Vector(0,0,15)
					end
				end
				if not pos then continue end


				local alpha = 255*math.Clamp((1 - dist/max_dist)*5, 0, 1 )

				local clr_nick = table.Copy(clr.main.text)
				clr_nick.a = alpha

				local job_clr = table.Copy(team.GetColor(v:Team()) or escore.colors.default.white)
				job_clr.a = alpha

				local textw, texth = esclib.util:TextSize(name,"es_ehud_60_500")
				local ox = -textw*0.5 - 20

				local ang = EyeAngles()
				ang:RotateAroundAxis(ang:Up(), -90)
				ang:RotateAroundAxis(ang:Forward(), 90)
				ang:RotateAroundAxis(ang:Right(), 0)

				cam.Start3D2D(pos,ang,ehud.config.PlayerOverheadSize)

					esclib.draw:ShadowText(name,"es_ehud_60_500",0,-nick_offset, clr_nick, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					esclib.draw:ShadowText(job,"es_ehud_36_500",0,0, job_clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

					if isVoicing then
						esclib.draw:MaterialCentered(2, -texth-icon_size-3-nick_offset, icon_size, clr.default.shadow, ehud.Materials["micro.png"])
						esclib.draw:MaterialCentered(0, -texth-icon_size-5-nick_offset, icon_size, clr.main.text, ehud.Materials["micro.png"])
					end
					

					if have_license then
						esclib.draw:MaterialCentered(2, texth*0.5+icon_size-1, half_icon, clr.default.shadow, ehud.Materials["license.png"])
						esclib.draw:MaterialCentered(0, texth*0.5+icon_size-3, half_icon, clr.main.white, ehud.Materials["license.png"])
					end

					if isArrested then
						esclib.draw:ShadowText(phrase_arrested,"es_ehud_60_500",0,-texth, siren_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					end

					if isWanted then
						local reason = v:getDarkRPVar("wantedReason")
						reason = reason and " ("..reason..")" or ""
						esclib.draw:ShadowText(phrase_wanted..reason,"es_ehud_36_500",0,-texth, siren_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					end


				cam.End3D2D()

			end
		end

	end)
end


local function off()
	hook.Remove("PostDrawTranslucentRenderables","ehud.render_nicknames")
end

local function custom_check()
	return ehud.addon:GetVar("module_ply_over")
end

ehud:Module("player_over",on,off,custom_check)



--------------------
/// ARRESTED HUD ///
--------------------
local function on()
	if not (DarkRP) then return end

	if (ehud.addon:GetVar("module_hud_arrested")) then
		usermessage.Hook("GotArrested", function(msg)
		    local start_time = CurTime()
		    local end_time = msg:ReadFloat()

		    local bg = ehud.bg
		    if not IsValid(bg) then return end
		    local sw,sh = bg:GetWide(), bg:GetTall()

		    local arr_panel = bg:Add("DPanel")
		    arr_panel:SetSize()


		    hook.Add("HUDPaint", "ehud.paint_arrested",function()
		    	local w,h = esclib.scrw, esclib.scrh
				local clr = ehud.addon:GetColors()


				local ply = LocalPlayer()
			    local var_arrested = ply:getDarkRPVar("Arrested")

			    local fraction = ((start_time + end_time) - CurTime()) / end_time
			    if ((CurTime() - start_time) <= end_time) and (var_arrested) then
			    	draw.RoundedBox(0,0,0,w,5,clr.notify.bg)
			    	draw.RoundedBox(0,0,0,w*fraction,5,clr.notify.error)


			    	esclib.draw:ShadowText("-= "..ehud.addon:Translate("phrase_arrested").." =-","es_ehud_30_500",w*0.5, h*0.05, clr.default.red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			    	esclib.draw:ShadowText(ehud.addon:Translate("phrase_time_left")..": "..esclib.util:NiceTime(start_time+end_time - CurTime(), false),"es_ehud_20_500",w*0.5, h*0.05+30, clr.main.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			    else
			    	hook.Remove("HUDPaint", "ehud.paint_arrested")
			    end
		    end)
		end)
	end
end


local function off()
	hook.Remove("HUDPaint", "ehud.paint_arrested")
end

local function custom_check()
	return ehud.addon:GetVar("module_hud_arrested")
end

ehud:Module("arrested_hud",on,off,custom_check)