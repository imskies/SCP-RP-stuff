local color_zero = Color(0, 0, 0, 0)
Nexus.Battlepass.Rewards["Nexus Inventory"] = {
    Name = "Nexus Inventory",
    Numeric = false,
    Display = function(panel, value)
        local col = table.Copy(Nexus:GetColor("secondary"))
        col.a = 150

        local model;
        local name;

        local ent = scripted_ents.GetStored(value)
        if ent then
            ent = ent or {["t"] = {["ClassName"] = data.class}}
            model = "models/Items/ammoCrate_Rockets.mdl"
            name = ent["t"].PrintName or ent["t"].ClassName
        else
            local weapon = weapons.Get(value)
            model = (weapon and weapon.WorldModel or "models/Items/ammoCrate_Rockets.mdl")
            name = weapon and weapon.PrintName or value
        end

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
        return Nexus.Inventory
    end,
    OnClaim = function(ply, value)
        Nexus.Inventory:GiveClass(ply, value)
    end,
}