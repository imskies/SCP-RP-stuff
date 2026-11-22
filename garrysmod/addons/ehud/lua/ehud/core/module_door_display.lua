-----------------
/// FUNCTIONS ///
-----------------
local function isDoor( door )
	if door.isDoor and door.isKeysOwnable then
		return (door:isDoor() and door:isKeysOwnable())
	end
end

local function isVehicle( ent )
	if ent.IsVehicle and isfunction(ent.IsVehicle) then
		return ent:IsVehicle()
	end
end

local function isOwnable( door )
	if door.getKeysNonOwnable then
		return door:getKeysNonOwnable() ~= true
	end
end

local function getTitle( door )
	if door.getKeysTitle then
		return door:getKeysTitle()
	end
end

local function getOwner( door )
	if door.getDoorOwner then
		local owner = door:getDoorOwner()

		if IsValid( owner ) then
			return owner
		end
	end
end

local function getGroup( door )
	if door.getKeysDoorGroup then
		return door:getKeysDoorGroup()
	end
end

local function getCoowners( door )
	local owner = getOwner( door )
	local coents = {}

	if door.isKeysOwnedBy then
		for _, ply in ipairs( player.GetAll() ) do
			if not ((door:isKeysOwnedBy( ply )) and (ply ~= owner)) then continue end

			table.insert( coents, ply )
		end
	end

	return coents
end

local function isAllowedToCoown( door, ply )
	if door.isKeysAllowedToOwn and door.isKeysOwnedBy then
		return door:isKeysAllowedToOwn( ply ) and not door:isKeysOwnedBy( ply )
	end
end

local function getAllowedGroupNames( door )
	local ret = {}

	if door.getKeysDoorGroup and door:getKeysDoorGroup() then
		table.insert( ret, door:getKeysDoorGroup() )
	elseif door.getKeysDoorTeams then
		for _,tid in ipairs( door:getKeysDoorTeams() or {} ) do
			local tname = team.GetName( tid )

			if tname then
				table.insert( ret, tname )
			end
		end
	end

	return ret
end

