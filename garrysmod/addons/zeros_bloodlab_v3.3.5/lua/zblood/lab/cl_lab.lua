/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if SERVER then return end
zbl = zbl or {}
zbl.Lab = zbl.Lab or {}
zbl.Actions = zbl.Actions or {}
zbl.Labs = zbl.Labs or {}

zclib.Hook.Add("PostDrawOpaqueRenderables", "zbl_DrawInterface", function(depth, skybox,skybox3d)
	if skybox3d == false then
		for _,lab in pairs(zbl.Labs) do
			if IsValid(lab) then
				zbl.Lab.Draw(lab)
			end
		end
	end
end)

function zbl.Lab.Initialize(Lab)
	zclib.Debug("Lab_Initialize")

	zclib.EntityTracker.Add(Lab)

	Lab.VGUI = {}
	Lab.VGUI.Research = {}
	Lab.VGUI.Analyze = {}
	Lab.VGUI.Mainmenu = {}

	// The selected vaccine list
	Lab.VaccineListID = 1

	// The selected vaccine
	Lab.VaccineID = 1

	// The current action state we are in
	Lab.LastActionState = -1

	// Tells us if the screen is clsoed
	Lab.IsClosed = true

	// Tells us if the screen is animating
	Lab.IsAnimating = false

	// PoseParameter to controll the open/close state of the screen
	Lab.pp_Screen = 0

	Lab.SelectedCure = false


	// Adds the Lab to get rendered
	zbl.Labs[Lab:EntIndex()] = Lab

	timer.Simple(0.3,function()
		if IsValid(Lab) then
			zbl.Lab.UpdateVisuals(Lab)
		end
	end)
end

// The Main Panel
function zbl.Lab.CreateMainInterface(Lab)
	zclib.Debug("Lab_CreateMainInterface")
	Lab.VGUI.Main = vgui.Create("DPanel")
	Lab.VGUI.Main:ParentToHUD()
	Lab.VGUI.Main:SetMouseInputEnabled(true)
	Lab.VGUI.Main:SetPos(0, 0)
	Lab.VGUI.Main:SetSize(650, 400)
	Lab.VGUI.Main.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, zbl.colors["lab_blue_dark"])
	end

	zbl.Lab.RemoveAllInterfaces(Lab)

	if Lab.LastActionState == 0 then
		zbl.Lab.MainMenu(Lab)
	elseif Lab.LastActionState == 1 then
		zbl.Lab.ProcessPanel(Lab)
	elseif Lab.LastActionState == 2 then
		zbl.Lab.ProcessPanel(Lab)
	elseif Lab.LastActionState == 3 then
		zbl.Lab.ProcessPanel(Lab)
	end
end

// The Draw Function of the Interface
function zbl.Lab.Draw(Lab)

	zbl.util.UpdateEntityVisuals(Lab)

	if IsValid(Lab) then

		// Is the player in distance?
		if zclib.util.InDistance(LocalPlayer():GetPos(), Lab:GetPos(), 1600) and Lab.IsAnimating == false and Lab.IsClosed == false then

			zbl.Lab.DrawInterface(Lab)
		else

			Lab.VaccineListID = 1
			Lab.VaccineID = 1

			// Hide the interface
			if Lab.VGUI and IsValid(Lab.VGUI.Main) and Lab.VGUI.Main:IsVisible() == true then
				Lab.VGUI.Main:SetVisible(false)
				Lab.VGUI.Main:Remove()
			end
		end

		if zclib.Convar.Get("zbl_cl_dynlight") == 1 and zclib.util.InDistance(LocalPlayer():GetPos(), Lab:GetPos(), 600) and Lab.LastActionState > 0 then
			// Create Dynamic light
			zbl.Lab.Light(Lab)
		end
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

local lpos_offset = Vector(0,40,40)
function zbl.Lab.Light(Lab)
	local dlight01 = DynamicLight(Lab:EntIndex())
	local pos = Lab:LocalToWorld(lpos_offset)

	if dlight01 then
		dlight01.pos = pos
		dlight01.r = zbl.colors["lab_blue"].r
		dlight01.g = zbl.colors["lab_blue"].g
		dlight01.b = zbl.colors["lab_blue"].b
		dlight01.brightness = 2
		dlight01.Decay = 1000
		dlight01.Size = 200
		dlight01.DieTime = CurTime() + 1
	end
end

function zbl.Lab.UpdateVisuals(Lab)
	Lab.LastActionState = Lab:GetActionState()

	if Lab.LastActionState == 0 then

		zbl.Lab.Animate(Lab,"idle",1)
	elseif Lab.LastActionState == 1 or Lab.LastActionState == 2 or Lab.LastActionState == 3 then

		zbl.Lab.Animate(Lab,"spin",1)
	end
end

local pos_offset = Vector(25, -16.5, 61.7)
local ang_offset = Angle(0, 90, 90)

function zbl.Lab.DrawInterface(Lab)
	zclib.vgui3d.Start3D2D(Lab:LocalToWorld(pos_offset), Lab:LocalToWorldAngles(ang_offset), 0.05)
		if Lab.VGUI and IsValid(Lab.VGUI.Main) then

			if Lab.VGUI and IsValid(Lab.VGUI.Main) and Lab.VGUI.Main:IsVisible() == false then
				Lab.VGUI.Main:SetVisible(true)
			end

			// Draws the UI
			Lab.VGUI.Main:ZCLIBPaint3D2D()


			// Cursor
			if zclib.vgui3d.IsPointingPanel(Lab.VGUI.Main) then
				local x, y = zclib.vgui3d.GetCursorPosition(Lab.VGUI.Main)

				surface.SetDrawColor(color_white)
				surface.SetMaterial(zbl.materials["zbl_cursor"])
				surface.DrawTexturedRect(x - 10, y - 10, 20, 20)
			end
		else
			zbl.Lab.CreateMainInterface(Lab)
		end
	zclib.vgui3d.End3D2D()
end

// Gets called when the Lab gets removed
function zbl.Lab.OnRemove(Lab)
	zclib.Debug("Lab_OnRemove")
	if IsValid(Lab) then
		if Lab.VGUI and IsValid(Lab.VGUI.Main) then
			zclib.Debug("Lab_Interface_Removed")
			Lab.VGUI.Main:Remove()
		end

		if Lab.SoundObj and Lab.SoundObj:IsPlaying() == true then
			Lab.SoundObj:ChangeVolume(0, 0)
			Lab.SoundObj:Stop()
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

		zbl.Labs[Lab:EntIndex()] = nil
	end
end

function zbl.Lab.Animate(Lab,anim,speed)
	local _,dur = Lab:LookupSequence( anim )
	local time = dur / speed

	zclib.Animation.Play(Lab,anim, speed)
	return time
end

