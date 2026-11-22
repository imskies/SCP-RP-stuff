/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

include("shared.lua")


local mat = Material( "zerochain/props_bloodlab/hazmat/zbl_hazmat_skin_colormask" )

function ENT:Initialize()
	local col = zclib.util.ColorToVector(zbl.config.NPC.SkinColor)
	mat:SetVector("$color2", col)
end

function ENT:Draw()
	self:DrawModel()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

	if zclib.Convar.Get("zclib_cl_drawui") == 1 and zclib.util.InDistance(LocalPlayer():GetPos(), self:GetPos(), 500) then
		self:DrawInfo()
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

function ENT:DrawInfo()
	local Pos = self:GetPos() + self:GetUp() * 85
	Pos = Pos + self:GetUp() * math.abs(math.sin(CurTime()) * 1)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

	cam.Start3D2D(Pos, zclib.HUD.GetLookAngles(), 0.1)
		draw.SimpleText(zbl.config.NPC.name, zclib.GetFont("zbl_npc_title"), 0, 0, zbl.colors["grey01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(zbl.config.NPC.name, zclib.GetFont("zbl_npc_title"), 2, 2, zbl.config.NPC.SkinColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
