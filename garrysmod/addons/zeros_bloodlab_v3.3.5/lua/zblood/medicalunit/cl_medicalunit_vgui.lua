/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if not CLIENT then return end

zbl = zbl or {}
zbl.vgui = zbl.vgui or {}

local zbl_MedicalUnit_Interface

zbl.vgui.MedicalUnit = zbl.vgui.MedicalUnit or {}
zbl.vgui.MedicalUnit.Sell = zbl.vgui.MedicalUnit.Sell or {}
zbl.vgui.MedicalUnit.actions = zbl.vgui.MedicalUnit.actions or {}
zbl.vgui.MedicalUnit.Unit = zbl.vgui.MedicalUnit.Unit or {}

local MedicalUnit

/////// GENERAL //////////////////
// This gets called when we open the MedicalUnit interface
net.Receive("zbl.MedicalUnit.Open", function(len)
	zclib.Debug("zbl.MedicalUnit.Open len: " .. len)

	local dataLength = net.ReadUInt(16)
	local boardDecompressed = util.Decompress(net.ReadData(dataLength))
	local data = util.JSONToTable(boardDecompressed)

	LocalPlayer().zbl_Flasks = data.swep

	MedicalUnit = net.ReadEntity()
	if not IsValid(MedicalUnit) then return end
	MedicalUnit.Inventory = data.inv or {}

	LocalPlayer().zbl_SelectedFlask = nil
	LocalPlayer().zbl_SelectedInvFlask = nil

	zbl.vgui.MedicalUnit.actions.OpenUI()
end)

net.Receive("zbl.MedicalUnit.Update", function(len)
	zclib.Debug("zbl.MedicalUnit.Update len: " .. len)

	local dataLength = net.ReadUInt(16)
	local boardDecompressed = util.Decompress(net.ReadData(dataLength))
	local data = util.JSONToTable(boardDecompressed)
	if not data then return end

	local ent = net.ReadEntity()
	if not IsValid(ent) then return end
	ent.Inventory = data

	if IsValid(zbl_MedicalUnit_Interface) and ent == MedicalUnit then
		zbl.vgui.MedicalUnit.Inventory()
	end
end)

////// INIT //////////////////
function zbl.vgui.MedicalUnit:Init()
	self:SetSize(900 * zclib.wM, 670 * zclib.hM)
	self:Center()
	self:MakePopup()
	self:SetDraggable(true)
	self:SetSizable(false)
	self:ShowCloseButton(false)
	self:SetTitle("")

	local title = vgui.Create("DPanel", self)
	title:SetPos(20 * zclib.wM, 20 * zclib.hM)
	title:SetSize(410 * zclib.wM, 40 * zclib.hM)
	title.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.colors["grey_light"])
		draw.DrawText("Stationary Medical Unit", zclib.GetFont("zbl_vgui_npc_title"), 10 * zclib.wM, 5 * zclib.hM, zbl.colors["virus_red"], TEXT_ALIGN_LEFT)
	end

	local button_close = vgui.Create("DButton", self)
	button_close:SetPos(840 * zclib.wM, 20 * zclib.hM)
	button_close:SetSize(40 * zclib.wM, 40 * zclib.hM)
	button_close:SetText("")
	button_close.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.colors["virus_red"])

		surface.SetDrawColor(color_white)
		surface.SetMaterial(zbl.materials["zbl_icon_close"])
		surface.DrawTexturedRect(5 * zclib.wM, 5 * zclib.hM, 30 * zclib.wM, 30 * zclib.hM)

		if s:IsHovered() then
			draw.RoundedBox(5, 0, 0, w, h, zbl.colors["white02"])
		end
	end
	button_close.DoClick = function()
		zbl.vgui.MedicalUnit.actions.CloseUI()
	end

	timer.Simple(0,function()
		zbl.vgui.MedicalUnit.Inventory()
		zbl.vgui.MedicalUnit.SellInterface()
	end)
end
function zbl.vgui.MedicalUnit:Paint(w,h)
	draw.RoundedBox( 5, 0, 0, w, h, zbl.colors["grey_dark"] )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

	if input.IsKeyDown(KEY_ESCAPE) then
		self:Remove()
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

