include("shared.lua")

function ENT:Draw()
	self:DrawModel()

    Nexus:Overhead(self, "Battlepass")
end