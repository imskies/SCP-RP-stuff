/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if SERVER then return end

zbl = zbl or {}
zbl.ScreenEffect = zbl.ScreenEffect or {}

local DSP_Active = false

local function DrawScreenEffect(p_data)
	if p_data.colormodify then
		local tab = {
			["$pp_colour_addr"] = p_data.colormodify["pp_colour_addr"],
			["$pp_colour_addg"] = p_data.colormodify["pp_colour_addg"],
			["$pp_colour_addb"] = p_data.colormodify["pp_colour_addb"],
			["$pp_colour_brightness"] = p_data.colormodify["pp_colour_brightness"],
			["$pp_colour_contrast"] = p_data.colormodify["pp_colour_contrast"],
			["$pp_colour_colour"] = p_data.colormodify["pp_colour_colour"],
			["$pp_colour_mulr"] = p_data.colormodify["pp_colour_mulr"],
			["$pp_colour_mulg"] = p_data.colormodify["pp_colour_mulg"],
			["$pp_colour_mulb"] = p_data.colormodify["pp_colour_mulb"]
		}

		DrawColorModify(tab)
	end

	if p_data.b_blur then
		DrawToyTown(10 / 100 * p_data.b_blur, 5 * p_data.b_blur)
	end

	if zclib.Convar.Get("zbl_cl_epilepsy") == 0  then

		if p_data.m_blur then
			DrawMotionBlur(0.2, 0.4 * p_data.m_blur, 0.1 * p_data.m_blur)
		end

		if p_data.mat then
			DrawMaterialOverlay(p_data.mat, 0)
		end

		if p_data.warp_mat then
			DrawMaterialOverlay(p_data.warp_mat, 0)
		end
	end

	if p_data.audio_filter and DSP_Active == false then
		LocalPlayer():SetDSP(p_data.audio_filter,true)
		DSP_Active = true
	end

	if p_data.bloom then
		DrawBloom(0, 1, 1, 1, 15, 0.1, p_data.bloom[1], p_data.bloom[2], p_data.bloom[3])
	end
end

local cough_strength = 0
net.Receive("zbl_scfx_cough", function(len)
	cough_strength = 1
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

local vomit_strength = 0
net.Receive("zbl_scfx_vomit", function(len)
	vomit_strength = 1
end)

zclib.Hook.Add("RenderScreenspaceEffects", "zbl_Sickness", function()
	local vaccineID = zbl.Vaccine.Get(LocalPlayer())

	if vaccineID ~= -1 then
		local percetionData = zbl.Vaccine.GetPerception_Data(vaccineID, zbl.Vaccine.GetStage(LocalPlayer()))
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

		if percetionData then
			DrawScreenEffect(percetionData)
		end
	else
		if DSP_Active == true then
			LocalPlayer():SetDSP(0, true)
			DSP_Active = false
		end
	end

	if cough_strength > 0 then
		cough_strength = math.Clamp(cough_strength - 1 * FrameTime(), 0, 1)
		DrawToyTown(5 * cough_strength, (600 / 1) * cough_strength)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

		local tab = {
			["$pp_colour_addr"] = 0.15 * cough_strength,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 1,
			["$pp_colour_colour"] = math.Clamp(cough_strength, 0.9, 1),
			["$pp_colour_mulr"] = cough_strength,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		}

		DrawColorModify(tab)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

	if vomit_strength > 0 then
		vomit_strength = math.Clamp(vomit_strength - 1 * FrameTime(), 0, 1)
		DrawSharpen(1.25 * vomit_strength, 1)
		DrawToyTown(5 * vomit_strength, (600 / 1) * vomit_strength)

		local tab = {
			["$pp_colour_addr"] = 0,
			["$pp_colour_addg"] = 0.25 * vomit_strength,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 1,
			["$pp_colour_colour"] = 1 - vomit_strength,
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = vomit_strength * 0.5,
			["$pp_colour_mulb"] = 0
		}

		DrawColorModify(tab)
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24
