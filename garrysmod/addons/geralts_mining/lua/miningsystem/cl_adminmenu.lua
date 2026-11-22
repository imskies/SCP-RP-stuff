local white_color = MININGSYSTEM.Colors.TextColor
local black_color = MININGSYSTEM.Colors.BlackColor

local function MineCreateMenu()
	local Language = MINING_Language[MININGSYSTEM.CurrentLanguage]
	local ply = LocalPlayer()
	if IsValid(MineCreateMenuPanel) then return end 
	if !ply:IsSuperAdmin() then return end 
	MineCreateMenuPanel = vgui.Create( "DFrame" )
	MineCreateMenuPanel:SetSize( ScrW() / 6 , ScrH() / 8)
	MineCreateMenuPanel:SetTitle( "" )
	MineCreateMenuPanel:SetVisible( true )
	MineCreateMenuPanel:SetDraggable( false )
	MineCreateMenuPanel:ShowCloseButton( true )
	MineCreateMenuPanel:MakePopup()
	MineCreateMenuPanel:Center()
	MineCreateMenuPanel.Paint = function(self, w, h)
		Derma_DrawBackgroundBlur( self, self.m_fCreateTime )
		MININGSYSTEM.DrawBlur(self, 6)
		MININGSYSTEM.DrawRect(0,0,w,h, MININGSYSTEM.Colors.Background, Material(MININGSYSTEM.Background))
		MININGSYSTEM.DrawRect(0,0,w,h, black_color, false, true)
		
		draw.DrawText(Language.OreCreationTitle, "CMS_SmallTextFont", w / 2, h * 0.3, white_color, TEXT_ALIGN_CENTER)
	end
	
	local OreCombo = vgui.Create( "DComboBox", MineCreateMenuPanel )
	OreCombo:SetPos(0, MineCreateMenuPanel:GetTall() * 0.55)
	OreCombo:CenterHorizontal()
	OreCombo:SetSize( MineCreateMenuPanel:GetWide() * 0.3, MineCreateMenuPanel:GetTall() * 0.15)
	OreCombo:SetValue( "Select Ore" )

	for k, v in pairs( MININGSYSTEM.Ores ) do
		OreCombo:AddChoice( v['Name'] )
	end
	
	OreCreate = MineCreateMenuPanel:Add("DButton")
	OreCreate:SetPos( 0, MineCreateMenuPanel:GetTall() * 0.8 )
	OreCreate:CenterHorizontal()
	OreCreate:SetSize( MineCreateMenuPanel:GetWide() * 0.3, MineCreateMenuPanel:GetTall() * 0.15 )
	OreCreate:SetText("CREATE")
	OreCreate:DockMargin( 0, 0, 0, 10 )

	OreCreate.DoClick = function(self)
		net.Start("CreateOre")
		net.WriteString(OreCombo:GetValue())
		net.SendToServer()
	end 
end 
net.Receive("OreMenu", MineCreateMenu)