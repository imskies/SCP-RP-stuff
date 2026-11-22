/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

zpiz = zpiz or {}

zclib.NetEvent.AddDefinition("zpiz_customer_sit", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	zclib.Animation.Play(ent, "d1_t03_sit_bed", 1)
end, true)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3a7bd44c53efd46df183636fbe76c3de2bd5fbbd78a3773db33588e14b60a4d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ee71cdadb4c1697a1f320cfc75c78c5f0135879a492afb53058e82fcefbc72f0

zclib.NetEvent.AddDefinition("zpiz_customer_sit_random", {
	[1] = {
		type = "entity"
	},
	[2] = {
		type = "uiint"
	}
}, function(received)
	local ent = received[1]
	local customerDataID = received[2]
	if customerDataID == nil then return end
	if not IsValid(ent) then return end
	local customerData = zpiz.config.Customers[customerDataID]
	local sitAnim = customerData.SitAnim[math.random(#customerData.SitAnim)]
	zclib.Animation.Play(ent, sitAnim, 1)
end, true)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

zclib.NetEvent.AddDefinition("zpiz_customer_serv_random", {
	[1] = {
		type = "entity"
	},
	[2] = {
		type = "uiint"
	}
}, function(received)
	local ent = received[1]
	local customerDataID = received[2]
	if customerDataID == nil then return end
	if not IsValid(ent) then return end
	local customerData = zpiz.config.Customers[customerDataID]
	local ServAnim = customerData.ServAnim[math.random(#customerData.ServAnim)]
	zclib.Animation.Play(ent, ServAnim, 1)
end, true)

zclib.NetEvent.AddDefinition("zpiz_oven_open", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	zclib.Animation.Play(ent, "open", 1)
end, true)

zclib.NetEvent.AddDefinition("zpiz_oven_close", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	zclib.Animation.Play(ent, "close", 1)
end, true)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 02d4e064402d16696deab5b093c9a34ae7a407e6165a08b9f87e1e597f153041

zclib.NetEvent.AddDefinition("zpiz_pizza_bake", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	zclib.Effect.ParticleEffect("zpizmak_oven_main", ent:GetPos(), ent:GetAngles(), ent)
end, true)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 02d4e064402d16696deab5b093c9a34ae7a407e6165a08b9f87e1e597f153041