function zbl.vgui.MedicalUnit.Inventory()

	if IsValid(zbl.vgui.MedicalUnit.Unit.MainPanel) then
		zbl.vgui.MedicalUnit.Unit.MainPanel:Remove()
	end

	local MainPanel = vgui.Create("DPanel", zbl_MedicalUnit_Interface)
	MainPanel:SetPos(20 * zclib.wM, 70 * zclib.hM)
	MainPanel:SetSize(410 * zclib.wM, 630 * zclib.hM)
	MainPanel.Paint = function(s, w, h)
		//draw.RoundedBox(5, 0, 0, w, h, zbl.colors["grey_light"])
	end
	zbl.vgui.MedicalUnit.Unit.MainPanel = MainPanel

	local InvPanel = vgui.Create("DPanel", MainPanel)
	InvPanel:SetPos(0 * zclib.wM, 0 * zclib.hM)
	InvPanel:SetSize(410 * zclib.wM, 350 * zclib.hM)
	InvPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.colors["grey_light"])
	end

	local xPos, yPos = 0, 0
	local xOffset = 0
	local NextCount = 4
	for i = 1, 28 do

		local flask_data = MedicalUnit.Inventory[i]

		local flask_button = InvPanel:Add("DButton")
		flask_button:SetSize(64 * zclib.wM, 64 * zclib.hM)
		flask_button:SetPos((64 * zclib.wM * xPos) + (32 * zclib.wM * xPos) + (xOffset * zclib.wM) + (5 * zclib.wM),yPos + (3 * zclib.hM))
		flask_button:SetText("")

		if flask_data then flask_button:SetTooltip(zbl.language.General["Cure"] .. " - " .. flask_data.gn) end

		flask_button.Paint = function(s, w, h)

			//BG
			surface.SetDrawColor(zbl.colors["black03"])
			surface.SetMaterial(zbl.materials["zbl_hexagon_icon"])
			surface.DrawTexturedRect(0, 0, w, h)

			if not flask_data then return end

			local icon = zbl.materials["zbl_cure_icon"]
			local color = zbl.colors["cure_green"]

			if i == LocalPlayer().zbl_SelectedInvFlask then
				surface.SetDrawColor(zbl.colors["black04"])
				surface.SetMaterial(zbl.materials["zbl_hexagon_icon"])
				surface.DrawTexturedRect(0,0,w,h)

				surface.SetDrawColor(color_white)
				surface.SetMaterial(icon)
				surface.DrawTexturedRect(w * 0.12, h * 0.12, w * 0.76, h * 0.76)

				surface.SetDrawColor(color_white)
				surface.SetMaterial(zbl.materials["zbl_hexagon_outline"])
				surface.DrawTexturedRect(0,0,w,h)
			else
				surface.SetDrawColor(color)
				surface.SetMaterial(zbl.materials["zbl_hexagon_icon"])
				surface.DrawTexturedRect(0,0,w,h)

				surface.SetDrawColor(zbl.colors["black02"])
				surface.SetMaterial(icon)
				surface.DrawTexturedRect(w * 0.12, h * 0.12, w * 0.76, h * 0.76)
			end

			if s:IsHovered() then
				surface.SetDrawColor(color_white)
				surface.SetMaterial(zbl.materials["zbl_hexagon_outline"])
				surface.DrawTexturedRect(0,0,w,h)
			end
		end
		flask_button.DoClick = function()
			zbl.vgui.MedicalUnit.InvFlaskInfo(i)
		end

		xPos = xPos + 1

		if (i % NextCount) == 0 then
			xPos = 0
			yPos = yPos + 39
			if xOffset > 0 then
				xOffset = 0
			else
				xOffset = 48
			end
		end
	end

	zbl.vgui.MedicalUnit.InvFlaskInfo()
end

