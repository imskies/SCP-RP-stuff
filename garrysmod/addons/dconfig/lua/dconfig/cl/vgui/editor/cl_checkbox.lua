
local PANEL = {}

function PANEL:Init()
	self:SetText("")
	self.slidePos = 0
    self.showLabel = true
end

function PANEL:SetValue(enabled)
	if self.enabled != enabled then
		self.sliding = true
	end
	if enabled then
		self.slideDirection = 1
	else
		self.slideDirection = -1
	end
	self.enabled = enabled
end

function PANEL:GetValue()
	return self.enabled
end

function PANEL:DoClick()
	self:SetValue(!self.enabled)
	DCONFIG2.PlaySound("checkbox")
end

function PANEL:SetDisabledColor(color)
    self.disabledColor = color 
end 

function PANEL:ShowLabel(shouldShow)
    self.showLabel = shouldShow
end 

local circle = Material("dconfig/circle.png")
function PANEL:Paint(w,h)
	local theme = DCONFIG2.GetTheme()
	self.barW = self.barW or 0
	draw.RoundedBox(8, 0, h * .2, w, h * .6, self.disabledColor or theme.panel)
	if self.barW >= h then
		draw.RoundedBox(8, 0, h * .2, self.barW, h * .6, theme.sliderfill or theme.theme)
    end
    if self.showLabel then 
        if self.enabled then 
            draw.SimpleText("ON", DCONFIG2.Font(12), w * .1, h * .5, theme.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("OFF", DCONFIG2.Font(12), w * .9, h * .5, theme.titletext, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end
    if not self.circleData then return end


    --local targetPos = self.slideDirection > 0 and w - h or 0
    self:MoveCircle(self.slidePos)
    surface.SetDrawColor(color_white)
    draw.NoTexture()
    surface.DrawPoly( self.circleData.poly )
end

function PANEL:Think()
    if self.sliding and self.slideDirection then
        local w, h = self:GetWide(), self:GetTall()
        local speed = w * 3
        self.slidePos = math.Clamp(self.slidePos + (speed * FrameTime()) * self.slideDirection, 0, w - h)
        self.barW = self.slidePos + h - 2
    end
end

local seg = 100

function PANEL:MoveCircle(x)
    if not self.circleData then return end

    if self.circleData.targetX and self.circleData.targetX == x then return end

    self.circleData.targetX = x

    for k,v in ipairs(self.circleData.poly) do
        v.startX = v.startX or v.x
        v.x = v.startX + x
    end 
end

function PANEL:CreateCircle(x, y, radius)
    self.circleData = {}
    self.circleData.poly = {}
    self.circleData.radius = radius
    table.insert( self.circleData.poly, { x = x, y = y, u = 0.5, v = 0.5 } )
    for i = 0, seg do
        local a = math.rad( ( i / seg ) * -360 )
        local startX = x + math.sin( a ) * self.circleData.radius
        table.insert( self.circleData.poly, { x = startX, startX = startX, y = y + math.cos( a ) * self.circleData.radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    end
    local a = math.rad( 0 ) -- This is needed for non absolute segment counts
    local startX = x + math.sin( a ) * self.circleData.radius
    table.insert( self.circleData.poly, { x = startX, startX = startX, y = y + math.cos( a ) * self.circleData.radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
end

function PANEL:OnSizeChanged(w,h)
    local radius = h * .5
    self:CreateCircle(radius, h * .5, radius)
end

derma.DefineControl("DCONFIG2Checkbox", "DCONFIG2 Checkbox", PANEL, "DButton")

