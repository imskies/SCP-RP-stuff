if CLIENT then
	SWEP.PrintName = "Pickaxe"
	SWEP.Slot = 1
	SWEP.SlotPos = 5
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "\nCODE: Geralt Of Rivia\nMODEL: Yogensia"
SWEP.Instructions = "Left Click: Mine Ore"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 90
SWEP.ViewModelFlip = false
SWEP.ViewModel 	= Model( "models/weapons/melee/v_fireaxe.mdl" )
SWEP.WorldModel = Model( "models/weapons/melee/w_fireaxe.mdl" )

SWEP.UseHands = false

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "Mining System"

SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = false;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.Damage = 1;
SWEP.Primary.Delay = 0.5;
SWEP.Primary.Ammo = "";
SWEP.HoldType = "melee2"

--[[-------------------------------------------------------
Name: SWEP:Initialize()
Desc: Called when the weapon is first loaded
---------------------------------------------------------]]
SWEP.WElements = {
	["element_name"] = { type = "Model", model = "models/weapons/melee/w_fireaxe.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.635, 1.557, 0), angle = Angle(0, 0, 180), size = Vector(0.8, 0.8, 0.8), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

function SWEP:Deploy()
    self:SetWeaponHoldType( "melee2" )
end 

function SWEP:Initialize()
    self:SetWeaponHoldType( "melee2" )
 
    if CLIENT then
   
 
        self.VElements = table.FullCopy( self.VElements )
        self.WElements = table.FullCopy( self.WElements )
        self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )
 
        self:CreateModels(self.VElements)
        self:CreateModels(self.WElements)
       
   
        if IsValid(self.Owner) then
            local vm = self.Owner:GetViewModel()
            if IsValid(vm) then
                self:ResetBonePositions(vm)
               
                if (self.ShowViewModel == nil or self.ShowViewModel) then
                    vm:SetColor(Color(255,255,255,255))
                else
                    vm:SetColor(Color(255,255,255,1))
                    vm:SetMaterial("Debug/hsv")        
                end
            end
        end
       
    end
 
end
 
function SWEP:Holster()
   
    if CLIENT and IsValid(self.Owner) then
        local vm = self.Owner:GetViewModel()
        if IsValid(vm) then
            self:ResetBonePositions(vm)
        end
    end
   
    return true
end
 
function SWEP:OnRemove()
    self:Holster()
end
 
if CLIENT then
 
    SWEP.vRenderOrder = nil
    function SWEP:ViewModelDrawn()
       
        local vm = self.Owner:GetViewModel()
        if !IsValid(vm) then return end
       
        if (!self.VElements) then return end
       
        self:UpdateBonePositions(vm)
 
        if (!self.vRenderOrder) then
           
            self.vRenderOrder = {}
 
            for k, v in pairs( self.VElements ) do
                if (v.type == "Model") then
                    table.insert(self.vRenderOrder, 1, k)
                elseif (v.type == "Sprite" or v.type == "Quad") then
                    table.insert(self.vRenderOrder, k)
                end
            end
           
        end
 
        for k, name in ipairs( self.vRenderOrder ) do
       
            local v = self.VElements[name]
            if (!v) then self.vRenderOrder = nil break end
            if (v.hide) then continue end
           
            local model = v.modelEnt
            local sprite = v.spriteMaterial
           
            if (!v.bone) then continue end
           
            local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
           
            if (!pos) then continue end
           
            if (v.type == "Model" and IsValid(model)) then
 
                model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)
 
                model:SetAngles(ang)
                //model:SetModelScale(v.size)
                local matrix = Matrix()
                matrix:Scale(v.size)
                model:EnableMatrix( "RenderMultiply", matrix )
               
                if (v.material == "") then
                    model:SetMaterial("")
                elseif (model:GetMaterial() != v.material) then
                    model:SetMaterial( v.material )
                end
               
                if (v.skin and v.skin != model:GetSkin()) then
                    model:SetSkin(v.skin)
                end
               
                if (v.bodygroup) then
                    for k, v in pairs( v.bodygroup ) do
                        if (model:GetBodygroup(k) != v) then
                            model:SetBodygroup(k, v)
                        end
                    end
                end
               
                if (v.surpresslightning) then
                    render.SuppressEngineLighting(true)
                end
               
                render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
                render.SetBlend(v.color.a/255)
                model:DrawModel()
                render.SetBlend(1)
                render.SetColorModulation(1, 1, 1)
               
                if (v.surpresslightning) then
                    render.SuppressEngineLighting(false)
                end
               
            elseif (v.type == "Sprite" and sprite) then
               
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                render.SetMaterial(sprite)
                render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
               
            elseif (v.type == "Quad" and v.draw_func) then
               
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)
               
                cam.Start3D2D(drawpos, ang, v.size)
                    v.draw_func( self )
                cam.End3D2D()
 
            end
           
        end
       
    end
 
    SWEP.wRenderOrder = nil
    function SWEP:DrawWorldModel()       
        if (!self.WElements) then return end
       
        if (!self.wRenderOrder) then
 
            self.wRenderOrder = {}
 
            for k, v in pairs( self.WElements ) do
                if (v.type == "Model") then
                    table.insert(self.wRenderOrder, 1, k)
                elseif (v.type == "Sprite" or v.type == "Quad") then
                    table.insert(self.wRenderOrder, k)
                end
            end
 
        end
       
        if (IsValid(self.Owner)) then
            bone_ent = self.Owner
        else
            bone_ent = self
        end
       
        for k, name in pairs( self.wRenderOrder ) do
       
            local v = self.WElements[name]
            if (!v) then self.wRenderOrder = nil break end
            if (v.hide) then continue end
           
            local pos, ang
           
            if (v.bone) then
                pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
            else
                pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
            end
           
            if (!pos) then continue end
           
            local model = v.modelEnt
            local sprite = v.spriteMaterial
           
            if (v.type == "Model" and IsValid(model)) then
 
                model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)
 
                model:SetAngles(ang)
                //model:SetModelScale(v.size)
                local matrix = Matrix()
                matrix:Scale(v.size)
                model:EnableMatrix( "RenderMultiply", matrix )
               
                if (v.material == "") then
                    model:SetMaterial("")
                elseif (model:GetMaterial() != v.material) then
                    model:SetMaterial( v.material )
                end
               
                if (v.skin and v.skin != model:GetSkin()) then
                    model:SetSkin(v.skin)
                end
               
                if (v.bodygroup) then
                    for k, v in pairs( v.bodygroup ) do
                        if (model:GetBodygroup(k) != v) then
                            model:SetBodygroup(k, v)
                        end
                    end
                end
               
                if (v.surpresslightning) then
                    render.SuppressEngineLighting(true)
                end
               
                render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
                render.SetBlend(v.color.a/255)
                model:DrawModel()
                render.SetBlend(1)
                render.SetColorModulation(1, 1, 1)
               
                if (v.surpresslightning) then
                    render.SuppressEngineLighting(false)
                end
               
            elseif (v.type == "Sprite" and sprite) then
               
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                render.SetMaterial(sprite)
                render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
               
            elseif (v.type == "Quad" and v.draw_func) then
               
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)
               
                cam.Start3D2D(drawpos, ang, v.size)
                    v.draw_func( self )
                cam.End3D2D()
 
            end
           
        end
       
    end
 
    function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
       
        local bone, pos, ang
        if (tab.rel and tab.rel != "") then
           
            local v = basetab[tab.rel]
           
            if (!v) then return end
           
            pos, ang = self:GetBoneOrientation( basetab, v, ent )
           
            if (!pos) then return end
           
            pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)
               
        else
       
            bone = ent:LookupBone(bone_override or tab.bone)
 
            if (!bone) then return end
           
            pos, ang = Vector(0,0,0), Angle(0,0,0)
            local m = ent:GetBoneMatrix(bone)
            if (m) then
                pos, ang = m:GetTranslation(), m:GetAngles()
            end
           
            if (IsValid(self.Owner) and self.Owner:IsPlayer() and
                ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
                ang.r = -ang.r
            end
       
        end
       
        return pos, ang
    end
 
    function SWEP:CreateModels( tab )
 
        if (!tab) then return end
 
        for k, v in pairs( tab ) do
            if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and
                    string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
               
                v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
                if (IsValid(v.modelEnt)) then
                    v.modelEnt:SetPos(self:GetPos())
                    v.modelEnt:SetAngles(self:GetAngles())
                    v.modelEnt:SetParent(self)
                    v.modelEnt:SetNoDraw(true)
                    v.createdModel = v.model
                else
                    v.modelEnt = nil
                end
               
            elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite)
                and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
               
                local name = v.sprite.."-"
                local params = { ["$basetexture"] = v.sprite }
                local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
                for i, j in pairs( tocheck ) do
                    if (v[j]) then
                        params["$"..j] = 1
                        name = name.."1"
                    else
                        name = name.."0"
                    end
                end
 
                v.createdSprite = v.sprite
                v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
               
            end
        end
       
    end
   
    local allbones
    local hasGarryFixedBoneScalingYet = false
 
    function SWEP:UpdateBonePositions(vm)
       
        if self.ViewModelBoneMods then
           
            if (!vm:GetBoneCount()) then return end
           
            local loopthrough = self.ViewModelBoneMods
            if (!hasGarryFixedBoneScalingYet) then
                allbones = {}
                for i=0, vm:GetBoneCount() do
                    local bonename = vm:GetBoneName(i)
                    if (self.ViewModelBoneMods[bonename]) then
                        allbones[bonename] = self.ViewModelBoneMods[bonename]
                    else
                        allbones[bonename] = {
                            scale = Vector(1,1,1),
                            pos = Vector(0,0,0),
                            angle = Angle(0,0,0)
                        }
                    end
                end
               
                loopthrough = allbones
            end
           
            for k, v in pairs( loopthrough ) do
                local bone = vm:LookupBone(k)
                if (!bone) then continue end
               
                local s = Vector(v.scale.x,v.scale.y,v.scale.z)
                local p = Vector(v.pos.x,v.pos.y,v.pos.z)
                local ms = Vector(1,1,1)
                if (!hasGarryFixedBoneScalingYet) then
                    local cur = vm:GetBoneParent(bone)
                    while(cur >= 0) do
                        local pscale = loopthrough[vm:GetBoneName(cur)].scale
                        ms = ms * pscale
                        cur = vm:GetBoneParent(cur)
                    end
                end
               
                s = s * ms
               
                if vm:GetManipulateBoneScale(bone) != s then
                    vm:ManipulateBoneScale( bone, s )
                end
                if vm:GetManipulateBoneAngles(bone) != v.angle then
                    vm:ManipulateBoneAngles( bone, v.angle )
                end
                if vm:GetManipulateBonePosition(bone) != p then
                    vm:ManipulateBonePosition( bone, p )
                end
            end
        else
            self:ResetBonePositions(vm)
        end
           
    end
     
    function SWEP:ResetBonePositions(vm)
       
        if (!vm:GetBoneCount()) then return end
        for i=0, vm:GetBoneCount() do
            vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
            vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
            vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
        end
       
    end
 
 
    function table.FullCopy( tab )
 
        if (!tab) then return nil end
       
        local res = {}
        for k, v in pairs( tab ) do
            if (type(v) == "table") then
                res[k] = table.FullCopy(v)
            elseif (type(v) == "Vector") then
                res[k] = Vector(v.x, v.y, v.z)
            elseif (type(v) == "Angle") then
                res[k] = Angle(v.p, v.y, v.r)
            else
                res[k] = v
            end
        end
       
        return res
       
    end
   
