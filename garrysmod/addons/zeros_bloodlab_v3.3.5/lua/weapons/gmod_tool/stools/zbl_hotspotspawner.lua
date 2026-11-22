/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

AddCSLuaFile()

TOOL.Category = "Zeros GenLab"
TOOL.Name = "#Hotspot Spawner"
TOOL.Command = nil


if (CLIENT) then
	language.Add("tool.zbl_hotspotspawner.name", "Zeros GenLab - Virus Hotspot Spawner")
	language.Add("tool.zbl_hotspotspawner.desc", "LeftClick: Creates a Virus HotSpot. \nRightClick: Removes a Virus HotSpot.")
	language.Add("tool.zbl_hotspotspawner.0", "LeftClick: Creates a Virus HotSpot.")
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

function TOOL:LeftClick(trace)
	local trEnt = trace.Entity

	if trEnt:IsPlayer() then return false end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

	if (CLIENT) then return end

	if (trEnt:GetClass() == "worldspawn") then

		if trace.Hit and trace.HitPos and zclib.util.InDistance(trace.HitPos, self:GetOwner():GetPos(), 3000) and zclib.Player.IsAdmin(self:GetOwner()) then
			local _ang = trace.HitNormal:Angle()
			_ang:RotateAroundAxis(_ang:Right(), -90)
			zbl.HotSpot.AddPos(trace.HitPos, _ang,self:GetOwner())
		end

		return true
	else
		return false
	end
end

function TOOL:RightClick(trace)
	if (trace.Entity:IsPlayer()) then return false end
	if (CLIENT) then return end

	if trace.Hit and trace.HitPos then
		if zclib.util.InDistance(trace.HitPos, self:GetOwner():GetPos(), 3000) and zclib.Player.IsAdmin(self:GetOwner()) then

			zbl.HotSpot.RemovePos(trace.HitPos, self:GetOwner())

			zbl.Node.CNP_RemovePos(trace.HitPos, self:GetOwner())
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

		return true
	else
		return false
	end
end

function TOOL:Deploy()
	if SERVER then
		local ply = self:GetOwner()
		timer.Simple(0.25,function()
			if IsValid(ply) and zclib.Player.IsAdmin(ply) then
				zbl.HotSpot.ShowAll(ply)
				zbl.Node.CNP_Show(ply)
			end
		end)
	end
end

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {
		Text = "#tool.zbl_hotspotspawner.name",
		Description = "#tool.zbl_hotspotspawner.desc"
	})

	CPanel:AddControl("label", {
		Text = "Saves all the HotSpot points that are currently on the Map"
	})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

	CPanel:Button("Save HotSpot points", "zbl_debug_VHS_SavePos")

	CPanel:AddControl("label", {
		Text = " "
	})
	CPanel:AddControl("label", {
		Text = "Removes all the HotSpot points that are currently on the Map"
	})

	CPanel:Button("Remove all HotSpot points", "zbl_debug_VHS_RemovePos")
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c
