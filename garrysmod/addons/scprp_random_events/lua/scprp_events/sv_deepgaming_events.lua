local E = SCPRPEvents
local C = E.Config

local function hasRoles(requirements)
    for role, minimum in pairs(requirements) do
        if #E.RolePlayers(role, true) < minimum then return false end
    end
    return true
end

local function spawnObjective(className, anchor, distance, active)
    if not IsValid(anchor) then return nil end

    local ent = ents.Create(className)
    if not IsValid(ent) then return nil end

    ent:SetPos(E.GroundPositionNear(anchor, distance))
    ent:Spawn()
    ent.SCPRPEventSerial = active.Serial
    return ent
end

local function randomFromRole(role)
    local candidates = E.RolePlayers(role, true)
    if #candidates == 0 then return nil end
    return candidates[math.random(#candidates)]
end

local function clearExposure()
    for _, ply in ipairs(player.GetAll()) do
        ply:SetNWFloat("SCPRPEvents_008Exposure", 0)
        ply:SetNWBool("SCPRPEvents_008Infected", false)
    end
end

local function transformInto0492(ply)
    if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return false end
    if ply:GetNWBool("SCPRPEvents_008Transformed", false) or ply:HasWeapon("weapon_ynot049_2") then return false end

    ply:SetNWBool("SCPRPEvents_008Transformed", true)
    ply:SetNWBool("SCPRPEvents_008Infected", false)
    ply:SetNWFloat("SCPRPEvents_008Exposure", 100)

    -- Match the server's existing SCP-049 conversion behavior.
    if ply.RDOTable and ply.SendInformations then
        ply.RDOTable["Mute"] = true
        ply:SendInformations()
    end

    local zombieHealth = 325
    if SCPJobsConfig and SCPJobsConfig[49] and isnumber(SCPJobsConfig[49].ZombieHealth) then
        zombieHealth = SCPJobsConfig[49].ZombieHealth
    end

    ply:SetModel("models/player/zombie_classic.mdl")
    ply:StripWeapons()
    ply:SetMaxHealth(zombieHealth)
    ply:SetHealth(zombieHealth)
    ply:Give("weapon_ynot049_2")
    ply:SelectWeapon("weapon_ynot049_2")
    ply:EmitSound("npc/zombie_poison/pz_warn" .. math.random(1, 2) .. ".wav", 80, 100, 0.9)
    ply:ChatPrint("SCP-008 has fully transformed you into an SCP-008-2 instance.")

    E.Announce("SCP-008 CONVERSION", ply:Nick() .. " has transformed into an SCP-008-2 instance.", 6, "danger")
    return true
end

local function spawnIncidentNPC(active, className, position)
    local npc = ents.Create(className)
    if not IsValid(npc) then return nil end

    npc:SetPos(position)
    npc:SetKeyValue("squadname", "scprp_event_" .. active.Serial)
    npc:Spawn()
    npc:Activate()
    npc.SCPRPEventSerial = active.Serial
    npc.SCPRPIncidentNPC = true
    return npc
end

-- Researchers calibrate each station, then Security authorizes the finished work.
E.Register("containment_calibration", {
    Title = "CONTAINMENT GRID CALIBRATION",
    Description = "Research must calibrate the temporary control stations. Security must authorize each completed calibration.",
    EndMessage = "Containment grid calibration is complete. Chamber stability has improved.",
    TimeoutMessage = "Containment grid calibration expired before all stations were authorized.",
    Duration = 210,
    Weight = 3,
    Effect = "resonance",
    CanRun = function()
        return hasRoles({ Research = 1, Security = 1 })
    end,
    Start = function(active)
        local desired = math.Clamp(math.ceil(#player.GetHumans() / 8), 2, 4)
        active.StationsRemaining = 0

        for _ = 1, desired do
            local anchor = randomFromRole("Research") or E.RandomLivingPlayer()
            if spawnObjective("scprp_event_calibration", anchor, 420, active) then
                active.StationsRemaining = active.StationsRemaining + 1
            end
        end

        if active.StationsRemaining == 0 then error("No calibration stations could be deployed.") end
    end
})

hook.Add("SCPRPEventCalibrationResearch", "SCPRPEvents_CalibrationResearch", function(station, ply)
    local active = E.Active
    if not active or active.Id ~= "containment_calibration" or station.SCPRPEventSerial ~= active.Serial then return end
    E.PayPlayer(ply, C.Rewards.CalibrationResearcher, "Research Calibration")
    E.Announce("CALIBRATION READY", "A control station now requires Security authorization.", 4, "info")
end)

hook.Add("SCPRPEventCalibrationAuthorized", "SCPRPEvents_CalibrationSecurity", function(station, ply)
    local active = E.Active
    if not active or active.Id ~= "containment_calibration" or station.SCPRPEventSerial ~= active.Serial then return end

    E.PayPlayer(ply, C.Rewards.CalibrationSecurity, "Security Authorization")
    active.StationsRemaining = math.max(0, (active.StationsRemaining or 1) - 1)
    E.Announce("STATION AUTHORIZED", active.StationsRemaining .. " calibration station(s) remain.", 4, "success")

    if active.StationsRemaining == 0 then
        for _, target in ipairs(E.RolePlayers("Foundation", true)) do
            target:SetArmor(math.min(100, target:Armor() + 20))
        end
        E.End("objective_complete")
    end
end)

-- SCP-999 becomes a moving morale objective rather than a passive global buff.
E.Register("scp999_morale_tour", {
    Title = "SCP-999 MORALE TOUR",
    Description = "SCP-999 has been cleared for a supervised facility tour. Stay nearby for morale and medical benefits.",
    EndMessage = "SCP-999's supervised morale tour has concluded.",
    Duration = 120,
    Weight = 2,
    Effect = "medical",
    Style = "success",
    CanRun = function()
        for _, ply in ipairs(player.GetAll()) do
            if E.GetJobName(ply) == C.SpecialJobs.SCP999 and ply:Alive() then return true end
        end
        return false
    end,
    Start = function(active)
        for _, ply in ipairs(player.GetAll()) do
            if E.GetJobName(ply) == C.SpecialJobs.SCP999 and ply:Alive() then
                active.SCP999 = ply
                break
            end
        end

        if not IsValid(active.SCP999) and C.IgnoreJobRequirements then
            active.SCP999 = E.RandomLivingPlayer()
        end

        if not IsValid(active.SCP999) then error("SCP-999 is no longer available.") end

        E.EventTimer(5, function(current)
            local wrongJob = not C.IgnoreJobRequirements and E.GetJobName(current.SCP999) ~= C.SpecialJobs.SCP999
            if not IsValid(current.SCP999) or not current.SCP999:Alive() or wrongJob then
                E.End("scp_unavailable")
                return
            end

            for _, ent in ipairs(ents.FindInSphere(current.SCP999:GetPos(), 420)) do
                if IsValid(ent) and ent:IsPlayer() and ent:Alive() and ent ~= current.SCP999 and not E.IsRole(ent, "SCP") then
                    ent:SetHealth(math.min(ent:GetMaxHealth(), ent:Health() + 5))
                    ent:SetArmor(math.min(100, ent:Armor() + 2))
                    ent:SetNWFloat("SCPRPEvents_999Boost", CurTime() + 6)
                end
            end
        end, 24)
    end
})

-- A spreading SCP-008 incident with exposure, hostile infected, and response objectives.
E.Register("scp008_outbreak", {
    Title = "SCP-008 OUTBREAK",
    Description = "Biohazard canisters have ruptured across the site. Avoid exposure, eliminate infected hosts, and have Medical or Research neutralize every leak.",
    EndMessage = "SCP-008 contamination has been neutralized. Remaining personnel are being screened.",
    TimeoutMessage = "SCP-008 response time expired. Emergency cleanup teams have assumed control.",
    Duration = 300,
    Weight = 5,
    Effect = "biohazard",
    CanRun = function()
        return hasRoles({ Foundation = 2, Medical = 1 })
    end,
    Start = function(active)
        clearExposure()
        active.LeaksRemaining = 0
        active.InfectedNPCs = {}
        local desired = math.Clamp(math.ceil(#player.GetHumans() / 8), 2, 5)

        for _ = 1, desired do
            local anchor = E.RandomLivingPlayer()
            local leak = spawnObjective("scprp_event_008leak", anchor, 520, active)
            if IsValid(leak) then
                active.LeaksRemaining = active.LeaksRemaining + 1
                local npc = spawnIncidentNPC(active, "npc_zombie", leak:GetPos() + Vector(math.random(-100, 100), math.random(-100, 100), 10))
                if IsValid(npc) then active.InfectedNPCs[npc] = true end
            end
        end

        if active.LeaksRemaining == 0 then error("No SCP-008 leaks could be deployed.") end

        active.DamageHook = "SCPRPEvents_008Damage_" .. active.Serial
        hook.Add("EntityTakeDamage", active.DamageHook, function(target, damage)
            local attacker = damage:GetAttacker()
            if E.Active ~= active or not IsValid(target) or not target:IsPlayer() or not active.InfectedNPCs[attacker] then return end
            if not C.IgnoreJobRequirements and E.IsRole(target, "SCP") then return end
            target:SetNWFloat("SCPRPEvents_008Exposure", math.min(100, target:GetNWFloat("SCPRPEvents_008Exposure", 0) + 18))
        end)

        active.SpawnHook = "SCPRPEvents_008Spawn_" .. active.Serial
        hook.Add("PlayerSpawn", active.SpawnHook, function(ply)
            ply:SetNWFloat("SCPRPEvents_008Exposure", 0)
            ply:SetNWBool("SCPRPEvents_008Infected", false)
            ply:SetNWBool("SCPRPEvents_008Transformed", false)
        end)

        E.EventTimer(2, function(current)
            for _, ply in ipairs(E.AlivePlayers()) do
                if not C.IgnoreJobRequirements and E.IsRole(ply, "SCP") then
                    ply:SetNWFloat("SCPRPEvents_008Exposure", 0)
                    ply:SetNWBool("SCPRPEvents_008Infected", false)
                    continue
                end

                if ply:GetNWBool("SCPRPEvents_008Transformed", false) then continue end

                local exposure = ply:GetNWFloat("SCPRPEvents_008Exposure", 0)

                for _, leak in ipairs(ents.FindByClass("scprp_event_008leak")) do
                    if leak.SCPRPEventSerial == current.Serial and ply:GetPos():DistToSqr(leak:GetPos()) <= 300 * 300 then
                        local trace = util.TraceLine({ start = leak:GetPos() + Vector(0, 0, 20), endpos = ply:EyePos(), filter = { leak, ply } })
                        if not trace.Hit then exposure = math.min(100, exposure + 7) end
                    end
                end

                ply:SetNWFloat("SCPRPEvents_008Exposure", exposure)
                if exposure >= 100 then
                    transformInto0492(ply)
                    continue
                end

                if exposure >= 60 then
                    ply:SetNWBool("SCPRPEvents_008Infected", true)
                end

                if ply:GetNWBool("SCPRPEvents_008Infected", false) then
                    ply:TakeDamage(3)
                    if math.random(1, 3) == 1 then ply:EmitSound("ambient/voices/cough" .. math.random(1, 4) .. ".wav", 60, 95, 0.55) end

                    for _, nearby in ipairs(ents.FindInSphere(ply:GetPos(), 125)) do
                        if IsValid(nearby) and nearby:IsPlayer() and nearby ~= ply and nearby:Alive() then
                            local immuneSCP = not C.IgnoreJobRequirements and E.IsRole(nearby, "SCP")
                            if not immuneSCP and math.random(1, 100) <= 18 then
                                nearby:SetNWFloat("SCPRPEvents_008Exposure", math.min(100, nearby:GetNWFloat("SCPRPEvents_008Exposure", 0) + 4))
                            end
                        end
                    end
                end
            end
        end, 150)
    end,
    Stop = function(active)
        if active.DamageHook then hook.Remove("EntityTakeDamage", active.DamageHook) end
        if active.SpawnHook then hook.Remove("PlayerSpawn", active.SpawnHook) end
        clearExposure()
    end
})

hook.Add("SCPRPEvent008Neutralized", "SCPRPEvents_008Progress", function(leak, ply)
    local active = E.Active
    if not active or active.Id ~= "scp008_outbreak" or leak.SCPRPEventSerial ~= active.Serial then return end

    E.PayPlayer(ply, C.Rewards.BiohazardNeutralized, "SCP-008 Response")
    active.LeaksRemaining = math.max(0, active.LeaksRemaining - 1)
    E.Announce("BIOHAZARD NEUTRALIZED", active.LeaksRemaining .. " SCP-008 leak(s) remain.", 5, "success")
    if active.LeaksRemaining == 0 then E.End("objective_complete") end
end)

hook.Add("KeyPress", "SCPRPEvents_008MedicalTreatment", function(ply, key)
    local active = E.Active
    if key ~= IN_USE or not active or active.Id ~= "scp008_outbreak" then return end
    if not C.IgnoreJobRequirements and not E.IsRole(ply, "Medical") then return end
    if (ply.SCPRPNext008Treatment or 0) > CurTime() then return end

    local trace = util.TraceHull({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:GetAimVector() * 100,
        mins = Vector(-10, -10, -10),
        maxs = Vector(10, 10, 10),
        filter = ply
    })
    local patient = trace.Entity
    if not IsValid(patient) or not patient:IsPlayer() or patient:GetNWBool("SCPRPEvents_008Transformed", false) then return end
    if not patient:GetNWBool("SCPRPEvents_008Infected", false) then return end

    ply.SCPRPNext008Treatment = CurTime() + 8
    patient:SetNWBool("SCPRPEvents_008Infected", false)
    patient:SetNWFloat("SCPRPEvents_008Exposure", 25)
    patient:EmitSound("items/medshot4.wav", 65, 100, 0.8)
    patient:ChatPrint("A biohazard responder administered an SCP-008 suppressant.")
    ply:ChatPrint("SCP-008 suppressant administered. Treatment equipment is recharging.")
end)

-- SCP-610 growths create a combat-and-cleanup incident distinct from a player breach.
E.Register("scp610_biomass_bloom", {
    Title = "SCP-610 BIOMASS BLOOM",
    Description = "Anomalous flesh growths are spreading through the site. Armed personnel must destroy the biomass before it produces more infected organisms.",
    EndMessage = "The SCP-610 biomass bloom has been incinerated.",
    TimeoutMessage = "The SCP-610 bloom was not destroyed in time. The affected sector has been sealed.",
    Duration = 270,
    Weight = 4,
    Effect = "biohazard",
    CanRun = function()
        return hasRoles({ Foundation = 3, Security = 1 })
    end,
    Start = function(active)
        active.GrowthsRemaining = 0
        active.InfectedNPCs = {}
        local desired = math.Clamp(math.ceil(#player.GetHumans() / 10), 2, 4)

        for _ = 1, desired do
            local growth = spawnObjective("scprp_event_610growth", E.RandomLivingPlayer(), 600, active)
            if IsValid(growth) then active.GrowthsRemaining = active.GrowthsRemaining + 1 end
        end

        if active.GrowthsRemaining == 0 then error("No SCP-610 growths could be deployed.") end

        E.EventTimer(18, function(current)
            local growths = {}
            for _, growth in ipairs(ents.FindByClass("scprp_event_610growth")) do
                if growth.SCPRPEventSerial == current.Serial then growths[#growths + 1] = growth end
            end
            if #growths == 0 then return end

            local growth = growths[math.random(#growths)]
            local className = math.random(1, 4) == 1 and "npc_fastzombie" or "npc_zombie"
            local npc = spawnIncidentNPC(current, className, growth:GetPos() + Vector(math.random(-120, 120), math.random(-120, 120), 12))
            if IsValid(npc) then current.InfectedNPCs[npc] = true end
        end, 14)
    end
})

hook.Add("SCPRPEvent610Destroyed", "SCPRPEvents_610Progress", function(growth, attacker)
    local active = E.Active
    if not active or active.Id ~= "scp610_biomass_bloom" or growth.SCPRPEventSerial ~= active.Serial then return end

    if IsValid(attacker) and attacker:IsPlayer() then
        E.PayPlayer(attacker, C.Rewards.BiomassDestroyed, "SCP-610 Incineration")
    end
    active.GrowthsRemaining = math.max(0, active.GrowthsRemaining - 1)
    E.Announce("BIOMASS DESTROYED", active.GrowthsRemaining .. " SCP-610 growth(s) remain.", 5, "success")
    if active.GrowthsRemaining == 0 then E.End("objective_complete") end
end)

hook.Add("SetupMove", "SCPRPEvents_IncidentMovement", function(ply, move)
    if ply:GetNWFloat("SCPRPEvents_999Boost", 0) > CurTime() then
        move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 1.08)
        move:SetMaxSpeed(move:GetMaxSpeed() * 1.08)
    end

    if ply:GetNWBool("SCPRPEvents_008Infected", false) then
        move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 0.78)
        move:SetMaxSpeed(move:GetMaxSpeed() * 0.78)
    end
end)

hook.Add("PlayerDeath", "SCPRPEvents_Clear008Transformation", function(ply)
    ply:SetNWFloat("SCPRPEvents_008Exposure", 0)
    ply:SetNWBool("SCPRPEvents_008Infected", false)
    ply:SetNWBool("SCPRPEvents_008Transformed", false)
end)
