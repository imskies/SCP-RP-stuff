/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if SERVER then return end
zbl = zbl or {}
zbl.Fence = zbl.Fence or {}

local pos_offset01 = Vector(3.2, 0, 107.6)
local ang_offset01 = Angle(180, -90, -90)

local pos_offset02 = Vector(-3.2, 0, 107.6)
local ang_offset02 = Angle(180, 90, -90)

local pos_offset03 = Vector(0, 0, 58)
local ang_offset03 = Angle(180, 90, -90)

local pos_offset04 = Vector(-5, 0, 37.3)
local ang_offset04 = Angle(180, 90, -90)

local pos_offset05 = Vector(5, 0, 37.3)
local ang_offset05 = Angle(0, 90, 90)

function zbl.Fence.Initialize(Fence)
	Fence.Wait = true
	timer.Simple(1,function()
		if IsValid(Fence) then
			Fence.Wait = false
		end
	end)

	zclib.EntityTracker.Add(Fence)

	Fence.WallModels = {}
	Fence.Constructed = false

	Fence:DrawShadow(false)
	Fence:DestroyShadow()
end

function zbl.Fence.OnDraw(Fence)
	if not zclib.util.InDistance(LocalPlayer():GetPos(), Fence:GetPos(), 1000) then return end

	if Fence:GetDoor() then
		cam.Start3D2D(Fence:LocalToWorld(pos_offset03), Fence:LocalToWorldAngles(ang_offset03), 0.1)
			surface.SetDrawColor(color_white)
			surface.SetMaterial(zbl.materials["zbl_gate_field"])
			surface.DrawTexturedRectRotated( 70,0,740,180,-90)

			surface.SetDrawColor(color_white)
			surface.SetMaterial(zbl.materials["zbl_gate_field"])
			surface.DrawTexturedRectRotated( -70,0,740,180,90)
		cam.End3D2D()
	end

	cam.Start3D2D(Fence:LocalToWorld(pos_offset04), Fence:LocalToWorldAngles(ang_offset04), 0.1)

		if zbl.config.Fence.door == true then
			// Button for Open/Close Door
			if Fence:OnDoorButton01(LocalPlayer()) then
				zbl.Fence.DrawIcon(Fence,262,0,zbl.materials["zbl_gate_icon"],zbl.colors["abillity_yellow"])
			else
				zbl.Fence.DrawIcon(Fence,262,0,zbl.materials["zbl_gate_icon"],color_white)
			end
		end

		// Button for Fence Unfold
		if zbl.config.Fence.unfold == true and (table.Count(zbl.config.Fence.ranks) <= 0 or zbl.config.Fence.ranks[zclib.Player.GetRank(LocalPlayer())]) then
			if Fence:OnFenceButton01(LocalPlayer()) then
				zbl.Fence.DrawIcon(Fence,-262,0,zbl.materials["zbl_fence_icon"],zbl.colors["abillity_yellow"])
			else
				zbl.Fence.DrawIcon(Fence,-262,0,zbl.materials["zbl_fence_icon"],color_white)
			end
		end
	cam.End3D2D()

	if not zbl.config.Fence.onesideonly then
		cam.Start3D2D(Fence:LocalToWorld(pos_offset05), Fence:LocalToWorldAngles(ang_offset05), 0.1)

			if zbl.config.Fence.door == true then
				// Button for Open/Close Door
				if Fence:OnDoorButton02(LocalPlayer()) then
					zbl.Fence.DrawIcon(Fence,-262,0,zbl.materials["zbl_gate_icon"],zbl.colors["abillity_yellow"])
				else
					zbl.Fence.DrawIcon(Fence,-262,0,zbl.materials["zbl_gate_icon"],color_white)
				end
			end

			// Button for Fence Unfold
			if zbl.config.Fence.unfold == true and (table.Count(zbl.config.Fence.ranks) <= 0 or zbl.config.Fence.ranks[zclib.Player.GetRank(LocalPlayer())]) then
				if Fence:OnFenceButton02(LocalPlayer()) then
					zbl.Fence.DrawIcon(Fence,262,0,zbl.materials["zbl_fence_icon"],zbl.colors["abillity_yellow"])
				else
					zbl.Fence.DrawIcon(Fence,262,0,zbl.materials["zbl_fence_icon"],color_white)
				end
			end
		cam.End3D2D()
	end

	if zclib.Convar.Get("zbl_cl_fence_simplify") == 1 then
		local _l_wall = Fence:GetLeftWall()
		local _r_wall = Fence:GetRightWall()

		if IsValid(_r_wall) then
			local min, max = _r_wall:GetCollisionBounds()
			render.SetColorMaterial()
			render.DrawBox(_r_wall:GetPos(), _r_wall:GetAngles(), min, max, zbl.colors["fence_indicator"])
		end

		if IsValid(_l_wall) then
			local min, max = _l_wall:GetCollisionBounds()
			render.SetColorMaterial()
			render.DrawBox(_l_wall:GetPos(), _l_wall:GetAngles(), min, max, zbl.colors["fence_indicator"])
		end
	end

	if zclib.Convar.Get("zclib_cl_drawui") == 1 then
		local ScanResult = Fence:GetScanResult()

		if ScanResult == 1 then
			zbl.Fence.DrawText(Fence,zbl.language.General["Clean"],zbl.colors["fence_check_good"])
		elseif ScanResult == 0 then
			zbl.Fence.DrawText(Fence,zbl.language.General["Virus"],zbl.colors["fence_check_bad"])
		elseif ScanResult == 2 then
			zbl.Fence.DrawText(Fence,zbl.language.General["Sterilized"],zbl.colors["fence_check_sterilized"])
		elseif ScanResult == 3 then
			zbl.Fence.DrawText(Fence,"MINGE",zbl.colors["fence_check_bad"])
		end
	end
