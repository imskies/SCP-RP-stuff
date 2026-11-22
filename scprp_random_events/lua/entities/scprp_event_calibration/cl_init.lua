include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    local angle = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)
    local stage = self:GetStage()
    local label = stage == 0 and "RESEARCH: CALIBRATE" or "SECURITY: AUTHORIZE"
    local color = stage == 0 and Color(90, 180, 240) or Color(245, 190, 65)

    cam.Start3D2D(self:GetPos() + Vector(0, 0, 38), angle, 0.11)
        draw.RoundedBox(6, -145, -34, 290, 68, Color(8, 12, 18, 235))
        draw.SimpleText(label, "DermaLarge", 0, -12, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.RoundedBox(3, -115, 12, 230, 10, Color(35, 40, 48))
        draw.RoundedBox(3, -115, 12, 230 * (self:GetProgress() / 100), 10, color)
    cam.End3D2D()
end
