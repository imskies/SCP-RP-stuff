DeepSquads.MySquad = DeepSquads.MySquad or {members = {}}
require("outline")

-- Faster for certain surface functions
local DefaultColorR,DefaultColorG,DefaultColorB,DefaultColorA = DeepSquads.Config.DefaultColor:Unpack()
local MenuBGR,MenuBGG,MenuBGB,MenuBGA = DeepSquads.Config.MenuBG:Unpack()
local MenuBGLightR,MenuBGLightG,MenuBGLightB,MenuBGLightA = DeepSquads.Config.MenuBGLight:Unpack()
local MenuBGLighterR,MenuBGLighterG,MenuBGLighterB,MenuBGLighterA = DeepSquads.Config.MenuBGLighter:Unpack()
local MenuBGLighterAltR,MenuBGLighterAltG,MenuBGLighterAltB,MenuBGLighterAltA = DeepSquads.Config.MenuBGLighterAlt:Unpack()
local LeaderColorR,LeaderColorG,LeaderColorB,LeaderColorA = DeepSquads.Config.LeaderColor:Unpack()

surface.CreateFont("DeepSquads:Header", {
    font = "Courier New",
    extended = false,
    weight = 600,
    size = 30
})

surface.CreateFont("DeepSquads:Medium", {
    font = "Courier New",
    extended = false,
    weight = 300,
    size = 18
})

surface.CreateFont("DeepSquads:Small", {
    font = "Consolas",
    extended = false,
    weight = 300,
    size = 15
})

local getAvatarMaterial = include("deepsquads/material-avatar.lua")

local function drawCircle( x, y, radius, seg )
    local cir = {}

    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
    for i = 0, seg do
        local a = math.rad( ( i / seg ) * -360 )
        table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    end

    local a = math.rad( 0 ) -- This is needed for non absolute segment counts
    table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

    surface.DrawPoly( cir )
end

local function OutlineText(text, x, y, color)
    local col = color or color_white
    surface.SetTextColor(0,0,0)
    surface.SetTextPos(x - 1,y - 1)
    surface.DrawText(text)
    surface.SetTextPos(x + 1,y - 1)
    surface.DrawText(text)
    surface.SetTextPos(x + 1,y + 1)
    surface.DrawText(text)
    surface.SetTextPos(x - 1,y + 1)
    surface.DrawText(text)
    surface.SetTextPos(x,y)
    surface.SetTextColor(col)
    surface.DrawText(text)
end

