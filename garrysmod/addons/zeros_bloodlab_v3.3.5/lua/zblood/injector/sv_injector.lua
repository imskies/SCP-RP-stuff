/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.Injector = zbl.Injector or {}

function zbl.Injector.GetTarget(swep)
	local tr = swep:GetOwner():GetEyeTrace()
	local ent = tr.Entity

	if tr.Hit == false then return end
	if not IsValid(ent) then return end

	if not ent:IsPlayer() then return end

	if zclib.util.InDistance(swep:GetOwner():GetPos(), ent:GetPos(), 100) == false then return end

	return ent
end

function zbl.Injector.Initialize(swep)
	zclib.Debug("zbl.Injector.Initialize")
	swep:SetHoldType(swep.HoldType)
	swep:SetBusy(false)
	swep.FlaskSetup = false

	swep.Flasks = {}

	timer.Simple(0,function()
		if IsValid(swep) and IsValid(swep:GetOwner()) then
			zbl.Injector.SetupFlasks(swep)
		end
	end)
end

function zbl.Injector.SetupFlasks(swep)
	if swep.FlaskSetup == true then return end
	swep.FlaskSetup = true

	zclib.Debug("zbl.Injector.SetupFlasks")

	swep.Flasks = {}
	local capacity = zbl.config.InjectorGun.flask_capacity[zclib.Player.GetRank(swep:GetOwner())]

	if capacity == nil then
		capacity = zbl.config.InjectorGun.flask_capacity["default"]
	end

	for i = 1, capacity do
		swep.Flasks[i] = {
			GenType = 0,
			GenValue = 0,
			GenName = "",
			GenPoints = 0,
			GenClass = ""
		}
	end

	zbl.Injector.UpdateFlaskSequence(swep)
end





function zbl.Injector.Primary(swep)
	zclib.Debug("zbl.Injector.Primary")

	if hook.Run("zbl_CanInjectorGun_Primary",swep,swep:GetOwner()) == false then
		swep:SetNextPrimaryFire(CurTime() + swep.Primary.Delay)
		return
	end

	if zbl.Injector.HasLiquid(swep) == false then
		zclib.Notify(swep:GetOwner(), zbl.language.Gun["GunEmpty"], 1)
		return
	end

	if swep:GetBusy() then
		return false
	end

	local _type = swep:GetGenType()
	local _val = swep:GetGenValue()
	if _type < 2 then
		zclib.Notify(swep:GetOwner(), zbl.language.Gun["NoVaccine"], 1)
		return false
	end

	// Performs a Target Trace
	local ent = zbl.Injector.GetTarget(swep)
	if not IsValid(ent) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

	if _type == 3 then

		// Check if player is even infected
		if zbl.Vaccine.Has(ent) then

			local vaccindID = zbl.Vaccine.Get(ent)

			// Remove Active Vaccine if the gun has the correct anti vaccine
			if vaccindID == _val then

				swep:GetOwner():EmitSound("zbl_vo_inject")
				timer.Simple(0.5, function()
					if IsValid(ent) then
						zbl.Player.HurtSound(ent)
					end
					if IsValid(swep) and IsValid(swep:GetOwner()) then
						swep:GetOwner():EmitSound("zbl_gun_inject")
					end
				end)

				// Makes the player immun against the virus for a certain amount of time
				zbl.Player.MakeImmun(ent,vaccindID,zbl.Vaccine.GetCure_Time(vaccindID))

				zclib.Notify(ent, string.Replace(zbl.language.General["MedicalUnitCured"],"$Virus",zbl.Vaccine.GetName(vaccindID)), 0)

				// Cures the player
				zbl.Player.Cure(ent)

				// Custom Hook
				hook.Run("zbl_OnPlayerCurePlayer" ,ent, vaccindID,swep:GetOwner())

				// Emptys the flask
				zbl.Injector.EmptyLiquid(swep,swep:GetSelectedFlask())

				swep:SetBusy(true)
				zbl.Injector.PlayShootAnim(swep)
			else

				zclib.Notify(swep:GetOwner(), zbl.language.Gun["WrongCure"], 1)
				return
			end
		else
			zclib.Notify(swep:GetOwner(), zbl.language.Gun["PlayerNotInfected"], 1)
		end
	elseif _type == 2 then

		// Check if the target is currently infected and if its a virus we stop
	    if zbl.Player.VaccineOverride(ent) == false then
	       zclib.Notify(swep:GetOwner(), zbl.language.Gun["PlayerAlreadyInfected"], 1)
		   return
	    end

		swep:GetOwner():EmitSound("zbl_vo_inject")

		timer.Simple(0.5, function()
			if IsValid(ent) and IsValid(swep) and IsValid(swep:GetOwner()) and _val then

				zbl.Player.HurtSound(ent)

				zbl.Player.Vaccinate(ent,_val,1,swep:GetOwner())

				swep:GetOwner():EmitSound("zbl_gun_inject")
			end
		end)

		zbl.Injector.EmptyLiquid(swep,swep:GetSelectedFlask())

		swep:SetBusy(true)
		zbl.Injector.PlayShootAnim(swep)
	end

	swep:SetNextPrimaryFire(CurTime() + swep.Primary.Delay)
