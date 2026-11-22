/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

if not CLIENT then return end

zpiz = zpiz or {}
zpiz.Pizza = zpiz.Pizza or {}

local PizzaDough
net.Receive("zpiz_pizza_open", function(len)
	PizzaDough = net.ReadEntity()
	zpiz.Pizza.Open()
end)

// A Clean way do display the ingredients
local size = 600

local function DrawIngredientItem(icon, y)
	surface.SetDrawColor(zpiz.colors["black02"])
	surface.SetMaterial(zpiz.materials["zpiz_circle"])
	surface.DrawTexturedRect(size * -0.5, 0, size * 1.5, size * 1.5)

	surface.SetDrawColor(color_white)
	surface.SetMaterial(icon)
	surface.DrawTexturedRect(size * -0.25, size * 0.25 + y, size, size)
end

function zpiz.Pizza.DrawIngredientsVgui(Pizza)
	if table.Count(Pizza.cl_NeededIngredients) <= 0 then return end

	for _, ing_id in pairs(Pizza.cl_NeededIngredients) do
		DrawIngredientItem(zpiz.Ingredient.GetIcon(ing_id), y)
		y = y - 80
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350945

local function drawRecipe(parent, pizzaId, infos, canRemove)
	local itm = vgui.Create("DButton", parent)
	itm:SetSize(665 * zclib.wM, 140 * zclib.hM)
	itm:SetText("")
	itm.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zclib.colors["black_a100"])

		surface.SetDrawColor(204, 112, 55)
		surface.SetMaterial(zpiz.materials["zpiz_circle"])
		surface.DrawTexturedRect(h * 0.05, h * 0.05, h * 0.9, h * 0.9)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(infos.icon)
		surface.DrawTexturedRect(h * 0.1, h * 0.1, h * 0.8, h * 0.8)

		surface.SetDrawColor(zclib.colors["black_a100"])
		surface.SetMaterial(zclib.Materials.Get("linear_gradient"))
		surface.DrawTexturedRectRotated(w * 0.61,h * 0.68,w * 0.8,h * 0.40,180)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- fde1005ae952a630057a2cc575fe1335e7c9809985c0483424501baa23d5a1ad

		local count = 1
		for ing_id, ing_amount in pairs(zpiz.Pizza.GetRecipe(pizzaId)) do

			local x, y = (55 * count) * zclib.wM ,  70 * zclib.hM
			x = x + (95 * zclib.wM)

			surface.SetDrawColor(zclib.colors["black_a200"])
			surface.SetMaterial(zclib.Materials.Get("radial_shadow"))
			surface.DrawTexturedRect(x,y,50 * zclib.wM,50 * zclib.hM)

			surface.SetDrawColor(color_white)
			surface.SetMaterial(zpiz.Ingredient.GetIcon(ing_id))
			surface.DrawTexturedRect(x + 5 * zclib.wM,y + 5 * zclib.hM,40 * zclib.wM,40 * zclib.hM)

			draw.SimpleText(ing_amount, zclib.GetFont("zclib_font_small"), x, y + 50 * zclib.hM, color_white, TEXT_ALIGN_LEFT,TEXT_ALIGN_BOTTOM)
			count = count + 1
		end

		draw.SimpleText(infos.name, zclib.GetFont("zclib_font_medium"), h, 10 * zclib.hM, color_white, TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		draw.SimpleText(infos.desc, zclib.GetFont("zclib_font_mediumsmall_thin"), h, 40 * zclib.hM, color_white, TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)

		draw.SimpleText(zpiz.language.VGUI_RecipeBakeTime .. " " .. infos.time .. "s   /   " .. zpiz.language.VGUI_RecipeProfit .. " " .. zclib.Money.Display(infos.price), zclib.GetFont("zclib_font_small_thin"), w - 20 * zclib.wM, 63 * zclib.hM, color_white, TEXT_ALIGN_RIGHT,TEXT_ALIGN_BOTTOM)

		if s:IsHovered() then
			draw.RoundedBox(5, 0, 0, w, h, zclib.colors["white_a15"])
		end
	end
	itm.DoClick = function()
		if canRemove then
			if IsValid(itm) then itm:Remove() end

			return
		end

		net.Start("zpiz_pizza_select")
			net.WriteUInt(pizzaId, 16)
			net.WriteEntity(PizzaDough)
		net.SendToServer()

		if IsValid(zpiz_main_panel) then zpiz_main_panel:Remove() end
	end

	return itm
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3a7bd44c53efd46df183636fbe76c3de2bd5fbbd78a3773db33588e14b60a4d

function zpiz.Pizza.Open()
	zpiz.vgui.Page(zpiz.language.VGUI_Recipe, function(main, top)
		main:SetSize(800 * zclib.wM, 900 * zclib.hM)
		main.BgColor = zpiz.colors["orange01"]

		local close_btn = zclib.vgui.ImageButton(240 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 50 * zclib.hM, top, zclib.Materials.Get("close"), function()
			if IsValid(zpiz_main_panel) then zpiz_main_panel:Remove() end
		end, false)
		close_btn:Dock(RIGHT)
		close_btn:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
		close_btn.IconColor = zclib.colors["red01"]
		close_btn.NoneHover_IconColor = zclib.colors["white_a15"]
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

		local seperator = zpiz.vgui.AddSeperator(top)
		seperator:SetSize(5 * zclib.wM, 50 * zclib.hM)
		seperator:Dock(RIGHT)
		seperator:DockMargin(10 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)

		local list, scroll = zpiz.vgui.List(main)
		scroll.Paint = function(s, w, h) end
		scroll:DockMargin(50 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 0 * zclib.hM)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- fde1005ae952a630057a2cc575fe1335e7c9809985c0483424501baa23d5a1ad

		for i, v in ipairs(zpiz.config.Pizza) do
			local itm = drawRecipe(list, i, v)

			local getRecipe = vgui.Create("DButton", itm)
			getRecipe:SetSize(50 * zclib.hM, 50 * zclib.hM)
			getRecipe:SetPos(itm:GetWide()* 0.91, itm:GetTall() * 0.6)
			getRecipe:SetText("✎")
			getRecipe:SetFont(zclib.GetFont("zpiz_vgui_font03"))
			getRecipe:SetTextColor(color_white)
			getRecipe.Paint = function(s, w, h)
				draw.RoundedBox(5, 0, 0, w, h, zclib.colors["orange01"])

				if s:IsHovered() then
					draw.RoundedBox(5, 0, 0, w, h, zclib.colors["white_a15"])
				end
			end
			getRecipe.DoClick = function()
				net.Start("zpiz_pizza_select")
					net.WriteUInt(i, 16)
					net.WriteEntity(PizzaDough)
				net.SendToServer()

				if IsValid(zpiz.Pizza.DrawedRecipe) then
					zpiz.Pizza.DrawedRecipe:Remove()
				end

				local drawRecipe = drawRecipe(nil, i, v, true)
				drawRecipe:SetPos(0, 0)
				drawRecipe.linkedTo = PizzaDough
				drawRecipe.Think = function(self)
					if not IsValid(self.linkedTo) or not zpiz.config.Jobs[LocalPlayer():Team()] then
						self:Remove()
					end
				end

				zpiz.Pizza.DrawedRecipe = drawRecipe

				if IsValid(zpiz_main_panel) then zpiz_main_panel:Remove() end
			end
		end
	end)
end