// Gets called when the actionstate changes
function zbl.Lab.OnStateChange(Lab,newstate,oldstate)
	zclib.Debug("Lab_OnStateChange")


	// Starts the processing animation
	if newstate == 1 or newstate == 2 or newstate == 3 then

		local dur = zbl.Lab.Animate(Lab,"prep",1)

		timer.Simple(dur,function()
			if IsValid(Lab) and Lab.LastActionState == 1 or Lab.LastActionState == 2 or Lab.LastActionState == 3  then

				zbl.Lab.Animate(Lab,"spin",1)
			end
		end)
	end

	// Finishes the processing animation
	if newstate == 0 and (oldstate == 1 or oldstate == 2 or oldstate == 3) then

		local dur = 1
		if oldstate == 2 or oldstate == 3 then
			dur = zbl.Lab.Animate(Lab,"output",1)
		else
			dur = zbl.Lab.Animate(Lab,"finish",1)
		end

		timer.Simple(dur,function()
			if IsValid(Lab) and Lab.LastActionState == 0 then
				zbl.Lab.Animate(Lab,"idle",1)
			end
		end)
	end

	Lab.LastActionState = newstate

	if Lab.VGUI and IsValid(Lab.VGUI.Main) then

		zbl.Lab.RemoveAllInterfaces(Lab)

		if newstate == 0 then
			zbl.Lab.MainMenu(Lab)
		elseif newstate == 1 then
			zbl.Lab.ProcessPanel(Lab)
		elseif newstate == 2 then
			zbl.Lab.ProcessPanel(Lab)
		elseif newstate == 3 then
			zbl.Lab.ProcessPanel(Lab)
		end
	end
end

function zbl.Lab.Think(Lab)

	zbl.Lab.OpenClose(Lab)

	zbl.Lab.Sound(Lab)

	if zclib.util.InDistance(LocalPlayer():GetPos(), Lab:GetPos(), 1600) then

		local _state = Lab:GetActionState()
		if Lab.LastActionState ~= _state then
			zbl.Lab.OnStateChange(Lab,_state,Lab.LastActionState)
		end
	else
		if Lab.SoundObj and Lab.SoundObj:IsPlaying() == true then
			Lab.SoundObj:ChangeVolume(0, 0)
			Lab.SoundObj:Stop()
		end
	end
end

function zbl.Lab.Sound(Lab)
	if Lab.LastActionState > 0 then
		if Lab.SoundObj == nil then
			Lab.SoundObj = CreateSound(Lab, "zbl_lab_scan")
		end

		if Lab.SoundObj:IsPlaying() == false then
			Lab.SoundObj:Play()
			Lab.SoundObj:ChangeVolume(0.3, 0)
		end
	else
		if Lab.SoundObj and Lab.SoundObj:IsPlaying() == true then
			Lab.SoundObj:ChangeVolume(0, 0)
			Lab.SoundObj:Stop()
		end
	end
end

// Open Closes the Screen according to the distance
function zbl.Lab.OpenClose(Lab)

	if zclib.util.InDistance(LocalPlayer():GetPos(), Lab:GetPos(), 100) then
		if Lab.pp_Screen >= 1 then
			if Lab.IsClosed == true then
				Lab.IsClosed = false

				if Lab.VGUI and IsValid(Lab.VGUI.Main) then
					Lab.VGUI.Main:SetAlpha(0)
					Lab.VGUI.Main:AlphaTo( 255, 0.3, 0, function() end )
				end

				Lab:EmitSound("zbl_lab_stop")
				Lab:StopSound("zbl_lab_move")
			end

			Lab.IsAnimating = false
		else
			if Lab.IsAnimating == false then
				Lab.IsAnimating = true

				Lab:EmitSound("zbl_lab_move")
				Lab:StopSound("zbl_lab_stop")
			end

		end

		Lab.pp_Screen = math.Clamp(Lab.pp_Screen + 2 * FrameTime(), 0, 1)
		Lab:SetPoseParameter("zbl_screenmover", Lab.pp_Screen)
	else
		if Lab.pp_Screen <= 0 then
			if Lab.IsClosed == false then
				Lab.IsClosed = true

				Lab:EmitSound("zbl_lab_stop")
				Lab:StopSound("zbl_lab_move")
			end

			Lab.IsAnimating = false
		else
			if Lab.IsAnimating == false then
				Lab.IsAnimating = true

				Lab:EmitSound("zbl_lab_move")
				Lab:StopSound("zbl_lab_stop")
			end
		end

		Lab.pp_Screen = math.Clamp(Lab.pp_Screen - 2 * FrameTime(), 0, 1)
		Lab:SetPoseParameter("zbl_screenmover", Lab.pp_Screen)
	end
end

function zbl.Lab.RemoveAllInterfaces(Lab)
	zclib.Debug("Lab_RemoveAllInterfaces")

	if Lab.VGUI and Lab.VGUI.Mainmenu and IsValid(Lab.VGUI.Mainmenu.MainPanel) then
		Lab.VGUI.Mainmenu.MainPanel:Remove()
	end

	if Lab.VGUI and Lab.VGUI.Analyze and IsValid(Lab.VGUI.Analyze.MainPanel) then
		Lab.VGUI.Analyze.MainPanel:Remove()
	end

	if Lab.VGUI and Lab.VGUI.Research and IsValid(Lab.VGUI.Research.MainPanel) then
		Lab.VGUI.Research.MainPanel:Remove()
	end

	if Lab.VGUI and IsValid(Lab.VGUI.ProcessPanel) then
		Lab.VGUI.ProcessPanel:Remove()
	end
end
////////////////////////////////////////////
////////////////////////////////////////////

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24


