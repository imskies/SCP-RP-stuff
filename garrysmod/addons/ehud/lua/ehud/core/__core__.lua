local clamp = math.Clamp

esclib:SetFontName("ehud")
esclib:SetFont("Uni Sans Heavy CAPS")
esclib:Font(12, 500)
esclib:Font(14, 500)
esclib:Font(16, 500)
esclib:Font(18, 500)
esclib:Font(20, 500)
esclib:Font(22, 500)
esclib:Font(24, 500) -- es_ehud_24_500
esclib:Font(24, 750)
esclib:Font(28, 500)
esclib:Font(30, 500) -- es_ehud_30_500
esclib:Font(36, 500) -- es_ehud_36_500
esclib:Font(120, 500)
esclib:Font(60, 500)
esclib:Font(300, 500)

esclib:SetFontName("ehud_n")
esclib:SetFont("Amsterdam")
esclib:Font(18, 500) -- es_ehud_n_18_500

ehud.Modules = ehud.Modules or {}
function ehud:Module(uid,enable_func,close_func,custom_check,refresh_once)
	local restart = false
	if self.Modules[uid] then restart = true end
	self.Modules[uid] = {
		["enable"] = enable_func,
		["close"] = close_func,
		["custom_check"] = custom_check,
		["enabled"] = false,
		["refresh_once"] = refresh_once
	}
	if restart then self:Restart() end
end

function ehud:GetModules()
	return self.Modules
end

function ehud:LoadModule(uid,...)
	local v = self.Modules[uid]
	if not v then return end

	local new_enabled = true
	if v["custom_check"] then
		new_enabled = v["custom_check"]()
	end

	local is_enabled = v["enabled"]
	if is_enabled == new_enabled then
		if not v["refresh_once"] and new_enabled then v["enable"](...) end
		return
	else
		if new_enabled then
			v["enable"](...)
		else
			v["close"](...)
		end
	end

	v["enabled"] = new_enabled
end

function ehud:LoadModules(...)
	for uid,_ in pairs(self.Modules) do
		self:LoadModule(uid,...)
	end
end

function ehud:Build()

	if not self.CanBuild then return end
	self.skin = ehud.addon:GetCurrentSkin()
	local clr = self.skin.colors
	local skin = self.skin
	if not skin then return end
	if IsValid(ehud.bg) then ehud.bg:Remove() end

	local ply = LocalPlayer()

	local bg = vgui.Create("DPanel")
	bg:SetSize(esclib.scrw,esclib.scrh)
	bg:SetZPos(-10)
	bg.Paint = nil
	bg:SetMouseInputEnabled(false)
	self.bg = bg

	local blur_areas = {}

	function ehud:PaintBlur(pnl,x,y,w,h)
		if not hook.Run("HUDShouldDraw", "CHudGMod") then return end

		if not IsValid(pnl) then return end
		if not ehud.addon:GetVar("paintblur") then return end
		local px,py = pnl:LocalToScreen()
		local uid = tostring(pnl)

		blur_areas[uid] = {true,true,true,true,true} --init table, causes hashing only once
		local tbl = blur_areas[uid]
		tbl[1] = px+x --x
		tbl[2] = py+y --y
		tbl[3] = w    --width
		tbl[4] = h    --height
		tbl[5] = false
	end

	local blur_panel = bg:Add("DPanel")
	local blur = Material("pp/blurscreen")
	blur_panel:SetSize(bg:GetWide(),bg:GetWide())
	blur_panel:SetZPos()
	local clr_white = clr.default.white
	local x,y = 0,0
	local drawblur= ehud.addon:GetVar("paintblur")

	local mask = esclib.draw.Mask
	function blur_panel:Paint(w,h)
		if not drawblur then return end
		if table.IsEmpty(blur_areas) then return end
		
		surface.SetDrawColor(255, 255, 255)
		esclib.draw:Mask(function()
			for i,v in pairs(blur_areas) do

				if not v[5] then
					surface.DrawRect(v[1],v[2],v[3],v[4])
					v[5] = true
				else
					blur_areas[i] = nil
				end
			end
		end, 
		function()
		    surface.SetMaterial(blur)
		    for i = 1, 3 do
		        blur:SetFloat("$blur", 3)
		        blur:Recompute()
		        render.UpdateScreenEffectTexture()
		        surface.DrawTexturedRect(0,0,esclib.scrw,esclib.scrh)
		    end
		end,false)
	end

	ehud.vars.lerp_x = 0
	ehud.vars.lerp_y = 0

	if ehud.addon:GetVar("dynamic_hud") then
		local prev_ang = Angle(0,0,0)
		local prev_h = 0.0
		function bg:Think()
			local vel = ply:GetPos()[3] or 0
			local vel_dif = clamp(prev_h-vel, -2,4)



			local eye_ang = ply:EyeAngles()
			local or_ang = eye_ang[2]
			eye_ang[2] = math.abs(eye_ang[2])

			local frac_ang = eye_ang - prev_ang

			local frac_x = frac_ang[2]
			local frac_y = -frac_ang[1]-vel_dif

			if not ply:Alive() then 
				frac_x = 0
				frac_y = 0
			end

			if or_ang < 0 then
				ehud.vars.lerp_x = Lerp(0.05, ehud.vars.lerp_x, frac_x*-5)
			else
				ehud.vars.lerp_x = Lerp(0.05, ehud.vars.lerp_x, frac_x*5)
			end
			ehud.vars.lerp_y = Lerp(0.1, ehud.vars.lerp_y, frac_y*5)

			prev_ang = eye_ang

			self:SetX(ehud.vars.lerp_x)
			blur_panel:SetX(-ehud.vars.lerp_x)

			self:SetY(ehud.vars.lerp_y)
			blur_panel:SetY(-ehud.vars.lerp_y)

			prev_h = vel

		end
	end

	self:LoadModules(bg)

