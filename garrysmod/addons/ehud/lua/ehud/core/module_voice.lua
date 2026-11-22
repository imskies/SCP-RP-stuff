local function on()
	--Remove SandBox Voice
	local function voice_rewrite()
		timer.Simple(0, function()
			if ehud.TTT then
				if IsValid(g_VoicePanelList) then g_VoicePanelList:SetVisible(false) end
			else
				g_VoicePanelList = nil
			end
		end)
	end
	hook.Add("InitPostEntity", "ehud.VoicePanelList_rewrite", voice_rewrite)
	voice_rewrite()

	--Change position of all voice panels
	local function InvalidateVoice()
	    local panels = ehud.vars.voice_panels

	    local panel
	    local startPos = esclib.scrh*0.7
	    local totalh = 0

	    for k,v in pairs(panels) do
	        panel = v

	        if not IsValid(panel) then
	        	panels[k] = nil
	            InvalidateVoice()
	            return
	        end

	        totalh = totalh + panel:GetTall() + 5

	        panel.busy = true
	        panel:MoveTo(esclib.scrw - panel:GetWide()-5,startPos - totalh, 0.1, 0, -1, function()
	        	if IsValid(panel) then
	        		panel.busy = false
	        	end
	        end)
	    end
	end


	ehud.vars.voice_panels = ehud.vars.voice_panels or {}

	hook.Add("PlayerStartVoice", "ehud.start_voice_panel",function(ply)
		local panels = ehud.vars.voice_panels
		if panels[ply] then  
			if IsValid(panels[ply]) then
				return
			else
				panels[ply] = nil
			end
		end

		local bg = ehud.bg
		if not IsValid(bg) then return end
		local clr = ehud.addon:GetColors()

		panels[ply] = bg:Add("DPanel")
		local pnl = panels[ply]
		pnl:SetX(esclib.scrw)
		pnl:SetY(esclib.scrh*0.7)
		pnl.player = ply

		local nickname = ply:Nick() or "?"
		local font = "es_ehud_20_500"
		local textw,texth = esclib.util:TextSize(nickname,font)
		pnl:SetSize(textw+texth*2+15,texth+16)
		pnl.clr = clr.main.accent

		if ehud.TTT then
			pnl.clr = Color(0,255,0)

			local client = LocalPlayer()
			if client:IsActiveTraitor() then
				if ply == client then
					if not client.traitor_gvoice then
						pnl.clr = Color(200, 20, 20, 255)
					end
				elseif ply:IsActiveTraitor() then
					if not ply.traitor_gvoice then
						pnl.clr = Color(200, 20, 20, 255)
					end
				end
			end
		  
			if ply:IsActiveDetective() then
				pnl.clr = Color(20, 20, 200, 255)
			end
		end

		local avatar = pnl:Add( "AvatarImage")
		avatar:SetSize(pnl:GetTall()-4,pnl:GetTall()-4)
		avatar:CenterVertical()
		avatar:SetX(2)
		avatar:SetPlayer(ply,64)

		local num_volumes = 8
		local cur_volume = 0

		local volumes = {}

		local gap = pnl:GetWide() / num_volumes
		function pnl:Paint(w,h)
			if not IsValid(self.player) then return end

			ehud:PaintBlur(self,0,0,w,h)

			--volume block
			local captured_volume = self.player:VoiceVolume() or 0
			cur_volume = cur_volume + 1

			if cur_volume > num_volumes then
				cur_volume = 1
			end
			volumes[cur_volume] = captured_volume

			--gradient
			local jobclr = self.clr
			surface.SetDrawColor(jobclr.r,jobclr.g,jobclr.b,jobclr.a)
	        surface.SetMaterial(ehud.Materials["gradient"])
	        surface.DrawTexturedRectRotated(w*0.5,h-(h*captured_volume),h,w,90)

	        --bg
	        surface.SetDrawColor(clr.main.bg)
	        surface.DrawRect(0,0,w,h)

			surface.SetDrawColor(jobclr.r,jobclr.g,jobclr.b,jobclr.a)
			surface.DrawRect(0,h-2,w,2)

			for k,v in ipairs(volumes) do
	        	surface.DrawRect(gap*(k-1)+2,h-(h*v),gap-2,h)
	        end

			draw.SimpleText(nickname,font,h+7, h*0.5, clr.main.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		function pnl:Think()
			if not IsValid(self.player) then
				self:Close()
				return
			end
			if not ehud.voiceActors[self.player:UserID()] then
				self:Close()
				return
			end
		end

		function pnl:Close()
			if not self.busy then
				self.busy = true
		        self:MoveTo(bg:GetWide(),self:GetY(),0.1,0,-1,function()
		            panels[ply] = nil
		            if IsValid(self) then self:Remove() end
		            InvalidateVoice()
		        end)
		    else
		    	if IsValid(self) then self:Remove() end
		    	InvalidateVoice()
		    end
		end

		InvalidateVoice()

		-- return true

	end)

	hook.Add("PlayerEndVoice", "ehud.end_voice_panel",function(ply)
		local panels = ehud.vars.voice_panels
		if panels[ply] then  
			if IsValid(panels[ply]) then
				panels[ply]:Close()
			else
				panels[ply] = nil
			end
		end
	end)

	--For example
	concommand.Add("ehud_VoiceCheck",function()
		local adjust = 0
		for k,v in ipairs(player.GetAll()) do
			hook.Run("PlayerStartVoice", v)
			timer.Simple(3+adjust,function()
				hook.Run("PlayerEndVoice", v)
			end)
			adjust = adjust + math.random(0, 1)
		end
	end)
end


local function off()
	if ehud.TTT then
		if IsValid(g_VoicePanelList) then g_VoicePanelList:SetVisible(false) end
	else
		g_VoicePanelList = g_VoicePanelList or {}
	end
	hook.Remove("PlayerStartVoice", "ehud.start_voice_panel")
	hook.Remove("PlayerEndVoice", "ehud.end_voice_panel")
	concommand.Remove("ehud_VoiceCheck")
end

local function custom_check()
	return ehud.addon:GetVar("module_voice")
end

ehud:Module("voice",on,off,custom_check)