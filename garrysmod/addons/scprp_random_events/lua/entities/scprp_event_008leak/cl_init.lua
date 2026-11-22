include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    local angle = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

    cam.Start3D2D(self:GetPos() + Vector(0, 0, 65), angle, 0.11)
        draw.RoundedBox(6, -155, -36, 310, 72, Color(8, 14, 10, 238))
        draw.SimpleText("SCP-008 LEAK • HOLD E", "DermaLarge", 0, -13, Color(175, 225, 90), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.RoundedBox(3, -120, 13, 240, 11, Color(35, 45, 35))
        draw.RoundedBox(3, -120, 13, 240 * (self:GetNeutralization() / 100), 11, Color(130, 215, 75))
    cam.End3D2D()
end
