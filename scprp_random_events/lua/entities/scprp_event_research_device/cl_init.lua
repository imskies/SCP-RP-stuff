include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local angle = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)
    local label = self:GetDeviceLabel()
    local action = self:GetActionLabel()
    local color = Color(150, 210, 255)

    cam.Start3D2D(self:GetPos() + Vector(0, 0, 36), angle, 0.1)
        draw.RoundedBox(6, -155, -42, 310, 84, Color(8, 12, 18, 235))
        draw.SimpleText(label, "DermaLarge", 0, -19, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(action, "DermaDefaultBold", 0, 4, Color(225, 235, 245), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.RoundedBox(3, -120, 20, 240, 10, Color(35, 40, 48))
        draw.RoundedBox(3, -120, 20, 240 * math.Clamp(self:GetProgress() / 100, 0, 1), 10, color)
    cam.End3D2D()
end