end

function zbl.Injector.Secondary(swep)
	if swep:GetBusy() then
		return false
	end

	zclib.Debug("zbl.Injector.Secondary")

	if hook.Run("zbl_CanInjectorGun_Secondary",swep,swep:GetOwner()) == false then
		swep:SetNextPrimaryFire(CurTime() + swep.Secondary.Delay)
		return
	end

	// If we still have a empty flask in the gun then we use it
	local empty_flask = zbl.Injector.GetEmptyFlask(swep)
	if empty_flask == nil then
		zclib.Notify(swep:GetOwner(), zbl.language.Gun["GunIsFull"], 1)
		return
	end

	local tr = swep:GetOwner():GetEyeTrace()

	local ent = tr.Entity

	if tr.Hit and IsValid(ent) and zclib.util.InDistance(swep:GetOwner():GetPos(), ent:GetPos(), 100) then

		if ent:GetClass() == "zbl_flask" and ent:GetGenType() ~= 0 then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

			zbl.Injector.AddLiquid(swep,empty_flask,ent:GetGenType(),ent:GetGenValue(),ent:GetGenName(),ent:GetGenPoints(),ent:GetGenClass())

			swep:GetOwner():EmitSound("zbl_gun_fill")

			SafeRemoveEntity(ent)

			zbl.Injector.PlayShootAnim(swep)
		elseif zbl.config.Contamination.collectable == true and zbl.config.Contamination.ents[ent:GetClass()] and zbl.Contamination.IsObjectContaminated(ent) then

			local sample_type = zbl.config.SampleTypes["contaminated_objects"]

			// Can this entity be collected/harvested?
			if sample_type == nil then return end

			local sample_name = sample_type.name(ent)
			local sample_value = sample_type.identifier(ent)
			local sample_points = sample_type.points_modify(swep:GetOwner(),ent,sample_type.dna_points)

			swep:GetOwner():EmitSound("zbl_gun_fill")

			sample_type.OnCollect(swep:GetOwner(),ent)

			zbl.Injector.AddLiquid(swep,empty_flask,1,sample_value,sample_name,sample_points,ent:GetClass())

			// Custom Hook
			hook.Run("zbl_OnPlayerGetSample" ,ent,swep:GetOwner(),sample_name,sample_value,sample_points)

			zbl.Injector.PlayShootAnim(swep)

			zbl.Contamination.ObjectSanitise(ent)
		else
			local sample_class = ent:GetClass()

			local sample_type = zbl.config.SampleTypes[sample_class]

			// Can this entity be collected/harvested?
			if sample_type == nil then return end

			local sample_name = sample_type.name(ent)
			local sample_value = sample_type.identifier(ent)
			local sample_points = sample_type.points_modify(swep:GetOwner(),ent,sample_type.dna_points)

			swep:GetOwner():EmitSound("zbl_gun_fill")

			sample_type.OnCollect(swep:GetOwner(),ent)

			zbl.Injector.AddLiquid(swep,empty_flask,1,sample_value,sample_name,sample_points,sample_class)

			// Custom Hook
			hook.Run("zbl_OnPlayerGetSample" ,ent,swep:GetOwner(),sample_name,sample_value,sample_points)


			zbl.Injector.PlayShootAnim(swep)
		end
	end

	swep:SetNextSecondaryFire(CurTime() + swep.Secondary.Delay)
end

function zbl.Injector.Equip(swep)
	zclib.Debug("zbl.Injector.Equip")
	zbl.Injector.PlayDrawAnim(swep)
	zbl.Injector.SetupFlasks(swep)
end

