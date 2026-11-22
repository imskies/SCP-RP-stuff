/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if SERVER then return end
zbl = zbl or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

local function SetupRendering(OnDraw, KeepDraw)
	zclib.Hook.Remove("PostDrawTranslucentRenderables", "zbl_PostDrawTranslucentRenderables_hotspotspawner")

	zclib.Hook.Add("PostDrawTranslucentRenderables", "zbl_PostDrawTranslucentRenderables_hotspotspawner", function(depth, skybox,skybox3d)
		if skybox3d == false then
			if KeepDraw() then
				OnDraw()
			else
				zclib.Hook.Remove("PostDrawTranslucentRenderables", "zbl_PostDrawTranslucentRenderables_hotspotspawner")
			end
		end
	end)
end

local function HasToolActive()
	local ply = LocalPlayer()

	if IsValid(ply) and ply:Alive() and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "gmod_tool" then
		local tool = ply:GetTool()

		if tool and table.Count(tool) > 0 and IsValid(tool.SWEP) and tool.Mode == "zbl_hotspotspawner" and tool.Name == "#Hotspot Spawner" then
			return true
		else
			return false
		end
	else
		return false
	end
end

local NodeCache
net.Receive("zbl_hotspot_showall", function(len)
	zclib.Debug("zbl_hotspot_showall Len: " .. len)
	local dataLength = net.ReadUInt(16)
	local d_Decompressed = util.Decompress(net.ReadData(dataLength))
	local positions = util.JSONToTable(d_Decompressed)

	if positions then
		SetupRendering(function()
			local tr = LocalPlayer():GetEyeTrace()

			if tr.Hit and zclib.util.InDistance(tr.HitPos, LocalPlayer():GetPos(), 3000) then
				render.SetColorMaterial()
				render.DrawWireframeSphere(tr.HitPos, 50, 12, 12, zbl.colors["hotspot_red"], true)
			end

			for k, v in pairs(positions) do
				if v then
					render.SetColorMaterial()
					render.DrawSphere(v, 50, 12, 12, zbl.colors["hotspot_red"])
					render.DrawWireframeSphere(v, 50, 12, 12, zbl.colors["hotspot_red"], false)
				end
			end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

			if NodeCache then
				for k, v in pairs(NodeCache) do
					if v then
						render.SetColorMaterial()
						render.DrawWireframeSphere(v, 15, 4, 4, zbl.colors["cachedpos_violett"], false)
					end
				end
			end
		end, HasToolActive)
	end
end)

net.Receive("zbl_CachedNodePositions_Show", function(len)
	zclib.Debug("zbl_CachedNodePositions_Show Len: " .. len)
	local dataLength = net.ReadUInt(16)
	local d_Decompressed = util.Decompress(net.ReadData(dataLength))
	local positions = util.JSONToTable(d_Decompressed)

	if positions then
		NodeCache = positions
		if zclib.Hook.Exist("PostDrawTranslucentRenderables", "zbl_PostDrawTranslucentRenderables_hotspotspawner") then return end
		SetupRendering(function()
			for k, v in pairs(positions) do
				if v then
					render.SetColorMaterial()
					render.DrawWireframeSphere(v, 15, 4, 4, zbl.colors["cachedpos_violett"], false)
				end
			end
		end, HasToolActive)
	end
end)

net.Receive("zbl_CtmnObjects_Show", function(len)
	zclib.Debug("zbl_CtmnObjects_Show Len: " .. len)
	local dataLength = net.ReadUInt(16)
	local d_Decompressed = util.Decompress(net.ReadData(dataLength))
	local positions = util.JSONToTable(d_Decompressed)

	if positions then

		local FinishRendering = CurTime() + 30
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

		SetupRendering(function()
			for k, v in pairs(positions) do
				if v then
					render.SetColorMaterial()
					render.DrawWireframeSphere(v, 15, 4, 4, zbl.colors["hotspot_red"], false)
				end
			end
		end, function()
			return CurTime() < FinishRendering
		end)
	end
end)

local function DrawVaccineInfo(target)
	local vac_id = zbl.Vaccine.Get(target)
	local vac_stage = zbl.Vaccine.GetStage(target)
	local pos = target:LocalToWorld(target:OBBCenter())
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

	//if zclib.util.InDistance(pos, LocalPlayer():GetPos(), 500) == false then return end

	pos = pos:ToScreen()

	local _name = ""
	local _info = zbl.language.General["Clean"]
	local _icon = zbl.materials["zbl_icon_clean"]
	local _color = color_white

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

		draw.SimpleText(target:Nick(), zclib.GetFont("zbl_gun_scan01"), pos.x + 22 * zclib.wM, pos.y -35 * zclib.hM, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360


		if _name == "" then
			draw.SimpleText(_info, zclib.GetFont("zbl_gun_scan01"), pos.x + 22 * zclib.wM, pos.y + 10 * zclib.hM, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		else

			draw.SimpleText(_info, zclib.GetFont("zbl_gun_scan01"), pos.x + 22 * zclib.wM, pos.y + 10 * zclib.hM , color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(_name, zclib.GetFont("zbl_gun_scan01"), pos.x + 22 * zclib.wM, pos.y - 13 * zclib.hM, _color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	cam.End2D()
end

net.Receive("zbl_PlayerInfection_Show", function(len)
	zclib.Debug("zbl_PlayerInfection_Show Len: " .. len)
	local dataLength = net.ReadUInt(16)
	local targets = {}
	for i = 1, dataLength do targets[ i ] = net.ReadEntity() end

	if targets then

		local FinishRendering = CurTime() + 30

		SetupRendering(function()
			for k, v in pairs(targets) do
				if v then
					local id = zbl.Vaccine.Get(v)

					if id and id > 0 then
						DrawVaccineInfo(v)
					end
				end
			end
		end, function()
			return CurTime() < FinishRendering
		end)
	end
end)
