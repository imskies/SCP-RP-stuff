local last_tick = CurTime()

ehud.vars.crashscreen = ehud.vars.crashscreen or nil
if IsValid(ehud.vars.crashscreen) then
	ehud.vars.crashscreen:Remove()
end

local closed_menu = false
local function on()

	timer.Create("ehud.crashscreen.tickchecker", 0.1, 0, function ()
	    last_tick = CurTime()
	end)

	hook.Add("Think", "ehud.crashscreen.update", function ()
	    if (CurTime() - last_tick >= 1.3) then
	    	if IsValid(ehud.vars.crashscreen) then return end
	    	if not ehud then return end
	    	if closed_menu then return end
	    	local clr = ehud.addon:GetColors()
	    	local start_time = RealTime()
	    	local max_time = ehud.config.reconnect_time

	    	local x = esclib.scrw
	    	local y = esclib.scrh

	    	ehud.vars.crashscreen = vgui.Create("DPanel")
	    	local crashscreen = ehud.vars.crashscreen
	    	crashscreen:SetSize(x,y)
	    	crashscreen:SetAlpha(0)
	    	crashscreen:AlphaTo(255,1)
	    	crashscreen:MakePopup()

	    	local crash_title = ehud.addon:Translate("crash_title")
	    	local crash_desc = ehud.addon:Translate("crash_subtitle")
	    	local crash_auto_rec = ehud.addon:Translate("crash_auto_reconnect")
	    	local jobclr = clr.main.bg

	    	local cur_seconds = 0

	    	local time_offset = draw.GetFontHeight("es_ehud_300_500")*0.5+10
	    	function crashscreen:Paint(w,h)
	    		ehud:PaintBlur(self,0,0,w,h)

	    		surface.SetDrawColor(jobclr.r,jobclr.g,jobclr.b,jobclr.a)
		        surface.SetMaterial(ehud.Materials["gradient"])
		        surface.DrawTexturedRectRotated(w*0.5,h*0.5,h,w,90)

	    		draw.RoundedBox(0,0,0,w,h,clr.main.bg)

	    		draw.SimpleText(crash_title,"es_ehud_120_500", w*0.1, h*0.3, clr.default.red,TEXT_ALIGN_LEFT,TEXT_ALIGN_BOTTOM)
	    		draw.SimpleText(crash_desc,"es_ehud_28_500", w*0.1, h*0.3, clr.main.text_gray,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)

	    		--auto reconnect
	    		local time_remain = esclib.util:Round(max_time-cur_seconds)
	    		draw.SimpleText(time_remain,"es_ehud_300_500",w*0.7,h*0.5,(time_remain < 10) and clr.default.red or clr.main.text,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

	    		draw.SimpleText(crash_auto_rec,"es_ehud_30_500",w*0.7,h*0.5+time_offset,clr.main.text_gray,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)

	    	end

	    	function crashscreen:Think()
	    		cur_seconds = RealTime()-start_time

	    		if cur_seconds+1 > max_time then
	    			RunConsoleCommand("retry") --reconnect
	    		end
	    	end

	    	local btn_text = ehud.addon:Translate("crash_reconnect")
			local reconnect_btn = crashscreen:Add("DButton")
			reconnect_btn:SetSize(400,60)
			reconnect_btn:SetText("")
			reconnect_btn:SetPos(x*0.1,y*0.5-reconnect_btn:GetTall())
			function reconnect_btn:Paint(w,h)
				local hovered = self:IsHovered()
				draw.RoundedBox(32,0,0,w,h,clr.main.bg)
				draw.SimpleText(btn_text,"es_ehud_30_500",w*0.5,h*0.5, hovered and clr.default.green or clr.main.text_gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			function reconnect_btn:DoClick()
				RunConsoleCommand("retry")
			end

			local btn_text =  ehud.addon:Translate("crash_close")
			local close_btn = crashscreen:Add("DButton")
			close_btn:SetSize(reconnect_btn:GetWide(),reconnect_btn:GetTall())
			close_btn:SetText("")
			close_btn:SetPos(reconnect_btn:GetX(),reconnect_btn:GetY()+10+close_btn:GetTall())	    
			function close_btn:Paint(w,h)
				local hovered = self:IsHovered()
				draw.RoundedBox(32,0,0,w,h,clr.main.bg)
				draw.SimpleText(btn_text,"es_ehud_30_500",w*0.5,h*0.5, hovered and clr.default.red or clr.main.text_gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			function close_btn:DoClick()
				crashscreen:Remove()
				closed_menu = true
			end


	        --show
	    else
	    	if IsValid(ehud.vars.crashscreen) then ehud.vars.crashscreen:Remove() end
	   	end
	end)

end

local function off()
	timer.Remove("ehud.crashscreen.tickchecker")
	hook.Remove("Think", "ehud.crashscreen.update")
	if IsValid(ehud.vars.crashscreen) then ehud.vars.crashscreen:Remove() end
end

local function custom_check()
	return ehud.addon:GetVar("module_crashscreen")
end

ehud:Module("crashscreen",on,off,custom_check)