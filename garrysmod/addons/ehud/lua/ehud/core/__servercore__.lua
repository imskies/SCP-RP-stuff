util.AddNetworkString("ehud.damage_informer")

---------------------------
/// HITMARKERS / IMPACT ///
---------------------------
hook.Add("EntityTakeDamage","ehud.damagehook",function(target, info)

	local attacker = info:GetAttacker()
	if not attacker then return end
	if not IsValid(attacker) then return end
	if not attacker:IsPlayer() then return end

	if not IsValid(target) then return end
	if not target:IsPlayer() then return end

	local damage = info:GetDamage() or 0

	--hitmark data to attacker
	if ehud.config.hitmarkers then
		if target ~= attacker then 
			net.Start("ehud.damage_informer")
				net.WriteBit(false)
				net.WriteFloat(damage)
			net.Send(attacker)
		end
	end

	--hitmarker data to target
	net.Start("ehud.damage_informer")
		net.WriteBit(true)
		net.WriteFloat(damage)
	net.Send(target)
end)

------------------
/// DOORS LIST ///
------------------
util.AddNetworkString("ehud.SendDoorList")
util.AddNetworkString("ehud.RequestDoorList")
local function isDoor( door )
	if door.isDoor and door.isKeysOwnable then
		return (door:isDoor() and door:isKeysOwnable())
	end
end

ehud.door_list = ehud.door_list or {}

--Generate all doors list on map (to use in client)
local function gendoors()
	for _, door in ipairs( ents.GetAll() ) do
		if isDoor( door ) then
			table.insert(ehud.door_list,door:EntIndex())
		end
	end
end

gendoors()

-- Player requested door list
net.Receive("ehud.RequestDoorList", function(len,ply)
	if table.IsEmpty(ehud.door_list) then return end
	if not IsValid(ply) then return end

	net.Start("ehud.SendDoorList")
		esclib:NetWriteCompressedTable(ehud.door_list)
	net.Send(ply)
end)

--voice icons remove
RunConsoleCommand('mp_show_voice_icons', '0')

--------------------
/// VEHICLE DATA ///
--------------------
util.AddNetworkString("ehud.vehicle_informer")
hook.Add("PlayerEnteredVehicle", "ehud.on_player_entered_vehicle", function(ply, veh, seat_num)
	net.Start("ehud.vehicle_informer")
		net.WriteFloat(veh:GetMaxSpeed() or 0)
	net.Send(ply)
end)

-- hook.Add("PlayerLeaveVehicle", "ehud.on_player_leaved_vehicle", function(ply, veh)
-- 	net.Start("ehud.vehicle_informer")
-- 		net.WriteBool(false) --is entered or exited
-- 	net.Send(ply)
-- end)