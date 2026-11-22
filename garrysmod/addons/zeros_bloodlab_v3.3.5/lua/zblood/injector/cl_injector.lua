/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if SERVER then return end
zbl = zbl or {}
zbl.Injector = zbl.Injector or {}


function zbl.Injector.Initialize(swep)
	zclib.Debug("zbl.Injector.Initialize")

	swep:SetHoldType(swep.HoldType)

	zbl.Injector.FlaskSequenceChanged(swep,swep:GetFlaskSequence())
end

function zbl.Injector.Primary(swep)
end

function zbl.Injector.Secondary(swep)
end

function zbl.Injector.Equip(swep)
end

function zbl.Injector.Deploy(swep)
end

function zbl.Injector.Holster(swep)
end

function zbl.Injector.Think(swep)
end

function zbl.Injector.FlaskSequenceChanged(swep,s_new_sequence)
	if not isstring(s_new_sequence) then return end
	zclib.Debug("zbl.Injector.FlaskSequenceChanged: " .. s_new_sequence)
	local seq_tbl = string.Split(s_new_sequence,"_" )
	swep.FlaskSequence = {}

	if seq_tbl and #seq_tbl > 0 then
		for k,v in pairs(seq_tbl) do
			local val = tonumber(v)

			// If for some reason the flask value is nill then lets set it to 0 (EMPTY)
			if val == nil then
				val = 0
			end

			swep.FlaskSequence[k] = val
		end
	end
end

// Uses the FlaskSequence to figure out which flask_id is empty
function zbl.Injector.GetEmptyFlask(swep)
	local emptyflask_id
	if IsValid(swep) and swep.FlaskSequence then
		for flask_id,flask_value in pairs(swep.FlaskSequence) do
			if flask_value == 0 then
				emptyflask_id = flask_id
				break
			end
		end
	end
	return emptyflask_id
end




local Show_Help = false
local TEX_SIZE = 512
local RTTexture = GetRenderTarget( "zbl_injector_screen_rt", TEX_SIZE, TEX_SIZE )
local matScreen = Material( "zerochain/props_bloodlab/injector/zbl_injector_screen" )

local mat_paths = {
	["Virus"] = surface.GetTextureID("zerochain/zblood/swep_icons/zbl_icon_virus"),
	["Sample"] = surface.GetTextureID("zerochain/zblood/swep_icons/zbl_icon_sample"),
	["Cure"] = surface.GetTextureID("zerochain/zblood/swep_icons/zbl_icon_cure"),
	["Abillity"] = surface.GetTextureID("zerochain/zblood/swep_icons/zbl_icon_abillity"),
	["Help"] = surface.GetTextureID("zerochain/zblood/swep_icons/zbl_icon_help"),
	["Hexagon"] = surface.GetTextureID("zerochain/zblood/swep_icons/zbl_icon_hexagon"),
	["Hexagon_Outline"] = surface.GetTextureID("zerochain/zblood/swep_icons/zbl_icon_hexagon_outline"),
}


