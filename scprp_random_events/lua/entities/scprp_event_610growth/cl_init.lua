include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    local angle = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

    cam.Start3D2D(self:GetPos() + Vector(0, 0, 42), angle, 0.11)
        draw.RoundedBox(6, -145, -34, 290, 68, Color(20, 6, 6, 238))
        draw.SimpleText("SCP-610 BIOMASS", "DermaLarge", 0, -12, Color(235, 85, 75), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.RoundedBox(3, -115, 12, 230, 10, Color(55, 25, 25))
        draw.RoundedBox(3, -115, 12, 230 * (self:GetIntegrity() / 100), 10, Color(210, 55, 45))
    cam.End3D2D()
end
