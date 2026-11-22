local color_zero = Color(0, 0, 0, 0)
Nexus.Battlepass.Rewards["money"] = {
    Name = "DarkRP $",
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
            local tw, th = draw.SimpleText(DarkRP.formatMoney(value), Nexus:GetFont({size = 15}), 0, 0, color_zero)
            tw = tw + Nexus:GetMargin()*2
            th = th + Nexus:GetMargin()

            Nexus.RNDX.Draw(Nexus:GetMargin(), (w/2) - (tw/2), (h*.9) - (th/2), tw, th, Nexus:GetColor("secondary"), Nexus.RNDX.BLUR)
            Nexus.RNDX.Draw(Nexus:GetMargin(), (w/2) - (tw/2), (h*.9) - (th/2), tw, th, col)

            draw.SimpleText(DarkRP.formatMoney(value), Nexus:GetFont({size = 15}), w/2, h*.9, Nexus:GetTextColor(Nexus:GetColor("secondary")), 1, 1)
        end
    end,
    ShouldShow = function()
        return DarkRP
    end,
    OnClaim = function(ply, value)
        ply:addMoney(tonumber(value) or 0)
        return true, ""
    end,
}