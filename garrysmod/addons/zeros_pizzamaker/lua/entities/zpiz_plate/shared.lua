/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PrintName = "Plate"
ENT.Author = "ClemensProduction aka Zerochain"
ENT.Information = "info"
ENT.Category = "Zeros PizzaMaker"
ENT.Model = "models/maxofs2d/hover_plate.mdl"
ENT.DisableDuplicator = false
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "PizzaID")
	self:NetworkVar("Float", 0, "PizzaWaitTime")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- fde1005ae952a630057a2cc575fe1335e7c9809985c0483424501baa23d5a1ad
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

	if (SERVER) then
		self:SetPizzaID(-1)
		self:SetPizzaWaitTime(-1)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ee71cdadb4c1697a1f320cfc75c78c5f0135879a492afb53058e82fcefbc72f0
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ee71cdadb4c1697a1f320cfc75c78c5f0135879a492afb53058e82fcefbc72f0