function zbl.vgui.MedicalUnit.InvFlaskInfo(id)

	LocalPlayer().zbl_SelectedInvFlask = id
	LocalPlayer():EmitSound("zbl_ui_click")

	if IsValid(zbl.vgui.MedicalUnit.Unit.FlaskInfoPanel) then
		zbl.vgui.MedicalUnit.Unit.FlaskInfoPanel:Remove()
	end

	local InfoPanel = vgui.Create("Panel", zbl.vgui.MedicalUnit.Unit.MainPanel)
	InfoPanel:SetPos(0 * zclib.wM, 370 * zclib.hM)
	InfoPanel:SetSize(410 * zclib.wM, 210 * zclib.hM)
	InfoPanel.Paint = function(s, w, h)
		//draw.RoundedBox(5, 0, 0, w, h, zbl.colors["cure_green"])
		draw.RoundedBox(5, 0, 0, w,  160 * zclib.hM, zbl.colors["grey_light"])
	end
	zbl.vgui.MedicalUnit.Unit.FlaskInfoPanel = InfoPanel


	if LocalPlayer().zbl_SelectedInvFlask == nil then return end
	local flask_data = MedicalUnit.Inventory[LocalPlayer().zbl_SelectedInvFlask]

	if flask_data == nil then return end

	if flask_data.gt == 0 then return end

	// Here we generate the name and desc according to the gen type
	local gen_name = flask_data.gn
	local gen_desc = zbl.language.General["Cure_desc"]
	local gen_color = zbl.colors["cure_green"]
	gen_desc = string.Replace(gen_desc,"$VaccineName",gen_name)
	gen_desc = string.Replace(gen_desc,"$ImmunityTime",zclib.util.FormatTime(zbl.Vaccine.GetCure_Time(flask_data.gv)))


	local flask_name = vgui.Create("DLabel", InfoPanel)
	flask_name:SetPos(10 * zclib.wM, 5 * zclib.hM)
	flask_name:SetSize(410 * zclib.wM, 60 * zclib.hM)
	flask_name:SetText(gen_name)
	flask_name:SetFont(zclib.GetFont("zbl_vgui_npc_button"))
	flask_name:SetContentAlignment(7)
	flask_name:SetTextColor(gen_color)

	local InfoPanel01 = vgui.Create("Panel", InfoPanel)
	InfoPanel01:SetPos(0 * zclib.wM, 175 * zclib.hM)
	InfoPanel01:SetSize(200 * zclib.wM, 36 * zclib.hM)
	InfoPanel01.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.colors["grey_light"])
	end

	// Depending on if its a cure or a virus we change the price
	local reward = zbl.Vaccine.GetCure_Price(flask_data.gv) * zbl.config.StationaryMedicalUnit.buy_mod
	reward = zclib.Money.Display(reward)

	local flask_price = vgui.Create("DLabel", InfoPanel01)
	flask_price:SetPos(0 * zclib.wM, 0 * zclib.hM)
	flask_price:SetSize(200 * zclib.wM, 40 * zclib.hM)
	flask_price:SetText("+" .. reward)
	flask_price:SetFont(zclib.GetFont("zbl_vgui_npc_job_reward"))
	flask_price:SetContentAlignment(5)
	flask_price:SetTextColor(zbl.colors["cure_green"])


	local buy_button = vgui.Create("DButton", InfoPanel)
	buy_button:SetPos(210 * zclib.wM, 175 * zclib.hM)
	buy_button:SetSize(200 * zclib.wM, 36 * zclib.hM)
	buy_button:SetText("")
	buy_button.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.colors["cure_green"])

		draw.DrawText(zbl.language.General["Vaccinate"], zclib.GetFont("zbl_vgui_npc_button"), 100 * zclib.wM, 2 * zclib.hM, color_white, TEXT_ALIGN_CENTER)

		if s:IsHovered() then
			draw.RoundedBox(5, 0, 0, w, h, zbl.colors["white02"])
		end
	end
	buy_button.DoClick = function()
		zbl.vgui.MedicalUnit.actions.BuyFlask()
	end

	local flask_desc = vgui.Create("DLabel", InfoPanel)
	flask_desc:SetPos(10 * zclib.wM, 35 * zclib.hM)
	flask_desc:SetSize(410 * zclib.wM, 150 * zclib.hM)
	flask_desc:SetText(gen_desc)
	flask_desc:SetWrap(true)
	flask_desc:SetFont(zclib.GetFont("zbl_vgui_npc_job_desc"))
	flask_desc:SetContentAlignment(7)
	flask_desc:SetTextColor(color_white)
