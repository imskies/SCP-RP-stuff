
local PANEL = {}

function PANEL:Init()

end

function PANEL:OnSizeChanged(w,h)

end

function PANEL:OpenMenu( pControlOpener )

	if ( pControlOpener && pControlOpener == self.TextEntry ) then
		return
	end

	-- Don't do anything if there aren't any options..
	if ( #self.Choices == 0 ) then return end

	-- If the menu still exists and hasn't been deleted
	-- then just close it and don't open a new one.
	if ( IsValid( self.Menu ) ) then
		self.Menu:Remove()
		self.Menu = nil
	end

    self.Menu = vgui.Create( "DMenu", self )
    local theme = DCONFIG2.GetTheme()
    self.Menu.Paint = function(me,w,h)
        draw.RoundedBox(6, 0, 0, w, h, theme.panel)
    end

    self.Menu.AddOption = function(me, strText, funcFunction)
        local pnl = vgui.Create( "DMenuOption", me )
        pnl:SetMenu( me )
        pnl:SetText( strText )
        pnl:SetTextColor(color_white)
        pnl:SetFont(DCONFIG2.Font(16))
        pnl:SetTextInset(10, 0)
        pnl:SetTall(100)
        pnl:InvalidateLayout(true)
        pnl.Paint = function(me,w,h)
            if me:IsHovered() then
                draw.RoundedBox(6, 0, 0, w, h, theme.hoverHighlight)
            end 
        end
        if ( funcFunction ) then pnl.DoClick = funcFunction end
    
        me:AddPanel( pnl )
    
        return pnl
    end

	if ( self:GetSortItems() ) then
		local sorted = {}
		for k, v in pairs( self.Choices ) do
			local val = tostring( v ) --tonumber( v ) || v -- This would make nicer number sorting, but SortedPairsByMemberValue doesn't seem to like number-string mixing
			if ( string.len( val ) > 1 && !tonumber( val ) && val:StartWith( "#" ) ) then val = language.GetPhrase( val:sub( 2 ) ) end
			table.insert( sorted, { id = k, data = v, label = val } )
		end
		for k, v in SortedPairsByMemberValue( sorted, "label" ) do
			local option = self.Menu:AddOption( v.data, function() self:ChooseOption( v.data, v.id ) end )
			if ( self.ChoiceIcons[ v.id ] ) then
				option:SetIcon( self.ChoiceIcons[ v.id ] )
			end
		end
	else
		for k, v in pairs( self.Choices ) do
			local option = self.Menu:AddOption( v, function() self:ChooseOption( v, k ) end )
			if ( self.ChoiceIcons[ k ] ) then
				option:SetIcon( self.ChoiceIcons[ k ] )
			end
		end
	end

	local x, y = self:LocalToScreen( 0, self:GetTall() )

	self.Menu:SetMinimumWidth( self:GetWide() )
	self.Menu:Open( x, y, false, self )

end

function PANEL:Paint(w,h)
    local theme = DCONFIG2.GetTheme()
    draw.RoundedBox(6, 0, 0, w, h, theme.panel)

end

derma.DefineControl("DCONFIG2DComboBox", "DCONFIG2 DComboBox", PANEL, "DComboBox")