////////////////////////////////////////////
////////////// ProgressBar /////////////////
////////////////////////////////////////////
// Creates a process bar which shows the progress
function zbl.Lab.ProcessPanel(Lab)
	zclib.Debug("Lab_ProcessPanel")

	zbl.Lab.RemoveAllInterfaces(Lab)

	if Lab.VGUI and IsValid(Lab.VGUI.ProcessPanel) then
		Lab.VGUI.ProcessPanel:Remove()
	end

	local name = ""
	local status = ""
	local color = zbl.colors["virus_red"]
	local icon = zbl.materials["zbl_virus_icon"]

	if Lab.LastActionState == 1 then
		status = zbl.language.General["analyzing"]
		color = zbl.colors["sample_blue"]
		icon = zbl.materials["zbl_dna_icon"]
	elseif Lab.LastActionState == 2 then

		if zbl.Vaccine.IsVirus(Lab:GetSelectedVaccine()) then
			color = zbl.colors["virus_red"]
			icon = zbl.materials["zbl_virus_icon"]
		else
			color = zbl.colors["abillity_yellow"]
			icon = zbl.materials["zbl_abillity_icon"]
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

		status = zbl.language.General["creating"]
		name = zbl.Vaccine.GetName(Lab:GetSelectedVaccine())
	elseif Lab.LastActionState == 3 then

		status = zbl.language.General["creating"]
		name = zbl.Vaccine.GetName(Lab:GetSelectedVaccine())
		color = zbl.colors["cure_green"]
		icon = zbl.materials["zbl_cure_icon"]
	end

	Lab.VGUI.ProcessPanel = vgui.Create("DPanel",Lab.VGUI.Main)
	Lab.VGUI.ProcessPanel:SetPos(0, 0)
	Lab.VGUI.ProcessPanel:SetSize(650, 400)
	Lab.VGUI.ProcessPanel.LastPoint = - CurTime()
	Lab.VGUI.ProcessPanel.Points = "..."
	Lab.VGUI.ProcessPanel.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, 45, zbl.colors["lab_blue_dark"])
		draw.RoundedBox(0, 80, 200, 500, 60, zbl.colors["lab_blue_light"])
		local time = Lab:GetProgressDuration() - math.Clamp(Lab:GetProgressEnd() - CurTime(), 0, 999999999)
		local width = (500 / Lab:GetProgressDuration()) * time
		draw.RoundedBox(0, 80, 200, width, 60, color)

		if Lab.LastActionState > 1 then
			draw.DrawText(name, zclib.GetFont("zbl_lab_button_main"), w / 2, 115, color, TEXT_ALIGN_CENTER)

			surface.SetDrawColor(color)
			surface.SetMaterial(icon)
			surface.DrawTexturedRect(w / 2 - 50, 25, 100, 100)
		else
			surface.SetDrawColor(color)
			surface.SetMaterial(icon)
			surface.DrawTexturedRect(w / 2 - 75, 25, 150, 150)
		end

		if (s.LastPoint + 1) < CurTime() then
			s.LastPoint = CurTime()

			if string.len(s.Points) >= 3 then
				s.Points = "."
			else
				s.Points = s.Points .. "."
			end
		end

		draw.DrawText(status .. s.Points, zclib.GetFont("zbl_lab_points"), w / 2, 310, color_white, TEXT_ALIGN_CENTER)
	end
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
//////////////// MainMenu //////////////////
////////////////////////////////////////////
// Creates the Main Interface
function zbl.Lab.MainMenu(Lab)
	zclib.Debug("Lab_MainMenu")

	zbl.Lab.RemoveAllInterfaces(Lab)

	if Lab.VGUI and Lab.VGUI.Mainmenu and IsValid(Lab.VGUI.Mainmenu.MainPanel) then
		Lab.VGUI.Mainmenu.MainPanel:Remove()
	end

	local owner = zclib.Player.GetOwner(Lab)
	local name = ""
	if IsValid(owner) then
		name = owner:Nick()
		name = string.Replace(zbl.language.General["LabTitle"],"$PlayerName",name)
	else
		name = string.Replace(zbl.language.General["LabTitle"],"$PlayerName","Public")
	end

	Lab.VGUI.Mainmenu.MainPanel = vgui.Create("DPanel",Lab.VGUI.Main)
	Lab.VGUI.Mainmenu.MainPanel:SetPos(0, 0)
	Lab.VGUI.Mainmenu.MainPanel:SetSize(650, 400)
	Lab.VGUI.Mainmenu.MainPanel.Paint = function(s, w, h)

		draw.RoundedBox(0, 0, 0, w,52, zbl.colors["lab_blue_light"])
		draw.DrawText(name, zclib.GetFont("zbl_gun_font02"), 30, 15, color_white, TEXT_ALIGN_LEFT)
	end


	Lab.VGUI.Mainmenu.PointPanel = vgui.Create("DPanel",Lab.VGUI.Mainmenu.MainPanel)
	Lab.VGUI.Mainmenu.PointPanel:SetPos(50, 300)
	Lab.VGUI.Mainmenu.PointPanel:SetSize(150, 60)
	Lab.VGUI.Mainmenu.PointPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w,h, zbl.colors["lab_blue_light"])

		draw.DrawText(zbl.DNASystem.Get(LocalPlayer()), zclib.GetFont("zbl_lab_points"), 90, 12, color_white, TEXT_ALIGN_CENTER)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(zbl.materials["zbl_dna_icon"])
		surface.DrawTexturedRect(0, 0, 60,60)
	end

	Lab.VGUI.Mainmenu.Analyze = vgui.Create("DButton", Lab.VGUI.Mainmenu.MainPanel)
	Lab.VGUI.Mainmenu.Analyze:SetPos(205,90)
	Lab.VGUI.Mainmenu.Analyze:SetSize(240 , 70 )
	Lab.VGUI.Mainmenu.Analyze:SetAutoDelete(true)
	Lab.VGUI.Mainmenu.Analyze:SetText("")
	Lab.VGUI.Mainmenu.Analyze.Paint = function(s, w, h)


		draw.RoundedBox(5, 0, 0, w, h, zbl.colors["lab_blue_light"])

		draw.SimpleText(zbl.language.General["Analyze"], zclib.util.FontSwitch(zbl.language.General["Analyze"], 7, zclib.GetFont("zbl_lab_button_main"), zclib.GetFont("zbl_lab_button_main_small")), 20, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		surface.SetDrawColor(zbl.colors["cure_green"])
		surface.SetMaterial(zbl.materials["zbl_icon_analyze"])
		surface.DrawTexturedRect(170, 10, 50,50)

		if s.Hovered then
			draw.RoundedBox(5, 0, 0, w, h, zbl.colors["white02"])
		end
	end
	Lab.VGUI.Mainmenu.Analyze.DoClick = function()

		if zbl.Player.IsResearcher(LocalPlayer()) == false then
			zclib.vgui.Notify(zbl.language.General["Wrong Job"],NOTIFY_ERROR)
			return
	    end

		if zbl.Lab.CanInteract(Lab,LocalPlayer()) == false then
			zclib.vgui.Notify(zbl.language.General["Wrong Owner"],NOTIFY_ERROR)
			return
		end

		if Lab.VGUI and Lab.VGUI.Mainmenu and IsValid(Lab.VGUI.Mainmenu.MainPanel) then
			Lab.VGUI.Mainmenu.MainPanel:Remove()
		end
		Lab:EmitSound("zbl_ui_click")
		zbl.Lab.AnalyzeInterface(Lab)
	end

	Lab.VGUI.Mainmenu.Research = vgui.Create("DButton", Lab.VGUI.Mainmenu.MainPanel)
	Lab.VGUI.Mainmenu.Research:SetPos(205,180)
	Lab.VGUI.Mainmenu.Research:SetSize(240 , 70 )
	Lab.VGUI.Mainmenu.Research:SetAutoDelete(true)
	Lab.VGUI.Mainmenu.Research:SetText("")
	Lab.VGUI.Mainmenu.Research.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.colors["lab_blue_light"])

		draw.SimpleText(zbl.language.General["Create"],  zclib.util.FontSwitch(zbl.language.General["Create"],7,zclib.GetFont("zbl_lab_button_main"),zclib.GetFont("zbl_lab_button_main_small")), 20, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

		surface.SetDrawColor(zbl.colors["abillity_yellow"])
		surface.SetMaterial(zbl.materials["zbl_icon_create"])
		surface.DrawTexturedRect(170, 10, 50,50)

		if s.Hovered then
			draw.RoundedBox(5, 0, 0, w, h, zbl.colors["white02"])
		end
	end
	Lab.VGUI.Mainmenu.Research.DoClick = function()

		if zbl.Player.IsResearcher(LocalPlayer()) == false then
			zclib.vgui.Notify(zbl.language.General["Wrong Job"],NOTIFY_ERROR)
			return
	    end

		if zbl.Lab.CanInteract(Lab,LocalPlayer()) == false then
			zclib.vgui.Notify(zbl.language.General["Wrong Owner"],NOTIFY_ERROR)
			return
		end

		if Lab.VGUI and Lab.VGUI.Mainmenu and IsValid(Lab.VGUI.Mainmenu.MainPanel) then
			Lab.VGUI.Mainmenu.MainPanel:Remove()
		end
		Lab:EmitSound("zbl_ui_click")
		zbl.Lab.VaccineInterface(Lab)
	end
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
//////////////// Analyze //////////////////
////////////////////////////////////////////

// Creates a table of numbers from the SampleSequence
local function CreateSampleSequence(Lab)
	local sequence = Lab:GetSampleSequence()
	sequence = string.Split(sequence,"_" )

	local seq_tbl = {}

	if sequence and #sequence > 0 then
		for k,v in pairs(sequence) do
			local val = tonumber(v)

			seq_tbl[k] = val
		end
	end

	return seq_tbl
end
net.Receive("zbl_Lab_Sample_Update", function(len)
	zclib.Debug("zbl_Lab_Sample_Update len: " .. len)

	local Lab = net.ReadEntity()

	if IsValid(Lab) and Lab.VGUI and Lab.VGUI.Analyze and IsValid(Lab.VGUI.Analyze.MainPanel) then
		zbl.Lab.AnalyzeInterface(Lab)
	end
end)


// Creates the Analyze Interface
function zbl.Lab.AnalyzeInterface(Lab)
	zclib.Debug("Lab_AnalyzeInterface")

	if Lab.VGUI and Lab.VGUI.Analyze and IsValid(Lab.VGUI.Analyze.MainPanel) then
		Lab.VGUI.Analyze.MainPanel:Remove()
	end

	Lab.VGUI.Analyze.MainPanel = vgui.Create("DPanel",Lab.VGUI.Main)
	Lab.VGUI.Analyze.MainPanel:SetPos(0, 0)
	Lab.VGUI.Analyze.MainPanel:SetSize(650, 400)
	Lab.VGUI.Analyze.MainPanel.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w,52, zbl.colors["lab_blue_light"])

		draw.DrawText(zbl.language.General["Analyze"], zclib.GetFont("zbl_gun_font02"), 30 , 15 , color_white, TEXT_ALIGN_LEFT)

		local tw,_ = zclib.util.GetTextSize(zbl.language.General["Analyze"],zclib.GetFont("zbl_gun_font02"))

		surface.SetDrawColor(zbl.colors["cure_green"])
		surface.SetMaterial(zbl.materials["zbl_icon_analyze"])
		surface.DrawTexturedRect(tw + 35, 17, 30,30)
	end


	Lab.VGUI.Analyze.DataPanel = vgui.Create("DPanel", Lab.VGUI.Analyze.MainPanel)
	Lab.VGUI.Analyze.DataPanel:SetPos(50, 60)
	Lab.VGUI.Analyze.DataPanel:SetSize(550, 85)
	Lab.VGUI.Analyze.DataPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.colors["lab_blue_light"])

		draw.DrawText(zbl.language.General["Sample Count"] .. ": ", zclib.GetFont("zbl_lab_analyze_names"), 20, 10, color_white, TEXT_ALIGN_LEFT)
		draw.DrawText(zbl.language.General["Sample Variability"] .. ": ", zclib.GetFont("zbl_lab_analyze_names"), 20, 45, color_white, TEXT_ALIGN_LEFT)

		draw.DrawText(Lab:GetSampleCount(), zclib.GetFont("zbl_lab_analyze_names"), 520, 10, zbl.colors["cure_green"], TEXT_ALIGN_RIGHT)
		draw.DrawText(Lab:GetSampleVariability(), zclib.GetFont("zbl_lab_analyze_names"), 520, 45, zbl.colors["cure_green"], TEXT_ALIGN_RIGHT)
	end


	Lab.VGUI.Analyze.DataResultPanel = vgui.Create("DPanel", Lab.VGUI.Analyze.MainPanel)
	Lab.VGUI.Analyze.DataResultPanel:SetPos(50, 155)
	Lab.VGUI.Analyze.DataResultPanel:SetSize(550, 60)
	Lab.VGUI.Analyze.DataResultPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.colors["lab_blue_light"])

		draw.DrawText(zbl.language.General["Reasearch Points"] .. ": ", zclib.GetFont("zbl_lab_analyze_names"), 20, 15, color_white, TEXT_ALIGN_LEFT)
		draw.DrawText("+" .. Lab:GetReward(), zclib.GetFont("zbl_lab_points"), 520, 12, zbl.colors["sample_blue"], TEXT_ALIGN_RIGHT)

		surface.SetDrawColor(zbl.colors["sample_blue"])
		surface.SetMaterial(zbl.materials["zbl_dna_icon"])
		surface.DrawTexturedRect(400, 5, 50,50)
	end

	Lab.VGUI.Analyze.PointPanel = vgui.Create("DPanel",Lab.VGUI.Analyze.MainPanel)
	Lab.VGUI.Analyze.PointPanel:SetPos(50, 300)
	Lab.VGUI.Analyze.PointPanel:SetSize(150, 60)
	Lab.VGUI.Analyze.PointPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w,h, zbl.colors["lab_blue_light"])

		draw.DrawText(zbl.DNASystem.Get(LocalPlayer()), zclib.GetFont("zbl_lab_points"), 90, 12, color_white, TEXT_ALIGN_CENTER)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(zbl.materials["zbl_dna_icon"])
		surface.DrawTexturedRect(0, 0, 60,60)
	end

	local IsRightClickDown = false

	local seq = CreateSampleSequence(Lab)
	Lab.VGUI.Analyze.FlaskButtons = {}

	for i = 1, 12 do
		local bttn_val = seq[i] or -1
		local bttn = vgui.Create("DButton", Lab.VGUI.Analyze.MainPanel)
		bttn:SetPos(4 + (46.5 * i), 225)
		bttn:SetSize(40, 40)
		bttn:SetAutoDelete(true)
		bttn:SetText("")
		bttn.DNAVal = bttn_val
		bttn.Index = i
		bttn.Paint = function(s, w, h)
			if s.DNAVal > -1 then
				if s.DNAVal > 0 then
					surface.SetDrawColor(zbl.colors["sample_blue"])
				else
					surface.SetDrawColor(zbl.colors["virus_red"])
				end
			else
				surface.SetDrawColor(zbl.colors["black03"])
			end
			surface.SetMaterial(zbl.materials["zbl_hexagon_icon"])
			surface.DrawTexturedRect(0, 0, w,h)

			if s.DNAVal > -1 then

				if s.Hovered then
					surface.SetDrawColor(zbl.colors["white02"])
					surface.SetMaterial(zbl.materials["zbl_hexagon_icon"])
					surface.DrawTexturedRect(0, 0, w,h)

					local scale = w * 0.8
					surface.SetDrawColor(zbl.colors["white07"])
					surface.SetMaterial(zbl.materials["zbl_cursor"])
					surface.DrawTexturedRectRotated((w * 0.1) + (scale / 2),(w * 0.1) + (scale / 2), scale,scale,45)
				else
					draw.SimpleText(s.DNAVal, zclib.GetFont("zbl_lab_analyze_names"), w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
		end
		bttn.DoClick = function()
			if bttn.DNAVal > -1 then
				Lab:EmitSound("zbl_ui_click")
				zbl.Lab.RemoveSample(Lab,bttn.Index)
				 bttn.DNAVal = -1
			end
		end

		Lab.VGUI.Analyze.FlaskButtons[i] = bttn
	end

	local ply = LocalPlayer()
	local NetWait = CurTime() + 0.7
	local function CollectSampleFromScreen()
		if NetWait > CurTime() then return end
		if not IsValid(Lab) then return end
		if Lab.VGUI == nil then return end
		if Lab.VGUI.Analyze == nil then return end
		if Lab.VGUI.Analyze.FlaskButtons == nil or table.Count(Lab.VGUI.Analyze.FlaskButtons) <= 0 then return end

		if not IsValid(ply) then return end
		if ply:Alive() == false then return end

		local swep = ply:GetActiveWeapon()
		if not IsValid(swep) then return end
		if swep:GetClass() ~= "zbl_gun" then return end
		if IsRightClickDown == false and input.IsMouseDown(MOUSE_RIGHT) == true then
			local empty_flask = zbl.Injector.GetEmptyFlask(swep)
			if empty_flask == nil then
				zclib.vgui.Notify(zbl.language.Gun["GunIsFull"],NOTIFY_ERROR)
			else
				for k,v in pairs(Lab.VGUI.Analyze.FlaskButtons) do
					if IsValid(v) and v.Hovered then
						// Send net message to server
						zbl.Lab.CollectSample(Lab,v.Index)
						NetWait = CurTime() + 0.7
						break
					end
				end
			end
		end
	end

	Lab.VGUI.Analyze.AnalyzeSamples = vgui.Create("DButton", Lab.VGUI.Analyze.MainPanel)
	Lab.VGUI.Analyze.AnalyzeSamples:SetPos(340,280)
	Lab.VGUI.Analyze.AnalyzeSamples:SetSize(260 , 80 )
	Lab.VGUI.Analyze.AnalyzeSamples:SetAutoDelete(true)
	Lab.VGUI.Analyze.AnalyzeSamples:SetText("")
	Lab.VGUI.Analyze.AnalyzeSamples.Paint = function(s, w, h)

		// This will handle the logic for collecting samples from the lab with the injector gun directly
		CollectSampleFromScreen()
		IsRightClickDown = input.IsMouseDown(MOUSE_RIGHT)

		draw.RoundedBox(5, 0, 0, w, h, zbl.colors["lab_blue_light"])

		local time = zbl.config.GenLab.time_per_sample * Lab:GetSampleCount()
		time = time * zbl.Lab.GetTimeModify(LocalPlayer())
		time = zclib.util.FormatTime(time)

		local tw,_ = zclib.util.GetTextSize(time,zclib.GetFont("zbl_lab_analyze_names"))

		draw.SimpleText(time, zclib.GetFont("zbl_lab_analyze_names"), 115, h / 2, zbl.colors["abillity_yellow"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		surface.SetDrawColor(zbl.colors["abillity_yellow"])
		surface.SetMaterial(zbl.materials["zbl_icon_time"])
		surface.DrawTexturedRect((115 - tw / 2) - 35, 30, 25,25)

		surface.SetDrawColor(zbl.colors["cure_green"])
		surface.SetMaterial(zbl.materials["zbl_icon_analyze"])
		surface.DrawTexturedRect(w-70, 10, 60,60)


		if s.Hovered then
			draw.RoundedBox(5, 0, 0, w, h, zbl.colors["white02"])
		end
	end
	Lab.VGUI.Analyze.AnalyzeSamples.DoClick = function()
		zbl.Lab.AnalyzeSamples(Lab)
		Lab:EmitSound("zbl_ui_click")
	end


	Lab.VGUI.Analyze.RemoveSamples = vgui.Create("DButton", Lab.VGUI.Analyze.MainPanel)
	Lab.VGUI.Analyze.RemoveSamples:SetPos(230 , 280 ) //410
	Lab.VGUI.Analyze.RemoveSamples:SetSize(80 , 80 )
	Lab.VGUI.Analyze.RemoveSamples:SetAutoDelete(true)
	Lab.VGUI.Analyze.RemoveSamples:SetText("")
	Lab.VGUI.Analyze.RemoveSamples.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.colors["lab_blue_light"])

		surface.SetDrawColor(zbl.colors["virus_red"])
		surface.SetMaterial(zbl.materials["zbl_icon_remove"])
		surface.DrawTexturedRect(10, 10, 60,60)

		if s.Hovered then
			draw.RoundedBox(5, 0, 0, w, h, zbl.colors["white02"])
		end
	end
	Lab.VGUI.Analyze.RemoveSamples.DoClick = function()
		zbl.Lab.RemoveSamples(Lab)
		Lab:EmitSound("zbl_ui_click")
	end




	Lab.VGUI.Analyze.BackToMain = vgui.Create("DButton", Lab.VGUI.Analyze.MainPanel)
	Lab.VGUI.Analyze.BackToMain:SetPos(608 , 15 )
	Lab.VGUI.Analyze.BackToMain:SetSize(30 , 30 )
	Lab.VGUI.Analyze.BackToMain:SetAutoDelete(true)
	Lab.VGUI.Analyze.BackToMain:SetText("")
	Lab.VGUI.Analyze.BackToMain.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.colors["virus_red"])

		surface.SetDrawColor(color_white)
		surface.SetMaterial(zbl.materials["zbl_icon_close"])
		surface.DrawTexturedRect(5, 5, 20,20)

		if s.Hovered then
			draw.RoundedBox(5, 0, 0, w, h, zbl.colors["white02"])
		end
	end
	Lab.VGUI.Analyze.BackToMain.DoClick = function()
		if Lab.VGUI and Lab.VGUI.Analyze and IsValid(Lab.VGUI.Analyze.MainPanel) then
			Lab.VGUI.Analyze.MainPanel:Remove()
		end
		zbl.Lab.MainMenu(Lab)
		Lab:EmitSound("zbl_ui_click")
	end
end

function zbl.Lab.AnalyzeSamples(Lab)

	if Lab:GetSampleCount() <= 0 then
		zclib.vgui.Notify(zbl.language.General["NotEnoughSamples"],NOTIFY_ERROR)
		return
	end

	net.Start("zbl_Lab_AnalyzeSample_Request")
	net.WriteEntity(Lab)
	net.SendToServer()
end

// Removes all samples
function zbl.Lab.RemoveSamples(Lab)

	if Lab:GetSampleCount() <= 0 then
		zclib.vgui.Notify(zbl.language.General["NotEnoughSamples"],NOTIFY_ERROR)
		return
	end

	net.Start("zbl_Lab_RemoveSamples")
	net.WriteEntity(Lab)
	net.SendToServer()
end

// Removes a specific sample
function zbl.Lab.RemoveSample(Lab,index)

	net.Start("zbl_Lab_Sample_Remove")
	net.WriteEntity(Lab)
	net.WriteInt(index,6)
	net.SendToServer()
end

// Collects a specific sample from the lab to the players injector gun
function zbl.Lab.CollectSample(Lab,index)

	net.Start("zbl_Lab_Sample_Collect")
	net.WriteEntity(Lab)
	net.WriteInt(index,6)
	net.SendToServer()
end
////////////////////////////////////////////
////////////////////////////////////////////





////////////////////////////////////////////
//////////////// Vaccines //////////////////
////////////////////////////////////////////
// Creates the Main Interface
function zbl.Lab.VaccineInterface(Lab)
	zclib.Debug("Lab_VaccineInterface")

	if Lab.VGUI and Lab.VGUI.Research and IsValid(Lab.VGUI.Research.MainPanel) then
		Lab.VGUI.Research.MainPanel:Remove()
	end

	Lab.VGUI.Research.MainPanel = vgui.Create("DPanel",Lab.VGUI.Main)
	Lab.VGUI.Research.MainPanel:SetPos(0, 0)
	Lab.VGUI.Research.MainPanel:SetSize(650, 400)
	Lab.VGUI.Research.MainPanel.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w,52, zbl.colors["lab_blue_light"])

		draw.DrawText(zbl.language.General["Create"], zclib.GetFont("zbl_gun_font02"), 30 , 15 , color_white, TEXT_ALIGN_LEFT)

		local tw,_ = zclib.util.GetTextSize(zbl.language.General["Create"],zclib.GetFont("zbl_gun_font02"))

		surface.SetDrawColor(zbl.colors["abillity_yellow"])
		surface.SetMaterial(zbl.materials["zbl_icon_create"])
		surface.DrawTexturedRect(tw + 35, 17, 30,30)
	end


	Lab.VGUI.Research.PointPanel = vgui.Create("DPanel",Lab.VGUI.Research.MainPanel)
	Lab.VGUI.Research.PointPanel:SetPos(050, 300)
	Lab.VGUI.Research.PointPanel:SetSize(150, 60)
	Lab.VGUI.Research.PointPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w,h, zbl.colors["lab_blue_light"])

		draw.DrawText(zbl.DNASystem.Get(LocalPlayer()), zclib.GetFont("zbl_lab_points"), 90, 12, color_white, TEXT_ALIGN_CENTER)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(zbl.materials["zbl_dna_icon"])
		surface.DrawTexturedRect(0, 0, 60,60)
	end

	// Creates a side buttons for each 9 vaccines in the conifg
	Lab.VGUI.Research.VaccineListButtons = {}
	for i = 1,math.ceil(zbl.Vaccine.GetCount() / 6) do
		local butt = vgui.Create("DButton", Lab.VGUI.Research.MainPanel)

		butt:SetPos(19.5 , 60 + (i * 30) - 30 )
		butt:SetSize(25 , 25 )
		butt:SetAutoDelete(true)
		butt:SetText("")
		butt.Paint = function(s, w, h)
			if i ~= Lab.VaccineListID then
				draw.RoundedBox(5, 0, 0, w, h, zbl.colors["lab_blue_light"])
			else
				draw.RoundedBox(5, 0, 0, w, h, zbl.colors["lab_blue_light"])

				surface.SetDrawColor(color_white)
				surface.SetMaterial(zbl.materials["zbl_ex_square"])
				surface.DrawTexturedRect(0, 0, w, h)
			end

			draw.DrawText(i, zclib.GetFont("zbl_lab_create_category"), 12 , 3 , color_white, TEXT_ALIGN_CENTER)

			if s.Hovered then
				draw.RoundedBox(5, 0, 0, w, h, zbl.colors["white02"])
			end
		end
		butt.DoClick = function()
			// Create list with defined ending number i * 6
			zbl.Lab.VaccineList(Lab, math.Clamp(i * 6 - 5, 1, zbl.Vaccine.GetCount()))
			Lab.VaccineListID = i
			Lab:EmitSound("zbl_ui_click")
		end

		Lab.VGUI.Research.VaccineListButtons[i] = butt
	end

	Lab.VGUI.Research.BackToMain = vgui.Create("DButton", Lab.VGUI.Research.MainPanel)
	Lab.VGUI.Research.BackToMain:SetPos(608 , 15 )
	Lab.VGUI.Research.BackToMain:SetSize(30 , 30 )
	Lab.VGUI.Research.BackToMain:SetAutoDelete(true)
	Lab.VGUI.Research.BackToMain:SetText("")
	Lab.VGUI.Research.BackToMain.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.colors["virus_red"])

		surface.SetDrawColor(color_white)
		surface.SetMaterial(zbl.materials["zbl_icon_close"])
		surface.DrawTexturedRect(5, 5, 20,20)

		if s.Hovered then
			draw.RoundedBox(5, 0, 0, w, h, zbl.colors["white02"])
		end
	end
	Lab.VGUI.Research.BackToMain.DoClick = function()
		if Lab.VGUI and Lab.VGUI.Research and IsValid(Lab.VGUI.Research.MainPanel) then
			Lab.VGUI.Research.MainPanel:Remove()
		end

		Lab:EmitSound("zbl_ui_click")

		Lab.VaccineListID = 1

		zbl.Lab.MainMenu(Lab)
	end

	zbl.Lab.VaccineList(Lab,1)
	zbl.Lab.VaccineInfo(Lab,1)