end


local campos = Vector(50,0,0)
local lookpos = Vector(0,0,1.5)
function zbl.vgui.MedicalUnit.SellInterface()

	if IsValid(zbl.vgui.MedicalUnit.Sell.MainPanel) then
		zbl.vgui.MedicalUnit.Sell.MainPanel:Remove()
	end

	local MainPanel = vgui.Create("DPanel", zbl_MedicalUnit_Interface)
	MainPanel:SetPos(450 * zclib.wM, 70 * zclib.hM)
	MainPanel:SetSize(430 * zclib.wM, 580 * zclib.hM)
	MainPanel.Paint = function(s, w, h) end
	zbl.vgui.MedicalUnit.Sell.MainPanel = MainPanel

	local ModelPanel = vgui.Create("Panel", MainPanel)
	ModelPanel:SetPos(0 * zclib.wM, 0 * zclib.hM)
	ModelPanel:SetSize(430 * zclib.wM, 350 * zclib.hM)
	ModelPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.colors["grey_light"])
	end
	zbl.vgui.MedicalUnit.Sell.ModelPanel = ModelPanel


	local DModelPanel = vgui.Create("DModelPanel", ModelPanel)
	DModelPanel:SetSize(430 * zclib.wM, 350 * zclib.hM)
	DModelPanel:SetPos(0 * zclib.wM, 0 * zclib.hM)
	DModelPanel:SetModel("models/zerochain/props_bloodlab/zbl_injector.mdl")
	DModelPanel:SetAutoDelete(true)
	DModelPanel:SetMouseInputEnabled( false )
	DModelPanel:SetColor(zbl.colors["white05"])
	DModelPanel.Mat = "models/wireframe"
	DModelPanel.LayoutEntity = function(s)
		s.Entity:SetMaterial(s.Mat)
		s.Entity:SetAngles(Angle(0, 45 * CurTime(), 0))
		s:SetFOV(20)
		s:SetCamPos(campos)
		s:SetLookAt(lookpos)
	end
	zbl.vgui.MedicalUnit.Sell.DModel = DModelPanel

	local BlurPanel = vgui.Create("Panel", ModelPanel)
	BlurPanel:SetPos(10 * zclib.wM, 10 * zclib.hM)
	BlurPanel:SetSize(410 * zclib.wM, 330 * zclib.hM)
	BlurPanel.Paint = function(s, w, h)
		zclib.util.DrawBlur(s, 1,3)
	end
	zbl.vgui.MedicalUnit.Sell.BlurPanel = BlurPanel


	// Create chamber buttons which display the vaccines the player has in his gun currently
	local flask_count = #LocalPlayer().zbl_Flasks
	for i = 1, flask_count do

		local radius = math.Clamp((140 / 12) * flask_count, 120 , 140)

		local start_x, start_y = 215, 175
		local x, y = 0, 0
		local a = math.rad((i / flask_count) * 360)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

		x = start_x + math.sin(a + 0.5) * radius
		y = start_y + math.cos(a + 0.5) * radius

		local b_size = 128 - (64 / 12) * flask_count
		local b_off = b_size / 2

		local flask_data = LocalPlayer().zbl_Flasks[i]
		local isvirus

		if flask_data.gt == 2 then
			isvirus = zbl.Vaccine.IsVirus(flask_data.gv)
		end

		local flask_button = vgui.Create("DButton", ModelPanel)
		flask_button:SetPos((x - b_off) * zclib.wM, (y - b_off) * zclib.hM)
		flask_button:SetSize(b_size * zclib.wM, b_size * zclib.hM)
		flask_button:SetText("")

		if flask_data.gt ~= 0 then
			if flask_data.gt == 1 then
				// Sample
				flask_button:SetTooltip(zbl.language.General["Sample"] .. " - " .. flask_data.gn)
			elseif flask_data.gt == 2 then
				// Virus
				if isvirus then
					flask_button:SetTooltip(zbl.language.General["Virus"] .. " - " .. flask_data.gn)
				else
					flask_button:SetTooltip(zbl.language.General["Abillity"] .. " - " .. flask_data.gn)
				end
			elseif flask_data.gt == 3 then
				// Cure
				flask_button:SetTooltip(zbl.language.General["Cure"] .. " - " .. flask_data.gn)
			end
		end
		flask_button.Paint = function(s, w, h)

			//BG
			surface.SetDrawColor(zbl.colors["black03"])
			surface.SetMaterial(zbl.materials["zbl_hexagon_icon"])
			surface.DrawTexturedRect(0, 0, w, h)

			local icon
			local color

			if flask_data.gt == 1 then


				// Sample
				color = zbl.colors["black04"]//zbl.colors["sample_blue"]
				icon = zbl.materials["zbl_dna_icon"]
			elseif flask_data.gt == 2 then

				// Vaccine
				// Is it virus?
				if isvirus then

					color = zbl.colors["black04"]//zbl.colors["virus_red"]
					icon = zbl.materials["zbl_virus_icon"]
				else
					// Abillity
					color = zbl.colors["black04"]//zbl.colors["abillity_yellow"]
					icon = zbl.materials["zbl_abillity_icon"]
				end
			elseif flask_data.gt == 3 then

				// Cure
				color = zbl.colors["cure_green"]
				icon = zbl.materials["zbl_cure_icon"]
			end

			if icon and color then

				if i == LocalPlayer().zbl_SelectedFlask then
					surface.SetDrawColor(zbl.colors["black04"])
					surface.SetMaterial(zbl.materials["zbl_hexagon_icon"])
					surface.DrawTexturedRect(0,0,w,h)

					surface.SetDrawColor(color_white)
					surface.SetMaterial(icon)
					surface.DrawTexturedRect(w * 0.12, h * 0.12, w * 0.76, h * 0.76)

					surface.SetDrawColor(color_white)
					surface.SetMaterial(zbl.materials["zbl_hexagon_outline"])
					surface.DrawTexturedRect(0,0,w,h)
				else
					surface.SetDrawColor(color)
					surface.SetMaterial(zbl.materials["zbl_hexagon_icon"])
					surface.DrawTexturedRect(0,0,w,h)

					surface.SetDrawColor(zbl.colors["black02"])
					surface.SetMaterial(icon)
					surface.DrawTexturedRect(w * 0.12, h * 0.12, w * 0.76, h * 0.76)
				end
			end

			if flask_data.gt == 3 and s:IsHovered() then
				surface.SetDrawColor(color_white)
				surface.SetMaterial(zbl.materials["zbl_hexagon_outline"])
				surface.DrawTexturedRect(0,0,w,h)
			end
		end
		flask_button.DoClick = function()
			zbl.vgui.MedicalUnit.actions.SelectFlask(i)
		end
		if flask_data.gt ~= 3 then flask_button:SetDisabled(true) end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

	zbl.vgui.MedicalUnit.CreateFlaskInfo()
