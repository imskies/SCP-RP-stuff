/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

if (not SERVER) then return end
zpiz = zpiz or {}
zpiz.Sign = zpiz.Sign or {}
zpiz.Sign.List = zpiz.Sign.List or {}

function zpiz.Sign.Initialize(Sign)
	Sign:SetModel(Sign.Model)
	Sign:PhysicsInit(SOLID_VPHYSICS)
	Sign:SetMoveType(MOVETYPE_VPHYSICS)
	Sign:SetSolid(SOLID_VPHYSICS)
	Sign:SetUseType(SIMPLE_USE)
	local phys = Sign:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end

	Sign:UseClientSideAnimation()
	Sign.ActiveCustomerCount = 0

	table.insert(zpiz.Sign.List,Sign)

	timer.Simple(0.1, function()
		if IsValid(Sign) then
			zpiz.Sign.FindTables(Sign)
			zpiz.Sign.RefreshCustomerCount(Sign)
		end
	end)
end

function zpiz.Sign.OnRemove(Sign)
	table.RemoveByValue(zpiz.Sign.List,Sign)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ee71cdadb4c1697a1f320cfc75c78c5f0135879a492afb53058e82fcefbc72f0

// Called when the Entity gets Damaged
function zpiz.Sign.TakeDamage(Sign, dmg)
	if not IsValid(Sign) then return end


	if (not Sign.m_bApplyingDamage) then

		Sign.m_bApplyingDamage = true

		Sign:TakePhysicsDamage(dmg)
		local damage = dmg:GetDamage()
		local entHealth = zpiz.config.Damage["zpiz_opensign"]

		if (entHealth > 0) then
			Sign.CurrentHealth = (Sign.CurrentHealth or entHealth) - damage

			if (Sign.CurrentHealth <= 0) then
				zclib.Effect.Generic("Explosion", Sign:GetPos())

				local earnedMoney = Sign:GetSessionEarnings()
				if (earnedMoney > 0) then

					zclib.Notify(dmg:GetAttacker(), zpiz.language.OpenSign_RevenueMessage .. zclib.Money.Display(earnedMoney), 0)

					if DarkRP and zpiz.config.RevenueSpawn then
						zpiz.config.SpawnMoney(Sign:GetPos() + Sign:GetUp() * 20, earnedMoney)
					end
				end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

				Sign:Remove()
			end
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 02d4e064402d16696deab5b093c9a34ae7a407e6165a08b9f87e1e597f153041


		Sign.m_bApplyingDamage = false
	end
end


// This Connects the Table to its Parent OpenSign
function zpiz.Sign.FindTables(Sign)
	for k, v in pairs(zpiz.CustomerTable.List) do
		if IsValid(v) and zclib.Player.SharedOwner(v,Sign) then
			v.OpenSign = Sign
		end
	end
end

function zpiz.Sign.OnUse(Sign, ply)
	if zpiz.Player.CanInteract(ply,Sign) == false then return end

	Sign:SetSignState(not Sign:GetSignState())

	if (Sign:GetSignState() == false) then
		local earnedMoney = Sign:GetSessionEarnings()

		if (earnedMoney > 0) then

			zclib.Notify(ply, zpiz.language.OpenSign_RevenueMessage .. zclib.Money.Display(earnedMoney), 0)

			if DarkRP then
				if zpiz.config.RevenueSpawn then
					zpiz.config.SpawnMoney(Sign:GetPos() + Sign:GetUp() * 20, earnedMoney)
				else
					zclib.Money.Give(ply, earnedMoney)
				end
			else
				zclib.Money.Give(ply, earnedMoney)
			end
		end

		Sign:SetSessionEarnings(0)

		for k, v in pairs(zpiz.CustomerTable.List) do
			if (IsValid(v) and zclib.Player.SharedOwner(v,Sign)) then
				zpiz.CustomerTable.DisableAllCustomers(v)
			end
		end
	end
end

// This checks if we are allowed do spawn another customer
function zpiz.Sign.NextCustomerCheck(Sign)
	if (not Sign:GetSignState()) then return end

	zpiz.Sign.RefreshCustomerCount(Sign)

	if (Sign.ActiveCustomerCount < zpiz.config.Customer.Limit) then

		// Here we get all the customer tables that the player owns
		local PlayerCFreeTables = {}

		for k, v in pairs(zpiz.CustomerTable.List) do
			if (IsValid(v) and zclib.Player.SharedOwner(v,Sign)) then
				table.insert(PlayerCFreeTables, v)
			end
		end

		// Here we get the first free seat on the table we find
		local freeSeats = {}

		for k, v in pairs(PlayerCFreeTables) do
			if (IsValid(v)) then
				local aFreeSeat = zpiz.CustomerTable.GetFreeSeat(v)

				if (aFreeSeat ~= nil) then
					table.insert(freeSeats, aFreeSeat)
				end
			end
		end

		local freeSeat = freeSeats[math.random(#freeSeats)]

		// Here we spawn the customer on the table
		if (freeSeat ~= nil) and IsValid(freeSeat.agent) then
			local cTable = freeSeat.agent:GetParent()
			zpiz.CustomerTable.EnableCustomer(cTable,freeSeat)

			zpiz.Sign.RefreshCustomerCount(Sign)
		end
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

// This recounts all of our customers if needed
function zpiz.Sign.RefreshCustomerCount(Sign)
	local count = 0

	for k, v in pairs(zpiz.CustomerTable.List) do
		if (IsValid(v) and zclib.Player.SharedOwner(v,Sign)) then
			count = count + zpiz.CustomerTable.GetActiveCustomerCount(v)
		end
	end

	Sign.ActiveCustomerCount = count
end

// This removes one customer from our count, gets called by the tables
function zpiz.Sign.CustomerDespawned(Sign,earning)
	Sign:SetSessionEarnings(Sign:GetSessionEarnings() + earning)
	zpiz.Sign.RefreshCustomerCount(Sign)
end

zclib.Timer.Create("zpiz_customertable_id", zpiz.config.Customer.RespawnRate, 0,function()
	for k, v in pairs(zpiz.Sign.List) do
		if IsValid(v) then
			zpiz.Sign.NextCustomerCheck(v)
		end
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968
