AddCSLuaFile("cl_init.lua")

AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel(MININGSYSTEM.CraftingTableModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

end
crafting_tables = {}
local NextUse = 0
function ENT:Use(activator, caller)
	crafting_tables[caller] = self
	if CurTime() < NextUse then return end 
	if (caller:IsPlayer()) then
		net.Start( "OpenCraftingMenu" )
		net.Send(caller)
		NextUse = CurTime() + 2
	end
end