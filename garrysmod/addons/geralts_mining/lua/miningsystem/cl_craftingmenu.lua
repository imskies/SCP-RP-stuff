local white_color = MININGSYSTEM.Colors.TextColor
local black_color = MININGSYSTEM.Colors.BlackColor

local function ListOfItems()
	ItemsList = vgui.Create( "DScrollPanel", CraftingMenuPanel )
	ItemsList:SetPos(CraftingMenuPanel:GetWide() * 0.05, CraftingMenuPanel:GetTall() * 0.23)
	ItemsList:SetSize(CraftingMenuPanel:GetWide() * 0.3, CraftingMenuPanel:GetTall() * 0.77)
	ItemsList:GetVBar():SetWide(0)
end 

local function SelectedItem(item)
	local Language = MINING_Language[MININGSYSTEM.CurrentLanguage]
	surface.SetFont("CMS_TitleFont")
	local CraftButtonW = select(1, surface.GetTextSize(Language.CraftButton))
	local ply = LocalPlayer()
	CraftItem = CraftingMenuPanel:Add("MS_SHOWITEM")
	CraftItem:SetSize( CraftingMenuPanel:GetWide() * 0.6, CraftingMenuPanel:GetTall() * 0.77 )
	CraftItem:SetPos(CraftingMenuPanel:GetWide() * 0.35, CraftingMenuPanel:GetTall() * 0.23 )
	CraftItem:Item(item, "CraftItem")
	
	local CraftButton = vgui.Create( "DButton", CraftItem)
	CraftButton:SetSize(CraftButtonW, CraftItem:GetTall() * 0.1)
	CraftButton:SetPos(CraftItem:GetWide() - CraftButtonW, CraftItem:GetTall() * 0.8)
	CraftButton:SetText('')
	CraftButton.Paint = function(self, w, h)
			if self:IsHovered() then 
				clr = item.Color
			else 
				clr = white_color
			end 
		draw.DrawText(Language.CraftButton, "CMS_TitleFont", w * 0.5, h * 0.01, clr, TEXT_ALIGN_CENTER)		
	end
	CraftButton.OnCursorEntered = function()
		surface.PlaySound(MININGSYSTEM.HoverSound)
	end 
	CraftButton.DoClick = function(self)
		if MININGSYSTEM.FunMode then 
			if math.random(0,100) < 20 then 
				surface.PlaySound(table.Random(gachi_sound))
			else 
				surface.PlaySound(MININGSYSTEM.ClickSound)
			end 
		else
			surface.PlaySound(MININGSYSTEM.ClickSound)
		end 
		local Menu = DermaMenu()

		local subMenu, MenuOption = Menu:AddSubMenu( Language.YouSure )

		local yesOption = subMenu:AddOption( Language.Yes, function()
			net.Start("CraftItem")
			net.WriteString(item.ItemID)
			net.SendToServer()
		end )
		yesOption:SetIcon( "icon16/accept.png" )

		local noOption = subMenu:AddOption( Language.No, function() end )
		noOption:SetIcon( "icon16/cross.png" )

		Menu:Open()
	end						

end 

local function Items(parent, item)
	ItemsOnList = parent:Add("MS_LISTITEM")
	ItemsOnList:SetSize( parent:GetWide(), ScrH() / 8 )
	ItemsOnList:SetText("")
	ItemsOnList:Dock( TOP )
	ItemsOnList:Item(item, "CraftItem")
	ItemsOnList:DockMargin( 0, 0, 0, 10 )
	ItemsOnList.DoClick = function(self)
		if MININGSYSTEM.FunMode then 
			if math.random(0,100) < 20 then 
				surface.PlaySound(table.Random(gachi_sound))
			else 
				surface.PlaySound(MININGSYSTEM.ClickSound)
			end 
		else
			surface.PlaySound(MININGSYSTEM.ClickSound)
		end 

		if IsValid(CraftItem) then CraftItem:Remove() end 
		SelectedItem(item)
	end 
	ItemsOnList.OnCursorEntered = function() 
		surface.PlaySound(MININGSYSTEM.HoverSound)
	end
end 

local function CraftingMenu()
	local Language = MINING_Language[MININGSYSTEM.CurrentLanguage]
	local ply = LocalPlayer()

	CraftingMenuPanel = vgui.Create( "MS_BASEFRAME" )
	CraftingMenuPanel:SetSize( ScrW() , ScrH())
	CraftingMenuPanel:Type("Craft")
	CraftingMenuPanel:SendDarkRPVar(ply:getDarkRPVar("money"))

 	local recipes = MININGSYSTEM.Recipes
	
	ListOfItems()
	for k,v in pairs(recipes) do	
		Items(ItemsList, v)
	end 

	
	local CategoryList = vgui.Create( "DComboBox", CraftingMenuPanel )
	CategoryList:SetPos(CraftingMenuPanel:GetWide() * 0.505, CraftingMenuPanel:GetTall() * 0.11)
	CategoryList:SetSize(CraftingMenuPanel:GetWide() * 0.08, CraftingMenuPanel:GetTall() * 0.036)
	CategoryList:SetFont("CMS_ItemNameFont")
	CategoryList:SetTextColor(black_color)
	CategoryList:SetValue( Language.All )
	CategoryList:AddChoice( Language.All )
	CategoryList.OnSelect = function( _, _, value )
		if value == Language.All then 
			if IsValid(ItemsList) then ItemsList:Remove() end 
			ListOfItems()
			for k,v in pairs(recipes) do	
				Items(ItemsList, v)
			end 
		else 
			if IsValid(ItemsList) then ItemsList:Remove() end 
			ListOfItems()
			for k,v in pairs(recipes) do
				if v.Category == value then 	
					Items(ItemsList, v)
				end 
			end 
		end 
	end
	for k, v in pairs( MININGSYSTEM.Categories ) do
		CategoryList:AddChoice( v.Name )
	end
end 
net.Receive("OpenCraftingMenu", CraftingMenu)