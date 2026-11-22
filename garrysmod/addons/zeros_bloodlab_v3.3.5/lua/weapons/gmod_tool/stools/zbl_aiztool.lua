/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

AddCSLuaFile()

TOOL.Category = "Zeros GenLab"
TOOL.Name = "#Anti Infection Zone"
TOOL.Command = nil
TOOL.ClientConVar["ZoneRadius"] = 500

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

if (CLIENT) then
	language.Add("tool.zbl_aiztool.name", "Zeros GenLab - Anti Infection Zone")
	language.Add("tool.zbl_aiztool.desc", "LeftClick: Creates a Anti Infection Zone. \nRightClick: Removes a Anti Infection Zone.")
	language.Add("tool.zbl_aiztool.0", "LeftClick: Creates a Anti Infection Zone.")
end


function TOOL:LeftClick(trace)
	local trEnt = trace.Entity

	if trEnt:IsPlayer() then return false end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

	if (CLIENT) then return end

	if (trEnt:GetClass() == "worldspawn") then

		if trace.Hit and trace.HitPos and zclib.util.InDistance(trace.HitPos, self:GetOwner():GetPos(), 3000) and zclib.Player.IsAdmin(self:GetOwner()) then

			local _radius = self:GetClientNumber("ZoneRadius", 3)

			zbl.AIZ.Add(trace.HitPos,_radius,self:GetOwner())
		end

		return true
	else
		return false
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

function TOOL:RightClick(trace)
	if (trace.Entity:IsPlayer()) then return false end
	if (CLIENT) then return end

	if trace.Hit and trace.HitPos then
		if zclib.util.InDistance(trace.HitPos, self:GetOwner():GetPos(), 1000) and zclib.Player.IsAdmin(self:GetOwner()) then
			zbl.AIZ.Remove(trace.HitPos, self:GetOwner(),self:GetClientNumber("ZoneRadius", 3))
		end

		return true
	else
		return false
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

function TOOL:Deploy()
	if SERVER then
		local ply = self:GetOwner()
		timer.Simple(0.25,function()
			if IsValid(ply) and zclib.Player.IsAdmin(ply) then
				zbl.AIZ.Show(ply)
			end
		end)
	end
end

function TOOL:Holster()
	if SERVER then
		zbl.AIZ.Hide(self:GetOwner())
	end
end

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {
		Text = "#tool.zbl_aiztool.name",
		Description = "#tool.zbl_aiztool.desc"
	})


	CPanel:NumSlider("Zone Radius", "zbl_aiztool_ZoneRadius", 100, 2000, 0)


	CPanel:AddControl("label", {
		Text = "Saves all the Anti Infection Zones that are currently on the Map"
	})

	CPanel:Button("Save Anti Infection Zone", "zbl_aiz_save")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

	CPanel:AddControl("label", {
		Text = " "
	})
	CPanel:AddControl("label", {
		Text = "Removes all the Anti Infection Zones that are currently on the Map"
	})

	CPanel:Button("Remove Anti Infection Zones", "zbl_aiz_remove")
end