end

// Used for creating a line break in centerd text
local function DrawTextCentered_LineBreak(w, h, txt)
	if string.len(txt) > 12 then
		local _start, _end = string.find(txt, " ", 1, false)

		if _start then
			draw.SimpleText(string.sub(txt, 1, _start), zclib.GetFont("zbl_lab_item_name"), w / 2, h - 30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(string.sub(txt, _start + 1, string.len(txt)), zclib.GetFont("zbl_lab_item_name"), w / 2, h - 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(txt, zclib.GetFont("zbl_lab_item_name"), w / 2, h - 25, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	else
		draw.SimpleText(txt, zclib.GetFont("zbl_lab_item_name"), w / 2, h - 25, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

// Creates the list of all the vaccines the user can create
function zbl.Lab.VaccineList(Lab,starting_id)

	zclib.Debug("Lab_VaccineList")
	if IsValid(Lab) and IsValid(Lab.VGUI.Research.ResearchPanel) then
		Lab.VGUI.Research.ResearchPanel:Remove()
	end

	Lab.VGUI.Research.ResearchPanel = vgui.Create("DPanel",Lab.VGUI.Research.MainPanel)
	Lab.VGUI.Research.ResearchPanel:SetPos(50, 60)
	Lab.VGUI.Research.ResearchPanel:SetSize(300, 205)
	Lab.VGUI.Research.ResearchPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0 , 0, w, h,  zbl.colors["lab_blue_light"])
	end


	Lab.VGUI.Research.scrollpanel = vgui.Create("DScrollPanel", Lab.VGUI.Research.ResearchPanel)
	Lab.VGUI.Research.scrollpanel:DockMargin(10 , 10 , 10 , 10 )
	Lab.VGUI.Research.scrollpanel:Dock(FILL)
	Lab.VGUI.Research.scrollpanel:GetVBar().Paint = function() return true end
	Lab.VGUI.Research.scrollpanel:GetVBar().btnUp.Paint = function() return true end
	Lab.VGUI.Research.scrollpanel:GetVBar().btnDown.Paint = function() return true end
	Lab.VGUI.Research.scrollpanel.Paint = function(s, w, h)
	end



	// Here we create the Research items buttons
	if Lab.VGUI.Research.ResearchItems and IsValid(Lab.VGUI.Research.ResearchItems.list) then
		Lab.VGUI.Research.ResearchItems.list:Remove()
	end

	Lab.VGUI.Research.ResearchItems = {}
	Lab.VGUI.Research.ResearchItems.list = vgui.Create("DIconLayout", Lab.VGUI.Research.scrollpanel)
	Lab.VGUI.Research.ResearchItems.list:SetSize(285 , 285 )
	Lab.VGUI.Research.ResearchItems.list:SetPos(0 , 0 )
	Lab.VGUI.Research.ResearchItems.list:SetSpaceY(5)
	Lab.VGUI.Research.ResearchItems.list:SetSpaceX(5)
	Lab.VGUI.Research.ResearchItems.list:SetAutoDelete(true)
	Lab.VGUI.Research.ResearchItems.list.Paint = function(s, w, h)
	end


	for i = 1,zbl.Vaccine.GetCount() do
		if i < starting_id then continue end
		if i >= starting_id + 6 then continue end

		Lab.VGUI.Research.ResearchItems[i] = Lab.VGUI.Research.ResearchItems.list:Add("DPanel")
		Lab.VGUI.Research.ResearchItems[i]:SetSize(90, 90 )
		Lab.VGUI.Research.ResearchItems[i]:SetAutoDelete(true)
		Lab.VGUI.Research.ResearchItems[i].Locked = zbl.Vaccine.CanResearch(LocalPlayer(),i,Lab.SelectedIsCure) == false
		Lab.VGUI.Research.ResearchItems[i].Paint = function(s, w, h)

			if zbl.Vaccine.IsVirus(i) then
				draw.RoundedBox(12, 0, 0, w, h, zbl.colors["virus_red"])
			else
				draw.RoundedBox(12, 0, 0, w, h, zbl.colors["abillity_yellow"])
			end

			if s.Locked then
				surface.SetDrawColor(color_white)
				surface.SetMaterial(zbl.materials["zbl_icon_locked"])
				surface.DrawTexturedRect(20, 5, 50, 50)
			else
				if zbl.Vaccine.IsVirus(i) then
					surface.SetDrawColor(color_white)
					surface.SetMaterial(zbl.materials["zbl_virus_icon"])
					surface.DrawTexturedRect(20, 0, 50, 50)
				else
					surface.SetDrawColor(color_white)
					surface.SetMaterial(zbl.materials["zbl_abillity_icon"])
					surface.DrawTexturedRect(20, 0, 50, 50)
				end
			end

			if s.Locked then
				draw.RoundedBox(12, 0, 0, w, h, zbl.colors["black02"])
			end

			DrawTextCentered_LineBreak(w, h, zbl.Vaccine.GetName(i))
		end

		Lab.VGUI.Research.ResearchItems[i].RButton = vgui.Create("DButton", Lab.VGUI.Research.ResearchItems[i])
		Lab.VGUI.Research.ResearchItems[i].RButton:SetSize(90, 90 )
		Lab.VGUI.Research.ResearchItems[i].RButton:SetPos(0, 0)
		Lab.VGUI.Research.ResearchItems[i].RButton:SetAutoDelete(true)
		Lab.VGUI.Research.ResearchItems[i].RButton:SetText("")
		Lab.VGUI.Research.ResearchItems[i].RButton.Paint = function(s, w, h)

			if i == Lab.VaccineID then
				surface.SetDrawColor(color_white)
				surface.SetMaterial(zbl.materials["zbl_ex_square"])
				surface.DrawTexturedRect(0, 0, w, h)
			end

			if s.Hovered then
				draw.RoundedBox(12, 0, 0, w, h, zbl.colors["white02"])
			end
		end
		Lab.VGUI.Research.ResearchItems[i].RButton.DoClick = function()

			if not zbl.Vaccine.CanResearch(LocalPlayer(),i,Lab.SelectedIsCure,true) then return end

			Lab:EmitSound("zbl_ui_click")
			zbl.Lab.VaccineInfo(Lab,i)
		end
	end

	zbl.Lab.VaccineInfo(Lab,starting_id)
end

function zbl.Lab.VaccineInfo(Lab,vaccineID)

	zclib.Debug("Lab_VaccineInfo")
	if IsValid(Lab) and IsValid(Lab.VGUI.Research.VaccineInfo) then
		Lab.VGUI.Research.VaccineInfo:Remove()
	end

	Lab.VGUI.Research.VaccineInfo = vgui.Create("DPanel",Lab.VGUI.Research.MainPanel)
	Lab.VGUI.Research.VaccineInfo:SetPos(360, 60)
	Lab.VGUI.Research.VaccineInfo:SetSize(280, 320)
	Lab.VGUI.Research.VaccineInfo.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h * 0.35, zbl.colors["lab_blue_light"])
	end

	local vaccine_name = vgui.Create("DLabel", Lab.VGUI.Research.VaccineInfo)
	vaccine_name:SetSize(290, 35)
	vaccine_name:SetPos(5, 0)
	vaccine_name:SetAutoDelete(true)
	vaccine_name:SetFont(zclib.GetFont("zbl_gun_font02"))
	vaccine_name:SetText(zbl.Vaccine.GetName(vaccineID))
	if zbl.Vaccine.IsVirus(vaccineID) then
		vaccine_name:SetTextColor(zbl.colors["virus_red"])
	else
		vaccine_name:SetTextColor(zbl.colors["abillity_yellow"])
	end
	vaccine_name:SetContentAlignment(7)
	vaccine_name:SetWrap(true)
	Lab.VGUI.Research.VaccineInfo_NamePanel = vaccine_name


	local desc = zbl.Vaccine.GetDescription(vaccineID)
	if Lab.SelectedIsCure then
		desc = zbl.language.General["Cure_desc"]
		desc = string.Replace(desc,"$VaccineName",zbl.Vaccine.GetName(vaccineID))
		desc = string.Replace(desc,"$ImmunityTime",zclib.util.FormatTime(zbl.Vaccine.GetCure_Time(vaccineID)))
	end
	local vaccine_desc = vgui.Create("DLabel", Lab.VGUI.Research.VaccineInfo)
	vaccine_desc:SetSize(270, 50)
	vaccine_desc:SetPos(5, 40)
	vaccine_desc:SetAutoDelete(true)
	vaccine_desc:SetFont(zclib.GetFont("zbl_lab_create_category"))
	vaccine_desc:SetText(desc)
	vaccine_desc:SetContentAlignment(7)
	vaccine_desc:SetWrap(true)
	Lab.VGUI.Research.VaccineInfo_DescPanel = vaccine_desc

	Lab.VaccineID = vaccineID

	zbl.Lab.CreateVaccinePanel(Lab,false)
end

function zbl.Lab.CreateVaccinePanel(Lab,iscure)
	zclib.Debug("Lab_CreateVaccinePanel")

	Lab.SelectedIsCure = iscure

	if Lab.SelectedIsCure then
		Lab.ItemColor = zbl.colors["cure_green"]
	else
		if zbl.Vaccine.IsVirus(Lab.VaccineID) then
			Lab.ItemColor = zbl.colors["virus_red"]
		else
			Lab.ItemColor = zbl.colors["abillity_yellow"]
		end
	end

	// Update Vaccine Name Color
	if IsValid(Lab.VGUI.Research.VaccineInfo_NamePanel) then
		Lab.VGUI.Research.VaccineInfo_NamePanel:SetTextColor(Lab.ItemColor)
	end

	// Update the Vaccine Desc if its a Cure or not
	if IsValid(Lab.VGUI.Research.VaccineInfo_DescPanel) then
		local desc = zbl.Vaccine.GetDescription(Lab.VaccineID)
		if Lab.SelectedIsCure then
			desc = zbl.language.General["Cure_desc"]
			desc = string.Replace(desc,"$VaccineName",zbl.Vaccine.GetName(Lab.VaccineID))
			desc = string.Replace(desc,"$ImmunityTime",zclib.util.FormatTime(zbl.Vaccine.GetCure_Time(Lab.VaccineID)))
		end
		Lab.VGUI.Research.VaccineInfo_DescPanel:SetText(desc)
	end

	if IsValid(Lab) and IsValid(Lab.VGUI.Research.VaccineInfoPanel) then
		Lab.VGUI.Research.VaccineInfoPanel:Remove()
	end

	Lab.VGUI.Research.VaccineInfoPanel = vgui.Create("DPanel",Lab.VGUI.Research.VaccineInfo)
	Lab.VGUI.Research.VaccineInfoPanel:SetPos(0, 125)
	Lab.VGUI.Research.VaccineInfoPanel:SetSize(280, 175)
	Lab.VGUI.Research.VaccineInfoPanel.Paint = function(s, w, h)
		draw.RoundedBox(0, 0 , 40, w, h-40,  zbl.colors["lab_blue_light"])
		draw.RoundedBox(0, 0, 30, w, 10, Lab.ItemColor)
	end

	local button_vac = vgui.Create("DButton", Lab.VGUI.Research.VaccineInfoPanel)
	button_vac:SetPos(0,0)
	button_vac:SetSize(30 , 30 )
	button_vac:SetAutoDelete(true)
	button_vac:SetText("")
	button_vac.Paint = function(s, w, h)
		if zbl.Vaccine.IsVirus(Lab.VaccineID) then
			draw.RoundedBox(0, 0, 0, w, h, zbl.colors["virus_red"])

			surface.SetDrawColor(color_white)
			surface.SetMaterial(zbl.materials["zbl_virus_icon"])
			surface.DrawTexturedRect(0, 0, w, h)
		else
			draw.RoundedBox(0, 0, 0, w, h, zbl.colors["abillity_yellow"])

			surface.SetDrawColor(color_white)
			surface.SetMaterial(zbl.materials["zbl_abillity_icon"])
			surface.DrawTexturedRect(0, 0, w, h)
		end



		if s.Hovered then
			draw.RoundedBox(0, 0, 0, w, h, zbl.colors["white02"])
		end
	end
	button_vac.DoClick = function()
		zbl.Lab.CreateVaccinePanel(Lab,false)
		Lab:EmitSound("zbl_ui_click")
	end
	Lab.VGUI.Research.SelectVaccineCreation = button_vac

	if zbl.Vaccine.GetResearch_CurePoints(Lab.VaccineID) > 0 then
		local button_cure = vgui.Create("DButton", Lab.VGUI.Research.VaccineInfoPanel)
		button_cure:SetPos(30,0)
		button_cure:SetSize(30 , 30 )
		button_cure:SetAutoDelete(true)
		button_cure:SetText("")
		button_cure.Paint = function(s, w, h)
			draw.RoundedBox(0, 0, 0, w, h, zbl.colors["cure_green"])

			surface.SetDrawColor(color_white)
			surface.SetMaterial(zbl.materials["zbl_cure_icon"])
			surface.DrawTexturedRect(0, 0, w, h)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

			if s.Hovered then
				draw.RoundedBox(0, 0, 0, w, h, zbl.colors["white02"])
			end
		end
		button_cure.DoClick = function()
			zbl.Lab.CreateVaccinePanel(Lab,true)
			Lab:EmitSound("zbl_ui_click")
		end
		Lab.VGUI.Research.SelectCureCreation = button_cure
	end

	local res_time
	local res_points

	if Lab.SelectedIsCure then
		res_time = zbl.Vaccine.GetResearch_CureTime(Lab.VaccineID)
		res_points = zbl.Vaccine.GetResearch_CurePoints(Lab.VaccineID)
	else
		res_time = zbl.Vaccine.GetResearch_VaccineTime(Lab.VaccineID)
		res_points = zbl.Vaccine.GetResearch_VaccinePoints(Lab.VaccineID)
	end
	res_time = res_time * zbl.Lab.GetTimeModify(LocalPlayer())

	local vaccine_time = vgui.Create("DPanel", Lab.VGUI.Research.VaccineInfoPanel)
	vaccine_time:SetSize(110, 50)
	vaccine_time:SetPos(15, 65)
	vaccine_time:SetAutoDelete(true)
	vaccine_time.Paint = function(s, w, h)
		draw.DrawText(zclib.util.FormatTime(res_time), zclib.GetFont("zbl_gun_font02"), 35 , -3 , zbl.colors["abillity_yellow"], TEXT_ALIGN_LEFT)

		surface.SetDrawColor(zbl.colors["abillity_yellow"])
		surface.SetMaterial(zbl.materials["zbl_icon_time"])
		surface.DrawTexturedRect(0, 0, 25,25)
	end
	Lab.VGUI.Research.VaccineInfo_TimePanel = vaccine_time

	local vaccine_points = vgui.Create("DPanel", Lab.VGUI.Research.VaccineInfoPanel)
	vaccine_points:SetSize(100, 50)
	vaccine_points:SetPos(15, 120)
	vaccine_points:SetAutoDelete(true)
	vaccine_points.Paint = function(s, w, h)
		draw.DrawText(res_points, zclib.GetFont("zbl_gun_font02"), 35 , -3 , zbl.colors["sample_blue"], TEXT_ALIGN_LEFT)

		surface.SetDrawColor(zbl.colors["sample_blue"])
		surface.SetMaterial(zbl.materials["zbl_dna_icon"])
		surface.DrawTexturedRect(-12, -10, 50,50)
	end
	Lab.VGUI.Research.VaccineInfo_PointPanel = vaccine_points

	Lab.VGUI.Research.CreateButton = vgui.Create("DButton", Lab.VGUI.Research.VaccineInfoPanel)
	Lab.VGUI.Research.CreateButton:SetPos(170,135)
	Lab.VGUI.Research.CreateButton:SetSize(100 , 30 )
	Lab.VGUI.Research.CreateButton:SetAutoDelete(true)
	Lab.VGUI.Research.CreateButton:SetText("")
	Lab.VGUI.Research.CreateButton.Paint = function(s, w, h)
		surface.SetDrawColor(Lab.ItemColor)
		surface.SetMaterial(zbl.materials["zbl_ex_square_wide"])
		surface.DrawTexturedRect(0, 0, w, h)

		draw.DrawText(zbl.language.General["Create"], zclib.GetFont("zbl_lab_create_bold"), w / 2 , 5 , Lab.ItemColor, TEXT_ALIGN_CENTER)

		if s.Hovered then
			draw.RoundedBox(5, 0, 0, w, h, zbl.colors["white02"])
		end
	end
	Lab.VGUI.Research.CreateButton.DoClick = function()
		if Lab.SelectedIsCure then
			zbl.Lab.CreateCure(Lab)
		else
			zbl.Lab.CreateVaccine(Lab)
		end
		Lab:EmitSound("zbl_ui_click")
	end
end

function zbl.Lab.CreateVaccine(Lab)
	zclib.Debug("Lab_CreateVaccine")

	if not zbl.Vaccine.CanResearch(LocalPlayer(),Lab.VaccineID,Lab.SelectedIsCure,true) then return end

	if zbl.DNASystem.Get(LocalPlayer()) < zbl.Vaccine.GetResearch_VaccinePoints(Lab.VaccineID) then
		zclib.vgui.Notify(zbl.language.General["NotEnoughDNA"],NOTIFY_ERROR)
		return
	end

	net.Start("zbl_Lab_CreateVaccine")
	net.WriteEntity(Lab)
	net.WriteInt(Lab.VaccineID, 16)
	net.SendToServer()
end

function zbl.Lab.CreateCure(Lab)
	zclib.Debug("Lab_CreateCure")

	if not zbl.Vaccine.CanResearch(LocalPlayer(),Lab.VaccineID,Lab.SelectedIsCure,true) then return end

	if zbl.DNASystem.Get(LocalPlayer()) < zbl.Vaccine.GetResearch_CurePoints(Lab.VaccineID) then
		zclib.vgui.Notify(zbl.language.General["NotEnoughDNA"],NOTIFY_ERROR)
		return
	end

	net.Start("zbl_Lab_CreateCure")
	net.WriteEntity(Lab)
	net.WriteInt(Lab.VaccineID, 16)
	net.SendToServer()
end
////////////////////////////////////////////
////////////////////////////////////////////
