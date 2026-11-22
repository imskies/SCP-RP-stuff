/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

if (not SERVER) then return end
zpiz = zpiz or {}
zpiz.Fridge = zpiz.Fridge or {}

function zpiz.Fridge.Initialize(Fridge)
	Fridge:SetModel(Fridge.Model)
	Fridge:PhysicsInit(SOLID_VPHYSICS)
	Fridge:SetMoveType(MOVETYPE_VPHYSICS)
	Fridge:SetSolid(SOLID_VPHYSICS)
	Fridge:SetUseType(SIMPLE_USE)
	local phys = Fridge:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end

	Fridge:UseClientSideAnimation()
	Fridge:SetPos(Fridge:GetPos() + Vector(0, 0, 25))

	Fridge.IsPublicEntity = false
end

function zpiz.Fridge.OnUse(Fridge,ply)
	if zpiz.Player.CanInteract(ply,Fridge) == false then return end

	net.Start("zpiz_fridge_open")
	net.WriteEntity(Fridge)
	net.Send(ply)

	ply._zpiz_fridge = Fridge
end

function zpiz.Fridge.TakeDamage(Fridge, dmg)
	if not IsValid(Fridge) then return end

	if (not Fridge.m_bApplyingDamage) then
		Fridge.m_bApplyingDamage = true
		Fridge:TakeDamageInfo(dmg)

		local damage = dmg:GetDamage()
		local entHealth = zpiz.config.Damage["zpiz_fridge"]

		if (entHealth <= 0) then return end

		Fridge.CurrentHealth = (Fridge.CurrentHealth or entHealth) - damage

		if Fridge.CurrentHealth <= 0 then
			zclib.Effect.Generic("Explosion", Fridge:GetPos())
			SafeRemoveEntity(Fridge)
		end

		Fridge.m_bApplyingDamage = false
	end
end

util.AddNetworkString( "zpiz_fridge_open" )
util.AddNetworkString("zpiz_fridge_buy")
net.Receive("zpiz_fridge_buy",function(len,ply)
	if zclib.Player.Timeout(nil,ply) then return end

	local val = net.ReadInt(16)
	local fridge = net.ReadEntity()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 02d4e064402d16696deab5b093c9a34ae7a407e6165a08b9f87e1e597f153041

	if not IsValid(fridge) then return end
	if fridge:GetClass() ~= "zpiz_fridge" then return end

	if zclib.util.InDistance(ply:GetPos(), fridge:GetPos(), 300) == false then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 17dc2f80cf0594471955ed2fce132d0271ce6541c38902a33a4148308c414a4d

	if not ply:Alive() then return end

	local ing_price = zpiz.Ingredient.GetPrice(val)

	if zclib.Money.Has(ply, ing_price) == false then
		zclib.Notify(ply, zpiz.language.FridgeShop_NoMoney, 1)
		return
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

	if zpiz.Player.ReachedIngredientLimit(ply) then
		zclib.Notify(ply, zpiz.language.FridgeShop_LimitReached, 1)
		return
	end

	local reachedIngredientLimit, limitIngredient = zpiz.Player.ReachedIngredientLimit(ply, val)

	if reachedIngredientLimit  then
		zclib.Notify(ply, zpiz.language.FridgeShop_LimitReached, 1)
		return
	end

	zclib.Money.Take(ply, ing_price)

	zpiz.Fridge.BuyIngredient(fridge,val,ply)

	local message = string.Replace(zpiz.language.FridgeShop_BoughtItem, "$ItemName", zpiz.Ingredient.GetName(val))
	message = string.Replace(message, "$ItemPrice", zclib.Money.Display(ing_price))
	zclib.Notify(ply, message, 2)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

function zpiz.Fridge.BuyIngredient(Fridge,ingID,ply)
	local class = "zpiz_ingredient"
	if ingID == ZPIZ_ING_DOUGH then class = "zpiz_pizza" end

	local ent = ents.Create(class)
	ent:SetAngles(Fridge:GetAngles())
	ent:SetPos(Fridge:GetPos() + Fridge:GetForward() * 50 + Vector(0, 0, 40))
	ent:Spawn()
	ent:Activate()
	ent.ingId = ingID
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

	if ingID ~= ZPIZ_ING_DOUGH then
		ent:SetModel(zpiz.Ingredient.GetModel(ingID))
		ent:SetIngredientID(ingID)
	end

	ent:PhysicsInit(SOLID_VPHYSICS)
	ent:SetMoveType(MOVETYPE_VPHYSICS)
	ent:SetSolid(SOLID_VPHYSICS)
	ent:SetUseType(SIMPLE_USE)
	ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)
		phys:EnableDrag(true)
		phys:SetDragCoefficient(1)
	end

	zclib.Player.SetOwner(ent, ply)

	table.insert(ply.zpiz_SpawnedIngredients, ent)
end

function zpiz.Player.ReachedIngredientLimit(ply, id)
	ply.zpiz_SpawnedIngredients = ply.zpiz_SpawnedIngredients or {}

	local count = 0
	for k,v in pairs(ply.zpiz_SpawnedIngredients) do
		local ingredientId = v.ingId
		if not isnumber(ingredientId) then continue end

		if IsValid(v) && id == ingredientId then
			count = count + 1
		end
	end

	local limit = zpiz.Ingredient.GetLimit(id)

	return (count >= limit), limit
end