local function DrawTitle(text,col)
	local font =  zclib.util.FontSwitch(text,15,zclib.GetFont("zbl_gun_font01"),zclib.GetFont("zbl_gun_font01_small"))
	draw.RoundedBox(1, 0, 0, TEX_SIZE, TEX_SIZE / 7, zbl.colors["black04"])
	draw.SimpleText(text, font, TEX_SIZE / 2, 32, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function DrawBackground(_type, color)
	draw.RoundedBox(1, 0, 0, TEX_SIZE, TEX_SIZE, color)

	if _type then
		local size = 150
		surface.SetDrawColor(color_white)
		surface.SetTexture(mat_paths[_type])
		surface.DrawTexturedRect(TEX_SIZE / 2 - size / 2, 70, size, size)
	end
end

local function DrawFlaskIcon(swep,color, pos,_selected)

	local x,y = 117,375

	x = x + (55 * pos)

	if pos > 6 then
		y = y + 55
		x = x - (55 * 6)
	end

	x = x - 55

	surface.SetDrawColor(color)
	surface.SetTexture(mat_paths["Hexagon"])
	surface.DrawTexturedRect( -25 + x, -25 + y, 50, 50)

	if pos == _selected then
		surface.SetDrawColor(color_white)
		surface.SetTexture(mat_paths["Hexagon_Outline"])
		surface.DrawTexturedRect( -25 + x, -25 + y, 50, 50)
	end
end

local function DrawFlaskCount(swep)
	local _selected = swep:GetSelectedFlask()

	if swep.FlaskSequence and table.Count(swep.FlaskSequence) > 0 then
		for k,v in pairs(swep.FlaskSequence) do

			if v > 100 then
				// Ability
				DrawFlaskIcon(swep,zbl.colors["abillity_yellow"], k,_selected)
			else
				if v == 0 then
					// Empty
					DrawFlaskIcon(swep,zbl.colors["grey01"], k,_selected)
				elseif v == 1 then
					//Sample
					DrawFlaskIcon(swep,zbl.colors["sample_blue"], k,_selected)
				elseif v == 2 then
					//Virus
					DrawFlaskIcon(swep,zbl.colors["virus_red"], k,_selected)
				elseif v == 3 then
					// Cure
					DrawFlaskIcon(swep,zbl.colors["cure_green"], k,_selected)
				end
			end
		end
	end
end

// A quick fix for a line return
local function DrawGenName(str,len)
	local name = str
	local _start, _end = string.find(name, " ", 1, false)

	if string.len(name) > len and _start then
		draw.SimpleText(string.sub(name, 1, _start - 1), zclib.GetFont("zbl_gun_dna"), TEX_SIZE / 2, 240, zbl.colors["black04"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(string.sub(name, _start + 1, string.len(name)), zclib.GetFont("zbl_gun_dna"), TEX_SIZE / 2, 280, zbl.colors["black04"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText(name, zclib.GetFont("zbl_gun_dna"), TEX_SIZE / 2, 240, zbl.colors["black04"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

local function DrawHelp(txt,key,_y)
	local font =  zclib.util.FontSwitch(txt,12,zclib.GetFont("zbl_gun_font04"),zclib.GetFont("zbl_gun_font02"))

	draw.RoundedBox(1, 0, _y + 25, TEX_SIZE, TEX_SIZE / 10, zbl.colors["black03"])
	draw.SimpleText(txt, font, 100, 52 + _y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText("[ " .. string.upper(language.GetPhrase(input.GetKeyName(key))) .. " ]", zclib.GetFont("zbl_gun_font02"), TEX_SIZE - 100, 52 + _y, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end

function zbl.Injector.DrawMain(swep)

	local _type = swep:GetGenType()
	local _value = swep:GetGenValue()

	if _type == 1 then
		DrawBackground("Sample", zbl.colors["sample_blue"])

		draw.SimpleText(swep:GetGenName() or "Patient", zclib.util.FontSwitch(swep:GetGenName(),18,zclib.GetFont("zbl_gun_dna"),zclib.GetFont("zbl_gun_name_small")),TEX_SIZE / 2, 240, zbl.colors["black04"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("+" .. swep:GetGenPoints(), zclib.GetFont("zbl_gun_dna"), TEX_SIZE / 2, 295, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		surface.SetDrawColor(color_white)
		surface.SetTexture(mat_paths["Sample"])
		surface.DrawTexturedRect(170, 270, 60,60)

		DrawTitle(zbl.language.General["DNASample"], zbl.colors["sample_blue"])
	elseif _type == 2 then

		if zbl.Vaccine.IsVirus(_value) then
			DrawBackground("Virus", zbl.colors["virus_red"])
			DrawTitle(zbl.language.General["Virus"],zbl.colors["virus_red"])
		else
			DrawBackground("Abillity", zbl.colors["abillity_yellow"])
			DrawTitle(zbl.language.General["Abillity"],zbl.colors["abillity_yellow"])
		end
		DrawGenName(zbl.Vaccine.GetName(_value),15)
	elseif _type == 3 then

		DrawBackground("Cure", zbl.colors["cure_green"])
		DrawTitle(zbl.language.General["Cure"],zbl.colors["cure_green"])
		DrawGenName(zbl.Vaccine.GetName(_value),15)
	else
		DrawBackground(nil, zbl.colors["grey01"])
		DrawTitle(zbl.language.Gun["Empty"],zbl.colors["grey01"])
	end

	draw.RoundedBox(1, 0, TEX_SIZE - 175, TEX_SIZE,175, zbl.colors["black04"])
	draw.SimpleText("[ " .. string.upper(language.GetPhrase(input.GetKeyName(zbl.config.InjectorGun.Keys.Help))) .. " ] " .. zbl.language.Gun["Help"], zclib.GetFont("zbl_gun_font04"), TEX_SIZE / 2, 480, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	DrawFlaskCount(swep)
end

function zbl.Injector.DrawHelp(swep)
	draw.RoundedBox(1, 0, 0, TEX_SIZE, TEX_SIZE, zbl.colors["grey01"])


	surface.SetDrawColor(zbl.colors["white06"])
	surface.SetTexture(mat_paths["Help"])
	surface.DrawTexturedRect(TEX_SIZE * 0.1, TEX_SIZE * 0.125, TEX_SIZE * 0.8, TEX_SIZE * 0.8)

	DrawTitle(zbl.language.Gun["Help"],zbl.colors["grey01"])

	DrawHelp(zbl.language.Gun["Inject"] .. ":", MOUSE_LEFT, 75)
	DrawHelp(zbl.language.Gun["Collect"] .. ":", MOUSE_RIGHT, 135)
	DrawHelp(zbl.language.Gun["Drop"] .. ":", zbl.config.InjectorGun.Keys.ExtractFlask, 195)
	DrawHelp(zbl.language.Gun["Self Inject"] .. ":", zbl.config.InjectorGun.Keys.SelfInject, 255)
	DrawHelp(zbl.language.Gun["Delete"] .. ":", zbl.config.InjectorGun.Keys.EmptyFlask, 315)
	DrawHelp(zbl.language.Gun["Switch"] .. ":", zbl.config.InjectorGun.Keys.SwitchFlask, 375)
	DrawHelp(zbl.language.Gun["Scan"] .. ":", zbl.config.InjectorGun.Keys.ScanArea, 435)
end

function zbl.Injector.DrawScreen(swep)

	// Set the material of the screen to our render target
	matScreen:SetTexture( "$basetexture", RTTexture )

	// Set up our view for drawing to the texture
	render.PushRenderTarget( RTTexture )
		cam.Start2D()

			if Show_Help then
				zbl.Injector.DrawHelp(swep)
			else
				zbl.Injector.DrawMain(swep)
			end

		cam.End2D()
	render.PopRenderTarget()
end

function zbl.Injector.DrawHUD(swep)

	zbl.Injector.DrawScreen(swep)
end

zclib.Hook.Add("PlayerButtonDown", "zbl_PlayerButtonDown_Injector", function(ply, key)
	if IsValid(ply) then

		local swep = ply:GetActiveWeapon()

		if IsValid(swep) and swep:GetClass() == "zbl_gun" and key == zbl.config.InjectorGun.Keys.Help and (ply.zbl_LastKey == nil or ply.zbl_LastKey < CurTime()) then
			ply.zbl_LastKey = CurTime() + 0.2

			ply:EmitSound("zbl_ui_click")

			// Toggle Help menu
			Show_Help = not Show_Help
		end
	end
end)



                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10


// SCAN FUNCTION
local ObjectList = ObjectList or {}

local function DrawVaccineInfo(target)
	local vac_id = zbl.Vaccine.Get(target)
	local vac_stage = zbl.Vaccine.GetStage(target)
	local pos = target:LocalToWorld(target:OBBCenter())

	//if zclib.util.InDistance(pos, LocalPlayer():GetPos(), 500) == false then return end

	pos = pos:ToScreen()

	local _name = ""
	local _info = zbl.language.General["Clean"]
	local _icon = zbl.materials["zbl_icon_clean"]
	local _color = color_white
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

	if vac_id == -1 then
		_info = zbl.language.General["Clean"]
	elseif vac_id == -2 then
		_info = zbl.language.General["Sterilized"]
		_color = zbl.colors["spray_sterilized"]
		_icon = zbl.materials["zbl_shield_icon"]
	else
		if zbl.Vaccine.IsVirus(vac_id) then
			_icon = zbl.materials["zbl_virus_icon"]
			_color = zbl.colors["virus_red"]
		else
			_icon = zbl.materials["zbl_abillity_icon"]
			_color = zbl.colors["abillity_yellow"]
		end

		_name = zbl.Vaccine.GetName(vac_id)
		_info = zbl.language.Gun["Stage"] .. ": " .. vac_stage
	end

	cam.Start2D()

		surface.SetDrawColor(color_white)
		surface.SetMaterial(zbl.materials["zbl_icon_scan"])
		surface.DrawTexturedRect(pos.x - 20 * zclib.wM, pos.y - 40 * zclib.hM, 80 * zclib.wM, 80 * zclib.hM)

		surface.SetDrawColor(_color)
		surface.SetMaterial(_icon)
		surface.DrawTexturedRect(pos.x - 20 * zclib.wM, pos.y - 20 * zclib.hM, 40 * zclib.wM, 40 * zclib.hM)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337


		if target:GetClass() == "zbl_corpse" then
			draw.SimpleText(target:GetPlayerName(), zclib.GetFont("zbl_gun_scan01"), pos.x + 22 * zclib.wM, pos.y -35 * zclib.hM, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		if _name == "" then
			draw.SimpleText(_info, zclib.GetFont("zbl_gun_scan01"), pos.x + 22 * zclib.wM, pos.y + 10 * zclib.hM, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		else

			draw.SimpleText(_info, zclib.GetFont("zbl_gun_scan01"), pos.x + 22 * zclib.wM, pos.y + 10 * zclib.hM , color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(_name, zclib.GetFont("zbl_gun_scan01"), pos.x + 22 * zclib.wM, pos.y - 13 * zclib.hM, _color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	cam.End2D()
end

local function DrawScannedObjects()

	if ObjectList == nil then
		zclib.Hook.Remove("PostDrawTranslucentRenderables", "zbl_Injector_Scan")
		return
	end

	if table.Count(ObjectList) <= 0 then
		zclib.Hook.Remove("PostDrawTranslucentRenderables", "zbl_Injector_Scan")
		return
	end

	for a, w in pairs(ObjectList) do
		if IsValid(w.ent) and w.time > CurTime() then

			render.MaterialOverride(zbl.materials["zbl_scanmat"])

			local newColor
			if w.got_sprayed then
				newColor = zbl.colors["clean_blue"]
			elseif w.ent:GetClass() == "zbl_virusnode" then

				newColor = zbl.colors["virus_red"]
			elseif w.ent:GetClass() == "zbl_corpse" then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

				newColor = zbl.colors["virus_red"]
			else

				local vacID = zbl.Vaccine.Get(w.ent)

				if vacID == -1 then

					newColor = zbl.colors["white04"]
				elseif vacID == -2 then
					newColor = zbl.colors["clean_blue"]
				else

					if zbl.Vaccine.IsVirus(vacID) then
						newColor = zbl.colors["virus_red"]
					else
						newColor = zbl.colors["abillity_yellow"]
					end
				end
			end

			// Decrease brightness according to time
			local t = math.Clamp(w.time - CurTime(),0,zbl.config.InjectorGun.Scan.duration)
			if t < 2 then
				t = (1 / 2) * t
				newColor = Color(newColor.r * t, newColor.g * t, newColor.b * t)
			end

			// Convert to normalized decimal
			newColor = zclib.util.ColorToVector(newColor)

			// Set color modulation
			render.SetColorModulation(newColor.x, newColor.y, newColor.z)

			w.ent:DrawModel()

			render.MaterialOverride()
			render.ModelMaterialOverride()
			render.SetColorModulation(1, 1, 1)

			if zbl.config.InjectorGun.Scan.show_info and w.hide_info == nil then
				DrawVaccineInfo(w.ent)
			end
		else
			ObjectList[a] = nil
		end
	end
end

net.Receive("zbl_scan_pulse", function(len)
	zclib.Debug("zbl_scan_pulse Len: " .. len)

	local pos = net.ReadVector()

	if pos then

		zclib.Effect.ParticleEffect("zbl_scan", pos, Angle(0,0,0))

		for a, w in pairs(ents.FindInSphere(pos, zbl.config.InjectorGun.Scan.radius)) do
			if not IsValid(w) then continue end

			if w:IsPlayer() and not w:Alive() then continue end

			local class = w:GetClass()
			if not w:IsPlayer() and not zbl.config.Contamination.ents[class] and class ~= "zbl_virusnode" and class ~= "zbl_corpse" then continue end
			if not LocalPlayer():IsLineOfSightClear( w ) then continue end

			if hook.Run("zbl_BlockObjectScan",w) == true then continue end

			ObjectList[w:EntIndex()] = {
				ent = w,
				time = CurTime() + zbl.config.InjectorGun.Scan.duration
			}
		end

		zclib.Hook.Remove("PostDrawTranslucentRenderables", "zbl_Injector_Scan")
		zclib.Hook.Add("PostDrawTranslucentRenderables", "zbl_Injector_Scan", function(depth, skybox,skybox3d)
			if skybox3d == false then
				DrawScannedObjects()
			end
		end)
	end
end)

// Called from the spray entity to show the object status
net.Receive("zbl_spray_scan", function(len)
	zclib.Debug("zbl_spray_scan Len: " .. len)

	local _ent = net.ReadEntity()

	if IsValid(_ent) and zbl.config.Contamination.ents[_ent:GetClass()] then

		ObjectList[_ent:EntIndex()] = {
			ent = _ent,
			time = CurTime() + 1,
			hide_info = true,
			got_sprayed = true
		}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

		zclib.Hook.Remove("PostDrawTranslucentRenderables", "zbl_Injector_Scan")
		zclib.Hook.Add("PostDrawTranslucentRenderables", "zbl_Injector_Scan", function(depth, skybox,skybox3d)
			if skybox3d == false then
				DrawScannedObjects()
			end
		end)
	end
end)
