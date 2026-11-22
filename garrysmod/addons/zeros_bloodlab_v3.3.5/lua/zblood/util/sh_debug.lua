/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

zbl = zbl or {}


local names = {"Peter", "Franz", "Juliet", "Naomi", "Henry","William","Hector","Donald","Goofy","Mickey"}

if SERVER then


	concommand.Add("zbl_debug_AddBotsToList", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			for k,v in pairs(player.GetAll()) do
				if IsValid(v) and v:IsBot() then
					zclib.Player.Add(v)
				end
			end
		end
	end)

	concommand.Add("zbl_debug_GetPlayermodel", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			print(ply:GetModel())
		end
	end)

	concommand.Add("zbl_debug_SetPlayermodel", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			local path = args[1]
			ply:SetModel(tostring(path))
		end
	end)

	concommand.Add("zbl_debug_VN_Print", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			PrintTable(zbl.Node.List)
		end
	end)

	concommand.Add("zbl_debug_InfectProximity", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			local vac_id = tonumber(args[1]) or 1
			local tr = ply:GetEyeTrace()

			if tr.Hit and tr.HitPos then
				zclib.NetEvent.Create("zbl_node_explode", {tr.HitPos})

				local vData = {
				    vaccine_id = vac_id,
				    vaccine_stage = 1,
				    inflictor = ply,
				    infect_type = "debug_InfectProximity"
				}

				zbl.Infect.Proximity(tr.HitPos, 150, 75,vData)
			end
		end
	end)


	/////////////// Virus Stats
	////////////////////////////////////////////
	concommand.Add("zbl_debug_VSS_Print", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) and zbl.VirusStatistics then
			PrintTable(zbl.VirusStatistics)
		end
	end)
	concommand.Add("zbl_debug_VSS_Refresh", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        zbl.VirusStatistics = {}

	        for k, v in pairs(zbl.Vaccine.GetAll()) do
	            if zbl.Vaccine.IsVirus(k) then
	                zbl.VirusStatistics[k] = {}

	                for i = 1, 4 do
	                    if zbl.VirusStatistics[k][i] == nil then
	                        zbl.VirusStatistics[k][i] = 0
	                    end
	                end
	            end
	        end
	        zbl.Sign.UpdateClients()
	    end
	end)


	/////////////// Object Contamination
	////////////////////////////////////////////
	concommand.Add("zbl_debug_Ctmn_Show", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			zbl.Contamination.DebugShow(ply)
		end
	end)

	concommand.Add("zbl_debug_Ctmn_Print", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			PrintTable(zbl.ContaminatedObjects)
			print("Count: " .. table.Count(zbl.ContaminatedObjects))
		end
	end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

	concommand.Add("zbl_debug_Ctmn_SetupTimer", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        zbl.Contamination.SetupTimer()
	    end
	end)

	concommand.Add("zbl_debug_Ctmn_ObjectContaminate", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        local tr = ply:GetEyeTrace()
	        if tr.Hit and IsValid(tr.Entity) then
	            zbl.Contamination.ObjectContaminate(tr.Entity,tonumber(args[1]))
	        end
	    end
	end)

	concommand.Add("zbl_debug_Ctmn_Auto_SetupTimer", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        zbl.Contamination.Auto_SetupTimer()
	    end
	end)

	concommand.Add("zbl_debug_Ctmn_ClearObjects", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			zbl.Contamination.ClearAll(ply)
		end
	end)

	/////////////// FLASK
	////////////////////////////////////////////
	concommand.Add("zbl_debug_flask_blood_unique", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        local tr = ply:GetEyeTrace()

	        if tr.Hit then
	            zbl.Flask.Spawn(ply,tr.HitPos + Vector(0, 0, 15), 1, math.random(1,500), names[math.random(#names)],math.random(3,10),"player")
	        end
	    end
	end)

	concommand.Add("zbl_debug_flask_blood", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()

			if tr.Hit then
				zbl.Flask.Spawn(ply,tr.HitPos + Vector(0, 0, 15), 1, 666, "Gorden",25,"player")
			end
		end
	end)

	concommand.Add("zbl_debug_flask_random", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        local tr = ply:GetEyeTrace()

	        if tr.Hit and tr.HitPos then
	            for i = 1, 10 do
	                local _type = math.random(1, 3)
	                local eang = ply:EyeAngles()
	                local _pos = tr.HitPos + Vector(0, 0, 15) + eang:Right() * (15 * i)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

	                if _type == 1 then

	                    zbl.Flask.Spawn(ply, _pos, _type, math.random(1, 500), "Ricky Gaysultanova ", 25, "player")
	                elseif _type == 2 or _type == 3 then

	                    local vac_id = math.random(zbl.Vaccine.GetCount())
	                    zbl.Flask.Spawn(ply, _pos, _type, vac_id, zbl.Vaccine.GetName(vac_id), 0, "")
	                end
	            end
	        end
	    end
	end)

	concommand.Add("zbl_debug_flask_cures", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        local tr = ply:GetEyeTrace()

	        if tr.Hit and tr.HitPos then

				for k, v in pairs(zbl.Vaccine.GetAll()) do
					local eang = ply:EyeAngles()
					local _pos = tr.HitPos + Vector(0, 0, 15) + eang:Right() * (15 * k)
					local vac_id = k
					zbl.Flask.Spawn(ply, _pos, 3, vac_id, zbl.Vaccine.GetName(vac_id), 0, "")
				end
	        end
	    end
	end)

	concommand.Add("zbl_debug_flask_vaccines", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()

			if tr.Hit and tr.HitPos then

				for k, v in pairs(zbl.Vaccine.GetAll()) do
					local eang = ply:EyeAngles()
					local _pos = tr.HitPos + Vector(0, 0, 15) + eang:Right() * (15 * k)
					local vac_id = k
					zbl.Flask.Spawn(ply, _pos, 2, vac_id, zbl.Vaccine.GetName(vac_id), 0, "")
				end
			end
		end
	end)

	concommand.Add("zbl_debug_flask", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()

			if tr.Hit and tr.HitNormal then
				local _type = math.Clamp(tonumber(args[1]), 2, 3)
				local vac_id = tonumber(args[2])
				local _pos = tr.HitPos + Vector(0, 0, 15)
				zbl.Flask.Spawn(nil, _pos, _type, vac_id, zbl.Vaccine.GetName(vac_id), 0, "")
			end
		end
	end)


	/////////////// GASMASK
	////////////////////////////////////////////
	concommand.Add("zbl_debug_GasMask_switch", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	       if zbl.GasMask.Has(ply) then
			   zbl.GasMask.Equipt(ply,false)
		   else
			   zbl.GasMask.Equipt(ply,true)
		   end
	    end
	end)
	concommand.Add("zbl_debug_GasMask_EquiptID", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			local maskID = tonumber(args[1])
			zbl.GasMask.Give(ply, maskID)

			zclib.Debug("zbl_Gasmask_Equipt: " .. tostring(ply) .. " " .. tostring(true) .. " MaskID: " .. maskID .. " Uses: " .. zbl.GasMask.GetUses(ply))


			net.Start("zbl_Gasmask_Equipt")
			net.WriteEntity(ply)
			net.WriteBool(true)
			net.WriteInt(maskID,6)
			net.Broadcast()
		end
	end)

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c


	/////////////// VIRUS HOTSPOTS
	////////////////////////////////////////////
	concommand.Add("zbl_debug_VHS_SetupTimer", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        zbl.HotSpot.SetupTimer()
	    end
	end)

	// Adds a new position
	concommand.Add("zbl_debug_VHS_AddPos", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        local pt = ply:GetEyeTrace()

	        if pt.Hit and pt.HitPos then
	            local _ang = pt.HitNormal:Angle()
	            _ang:RotateAroundAxis(_ang:Right(), -90)

				zbl.HotSpot.AddPos(pt.HitPos,_ang,ply)

	            debugoverlay.Sphere( pt.HitPos, 3, 1, Color(255, 0, 0), true)
	            debugoverlay.Line( pt.HitPos, pt.HitPos + _ang:Up() * 100, 1, Color(255, 0, 0), true)
	        end
	    end
	end)

	// Shows all existing positions (Only works on developer 1)
	concommand.Add("zbl_debug_VHS_ShowPos", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        for k, v in pairs(zbl.HotSpot.Positions) do
	            if v then
	                debugoverlay.Sphere(v.pos, 3, 1, Color(255, 0, 0), true)
	                debugoverlay.Line(v.pos, v.pos + v.ang:Up() * 100, 1, Color(255, 0, 0), true)
	            end
	        end

	        PrintTable(zbl.HotSpot.Positions)
	    end
	end)

	// Clears all positions
	concommand.Add("zbl_debug_VHS_ClearPos", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        zbl.HotSpot.Positions = {}
	    end
	end)

	// Purges all the Virus Hotspots
	concommand.Add("zbl_debug_VHS_Purge", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
			for k,v in pairs(zbl.HotSpot.CoreNodes) do
				if IsValid(v) then
		            SafeRemoveEntity(v)
					zbl.HotSpot.CoreNodes[k] = nil
		        end
			end
	    end
	end)

	// Starts a Hotspot at the point you are looking
	concommand.Add("zbl_debug_VHS_StartHere", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then

		    zbl.HotSpot.SetupTimer()

		    zbl.HotSpot.Positions = {}

		    local pt = ply:GetEyeTrace()

		    if pt.Hit and pt.HitPos then
		        local _ang = pt.HitNormal:Angle()
		        _ang:RotateAroundAxis(_ang:Right(), -90)

		        table.insert(zbl.HotSpot.Positions, {
		            pos = pt.HitPos,
		            ang = _ang
		        })

		        debugoverlay.Sphere( pt.HitPos, 3, 1, Color(255, 0, 0), true)
		        debugoverlay.Line( pt.HitPos, pt.HitPos + _ang:Up() * 100, 1, Color(255, 0, 0), true)
		    end
		end
	end)

	// Gives all the virus nodes full health
	concommand.Add("zbl_debug_VHS_MaxHealth", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        for k, v in pairs(zbl.Node.List) do
	            if IsValid(v) then
	                zbl.Node.ChangeHealth(v, zbl.config.VirusHotspots.node_health_max)
	            end
	        end
	    end
	end)

	// Saves all the HotSpot position to a txt file
	concommand.Add("zbl_debug_VHS_SavePos", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        zbl.HotSpot.Save(ply)
	    end
	end)

	// Removes all the HotSpots positions for the current map
	concommand.Add("zbl_debug_VHS_RemovePos", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			zbl.HotSpot.RemoveAll(ply)

			for k,v in pairs(zbl.HotSpot.CoreNodes) do
				if IsValid(v) then
					SafeRemoveEntity(v)
					zbl.HotSpot.CoreNodes[k] = nil
				end
			end

			zbl.HotSpot.ShowAll(ply)
		end
	end)

	concommand.Add("zbl_debug_VHS_PrintLists", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
			print("///////////////////////////////////")
			PrintTable(zbl.HotSpot.CoreNodes)
			print("__________________________")
			PrintTable(zbl.HotSpot.SlaveNodes)
			print("///////////////////////////////////")
	    end
	end)




	/////////////// NPC ENTITY
	////////////////////////////////////////////
	concommand.Add("zbl_debug_NPC_SetQuest", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        local tr = ply:GetEyeTrace()

	        if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "zbl_npc" then
				ply.zbl_Quest = {
					id = math.random(#zbl.config.NPC.quests),
					request_time = CurTime(),
					start_time = -1,
					accepted = false,
					npc = tr.Entity
				}
	        end
	    end
	end)



	/////////////// LAB ENTITY
	////////////////////////////////////////////
	concommand.Add("zbl_debug_lab", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        local tr = ply:GetEyeTrace()
	        if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "zbl_lab" then
	            print(tr.Entity:GetActionState())
	        end
	    end
	end)



	/////////////// VIRUS OCCOPATING
	////////////////////////////////////////////
	concommand.Add("zbl_debug_OV_SetupTimer", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        zbl.Occopation.SetupTimer()
	    end
	end)



	/////////////// INJECTOR GUN
	////////////////////////////////////////////
	concommand.Add("zbl_debug_InjectorLoadout", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			local swep = ply:GetWeapon("zbl_gun")

			if IsValid(swep) then
				for k, v in pairs(swep.Flasks) do
					local gn = math.random(0, 3)
					v.GenType = gn

					if gn == 2 or gn == 3 then
						local vac_id = math.random(zbl.Vaccine.GetCount())
						v.GenValue = vac_id
						v.GenName = zbl.Vaccine.GetName(vac_id)
						v.GenPoints = 0
					elseif gn == 1 then
						local name = names[math.random(#names)]
						v.GenValue = math.random(5, 999)
						v.GenName = name
						v.GenPoints = 25
						v.GenClass = "player"
					end
				end

				local _data = swep.Flasks[swep:GetSelectedFlask()]

				swep:SetGenType(_data.GenType)
				swep:SetGenValue(_data.GenValue)
				swep:SetGenName(_data.GenName)
				swep:SetGenPoints(_data.GenPoints)
				swep:SetGenClass(_data.GenClass)
			end
		end
	end)

	concommand.Add("zbl_debug_InjectorLoadout_PlayerSample", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			local swep = ply:GetWeapon("zbl_gun")

			if IsValid(swep) then
				for k, v in pairs(swep.Flasks) do
					v.GenType = 1
					v.GenValue = math.random(5, 999)
					v.GenName = names[math.random(#names)]
					v.GenPoints = 25
					v.GenClass = "player"
				end

				local _data = swep.Flasks[swep:GetSelectedFlask()]

				swep:SetGenType(_data.GenType)
				swep:SetGenValue(_data.GenValue)
				swep:SetGenName(_data.GenName)
				swep:SetGenPoints(_data.GenPoints)
				swep:SetGenClass(_data.GenClass)
			end
		end
	end)



	/////////////// VACCINES
	////////////////////////////////////////////
	// Infected yourself with the provided virus id
	concommand.Add("zbl_debug_vaccinate_self", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        local vaccineID = tonumber(args[1]) or 1
	        local vaccineStage = tonumber(args[2]) or 1

	        if zbl.Vaccine.IsValidMutationStage(vaccineID,vaccineStage) then
				zbl.Player.Vaccinate(ply,vaccineID,vaccineStage,ply)
	        end
	    end
	end)

	// Infected target with the provided virus id
	concommand.Add("zbl_debug_vaccinate_target", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        local tr = ply:GetEyeTrace()
	        if tr.Hit and IsValid(tr.Entity) and tr.Entity:IsPlayer() and tr.Entity:Alive() then
				local vaccineID = tonumber(args[1]) or 1
		        local vaccineStage = tonumber(args[2]) or 1
	            if vaccineID then
	                zbl.Player.Vaccinate(tr.Entity,vaccineID,vaccineStage,ply)
	            end
	        end
	    end
	end)

	// Infected all with the provided virus id
	concommand.Add("zbl_debug_vaccinate_all", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
			local vaccineID = tonumber(args[1]) or 1
			local vaccineStage = tonumber(args[2]) or 1

	        if vaccineID then
	            for k,v in pairs(zclib.Player.List) do
	                if IsValid(v) then
	                    zbl.Player.Vaccinate(v,vaccineID,vaccineStage,ply)
	                end
	            end
	        end
	    end
	end)

	concommand.Add("zbl_debug_ForceCure", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then

	        for k,v in pairs(zclib.Player.List) do
	            if IsValid(v) and v:Alive() and zbl.Vaccine.Has(v) then

					// Custom Hook
					hook.Run("zbl_OnPlayerCurePlayer" ,v, zbl.Vaccine.Get(v),ply)

	                zbl.Player.ForceCure(v)
	            end
	        end
	    end
	end)

	concommand.Add("zbl_debug_Cure_Self", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) and zbl.Vaccine.Has(ply) then

			// Custom Hook
			hook.Run("zbl_OnPlayerCurePlayer" ,ply, zbl.Vaccine.Get(ply),ply)

			zbl.Player.ForceCure(ply)
		end
	end)

	concommand.Add("zbl_debug_Cure_Near", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then

	        for k,v in pairs(zclib.Player.List) do
	            if IsValid(v) and zclib.util.InDistance(ply:GetPos(), v:GetPos(), 500) and v:Alive() and zbl.Vaccine.Has(v) then

					// Custom Hook
					hook.Run("zbl_OnPlayerCurePlayer" ,v, zbl.Vaccine.Get(v),ply)

	                zbl.Player.ForceCure(v)
	            end
	        end
	    end
	end)



	/////////////// VIRUsNODES
	////////////////////////////////////////////
	concommand.Add("zbl_debug_createnode", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()

			if tr.Hit and tr.HitPos then
				local ang = tr.HitNormal:Angle()
				ang:RotateAroundAxis(ang:Right(), -90)
				local ent = zbl.Node.CreateNode(tr.HitPos, ang, math.Clamp(tonumber(args[1] or 1),1,zbl.Vaccine.GetCount()), 1)

				zbl.Node.ChangeHealth(ent,zbl.config.VirusHotspots.node_health_max)
			end
		end
	end)

	concommand.Add("zbl_debug_VN_TraceTest", function(ply, cmd, args)
	    if zclib.Player.IsAdmin(ply) then
	        local pt = ply:GetEyeTrace()

	        if pt.Hit then
	            local pos , ang

	            if IsValid(pt.Entity) then
	                pos = pt.Entity:GetPos() + pt.Entity:GetUp() * 50
	                ang = pt.Entity:GetAngles()
	            else
	                pos = pt.HitPos + pt.HitNormal:Angle():Forward() * 50
	                ang = Angle(0,0,0)
	            end

	            for i = 1, 100 do
	                zbl.Node.PerformSpawnTrace(pos,ang,1000)
	            end
	        end
	    end
	end)

	concommand.Add("zbl_debug_VN_removeall", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			//  Kill all nodes
			for k, v in pairs(ents.FindByClass("zbl_virusnode")) do
				if IsValid(v) then
					SafeRemoveEntity(v)
				end
			end
		end
	end)


                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

	/////////////// CORPSES
	////////////////////////////////////////////
	concommand.Add("zbl_debug_corpse_create", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			zbl.Corpse.Spawn(ply,tonumber(args[1] or 1),1)
		end
	end)

	concommand.Add("zbl_debug_corpse_removeall", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then

			//  Kill all nodes
			for k, v in pairs(ents.FindByClass("zbl_corpse")) do
				if IsValid(v) then
					SafeRemoveEntity(v)
				end
			end
		end
	end)

	concommand.Add("zbl_debug_corpse_graveyard", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			local virusID = tonumber(args[1] or 1)
			if zbl.Vaccine.IsValid(virusID) == false then return end

			for i = 1, 15 do
				local pos = ply:GetPos() + zclib.util.GetRandomPositionInsideCircle(50,300,10)
				zbl.Corpse.SpawnAtPos(ply, pos, virusID, 1)
			end
		end
	end)

else


	/////////////// SYMPTOMES
	////////////////////////////////////////////
	concommand.Add("zbl_debug_runninghooks", function(ply, cmd, args)
		if zclib.Player.IsAdmin(ply) then
			PrintTable(zbl.RunningHooks)
		end
	end)
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24


/////////////// Display Player Infection
////////////////////////////////////////////
if SERVER then

	util.AddNetworkString("zbl_PlayerInfection_Show")
	local function ShowPlayerInfection(ply)

		local new_tbl = {}
		for k, v in pairs(player.GetAll()) do
			if IsValid(v) then
				local id = zbl.Vaccine.Get(v)

				if id and id > 0 then
					table.insert(new_tbl, v)
				end
			end
		end

		net.Start("zbl_PlayerInfection_Show")

		local len = #new_tbl
		net.WriteUInt(len, 16)

		for i = 1, len do
			net.WriteEntity(new_tbl[ i ])
		end

		net.Send(ply)
	end
	concommand.Add("zbl_debug_infection_Show", function(ply, cmd, args) if zclib.Player.IsAdmin(ply) then ShowPlayerInfection(ply) end end)

end
