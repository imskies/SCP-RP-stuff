include('shared.lua')

local v = Vector()
function ENT:Draw()
	local getfromtable = MININGSYSTEM.Ores[self:GetNWString("OreType")]
	self:DrawModel()

	if LocalPlayer():GetPos():Distance(self:GetPos()) > 250 then return end
	local ang = self:GetAngles();
	if !getfromtable then return end
	ang:RotateAroundAxis(ang:Forward(), 90);
	ang:RotateAroundAxis(ang:Right(), -90);

    local ang = self:GetAngles()
	ang:RotateAroundAxis(self:GetAngles():Right(), 90)
	ang:RotateAroundAxis(self:GetAngles():Forward(), 90)

	cam.Start3D2D(self:GetPos() + ang:Up(), Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.1)
		v.z = math.sin( CurTime() ) * 60
			if self:GetNWString("OreClass") == "Wood" then 
				draw.SimpleTextOutlined(self:GetNWString("OreClass"), "CMS_EntityFont", v.x - 0, ( v.z / 2 ) - 320, getfromtable.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0))
			else 
				draw.SimpleTextOutlined(self:GetNWString("OreType") .. " " ..self:GetNWString("OreClass"), "CMS_EntityFont", v.x - 0, ( v.z / 2 ) - 320, getfromtable.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0))
			end 
	cam.End3D2D()
end


function ENT:Think()
	local getfromtable = MININGSYSTEM.Ores[self:GetNWString("OreType")] 
	if !getfromtable then return end 
	if LocalPlayer():GetPos():Distance(self:GetPos()) > 512 then return end
		if getfromtable.Radioactive == true then 
			local rgba = self:GetColor();
			local dlight = DynamicLight( self:EntIndex() )
			if ( dlight ) then
				dlight.Pos = self:GetPos() 
				dlight.r = getfromtable.Color.r
				dlight.g = getfromtable.Color.g
				dlight.b = getfromtable.Color.b
				dlight.Brightness = getfromtable.Brightness - 1.2
				dlight.Size =  (math.sin( CurTime() ) * 15) + getfromtable.Size - 450
				dlight.Decay = 0
				dlight.DieTime = CurTime() + 0.05
			end
		end 
end