-------------------------------
/// IMPACT BLUR / HITMARKER ///
-------------------------------

local min = math.min
local max = math.max

local function on()
	local blur = Material("pp/blurscreen")
	local not_blur_valid = blur:IsError()
	local function edraw_blur( a, d )
		if not_blur_valid then return end
		surface.SetDrawColor( 255, 255, 255 )
		surface.SetMaterial( blur )
		for i = 1, d do
		
			blur:SetFloat( "$blur", (i / d ) * ( a ) )
			blur:Recompute()
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect( 0, 0, esclib.scrw, esclib.scrh )
			
		end
	end

	local edraw_blur = edraw_blur

	ehud.vars.impactblurlerp = 0
	ehud.vars.hitmarker_time = 0
	ehud.vars.hitmarker_damage = 0
	ehud.vars.hitmarker_color = Color(255,255,255)
	hook.Add("HUDPaint", "ehud.DrawImpact", function()

		local w, h = esclib.scrw, esclib.scrh
		if (ehud.vars.impactblurlerp > 0) and (ehud.config.blur_on_damage) then
			local min_len = max(ehud.config.heartbeat_speed, 1)
			ehud.vars.impactblurlerp = math.Approach(ehud.vars.impactblurlerp, 0, min_len * RealFrameTime())
			edraw_blur(min(ehud.vars.impactblurlerp, min_len), ehud.config.heartbeat_strength)
			surface.SetDrawColor(255, 0, 0, 2*ehud.vars.impactblurlerp)
			surface.DrawRect(0,0,w,h)
		end

		if (ehud.vars.hitmarker_time > CurTime()) then
			esclib.draw:MaterialCentered(w*0.5,h*0.5, 12, ehud.vars.hitmarker_color, ehud.Materials["hitmarker.png"])
			draw.SimpleText(esclib.util:Round(ehud.vars.hitmarker_damage),"es_ehud_20_500",w*0.5+12,h*0.5+10, ehud.vars.hitmarker_color,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		else
			ehud.vars.hitmarker_damage = 0
		end

	end)

	function ehud:DoImpactBlur(intensity)
		ehud.vars.impactblurlerp = intensity
	end

	function ehud:DoHitmark(time, damage)
		ehud.vars.hitmarker_time = CurTime() + time
		ehud.vars.hitmarker_damage = ehud.vars.hitmarker_damage + damage
	end

	net.Receive("ehud.damage_informer", function()
		local for_me = net.ReadBit() ~= 0
		local damage = net.ReadFloat()

		if for_me then
			ehud:DoImpactBlur(2)
			ehud.vars.lerp_y = -20
		else
			if ehud.addon:GetVar("module_hitmarker") then
				surface.PlaySound( "ehud_hitmark.wav" )
				ehud:DoHitmark(0.2, damage)
			end
		end
	end)
end

local function off()
	hook.Remove("HUDPaint", "ehud.DrawImpact")
end

local function custom_check()
	return true
end

ehud:Module("impact",on,off,custom_check)