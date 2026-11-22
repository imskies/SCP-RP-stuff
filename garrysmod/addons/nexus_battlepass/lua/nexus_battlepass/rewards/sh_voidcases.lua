local color_zero = Color(0, 0, 0, 0)
Nexus.Battlepass.Rewards["voidcases"] = {
    Name = "Voidcases",
    Numeric = true,
    Display = function(panel, value)
        value = tonumber(value)

        local col = table.Copy(Nexus:GetColor("secondary"))
        col.a = 150

        if not VoidCases then return end

        local data = VoidCases.Config.Items[itemVal]
        local name = data.name
        local model = data and data.info.icon or ".mdl"

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
        modelEnt.LayoutEntity = function() return true end

        modelEnt.PaintOver = function(s, w, h)
            local tw, th = draw.SimpleText(name, Nexus:GetFont({size = 15}), 0, 0, color_zero)
            tw = tw + Nexus:GetMargin()*2
            th = th + Nexus:GetMargin()

            Nexus.RNDX.Draw(Nexus:GetMargin(), (w/2) - (tw/2), (h*.9) - (th/2), tw, th, Nexus:GetColor("secondary"), Nexus.RNDX.BLUR)
            Nexus.RNDX.Draw(Nexus:GetMargin(), (w/2) - (tw/2), (h*.9) - (th/2), tw, th, col)

            draw.SimpleText(name, Nexus:GetFont({size = 15}), w/2, h*.9, Nexus:GetTextColor(Nexus:GetColor("secondary")), 1, 1)
        end

        if not data or not IsValid(modelEnt.Entity) then return end
  
        if data.info.caseColor then
            local col = data.info.caseColor
            modelEnt.Entity:SetNWVector("CrateColor", Color(col.r, col.g, col.b):ToVector())
        end

        if data.info.caseIcon then
            VoidCases.FetchImage(data.info.caseIcon, function() end)
            modelEnt.Entity:SetNWString("CrateLogo", data.info.caseIcon)
        end
    end,
    ShouldShow = function()
        return VoidCases
    end,
    OnClaim = function(ply, value)
        value = tonumber(value) or 0
        VoidCases.AddItem(ply:SteamID64(), value, 1)
        return true, ""
    end,
}