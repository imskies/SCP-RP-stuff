/*
    Addon id: 2bab5356-b4ae-4c4d-acb8-e199f204bd54
    Version: v1.3.8 (stable)
*/

Kobralost = Kobralost or {}
Kobralost.NotifyTable = Kobralost.NotifyTable or {}

local CoolDownnNotify
function Realistic_Radio.Notify(msg, time)
    CoolDownnNotify = CoolDownnNotify or 0 
    if CoolDownnNotify > CurTime() then return end 
    CoolDownnNotify = CurTime() + 1
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 62b35ce3a02dafbf5bb97998ac5e1886a97ed5d0e48e20b97ca269692c124a07
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c750873a37e0a75f99a502a9e5939b02f1b88b5df95e9c2b5c42581a8e324e05
    
    if Realistic_Radio.UseCustomNotify then
        Kobralost.NotifyTable[#Kobralost.NotifyTable + 1] = {
            ["Message"] = msg,
            ["Time"] = CurTime() + time, 
            ["Color1"] = Realistic_Radio.Colors["black41200"], 
            ["Color2"] = Realistic_Radio.Colors["blue41200"], 
            ["Material"] = "rdo_materials/walkie_talkie_icon.png", 
            ["Font"] = "rdo_font_10",
        }
    else
        notification.AddLegacy(msg, 1, 5)
    end
end 

hook.Add("DrawOverlay", "RDO:DrawOverlayNotify", function()
    if Kobralost.NotifyTable && #Kobralost.NotifyTable > 0 then 
        for k,v in pairs(Kobralost.NotifyTable) do 
            if not isnumber(v.RLerp) then v.RLerp = -(ScrW()*0.25 + #v.Message*ScrW()*0.0057) end 
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 76561199123350968 */

            if v.Time > CurTime() then 
                v.RLerp = math.Round(Lerp(3*FrameTime(), v.RLerp, ScrW()*0.03))
            else 
                v.RLerp = math.Round(Lerp(3*FrameTime(), v.RLerp, -(ScrW()*0.25 + #v.Message*ScrW()*0.0057+ScrW()*0.032)))
                if v.RLerp < -(ScrW()*0.1 + #v.Message*ScrW()*0.0057+ScrW()*0.032) then Kobralost.NotifyTable[k] = nil Kobralost.NotifyTable = table.ClearKeys( Kobralost.NotifyTable ) end 
            end 
            
            draw.RoundedBox(4, v.RLerp, (ScrH()*0.055*k)-ScrH()*0.038, #v.Message*ScrW()*0.0055+ScrW()*0.032, ScrH()*0.043, v.Color1)
            draw.RoundedBox(4, v.RLerp, (ScrH()*0.055*k)-ScrH()*0.038, ScrH()*0.043, ScrH()*0.043, v.Color2)

            surface.SetDrawColor( Realistic_Radio.Colors["white240"] )
            surface.SetMaterial(Material(v.Material))
		    surface.DrawTexturedRect( v.RLerp + ScrW()*0.001, (ScrH()*0.055*k)-ScrH()*0.0365, ScrH()*0.04, ScrH()*0.04 )

            draw.SimpleText(v.Message, v.Font, v.RLerp+ScrW()*0.03, (ScrH()*0.055*k) + ScrH()*0.043/2-ScrH()*0.038, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end 
    end 
end ) 

net.Receive("Kobralost:Notifications", function()
    local TableNotify = net.ReadTable()
    Realistic_Radio.Notify(TableNotify["message"], TableNotify["time"])
end) 
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1d139e0850450ff0c55cc5ad19568a0794d4d3bdce3fa3d34f714425a4e44079

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 90c45c83c06fd45965c506b0a40f9bf317f89c91d0aae2aa014fd2a772e64796
