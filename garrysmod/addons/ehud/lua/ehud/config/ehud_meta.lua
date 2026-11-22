ehud.addon = esclib:Addon("ehud")
ehud.addon:SetName("ehud")
ehud.addon:SetBranch("release")
ehud.addon:SetVersion("1.62")
ehud.addon:SetDescription("HUD solution")
ehud.addon:SetColor(Color(13,255,73))

if CLIENT then
	ehud.addon:SetThumbnail(ehud.Materials["ehud_icon.png"])
end