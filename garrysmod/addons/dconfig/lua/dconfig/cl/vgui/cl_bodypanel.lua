
function DCONFIG2.IsBodyAvailable()
	if not IsValid(DCONFIG2.ScreenPanel) or not IsValid(DCONFIG2.ScreenPanel.bodyPanel) then return false end

	return true
end

function DCONFIG2.GetBody()
	if DCONFIG2.IsBodyAvailable() then
		return DCONFIG2.ScreenPanel.bodyPanel
	end
end

function DCONFIG2.ClearBody()
	if not DCONFIG2.IsBodyAvailable() then return end

	for k,v in ipairs(DCONFIG2.ScreenPanel.bodyPanel:GetChildren()) do
		v:Remove()
	end
end

local PANEL = {}

function PANEL:Init() end

function PANEL:Paint(w,h)
	local theme = DCONFIG2.GetTheme()
	draw.RoundedBoxEx(20,0,0,w,h,theme.body,false,true,false,true)
end

derma.DefineControl("DCONFIG2Body", "DCONFIG2 Body", PANEL, "DPanel")
