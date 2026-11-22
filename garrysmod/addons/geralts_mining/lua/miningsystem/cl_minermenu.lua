local white_color = MININGSYSTEM.Colors.TextColor
local light_green = MININGSYSTEM.Colors.BuyButtonHover
local dark_red = MININGSYSTEM.Colors.SellButtonHover
local black_color = MININGSYSTEM.Colors.BlackColor
local yellow_color = MININGSYSTEM.Colors.RadioactiveSuitHover

local underbar = MININGSYSTEM.Colors.Background
local radmat = Material("miningsystem/icons/radiation.png", "smooth mips")

local function CreateOreList()
	OreList = vgui.Create( "DScrollPanel", MinerMenuPanel )
	OreList:SetPos(MinerMenuPanel:GetWide() * 0.05, MinerMenuPanel:GetTall() * 0.23)
	OreList:SetSize(MinerMenuPanel:GetWide() * 0.3, MinerMenuPanel:GetTall() * 0.77)
	OreList:GetVBar():SetWide(0)
end 

local function SelectedMat(item)	
	local Language = MINING_Language[MININGSYSTEM.CurrentLanguage]
	surface.SetFont("CMS_TitleFont")
	
	local BuyButtonW = select(1, surface.GetTextSize(Language.BuyButton))
	local SellButtonW = select(1, surface.GetTextSize(Language.SellButton))
	ChosenMaterial = vgui.Create( "MS_SHOWITEM", MinerMenuPanel )
	ChosenMaterial:SetSize( MinerMenuPanel:GetWide() * 0.6, MinerMenuPanel:GetTall() * 0.77)
	ChosenMaterial:SetPos( MinerMenuPanel:GetWide() * 0.35, MinerMenuPanel:GetTall() * 0.23)
	ChosenMaterial:Item(item, "Ore")

	local BuyButton = vgui.Create("DButton", ChosenMaterial)
	BuyButton:SetSize(BuyButtonW, ChosenMaterial:GetTall() * 0.1)
	BuyButton:SetPos(ChosenMaterial:GetWide() - BuyButtonW - SellButtonW - 50, ChosenMaterial:GetTall() * 0.8)
	BuyButton:SetText("")
	BuyButton.Paint = function(self, w, h)
			if self:IsHovered() then 
				clr = light_green
			else 
				clr = white_color
			end 
		draw.DrawText(Language.BuyButton, "CMS_TitleFont", w * 0.5, h * 0.01, clr, TEXT_ALIGN_CENTER)		
	end 	
	BuyButton.OnCursorEntered = function()
		surface.PlaySound(MININGSYSTEM.HoverSound)
	end 	
	BuyButton.DoClick = function()
		if MININGSYSTEM.FunMode then 
			if math.random(0,100) < 20 then 
				surface.PlaySound(table.Random(gachi_sound))
			else 
				surface.PlaySound(MININGSYSTEM.ClickSound)
			end 
		else
			surface.PlaySound(MININGSYSTEM.ClickSound)
		end 
		Derma_StringRequest(
			Language.BuyRequestTitle,
			Language.BuyRequestSubTitle,
			Language.BuyRequestText,
				function( text ) 
					text = tonumber(text)
					if type( text ) == "number" then 
						net.Start("OreBuyingSelling")
						net.WriteBool(true)
						net.WriteString("CMS_"..item['Name'])
						net.WriteString(text)
						net.WriteString(item.Price * MININGSYSTEM.BuyPriceMultiplier * text)
						net.SendToServer()
					end 
				end,
				function( text ) end)
	end 
	
	local SellButton = vgui.Create("DButton", ChosenMaterial)
	SellButton:SetSize(SellButtonW, ChosenMaterial:GetTall() * 0.1)
	SellButton:SetPos(ChosenMaterial:GetWide() - SellButtonW, ChosenMaterial:GetTall() * 0.8)
	SellButton:SetText("")
	SellButton.Paint = function(self, w, h)
			if self:IsHovered() then 
				clr = dark_red
			else 
				clr = white_color
			end 
		draw.DrawText(Language.SellButton, "CMS_TitleFont", w * 0.5, h * 0.01, clr, TEXT_ALIGN_CENTER)		
	end 	
	SellButton.OnCursorEntered = function()
		surface.PlaySound(MININGSYSTEM.HoverSound)
	end 
	SellButton.DoClick = function()
		if MININGSYSTEM.FunMode then 
			if math.random(0,100) < 20 then 
				surface.PlaySound(table.Random(gachi_sound))
			else 
				surface.PlaySound(MININGSYSTEM.ClickSound)
			end 
		else
			surface.PlaySound(MININGSYSTEM.ClickSound)
		end 	
		Derma_StringRequest(
			Language.SellRequestTitle,
			Language.SellRequestSubTitle,
			Language.SellRequestText,
				function( text ) 
					text = tonumber(text)
					if type( text ) == "number" then 
						net.Start("OreBuyingSelling")
						net.WriteBool(false)
						net.WriteString("CMS_"..item['Name'])
						net.WriteString(text)
						net.WriteString(item.Price * text)
						net.SendToServer()
					end 
				end,
				function( text ) end)
	end 