function zbl.Injector.Deploy(swep)
	zclib.Debug("zbl.Injector.Deploy")

	zclib.Timer.Remove("zbl_gun_drawanim_" .. swep:EntIndex() .. "_timer")
	zclib.Timer.Remove("zbl_gun_shootanim_" .. swep:EntIndex() .. "_timer")
	zclib.Timer.Remove("zbl_gun_reloadanim_" .. swep:EntIndex() .. "_timer")
	zclib.Timer.Remove("zbl_gun_selfinjectanim_" .. swep:EntIndex() .. "_timer")



	zbl.Injector.PlayDrawAnim(swep)
	zbl.Injector.SetupFlasks(swep)
end

function zbl.Injector.Holster(swep)
	zclib.Debug("zbl.Injector.Holster")

	zclib.Timer.Remove("zbl_gun_drawanim_" .. swep:EntIndex() .. "_timer")
	zclib.Timer.Remove("zbl_gun_shootanim_" .. swep:EntIndex() .. "_timer")
	zclib.Timer.Remove("zbl_gun_reloadanim_" .. swep:EntIndex() .. "_timer")
	zclib.Timer.Remove("zbl_gun_selfinjectanim_" .. swep:EntIndex() .. "_timer")

	swep:SendWeaponAnim(ACT_VM_HOLSTER)

	swep:SetBusy(false)
end

function zbl.Injector.Reload(swep)

	if swep:GetBusy() then
		return false
	end

	zclib.Debug("zbl.Injector.Reload")

	swep:SetBusy(true)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

	swep:GetOwner():EmitSound("zbl_gun_fill")

	swep:SendWeaponAnim(ACT_VM_RELOAD)
	swep:GetOwner():SetAnimation(PLAYER_ATTACK1)

	zbl.Injector.SwitchFlask(swep)

	local timerID = "zbl_gun_reloadanim_" .. swep:EntIndex() .. "_timer"
	zclib.Timer.Remove(timerID)

	zclib.Timer.Create(timerID,0.1,1,function()
		zclib.Timer.Remove(timerID)

		if IsValid(swep) and IsValid(swep:GetOwner()) and IsValid(swep:GetOwner():GetActiveWeapon()) and swep:GetOwner():GetActiveWeapon():GetClass() == "zbl_gun"  then

			zbl.Injector.PlayIdleAnim(swep)
		end
	end)
end

// Inject the currently selected vaccin in to yourself
function zbl.Injector.SelfInject(swep)
	zclib.Debug("zbl.Injector.SelfInject")

	if zbl.Injector.HasLiquid(swep) == false then
		zclib.Notify(swep:GetOwner(), zbl.language.Gun["Empty"], 1)
		return
	end

	if swep:GetBusy() then
		return false
	end

	local _type = swep:GetGenType()
	local _val = swep:GetGenValue()
	if _type < 2 then
		zclib.Notify(swep:GetOwner(), zbl.language.Gun["NoVaccine"], 1)
		return false
	end

	// Performs a Target Trace
	local ent = swep:GetOwner()
	if not IsValid(ent) then return end

	if _type == 3 then

		// Check if player is even infected
		if zbl.Vaccine.Has(ent) then

			local vaccindID = zbl.Vaccine.Get(ent)

			// Remove Active Vaccine if the gun has the correct anti vaccine
			if vaccindID == _val then

				swep:GetOwner():EmitSound("zbl_vo_inject")
				timer.Simple(0.5, function()
					if IsValid(ent) then
						zbl.Player.HurtSound(ent)

						// Makes the player immun against the virus for a certain amount of time
						zbl.Player.MakeImmun(ent,vaccindID,zbl.Vaccine.GetCure_Time(vaccindID))

						// Cures the player
						zbl.Player.Cure(ent)
					end
					if IsValid(swep) and IsValid(swep:GetOwner()) then
						swep:GetOwner():EmitSound("zbl_gun_inject")
					end
				end)

				// Emptys the flask
				zbl.Injector.EmptyLiquid(swep,swep:GetSelectedFlask())

				swep:SetBusy(true)
				zbl.Injector.PlaySelfInjectAnim(swep)
			else

				zclib.Notify(swep:GetOwner(), zbl.language.Gun["WrongCure"], 1)
				return
			end
		else
			zclib.Notify(swep:GetOwner(), zbl.language.Gun["PlayerNotInfected"], 1)
		end
	elseif _type == 2 then

		// Check if the target is currently infected and if its a virus we stop
	    if zbl.Player.VaccineOverride(ent) == false then
	       zclib.Notify(swep:GetOwner(), zbl.language.Gun["PlayerAlreadyInfected"], 1)
		   return
	    end

		swep:GetOwner():EmitSound("zbl_vo_inject")

		timer.Simple(0.5, function()
			if IsValid(ent) and IsValid(swep) then
				zbl.Player.HurtSound(ent)
				zbl.Player.Vaccinate(ent,_val,1,swep:GetOwner())
			end
			if IsValid(swep) and IsValid(swep:GetOwner()) then
				swep:GetOwner():EmitSound("zbl_gun_inject")
			end
		end)

		zbl.Injector.EmptyLiquid(swep,swep:GetSelectedFlask())

		swep:SetBusy(true)
		zbl.Injector.PlaySelfInjectAnim(swep)
	end

	swep:SetNextPrimaryFire(CurTime() + 1.6)
