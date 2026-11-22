local color_zero = Color(0, 0, 0, 0)
Nexus.Battlepass.Rewards["mtokens"] = {
    Name = "MTokens",
    Numeric = true,
    Display = function(panel, value)
        value = tonumber(value) or 0

        local col = table.Copy(Nexus:GetColor("secondary"))
        col.a = 150

        local imgurIcon = panel:Add("DPanel")
        imgurIcon:Dock(FILL)
        imgurIcon.Paint = nil
        imgurIcon.PaintOver = function(s, w, h)
            local tw, th = draw.SimpleText(string.Comma(value).." Tokens", Nexus:GetFont({size = 15}), 0, 0, color_zero)
            tw = tw + Nexus:GetMargin()*2
            th = th + Nexus:GetMargin()

            local tall = w*.5
            Nexus:DrawImgur("https://imgur.com/s4vll4U", (w/2) - (tall/2), (h/2) - (tall/2), tall, tall, Nexus:GetColor("green"))

            Nexus.RNDX.Draw(Nexus:GetMargin(), (w/2) - (tw/2), (h*.9) - (th/2), tw, th, Nexus:GetColor("secondary"), Nexus.RNDX.BLUR)
            Nexus.RNDX.Draw(Nexus:GetMargin(), (w/2) - (tw/2), (h*.9) - (th/2), tw, th, col)

            draw.SimpleText(string.Comma(value).." Tokens", Nexus:GetFont({size = 15}), w/2, h*.9, Nexus:GetTextColor(Nexus:GetColor("secondary")), 1, 1)
        end
    end,
    ShouldShow = function()
        return mTokens
    end,
    OnClaim = function(ply, value)
        value = tonumber(value) or 0
        mTokens.AddPlayerTokens(ply, value)
    end,
}