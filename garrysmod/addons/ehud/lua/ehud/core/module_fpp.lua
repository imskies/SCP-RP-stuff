-------------------
/// FPP NOTICES ///
-------------------
local function on()
	local notices = {}
	local ply = LocalPlayer()
	local clr = ehud.addon:GetColors()

	local function UpdatePositions()
		local size = 0
		for k,v in pairs(notices) do
			if not IsValid(v) then
				notices[k] = nil
				continue
			end

			size = size + v:GetTall()
			v:MoveTo(v:GetX(), esclib.scrh - size, 0.1)
		end
	end

	local function FPPNotify(str, type)
		local bg = ehud.bg
		if not IsValid(bg) then return end
		local str = str or "?"

		local clr = ehud.addon:GetColors()


		if not notices[str] then
			local font = "es_ehud_20_500"
			local tw,th = esclib.util:TextSize(str,font)

			notices[str] = vgui.Create("DPanel")
			local panel = notices[str]
			panel:SetSize(tw+10, th+10)
			panel:CenterHorizontal()
			panel:SetY(esclib.scrh - panel:GetTall()-5)
			panel.mult = 0

			function panel:Close()
				self.closing = true
				self:MoveTo(self:GetX(), esclib.scrh, 0.1, 0, -1, function()
					if not IsValid(self) then UpdatePositions() return end
					self:Remove()
					UpdatePositions()
				end)
			end

			function panel:eUpdate()
				self.mult = self.mult + 1
				self.timeLeft = CurTime()+5

				local add = self.mult and (" x"..self.mult) or ""
				local tw,th = esclib.util:TextSize(str..add,font)
				self:SetSize(tw+10,th+10)
			end
			panel:eUpdate()

			function panel:Think()
				if (self.timeLeft < CurTime()) and not (self.closing) then
					self:Close()
					return
				end
			end

			function panel:Paint(w,h)
				local add = self.mult and (" x"..self.mult) or ""
				esclib.draw:ShadowText(str, font, w-2, h*0.5, type and clr.default.green or clr.default.red, TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
				esclib.draw:ShadowText(add, font, 2, h*0.5, clr.main.text, TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			end

			UpdatePositions()
		else
			if IsValid(notices[str]) then
				notices[str]:eUpdate()
			else
				notices[str] = nil
			end
			UpdatePositions()
		end
	end

	usermessage.Hook("FPP_Notify", function(u) FPPNotify(u:ReadString(), u:ReadBool()) end)

	local function fpp_rewrite()
		if not ehud.addon:GetVar("module_fpp") then return end

		if FPP then
			if FPP.AddNotify then
				FPP.AddNotify = FPPNotify
			end
			hook.Remove("HUDPaint", "FPP_HUDPaint")
	 	end
	end

	hook.Add("OnGamemodeLoaded","ehud.fpp_rewrite",function()
		timer.Simple(1,function()
			fpp_rewrite()
		end)
	end)

	fpp_rewrite()

	local weaponClassTouchTypes = {
	    ["weapon_physgun"] = "Physgun",
	    ["weapon_physcannon"] = "Gravgun",
	    ["gmod_tool"] = "Toolgun",
	}

	local w = esclib.scrw
	local h = esclib.scrh
	hook.Add("HUDPaint", "ehud.fpp_paint",function()
		if not FPP then return end
		if ply:InVehicle() then return end

	    local eyeTrace = ply:GetEyeTrace()
	    if eyeTrace == nil then return end

	    if eyeTrace.HitPos:DistToSqr(eyeTrace.StartPos) > ehud.addon:GetVar("draw_dist")*500 then return end

	    local LAEnt = eyeTrace.Entity
	    if not IsValid(LAEnt) then return end

	    local weapon = ply:GetActiveWeapon()
	    local class = weapon:IsValid() and weapon:GetClass() or ""

	    local touchType = weaponClassTouchTypes[class] or "EntityDamage"
	    local reason = FPP.entGetTouchReason(LAEnt, touchType)
	    if not reason then return end

	    local originalOwner = LAEnt:GetNW2String("FPP_OriginalOwner")
	    originalOwner = originalOwner ~= "" and (" (previous owner: %s)"):format(originalOwner) or ""
	    reason = reason .. originalOwner

	    local col = FPP.canTouchEnt(LAEnt, touchType) and clr.default.green or clr.default.red

	    esclib.draw:ShadowText(reason, "es_ehud_n_18_500", 5, h*0.5, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER,1)
	end)
end

local function off()
	local text = "[EHUD] "..esclib.addon:Translate("phrase_restart_needed")
	notification.AddLegacy(text, 2, 30)

	hook.Remove("HUDPaint", "ehud.fpp_paint")
end

local function custom_check()
	return ehud.addon:GetVar("module_fpp")
end

ehud:Module("fpp_notify",on,off,custom_check)