end


-----------------------
/// OTHER FUNCTIONS ///
-----------------------
function ehud:IsValid()
	return IsValid(self.bg)
end

function ehud:Remove()
	if self:IsValid() then self.bg:Remove() end
end

function ehud:Restart()
	if self:IsValid() then
		self.bg:Remove() 
	end
	self:Build()
end

hook.Add("ehud_settings_changed","ehud.onsettings_change",function(needrestart, changed_vars)
	if needrestart then
		ehud:Restart()
	end
end)

--if lua refresh 
if ehud:IsValid() then ehud:Restart() end

hook.Add("InitPostEntity","ehud_buildhook",function()
	ehud.CanBuild = true
	ehud:Build()
end)

--RESOLUTION CHANGE
hook.Add( "OnScreenSizeChanged", "ehud.onscreenchange", function(oldw,oldh)
	timer.Simple(1,function() ehud:Restart() end)
end)

concommand.Add("ehud_hide",function()
	if not IsValid(ehud.bg) then return end
	ehud.bg:SetVisible(not ehud.bg:IsVisible())
end)

concommand.Add("ehud_GetMaterials",function()
	PrintTable(ehud.Materials)
end)

concommand.Add("ehud_RequestTest",function()
	esclib.addon:RequestSettings()
end)

concommand.Add("ehud_restart",function()
	ehud:Restart()
end)


concommand.Add("ehud_NotifyTest",function()
	local text = "Hello world (123456789) [AaBbCcDd]"
	notification.AddLegacy(text, 0, 5+math.Rand(0, 1))
	notification.AddLegacy(text, 1, 5+math.Rand(0, 1))
	notification.AddLegacy(text, 2, 5+math.Rand(0, 1))
	notification.AddLegacy(text, 3, 5+math.Rand(0, 1))
	notification.AddLegacy(text, 4, 5+math.Rand(0, 1))

	notification.AddProgress("ehud_notifytest1", text)
	timer.Simple(5, function()
		notification.Kill("ehud_notifytest1")
	end)

	notification.AddProgress("ehud_notifytest2", text, 0)
	timer.Simple(2, function()
		notification.AddProgress("ehud_notifytest2", text, 0.2)
	end)
	timer.Simple(3, function()
		notification.AddProgress("ehud_notifytest2", text, 0.6)
	end)
	timer.Simple(4, function()
		notification.AddProgress("ehud_notifytest2", text, 1)
	end)
	timer.Simple(5, function()
		notification.Kill("ehud_notifytest2")
	end)
end)


hook.Add("ehud_skin_changed","ehud.skin_changed_reload",function(skin_name)
	local skin = ehud.addon:GetCurrentSkin()
	if skin then
		ehud.skin = skin
		ehud:Restart()
	end
end)


-------------------------
/// HIDE HUD ELEMENTS ///
-------------------------
-- https://wiki.facepunch.com/gmod/HUD_Element_List
local toHide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudDamageIndicator"] = true,
	["CHudPoisonDamageIndicator"] = true,
	["CHudSquadStatus"] = true,
	["CHudBattery"] = true,
	["CHudVoiceStatus"] = true,

	["DarkRP_HUD"] = true,
	["DarkRP_Hungermod"] = true,
	["DarkRP_LocalPlayerHUD"] = true,
	["DarkRP_EntityDisplay"] = true,
	["DarkRP_Agenda"] = true,
	["DarkRP_LockdownHUD"] = true,
	["DarkRP_ArrestedHUD"] = true,
	["DarkRP_VoiceChat"] = true,

	["TTTInfoPanel"] = true,
	["TTTSpecHUD"] = true,
}

hook.Add("HUDShouldDraw", "ehud_hidehud", function( name )
	if toHide[name] then return false end
end)