local color_zero = Color(0, 0, 0, 0)
Nexus.Battlepass.Rewards["helixpoints"] = {
    Name = "Helix $",
    Numeric = true,
    Display = function(panel, value)
        value = tonumber(value or "") or 0

        local col = table.Copy(Nexus:GetColor("secondary"))
        col.a = 150

        local moneyEnt = panel:Add("DModelPanel")
        moneyEnt:SetModel("models/props/cs_assault/money.mdl")
        moneyEnt:Dock(FILL)

        local mn, mx = moneyEnt.Entity:GetRenderBounds()
        local size = 0
        size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
        size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
        size = math.max(size, math.abs(mn.z) + math.abs(mx.z))

        moneyEnt:SetFOV(45)
        moneyEnt:SetCamPos(Vector(size, size, size))
        moneyEnt:SetLookAt((mn + mx) * 0.5)

        moneyEnt.PaintOver = function(s, w, h)
            local tw, th = draw.SimpleText("$"..string.Comma(value), Nexus:GetFont({size = 15}), 0, 0, color_zero)
            tw = tw + Nexus:GetMargin()*2
            th = th + Nexus:GetMargin()

            Nexus.RNDX.Draw(Nexus:GetMargin(), (w/2) - (tw/2), (h*.9) - (th/2), tw, th, Nexus:GetColor("secondary"), Nexus.RNDX.BLUR)
            Nexus.RNDX.Draw(Nexus:GetMargin(), (w/2) - (tw/2), (h*.9) - (th/2), tw, th, col)

            draw.SimpleText("$"..string.Comma(value), Nexus:GetFont({size = 15}), w/2, h*.9, Nexus:GetTextColor(Nexus:GetColor("secondary")), 1, 1)
        end
    end,
    ShouldShow = function()
        return ix
    end,
    OnClaim = function(ply, value)
        value = tonumber(value) or 0
        ply:GetCharacter():SetMoney(ply:GetCharacter():GetMoney() + value)
    end,
}