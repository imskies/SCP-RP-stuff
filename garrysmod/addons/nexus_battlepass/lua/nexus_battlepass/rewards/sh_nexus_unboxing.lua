local color_zero = Color(0, 0, 0, 0)
Nexus.Battlepass.Rewards["nexus_unboxing"] = {
    Name = "Nexus Unboxing",
    Numeric = true,
    Display = function(panel, value)
        value = tonumber(value)

        local col = table.Copy(Nexus:GetColor("secondary"))
        col.a = 150

        if not Nexus or not Nexus.Unbox then return end

        local itemDATA = Nexus.Unbox:GetItemFromID(value)
    	if not itemDATA then return end

        local iconType = itemDATA.iconType
        local model = itemDATA.iconPath
        local name = itemDATA.name

        if iconType == "Imgur" then
            local imgurIcon = panel:Add("DPanel")
            imgurIcon:Dock(FILL)
            imgurIcon.Paint = nil
            imgurIcon.PaintOver = function(s, w, h)
                local tw, th = draw.SimpleText(name, Nexus:GetFont({size = 15}), 0, 0, color_zero)
                tw = tw + Nexus:GetMargin()*2
                th = th + Nexus:GetMargin()

                local tall = w*.5
                Nexus:DrawImgur(model, (w/2) - (tall/2), (h/2) - (tall/2), tall, tall)

                Nexus.RNDX.Draw(Nexus:GetMargin(), (w/2) - (tw/2), (h*.9) - (th/2), tw, th, Nexus:GetColor("secondary"), Nexus.RNDX.BLUR)
                Nexus.RNDX.Draw(Nexus:GetMargin(), (w/2) - (tw/2), (h*.9) - (th/2), tw, th, col)

                draw.SimpleText(name, Nexus:GetFont({size = 15}), w/2, h*.9, Nexus:GetTextColor(Nexus:GetColor("secondary")), 1, 1)
            end
        else
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
        end
    end,
    ShouldShow = function()
        return Nexus and Nexus.Unbox
    end,
    OnClaim = function(ply, value)
        value = tonumber(value) or 0
        Nexus.Unbox:GiveItem(ply:SteamID64(), value, 1)
        return true, ""
    end,
}