end



function zbl.Injector.PlayShootAnim(swep)
	if not IsValid(swep) then return end // Safety first!

	swep:SetBusy(true)

	swep:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	swep:GetOwner():SetAnimation(PLAYER_ATTACK1)

	local timerID = "zbl_gun_shootanim_" .. swep:EntIndex() .. "_timer"
	zclib.Timer.Remove(timerID)

	zclib.Timer.Create(timerID,0.9,1,function()
		if IsValid(swep) and IsValid(swep:GetOwner()) and IsValid(swep:GetOwner():GetActiveWeapon()) and swep:GetOwner():GetActiveWeapon():GetClass() == "zbl_gun"  then
			zbl.Injector.PlayIdleAnim(swep)
		end
		zclib.Timer.Remove(timerID)
	end)
end

function zbl.Injector.PlayDrawAnim(swep)
	if not IsValid(swep) then return end // Safety first!

	swep:SetBusy(true)

	swep:GetOwner():SetAnimation(PLAYER_IDLE)
	swep:SendWeaponAnim(ACT_VM_DRAW) // Play draw anim

	local timerID = "zbl_gun_drawanim_" .. swep:EntIndex() .. "_timer"
	zclib.Timer.Remove(timerID)

	zclib.Timer.Create(timerID,0.9,1,function()
		zclib.Timer.Remove(timerID)

		if IsValid(swep) and IsValid(swep:GetOwner()) and IsValid(swep:GetOwner():GetActiveWeapon()) and swep:GetOwner():GetActiveWeapon():GetClass() == "zbl_gun"  then

			zbl.Injector.PlayIdleAnim(swep)
		end
	end)
end

function zbl.Injector.PlayIdleAnim(swep)
	if not IsValid(swep) then return end // Safety first!

	swep:SendWeaponAnim(ACT_VM_IDLE)
	swep:GetOwner():SetAnimation(PLAYER_IDLE)
	swep:SetBusy(false)
end

function zbl.Injector.PlaySelfInjectAnim(swep)
	if not IsValid(swep) then return end // Safety first!

	swep:SetBusy(true)

	swep:SendWeaponAnim(ACT_VM_THROW)
	swep:GetOwner():SetAnimation(PLAYER_ATTACK1)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

	local timerID = "zbl_gun_selfinjectanim_" .. swep:EntIndex() .. "_timer"
	zclib.Timer.Remove(timerID)

	zclib.Timer.Create(timerID,1.6,1,function()
		zclib.Timer.Remove(timerID)

		if IsValid(swep) and IsValid(swep:GetOwner()) and IsValid(swep:GetOwner():GetActiveWeapon()) and swep:GetOwner():GetActiveWeapon():GetClass() == "zbl_gun"  then

			zbl.Injector.PlayIdleAnim(swep)
		end
	end)
end



function zbl.Injector.SwitchFlask(swep)
	zclib.Debug("zbl.Injector.SwitchFlask")

	if swep.Flasks == nil then
		swep.Flasks = {}
	end

	// Switch to next flask
	local nextFlask = swep:GetSelectedFlask() + 1
	if nextFlask > #swep.Flasks then
		nextFlask = 1
	end
	swep:SetSelectedFlask(nextFlask)

	local _data = swep.Flasks[nextFlask]


	if _data == nil then
		swep.Flasks[nextFlask] = {
			GenType = 0,
			GenValue = 0,
			GenName = "",
			GenPoints = 0,
			GenClass = ""
		}
		_data = swep.Flasks[nextFlask]
	end


	swep:SetGenType(_data.GenType)
	swep:SetGenValue(_data.GenValue)
	swep:SetGenName(_data.GenName)
	swep:SetGenPoints(_data.GenPoints)
	swep:SetGenClass(_data.GenClass)
