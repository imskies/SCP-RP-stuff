
ehud.notices = ehud.notices or {}

local function on()
	local Notices = ehud.notices
	function notification.AddProgress( uid, text, frac )

		if ( IsValid( Notices[ uid ] ) ) then

			Notices[ uid ].StartTime = SysTime()
			Notices[ uid ].Length = -1
			Notices[ uid ]:SetText( text )
			Notices[ uid ]:SetProgress( frac )
			return

		end

		local parent = nil
		if ( GetOverlayPanel ) then parent = GetHUDPanel() end

		local Panel = vgui.Create( "ehud.notice_panel", parent )
		Panel.StartTime = SysTime()
		Panel.Length = -1
		Panel.VelX = -5
		Panel.VelY = 0
		Panel.fx = esclib.scrw + 200
		Panel.fy = esclib.scrh
		Panel:SetAlpha( 255 )
		Panel:SetZPos(1)
		Panel:SetText( text )
		Panel:SetPos( Panel.fx, Panel.fy )
		Panel:SetProgress( frac )

		Notices[ uid ] = Panel

	end

	function notification.Kill( uid )

		if ( not IsValid( Notices[ uid ] ) ) then return end

		Notices[ uid ].StartTime = SysTime()
		Notices[ uid ].Length = 0.8

	end

	function notification.AddLegacy( text, type, length )

		local parent = ehud.bg
		if not IsValid(parent) then
			if ( GetOverlayPanel ) then parent = GetOverlayPanel() end
		end

		local Panel = vgui.Create( "ehud.notice_panel", parent )
		Panel.StartTime = SysTime()
		Panel.Length = math.max( length, 0 )
		Panel.VelX = -5
		Panel.VelY = 0
		Panel.fx = esclib.scrw + 200
		Panel.fy = esclib.scrh
		Panel:SetAlpha( 255 )
		Panel:SetText( text )
		Panel:SetZPos(1)
		Panel:SetLegacyType( type )
		Panel:SetPos( Panel.fx, Panel.fy )

		table.insert( Notices, Panel )

	end

	local function UpdateNotice( pnl, total_h )

		if not pnl then return end
		if not IsValid(pnl) then return end
		if not total_h then total_h = 0 end

		local x = pnl.fx
		local y = pnl.fy

		local w = pnl:GetWide() + 16
		local h = pnl:GetTall() + 4

		local ideal_y = esclib.scrh - 150 - h - total_h
		local ideal_x = esclib.scrw - w

		local timeleft = pnl.StartTime - ( SysTime() - pnl.Length )
		if ( pnl.Length < 0 ) then timeleft = 1 end

		if ( timeleft < 0.2 ) then
			ideal_x = ideal_x + w * 2
		end

		local spd = RealFrameTime() * 15

		y = y + pnl.VelY * spd
		x = x + pnl.VelX * spd

		local dist = ideal_y - y
		pnl.VelY = pnl.VelY + dist * spd
		if ( math.abs( dist ) < 5 && math.abs( pnl.VelY ) < 0.1 ) then pnl.VelY = 0 end
		
		dist = ideal_x - x
		pnl.VelX = pnl.VelX + dist * spd
		if ( math.abs( dist ) < 2 && math.abs( pnl.VelX ) < 0.1 ) then pnl.VelX = 0 end

		-- Friction.. kind of FPS independant.
		pnl.VelX = pnl.VelX * ( 0.95 - RealFrameTime() * 8 )
		pnl.VelY = pnl.VelY * ( 0.95 - RealFrameTime() * 8 )

		pnl.fx = x
		pnl.fy = y

		-- If the panel is too high up (out of screen), do not update its position. This lags a lot when there are lot of panels outside of the screen
		if ( ideal_y > -esclib.scrh ) then
			pnl:SetPos( pnl.fx, pnl.fy )
		end

		return total_h + h

	end

	local function Update()

		if ( not Notices ) then return end

		local h = 0
		for key, pnl in pairs( Notices ) do

			h = UpdateNotice( pnl, h )

		end

		for k, Panel in pairs( Notices ) do

			if ( not IsValid( Panel ) || Panel:KillSelf() ) then Notices[ k ] = nil end

		end

	end

	if DarkRP then
		--https://github.com/FPtje/DarkRP/blob/a266f9fba5d1bab03ca37d1960e92cdac69a486d/gamemode/modules/hud/cl_hud.lua#L220-L235
		local AdminTell = function() end
		local clr = ehud.addon:GetColors()

		usermessage.Hook("AdminTell", function(msg)
			timer.Remove("DarkRP_AdminTell")
			local Message = msg:ReadString()
			local Scrw = ScrW()
			local offset_y = draw.GetFontHeight("es_ehud_30_500")

			AdminTell = function()
				esclib.draw:ShadowText(DarkRP.getPhrase("listen_up"), "es_ehud_30_500", Scrw / 2 + 10, 10, clr.notify.generic, TEXT_ALIGN_CENTER)
				esclib.draw:ShadowText(Message, "es_ehud_20_500", Scrw / 2 + 10, offset_y+15, clr.notify.generic, TEXT_ALIGN_CENTER)
			end

			timer.Create("DarkRP_AdminTell", 10, 1, function()
				Scrw = ScrW()
				AdminTell = function() end
			end)
		end)

		hook.Add( "HUDPaint", "ehud.draw.admintell", function()
			AdminTell()
		end)

	end

	hook.Add( "Think", "ehud.notify_think", Update )
end

local function off()
	local text = "[EHUD] "..esclib.addon:Translate("phrase_restart_needed")
	notification.AddLegacy(text, 2, 30)
end

local function custom_check()
	return ehud.addon:GetVar("module_notify")
end

ehud:Module("notify",on,off,custom_check)