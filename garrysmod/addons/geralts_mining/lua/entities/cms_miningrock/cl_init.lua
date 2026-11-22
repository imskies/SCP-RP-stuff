include("shared.lua")
local v = Vector()

function ENT:Draw()
	local getfromtable = MININGSYSTEM.Ores[self:GetNWString("RockType")] 
	self:DrawModel()
	if LocalPlayer():GetPos():Distance(self:GetPos()) > 350 then return end
	if !getfromtable then return end
	local ang = self:GetAngles();

	ang:RotateAroundAxis(ang:Forward(), 90);
	ang:RotateAroundAxis(ang:Right(), -90);

    local ang = self:GetAngles()
	ang:RotateAroundAxis(self:GetAngles():Right(), 90)
	ang:RotateAroundAxis(self:GetAngles():Forward(), 90)
	cam.Start3D2D(self:GetPos() + ang:Up(), Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.1)
		v.z = math.sin( CurTime() ) * 60
		if getfromtable.Icon == icons.wood then 
			draw.SimpleTextOutlined(getfromtable.Name, "CMS_EntityFont", v.x - 300, ( v.z / 2 ) - 625, getfromtable.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0))
		else
			draw.SimpleTextOutlined(getfromtable.Name .. " " .. getfromtable.Type, "CMS_EntityFont", v.x  - 0, ( v.z / 2 ) - 625, getfromtable.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0))
		end 
		cam.End3D2D()
end

function ENT:Think()
	local getfromtable = MININGSYSTEM.Ores[self:GetNWString("RockType")] 
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
				dlight.Brightness = getfromtable.Brightness
				dlight.Size =  (math.sin( CurTime() ) * 300) + getfromtable.Size
				dlight.Decay = 0
				dlight.DieTime = CurTime() + 0.05
			end
		end 
end