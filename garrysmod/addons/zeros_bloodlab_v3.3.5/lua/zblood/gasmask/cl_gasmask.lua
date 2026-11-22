/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if SERVER then return end
zbl = zbl or {}
zbl.GasMask = zbl.GasMask or {}


local LPly = LocalPlayer()


net.Receive("zbl_Gasmask_Equipt", function()
    local ply = net.ReadEntity()
    local show = net.ReadBool()
    local maskID = net.ReadInt(6)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    zclib.Debug("zbl_Gasmask_Equipt: " .. tostring(ply) .. " " .. tostring(show))

    zbl.GasMask.Equipt(ply, show,maskID)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

function zbl.GasMask.Equipt(ply, show,maskID)

	ply.zbl_MaskID = maskID
	ply.zbl_MaskEquipt = show

	ply:EmitSound(show and "zbl_mask_on" or "zbl_mask_off")

	if zbl.config.Respirator.nodraw then return end

	if IsValid(ply.zbl_GasMask_model) then

		// Spawn Client GasMask model falling of player
		zbl.GasMask.PhysicsHandler_Create(ply:GetPos() + Vector(0,0,60))

		SafeRemoveEntity(ply.zbl_GasMask_model)
		zclib.Debug("ClientModel removed")
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

    if not show then return end
    local cs = ents.CreateClientProp()
	if not IsValid(cs) then return end
	if not cs.SetModel then return end

    local maskData = zbl.config.Respirator.styles[maskID]

    cs.zbl_OwnerID = zclib.Player.GetOwnerID(ply)
    cs.zbl_Owner = ply
    cs:SetModel(maskData.model)
    cs:SetSkin(maskData.skin)
    cs:SetNoDraw(true)
    cs:SetPredictable(false)
    cs:DrawShadow(false)
    cs:DestroyShadow()
    cs:SetMoveType(MOVETYPE_NONE)
    cs:Spawn()
    ply.zbl_GasMask_model = cs
    zclib.Debug("ClientModel created")
end


local function DrawHUD()
    local pos_x = (1920 / 100) * zclib.Convar.Get("zbl_cl_mask_pos_x")
    local pos_y = (1080 / 100) * zclib.Convar.Get("zbl_cl_mask_pos_y")

    local scale = zclib.Convar.Get("zbl_cl_mask_scale")

    local width,height = 150 * scale, 150 * scale

    pos_x = pos_x - (width / 2)
    pos_y = pos_y - (height / 2)

    draw.RoundedBox(100 * scale, pos_x * zclib.wM, pos_y * zclib.hM, width * zclib.wM, height * zclib.hM, zbl.colors["black02"])

    surface.SetDrawColor(zbl.colors["white04"])
    surface.SetMaterial(zbl.materials["zbl_mask_off"])
    surface.DrawTexturedRect(pos_x * zclib.wM, pos_y * zclib.hM, width * zclib.wM, height * zclib.hM)

    surface.SetDrawColor(zbl.colors["cure_green"])
    surface.SetMaterial(zbl.materials["zbl_mask_on"])
    surface.DrawTexturedRect(pos_x * zclib.wM, pos_y * zclib.hM, width * zclib.wM, height * zclib.hM)

    local max_uses = zbl.GasMask.GetMaxUses(LPly.zbl_MaskID)
    draw.SimpleText(math.Round((100 / max_uses) * zbl.GasMask.GetUses(LPly)) .. "%", zclib.GetFont("zbl_gasmaskhud_font01"), (pos_x + (width / 2)) * zclib.wM, (pos_y + (height / 1.6)) * zclib.hM, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

zclib.Hook.Add("HUDPaint", "zbl_Gasmask_HUDPaint", function()
	if not IsValid(LPly) then
        LPly = LocalPlayer()
    else
	    if zclib.Convar.Get("zbl_cl_mask_enabled") == 1 and LPly.zbl_MaskEquipt then
	        DrawHUD()
	    end
	end
end)

// If we dont draw the models then anything below becomes irelevant
if zbl.config.Respirator.nodraw then return end

function zbl.GasMask.Draw(ply)
    if not IsValid(ply.zbl_GasMask_model) then return end
    local pos, ang , scale

    local boneid = ply:LookupBone("ValveBiped.Bip01_Head1")
    local offset = zbl.ModelOffsets[ply:GetModel()]

    if boneid then
        local mat = ply:GetBoneMatrix(boneid)
        if not mat then return end
        pos, ang = mat:GetTranslation(), mat:GetAngles()
        local start_ang = ang
        ang:RotateAroundAxis(start_ang:Forward(), -90)
        ang:RotateAroundAxis(start_ang:Right(), -90)

        if offset == nil then
            offset = zbl.ModelOffsets["Default"]
        end

        ang:RotateAroundAxis(start_ang:Up(), offset.ang.y)
        ang:RotateAroundAxis(start_ang:Right(), offset.ang.p)
        ang:RotateAroundAxis(start_ang:Forward(), offset.ang.r)
        pos:Set(pos + ang:Forward() * offset.pos.x + ang:Right() * offset.pos.y + ang:Up() * offset.pos.z)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337


        if offset.scale then
            scale = offset.scale
        else
            scale = 1
        end
    else
        pos = ply:GetPos()
        ang = Angle(0, 0, 0)
        scale = 1
    end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

    ply.zbl_GasMask_model:SetPos(pos)
    ply.zbl_GasMask_model:SetAngles(ang)
    ply.zbl_GasMask_model:SetModelScale(scale)
    ply.zbl_GasMask_model:SetRenderOrigin(pos)
    ply.zbl_GasMask_model:SetRenderAngles(ang)
    ply.zbl_GasMask_model:SetupBones()
    ply.zbl_GasMask_model:DrawModel()
end

zclib.Hook.Add("PostPlayerDraw", "zbl_GasMask_PostPlayerDraw", function(ply)
	if IsValid(LPly) and IsValid(ply) and ply:Alive() and zclib.util.InDistance(LPly:GetPos(), ply:GetPos(), 1000) then
		zbl.GasMask.Draw(ply)
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

gameevent.Listen("player_disconnect")
zclib.Hook.Add("player_disconnect", "zbl_GasMask_player_disconnect", function(data)
    for k, v in pairs(ents.GetAll()) do
        if IsValid(v) and v.zbl_OwnerID and v.zbl_OwnerID == data.networkid then
            SafeRemoveEntity(v)
        end
    end
end)

local zbl_GasmaskObjects = {}
function zbl.GasMask.PhysicsHandler_Create(pos)
    zclib.Debug("zbl.GasMask.PhysicsHandler_Create " .. tostring(pos))

    local ent = ents.CreateClientProp()
	if not IsValid(ent) then return end
	if not ent.SetModel then return end
    ent:SetModel("models/zerochain/props_bloodlab/zbl_n95mask_worn.mdl")
    ent:SetPos(pos)
    ent:SetAngles(Angle(0, 0, 0))
    ent:Spawn()
    ent:PhysicsInit(SOLID_VPHYSICS)
    ent:SetSolid(SOLID_NONE)
    ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:SetRenderMode(RENDERMODE_NORMAL)

    local phys = ent:GetPhysicsObject()

    if IsValid(phys) then
        phys:SetMass(25)
        phys:Wake()
        phys:EnableMotion(true)
        phys:SetDragCoefficient(100)

        local tickrate = 66.6 * engine.TickInterval()
        tickrate = tickrate * 64
        tickrate = math.Clamp(tickrate, 15, 64)


        local f_force = tickrate * 2
        local f_dir = Vector(math.Rand(-1,1), math.Rand(-1,1), 1) * f_force
        phys:ApplyForceCenter(phys:GetMass() * f_dir)

        local val = 0.9
        local angVel = (Vector(0, 0, 1) * math.Rand(-val, val)) * phys:GetMass() * tickrate
        phys:AddAngleVelocity(angVel)
    else
        SafeRemoveEntity(ent)
    end

    table.insert(zbl_GasmaskObjects, {
        ent = ent,
        remove_time = CurTime() + 5,
    })
end

function zbl.GasMask.PhysicsHandler()
    if IsValid(LPly) and #zbl_GasmaskObjects > 0 then

        local ply = LPly
        local distance = 1000

        for k, v in pairs(zbl_GasmaskObjects) do
            if IsValid(v.ent) and not zclib.util.InDistance(ply:GetPos(), v.ent:GetPos(), distance) or CurTime() >= v.remove_time then
                SafeRemoveEntity(v.ent)
                table.remove(zbl_GasmaskObjects, k)
            end
        end
    end
end
zclib.Hook.Add("Think", "zbl_think_GasMask_PhysicsHandler_cl", zbl.GasMask.PhysicsHandler)