end

// Returns the first free flask it finds in the gun
function zbl.Injector.GetEmptyFlask(swep)
	local emptyflask_id
	if IsValid(swep) and swep.Flasks then
		for i,v in ipairs(swep.Flasks) do
			if v.GenType == 0 then
				emptyflask_id = i
				break
			end
		end
	end
	return emptyflask_id
end

// Tells us if the current selected flask has any liquid in it
function zbl.Injector.HasLiquid(swep)
	return swep.Flasks[swep:GetSelectedFlask()].GenType > 0
end

function zbl.Injector.AddLiquid(swep,flask_id,gen_type,gen_value,gen_name,gen_points,gen_class)
	swep:SetSelectedFlask(flask_id)
	//local select_flask = swep:GetSelectedFlask()
	local select_flask = flask_id

	swep:SetGenType(gen_type)
	swep.Flasks[select_flask].GenType = gen_type

	swep:SetGenValue(gen_value)
	swep.Flasks[select_flask].GenValue = gen_value

	swep:SetGenName(gen_name)
	swep.Flasks[select_flask].GenName = gen_name

	swep:SetGenPoints(gen_points)
	swep.Flasks[select_flask].GenPoints = gen_points

	swep:SetGenClass(gen_class)
	swep.Flasks[select_flask].GenClass = gen_class

	zbl.Injector.UpdateFlaskSequence(swep)
end

function zbl.Injector.EmptyLiquid(swep,flask_id)
	swep:SetGenType(0)
	swep:SetGenValue(0)
	swep:SetGenName("")
	swep:SetGenPoints(0)
	swep:SetGenClass("")

	swep.Flasks[flask_id] = {
		GenType = 0,
		GenValue = 1,
		GenName = "",
		GenPoints = 0,
		GenClass = ""
	}

	zbl.Injector.UpdateFlaskSequence(swep)
end

function zbl.Injector.ExtractLiquid(swep)
	local tr = swep:GetOwner():GetEyeTrace()

	if tr.Hit and tr.HitPos and zclib.util.InDistance(swep:GetOwner():GetPos(), tr.HitPos, 300) then

		if IsValid(tr.Entity) and tr.Entity:GetClass() == "zbl_lab" and swep:GetGenType() == 1 then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360


			if tr.Entity:GetSampleCount() >= 12 then

				return
			end

			local sample_data = {
				id = swep:GetGenValue(),
				type = swep:GetGenType(),
				name = swep:GetGenName(),
				points = swep:GetGenPoints(),
				class = swep:GetGenClass()
			}

			zbl.Lab.AddSampleData(tr.Entity,sample_data)

			zbl.Injector.EmptyLiquid(swep,swep:GetSelectedFlask())
			swep:GetOwner():EmitSound("zbl_gun_extract")
		else

			if zbl.Flask.DropLimitReached(swep:GetOwner()) then
				return
			end

			local flask = zbl.Flask.Spawn(swep:GetOwner(),tr.HitPos + Vector(0, 0, 15), swep:GetGenType(), swep:GetGenValue(), swep:GetGenName(),swep:GetGenPoints(),swep:GetGenClass())
			zbl.Flask.Add(swep:GetOwner(),flask)

			zbl.Injector.EmptyLiquid(swep,swep:GetSelectedFlask())
			swep:GetOwner():EmitSound("zbl_gun_extract")
		end
	end
end

// Returns true if we have the specified amount of (unique) samples with the specified class
function zbl.Injector.HasFlask(swep,count,unique,genclass, genvalue,gentype)
	zclib.Debug("zbl.Injector.HasUniqueSamples")

	/*
		swep - The swep from the player
		count - How many samples should we have
		unique - Should we only search for unique samples (no duplicates allowed)
		genclass - What class should the sample have
		genvalue - If specified then we also check if the flasks genvalue matches with this
		gentype - Check if the flasks genvalue matches with this
	*/

	local current = 0
	local used_id = {}
	for k, v in pairs(swep.Flasks) do
		// Is this flask a sample with the correct class?
		if v.GenType == gentype and (genclass == nil or v.GenClass == genclass) and (genvalue == nil or v.GenValue == genvalue) then

			// Are we searching for only unique samples?
			if unique then

				// Is this sample unique?
				if table.HasValue(used_id, v.GenValue) == false then
					table.insert(used_id, v.GenValue)
					current = current + 1
				end
			else
				current = current + 1
			end
		end
	end

	if current >= count then
		return true
	else
		return false
	end
