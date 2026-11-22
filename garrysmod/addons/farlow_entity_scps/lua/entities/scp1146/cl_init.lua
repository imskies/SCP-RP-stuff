include("shared.lua")

-- Client-side insults (chat only, per-player)
net.Receive("scp1146_Insult", function()
    local ent = net.ReadEntity()
    local msg = net.ReadString()
    if not IsValid(ent) then return end

    chat.AddText(Color(180, 80, 80), "[SCP-1146] ", Color(255, 255, 255), msg)
end)

-- Client-side print complaints + cooldown messages
net.Receive("scp1146_PrintMsg", function()
    local ent = net.ReadEntity()
    local msg = net.ReadString()
    if not IsValid(ent) then return end

    chat.AddText(Color(180, 80, 80), "[SCP-1146] ", Color(255, 255, 255), msg)
end)

-- Simple interaction prompt
hook.Add("HUDPaint", "scp1146_prompt", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local tr = ply:GetEyeTrace()
    local ent = tr and tr.Entity
    if not IsValid(ent) or ent:GetClass() ~= "scp_1146" then return end
    if tr.HitPos:DistToSqr(ply:GetShootPos()) > (150 * 150) then return end

    local txt = "Press E to request a print from SCP-1146"
    surface.SetFont("Trebuchet24")
    local tw, th = surface.GetTextSize(txt)
    surface.SetTextColor(255, 255, 255, 220)
    surface.SetTextPos(ScrW() * 0.5 - tw * 0.5, ScrH() * 0.85)
    surface.DrawText(txt)
end)