DeepSquads.OpenMenu = function()
    local OpenTime = CurTime()
    local HasSquad = table.Count(DeepSquads.MySquad.members) > 0

    local Top = vgui.Create("DFrame")
    Top:ShowCloseButton(false)
    Top:SetSize(800,600)
    Top:Center()
    Top:SetY(ScrH())
    Top:SetTitle("")
    Top:MakePopup()
    Top.Think = function(self)
        self:SetY(Lerp((CurTime() - OpenTime) * 5, ScrH(), ScrH() / 2 - 300))
        if self:GetY() <= ScrH() / 2-300 then
            Top.Think = function() end
        end
    end
    Top.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, DeepSquads.Config.MenuBGDark)
        draw.RoundedBoxEx(8, 0, 0, w, 30, DeepSquads.Config.MenuBGLight, true, true)
        surface.SetDrawColor(MenuBGLighterR,MenuBGLighterG,MenuBGLighterB,MenuBGLighterA)
        surface.DrawRect(0, 30, w, 135)
        if HasSquad then
            surface.SetDrawColor(MenuBGLighterAltR,MenuBGLighterAltG,MenuBGLighterAltB,MenuBGLighterAltA)
            surface.DrawRect(0, 62, w, 17)
            surface.DrawRect(0, 96, w, 17)
            surface.DrawRect(0, 130, w, 17)
            surface.SetFont("DeepSquads:Header")
            OutlineText(DeepSquads.MySquad.name, 5, 30)
            surface.SetFont("DeepSquads:Medium")
            local side_x = 0
            local iterations_y = 0
            for sid,plyinfo in pairs(DeepSquads.MySquad.members) do
                if sid == DeepSquads.MySquad.sid then
                    OutlineText(plyinfo.name .. " (LEAD)", 5 + (side_x * 400), 60 + (iterations_y * 17), DeepSquads.Config.LeaderColor)
                else
                    OutlineText(plyinfo.name, 5 + (side_x * 400), 60 + (iterations_y * 17))
                end
                iterations_y = iterations_y + 1
                if iterations_y >= 6 then
                    side_x = 1
                    iterations_y = 0
                end
            end
        else
            surface.SetFont("DeepSquads:Header")
            OutlineText("Create Squad", 298, 30)
            surface.SetFont("DeepSquads:Medium")
            OutlineText("Name: ", 224, 60)
            OutlineText("Division: ", 322, 82)
        end
    end

    local CloseButton = Top:Add("DButton")
    CloseButton:SetPos(775, 5)
    CloseButton:SetSize(20,20)
    CloseButton:SetText("")
    CloseButton.DoClick = function(self)
        Top:Close()
    end
    CloseButton.Paint = function(self, w, h)
        draw.NoTexture()
        surface.SetDrawColor(255,0,0)
        drawCircle(w / 2, h / 2, w / 2, 12)
    end

    net.Start("DeepSquads:RequestMasterList")
    net.SendToServer()

    local SquadMenu = Top:Add("DScrollPanel")
    SquadMenu:SetPos(0, 165)
    SquadMenu:SetSize(800, 435)
    local sbar = SquadMenu:GetVBar()
    sbar:SetWide(6)
    function sbar:Paint(w, h)
        surface.SetDrawColor(MenuBGR,MenuBGG,MenuBGB,MenuBGA)
        surface.DrawRect(0,0,w,h)
    end
    function sbar.btnUp:Paint(w, h)
        surface.SetDrawColor(DefaultColorR,DefaultColorG,DefaultColorB,DefaultColorA)
        surface.DrawRect(0,0,w,h)
    end
    function sbar.btnDown:Paint(w, h)
        surface.SetDrawColor(DefaultColorR,DefaultColorG,DefaultColorB,DefaultColorA)
        surface.DrawRect(0,0,w,h)
    end
    function sbar.btnGrip:Paint(w, h)
        surface.SetDrawColor(DefaultColorR,DefaultColorG,DefaultColorB,DefaultColorA)
        surface.DrawRect(0,0,w,h)
    end

    local iteration = 0
    net.Receive("DeepSquads:SendSquad", function()
        if not Top or not IsValid(Top) then return end
        local squad_name = net.ReadString()
        local squad_tag = net.ReadString()
        local squad_sid = net.ReadString()
        local member_count = net.ReadUInt(8)
        local members = {}
        for i = 1, member_count do
            local sid = net.ReadString()
            local name = net.ReadString()
            members[sid] = name
        end
        for k,v in ipairs(Top:GetChildren()) do
            if v:GetName() == squad_sid then return end -- No duplicate squad entries
        end
        local SquadFrame = SquadMenu:Add("DPanel")
        SquadFrame:SetName(squad_sid)
        SquadFrame:SetPos(5 + (397.5 * math.fmod(iteration, 2)), 5 + (205 * math.floor(iteration / 2)))
        SquadFrame:SetSize(392.5, 156)
        SquadFrame.Paint = function(self, w, h)
            draw.RoundedBox(5, 0, 0, w, h, DeepSquads.Config.MenuBGDark)
            draw.RoundedBox(5, 0, 0, w, 40, DeepSquads.Config.MenuBGDark)
            surface.SetFont("DeepSquads:Medium")
            OutlineText(squad_name, 5, 5)
            surface.SetFont("DeepSquads:Small")
            OutlineText(squad_tag, 5, 20)
        end
        if LocalPlayer():IsAdmin() then
            local KSConfirm = false
            local KillSwitch = SquadFrame:Add("DButton")
            KillSwitch:SetText("")
            KillSwitch:SetSize(47, 15)
            KillSwitch:SetPos(336, 4)
            KillSwitch.Paint = function(self, w, h)
                surface.SetDrawColor(140,65,65)
                surface.DrawRect(0,0,w,h)
                surface.SetFont("DeepSquads:Small")
                OutlineText(KSConfirm and "CONFIRM?" or "DELETE", 2, 0, self:IsHovered() and DeepSquads.Failure)
            end
            KillSwitch.DoClick = function(self)
                if not KSConfirm then
                    KSConfirm = true
                    KillSwitch:SetWide(61, 15)
                    KillSwitch:SetPos(322, 4)
                else
                    net.Start("DeepSquads:DeleteSquad")
                    net.WriteString(squad_sid)
                    net.SendToServer()
                    Top:Close()
                end
            end
        end
        local JoinButton = SquadFrame:Add("DButton")
        JoinButton:SetText("")
        JoinButton:SetSize(33, 15)
        JoinButton:SetPos(350, 21)
        JoinButton.Paint = function(self, w, h)
            surface.SetDrawColor(DefaultColorR,DefaultColorG,DefaultColorB,DefaultColorA)
            surface.DrawRect(0,0,w,h)
            surface.SetFont("DeepSquads:Small")
            OutlineText("Join", 2, 0, self:IsHovered() and DeepSquads.Config.LeaderColor)
        end
        JoinButton.DoClick = function(self)
            net.Start("DeepSquads:JoinSquad")
            net.WriteString(squad_sid)
            net.SendToServer()
            Top:Close()
        end
        local avy_iteration = 0
        for sid,name in pairs(members) do
            local avatar = SquadFrame:Add("AvatarMaterial")
            avatar:SetSize(16, 16)
            avatar:SetPos(5 + (198.75 * math.floor(avy_iteration / 6)), 45 + (18 * math.fmod(avy_iteration, 6)))
            avatar:SetSteamID64(util.SteamIDTo64(sid))
            local avname = SquadFrame:Add("DLabel")
            avname:SetPos(23 + (198.75 * math.floor(avy_iteration / 6)), 43 + (18 * math.fmod(avy_iteration, 6)))
            avname:SetWide(190)
            avname:SetTextColor(sid == squad_sid and DeepSquads.Config.LeaderColor or color_white)
            avname:SetFont("DeepSquads:Small")
            avname:SetText(name)
            avy_iteration = avy_iteration + 1
        end
        iteration = iteration + 1
    end)

    if HasSquad then
        local LeaveButton = Top:Add("DButton")
        LeaveButton:SetText("")
        LeaveButton:SetPos(755,36)
        LeaveButton:SetSize(40,18)
        LeaveButton.DoClick = function(self)
            net.Start("DeepSquads:LeaveSquad")
            net.SendToServer()
            Top:Close()
        end
        LeaveButton.Paint = function(self, w, h)
            draw.NoTexture()
            surface.SetDrawColor(MenuBGLightR,MenuBGLightG,MenuBGLightB,MenuBGLightA)
            surface.DrawRect(0,0,w,h)
            surface.SetFont("DeepSquads:Small")
            OutlineText("LEAVE", 2, 1, self:IsHovered() and DeepSquads.Failure)
        end
        if LocalPlayer():SteamID() == DeepSquads.MySquad.sid then
            local NameChange = Top:Add("DButton")
            NameChange:SetText("")
            NameChange:SetPos(625,36)
            NameChange:SetSize(125,18)
            local prompt
            NameChange.DoClick = function(self)
                if prompt and IsValid(prompt) then
                    prompt:MakePopup()
                    return
                end
                prompt = vgui.Create("DFrame")
                prompt:SetTitle("Change Squad Name")
                prompt:SetSize(300,100)
                prompt:Center()
                prompt:MakePopup()
                local NameChangeEntry = prompt:Add("DTextEntry")
                NameChangeEntry:SetWide(250)
                NameChangeEntry:Center()
                NameChangeEntry.AllowInput = function(me, char)
                    return string.len(me:GetValue()) > 36 -- Max 36 characters for squad name
                end
                local NameChangeButton = prompt:Add("DButton")
                NameChangeButton:SetY(75)
                NameChangeButton:CenterHorizontal()
                NameChangeButton:SetText("Submit")
                NameChangeButton.DoClick = function()
                    net.Start("DeepSquads:ChangeSquadName")
                    net.WriteString(NameChangeEntry:GetValue())
                    net.SendToServer()
                    prompt:Close()
                    if Top and IsValid(Top) then
                        Top:Close()
                    end
                end
            end
            NameChange.Paint = function(self, w, h)
                draw.NoTexture()
                surface.SetDrawColor(MenuBGLightR,MenuBGLightG,MenuBGLightB,MenuBGLightA)
                surface.DrawRect(0,0,w,h)
                surface.SetFont("DeepSquads:Small")
                OutlineText("CHANGE SQUAD NAME", 2, 1, self:IsHovered() and DeepSquads.Config.LeaderColor)
            end
            local side_x = 0
            local iterations_y = 0
            for sid,plyinfo in pairs(DeepSquads.MySquad.members) do
                if sid ~= DeepSquads.MySquad.sid then
                    local PromoteButton = Top:Add("DButton")
                    PromoteButton:SetText("")
                    PromoteButton:SetPos(307 + (side_x * 400), 62 + (iterations_y * 17))
                    PromoteButton:SetSize(54, 17)
                    PromoteButton.DoClick = function(self)
                        net.Start("DeepSquads:MakeLeader")
                        net.WriteString(sid)
                        net.SendToServer()
                        Top:Close()
                    end
                    PromoteButton.Paint = function(self, w, h)
                        draw.NoTexture()
                        surface.SetDrawColor(MenuBGLightR,MenuBGLightG,MenuBGLightB,MenuBGLightA)
                        surface.DrawRect(0,0,w,h)
                        surface.SetFont("DeepSquads:Small")
                        OutlineText("PROMOTE", 2, 1, self:IsHovered() and DeepSquads.Config.LeaderColor)
                    end
                    local KickButton = Top:Add("DButton")
                    KickButton:SetText("")
                    KickButton:SetPos(363 + (side_x * 400), 62 + (iterations_y * 17))
                    KickButton:SetSize(33, 17)
                    KickButton.DoClick = function(self)
                        net.Start("DeepSquads:KickPlayer")
                        net.WriteString(sid)
                        net.SendToServer()
                        Top:Close()
                    end
                    KickButton.Paint = function(self, w, h)
                        draw.NoTexture()
                        surface.SetDrawColor(MenuBGLightR,MenuBGLightG,MenuBGLightB,MenuBGLightA)
                        surface.DrawRect(0,0,w,h)
                        surface.SetFont("DeepSquads:Small")
                        OutlineText("KICK", 2, 1, self:IsHovered() and DeepSquads.Failure)
                    end
                end
                iterations_y = iterations_y + 1
                if iterations_y >= 6 then
                    side_x = 1
                    iterations_y = 0
                end
            end
        end
    else
        local NameEntry = Top:Add("DTextEntry")
        NameEntry:SetPos(276, 60)
        NameEntry:SetWide(300)
        NameEntry.AllowInput = function(self, char)
            return string.len(self:GetValue()) > 36 -- Max 36 characters for squad name
        end
        local DivisonEntry = Top:Add("DComboBox")
        DivisonEntry:SetPos(414, 80)
        if not DeepSquads.Config.JobTags[team.GetName(LocalPlayer():Team())] or #DeepSquads.Config.JobTags[team.GetName(LocalPlayer():Team())] == 0 or (#DeepSquads.Config.JobTags[team.GetName(LocalPlayer():Team())] == 1 and DeepSquads.Config.JobTags[team.GetName(LocalPlayer():Team())][1] == "Spy") then
            DivisonEntry:SetValue("Unavailable")
        else
            local first = true
            for k,v in ipairs(DeepSquads.Config.JobTags[team.GetName(LocalPlayer():Team())]) do
                if v == "Spy" then continue end
                if first then
                    DivisonEntry:SetValue(v)
                    first = false
                end
                DivisonEntry:AddChoice(v)
            end
        end
        local CreateSquad = Top:Add("DButton")
        CreateSquad:SetText("")
        CreateSquad:SetPos(340, 110)
        CreateSquad:SetSize(120, 40)
        CreateSquad.DoClick = function(self)
            net.Start("DeepSquads:MakeSquad")
            net.WriteString(NameEntry:GetValue())
            net.WriteString(DivisonEntry:GetValue())
            net.SendToServer()
            Top:Close()
        end
        CreateSquad.Paint = function(self, w, h)
            draw.NoTexture()
            surface.SetDrawColor(MenuBGLighterAltR,MenuBGLighterAltG,MenuBGLighterAltB,MenuBGLighterAltA)
            surface.DrawRect(0,0,w,h)
            surface.SetFont("DeepSquads:Header")
            OutlineText("Submit", 8, 5, self:IsHovered() and DeepSquads.Config.LeaderColor)
        end
    end

