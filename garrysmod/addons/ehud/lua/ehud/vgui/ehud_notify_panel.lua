local NoticeMaterial = {}

NoticeMaterial[ NOTIFY_GENERIC ]	= { ehud.Materials["notify_generic.png"], true }
NoticeMaterial[ NOTIFY_ERROR ]		= { ehud.Materials["notify_error.png"], true }
NoticeMaterial[ NOTIFY_UNDO ]		= { ehud.Materials["notify_undo.png"], false }
NoticeMaterial[ NOTIFY_HINT ]		= { ehud.Materials["notify_hint.png"], false }
NoticeMaterial[ NOTIFY_CLEANUP ]	= { ehud.Materials["notify_cleanup.png"], true }

local PANEL = {}

function PANEL:Init()
	self.legacy_type = 0

	self.clr = ehud.addon:GetColors()

	self.type_clr = {}
	self.type_clr[ NOTIFY_GENERIC ] = self.clr.notify.generic
	self.type_clr[ NOTIFY_ERROR ] = self.clr.notify.error
	self.type_clr[ NOTIFY_UNDO ] = self.clr.notify.undo
	self.type_clr[ NOTIFY_HINT ] = self.clr.notify.hint
	self.type_clr[ NOTIFY_CLEANUP ] = self.clr.notify.cleanup

	-- self:DockPadding( 3, 1, 3, 3 )

	self.Label = vgui.Create( "DLabel", self )
	self.Label:SetX(5)
	self.Label:CenterVertical()
	-- self.Label:Dock( FILL )
	self.Label:SetFont( "es_ehud_n_18_500" )
	self.Label:SetTextColor( color_white )
	self.Label:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )
	-- self.Label:SetContentAlignment( 5 )

	self.mask_poly = nil

end

function PANEL:SetText( txt )

	self.Label:SetText( txt )
	self:SizeToContents()

end

function PANEL:SizeToContents()

	self.Label:SetText(esclib.text:MultilineToString(esclib.text:Multiline(self.Label:GetText(),self.Label:GetFont(),esclib.scrw*0.3)))

	self.Label:SizeToContents()


	local tw, th = self.Label:GetSize()

	if ( IsValid( self.Image ) ) then
		local im_size = math.Clamp(th*0.45+20, 1, 20)
		self.Image:SetSize(im_size, im_size)
		self.Image:SetX(8)
		self.Label:SetPos(self.Image:GetX()+self.Image:GetWide()+10)

		self:SetSize( self.Label:GetX()+tw+15, th+18 )
		self.Image:SetY(self:GetTall()*0.5-self.Image:GetTall()*0.5-1)
		self.Label:SetY(self:GetTall()*0.5-self.Label:GetTall()*0.5-1)
	end

	if ( self.Progress ) then
		--tall = tall + 10

		self:SetSize(tw+20,th+20)
		-- self.Label:DockMargin( 0, 0, 0, 10 )
	end

	self:InvalidateLayout()

end

function PANEL:SetLegacyType( t )

	local t = math.Clamp(t, 0, 4)

	self.legacy_type = t;

	self.Image = vgui.Create( "DImageButton", self )
	self.Image:SetMaterial( NoticeMaterial[ t ][1] )
	if not NoticeMaterial[t][2] then
		self.Image:SetColor( self.type_clr[t] )
	end
	self.Image:SetSize( 26, 26 )
	-- self.Image:Dock( LEFT )
	-- self.Image:DockMargin( 0, 0, 8, 0 )
	self.Image.DoClick = function()
		self.StartTime = 0
	end

	self:SizeToContents()

end

function PANEL:Paint( w, h )

	local shouldDraw = not ( LocalPlayer && IsValid( LocalPlayer() ) && IsValid( LocalPlayer():GetActiveWeapon() ) && LocalPlayer():GetActiveWeapon():GetClass() == "gmod_camera" )

	if ( IsValid( self.Label ) ) then self.Label:SetVisible( shouldDraw ) end
	if ( IsValid( self.Image ) ) then self.Image:SetVisible( shouldDraw ) end

	-- ehud:PaintBlur(self,0,0,w,h)

	if ( not shouldDraw ) then return end

	local ratio = (SysTime() - self.StartTime) / self.Length + 0.1
	local legacy_color = self.type_clr[self.legacy_type]

	esclib.draw:Mask(function()
		if not self.mask_poly then
			self.mask_poly = esclib.util:PrecacheRoundedPoly(0, 0, w, h, 8, 4)
		end
		draw.NoTexture();
		surface.SetDrawColor( color_white )
		surface.DrawPoly( self.mask_poly )
	end, 
	function()
		surface.SetDrawColor(legacy_color.r,legacy_color.g,legacy_color.b,legacy_color.a)
		surface.SetMaterial(ehud.Materials["gradient"])
		surface.DrawTexturedRectRotated( (w-w*ratio)*0.5,h*0.5,h,w*(1-ratio),90)

		draw.RoundedBox(0,0,0,w,h,self.clr.main.bg)
		draw.RoundedBox(0,0,h-2,(w)*(1-ratio),2,legacy_color)
	end,false)

	-- surface.SetDrawColor(legacy_color.r,legacy_color.g,legacy_color.b,legacy_color.a)
    -- surface.SetMaterial(ehud.Materials["gradient"])
    -- surface.DrawTexturedRectRotated( (w-w*ratio)*0.5,h*0.5,h,w*(1-ratio),90)

	-- draw.RoundedBox(0,0,0,w,h,self.clr.main.bg)
	-- draw.RoundedBox(0,0,h-2,(w)*(1-ratio),2,legacy_color)

	if ( not self.Progress ) then return end

	local boxX, boxY = 10, self:GetTall() - 13
	local boxW, boxH = self:GetWide() - 20, 5
	local boxInnerW = boxW - 2

	surface.SetDrawColor( 13, 13, 13, 200 )
	surface.DrawRect( boxX, boxY, boxW, boxH )

	local w = math.ceil( boxInnerW * 0.25 )
	local x = math.fmod( math.floor( SysTime() * 200 ), boxInnerW + w ) - w

	if ( self.ProgressFrac ) then
		x = 0
		w = math.ceil( boxInnerW * self.ProgressFrac )
	end

	if ( x + w > boxInnerW ) then w = math.ceil( boxInnerW - x ) end
	if ( x < 0 ) then
		w = w + x
		x = 0
	end

	surface.SetDrawColor( 255, 0, 0, 255 )
	surface.DrawRect( boxX + x, boxY, w, boxH )

end

function PANEL:SetProgress( frac )

	self.Progress = true
	self.ProgressFrac = frac

	self:SizeToContents()

end

function PANEL:KillSelf()

	-- Infinite length
	if ( self.Length < 0 ) then return false end

	if ( self.StartTime + self.Length < SysTime() ) then

		self:Remove()
		return true

	end

	return false

end

vgui.Register( "ehud.notice_panel", PANEL, "DPanel" )