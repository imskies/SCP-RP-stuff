local max = math.max
local min = math.min
local floor = math.floor

local PANEL = {}

AccessorFunc(PANEL, "BorderLeft", "BorderLeft", FORCE_NUMBER)
AccessorFunc(PANEL, "BorderTop", "BorderTop", FORCE_NUMBER)
AccessorFunc(PANEL, "BorderRight", "BorderRight", FORCE_NUMBER)
AccessorFunc(PANEL, "BorderBottom", "BorderBottom", FORCE_NUMBER)

-- Initialize panel properties
function PANEL:Init()
    self.Horizontal = false
    self.VerticalSpacer = 0
    self.HorizontalSpacer = 0
    self.BorderLeft = 0
    self.BorderTop = 0
    self.BorderRight = 0
    self.BorderBottom = 0
    self.AutoStretchWidth = false
    self.AutoStretchHeight = false
    self.LastX = 0
    self.LastY = 0
    self.ChildPanels = {}
end
-- Set auto height stretching
function PANEL:SetStretchHeight(bStretch)
    self.AutoStretchHeight = bStretch
    return self
end

-- Set auto width stretching
function PANEL:SetStretchWidth(bStretch)
    self.AutoStretchWidth = bStretch
    return self
end

-- Set panel border
function PANEL:SetBorder(border)
    self.BorderLeft = border
    self.BorderTop = border
    self.BorderRight = border
    self.BorderBottom = border
    return self
end

function PANEL:SetPadding(pLeft, pTop, pRight, pBottom)
    self.BorderLeft = pLeft or 0
    self.BorderTop = pTop or 0
    self.BorderRight = pRight or 0
    self.BorderBottom = pBottom or 0
    return self
end

function PANEL:GetBorder()
    return self.BorderLeft
end

-- Set horizontal spacing between panels
function PANEL:SetSpaceX(x)
    self.HorizontalSpacer = x
    return self
end

function PANEL:GetSpaceX()
    return self.HorizontalSpacer
end

-- Set vertical spacing between panels
function PANEL:SetSpaceY(y)
    self.VerticalSpacer = y
    return self
end

function PANEL:GetSpaceY()
    return self.VerticalSpacer
end

-- Override Add method to track child panels and update size
function PANEL:Add(pnl)
    if not ispanel(pnl) then 
        pnl = vgui.Create(pnl, self) 
    end
    pnl:SetParent(self)
    table.insert(self.ChildPanels, pnl)
    
    -- Perform layout and update size immediately if auto stretching is enabled
    self:Layout()
    
    return pnl
end

function PANEL:OnLayout()
    --Override to do something when layout is done
end

-- Main layout function to arrange child panels
function PANEL:Layout()
    local x = self.BorderLeft
    local y = self.BorderTop
    local maxWidth = 0
    local maxHeight = 0
    local row_height = 0
    
    for k, pnl in pairs(self.ChildPanels) do
        if !IsValid(pnl) then continue end
        
        local pnlWidth, pnlHeight = pnl:GetSize()
        
        -- Check if we need to move to next row
        if x + pnlWidth + self.BorderRight > self:GetWide() and x > self.BorderLeft then
            x = self.BorderLeft
            y = y + row_height + self.VerticalSpacer
            row_height = 0
        end
        
        -- Position the panel
        pnl:SetPos(x, y)
        
        -- Update x position for next panel
        x = x + pnlWidth + self.HorizontalSpacer
        
        -- Update max width and row height
        maxWidth = max(maxWidth, x)
        row_height = max(row_height, pnlHeight)
        
        -- Update max height
        maxHeight = max(maxHeight, y + pnlHeight)
    end
    
    -- Calculate final dimensions considering borders
    self.LastX = maxWidth + self.BorderRight
    self.LastY = maxHeight + self.BorderBottom
    
    -- Auto stretch if enabled
    if self.AutoStretchWidth then
        self:SetWide(self.LastX)
    end
    
    if self.AutoStretchHeight then
        self:SetTall(self.LastY)
    end

    self:OnLayout()

    return maxWidth, maxHeight
end

