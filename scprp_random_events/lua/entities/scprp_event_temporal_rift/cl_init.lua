include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local pos = self:GetPos() + Vector(0, 0, 36 + math.sin(CurTime() * 4) * 6)
    local angle = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)
    local pulse = 120 + math.sin(CurTime() * 6) * 50

    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(pos, 170 + pulse, 170 + pulse, Color(110, 170, 255, 185))

    cam.Start3D2D(pos + Vector(0, 0, 38), angle, 0.11)
        draw.RoundedBox(6, -135, -24, 270, 48, Color(8, 12, 22, 225))
        draw.SimpleText("TEMPORAL RIFT", "DermaLarge", 0, 0, Color(155, 205, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end
