if SERVER then
    util.AddNetworkString("DeepSCPDestroyDoor")

    -- Spawns a non-solid, non-physics prop that looks like the door lying on the ground.
    -- Returns the created entity (or nil if it failed).
    local function DeepSCP_SpawnFallenDoor(visibleDoor, hingePos)
        if not IsValid(visibleDoor) then
            print("[SCP3199] SpawnFallenDoor: visibleDoor invalid, aborting")
            return nil
        end

        local model = visibleDoor:GetModel()
        util.PrecacheModel(model)

        local fallen = ents.Create("prop_dynamic")
        if not IsValid(fallen) then
            print("[SCP3199] SpawnFallenDoor: ents.Create('prop_dynamic') FAILED")
            return nil
        end

        fallen:SetModel(model)

        -- Tip the door over so it looks like it fell flat.
        local ang = visibleDoor:GetAngles()
        ang.r = ang.r + 90                                    -- roll = rotation around the door's own forward axis, knocks it onto its side/face
        ang.y = ang.y + math.random(-15, 15)                  -- slight random scatter so they don't look identical

        -- NOTE: spawning at the EXACT same spot as the original door for now (no floor offset).
        -- Once you confirm you can see it, tweak position/offset from here as needed.
        local pos = visibleDoor:GetPos()

        fallen:SetAngles(ang)
        fallen:SetPos(pos)
        fallen:Spawn()

        fallen:SetSolid(SOLID_NONE)
        fallen:SetNotSolid(true)
        fallen:SetCollisionGroup(COLLISION_GROUP_WORLD)
        fallen:SetMoveType(MOVETYPE_NONE)
        fallen:DrawShadow(true)

        return fallen
    end

    function DeepSCP_DestroyDoor(target, destroyer, wep)
        local pos
        if IsValid(target) then
            pos = target:GetPos()
        elseif isvector(target) then
            pos = target
        else
            return
        end

        local doors = ents.FindInSphere(pos, 90)
        local sent = false

        for _, v in ipairs(doors) do
            if v:GetClass() ~= "func_door" then continue end

            local visibleDoor = nil
            local nearby = ents.FindInSphere(v:GetPos(), 120)
            for _, ent in ipairs(nearby) do
                if not IsValid(ent) then continue end
                local class = ent:GetClass()
                if class == "prop_dynamic" or
                   class == "prop_dynamic_override" or
                   class == "prop_physics" or
                   class == "prop_physics_multiplayer" then
                    if wep.DestroyModels[ent:GetModel()] then
                        visibleDoor = ent
                        break
                    end
                end
            end

            if not IsValid(visibleDoor) then continue end

            if not sent then
                net.Start("DeepSCPDestroyDoor")
                    net.WriteEntity(visibleDoor)
                    net.WriteEntity(v)
                    net.WriteVector(v:GetPos())
                    net.WriteAngle(visibleDoor:GetAngles())
                    net.WriteFloat(wep.RespawnTime or 180)
                net.Broadcast()
                sent = true
            end

            -- Hide/disable the original door + visible prop
            v:SetNoDraw(true)
            v:SetNotSolid(true)
            visibleDoor:SetNoDraw(true)
            visibleDoor:SetNotSolid(true)

            -- Create the fallen "wreckage" version on the ground
            local fallenDoor = DeepSCP_SpawnFallenDoor(visibleDoor, v:GetPos())

            timer.Simple(wep.RespawnTime or 180, function()
                if IsValid(v) then
                    v:SetNoDraw(false)
                    v:SetNotSolid(false)
                end
                if IsValid(visibleDoor) then
                    visibleDoor:SetNoDraw(false)
                    visibleDoor:SetNotSolid(false)
                end
                -- Clean up the fallen prop once the door respawns
                if IsValid(fallenDoor) then
                    fallenDoor:Remove()
                end
            end)
        end
    end
end