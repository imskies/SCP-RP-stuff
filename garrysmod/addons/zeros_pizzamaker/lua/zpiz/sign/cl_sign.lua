/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

if SERVER then return end
zpiz = zpiz or {}
zpiz.Sign = zpiz.Sign or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ee71cdadb4c1697a1f320cfc75c78c5f0135879a492afb53058e82fcefbc72f0
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3a7bd44c53efd46df183636fbe76c3de2bd5fbbd78a3773db33588e14b60a4d

function zpiz.Sign.Draw(Sign)
	if zclib.util.InDistance(LocalPlayer():GetPos(), Sign:GetPos(), 500) then
		zpiz.Sign.DrawMainInfo(Sign)
	end
end

function zpiz.Sign.DrawMainInfo(Sign)
	local status
	local sState = Sign:GetSignState()

	if (sState) then
		status = zpiz.language.OpenSign_open
	else
		status = zpiz.language.OpenSign_closed
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 17dc2f80cf0594471955ed2fce132d0271ce6541c38902a33a4148308c414a4d

	cam.Start3D2D(Sign:GetPos(), zclib.HUD.GetLookAngles(), 0.1)
		surface.SetDrawColor(0, 0, 0, 100)
		surface.SetMaterial(zpiz.materials["zpiz_button"])
		surface.DrawTexturedRect(-250, -360, 500, 80)

		if (sState) then
			surface.SetDrawColor(0, 0, 0, 100)
			surface.SetMaterial(zpiz.materials["zpiz_button"])
			surface.DrawTexturedRect(-150, -280, 300, 80)
			draw.DrawText(zpiz.language.OpenSign_Revenue .. zclib.Money.Display(Sign:GetSessionEarnings()), zclib.GetFont("zpiz_vgui_font03"), 0, -250, color_white, TEXT_ALIGN_CENTER)
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350945

		draw.DrawText(status, zclib.GetFont("zpiz_plate_font02"), 0, -350, color_white, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