-----------------------
/// DRAW 3D2D DOORS ///
-----------------------
local function on()

	--------------------------
	/// GENERATE DOOR LIST ///
	--------------------------
	ehud.door_list = ehud.door_list or {}
	function ehud:UpdateDoorList()


		-- If not recieved doorlist from server, use ents.getall
		if not ehud.full_door_list then
			local ply = LocalPlayer()
			table.Empty(ehud.door_list)
			local max_dist = (ehud.addon:GetVar("draw_dist") or 75) * 2000
			for _, door in ipairs( ents.GetAll() ) do
				if not IsValid(door) then continue end
				if not isDoor(door) then continue end
				if door:GetPos():DistToSqr(ply:GetPos()) > max_dist then continue end

				local owner = getOwner(door) or 0
				-- if not IsValid(owner) then continue end

				local door_info = {
					ent = door,
					title = getTitle(door),
					owner = owner,
					coowners = getCoowners(door),
					group = getGroup(door)
				}

				table.insert(ehud.door_list, door_info)
			end
			return
		end

		local ply = LocalPlayer()
		local max_dist = (ehud.addon:GetVar("draw_dist") or 75) * 2000

		table.Empty(ehud.door_list)
		for _,ind in ipairs(ehud.full_door_list) do
			local door = ents.GetByIndex(ind)
			if not IsValid(door) then continue end
			if door:GetPos():DistToSqr(ply:GetPos()) > max_dist then continue end

			local owner = getOwner(door)
			-- if not IsValid(owner) and isOwnable( door ) then continue end

			local door_info = {
				ent = door,
				title = getTitle(door),
				owner = owner,
				coowners = getCoowners(door),
				group = getGroup(door)
			}

			table.insert(ehud.door_list, door_info)
		end
	end

	function ehud:ChangeDoorUpdate(seconds)
		timer.Remove("ehud.door_update")
		timer.Create("ehud.door_update", seconds, 0, function() ehud:UpdateDoorList() end) 
	end

	local function override()
		if (not DarkRP) or (not ehud.addon:GetVar("module_hud_doors")) then return end

		net.Start("ehud.RequestDoorList")
		net.SendToServer()

		ehud:ChangeDoorUpdate(3)
	end

	hook.Add("InitPostEntity","ehud.doors_init",override)
	override()

	net.Receive("ehud.SendDoorList", function()
		ehud.full_door_list = esclib:NetReadCompressedTable()
	end)



	-------------------------------
	/// MAIN DOOR DRAW FUNCTION ///
	-------------------------------
	local doorInfo = doorInfo or {}
	local function draw_door_info(door_data,alpha)

		local door = door_data["ent"]
		if not IsValid(door) then return end

		local dinfo = doorInfo[door]

		--Calculates only 1 time 
		if not dinfo then
			dinfo = {}

			local dimens = door:OBBMaxs() - door:OBBMins()
			local center = door:OBBCenter()
			local min, j 

			for i=1, 3 do
				if not min or dimens[i] <= min then
					j = i
					min = dimens[i]
				end
			end

			local norm = Vector()
			norm[j] = 1

			local lang = Angle( 0, norm:Angle().y + 90, 90 )

			if door:GetClass() == "prop_door_rotating" then
				dinfo.lpos = Vector( center.x, center.y, 20 ) + lang:Up() * (min / 6)
			else
				dinfo.lpos = center + Vector( 0, 0, 20 ) + lang:Up() * ((min * 0.5) - 0.1)
			end
			
			dinfo.lang = lang

			doorInfo[door] = dinfo
		end

		-------------------
		/// OWNER CHECK ///
		-------------------
		local owner = door_data["owner"]
		local name
		if owner and not isnumber(owner) then
			if IsValid(owner) then
				name = owner:Nick()
			end
		end
		local title = door_data["title"]
		local group = door_data["group"]
		if not name and not title and not group then return end

		local coowners = door_data["coowners"]

		------------------------
		/// COMPUTING ANGLES ///
		------------------------
		local lpos, lang = Vector(), Angle()
		lpos:Set( dinfo.lpos )
		lang:Set( dinfo.lang )

		local ang = door:LocalToWorldAngles( lang )
		local dot = ang:Up():Dot( 
			LocalPlayer():GetShootPos() - door:WorldSpaceCenter()
		)

		if dot < 0 then
			lang:RotateAroundAxis( lang:Right(), 180 )

			lpos = lpos - (2 * lpos * -lang:Up())
			ang = door:LocalToWorldAngles( lang )
		end

		local pos = door:LocalToWorld( lpos )

		-----------------
		/// MAIN DRAW ///
		-----------------
		local clr = ehud.addon:GetColors()
		local text_color1 = table.Copy(clr.doors.nickname)
		text_color1.a = alpha

		local text_color2 = table.Copy(clr.doors.title)
		text_color2.a = alpha

		local text_color3 = table.Copy(clr.doors.coowner)
		text_color3.a = alpha

		local door_limit_phrase = ehud.addon:Translate("door_coowners_limit")

		cam.Start3D2D( pos, ang, 0.10 )
			local yoffset = 0

			if name then
				esclib.draw:ShadowText(name,"es_ehud_60_500",0, yoffset,text_color1,TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				yoffset = yoffset + 60
			end
			if title or group then
				local newtitle = esclib.util:TextCut(group or title,"es_ehud_60_500",1000)
				if string.len( newtitle ) < string.len( group or title ) then newtitle = newtitle.."..." end
				esclib.draw:ShadowText(newtitle,"es_ehud_60_500",0, yoffset,text_color2,TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				yoffset = yoffset + 60
			end

			if #coowners then
				yoffset = yoffset + 10

				for i = 0, #coowners do
					v = coowners[i]
					if IsValid(v) then
						esclib.draw:ShadowText("+ "..v:Name(),"es_ehud_30_500",0, yoffset,text_color3,TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
						yoffset = yoffset + 34

						if (i > 4) then
							esclib.draw:ShadowText(string.format(door_limit_phrase, #coowners - 5) ,"es_ehud_30_500",0, yoffset,text_color3,TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
							break
						end
					end
				end
			end


		cam.End3D2D()
	end

	hook.Add( "PostDrawTranslucentRenderables", "ehud.doordisplay", function()

		if not ehud.addon then return end

		if (not DarkRP) or (not ehud.addon:GetVar("module_hud_doors")) then 
			hook.Remove("PostDrawTranslucentRenderables", "ehud.doordisplay")
			return
		end

		local ply = LocalPlayer()
		local pl_pos = EyePos()

		local draw_type = 0
		local max_dist = (ehud.addon:GetVar("draw_dist") or 400) * 1000

		if draw_type == 0 then
			if not ehud.door_list then return end
			for _,door in ipairs(ehud.door_list) do
				draw_door_info(door,255)
			end
		else
			local door = ply:GetEyeTrace().Entity

			local fov = 180
			local fov_off = Vector(fov,fov,fov)
			local fov_neg = fov_off * -2

			if not door then return end
			if not isDoor( door ) then return end

			local door_pos = door:GetPos()
			local dist = pl_pos:DistToSqr(door_pos)
			if dist >= max_dist then return end
			local alpha = 255*math.Clamp((1 - dist/max_dist)*5, 0, 1 )

			draw_door_info(door, alpha)
		end

	end)



	------------------
	/// TEXT HINTS ///
	------------------
	hook.Add("HUDPaint","ehud.door_hint",function()
		if not ehud.addon then return end

		if (not DarkRP) or (not ehud.addon:GetVar("module_hud_doors")) then 
			return
		end
		
		local ply = LocalPlayer()
		local trace = ply:GetEyeTrace()
		local ent = trace.Entity
		if not ent then return end
		if not IsValid( ent ) then return end
		if not isDoor( ent ) or not isOwnable( ent ) then return end
		if trace.HitPos:DistToSqr(trace.StartPos) >= 10000 then return end
		if getTitle(ent) then return end
		if getGroup(ent) then return end

		local w = esclib.scrw
		local h = esclib.scrh

		local clr = ehud.addon:GetColors()

		local text
		if (not getOwner( ent ) or isAllowedToCoown( ent, ply )) then
			text = ehud.addon:Translate("door_canbuy")
		end

		if ent:isKeysOwnedBy(ply) then
			text = ehud.addon:Translate("door_canedit")
		end
		if not text then return end

		local font = "es_ehud_24_500"
		local textw, texth = esclib.util:TextSize(text,font)

		esclib.draw:ShadowText(text,font,w*0.5,h-texth*0.5-55,clr.main.text,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		
	end) 

	local function update_doors()
		timer.Simple(0.1,function()
			ehud:UpdateDoorList()
		end)
	end

	local bg
	local function openMenu(setDoorOwnerAccess, doorSettingsAccess)

		local clr = ehud.addon:GetColors()
		local ply = LocalPlayer()

		local trace = ply:GetEyeTrace()
    	local ent = trace.Entity

    	if trace.HitPos:DistToSqr(ply:EyePos()) > 40000 then return end
    	if not IsValid(ent) then return end
    	if not isDoor(ent) and not isVehicle(ent) then return end



		--checks
		local canbuydoor = (not ent:isKeysOwned() and not ent:getKeysNonOwnable() and not ent:getKeysDoorGroup() and not ent:getKeysDoorTeams() or not ent:isKeysOwnedBy(ply) and ent:isKeysAllowedToOwn(ply))
		local islpOwner = ent:isKeysOwnedBy(ply)

		--Auto buy, if only 1 button
		if (canbuydoor) and (not islpOwner) and (not doorSettingsAccess) then
			RunConsoleCommand("darkrp", "toggleown")
			update_doors()
			return
		end

		--Can generate?
		if (not canbuydoor) and (not islpOwner) and (not doorSettingsAccess) then
			return
		end

		if IsValid(bg) then return end
		bg = esclib:GenerateBGClicker()
		bg:SetZPos(1)

		bg.Paint = nil
		function bg:Think()
			local tr = ply:GetEyeTrace()
	       	local LAEnt = tr.Entity
	        if not IsValid(LAEnt) or not LAEnt:isKeysOwnable() or tr.HitPos:DistToSqr(ply:EyePos()) > 40000 then
	            self:Close()
	        end
		end

		local buttonw, buttonh = bg:GetWide()*0.1, 80
		local num_buttons = 0

		local new_panel = bg:Add("DPanel")
		new_panel:SetTall(buttonh+10)
		new_panel.paintblur = true
		local poly = nil
		function new_panel:Paint(w,h)
			-- if self.paintblur then ehud:PaintBlur(self,0,0,w,h) end

			esclib.draw:Mask(function()
				if not poly then
					poly = esclib.util:PrecacheRoundedPoly(0, 0, w, h, 8, 3)
				end
				draw.NoTexture();
				surface.SetDrawColor( color_white )
				surface.DrawPoly( poly )
			end, 
			function()
				surface.SetDrawColor(clr.main.accent.r,clr.main.accent.g,clr.main.accent.b,clr.main.accent.a)
				surface.SetMaterial(ehud.Materials["gradient"])
				surface.DrawTexturedRectRotated(w*0.5,h*0.5+10,h,w,90)

				draw.RoundedBox(0,0,0,w,h,clr.main.bg)
				draw.RoundedBox(0,0,h-4,w,4,clr.main.accent)
			end,false)
		end
		function bg:OnClose()
			new_panel.paintblur = false
		end

		local list = new_panel:Add("DIconLayout")
		list:SetPos(5,3)
		list:SetSpaceX(5)

		local function addButton(name,icon_mat)
			local name = name or "?"

			num_buttons = num_buttons + 1

			local button = list:Add("DButton")
			button:SetSize(buttonw,buttonh)
			button:SetText("")

			local icon
			if icon_mat then
				icon = button:Add("DImage")
				button.icon_panel = icon
				local iconsize = button:GetTall() - esclib.util.GetTextSize(name,"es_ehud_16_500").h-35
				icon:SetSize(iconsize,iconsize)
				icon:SetPos(button:GetWide()*0.5 - icon:GetWide()*0.5,10)
				icon:SetMaterial(icon_mat)
			end

			function button:Paint(w,h)
				local hovered = self:IsHovered()

				if icon_mat then
					if IsValid(icon) then icon:SetImageColor(hovered and clr.main.text or clr.main.text_gray) end
					esclib.draw:ShadowText(name,"es_ehud_16_500",w*0.5,h-10, hovered and clr.main.text or clr.main.text_gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
				else
					esclib.draw:ShadowText(name,"es_ehud_16_500",w*0.5,h*0.5, hovered and clr.main.text or clr.main.text_gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end

			return button
		end

		--SELL
		if islpOwner then
			local button = addButton(ehud.addon:Translate("phrase_sell"), ehud.Materials["dollar.png"])
			function button:DoClick()
				RunConsoleCommand("darkrp", "toggleown")
				update_doors()
				if IsValid(bg) then bg:Close() end
			end
		end

		--BUY
		if canbuydoor then
			local button = addButton(ehud.addon:Translate("phrase_buy"), ehud.Materials["dollar.png"])
			function button:DoClick()
				RunConsoleCommand("darkrp", "toggleown")
				update_doors()
				if IsValid(bg) then bg:Close() end
			end
		end

		--ADMIN EDITS
		if (doorSettingsAccess) and (not islpOwner) then
			--SET OWNABLE
			local button
			if ent:getKeysNonOwnable() then
				button = addButton( ehud.addon:Translate("allow_ownership"), ehud.Materials["true.png"])
			else
				button = addButton( ehud.addon:Translate("disallow_ownership"), ehud.Materials["forbidden.png"])
			end
			
			function button:DoClick()
				RunConsoleCommand("darkrp", "toggleownable")
				update_doors()
				if IsValid(bg) then bg:Close() end
			end

			local button = addButton(ehud.addon:Translate("edit_door_group"), ehud.Materials["group.png"])
			function button:DoClick()
				local menu = DermaMenu()
	            local groups = menu:AddSubMenu(DarkRP.getPhrase("door_groups"))
	            local teams = menu:AddSubMenu(DarkRP.getPhrase("jobs"))
	            local add = teams:AddSubMenu(DarkRP.getPhrase("add"))
	            local remove = teams:AddSubMenu(DarkRP.getPhrase("remove"))

	            menu:AddOption(DarkRP.getPhrase("none"), function()
	                RunConsoleCommand("darkrp", "togglegroupownable")
	                update_doors()
	                if IsValid(bg) then bg:Close() end
	            end)

	            for k in pairs(RPExtraTeamDoors) do
	                groups:AddOption(k, function()
	                    RunConsoleCommand("darkrp", "togglegroupownable", k)
	                    update_doors()
	                    if IsValid(bg) then bg:Close() end
	                end)
	            end

	            local doorTeams = ent:getKeysDoorTeams()
	            for k, v in pairs(RPExtraTeams) do
	                local which = (not doorTeams or not doorTeams[k]) and add or remove
	                which:AddOption(v.name, function()
	                    RunConsoleCommand("darkrp", "toggleteamownable", k)
	                    update_doors()
	                    if IsValid(bg) then bg:Close() end
	                end)
	            end

	            menu:Open()
			end
		end

		--SET TITLE
		if doorSettingsAccess and (ent:isKeysOwned() or ent:getKeysNonOwnable() or ent:getKeysDoorGroup() or hasTeams) or islpOwner then
			local button = addButton(ehud.addon:Translate("phrase_set_title") , ehud.Materials["text.png"])
			function button:DoClick()
				esclib:TextInputWindow(ehud.addon:Translate("phrase_set_title"), "", false, false, function(text)
					if not text then return end

					RunConsoleCommand("darkrp", "title", text)
					update_doors()
					if IsValid(bg) then bg:Close() end
				end)
			end
		end

		if islpOwner then
			--ADD OWNER
			local button = addButton(ehud.addon:Translate("phrase_addowner"), ehud.Materials["true.png"])
			function button:DoClick()

				esclib:PlayerSelectWindow(ehud.addon:Translate("phrase_select_players"), 100, true, function(player_list)
					if player_list then
						for _,v in ipairs(player_list) do
							if IsValid(v) then
								RunConsoleCommand("darkrp", "ao", v:SteamID())
								update_doors()
								if IsValid(bg) then bg:Close() end
							end
						end
					end
				end,
				function(player)
					return not player:IsBot()
				end)
			end

			--REMOVE OWNER
			local button = addButton(ehud.addon:Translate("phrase_remowner"), ehud.Materials["forbidden.png"])
			function button:DoClick()

				esclib:PlayerSelectWindow(ehud.addon:Translate("phrase_select_players"), 100, true, function(player_list)
					if player_list then
						for _,v in ipairs(player_list) do
							--timer.Simple(0.2,function()
								if IsValid(v) then
									RunConsoleCommand("darkrp", "ro", v:SteamID())
									update_doors()
									if IsValid(bg) then bg:Close() end
								end
							--end)
						end
					end
				end,
				function(player)
					return ((ent:isKeysOwnedBy(player) and not ent:isMasterOwner(player)) or ent:isKeysAllowedToOwn(player))
				end)
			end
		end
		
		if num_buttons > 0 then
			new_panel:SetWide(buttonw*num_buttons+list:GetSpaceX()*(num_buttons+1))
			new_panel:CenterHorizontal()
			new_panel:CenterVertical(0.7)
			list:SetSize(new_panel:GetWide(),new_panel:GetTall())
		else
			new_panel:SetMouseInputEnabled(false)
			new_panel:SetSize(bg:GetWide(),bg:GetTall())
			function new_panel:Paint(w,h)
				draw.SimpleText("No actions","es_ehud_24_500",w*0.5,h*0.5,clr.main.text,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			end
			timer.Simple(1,function()
				if IsValid(bg) then bg:Close() end
			end)
			return
		end

		hook.Run("onKeysMenuOpened",ent,new_panel,addButton)
	end

	DarkRP.openKeysMenu = function(um)
	    CAMI.PlayerHasAccess(LocalPlayer(), "DarkRP_SetDoorOwner", function(setDoorOwnerAccess)
	        CAMI.PlayerHasAccess(LocalPlayer(), "DarkRP_ChangeDoorSettings", fp{openMenu, setDoorOwnerAccess})
	    end)
	end
	usermessage.Hook("KeysMenu", DarkRP.openKeysMenu)

	--rewrite gamemode function
	timer.Simple(1, function()
		local gm = GAMEMODE or GM
		gm.ShowTeam = DarkRP.openKeysMenu
	end)

	-----------------
	/// ANIM MENU ///
	-----------------
	function ehud:GetAnimations()
		if not DarkRP then return end
		local Anims = {}
	    Anims[ACT_GMOD_GESTURE_BOW] = DarkRP.getPhrase("bow")
	    Anims[ACT_GMOD_TAUNT_MUSCLE] = DarkRP.getPhrase("sexy_dance")
	    Anims[ACT_GMOD_GESTURE_BECON] = DarkRP.getPhrase("follow_me")
	    Anims[ACT_GMOD_TAUNT_LAUGH] = DarkRP.getPhrase("laugh")
	    Anims[ACT_GMOD_TAUNT_PERSISTENCE] = DarkRP.getPhrase("lion_pose")
	    Anims[ACT_GMOD_GESTURE_DISAGREE] = DarkRP.getPhrase("nonverbal_no")
	    Anims[ACT_GMOD_GESTURE_AGREE] = DarkRP.getPhrase("thumbs_up")
	    Anims[ACT_GMOD_GESTURE_WAVE] = DarkRP.getPhrase("wave")
	    Anims[ACT_GMOD_TAUNT_DANCE] = DarkRP.getPhrase("dance")
	    return Anims
	end



	local bg
	local clr = ehud.addon:GetColors()
	local waitTime = CurTime()+1

	local Anims = ehud:GetAnimations()

	concommand.Remove("_DarkRP_AnimationMenu")
	concommand.Add("_DarkRP_AnimationMenu",function()
		if not istable(Anims) then return end
		if table.IsEmpty(Anims) then return end

		local ct = CurTime()
		if waitTime < ct then 
			if IsValid(bg) then
				waitTime = ct + 0.3
				bg:Close()
				return
			end
		else
			return
		end
		bg = esclib:GenerateBGClicker()
		waitTime = ct + 0.3
		bg.Paint = nil

		local maxw = 0

		for k,v in pairs(Anims) do
			local tw, th = esclib.util:TextSize(v or "?", "es_ehud_20_500")
			if tw > maxw then maxw = tw + 20 end
		end

		local buttonw, buttonh = maxw, draw.GetFontHeight("es_ehud_20_500") + 15
		local bnum = 0

		local new_panel = bg:Add("DPanel")
		new_panel.paintblur = true
		new_panel.Paint = nil
		function bg:OnClose()
			new_panel.paintblur = false
		end

		local list = new_panel:Add("DIconLayout")
		list:SetPos(2,10)
		list:SetSpaceY(1)

		for k,v in pairs(Anims) do
			local button = list:Add("DButton")
			button:SetSize(buttonw,buttonh)
			button:SetText("")
			local text = v or "?"
			if string.len(text) < string.len(v) then text = text.."..." end
			function button:Paint(w,h)
				local hovered = self:IsHovered()
				if hovered then
					draw.RoundedBox(0,0,0,w,h,clr.main.bg)
				end
				if new_panel.paintblur then 
					ehud:PaintBlur(self,0,0,w,h) 
				end
				draw.RoundedBox(0,0,0,w,h,clr.main.bg)
				draw.RoundedBox(0,0,0,3,h,hovered and clr.main.text or clr.main.accent)
				esclib.draw:ShadowText(v or "?","es_ehud_20_500",10,h*0.5, clr.main.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end

			function button:DoClick()
				RunConsoleCommand("_DarkRP_DoAnimation", k)
				bg:Close()
			end
			bnum = bnum + 1
		end

		new_panel:SetSize(buttonw,(buttonh+list:GetSpaceY())*bnum+20)
		new_panel:CenterHorizontal(0.7)
		new_panel:CenterVertical()
		list:SetSize(new_panel:GetWide(),new_panel:GetTall())

	end)

end

local function off()
	hook.Remove("InitPostEntity","ehud.doors_init")
	hook.Remove("HUDPaint","ehud.door_hint")
	hook.Remove("PostDrawTranslucentRenderables", "ehud.doordisplay")

	local text = "[EHUD] "..esclib.addon:Translate("phrase_restart_needed")
	notification.AddLegacy(text, 2, 30)
end

local function custom_check()
	return ehud.addon:GetVar("module_hud_doors") and DarkRP ~= nil
end

ehud:Module("doors_hud",on,off,custom_check)