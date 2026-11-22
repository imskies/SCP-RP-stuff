/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.MedicalUnit = zbl.MedicalUnit or {}

function zbl.MedicalUnit.Initialize(MedicalUnit)
    zclib.EntityTracker.Add(MedicalUnit)

	MedicalUnit.Inventory = {}

	zbl.MedicalUnit.ScanArea(MedicalUnit)
end

/*
	Open interface to let the player ask/buy for Vaccine
*/
util.AddNetworkString("zbl.MedicalUnit.Open")
function zbl.MedicalUnit.OnUse(MedicalUnit,ply)
	local swep = ply:GetWeapon( "zbl_gun" )

	if not IsValid(swep) then
		zclib.Notify(ply, zbl.language.General["nogun"], 1)
		return
	end

	local reduced_tbl = {
		swep = {},
		inv = {}
	}

	// Makes the flask table a bit smaller for networking
	for k,v in pairs(swep.Flasks) do
		reduced_tbl.swep[k] = {
			gt = v.GenType,
			gv = v.GenValue,
			gn = v.GenName,
		}
	end

	for k,v in pairs(MedicalUnit.Inventory) do
		reduced_tbl.inv[k] = {
			gt = v.GenType,
			gv = v.GenValue,
			gn = v.GenName,
		}
	end

	local dataString = util.TableToJSON(reduced_tbl)
	local dataCompressed = util.Compress(dataString)

	net.Start("zbl.MedicalUnit.Open")
	net.WriteUInt(#dataCompressed, 16)
	net.WriteData(dataCompressed, #dataCompressed)
	net.WriteEntity(MedicalUnit)
	net.Send(ply)
end

/*
	Searches the near area for infected
*/
util.AddNetworkString("zbl.MedicalUnit.InfectionDetected")
function zbl.MedicalUnit.ScanArea(MedicalUnit)

	if not zbl.config.StationaryMedicalUnit.Scan.enabled then return end

	local timerid = "zbl.MedicalUnit.Scan." .. MedicalUnit:EntIndex()
	zclib.Timer.Create(timerid,zbl.config.StationaryMedicalUnit.Scan.default_interval,0,function()
		if not IsValid(MedicalUnit) then
			zclib.Timer.Remove(timerid)
			return
		end

		local _ , FoundInfected = zbl.MedicalUnit.GetScanned(MedicalUnit)

		net.Start("zbl.MedicalUnit.InfectionDetected",true)
		net.WriteEntity(MedicalUnit)
		net.Broadcast()

		// If one of the entities is infected then increase timer interval and turn on the red warn lights
		if FoundInfected then
			timer.Adjust(timerid,zbl.config.StationaryMedicalUnit.Scan.threat_interval)
			MedicalUnit:SetThreatDetected(true)
		else
			timer.Adjust(timerid,zbl.config.StationaryMedicalUnit.Scan.default_interval)
			MedicalUnit:SetThreatDetected(false)
		end
	end)
end

/*
	Returns the first free slot it finds
*/
function zbl.MedicalUnit.FindFreeInventorySlot(MedicalUnit)
	local slot

	for i = 1, 28 do
		if not MedicalUnit.Inventory[ i ] then
			slot = i
			break
		end
	end

	return slot
end

local function NetCheck(ply,MedicalUnit)
    if not IsValid(ply) then return end
    if zclib.Player.Timeout(nil,ply) then return end
    if not IsValid(MedicalUnit) then return end
    if MedicalUnit:GetClass() ~= "zbl_medical_unit" then return end
    if zclib.util.InDistance(ply:GetPos(), MedicalUnit:GetPos(), 600) == false then return end
    return true
end

util.AddNetworkString("zbl.MedicalUnit.Sell")
net.Receive("zbl.MedicalUnit.Sell", function(len, ply)
    zclib.Debug("zbl.MedicalUnit.Sell len: " .. len)
    local MedicalUnit = net.ReadEntity()
    local id = net.ReadInt(16)
    if id == nil then return end

    if not NetCheck(ply,MedicalUnit) then return end

    zbl.MedicalUnit.Sell(MedicalUnit,ply,id)
end)
function zbl.MedicalUnit.Sell(MedicalUnit,ply,flask_id)
    zclib.Debug("zbl.MedicalUnit.Sell")

    local swep = ply:GetWeapon("zbl_gun")

    if not IsValid(swep) then return end
    if swep.Flasks == nil then return end

    local flask_data = swep.Flasks[flask_id]
    if flask_data == nil then return end

	// We can only sell cures
    if flask_data.GenType ~= 3 then return end

    local money = zbl.Vaccine.GetCure_Price(flask_data.GenValue) * zbl.config.StationaryMedicalUnit.sell_mod

    // Remove Flask from player swep
    zbl.Injector.EmptyLiquid(swep,flask_id)

	// Give player the money
	zclib.Money.Give(ply, money)

	zclib.Notify(ply, string.Replace(zbl.language.General["ReceivedMoney"],"$Money",zclib.Money.Display(money)), 0)
	ply:EmitSound("zbl_cash")

	MedicalUnit:SetBoughtVaccines(MedicalUnit:GetBoughtVaccines() + 1)

	// If we have a free inventory slot in the machine then add it, otherwhise its just gonna be gone
	local slot = zbl.MedicalUnit.FindFreeInventorySlot(MedicalUnit)
	if slot then
		MedicalUnit.Inventory[slot] = {
			GenType = flask_data.GenType,
			GenValue = flask_data.GenValue,
			GenName = flask_data.GenName,
			GenPoints = flask_data.GenPoints,
			GenClass = flask_data.GenClass
		}

		zbl.MedicalUnit.OnUse(MedicalUnit,ply)

		zbl.MedicalUnit.Update(MedicalUnit)
	end
end

util.AddNetworkString("zbl.MedicalUnit.Buy")
net.Receive("zbl.MedicalUnit.Buy", function(len, ply)
    zclib.Debug("zbl.MedicalUnit.Buy len: " .. len)
    local MedicalUnit = net.ReadEntity()
	if not IsValid(MedicalUnit) then return end
    local slot = net.ReadInt(16)
    if slot == nil then return end

    if not NetCheck(ply,MedicalUnit) then return end

    zbl.MedicalUnit.Buy(MedicalUnit,ply,slot)
end)
function zbl.MedicalUnit.Buy(MedicalUnit,ply,slot)
    zclib.Debug("zbl.MedicalUnit.Buy")

    local flask_data = MedicalUnit.Inventory[slot]
    if flask_data == nil then return end

    local money = zbl.Vaccine.GetCure_Price(flask_data.GenValue) * zbl.config.StationaryMedicalUnit.buy_mod

	// Check if the player has enough money
	if not zclib.Money.Has(ply, money) then
		return
	end

    // Remove Flask from the machine
    MedicalUnit.Inventory[slot] = nil

	// Take the money
	zclib.Money.Take(ply, money)

	MedicalUnit:SetSoldVaccines(MedicalUnit:GetSoldVaccines() + 1)

	zclib.Notify(ply, "-" .. zclib.Money.Display(money), 0)
	ply:EmitSound("zbl_cash")

	zbl.Player.HurtSound(ply)

	// Makes the player immun against the virus for a certain amount of time
	zbl.Player.MakeImmun(ply,flask_data.GenValue,zbl.Vaccine.GetCure_Time(flask_data.GenValue))

	// Is this the correct cure?
	local vaccindID = zbl.Vaccine.Get(ply)
	if vaccindID == flask_data.GenValue then
		// Cures the player
		zbl.Player.Cure(ply)

		zclib.Notify(ply, string.Replace(zbl.language.General["MedicalUnitCured"],"$Virus",zbl.Vaccine.GetName(flask_data.GenValue)), 0)
	end

	zbl.MedicalUnit.OnUse(MedicalUnit,ply)

	zbl.MedicalUnit.Update(MedicalUnit)
end

util.AddNetworkString("zbl.MedicalUnit.Update")
function zbl.MedicalUnit.Update(MedicalUnit)

	local reduced_tbl = {}
	for k,v in pairs(MedicalUnit.Inventory) do
		reduced_tbl[k] = {
			gt = v.GenType,
			gv = v.GenValue,
			gn = v.GenName,
		}
	end

	local dataString = util.TableToJSON(reduced_tbl)
	local dataCompressed = util.Compress(dataString)

	net.Start("zbl.MedicalUnit.Update")
	net.WriteUInt(#dataCompressed, 16)
	net.WriteData(dataCompressed, #dataCompressed)
	net.WriteEntity(MedicalUnit)
	net.Broadcast()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

if zbl.config.StationaryMedicalUnit.AutoRefillInterval and zbl.config.StationaryMedicalUnit.AutoRefillInterval > 0 then
	timer.Simple(5,function()

		timer.Create("zbl.MedicalUnit.AutoRefill",zbl.config.StationaryMedicalUnit.AutoRefillInterval,0,function()

			local Cures = {}
			for k,v in pairs(zbl.config.Vaccines) do
				if v and v.isvirus and v.cure then
					table.insert(Cures,k)
				end
			end

			for k,v in ipairs(ents.FindByClass("zbl_medical_unit")) do
				if not IsValid(v) then continue end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

				local slot = zbl.MedicalUnit.FindFreeInventorySlot(v)
				if slot then
					local cure_id = Cures[math.random(#Cures)]

					if not v.Inventory then v.Inventory = {} end

					v.Inventory[slot] = {
						GenType = 3,
						GenValue = cure_id,
						GenName = zbl.Vaccine.GetName(cure_id),
						GenPoints = 0,
						GenClass = ""
					}

					zbl.MedicalUnit.Update(v)
				end
			end
		end)
	end)
end




file.CreateDir("zbl")
zclib.STM.Setup("zbl_medical_unit", "zbl/" .. string.lower(game.GetMap()) .. "_smu" .. ".txt", function()
    local data = {}
    for u, j in pairs(ents.FindByClass("zbl_medical_unit")) do
        if IsValid(j) then
            table.insert(data, {
                pos = j:GetPos(),
                ang = j:GetAngles()
            })
        end
    end
    return data
end, function(data)
    for k, v in pairs(data) do
        local ent = ents.Create("zbl_medical_unit")
        ent:SetPos(v.pos)
        ent:SetAngles(v.ang)
        ent:Spawn()
        ent:Activate()

        local phys = ent:GetPhysicsObject()

        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(false)
        end
    end
    zbl.Print("Finished loading Info MedicalUnits!")
end, function()
    for k, v in pairs(ents.FindByClass("zbl_medical_unit")) do
        if IsValid(v) then
            v:Remove()
        end
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

function zbl.MedicalUnit.Save(ply)
    zclib.Notify(ply, "MedicalUnits have been saved for the map " .. string.lower(game.GetMap()) .. "!", 0)
    zclib.STM.Save("zbl_medical_unit")
end

function zbl.MedicalUnit.Remove(ply)
    zclib.Notify(ply, "MedicalUnits have been removed for the map " .. string.lower(game.GetMap()) .. "!", 0)
    zclib.STM.Remove("zbl_medical_unit")
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

concommand.Add( "zbl_medicalunit_save", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        zbl.MedicalUnit.Save(ply)
    end
end )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

concommand.Add( "zbl_medicalunit_remove", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        zbl.MedicalUnit.Remove(ply)
    end
end )