end

DeepSquads.StatusText = function(message, color)
    local col = color or color_white
    chat.AddText(color_white, "[", DeepSquads.Config.DefaultColor, "DeepSquads", color_white, "] ", col, message)
end

DeepSquads.SquadText = function(message, color)
    local col = color or color_white
    chat.AddText(color_white, "[", DeepSquads.Config.SquadChatColor, "SQUAD", color_white, "] ", col, message)
end

surface.CreateFont("DeepSquads:Lead", {
    font = "Consolas",
    extended = false,
    weight = 100,
    size = 13
})

local queued_squares = {}
local queued_leader_squares = {}
hook.Add( "PostDrawEffects", "DeepSquads:Outline", function() -- Called before HUDPaint
    local targets = {}
    local leader = {}
    for sid,plyinfo in pairs(DeepSquads.MySquad.members) do
        if plyinfo.plyref and plyinfo.plyref ~= LocalPlayer() and IsValid(plyinfo.plyref) and IsEntity(plyinfo.plyref) and plyinfo.plyref:IsPlayer() then
            if plyinfo.plyref:IsDormant() and plyinfo.vec then
                if sid == DeepSquads.MySquad.sid then
                    table.insert(queued_leader_squares, plyinfo.vec:ToScreen())
                else
                    table.insert(queued_squares, plyinfo.vec:ToScreen())
                end
            else
                if sid == DeepSquads.MySquad.sid then
                    table.insert(leader, plyinfo.plyref)
                else
                    table.insert(targets, plyinfo.plyref)
                end
            end
        end
    end
    -- Don't render outlines when using a INS2 scope
    if LocalPlayer():KeyDown(IN_ATTACK2) and LocalPlayer() and LocalPlayer():GetActiveWeapon() and LocalPlayer():GetActiveWeapon().AttachmentTableCache and LocalPlayer():GetActiveWeapon().AttachmentTableCache.INS2_SightSuffix then
        return
    end
    outline.Add(targets, DeepSquads.Config.DefaultColor)
    outline.Add(leader, DeepSquads.Config.LeaderColor)
end )

