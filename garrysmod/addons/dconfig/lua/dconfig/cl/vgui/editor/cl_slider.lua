
local PANEL = {}

function PANEL:Init()
	self:SetText("")

end

function PANEL:GetValue()
	return self.enabled
end

function PANEL:DoClick()
	self:SetValue(!self.enabled)
	DCONFIG2.PlaySound("checkbox")
end






derma.DefineControl("DCONFIG2Slider", "DCONFIG2 Slider", PANEL, "DNumSlider")

