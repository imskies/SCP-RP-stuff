local color_zero = Color(0, 0, 0, 0)
Nexus.Battlepass.Rewards["weapon"] = {
    Name = "Weapon / Entity",
    Numeric = false,
    Display = function(panel, value)
        local col = table.Copy(Nexus:GetColor("secondary"))
        col.a = 150

        local weapon = weapons.Get(value)
        local model = (weapon and weapon.WorldModel or "models/Items/ammoCrate_Rockets.mdl")
        local name = weapon and weapon.PrintName or value

        local modelEnt = panel:Add("DModelPanel")
        modelEnt:SetModel(model)
        modelEnt:Dock(FILL)

        local mn, mx = modelEnt.Entity:GetRenderBounds()
        local size = 0
        size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
        size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
        size = math.max(size, math.abs(mn.z) + math.abs(mx.z))

        modelEnt:SetFOV(45)
        modelEnt:SetCamPos(Vector(size, size, size))
        modelEnt:SetLookAt((mn + mx) * 0.5)
        modelEnt.LayoutEntity = function() end
        modelEnt.PaintOver = function(s, w, h)
            local tw, th = draw.SimpleText(name, Nexus:GetFont({size = 15}), 0, 0, color_zero)
            tw = tw + Nexus:GetMargin()*2
            th = th + Nexus:GetMargin()

            Nexus.RNDX.Draw(Nexus:GetMargin(), (w/2) - (tw/2), (h*.9) - (th/2), tw, th, Nexus:GetColor("secondary"), Nexus.RNDX.BLUR)
            Nexus.RNDX.Draw(Nexus:GetMargin(), (w/2) - (tw/2), (h*.9) - (th/2), tw, th, col)

            draw.SimpleText(name, Nexus:GetFont({size = 15}), w/2, h*.9, Nexus:GetTextColor(Nexus:GetColor("secondary")), 1, 1)
        end
    end,
    ShouldShow = function()
        return true
    end,
    OnClaim = function(ply, value)
        if ply:HasWeapon(value) then
            return false, Nexus:GetPhrase("Already holding", "nBattlepass", ply)
        end

        ply:Give(value)
        return true, ""
    end,
}