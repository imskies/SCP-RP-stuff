/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PrintName = "Base Ingredient"
ENT.Author = "ClemensProduction aka Zerochain"
ENT.Information = "info"
ENT.Category = "Zeros PizzaMaker"
ENT.Model = "models/props_borealis/bluebarrel001.mdl"
ENT.AutomaticFrameAdvance = true
ENT.DisableDuplicator = false
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 02d4e064402d16696deab5b093c9a34ae7a407e6165a08b9f87e1e597f153041
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "IngredientID")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350945

	if (SERVER) then
		self:SetIngredientID(-1)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 17dc2f80cf0594471955ed2fce132d0271ce6541c38902a33a4148308c414a4d