end

function SWEP:DoHitEffects()
	local trace = self.Owner:GetEyeTraceNoCursor();
	
	if (((trace.Hit or trace.HitWorld) and self.Owner:GetShootPos():Distance(trace.HitPos) <= 64)) then
		self:SendWeaponAnim(ACT_VM_HITCENTER);
		self:EmitSound("physics/metal/metal_solid_impact_hard" .. math.random(4,5) .. ".wav");
	else
		self:SendWeaponAnim(ACT_VM_MISSCENTER);
		self:EmitSound("npc/vort/claw_swing2.wav");
	end;
end;

function SWEP:DoAnimations(idle)
	if (!idle) then
		self.Owner:SetAnimation(PLAYER_ATTACK1);
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	end;
end;

--[[-------------------------------------------------------
Name: SWEP:PrimaryAttack()
Desc: +attack1 has been pressed
---------------------------------------------------------]]
function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
	self:DoAnimations();
	self:DoHitEffects();
	
	if (SERVER) then
		if (self.Owner.LagCompensation) then
			self.Owner:LagCompensation(true);
		end;
		
		local trace = self.Owner:GetEyeTraceNoCursor();
		
		if (self.Owner:GetShootPos():Distance(trace.HitPos) <= 64) then
			if (IsValid(trace.Entity)) then
				self.Owner:FireBullets({
					Spread = Vector(0, 0, 0),
					Damage = 1,
					Tracer = 0,
					Force = 1,
					Num = 1,
					Src = self.Owner:GetShootPos(),
					Dir = self.Owner:GetAimVector()
				});
			end;
		end;
		
		if (self.Owner.LagCompensation) then
			self.Owner:LagCompensation(false);
		end;
	end;
end

function SWEP:Holster()
	return true
end

function SWEP:Think()
end

function SWEP:DrawHUD()
end

function SWEP:SecondaryAttack()
end
