local blur = Material("pp/blurscreen")
local white_color = MININGSYSTEM.Colors.TextColor
local light_green = MININGSYSTEM.Colors.BuyButtonHover
local dark_red = MININGSYSTEM.Colors.SellButtonHover
local black_color = MININGSYSTEM.Colors.BlackColor
gachi_sound = {
	"miningsystem/fun_mode/WOO.mp3",
	"miningsystem/fun_mode/Suction.mp3",
	"miningsystem/fun_mode/Mmmmh.mp3",
}

function MININGSYSTEM.DrawBlur(panel, amount)
    local x, y = panel:LocalToScreen(0, 0)
    local scrW, scrH = ScrW(), ScrH()
    surface.SetDrawColor(white_color)
    surface.SetMaterial(blur)
    for i = 1, 3 do
        blur:SetFloat("$blur", (i / 3) * (amount or 6))
        blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
    end
end

function MININGSYSTEM.sortedPairs(tData, fSortingFunction)
	local keys = {}
	for key in next, tData do keys[#keys + 1] = key end 
	table.sort(keys, fSortingFunction and function(value1, value2) return fSortingFunction(tData, value1, value2) end or nil)
	local counter = 0 
	return function()
			counter = counter + 1
			local key = keys[counter]
			if key then 
				return key, tData[key]
			end 
	end 
end 

function MININGSYSTEM.DrawRect(x, y, w, h, color, material, outline )
	surface.SetDrawColor(color)
	if material then 
		surface.SetMaterial(material)
		surface.DrawTexturedRect(x, y, w, h)
	elseif outline then 
		surface.DrawOutlinedRect(x,y,w,h)
	else 
		surface.DrawRect(x,y,w,h)
	end 
end

local BASE = {}
local underbar = MININGSYSTEM.Colors.Background
local ply = LocalPlayer()

function BASE:Init()
	self:SetTitle( "" )
	self:SetDraggable( false )
	self:ShowCloseButton( false )
	self:MakePopup()
	
	if IsValid(ChosenMaterial) then ChosenMaterial:Remove() end 
	
	timer.Simple(.1, function()
		local Close_Button = vgui.Create( "DButton", self)
		Close_Button:SetPos(self:GetWide() * 0.96, self:GetTall() * 0.005)
		Close_Button:SetSize(ScrW() * 0.015, ScrH() * 0.039)
		Close_Button:SetText('')
		Close_Button.Paint = function(self, w, h)
			if self:IsHovered() then 
				draw.DrawText("x", "CMS_ItemNameFont", w / 2, -4, dark_red, TEXT_ALIGN_CENTER)
			else
				draw.DrawText("x", "CMS_ItemNameFont", w / 2, -4, white_color, TEXT_ALIGN_CENTER)
			end	
		end
		Close_Button.DoClick = function()
			if IsValid(self) then self:SetVisible(false) end 
			surface.PlaySound(MININGSYSTEM.ClickSound)
		end 
		Close_Button.OnCursorEntered = function() 
			surface.PlaySound(MININGSYSTEM.HoverSound)
		end
	end)
end 

function BASE:Type(type)
	self.Type = type
end 

function BASE:SendDarkRPVar(var, level, progress)
	self.DarkRPVar = var
	self.PlayerLevel = level 
	self.PlayerProgress = progress
end 

function BASE:Paint(w, h)
		local Language = MINING_Language[MININGSYSTEM.CurrentLanguage]
		Derma_DrawBackgroundBlur( self, self.m_fCreateTime )
		MININGSYSTEM.DrawBlur(self, 6)
		MININGSYSTEM.DrawRect(0,0,w,h, Color(underbar.r, underbar.g, underbar.b, 100), Material(MININGSYSTEM.Background))
		
		MININGSYSTEM.DrawRect(0,0,w,h, Color(black_color.r,black_color.g,black_color.b, 200))

		MININGSYSTEM.DrawRect(w * 0.05,h * 0.2,w * 0.9,h / h * 6, underbar)
		
		if self.Type == "Craft" then 
			local title = Language.WorkbenchTitle
			surface.SetFont("CMS_TitleFont")
			local titleW = select( 1, surface.GetTextSize(title) )
			
			draw.DrawText(title, "CMS_TitleFont", w * 0.5, h * 0.02, white_color, TEXT_ALIGN_CENTER)
			draw.DrawText(Language.MoneySubtitle ..DarkRP.formatMoney(self.DarkRPVar), "CMS_ItemNameFont", w * 0.05, h * 0.158, white_color, TEXT_ALIGN_LEFT)
			
			MININGSYSTEM.DrawRect((w - titleW) * 0.5,h * 0.1,titleW,h / h * 6, underbar)	
			
			draw.DrawText(Language.Category, "CMS_ItemNameFont", w * 0.495, h * 0.105, white_color, TEXT_ALIGN_RIGHT)
			
			
		elseif self.Type == "Miner" then 
			local title = Language.MinerTitle
			surface.SetFont("CMS_TitleFont")
			local titleW = select( 1, surface.GetTextSize(title) )
			
			draw.DrawText(title, "CMS_TitleFont", w * 0.5, h * 0.02, white_color, TEXT_ALIGN_CENTER)
			draw.DrawText(Language.CurrentBuyRate .. MININGSYSTEM.BuyPriceMultiplier , "CMS_ItemNameFont", w * 0.05, h * 0.16, white_color, TEXT_ALIGN_LEFT)
			draw.DrawText(Language.MoneySubtitle ..DarkRP.formatMoney(self.DarkRPVar), "CMS_ItemNameFont", w * 0.05, h * 0.12, white_color, TEXT_ALIGN_LEFT)
			
			MININGSYSTEM.DrawRect((w - titleW) * 0.5,h * 0.1,titleW,h / h * 6, underbar)		
			
			if !IsValid(ChosenMaterial) then 
				draw.DrawText(Language.MinerCenterText, "CMS_ItemNameFont", w * 0.6, h * 0.3, white_color, TEXT_ALIGN_CENTER)
			end 
			draw.DrawText(Language.LevelText1  .. self.PlayerLevel .. "\n" .. Language.LevelText2 .. math.Round(self.PlayerProgress) .. "/" .. math.Round(self.PlayerLevel * MININGSYSTEM.LevelProgress), "CMS_ItemNameFont", w * 0.5, h * 0.11, white_color, TEXT_ALIGN_CENTER)	
		end 
end 

vgui.Register("MS_BASEFRAME", BASE, "DFrame")

local LIST_ITEM = {}

function LIST_ITEM:Init()
end

function LIST_ITEM:Item(item, type)
	self.Item = item
	self.Type = type 
end 

function LIST_ITEM:SendCurrentAmount(int) 
	self.Amount = int
end 

function LIST_ITEM:OnCursorEntered()
	surface.PlaySound(MININGSYSTEM.HoverSound)
end 

function LIST_ITEM:Paint(w, h)
	local Language = MINING_Language[MININGSYSTEM.CurrentLanguage]
	MININGSYSTEM.DrawBlur(self, 10)

	local IconColor = self.Item.Color
	if self:IsHovered() then 
		IconColor = Color(self.Item.Color.r + 50, self.Item.Color.g + 50, self.Item.Color.b + 50, 255)
		underbar = Color(math.Approach(underbar.r, self.Item.Color.r + 50, 1) , math.Approach(underbar.g, self.Item.Color.g + 50, 1) , math.Approach(underbar.b, self.Item.Color.b + 50, 1) , 255)
	else
		IconColor = self.Item.Color
	end
		MININGSYSTEM.DrawRect(0,0,w,h, Color(IconColor.r, IconColor.g, IconColor.b, 10))
		MININGSYSTEM.DrawRect(0,0,w,h, Color(black_color.r, black_color.g, black_color.b, 30))


		MININGSYSTEM.DrawRect(1,1,w - 2,h * 0.1, IconColor)
		
		MININGSYSTEM.DrawRect(0,0,w,h, Color(black_color.r, black_color.g, black_color.b, 150), false, true)
		
		if self.Type == "Ore" then 
			MININGSYSTEM.DrawRect(w * 0.05, h * 0.14, ScrW() / 17.45, ScrH() / 9.8, IconColor, self.Item.Icon)
			if self.Item.Type == "Wood" then 
				draw.DrawText(self.Item.Name, "CMS_ItemNameFont", w * 0.3, h * 0.1, white_color, TEXT_ALIGN_LEFT)
			else 
				draw.DrawText(self.Item.Name .. " " ..self.Item.Type, "CMS_ItemNameFont", w * 0.3, h * 0.1,  white_color, TEXT_ALIGN_LEFT)
			end 
			draw.DrawText(Language.ListOreSubTitle1 .. math.Round(self.Amount), "CMS_SmallTextFont", w * 0.3, h * 0.5, white_color, TEXT_ALIGN_LEFT)
			draw.DrawText(Language.ListOreSubTitle2 .. DarkRP.formatMoney(self.Item.Price), "CMS_SmallTextFont", w * 0.3, h * 0.7, white_color, TEXT_ALIGN_LEFT)
		elseif self.Type == "CraftItem" then 	
			if self.Item.IsWeapon == true then 
				MININGSYSTEM.DrawRect(w * 0.02, h * 0.14, ScrW() / 12.45, ScrH() / 9.8, IconColor, icons.gun)
			else 
				MININGSYSTEM.DrawRect(w * 0.05, h * 0.14, ScrW() / 17.45, ScrH() / 9.8, IconColor, icons.box)
			end

			draw.DrawText(self.Item.Name, "CMS_ItemNameFont", w * 0.3, h * 0.1, self.Item.Color, TEXT_ALIGN_LEFT)
			draw.DrawText(Language.ItemListSubTitle, "CMS_ItemNameFont", w * 0.3, h * 0.5, white_color, TEXT_ALIGN_LEFT)
		end 
end
vgui.Register("MS_LISTITEM", LIST_ITEM, "DButton")

local SHOW_ITEM = {}

function SHOW_ITEM:Init()
	self:SetDraggable( false )
	self:ShowCloseButton( false )
	self:SetTitle( "" )
end 

function SHOW_ITEM:Item(item, type)
	self.Item = item
	self.Type = type
	
		if self.Type == "CraftItem" then 
			local icon = vgui.Create( "DModelPanel", self )
			icon:SetSize( self:GetWide(), self:GetTall() * 0.3 )
			icon:SetPos( 0, self:GetTall() * 0.1 )
			icon:SetModel( item.Model )
			icon:SetCamPos( Vector(55, 0, 0) )
			if item.AdditionalViewPosZ != nil then 
				addposz = item.AdditionalViewPosZ
			else 
				addposz = 0 
			end 
			icon:SetLookAt( Vector( 0, 0, 3 + addposz ) )
			
			local ResourceList = vgui.Create( "DScrollPanel", self )
			ResourceList:SetSize(self:GetWide() * 0.97, self:GetTall() * 0.389)
			ResourceList:SetPos(self:GetWide() * 0.05, self:GetTall() * 0.47)
			ResourceList.Paint = function(self, w, h)
			end 

			for k, item in next, item.Resources do
				local quantity = item[1]
				local type = item[2]
				
				local ResourceName = vgui.Create( "DLabel", ResourceList )
				ResourceName:SetSize(ResourceList:GetWide(), ResourceList:GetTall() * 0.1)
				ResourceName:Dock(TOP)
				ResourceName:DockMargin(0,0,0,15)
				ResourceName:SetFont("CMS_HugeTextFont")
				ResourceName:SetColor(Color(255,255,255))
				ResourceName:SetText( type .. ": " .. LocalPlayer():GetNWInt("CMS_"..type) .. "/" .. quantity )
			end		
			elseif self.Type == "Ore" then 
				local icon = vgui.Create( "DModelPanel", self )
				icon:SetSize( self:GetWide() * 0.8, self:GetTall() * 0.35 )
				icon:SetPos( self:GetWide() * 0.1, self:GetTall() * 0.3 )
				icon:SetModel( item.MaterialModel )
				icon:SetCamPos( Vector( 20, 5, 25 ) )
				icon:SetLookAt( Vector( 0, 0, 0 ) )
				icon:SetColor(item.Color)

				if item.Type == "Wood" then 
					icon:SetCamPos( Vector( 85, 15, 65 ) )
				end 
					
		end 
end 

function SHOW_ITEM:Paint(w, h)
	local Language = MINING_Language[MININGSYSTEM.CurrentLanguage]
	
	if self.Type == "CraftItem" then 
		draw.DrawText(self.Item.Name, "CMS_TitleFont", w * 0.5, h * 0.01, self.Item.Color, TEXT_ALIGN_CENTER)
				
		local CraftPriceText = DarkRP.formatMoney(self.Item.CraftPrice)

		surface.SetFont("CMS_HugeTextFont")
		local craftW = select(1, surface.GetTextSize(CraftPriceText))
		
		draw.DrawText(Language.CraftPrice, "CMS_ItemNameFont", w * 0.99 - craftW, h * 0.41, white_color, TEXT_ALIGN_RIGHT)
		if LocalPlayer():getDarkRPVar("money") < self.Item.CraftPrice then 
			draw.DrawText(DarkRP.formatMoney(self.Item.CraftPrice), "CMS_HugeTextFont", w * 0.99, h * 0.41, dark_red, TEXT_ALIGN_RIGHT)
		else
			draw.DrawText(DarkRP.formatMoney(self.Item.CraftPrice), "CMS_HugeTextFont", w * 0.99, h * 0.41, light_green, TEXT_ALIGN_RIGHT)
		end 
		if self.Item.Level != nil then 
			local CraftLevelText = self.Item.Level
			local craftLW = select(1, surface.GetTextSize(CraftLevelText))

			draw.DrawText(Language.RequiredLevel, "CMS_ItemNameFont", w * 0.99 - craftLW, h * 0.47, white_color, TEXT_ALIGN_RIGHT)
			
			if LocalPlayer():GetNWInt("CMS_MiningLevel") < CraftLevelText then 
				draw.DrawText(CraftLevelText, "CMS_HugeTextFont", w * 0.99, h * 0.472, dark_red, TEXT_ALIGN_RIGHT)
			else
				draw.DrawText(CraftLevelText, "CMS_HugeTextFont", w * 0.99, h * 0.472, light_green, TEXT_ALIGN_RIGHT)
			end
		end 
		draw.DrawText(Language.RequiredResources, "CMS_ItemNameFont", w * 0.05, h * 0.41, white_color, TEXT_ALIGN_LEFT)
	elseif self.Type == "Ore" then 
		surface.SetFont("CMS_TitleFont")
		local SellButtonW = select(1, surface.GetTextSize(Language.SellButton))
		draw.DrawText("/", "CMS_TitleFont", w - SellButtonW - 25, h * 0.8, white_color, TEXT_ALIGN_CENTER)

		MININGSYSTEM.DrawRect(w * 0.35, h * 0.01, ScrW() / 17.45, ScrH() / 9.8, self.Item.Color, self.Item.Icon)	
			if self.Item.Type == "Wood" then 
				draw.DrawText( self.Item.Name, "CMS_TitleFont", w * 0.45, h * 0.01, white_color, TEXT_ALIGN_LEFT)
			else 
				draw.DrawText( self.Item.Name .. " " ..self.Item.Type, "CMS_TitleFont", w * 0.45, h * 0.01, white_color, TEXT_ALIGN_LEFT)
			end
		draw.DrawText(Language.InInventory .. LocalPlayer():GetNWInt("CMS_".. self.Item.Name), "CMS_TitleFont", w * 0.99, h * 0.15, white_color, TEXT_ALIGN_RIGHT)
		local BuyPriceText = DarkRP.formatMoney( self.Item.Price * MININGSYSTEM.BuyPriceMultiplier)
		local SellPriceText = DarkRP.formatMoney( self.Item.Price)
		surface.SetFont("CMS_HugeTextFont")
		local buyW = select(1, surface.GetTextSize(BuyPriceText))
		local sellW = select(1, surface.GetTextSize(SellPriceText))
		
		draw.DrawText(BuyPriceText, "CMS_HugeTextFont", w * 0.99, h * 0.25, light_green, TEXT_ALIGN_RIGHT)
		draw.DrawText(Language.BuyPrice, "CMS_ItemNameFont", w * 0.99 - buyW, h * 0.25, white_color, TEXT_ALIGN_RIGHT)		
		draw.DrawText(SellPriceText, "CMS_HugeTextFont", w * 0.99, h * 0.3, light_green, TEXT_ALIGN_RIGHT)
		draw.DrawText(Language.SellPrice, "CMS_ItemNameFont", w * 0.99 - sellW, h * 0.3, white_color, TEXT_ALIGN_RIGHT)
			
	end 
end 

vgui.Register("MS_SHOWITEM", SHOW_ITEM, "DFrame")