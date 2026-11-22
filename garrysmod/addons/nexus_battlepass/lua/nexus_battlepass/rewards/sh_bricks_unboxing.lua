local color_zero = Color(0, 0, 0, 0)
Nexus.Battlepass.Rewards["bricksunbox"] = {
    Name = "Bricks Unboxing",
    Numeric = true,
    Display = function(panel, value)
        value = tonumber(value)

        local col = table.Copy(Nexus:GetColor("secondary"))
        col.a = 150

        if not BRICKS_SERVER or not BRICKS_SERVER.UNBOXING then return end
        
        local itemDATA = BRICKS_SERVER.UNBOXING.Func.GetItemFromGlobalKey(value)
    	if not itemDATA then return end

        local model = itemDATA.Model
        local name = itemDATA.Name

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
    end,
    ShouldShow = function()
        return BRICKS_SERVER and BRICKS_SERVER.UNBOXING
    end,
    OnClaim = function(ply, value)
        value = tonumber(value) or 0
        ply:AddUnboxingInventoryItem(value, 1)
        return true, ""
    end,
}