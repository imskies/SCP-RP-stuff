/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

local ITEM = XeninInventory:CreateItemV2()
ITEM:SetMaxStack(1)
ITEM:SetModel("models/zerochain/props_pizza/zpizmak_pizza.mdl")

ITEM:SetDescription(function(self, tbl)
	return zpiz.Pizza.GetDesc(tbl.data.PizzaID)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 17dc2f80cf0594471955ed2fce132d0271ce6541c38902a33a4148308c414a4d

function ITEM:OnPickup(ply, ent)
	if (not IsValid(ent)) then return end
	if ent:GetPizzaState() < 3 then
		return
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3a7bd44c53efd46df183636fbe76c3de2bd5fbbd78a3773db33588e14b60a4d

	local info = {
		ent = self:GetEntityClass(ent),
		dropEnt = self:GetDropEntityClass(ent),
		amount = self:GetEntityAmount(ent),
		data = self:GetData(ent)
	}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 17dc2f80cf0594471955ed2fce132d0271ce6541c38902a33a4148308c414a4d

	self:Pickup(ply, ent, info)

	return true
end

ITEM:AddDrop(function(self, ply, ent, tbl, tr)
	ent:SetPizzaID(tbl.data.PizzaID)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

	timer.Simple(0.1, function()
		if IsValid(ent) then
			zpiz.Pizza.ItemStoreDrop(ent)
		end
	end)

	zclib.Player.SetOwner(ent, ply)
end)

function ITEM:GetData(ent)
	return {
		PizzaID = ent:GetPizzaID(),
	}
end

function ITEM:GetDisplayName(item)
	return self:GetName(item)
end

function ITEM:GetName(item)
	local ent = isentity(item)
	local PizzaID = ent and item:GetPizzaID() or item.data.PizzaID
	return zpiz.Pizza.GetName(PizzaID)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350945

function ITEM:GetCameraModifiers(tbl)
	return {
		FOV = 40,
		X = 0,
		Y = -22,
		Z = 25,
		Angles = Angle(0, -190, 0),
		Pos = Vector(0, 0, -1)
	}
end

function ITEM:GetClientsideModel(tbl, mdlPanel)
	mdlPanel.Entity:SetSkin(1)
end

ITEM:Register("zpiz_pizza")