end
function zbl.vgui.MedicalUnit.CreateFlaskInfo()

	if IsValid(zbl.vgui.MedicalUnit.Sell.FlaskInfoPanel) then
		zbl.vgui.MedicalUnit.Sell.FlaskInfoPanel:Remove()
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

	local InfoPanel = vgui.Create("Panel", zbl.vgui.MedicalUnit.Sell.MainPanel)
	InfoPanel:SetPos(0 * zclib.wM, 370 * zclib.hM)
	InfoPanel:SetSize(430 * zclib.wM, 210 * zclib.hM)
	InfoPanel.Paint = function(s, w, h)
		//draw.RoundedBox(5, 0, 0, w, h, zbl.colors["cure_green"])
		draw.RoundedBox(5, 0, 0, w,  160 * zclib.hM, zbl.colors["grey_light"])
	end
	zbl.vgui.MedicalUnit.Sell.FlaskInfoPanel = InfoPanel


	if LocalPlayer().zbl_SelectedFlask == nil then return end
	local flask_data = LocalPlayer().zbl_Flasks[LocalPlayer().zbl_SelectedFlask]

	if flask_data == nil then return end

	if flask_data.gt == 0 then return end

	// Here we generate the name and desc according to the gen type
	local gen_name
	local gen_desc
	local gen_color
	if flask_data.gt == 1 then
		// Can this sample value be found in the vaccine config?
		// If yes then this means it is a virus sample which can only be found in virusnodes
		if zbl.Vaccine.GetData(flask_data.gv) then
			gen_name = flask_data.gn
			gen_desc = zbl.language.NPC["SampleInfo_Virus"]
		else
			gen_name = flask_data.gn
			gen_desc = string.Replace(zbl.language.NPC["SampleInfo_Other"], "$Name", flask_data.gn)
		end

		gen_color = zbl.colors["sample_blue"]
	elseif flask_data.gt == 2 then

		if zbl.Vaccine.IsVirus(flask_data.gv) then
			gen_name = flask_data.gn
			gen_desc = zbl.Vaccine.GetDescription(flask_data.gv)
			gen_color = zbl.colors["virus_red"]
		else
			gen_name =  flask_data.gn
			gen_desc = zbl.Vaccine.GetDescription(flask_data.gv)
			gen_color = zbl.colors["abillity_yellow"]
		end
	elseif flask_data.gt == 3 then

		gen_name = flask_data.gn

		gen_desc = zbl.language.General["Cure_desc"]
		gen_desc = string.Replace(gen_desc,"$VaccineName",gen_name)
		gen_desc = string.Replace(gen_desc,"$ImmunityTime",zclib.util.FormatTime(zbl.Vaccine.GetCure_Time(flask_data.gv)))

		gen_color = zbl.colors["cure_green"]
	end

	local CanSell = flask_data.gt == 3


	local flask_name = vgui.Create("DLabel", InfoPanel)
	flask_name:SetPos(10 * zclib.wM, 5 * zclib.hM)
	flask_name:SetSize(410 * zclib.wM, 60 * zclib.hM)
	flask_name:SetText(gen_name)
	flask_name:SetFont(zclib.GetFont("zbl_vgui_npc_button"))
	flask_name:SetContentAlignment(7)
	flask_name:SetTextColor(gen_color)

	if CanSell then


		local InfoPanel01 = vgui.Create("Panel", InfoPanel)
		InfoPanel01:SetPos(0 * zclib.wM, 175 * zclib.hM)
		InfoPanel01:SetSize(215 * zclib.wM, 36 * zclib.hM)
		InfoPanel01.Paint = function(s, w, h)
			draw.RoundedBox(5, 0, 0, w, h, zbl.colors["grey_light"])
		end

		// Depending on if its a cure or a virus we change the price
		local reward = 0
		if flask_data.gt == 3 then
			reward = zbl.Vaccine.GetCure_Price(flask_data.gv) * zbl.config.StationaryMedicalUnit.sell_mod
		end
		reward = zclib.Money.Display(reward)

		local flask_price = vgui.Create("DLabel", InfoPanel01)
		flask_price:SetPos(0 * zclib.wM, 0 * zclib.hM)
		flask_price:SetSize(215 * zclib.wM, 40 * zclib.hM)
		flask_price:SetText("+" .. reward)
		flask_price:SetFont(zclib.GetFont("zbl_vgui_npc_job_reward"))
		flask_price:SetContentAlignment(5)
		flask_price:SetTextColor(zbl.colors["cure_green"])

		local sell_button = vgui.Create("DButton", InfoPanel)
		sell_button:SetPos(230 * zclib.wM, 175 * zclib.hM)
		sell_button:SetSize(200 * zclib.wM, 36 * zclib.hM)
		sell_button:SetText("")
		sell_button.Paint = function(s, w, h)
			draw.RoundedBox(5, 0, 0, w, h, zbl.colors["cure_green"])

			draw.DrawText(zbl.language.NPC["Sell"], zclib.GetFont("zbl_vgui_npc_button"), 100 * zclib.wM, 2 * zclib.hM, color_white, TEXT_ALIGN_CENTER)

			if s:IsHovered() then
				draw.RoundedBox(5, 0, 0, w, h, zbl.colors["white02"])
			end
		end
		sell_button.DoClick = function()
			zbl.vgui.MedicalUnit.actions.SellFlask()
		end
	end

	local flask_desc = vgui.Create("DLabel", InfoPanel)
	flask_desc:SetPos(10 * zclib.wM, 35 * zclib.hM)
	flask_desc:SetSize(410 * zclib.wM, 150 * zclib.hM)
	flask_desc:SetText(gen_desc)
	flask_desc:SetWrap(true)
	flask_desc:SetFont(zclib.GetFont("zbl_vgui_npc_job_desc"))
	flask_desc:SetContentAlignment(7)
	flask_desc:SetTextColor(color_white)