end

function zbl.Fence.OnThink(Fence)
	if Fence.Wait == true then return end

	if zclib.util.InDistance(LocalPlayer():GetPos(), Fence:GetPos(), 1500) and Fence:GetFence() and zclib.Convar.Get("zbl_cl_fence_simplify") == 0 then

		local _l_wall = Fence:GetLeftWall()
		local _r_wall = Fence:GetRightWall()

		if not IsValid(_r_wall) or not IsValid(_l_wall) then return end

		if Fence.Constructed == false then

			zbl.Fence.DestroyMesh(Fence)

			zbl.Fence.ConstructWall(Fence, _r_wall, false)
			zbl.Fence.ConstructWall(Fence, _l_wall, true)

			Fence:EmitSound("zbl_fence_move")
			timer.Simple(0.5,function()
				if IsValid(Fence) then
					Fence:StopSound("zbl_fence_move")
					Fence:EmitSound("zbl_fence_stop")
				end
			end)

			Fence.Constructed = true
		else
			// Position the entitites
			for k,v in pairs(Fence.WallModels) do
				if IsValid(v.ent) then
					v.ent:SetPos(Fence:LocalToWorld(v.lpos))
					v.ent:SetAngles(Fence:LocalToWorldAngles(v.lang))
					v.ent:SetColor(zbl.Fence.GetHealthColor(Fence))
				end
			end
		end
	else
		if Fence.Constructed == true then

			zbl.Fence.DestroyMesh(Fence)
			Fence:StopSound("zbl_fence_move")
			Fence:EmitSound("zbl_fence_remove")

			Fence.Constructed = false
		end
	end
end

function zbl.Fence.OnRemove(Fence)
	zbl.Fence.DestroyMesh(Fence)
end

function zbl.Fence.DrawText(Fence,txt,color)
	local w,h = 340,100
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

	local font = zclib.util.FontSwitch(txt,10,zclib.GetFont("zbl_fence_title"),zclib.GetFont("zbl_fence_title_small"))

	cam.Start3D2D(Fence:LocalToWorld(pos_offset01), Fence:LocalToWorldAngles(ang_offset01), 0.1)
		draw.RoundedBox(0, -w / 2, -h / 2, w, h, color)
		draw.SimpleText(txt, font, 0,0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()

	cam.Start3D2D(Fence:LocalToWorld(pos_offset02), Fence:LocalToWorldAngles(ang_offset02), 0.1)
		draw.RoundedBox(0, -w / 2, -h / 2, w, h, color)
		draw.SimpleText(txt, font, 0,0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end

function zbl.Fence.DrawIcon(Fence,x, y, icon, color)
	local size = 50

	draw.RoundedBox(5, x - size / 2, y - size / 2, size, size, zbl.colors["grey01"])

	local i_size = size * 0.8
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

	surface.SetDrawColor(color)
	surface.SetMaterial(icon)
	surface.DrawTexturedRect(x - i_size / 2, y - i_size / 2, i_size, i_size)
end

function zbl.Fence.CreateFencePiece(Fence,pos,ang)
	local cs = ents.CreateClientProp()
	if not IsValid(cs) then return end
	if not cs.SetModel then return end
	cs:SetPos(pos)
	cs:SetAngles(ang)
	cs:SetModel("models/zerochain/props_bloodlab/zbl_fence.mdl")
	cs:SetMoveType(MOVETYPE_NONE)
	cs:SetParent(Fence)
	cs:Spawn()
	cs:DrawShadow(false)
	cs:DestroyShadow()

	table.insert(Fence.WallModels,{
		ent = cs,
		lpos = Fence:WorldToLocal(pos),
		lang = Fence:WorldToLocalAngles(ang)
	})
end

function zbl.Fence.ConstructWall(Fence,wall_end,left)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

	local wall_size = 100

	local pos = Fence:GetPos()

	if left then
		pos = Fence:GetPos() + Fence:GetRight() * 40
	else
		pos = Fence:GetPos() - Fence:GetRight() * 40
	end

	local e_pos = wall_end:GetPos()
	local dist = math.Distance( pos.x,pos.y, e_pos.x,e_pos.y )

	local count = math.Round(dist / wall_size)
	local rest = dist - (wall_size * count)
	if rest > wall_size / 8 then
		count = count + 1
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

	local ang = Fence:GetAngles()
	ang:RotateAroundAxis(Fence:GetUp(),90)

	if left then
		ang:RotateAroundAxis(Fence:GetUp(),180)
	end

	for i = 1, count do
		local w_pos = pos

		if left then
			w_pos = w_pos - Fence:GetRight() * 60
			w_pos = w_pos + Fence:GetRight() * (wall_size * i)
		else
			w_pos = w_pos + Fence:GetRight() * 60
			w_pos = w_pos - Fence:GetRight() * (wall_size * i)
		end

		zbl.Fence.CreateFencePiece(Fence,w_pos, ang)
	end
end

function zbl.Fence.DestroyMesh(Fence)
	for k,v in pairs(Fence.WallModels) do
		if v and IsValid(v.ent) then
			v.ent:Remove()
		end
	end

	Fence.WallModels = {}
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c
