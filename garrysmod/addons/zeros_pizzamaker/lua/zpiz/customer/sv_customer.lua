/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

if (not SERVER) then return end
zpiz = zpiz or {}
zpiz.CustomerTable = zpiz.CustomerTable or {}
zpiz.CustomerTable.List = zpiz.CustomerTable.List or {}

local function CreateProp(parent,class, pos, ang, model)
	local ent = ents.Create(class)
	ent:SetModel(model)
	ent:SetAngles(ang)
	ent:SetPos(pos)
	ent:SetParent(parent)
	ent:Spawn()
	ent:Activate()
	ent.PhysgunDisabled = zpiz.config.DisablePhysgun
	ent:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

	return ent
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350945

function zpiz.CustomerTable.Initialize(CustomerTable)
	CustomerTable:SetModel(CustomerTable.Model)
	CustomerTable:PhysicsInit( SOLID_VPHYSICS )
	CustomerTable:SetMoveType( MOVETYPE_NONE )
	CustomerTable:SetSolid( SOLID_VPHYSICS )
	CustomerTable:SetUseType(SIMPLE_USE)
	CustomerTable:SetTrigger(true)

	local phys = CustomerTable:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(false)
	end

	CustomerTable:UseClientSideAnimation()

	CustomerTable.OpenSign = nil

	table.insert(zpiz.CustomerTable.List,CustomerTable)


	// Customer Setup
	CustomerTable.Customers = {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ee71cdadb4c1697a1f320cfc75c78c5f0135879a492afb53058e82fcefbc72f0

	zpiz.CustomerTable.SetupCustomers(CustomerTable,1, CustomerTable:LocalToWorldAngles(Angle(0,0,0)), CustomerTable:LocalToWorld(Vector(-30,0,1)), CustomerTable:LocalToWorld(Vector(-30,0,-20)), CustomerTable:LocalToWorld(Vector(-15,0,18)) )

	zpiz.CustomerTable.SetupCustomers(CustomerTable,2, CustomerTable:LocalToWorldAngles(Angle(0,90,0)), CustomerTable:LocalToWorld(Vector(0,-30,1)), CustomerTable:LocalToWorld(Vector(0,-30,-20)), CustomerTable:LocalToWorld(Vector(0,-15,18)))

	zpiz.CustomerTable.SetupCustomers(CustomerTable,3,  CustomerTable:LocalToWorldAngles(Angle(0,-90,0)), CustomerTable:LocalToWorld(Vector(0,30,1)), CustomerTable:LocalToWorld(Vector(0,30,-20)), CustomerTable:LocalToWorld(Vector(0,15,18)))

	zpiz.CustomerTable.SetupCustomers(CustomerTable,4, CustomerTable:LocalToWorldAngles(Angle(0,180,0)), CustomerTable:LocalToWorld(Vector(30,0,1)), CustomerTable:LocalToWorld(Vector(30,0,-20)), CustomerTable:LocalToWorld(Vector(15,0,18)) )

	timer.Simple(0.1, function()
		if IsValid(CustomerTable) then
			zpiz.CustomerTable.FindOpenSign(CustomerTable)
		end
	end)
end

// Here we make sure the Customer Count gets recalculated if a Table gets removed
function zpiz.CustomerTable.OnRemove(CustomerTable)
	if IsValid(CustomerTable.OpenSign) then
		zpiz.Sign.RefreshCustomerCount(CustomerTable.OpenSign)
	end

	table.RemoveByValue(zpiz.CustomerTable.List,CustomerTable)
end

function zpiz.CustomerTable.Touch(CustomerTable,other)
	if not IsValid(other) then return end

	if other:GetClass() ~= "zpiz_pizza" then return end

	if zclib.util.CollisionCooldown(other) then return end

	if other:GetPizzaState() < 3 then return end

	if other.Delivered == true then return end

	if CustomerTable.ServingPizza == true then return end
	CustomerTable.ServingPizza = true
	timer.Simple(1,function()
		if IsValid(CustomerTable) then
			CustomerTable.ServingPizza = false
		end
	end)

	local cook = zpiz.Player.GetNearPizzaChef(other)
	if (cook) then
		zpiz.CustomerTable.ServPizza(CustomerTable,other,cook)
	end
end


///////////////////////////////////////////////
//////////////// Customers ////////////////////
///////////////////////////////////////////////

// This is used for spawning the cusomer, plate and chair
function zpiz.CustomerTable.SetupCustomers(CustomerTable,num,ang,ChairPos,GuyPos,PlatePos)
	CreateProp(CustomerTable,"zpiz_animbase",ChairPos,ang,"models/props_interiors/furniture_chair01a.mdl")

	local customer = CreateProp(CustomerTable,"zpiz_animbase",GuyPos,ang,"models/alyx.mdl")
	customer:SetNoDraw(true)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 17dc2f80cf0594471955ed2fce132d0271ce6541c38902a33a4148308c414a4d

	zclib.NetEvent.Create("zpiz_customer_sit", {customer})

	local plate = CreateProp(CustomerTable,"zpiz_plate",PlatePos,ang,"models/maxofs2d/hover_plate.mdl")
	plate:SetNoDraw(true)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 02d4e064402d16696deab5b093c9a34ae7a407e6165a08b9f87e1e597f153041

	CustomerTable.Customers[num] = {agent = customer, customerID = 1, agentPlate = plate, agentState = "DISABLED"}
end

// This Connects the Table to its Parent OpenSign
function zpiz.CustomerTable.FindOpenSign(CustomerTable)
	for k, v in pairs(zpiz.Sign.List) do
		if zclib.Player.SharedOwner(v,CustomerTable) then
			CustomerTable.OpenSign = v
			break
		end
	end
end

// This returns the first free seat it can finds
function zpiz.CustomerTable.GetFreeSeat(CustomerTable)
	local seat

	for k, v in pairs(CustomerTable.Customers) do
		if v.agentState == "DISABLED" then
			seat = v
			break
		end
	end
	return seat
end

// This returns the count of active Customer
function zpiz.CustomerTable.GetActiveCustomerCount(CustomerTable)
	local customerCount = 0
	for k, v in pairs(CustomerTable.Customers) do
		if (v.agentState == "WAITING") then
			customerCount = customerCount + 1
		end
	end
	return customerCount
end

// This Enables the Customer
function zpiz.CustomerTable.EnableCustomer(CustomerTable,TheCustomer)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

	local customerDataID = math.random( #zpiz.config.Customers )
	local customerData = zpiz.config.Customers[ customerDataID ]
	TheCustomer.agent:SetModel(customerData.Model)
	TheCustomer.customerID = customerDataID

	zclib.NetEvent.Create("zpiz_customer_sit_random", {TheCustomer.agent,customerDataID})

	TheCustomer.agent:SetNoDraw(false)
	TheCustomer.agentPlate:SetNoDraw(false)

	local pizzaWish = zpiz.Pizza.GetRandom()

	local waitTime = zpiz.Pizza.GetBakeTime(pizzaWish) + zpiz.config.Customer.ExtraWaitTime
	TheCustomer.agentPlate:SetPizzaID(pizzaWish)
	TheCustomer.agentPlate:SetPizzaWaitTime(CurTime() + waitTime)
	TheCustomer.agentState = "WAITING"

	zclib.Timer.Create("CustomerTable_" .. CustomerTable:EntIndex() .. "_Customer_" .. TheCustomer.agent:EntIndex(),waitTime,1,function()
		if IsValid(TheCustomer.agent) then
			zpiz.CustomerTable.DisableCustomer(CustomerTable,TheCustomer, 0)
		end
	end)
end

// This Disables the Customer
function zpiz.CustomerTable.DisableCustomer(CustomerTable,customer,income)
	zclib.Timer.Remove("CustomerTable_" .. CustomerTable:EntIndex() .. "_Customer_" .. customer.agent:EntIndex())
	customer.agent:SetNoDraw(true)
	customer.agentPlate:SetNoDraw(true)
	customer.agentState = "DISABLED"
	customer.agentPlate:SetPizzaWaitTime(-1)
	customer.agentPlate:SetPizzaID(-1)

	if IsValid(CustomerTable.OpenSign) then
		zpiz.Sign.CustomerDespawned(CustomerTable.OpenSign,income)
	end
end

// This disables all customers
function zpiz.CustomerTable.DisableAllCustomers(CustomerTable)
	for k, v in pairs(CustomerTable.Customers) do
		if v.agentState ~= "DISABLED" then
			zpiz.CustomerTable.DisableCustomer(CustomerTable,v,0)
		end
	end
end

// Here we serv the Pizza
function zpiz.CustomerTable.ServPizza(CustomerTable,pizza,ply)
	local pizzaID = pizza:GetPizzaID()

	local ValidCustomer
	local ValidCustomerTime = 999999
	for k, v in pairs(CustomerTable.Customers) do
		if (v.agentPlate:GetPizzaID() == pizzaID and v.agentPlate:GetPizzaWaitTime() < ValidCustomerTime) then
			ValidCustomer = v
			ValidCustomerTime = v.agentPlate:GetPizzaWaitTime()
		end
	end

	if ValidCustomer then

		pizza.Delivered = true

		local earnings = zpiz.Pizza.GetPrice(pizzaID)

		if (pizza:GetPizzaState() == 3) then
			zclib.Notify(ply, zpiz.language.Customer_ServPizza_good, 0)
		elseif (pizza:GetPizzaState() == 4) then
			earnings = earnings * zpiz.config.Customer.BurnedPizzaPenalty
			zclib.Notify(ply, zpiz.language.Customer_ServPizza_bad, 1)
		end

		zclib.Timer.Remove("CustomerTable_" .. CustomerTable:EntIndex() .. "_Customer_" .. ValidCustomer.agent:EntIndex())

		// This makes sure we cant serve him double
		ValidCustomer.agentPlate:SetPizzaID(-1)

		SafeRemoveEntity(pizza)

		local customerData = zpiz.config.Customers[ValidCustomer.customerID]

		zclib.NetEvent.Create("zpiz_customer_serv_random", {ValidCustomer.agent,ValidCustomer.customerID})
		local ServAnim = customerData.ServAnim[math.random(#customerData.ServAnim)]
		local dur = ValidCustomer.agent:SequenceDuration(ValidCustomer.agent:LookupSequence(ServAnim))

		// Call Sell Hook
		hook.Run("zpiz_OnPizzaSold" ,ply, earnings, pizzaID, pizza:GetPizzaState() == 4)

		timer.Simple(dur, function()
			if IsValid(CustomerTable) and IsValid(ValidCustomer.agent) then

				zclib.Notify(ply, zpiz.language.Customer_Pays .. "  +" .. zclib.Money.Display(earnings), 0)
				zpiz.CustomerTable.DisableCustomer(CustomerTable,ValidCustomer,earnings)
			end
		end)
	end
end
///////////////////////////////////////////////
///////////////////////////////////////////////
