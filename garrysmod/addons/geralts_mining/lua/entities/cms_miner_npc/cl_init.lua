include('shared.lua')
local black = Color(0,0,0)
local v = Vector()
function ENT:Draw()
	self:DrawModel()
	if LocalPlayer():GetPos():Distance(self:GetPos()) > 250 then return end
	local ang = self:GetAngles();

	ang:RotateAroundAxis(ang:Forward(), 90);
	ang:RotateAroundAxis(ang:Right(), -90);

    local ang = self:GetAngles()
	ang:RotateAroundAxis(self:GetAngles():Right(), 90)
	ang:RotateAroundAxis(self:GetAngles():Forward(), 90)
	cam.Start3D2D(self:GetPos() + ang:Up(), Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.1)
		v.z = math.sin( CurTime() ) * 60
		
			draw.SimpleTextOutlined(MINING_Language[MININGSYSTEM.CurrentLanguage].MinerTitle, "CMS_EntityFont", v.x , ( v.z / 2 ) - 825, MININGSYSTEM.Colors.Background, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, black) 
		
		cam.End3D2D()
end