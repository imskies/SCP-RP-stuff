/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

ITEM.Name = "Pizza"
ITEM.Description = "A tasty Pizza"
ITEM.Model = "models/zerochain/props_pizza/zpizmak_pizza.mdl"
ITEM.Base = "base_darkrp"
ITEM.Stackable = false
ITEM.DropStack = false

function ITEM:GetName()
	return self:GetData("Name", zpiz.Pizza.GetName(self:GetData("PizzaID")))
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ee71cdadb4c1697a1f320cfc75c78c5f0135879a492afb53058e82fcefbc72f0

function ITEM:GetDescription()
	local pizzaID = self:GetData("PizzaID")
	local desc = zpiz.Pizza.GetDesc(pizzaID) .. " | Health: " .. zpiz.Pizza.GetHealth(pizzaID) .. " | Price: " .. zclib.Money.Display(zpiz.Pizza.GetPrice(pizzaID))

	return self:GetData("Description", desc)
end

function ITEM:Use(ply, con, slot)
	zpiz.Pizza.Eat(nil,self:GetData("PizzaID"),ply)
	return true
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 17dc2f80cf0594471955ed2fce132d0271ce6541c38902a33a4148308c414a4d

function ITEM:CanPickup(pl, ent)
	if ent:GetPizzaState() == 3 then
		return true
	else
		return false
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

function ITEM:SaveData(ent)
	self:SetData("PizzaID", ent:GetPizzaID())
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- fde1005ae952a630057a2cc575fe1335e7c9809985c0483424501baa23d5a1ad

function ITEM:LoadData(ent)
	ent:SetPizzaID(self:GetData("PizzaID"))

	//Call function to change entity state to fully baked pizza
	timer.Simple(0.1, function()
		if IsValid(ent) then
			zpiz.Pizza.ItemStoreDrop(ent)
		end
	end)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- fde1005ae952a630057a2cc575fe1335e7c9809985c0483424501baa23d5a1ad

function ITEM:Drop(ply, con, slot, ent)
	zclib.Player.SetOwner(ent, ply)
end