local avatars = {}
hook.Add("HUDPaint", "DeepSquads:HUD", function()
    if not DeepSquads.MySquad then return end
    if not DeepSquads.MySquad.members then return end
    if table.IsEmpty(DeepSquads.MySquad.members) then return end
    -- Outside PVS, outline will not show accurate location, so we show a square at their real position
    surface.SetDrawColor(DefaultColorR,DefaultColorG,DefaultColorB,DefaultColorA)
    for k,v in ipairs(queued_squares) do
        if not v.visible then continue end
        surface.DrawRect(v.x - 5, v.y - 5, 10, 10)
    end
    queued_squares = {}
    surface.SetDrawColor(LeaderColorR,LeaderColorG,LeaderColorB,LeaderColorA)
    for k,v in ipairs(queued_leader_squares) do
        if not v.visible then continue end
        surface.DrawRect(v.x - 5, v.y - 5, 10, 10)
    end
    queued_leader_squares = {}

    -- HEADER --
    surface.SetFont("DeepSquads:Header")
    OutlineText(DeepSquads.MySquad.name, 20, 100)

    local iteration = 0
    for sid,plyinfo in pairs(DeepSquads.MySquad.members) do
        if sid == DeepSquads.MySquad.sid then
            surface.SetFont("DeepSquads:Lead")
            OutlineText("LEADER", 20, 138 + (iteration * 50), DeepSquads.Config.LeaderColor)
        end
        if not avatars[sid] then
            avatars[sid] = Material("vgui/avatar_default")
            getAvatarMaterial(util.SteamIDTo64(sid), function(mat)
                avatars[sid] = mat
            end)
        end
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(avatars[sid])
        surface.DrawTexturedRect(20, 152 + (iteration * 50), 15, 15)
        surface.SetFont("DeepSquads:Medium")
        OutlineText(plyinfo.name, 38, 150 + (iteration * 50))
        surface.SetDrawColor(255,0,0)
        local maxhp = 100
        if plyinfo.plyref and IsValid(plyinfo.plyref) and IsEntity(plyinfo.plyref) and plyinfo.plyref:IsPlayer() then
            maxhp = plyinfo.plyref:GetMaxHealth()
        end
        surface.DrawRect(20, 170 + (iteration * 50), math.min(190, 190 * (plyinfo.hp / maxhp)), 16)
        surface.SetDrawColor(0,0,0)
        surface.DrawOutlinedRect(20, 170 + (iteration * 50), 190, 16, 2)
        surface.SetFont("DeepSquads:Small")
        OutlineText(plyinfo.hp, 23, 170 + (iteration * 50))
        iteration = iteration + 1
    end
end)

MsgC("[Deep Squads]", DeepSquads.Success, " Client functionality initialized.\n") -- EOF