-- Recalculate size only, without repositioning elements
function PANEL:CalculateSize()
    local x = self.BorderLeft
    local y = self.BorderTop
    local maxWidth = 0
    local maxHeight = 0
    local row_height = 0
    
    for k, pnl in pairs(self.ChildPanels) do
        if !IsValid(pnl) then continue end
        
        local pnlWidth, pnlHeight = pnl:GetSize()
        local pnlX, pnlY = pnl:GetPos()
        
        -- Update max width and height based on panel position and size
        maxWidth = max(maxWidth, pnlX + pnlWidth)
        maxHeight = max(maxHeight, pnlY + pnlHeight)
    end
    
    -- Calculate final dimensions considering borders
    self.LastX = maxWidth + self.BorderRight
    self.LastY = maxHeight + self.BorderBottom
    
    -- Auto stretch if enabled
    if self.AutoStretchWidth then
        self:SetWide(self.LastX)
    end
    
    if self.AutoStretchHeight then
        self:SetTall(self.LastY)
    end
end

-- Override PerformLayout to ensure layout is updated
function PANEL:PerformLayout(w, h)
    self:Layout()
end

-- Remove a child panel
function PANEL:RemoveItem(item)
    for k, v in pairs(self.ChildPanels) do
        if v == item then
            table.remove(self.ChildPanels, k)
            self:Layout()
            break
        end
    end
end

-- Clear all child panels
function PANEL:Clear()
    for k, v in pairs(self.ChildPanels) do
        if IsValid(v) then
            v:Remove()
        end
    end
    
    self.ChildPanels = {}
    self:Layout()
end

function PANEL:GetColumnSizeFor(cols)
    if not isnumber(cols) or cols < 1 then return 0 end
    
    local totalWidth = self:GetWide() - (self.BorderLeft + self.BorderRight)
    if totalWidth <= 0 then return 0 end
    
    local spacer = self.HorizontalSpacer or 0
    local columnWidth = (totalWidth - (spacer * (cols-1))) / cols
    
    return floor(columnWidth)
end

function PANEL:GetRowSizeFor(rows)
    if not isnumber(rows) or rows < 1 then return 0 end
    
    local totalHeight = self:GetTall() - (self.BorderTop + self.BorderBottom)
    if totalHeight <= 0 then return 0 end

    local spacer = self.VerticalSpacer or 0
    local rowHeight = (totalHeight - (spacer * (rows-1))) / rows
    
    return floor(rowHeight)
end

vgui.Register("esclib.iconlayout", PANEL, "DPanel")



-- if IsValid(frame) then
--     frame:Remove()
-- end 
-- frame = vgui.Create("DFrame")
-- frame:SetSize(600, 400)
-- frame:Center()
-- frame:SetTitle("better iconlayout")
-- frame:MakePopup()

-- -- Create scroll panel container
-- local scroll = vgui.Create("DScrollPanel", frame)
-- scroll:SetSize(600, 350)
-- scroll:SetPos(0, 40) -- Position below buttons

-- local layout = vgui.Create("esclib.iconlayout", scroll)
-- layout:SetSize(600, 0) -- Height will be auto-expanded
-- layout:SetSpacing(10, 10)
-- layout:SetBorder(10, 10, 10, 10)
-- layout:SetStretchHeight(true)

-- local addButton = vgui.Create("DButton", frame)
-- addButton:SetSize(100, 30)
-- addButton:SetPos(10, 10)
-- addButton:SetText("Добавить панель")
-- addButton.DoClick = function()
--     local panel = vgui.Create("DButton")
--     local w = math.random(50, 100)
--     local h = math.random(50, 100)
--     panel:SetSize(w, h)

--     function panel:DoClick()
--         self:SizeTo(self:GetWide()*2, self:GetTall()*2, 0.5)
--     end
    
--     local color = Color(math.random(100, 255), math.random(100, 255), math.random(100, 255))
--     panel.Paint = function(s, w, h)
--         surface.SetDrawColor(color)
--         surface.DrawRect(0, 0, w, h)
--     end
    
--     layout:Add(panel)
    
--     print("New size: " .. layout:GetWide() .. "x" .. layout:GetTall())
-- end

-- local clearButton = vgui.Create("DButton", frame)
-- clearButton:SetSize(100, 30)
-- clearButton:SetPos(120, 10)
-- clearButton:SetText("clear")
-- clearButton.DoClick = function()
--     layout:Clear()
-- end

-- local setColumnsButton = vgui.Create("DButton", frame)
-- setColumnsButton:SetSize(100, 30)
-- setColumnsButton:SetPos(230, 10)
-- setColumnsButton:SetText("3 columns")
-- setColumnsButton.DoClick = function()
--     layout:SetColumnCount(3)
--     layout:InvalidateLayout(true)
-- end