end 

local function CreateOresListed()
	for k,v in MININGSYSTEM.sortedPairs(MININGSYSTEM.Ores, function(t,v1,v2) return t[v1].Price < t[v2].Price end ) do
		OreListed = OreList:Add("MS_LISTITEM")
		OreListed:SetSize( OreList:GetWide(), ScrH() / 8 )
		OreListed:SetText("")
		OreListed:Dock( TOP )
		OreListed:DockMargin( 0, 0, 0, 10 )
		OreListed:Item(v, "Ore")
		OreListed:SendCurrentAmount(LocalPlayer():GetNWInt("CMS_"..v.Name))
		OreListed.DoClick = function(self)
			if MININGSYSTEM.FunMode then 
				if math.random(0,100) < 20 then 
					surface.PlaySound(table.Random(gachi_sound))
				else 
					surface.PlaySound(MININGSYSTEM.ClickSound)
				end 
			else
				surface.PlaySound(MININGSYSTEM.ClickSound)
			end 		
			if IsValid(ChosenMaterial) then ChosenMaterial:Remove() end 

			SelectedMat(v)
		end 
	end 
end 

local function MinerMenu()
	local Language = MINING_Language[MININGSYSTEM.CurrentLanguage]
	local ply = LocalPlayer()
	MinerMenuPanel = vgui.Create( "MS_BASEFRAME" )
	MinerMenuPanel:SetSize( ScrW(), ScrH())
	MinerMenuPanel:Type("Miner")
	MinerMenuPanel:SendDarkRPVar(ply:getDarkRPVar("money"), ply:GetNWInt("CMS_MiningLevel"), ply:GetNWInt("CMS_LevelProgress"))
	
	CreateOreList()
	CreateOresListed()
	
	local BuySuit = MinerMenuPanel:Add("DButton")
	BuySuit:SetSize( MinerMenuPanel:GetWide() * 0.2, MinerMenuPanel:GetTall() * 0.08 )
	BuySuit:SetPos( MinerMenuPanel:GetWide() * 0.75, MinerMenuPanel:GetTall() * 0.118 )
	BuySuit:SetText("")
	BuySuit:DockMargin( 0, 0, 0, 10 )
	BuySuit.Paint = function(self, w, h)
		if self:IsHovered() then 
			textclr = yellow_color
		else
			textclr = white_color
		end
		
		draw.DrawText(Language.BuySuit .. "\n" .. DarkRP.formatMoney(MININGSYSTEM.RadioactiveSuitPrice), "CMS_ItemNameFont", w * 0.5, h * 0.001, textclr, TEXT_ALIGN_CENTER)
	end
	BuySuit.OnCursorEntered = function()
		surface.PlaySound(MININGSYSTEM.HoverSound)
	end 
	BuySuit.DoClick = function(self)
		if MININGSYSTEM.FunMode then 
			surface.PlaySound("miningsystem/fun_mode/Suction.mp3")
		else
			surface.PlaySound(MININGSYSTEM.ClickSound)
		end 	
		local Menu = DermaMenu()

		local subMenu, MenuOption = Menu:AddSubMenu( Language.YouSure )

		local yesOption = subMenu:AddOption( Language.Yes, function()
			surface.PlaySound("npc/combine_soldier/gear5.wav")
			net.Start("SetPlayerSuit")
			net.WriteString(ply:SteamID64())
			net.SendToServer()
		end )
		yesOption:SetIcon( "icon16/accept.png" )

		local noOption = subMenu:AddOption( Language.No, function() end )
		noOption:SetIcon( "icon16/cross.png" )

		Menu:Open()
	end 

end 
net.Receive("OpenMinerMenu", MinerMenu)