end

////// Actions //////////////////
function zbl.vgui.MedicalUnit.actions.OpenUI()
	zclib.Debug("zbl.vgui.MedicalUnit.actions.OpenUI")

	if IsValid(zbl_MedicalUnit_Interface) then
		zbl_MedicalUnit_Interface:Remove()
	end

	zbl_MedicalUnit_Interface = vgui.Create("zbl.vgui.MedicalUnitInterface")
end

function zbl.vgui.MedicalUnit.actions.CloseUI()
	zclib.Debug("zbl.vgui.MedicalUnit.actions.CloseUI")

	MedicalUnit = nil

	if IsValid(zbl_MedicalUnit_Interface) then
		zbl_MedicalUnit_Interface:Remove()
	end
end

function zbl.vgui.MedicalUnit.actions.SelectFlask(id)
	zclib.Debug("zbl.vgui.MedicalUnit.actions.SelectFlask: " .. id)
	local flask_data = LocalPlayer().zbl_Flasks[id]

	if flask_data.gt ~= 2 and flask_data.gt ~= 3 and flask_data.gt ~= 1 then return end
	LocalPlayer().zbl_SelectedFlask = id
	LocalPlayer():EmitSound("zbl_ui_click")

	zbl.vgui.MedicalUnit.CreateFlaskInfo()
