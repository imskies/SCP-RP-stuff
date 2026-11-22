
local circle = Material("dconfig/circle.png", "smooth")
local circle_stencil = Material("dconfig/circle.png", "alphatest")
local circle_stencil_s = Material("dconfig/circle_s.png", "alphatest", "smooth")
function DCONFIG2.PopulateEditorNavigation(panel, navType, editorPanel)
	local navData = DCONFIG2.Editor.Navigation[navType]
	if not navData or not navData.contents then
		local body = DCONFIG2.GetBody()
		panel:Remove()
		editorPanel.editorBody:SetWide(body:GetWide())
		return
	end
	local scrw,scrh = ScrW(),ScrH()
	local theme = DCONFIG2.GetTheme()
	panel.scroll = panel:Add("DCONFIG2ScrollBar")
	panel.scroll:Dock(FILL)
	DCONFIG2.PaintScrollBar(panel.scroll)

	local xPad = panel:GetTall() * .5
	local panelXPad = scrw * .01
	panel.contents = {}
	local newPanel = panel.scroll:Add("DButton")
	newPanel:Dock(TOP)
	newPanel:DockMargin(panelXPad, scrh * .01, panelXPad, 0)
	newPanel:SetText("")
	newPanel.Paint = function(me,w,h)
		draw.RoundedBox(10, 2, 2, w - 4, h - 4, theme.panel)
		if me:IsHovered() then
			draw.RoundedBox(10, 2, 2, w - 4, h - 4, theme.hoverHighlight)
		end
	end
	newPanel.DoClick = function()
		DCONFIG2.OpenEditor(navType, {})
		DCONFIG2.PlaySound("click")
	end

	local newButton = newPanel:Add("DPanel")
	newButton.Paint = function(me,w,h)
		surface.SetMaterial(circle)
		surface.SetDrawColor(theme.theme)
		surface.DrawTexturedRect(0,0,w,h)
		surface.SetDrawColor(theme.body)
		surface.DrawTexturedRect(2,2,w - 4,h - 4)
		draw.SimpleText("+", DCONFIG2.Font(28), w * .5, h * .5, theme.theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local titleLabel = newPanel:Add("DLabel")
	titleLabel:SetText("Create New")
	titleLabel:SetFont(DCONFIG2.Font(18))
	titleLabel:SetTextColor(theme.titletext)
	titleLabel:SetContentAlignment(4)


	local subLabel = newPanel:Add("DLabel")
	subLabel:SetText("Empties Editor")
	subLabel:SetFont(DCONFIG2.Font(14))
	subLabel:SetTextColor(theme.subtitletext)
	subLabel:SetContentAlignment(4)

	newPanel.OnSizeChanged = function(me,w,h)

		local modelSize = h - xPad * 2
		newButton:SetSize(modelSize,modelSize)
		newButton:SetPos(xPad, xPad)
		local labelX = xPad * 2 + modelSize

		titleLabel:SetPos(labelX, h * .1)
		titleLabel:SetSize(w * .7 - xPad, h * .33)
		subLabel:SetPos(labelX, h * .35)
		subLabel:SetSize(w * .7 - xPad, h * .33)
	end
	panel.contents[#panel.contents + 1 or 1] = newPanel

	local loopData = navData.contents
	if type(navData.contents) == "function" then
		loopData = navData.contents()
	end
	for k, contentData in ipairs(loopData) do

		local content = panel.scroll:Add("DButton")
		content:Dock(TOP)
		content:DockMargin(panelXPad, scrh * .01, panelXPad, 0)
		content:SetText("")
		content.Paint = function(me,w,h)
			local body = DCONFIG2.GetBody()
			if body and IsValid(body.editorPanel) and body.editorPanel.contentData == contentData then
				draw.RoundedBox(10, 0, 0, w, h, theme.theme)
			end
			draw.RoundedBox(10, 2, 2, w - 4, h - 4, theme.panel)
			if me:IsHovered() then
				draw.RoundedBox(10, 2, 2, w - 4, h - 4, theme.hoverHighlight)
			end
		end
		content.DoClick = function()
			DCONFIG2.OpenEditor(navType, contentData)
			DCONFIG2.PlaySound("click")
		end
		
		local modelPanel
		local image
		if navData.getRemoteImage then
      		local imageData = navData.getRemoteImage(contentData)

			DCONFIG2.loadMaterial(imageData, function(material, matStr)
				image = content:Add("DImage")
				image:SetTall(40)
				if not matStr then
					image.Paint = function(me,w,h)
						draw.RoundedBox(20,0,0,w,h,theme.theme)
					end
				else
					image:SetImage(matStr)
				end
			end)
		elseif navData.getImage then
			local imageData = navData.getImage(contentData)
			image = content:Add("DPanel")
			image:SetTall(40)
			image.Paint = function(me,w,h)
				surface.SetDrawColor(contentData.color or theme.theme)
				surface.SetMaterial(circle)
				surface.DrawTexturedRect(0, 0, w, h)
	
				surface.SetDrawColor(theme.body)
				surface.DrawTexturedRect(2, 2, w - 4, h - 4)
				
				surface.SetDrawColor(color_white)
				surface.SetMaterial(imageData.material)
				local iconSize = h * .45
				surface.DrawTexturedRect(w * .5 - iconSize * .5, h * .5 - iconSize * .5, iconSize, iconSize)
			end 
			
		else
			modelPanel = content:Add("DModelPanel")
			modelPanel:SetModel(navData.getModel and navData.getModel(contentData) or isstring(contentData.model) and contentData.model or contentData.model[1])
			modelPanel.LayoutEntity = function() end
			if IsValid(modelPanel.Entity) and navData.decorateModel then
				navData.decorateModel(contentData, modelPanel)
			end 
			local oldPaint = modelPanel.Paint
			if navType == "jobs" then
				modelPanel:SetCamPos(Vector( 50, -4, 65))
				modelPanel:SetFOV(20)
				local bone = modelPanel.Entity:LookupBone("ValveBiped.Bip01_Head1")
				if bone then
					local pos, ang = modelPanel.Entity:GetBonePosition(bone)
					modelPanel:SetLookAt(pos)
				else
					modelPanel:SetLookAt( Vector( 0, 0, 66.5 ) )
				end
			else
				modelPanel.Entity:SetPos( modelPanel.Entity:GetPos() - Vector( 0, 0, 4 ) )
				local num = .7
				local min, max = modelPanel.Entity:GetRenderBounds()
				modelPanel:SetCamPos(min:Distance(max) * Vector(num, num, num))
				modelPanel:SetLookAt((max + min) / 2)
				modelPanel:SetFOV(60)
			end
			modelPanel.Paint = function(me,w,h)
				surface.SetDrawColor(contentData.color or theme.theme)
				surface.SetMaterial(circle)
				surface.DrawTexturedRect(0, 0, w, h)
	
				surface.SetDrawColor(theme.body)
				surface.DrawTexturedRect(2, 2, w - 4, h - 4)
				render.ClearStencil()
				render.SetStencilEnable(true)
				render.SetStencilCompareFunction(STENCIL_NEVER)
				render.SetStencilWriteMask(1)
				render.SetStencilTestMask(1)
				render.SetStencilReferenceValue(1)
	
				surface.SetMaterial(circle_stencil_s)
				surface.DrawTexturedRect(0, 0, w, h)
	
				render.SetStencilCompareFunction(STENCIL_EQUAL)
				render.SetStencilPassOperation(STENCIL_KEEP)
				render.SetStencilFailOperation(STENCIL_REPLACE)
				oldPaint(me, w - 4, h - 4)
				render.SetColorModulation(1,1,1)
	
				render.SetStencilWriteMask(2)
				render.SetStencilTestMask(2)
				render.SetStencilReferenceValue(2)
	
				surface.SetMaterial(circle_stencil_s)
				surface.DrawTexturedRect(2, 2, w - 4, h - 4) 
	
				render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
	
				render.SetStencilEnable(false)
			end
		end

		local titleLabel = content:Add("DLabel")
		titleLabel:SetText(navData.getTitle(contentData))
		titleLabel:SetFont(DCONFIG2.Font(18))
		titleLabel:SetTextColor(theme.titletext)
		titleLabel:SetContentAlignment(4)


		local subLabel = content:Add("DLabel")
		subLabel:SetText(navData.getSubTitle(contentData))
		subLabel:SetFont(DCONFIG2.Font(14))
		subLabel:SetTextColor(theme.subtitletext)
		subLabel:SetContentAlignment(4)

		local deleteText = "Delete"
		local hardCoded = contentData.inLuaFile
		if hardCoded then
			deleteText = "Reset"
		end
		local deleteButton = content:Add("DButton")
		deleteButton:SetText("")
		deleteButton.Paint = function(me,w,h)
			if me:IsHovered() then
				draw.SimpleText(deleteText, DCONFIG2.Font(16), 0, h * .5, theme.red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(deleteText, DCONFIG2.Font(14), 0, h * .5, theme.red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		end

		deleteButton.DoClick = function()
			
			DCONFIG2.PlaySound("click")
			if hardcoded then
				contentData.shouldReset = true
			end 
			local networkData = util.Compress(util.TableToJSON(contentData))
			local length = networkData:len()

			local name = contentData.name or "content"
			local verb = hardCoded and "reset" or "delete"
			local notice = hardCoded and "This content will be reset to it's hardcoded values. " or "This content will be deleted. "
			local prompt = DCONFIG2.ConfirmationPrompt {
				title = "Attention! Are you sure you want to ".. verb .. " this " .. name .. "?",
				message = notice .. "If you're unsure it's recommended you create a back up first.",
				confirmCallback = function(amt)
					local deleteMethod = DCONFIG2.Editor.Deleting[navType]
					local resetMethod = DCONFIG2.Editor.Resetting[navType]
					if not hardCoded and deleteMethod then
						local data = deleteMethod(contentData)
						if not data.success then
							DCONFIG2.ShowPopup(data.msg, "dconfig/close.png", 5, true)
							return 
						end
						net.Start("dconfig2_deleteContent")
						net.WriteString(navType)
						net.WriteUInt(length, 32)
						net.WriteData(networkData, length)
						net.SendToServer()
						if data.success and IsValid(DCONFIG2.ScreenPanel) then
							DCONFIG2.ClearBody()
							DCONFIG2.OpenEditor(navType)
						end
					elseif hardCoded then
						local data = resetMethod(contentData)
						if not data.success then
							DCONFIG2.ShowPopup(data.msg, "dconfig/close.png", 5, true)
							return 
						end
						net.Start("dconfig2_resetContent")
						net.WriteString(navType)
						net.WriteUInt(length, 32)
						net.WriteData(networkData, length)
						net.SendToServer()
						if data.success and IsValid(DCONFIG2.ScreenPanel) then
							DCONFIG2.ClearBody()
							DCONFIG2.OpenEditor(navType)
						end						
					end
				end,
				cancelCallback = function()
				end,
			}
		end

		content.OnSizeChanged = function(me,w,h)
			local modelSize = h - xPad * 2
			if IsValid(modelPanel) then 
				modelPanel:SetSize(modelSize,modelSize)
				modelPanel:SetPos(xPad, xPad)
			end
			if IsValid(image) then
				image:SetSize(modelSize,modelSize)
				image:SetPos(xPad, xPad)
			end 
			local labelX = xPad * 2 + modelSize
			titleLabel:SetPos(labelX, h * .1)
			titleLabel:SetSize(w * .7 - xPad, h * .33)
			subLabel:SetPos(labelX, h * .35)
			subLabel:SetSize(w * .7 - xPad, h * .33)
			surface.SetFont(DCONFIG2.Font(20))
			local deleteW = surface.GetTextSize("Delete")
			deleteButton:SetPos(labelX, h * .6)
			deleteButton:SetSize(deleteW, h * .33)
		end

		panel.contents[#panel.contents + 1 or 1] = content
	end
	panel.scroll.OnSizeChanged = function(scroll, w, h)
		for k,v in ipairs(panel.contents) do
			v:SetTall(h * .085)
		end
	end

end