local function DropOre(parent)
	local Language = MINING_Language[MININGSYSTEM.CurrentLanguage]

	if parent then
		DropOrePanel = vgui.Create( "DFrame", parent )
	else
		DropOrePanel = vgui.Create( "DFrame" )
		DropOrePanel:MakePopup()

		DropOrePanel.Think = function()
			if not input.IsKeyDown(MININGSYSTEM.UtilizeKey) then
				DropOrePanel:Remove()
			end
		end
	end

	DropOrePanel:SetSize( ScrW() / 7 , ScrH() / 3)
	DropOrePanel:SetTitle( "" )
	DropOrePanel:SetDraggable( true )
	DropOrePanel:InvalidateLayout( true )
	DropOrePanel:ShowCloseButton( false )
	DropOrePanel:SetMouseInputEnabled( true )
	DropOrePanel:CenterVertical()

	DropOrePanel.OnCursorEntered = function(self) end

	DropOrePanel.Paint = function(self, w, h)
		MININGSYSTEM.DrawBlur(self, 6)
		MININGSYSTEM.DrawRect(0,0,w,h, underbar, Material(MININGSYSTEM.Background))
		MININGSYSTEM.DrawRect(0,0,w,h, black_color, false, true)
		MININGSYSTEM.DrawRect(0,0,w,h, Color(black_color.r, black_color.g, black_color.b, 150))
		
		draw.DrawText(Language.MatsInventoryTitle, "CMS_ItemNameFont", w * 0.5, h * 0.01, white_color, TEXT_ALIGN_CENTER)
	end
		
	local AvailableOresList = vgui.Create( "DScrollPanel", DropOrePanel )
	AvailableOresList:SetPos(0, DropOrePanel:GetTall() * 0.15)
	AvailableOresList:SetSize(DropOrePanel:GetWide(), DropOrePanel:GetTall() * 0.85)
	AvailableOresList:GetVBar():SetWide(0)
	
	for k, v in pairs(MININGSYSTEM.Ores) do 
		if tonumber(LocalPlayer():GetNWInt("CMS_"..v.Name)) > 0 then
			local AvailableOres = AvailableOresList:Add("DFrame")
			AvailableOres:SetSize(AvailableOresList:GetWide(), AvailableOresList:GetTall() * 0.1)
			AvailableOres:ShowCloseButton(false)
			AvailableOres:SetTitle("")
			AvailableOres:SetDraggable(false)
			AvailableOres:Dock(TOP)
			AvailableOres:DockMargin(0,0,0,5)
			AvailableOres.Paint = function(self, w, h)
				if self:IsHovered() then 
					IconColor = Color(v.Color.r + 50, v.Color.g + 50, v.Color.b + 50, 255)
					MININGSYSTEM.DrawRect(0,0,w,h, Color(white_color.r, white_color.g, white_color.b, 15))
				else
					IconColor = v.Color
				end
				MININGSYSTEM.DrawRect(0,0,w,h, Color(IconColor.r, IconColor.g, IconColor.b, 75))
				MININGSYSTEM.DrawRect(0,0,w,h, Color(black_color.r, black_color.g, black_color.b, 150))
				MININGSYSTEM.DrawRect(0,0,w,h, black_color, false, true)

				draw.DrawText(v.Name .. ": " .. math.Round(LocalPlayer():GetNWInt("CMS_"..v.Name)), "CMS_SmallTextFont", w * 0.05, h * 0.1, v.Color, TEXT_ALIGN_LEFT)
			end 
			
			if MININGSYSTEM.CanBeDropped then 
				local DropOres = vgui.Create("DButton", AvailableOres)
				DropOres:SetSize(AvailableOres:GetWide() * 0.25, AvailableOres:GetTall())
				DropOres:SetPos(AvailableOres:GetWide() * 0.75, 0)
				DropOres:SetText("")
				DropOres.Paint = function(self, w, h)
					if self:IsHovered() then 
						MININGSYSTEM.DrawRect(0,0,w,h, Color(IconColor.r, IconColor.g, IconColor.b, 150))
					else 
						MININGSYSTEM.DrawRect(0,0,w,h, Color(white_color.r,white_color.g,white_color.b, 15))
					end 
					MININGSYSTEM.DrawRect(0,0,w,h, black_color, false, true)
					
					draw.DrawText(Language.Drop, "CMS_SmallTextFont", w * 0.5, h * 0.1, black_color, TEXT_ALIGN_CENTER)
				end 
				DropOres.DoClick = function()
					net.Start("DropOre")
					net.WriteString(v.Name)
					net.WriteString(v.Type)
					net.SendToServer()
				end 
			end 
		end
	end 
end 

	
hook.Add("OnContextMenuOpen", "OpenDropPanel", function()
	if not MININGSYSTEM.UtilizeKeyInsteadContext then 
		DropOre(g_ContextMenu)
	end
end)
hook.Add("OnContextMenuClose", "CloseDropPanel", function() 
	if IsValid(DropOrePanel) then DropOrePanel:Remove() end 
end )

hook.Add("PlayerButtonDown", "KeyOpenDropPanel", function(pPlayer, iKey)
	if MININGSYSTEM.UtilizeKeyInsteadContext and IsValid(pPlayer) and pPlayer == LocalPlayer() and iKey == MININGSYSTEM.UtilizeKey then
		if IsFirstTimePredicted() then
			DropOre()
		end
	end 
end)