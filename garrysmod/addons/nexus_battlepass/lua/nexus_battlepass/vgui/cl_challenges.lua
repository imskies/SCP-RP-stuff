local PANEL = {}
function PANEL:Init()
    self.Scroll = self:Add("Nexus:V2:ScrollPanel")
    self.Scroll:Dock(FILL)

    local tbl = {}
    for id, v in pairs(Nexus.Battlepass.Challenges) do
        table.insert(tbl, {id = id, text = v.Category()})
    end

    table.sort(tbl, function(a, b)
        return a.text < b.text        
    end)

    for _, v in ipairs(tbl) do
        local data = Nexus.Battlepass.Challenges[v.id]
        local category = self.Scroll:Add("Nexus:Category")
        category:Dock(TOP)
        category:DockMargin(0, 0, 0, Nexus:GetMargin())
        category:SetText(data.Category())

        for _, challengeDATA in ipairs(data.Challenges) do
            local panel = category:AddItem("DPanel")
            panel:SetTall(Nexus:GetScale(30))
            panel.Paint = function(s, w, h)
                Nexus.RNDX.Draw(Nexus:GetMargin(), 0, 0, w, h, Nexus:GetColor("secondary-2"))

                local curProgress = math.min(challengeDATA.Amount, Nexus.Battlepass:GetChallengeProgress(v.id))
                local percentage = (curProgress/challengeDATA.Amount)

                local x, y = s:LocalToScreen()
                render.SetScissorRect(x, y, x + w*percentage, y + h, true)
                    Nexus.RNDX.Draw(Nexus:GetMargin(), 0, 0, w, h, Nexus:GetColor("green"))
                render.SetScissorRect(0, 0, 0, 0, false)

                draw.SimpleText(data.Format(curProgress, challengeDATA.Amount), Nexus:GetFont({size = 15}), w/2, h/2, Nexus:GetTextColor(Nexus:GetColor(percentage > 0.5 and "green" or "secondary-2")), 1, 1)
            end
        end
    end
end
vgui.Register("Nexus:Battlepass:Challenges", PANEL, "EditablePanel")