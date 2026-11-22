/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if SERVER then return end
zbl = zbl or {}
zbl.AIZ = zbl.AIZ or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

zbl.AIZ.Hints = {}

local function HasToolActive()
	local ply = LocalPlayer()

	if IsValid(ply) and ply:Alive() and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "gmod_tool" then
		local tool = ply:GetTool()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

		if tool and table.Count(tool) > 0 and IsValid(tool.SWEP) and tool.Mode == "zbl_aiztool" and tool.Name == "#Anti Infection Zone" then
			return true
		else
			return false
		end
	else
		return false
	end
end

net.Receive("zbl_aiz_showall", function(len)
	zclib.Debug("zbl_aiz_showall Len: " .. len)

	local dataLength = net.ReadUInt(16)
	local d_Decompressed = util.Decompress(net.ReadData(dataLength))
	local positions = util.JSONToTable(d_Decompressed)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

	zclib.Hook.Remove("PostDrawTranslucentRenderables", "zbl_PostDrawTranslucentRenderables_AIZ")
	if positions then
		zbl.AIZ.Hints = positions

		zclib.Hook.Add("PostDrawTranslucentRenderables", "zbl_PostDrawTranslucentRenderables_AIZ", function(depth, skybox,skybox3d)
			if skybox3d == false then
				if HasToolActive() then

					local tr = LocalPlayer():GetEyeTrace()
					if tr.Hit and not IsValid(tr.Entity) and zclib.util.InDistance(tr.HitPos, LocalPlayer():GetPos(), 3000) then
						local size = LocalPlayer():GetTool():GetClientNumber("ZoneRadius", 3)

						render.SetColorMaterial()
						render.DrawSphere(tr.HitPos, size, 12, 12, zbl.colors["aiz_green"])
						render.DrawWireframeSphere( tr.HitPos, size, 12, 12, zbl.colors["aiz_green"],true )
					end

					for k, v in pairs(zbl.AIZ.Hints) do
						if v then
							local pos = v.pos
							local size = v.radius or 100
							render.SetColorMaterial()
							render.DrawSphere( pos, size, 12,12, zbl.colors["aiz_green"] )
							render.DrawWireframeSphere( pos, size, 12, 12, zbl.colors["aiz_green"],false )
						end
					end
				else
					zclib.Hook.Remove("PostDrawTranslucentRenderables", "zbl_PostDrawTranslucentRenderables_AIZ")
				end
			end
		end)
	end
end)

net.Receive("zbl_aiz_hideall", function(len)
	zbl.AIZ.Hints = {}
	zclib.Hook.Remove("PostDrawTranslucentRenderables", "zbl_PostDrawTranslucentRenderables_AIZ")
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955