end

// Removes the amount of samples which match the class
function zbl.Injector.RemoveFlask(swep,count,unique,genclass,genvalue,gentype)
	zclib.Debug("zbl.Injector.RemoveUniqueSamples")

	local current = 0
	local used_id = {}
	local seleced_flask = swep:GetSelectedFlask()
	for k,v in pairs(swep.Flasks) do

		// Did we allready hit our target count?
		if current >= count then
			break
		end

		// Is this flask a sample with the correct class?
		if v.GenType == gentype and (genclass == nil or v.GenClass == genclass) and (genvalue == nil or v.GenValue == genvalue) then

			// Are we searching for only unique samples?
			if unique then

				if table.HasValue(used_id, v.GenValue) == false then

					table.insert(used_id, v.GenValue)
					current = current + 1

					if k == seleced_flask then
						swep:SetGenType(0)
						swep:SetGenValue(0)
						swep:SetGenName("")
						swep:SetGenPoints(0)
						swep:SetGenClass("")
					end

					swep.Flasks[k] = {
						GenType = 0,
						GenValue = 0,
						GenName = "",
						GenPoints = 0,
						GenClass = ""
					}

				end
			else
				current = current + 1

				if k == seleced_flask then
					swep:SetGenType(0)
					swep:SetGenValue(0)
					swep:SetGenName("")
					swep:SetGenPoints(0)
					swep:SetGenClass("")
				end

				swep.Flasks[k] = {
					GenType = 0,
					GenValue = 0,
					GenName = "",
					GenPoints = 0,
					GenClass = ""
				}
			end
		end
	end

	zbl.Injector.UpdateFlaskSequence(swep)
end




function zbl.Injector.UpdateFlaskSequence(swep)
	// Creates a string sequence which tells us
		// How many flasks
		// What flasks holst which gen type
		// and if the gen type is vaccine but its a ability then we add 100
	local sequence
	for k,v in pairs(swep.Flasks) do
		local val
		if v.GenType == 2 then

			if zbl.Vaccine.IsVirus(v.GenValue) then
				val = v.GenType
			else
				val = tostring(100 + v.GenType)
			end
		else
			val = v.GenType
		end

		if sequence == nil then
			sequence = val
		else
			sequence = sequence .. val
		end

		if k < #swep.Flasks then
			sequence = sequence .. "_"
		end
	end
	zclib.Debug("zbl.Injector.UpdateFlaskSequence: " .. sequence)
	swep:SetFlaskSequence(sequence)
end



// Scans the area arround the player
util.AddNetworkString("zbl_scan_pulse")
function zbl.Injector.Scan(swep)
	local interval = zbl.config.InjectorGun.Scan.interval[zclib.Player.GetRank(swep:GetOwner())]

	if interval == nil then
		interval = zbl.config.InjectorGun.Scan.interval["default"]
	end

	if swep.LastScan ~= nil and (swep.LastScan + interval) > CurTime() then return end

	zclib.NetEvent.Create("zbl_scan_fx", {swep:GetOwner()})

	// Create scan pulse
	net.Start("zbl_scan_pulse")
	net.WriteVector(swep:GetOwner():GetPos())
	net.Send(swep:GetOwner())

	swep:GetOwner():EmitSound("zbl_scan_action")
	swep.LastScan = CurTime()
end

zclib.Hook.Add("PlayerButtonDown", "a_zbl_PlayerButtonDown_Injector", function(ply, key)
	if IsValid(ply) then

		local swep = ply:GetActiveWeapon()

		if IsValid(swep) and swep:GetClass() == "zbl_gun" then

			if key == zbl.config.InjectorGun.Keys.EmptyFlask and zbl.Injector.HasLiquid(swep) then
				zbl.Injector.EmptyLiquid(swep,swep:GetSelectedFlask())
				zclib.Notify(ply, "Chamber removed!", 4)

			elseif key == zbl.config.InjectorGun.Keys.SwitchFlask then
				zbl.Injector.Reload(swep)

			elseif key == zbl.config.InjectorGun.Keys.ExtractFlask and zbl.Injector.HasLiquid(swep) then
				zbl.Injector.ExtractLiquid(swep)

			elseif key == zbl.config.InjectorGun.Keys.SelfInject then
				zbl.Injector.SelfInject(swep)

			elseif key == zbl.config.InjectorGun.Keys.ScanArea then
				zbl.Injector.Scan(swep)

			end
		end
	end
end)
