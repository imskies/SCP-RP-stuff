ehud.votes = ehud.votes or {}

local function invalidateLayout()
    local panels = ehud.votes
    local amount = #panels
    if amount < 1 then return end

    local panel
    local max_height = esclib.scrh
    local startPos = max_height*0.5
    local cur_height = 0
    local offset = 5

    local amount = #panels

    local total_height = offset*amount
    for k,v in ipairs(panels) do
        total_height = total_height + v:GetTall()
    end

    for k,v in ipairs(panels) do
        panel = panels[k]

        if not IsValid(panel) then
            table.remove(panels,k)
            invalidateLayout()
            return
        end

        if (#panels > 8) then
            local pnl = panels[1]
            pnl:Close()
            table.remove(panels,1)
            invalidateLayout()
            return
        end

        if (total_height > max_height) then
            local pnl = panels[1]
            pnl:Close()
            table.remove(panels,1)
            invalidateLayout()
            return
        end

        --set position
        cur_height = cur_height + panel:GetTall() + 5
        panel:MoveTo(esclib.scrw - panel:GetWide()-5,(startPos - cur_height) + (total_height * 0.5), 0.1)
    end
end

local function MsgDoQuestion(msg, qtype)
	if not IsValid(LocalPlayer()) then return end
    if not DarkRP then return end

    local question = "test\nWants to be\nCivil Protection"--msg:ReadString()
    local voteid = 1--msg:ReadShort()
    local time = 20--msg:ReadFloat()
    if time == 0 then
        time = 5
    end

    if msg then
        question = msg:ReadString()
        if qtype == 0 then --darkrp.........
            voteid = msg:ReadShort()
        elseif qtype == 1 then
            voteid = msg:ReadString()
        end
        time = msg:ReadFloat()
        if time == 0 then
            time = 20
        end
    end

    local startTime = CurTime()
    local clr = ehud.addon:GetColors()

    local panel = vgui.Create("DPanel")
    table.insert(ehud.votes, panel)
    panel:SetPos(esclib.scrw,esclib.scrh*0.5)
    panel:SetWide(esclib.scrw*0.15)
    panel.TimeLeft = CurTime() + time
    panel.id = voteid

    if qtype == 1 then
        panel.question = true
    end

    local panel_accent = clr.main.accent
    function panel:Paint(w,h)
        local fraction = (self.TimeLeft - CurTime()) / time

        ehud:PaintBlur(self,0,0,w,h)

        surface.SetDrawColor(panel_accent.r,panel_accent.g,panel_accent.b,panel_accent.a)
        surface.SetMaterial(ehud.Materials["gradient"])
        surface.DrawTexturedRectRotated(w*0.5*fraction,h,h,w*fraction,90)

        surface.SetDrawColor(clr.main.bg)
        surface.DrawRect(0,0,w+5,h)

        surface.SetDrawColor(panel_accent.r,panel_accent.g,panel_accent.b,panel_accent.a)
        surface.DrawRect(0,h-2,w*fraction,2)
    end

    function panel:Close()
        self.closing = true
        self:MoveTo(esclib.scrw,self:GetY(),0.1,0,-1,function()
            if IsValid(self) then self:Remove() end
            invalidateLayout()
        end)
    end

    function panel:Think(w,h)
        if (CurTime() > self.TimeLeft) and (not self.closing) then
            self:Close()
            return
        end
    end



    local multiline = esclib.text:Multiline(question,"es_ehud_n_18_500",panel:GetWide()-10)
    panel:SetTall(multiline.height+40)

    local text_panel = panel:Add("DPanel")
    text_panel:SetSize(panel:GetWide()-10,multiline.height)
    text_panel:SetPos(5,5)
    function text_panel:Paint(w,h)
        -- draw.RoundedBox(0,0,0,w,h,Color(255,0,0))

        esclib.text:DrawMultiline(multiline,0,0,clr.main.text)
    end


    local clr2 = esclib.addon:GetColors()
    local yes = DarkRP.getPhrase("yes")
    local no = DarkRP.getPhrase("no")

    local ybutton = panel:Add("DButton")
    ybutton:SetSize(60, 20)
    ybutton:SetPos(panel:GetWide()*0.5 - ybutton:GetWide()-5, panel:GetTall() - ybutton:GetTall()-10)
    ybutton:SetText("")
    ybutton:SetVisible(true)
    ybutton.DoClick = function()
        if qtype == 1 then
            LocalPlayer():ConCommand("ans " .. voteid .. " 1\n")
        else
            LocalPlayer():ConCommand("vote " .. voteid .. " yea\n")
        end

        panel:Close()
    end
    function ybutton:Paint(w,h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0,0,0,w,h,hovered and clr2.button.apply_hover or clr2.button.apply)

        draw.SimpleText(yes,"es_ehud_16_500",w*0.5-1,h*0.5,clr2.default.black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    local nbutton = panel:Add("DButton")
    nbutton:SetSize(60, 20)
    nbutton:SetPos(panel:GetWide()*0.5 + 5, panel:GetTall() - nbutton:GetTall()-10)
    nbutton:SetText("")
    nbutton:SetVisible(true)
    nbutton.DoClick = function()
        if qtype == 1 then
            LocalPlayer():ConCommand("ans " .. voteid .. " 2\n")
        else
            LocalPlayer():ConCommand("vote " .. voteid .. " nay\n")
        end

        panel:Close()

    end

    function nbutton:Paint(w,h)
        local hovered = self:IsHovered()
        draw.RoundedBox(0,0,0,w,h,hovered and clr2.button.discard_hover or clr2.button.discard)

        draw.SimpleText(no,"es_ehud_16_500",w*0.5-1,h*0.5,clr2.default.black,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    surface.PlaySound("ambient/water/rain_drip1.wav")
    invalidateLayout()

end


usermessage.Hook("DoVote", function(msg) MsgDoQuestion(msg,0) end)
usermessage.Hook("DoQuestion", function(msg) MsgDoQuestion(msg,1) end)


local function KillQuestionVGUI(msg)
    local id = msg:ReadString()

    for k,v in ipairs(ehud.votes) do
        if not v then continue end
        if not v.question then continue end

        if v.id == id then
            v:Close()
        end
    end
end
usermessage.Hook("KillQuestionVGUI", KillQuestionVGUI)


-- concommand.Add("ehud_VoteTest",function()
--     timer.Simple(0.2,function()
--         MsgDoQuestion(nil,0)
--     end)
--     timer.Simple(0.4,function()
--         MsgDoQuestion(nil,0)
--     end)
--     timer.Simple(1,function()
--         MsgDoQuestion(nil,0)
--     end)
-- end)