
ehud.vars.agenda_panel = ehud.vars.agenda_panel or {}
-- if IsValid(ehud.vars.agenda_panel) then ehud.vars.agenda_panel:Remove() end --lua refresh

local function on()
	local bg = ehud.bg
	local clr = ehud.addon:GetColors()
	local agenda_panel = ehud.vars.agenda_panel

	local max_wide = esclib.scrw*0.2
	local font = "es_ehud_n_18_500"
	local panel_accent = clr.main.accent
	local title = ehud.addon:Translate("agenda_title")
	local titlefont = "es_ehud_20_500"
	local titlew, titleh = esclib.util:TextSize(title,"es_ehud_20_500")

	if IsValid(ehud.vars.agenda_panel) then ehud.vars.agenda_panel:Remove() end
	if not IsValid(bg) then return end

	--update hooks
	hook.Add("DarkRPVarChanged","ehud.agenda.onchange.darkrpvar",function(ply,var,_,agenda_text)
		if not var then return end
		if var ~= "agenda" then return end
		if IsValid(ehud.vars.agenda_panel) then ehud.vars.agenda_panel:Remove() end
		if not agenda_text then return end
		if string.len(agenda_text) < 1 then return end

		local agenda_multiline = esclib.text:Multiline(agenda_text or "",font,max_wide)
		local title_offset = titleh+5

		ehud.vars.agenda_panel = vgui.Create("DButton")
		local agenda_panel = ehud.vars.agenda_panel
		agenda_panel:SetSize(math.max(agenda_multiline.width+10, titlew+20),agenda_multiline.height+title_offset+14)
		agenda_panel:SetPos(5,5)
		agenda_panel:SetText("")
		function agenda_panel:Paint(w,h)
			local hovered = self:IsHovered()

			ehud:PaintBlur(self,0,0,w,h)

			surface.SetDrawColor(panel_accent.r,panel_accent.g,panel_accent.b,panel_accent.a)
	        surface.SetMaterial(ehud.Materials["gradient"])
	        surface.DrawTexturedRectRotated(w*0.5,h,100,w,90)

	        surface.SetDrawColor(clr.main.bg)
	        surface.DrawRect(0,0,w+5,h)

	        surface.SetDrawColor(panel_accent.r,panel_accent.g,panel_accent.b,panel_accent.a)
	        surface.DrawRect(0,h-2,w,2)

			if hovered then
				draw.SimpleText("r","Marlett",w*0.5,h*0.5,clr.main.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				esclib.draw:ShadowText(title,titlefont,8,4,clr.main.text,nil,nil,1)

		        surface.DrawLine(0, title_offset+2, w, title_offset+2)

				esclib.text:DrawMultiline(agenda_multiline,6,title_offset+9,clr.default.shadow)
				esclib.text:DrawMultiline(agenda_multiline,5,title_offset+8,clr.main.text)
			end
		end

		function agenda_panel:DoClick()
			self:Close()
		end

		function agenda_panel:Close()
			self.closing = true
			self:MoveTo(-self:GetWide(),self:GetY(),0.2,0,3,function()
				self:Remove()
			end)
		end
	end)

end

local function off()
	if IsValid(ehud.vars.agenda_panel) then ehud.vars.agenda_panel:Remove() end

	hook.Remove("DarkRPVarChanged","ehud.agenda.onchange.darkrpvar")
end

local function custom_check()
	return ehud.addon:GetVar("module_agenda")
end


ehud:Module("agenda",on,off,custom_check)