end

function zbl.vgui.MedicalUnit.actions.SellFlask()
	zclib.Debug("zbl.vgui.MedicalUnit.actions.SellFlask")

	LocalPlayer():EmitSound("zbl_ui_click")

	local flask_data = LocalPlayer().zbl_Flasks[LocalPlayer().zbl_SelectedFlask]
	if flask_data.gt ~= 2 and flask_data.gt ~= 3 then
		zclib.vgui.Notify(zbl.language.NPC["DNA_SellNotify"],NOTIFY_ERROR)
		return
	end

	net.Start("zbl.MedicalUnit.Sell")
	net.WriteEntity(MedicalUnit)
	net.WriteInt(LocalPlayer().zbl_SelectedFlask, 16)
	net.SendToServer()

	// Reset the data from this flask as if it was sold
	LocalPlayer().zbl_Flasks[LocalPlayer().zbl_SelectedFlask] = {
		gt = 0,
		gv = 0,
		gn = "",
	}

	LocalPlayer().zbl_SelectedFlask = -1

	if IsValid(zbl.vgui.MedicalUnit.Sell.FlaskInfoPanel) then
		zbl.vgui.MedicalUnit.Sell.FlaskInfoPanel:Remove()
	end

	// Rebuild the sell interface
	zbl.vgui.MedicalUnit.SellInterface()
end

function zbl.vgui.MedicalUnit.actions.BuyFlask()
	zclib.Debug("zbl.vgui.MedicalUnit.actions.BuyFlask")

	LocalPlayer():EmitSound("zbl_ui_click")

	net.Start("zbl.MedicalUnit.Buy")
	net.WriteEntity(MedicalUnit)
	net.WriteInt(LocalPlayer().zbl_SelectedInvFlask, 16)
	net.SendToServer()

	// Reset the data from this flask as if it was sold
	MedicalUnit.Inventory[ LocalPlayer().zbl_SelectedInvFlask ] = nil

	LocalPlayer().zbl_SelectedInvFlask = -1

	if IsValid(zbl.vgui.MedicalUnit.Unit.FlaskInfoPanel) then
		zbl.vgui.MedicalUnit.Unit.FlaskInfoPanel:Remove()
	end

	// Rebuild the sell interface
	zbl.vgui.MedicalUnit.Inventory()
end

vgui.Register("zbl.vgui.MedicalUnitInterface", zbl.vgui.MedicalUnit, "DFrame")
