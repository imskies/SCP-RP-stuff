/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if SERVER then return end
zbl = zbl or {}
zbl.MedicalUnit = zbl.MedicalUnit or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

function zbl.MedicalUnit.Initialize(MedicalUnit)
	zclib.EntityTracker.Add(MedicalUnit)

	MedicalUnit.screenMaterial01 = CreateMaterial("zbl_smu_mat_" .. MedicalUnit:EntIndex(), "UnlitGeneric", {
		["$basetexture"] = "zerochain/props_advertisement/zad_paint",
		["$model"] = 1,
	})
	MedicalUnit.renderTarget01 = GetRenderTarget("zbl_smu_mat_" .. MedicalUnit:EntIndex(), 512, 512, false)

end

function zbl.MedicalUnit.DrawLight(MedicalUnit,pos,color,size)
	local dlight = DynamicLight(MedicalUnit:EntIndex())

	if dlight then
		dlight.Pos = pos
		dlight.r = color.r
		dlight.g = color.g
		dlight.b = color.b
		dlight.Brightness = 2
		dlight.Size = size
		dlight.Decay = 1000
		dlight.Style = 1
		dlight.DieTime = CurTime() + 1
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

local function DrawTextBox(text1,text2,font,color,x,y,w,h)
	draw.SimpleText(text1, font, x - (w/2) + 10,y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText(text2, text2 > 99999999 and zclib.GetFont("zbl_vgui_item_desc") or font, x + (w/2) - 10,y, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	zclib.util.DrawOutlinedBox(x - (w/2),y - (h/2), w, h, 2, color)
end

local function ReplaceMaterial(MedicalUnit,renderTarget,FoundThread)

	local w,h = 512,512

	local mat = Matrix()
	render.PushRenderTarget(renderTarget)
		render.Clear(0, 0, 0, 255, true, true)
		render.OverrideAlphaWriteEnable(true, true)
		cam.Start2D()
			cam.PushModelMatrix(mat)

				surface.SetDrawColor(FoundThread and zbl.colors["virus_red"] or zbl.colors["sample_blue"])
				surface.SetMaterial(zclib.Materials.Get("item_bg"))
				surface.DrawTexturedRect(0,0,w,h)

				surface.SetDrawColor(zbl.colors["black03"])
				surface.SetMaterial(FoundThread and zbl.materials["zbl_virus_icon"] or zclib.Materials.Get("statistic"))
				surface.DrawTexturedRect(0,0,w,h)


				if FoundThread then
					draw.SimpleText(zbl.language.General["VirusDetected"], zclib.GetFont("zbl_npc_title"), w / 2, 50, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				else

					draw.SimpleText(zbl.language.General["ScanReport"], zclib.GetFont("zbl_npc_title"), w / 2, 50, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

					DrawTextBox(zbl.language.General["ScannedOjbects"] .. ":",MedicalUnit:GetScannedOjbects(),zclib.GetFont("zbl_sign_count_small"),color_white, w / 2, 150,320,40)

					DrawTextBox(zbl.language.General["FoundInfecions"] .. ":",MedicalUnit:GetFoundInfections(),zclib.GetFont("zbl_sign_count_small"),color_white, w / 2, 220,320,40)

					DrawTextBox(zbl.language.General["SoldVaccines"] .. ":",MedicalUnit:GetSoldVaccines(),zclib.GetFont("zbl_sign_count_small"),color_white, w / 2, 290,320,40)

					DrawTextBox(zbl.language.General["BoughtVaccines"] .. ":",MedicalUnit:GetBoughtVaccines(),zclib.GetFont("zbl_sign_count_small"),color_white, w / 2, 360,320,40)
				end


				surface.SetDrawColor(zbl.colors["black03"])
				surface.SetMaterial(zbl.materials["zbl_scanlines"])
				surface.DrawTexturedRectRotated(w / 2, h / 2, w, h, 90)

			cam.PopModelMatrix()
		cam.End2D()
	render.PopRenderTarget()
end

local col_blue = Color(100,100,255)
function zbl.MedicalUnit.Draw(MedicalUnit)
	if not zclib.util.InDistance(LocalPlayer():GetPos(), MedicalUnit:GetPos(), 500) then
		return
	end

	-- This needs to run per frame , otherwhise we get lightning problems on the replaced materials
	ReplaceMaterial(MedicalUnit,MedicalUnit.renderTarget01,MedicalUnit:GetThreatDetected())
	MedicalUnit.screenMaterial01:SetTexture("$basetexture", MedicalUnit.renderTarget01)
	MedicalUnit:SetSubMaterial(5, "!zbl_smu_mat_" .. MedicalUnit:EntIndex())

	if MedicalUnit:GetThreatDetected() then
		MedicalUnit:SetSkin(1)
		MedicalUnit:ManipulateBoneAngles(MedicalUnit:LookupBone("warnlights_jnt"),Angle(0,0,CurTime() * 500))
		zbl.MedicalUnit.DrawLight(MedicalUnit,MedicalUnit:LocalToWorld(Vector(0,15,170)),color_red,1024)
	else
		MedicalUnit:ManipulateBoneAngles(MedicalUnit:LookupBone("spinner01_jnt"),Angle(0,0,CurTime() * 90))
		MedicalUnit:ManipulateBoneAngles(MedicalUnit:LookupBone("spinner02_jnt"),Angle(0,0,-CurTime() * 90))
		zbl.MedicalUnit.DrawLight(MedicalUnit,MedicalUnit:LocalToWorld(Vector(0,0,50)),col_blue,128)
		MedicalUnit:SetSkin(0)
	end
end

local function CreateClientProp(ent,mdl,pos,ang)
	local cs = ents.CreateClientProp()
	if not IsValid(cs) then return end
	if not cs.SetModel then return end
	if not mdl then return end

	cs:SetModel(mdl)
	cs:SetPos(pos)
	cs:SetAngles(ang)

	cs:SetNoDraw(true)
    cs:SetPredictable(false)
    cs:DrawShadow(false)
    cs:DestroyShadow()
    cs:SetMoveType(MOVETYPE_NONE)
	cs:Spawn()
	cs:SetLOD( 0 )

	if ent:IsPlayer() then

		local CallBackID = cs:AddCallback("BuildBonePositions", function(dummy, numbones)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

			if not cs.PlayerBoneSet then

				/*
					Get all of the players current bone position and rotations
				*/
				cs.PlayerBoneSet = {}
				for i = 0, ent:GetBoneCount() do
					local vec, aang = ent:GetBonePosition(i)

					if vec == ent:GetPos() then
						local mtx = ent:GetBoneMatrix(i)
						if not mtx then continue end

						vec = mtx:GetTranslation()
						//aang = mtx:GetAngles()
					end

					if vec and aang then
						cs.PlayerBoneSet[ i ] = { vec, aang }
					end
				end
			else

				for i = 0, numbones - 1 do

				   if not cs.PlayerBoneSet[ i ] then continue end

				   local vec, aang = cs.PlayerBoneSet[ i ][ 1 ], cs.PlayerBoneSet[ i ][ 2 ]
				   if not vec or not aang then continue end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

				   local mat = cs:GetBoneMatrix(i)
				   if not mat then continue end

				   mat:SetAngles(aang)
				   mat:SetTranslation(vec)

				   cs:SetBoneMatrix(i, mat)
			   end

			end

	    end)

	    cs:CallOnRemove("zbl_remove_cs_dummy_BuildBonePositions_Callback_" .. math.random(99999999), function(aent) aent:RemoveCallback("BuildBonePositions", CallBackID) end)
	end

	return cs
end

local laser_mat = Material("sprites/physbeam")
local laser_thick = 10
local function DrawLine(posA,posB,color)

    render.SetMaterial(laser_mat)
    render.StartBeam(2)
       local dist = posA:DistToSqr(posB)
       dist = dist / 2

       local tex = math.floor(dist / 50)

        render.AddBeam(posA, laser_thick, tex * 1, color)
        render.AddBeam(posB, laser_thick, tex * 2, color)
    render.EndBeam()

    render.SetMaterial(zclib.Materials.Get("glow01"))
    render.DrawSprite(posB, laser_thick, laser_thick, color)
end

local ObjectList = {}
local HookCreated = false
local function StopRendering()
	zclib.Hook.Remove("PostDrawTranslucentRenderables", "zbl.MedicalUnit.InfectionDetected")
	zclib.Hook.Remove("Think", "zbl.MedicalUnit.InfectionDetected")
	HookCreated = false
end

local function StartRendering()
	if HookCreated then return end

	HookCreated = true

	zclib.Hook.Add("Think", "zbl.MedicalUnit.InfectionDetected", function()

		if not ObjectList then
			StopRendering()
			return
		end

		if table.Count(ObjectList) <= 0 then
			StopRendering()
			return
		end

		for a, w in pairs(ObjectList) do

			if not IsValid(w.ent) then
				ObjectList[a] = nil
				continue
			end

			if not IsValid(w.MedicalUnit) then
				w.ent:Remove()
				ObjectList[a] = nil
				continue
			end

			if w.time < CurTime() then
				w.ent:Remove()
				ObjectList[a] = nil
				continue
			end
		end
	end)

	zclib.Hook.Add("PostDrawTranslucentRenderables", "zbl.MedicalUnit.InfectionDetected", function(depth, skybox,skybox3d)
		if skybox3d then return end
		if not ObjectList then return end
		if table.Count(ObjectList) <= 0 then return end

		for a, w in pairs(ObjectList) do

			if not IsValid(w.ent) then continue end
			if not IsValid(w.MedicalUnit) then continue end
			if w.time < CurTime() then continue end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

			if CurTime() > (w.start + 0.1) and zclib.util.InDistance(LocalPlayer():GetPos(), w.ent:GetPos(), 50) then continue end

			render.MaterialOverride(zbl.materials["zbl_scanmat"])

			local newColor = w.color

			// Decrease brightness according to time
			local t = math.Clamp(w.time - CurTime(),0,zbl.config.StationaryMedicalUnit.Scan.duration)
			if t < 2 then
				t = (1 / 2) * t
				newColor = Color(newColor.r * t, newColor.g * t, newColor.b * t)
			end

			// Draw a beam to the scanned target
			DrawLine(w.MedicalUnit:LocalToWorld(Vector(0,0,140)),w.ent:LocalToWorld(w.ent:OBBCenter()),newColor)

			// Convert to normalized decimal
			newColor = zclib.util.ColorToVector(newColor)

			// Set color modulation
			render.SetColorModulation(newColor.x, newColor.y, newColor.z)

			w.ent:SetModelScale(w.scale)
			w.ent:DrawModel()

			render.MaterialOverride()
			render.ModelMaterialOverride()
			render.SetColorModulation(1, 1, 1)
		end
	end)
end

net.Receive("zbl.MedicalUnit.InfectionDetected",function(len)
	local MedicalUnit = net.ReadEntity()
	if not IsValid(MedicalUnit) then return end
	if not MedicalUnit:IsValid() then return end

	local ScannedEntities = zbl.MedicalUnit.GetScanned(MedicalUnit)

	// Create a laser to the infected entity and also a hologram of it which starts to fade
	for _,ent in pairs(ScannedEntities) do
		if not IsValid(ent) then continue end
		if not ent.GetModelScale then continue end
		// If we found a thread but this entity is not it then ignore it
		//if MedicalUnit:GetThreatDetected() and not zbl.Player.IsInfected(ent) then continue end

		// Create a dummy object for the scanned entities, so that they dont move
		local Dummy = CreateClientProp(ent,ent:GetModel(),ent:GetPos(),ent:GetAngles())

		table.insert(ObjectList,{
			MedicalUnit = MedicalUnit,
			ent = Dummy,
			scale = ent:GetModelScale() + 0.1,
			class = ent:GetClass(),
			color = zbl.Player.IsInfected(ent) and zbl.colors["virus_red"] or zbl.colors["clean_blue"],
			vacID = zbl.Vaccine.Get(ent),
			start = CurTime(),
			time = CurTime() + zbl.config.StationaryMedicalUnit.Scan.duration
		})
	end

	StartRendering()

	local pos = MedicalUnit:LocalToWorld(Vector(0,0,-90))

	if MedicalUnit:GetThreatDetected() then
		MedicalUnit:EmitSound("zbl_scan_smu")
		util.ScreenShake(pos, 1, 100, 1, zbl.config.StationaryMedicalUnit.Scan.radius)
	end

	local col = MedicalUnit:GetThreatDetected() and Color(255, 0, 0, 64) or Color(125, 125, 255, 64)

	effects.BeamRingPoint(pos, 0.25, 12, zbl.config.StationaryMedicalUnit.Scan.radius * 2, 32, 0, col, {
		speed = 0,
		spread = 0,
		delay = 0,
		framerate = 2,
		material = "sprites/lgtning.vmt"
	})

	effects.BeamRingPoint(pos, 0.5, 12, zbl.config.StationaryMedicalUnit.Scan.radius * 2, 32, 0, col, {
		speed = 0,
		spread = 0,
		delay = 0,
		framerate = 2,
		material = "sprites/lgtning.vmt"
	})

	effects.BeamRingPoint(pos, 0.75, 12, zbl.config.StationaryMedicalUnit.Scan.radius * 2, 32, 0, col, {
		speed = 0,
		spread = 0,
		delay = 0,
		framerate = 2,
		material = "sprites/lgtning.vmt"
	})
end)
