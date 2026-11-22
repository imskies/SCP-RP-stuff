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

local function spawnResearchDevice(anchor, distance, active, label, action, mode)
    local ent = spawnObjective("scprp_event_research_device", anchor, distance, active)
    if not IsValid(ent) then return nil end

    ent:SetDeviceLabel(label or "RESEARCH DEVICE")
    ent:SetActionLabel(action or "HOLD E")
    ent.SCPRPDeviceMode = mode
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

local function clear610Exposure()
    for _, ply in ipairs(player.GetAll()) do
        ply:SetNWFloat("SCPRPEvents_610Exposure", 0)
    end
end

local function transformInto610(ply)
    if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return false end
    if ply:GetNWBool("SCPRPEvents_610Transformed", false) or ply:HasWeapon("weapon_ynot610") then return false end

    ply:SetNWBool("SCPRPEvents_610Transformed", true)
    ply:SetNWFloat("SCPRPEvents_610Exposure", 100)
    ply:SetModel("models/player/zombie_soldier.mdl")
    ply:StripWeapons()
    ply:Give("weapon_ynot610")
    ply:SelectWeapon("weapon_ynot610")
    ply:EmitSound("npc/zombie_poison/pz_alert" .. math.random(1, 2) .. ".wav", 80, 92, 0.9)
    ply:ChatPrint("The SCP-610 biomass has converted you into an SCP-610 instance.")

    E.Announce("SCP-610 CONVERSION", ply:Nick() .. " has transformed into an SCP-610 instance.", 6, "danger")
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

local function clearCognitoExposure()
    for _, ply in ipairs(player.GetAll()) do
        ply:SetNWFloat("SCPRPEvents_CognitoExposure", 0)
        ply:SetNWBool("SCPRPEvents_CognitoExposed", false)
    end
end

local function makeCognitoExposed(active, ply)
    if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return false end
    if ply:GetNWBool("SCPRPEvents_CognitoExposed", false) then return false end
    if not C.IgnoreJobRequirements and E.IsRole(ply, "SCP") then return false end

    ply:SetNWBool("SCPRPEvents_CognitoExposed", true)
    ply:SetNWFloat("SCPRPEvents_CognitoExposure", 100)
    ply:EmitSound("ambient/voices/psycho1.wav", 65, 100, 0.65)
    ply:ChatPrint("You remember something that never happened. Research personnel should interview you immediately.")

    active.CognitoSubjects = active.CognitoSubjects or {}
    active.CognitoSubjects[ply] = true
    return true
end

local function findNearbySubject(origin, radius, preferDClass, exclude)
    local fallback = nil

    for _, ent in ipairs(ents.FindInSphere(origin, radius or 160)) do
        if IsValid(ent) and ent:IsPlayer() and ent:Alive() and ent ~= exclude then
            if preferDClass and E.IsRole(ent, "DClass") then return ent end
            fallback = fallback or ent
        end
    end

    return fallback
end

local function randomTemporalMessage(ply)
    local messages = {
        "You hear your own voice say something five seconds early.",
        "A warning from tomorrow flickers across your thoughts.",
        "Your last step happens twice.",
        "The air smells like burned copper and old rain.",
        "For a moment, the hallway remembers being somewhere else."
    }

    ply:ChatPrint(messages[math.random(#messages)])
end

local function clearMedicalScreening()
    for _, ply in ipairs(player.GetAll()) do
        ply:SetNWBool("SCPRPEvents_MedicalScreening", false)
        ply:SetNWBool("SCPRPEvents_AnomalousCarrier", false)
    end
end

local function setSiteLights(on)
    local input = on and "TurnOn" or "TurnOff"
    for _, ent in ipairs(ents.FindByName("light_all")) do
        if IsValid(ent) then ent:Fire(input, "", 0) end
    end
end

local function fireNamedTarget(name, input)
    for _, ent in ipairs(ents.FindByName(name)) do
        if IsValid(ent) then ent:Fire(input, "", 0) end
    end
end

local function flickerSiteLights(active)
    setSiteLights(false)
    timer.Simple(0.25, function()
        if not active or E.Active == active then setSiteLights(true) end
    end)
    timer.Simple(0.55, function()
        if not active or E.Active == active then setSiteLights(false) end
    end)
end

local function applyManifestEffect(device, ply, objectType)
    local pos = device:GetPos()
    local label = objectType or "unstable"

    if label == "harmless" then
        device:EmitSound("buttons/button14.wav", 65, 120, 0.65)
    elseif label == "unstable" then
        util.BlastDamage(device, IsValid(ply) and ply or device, pos, 190, 18)
        device:EmitSound("ambient/energy/spark" .. math.random(1, 6) .. ".wav", 75, 95, 0.85)
    elseif label == "cognitohazard" then
        for _, target in ipairs(ents.FindInSphere(pos, 260)) do
            if IsValid(target) and target:IsPlayer() and target:Alive() then
                target:SetNWFloat("SCPRPEvents_CognitoExposure", math.min(70, target:GetNWFloat("SCPRPEvents_CognitoExposure", 0) + 25))
                randomTemporalMessage(target)
                target:EmitSound("ambient/voices/psycho" .. math.random(1, 4) .. ".wav", 55, 95, 0.45)
            end
        end
    elseif label == "energetic" then
        for _, target in ipairs(ents.FindInSphere(pos, 230)) do
            if IsValid(target) and target:IsPlayer() and target:Alive() then
                target:SetArmor(math.min(100, target:Armor() + 10))
                target:SetNWFloat("SCPRPEvents_999Boost", CurTime() + 5)
            end
        end
        device:EmitSound("ambient/energy/newspark03.wav", 75, 125, 0.8)
    elseif label == "biological" then
        for _, target in ipairs(ents.FindInSphere(pos, 230)) do
            if IsValid(target) and target:IsPlayer() and target:Alive() then
                target:EmitSound("ambient/voices/cough" .. math.random(1, 4) .. ".wav", 55, 95, 0.5)
                target:SetNWFloat("SCPRPEvents_TemporalSlow", CurTime() + 4)
            end
        end
    else
        for _, target in ipairs(ents.FindInSphere(pos, 250)) do
            if IsValid(target) and target:IsPlayer() and target:Alive() then
                target:SetVelocity(Vector(math.random(-220, 220), math.random(-220, 220), 130))
                randomTemporalMessage(target)
            end
        end
    end

    return string.upper(label)
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

-- Research must locate and stabilize personnel affected by a spreading cognitohazard.
E.Register("cognitohazard_interview", {
    Title = "COGNITOHAZARD INTERVIEW",
    Description = "An anomalous thought pattern is spreading through personnel. Research must locate exposed subjects and stabilize them through interview protocol.",
    EndMessage = "The cognitohazard has been documented and stabilized.",
    TimeoutMessage = "The cognitohazard was not fully contained. Memetics teams have assumed control.",
    Duration = 240,
    Weight = 4,
    Effect = "cognito",
    Style = "danger",
    CanRun = function()
        return hasRoles({ Research = 1, Foundation = 2 })
    end,
    Start = function(active)
        clearCognitoExposure()
        active.CognitoRequired = math.Clamp(math.ceil(#player.GetHumans() / 7), 2, 5)
        active.CognitoStabilized = 0
        active.CognitoSubjects = {}

        local first = E.RandomLivingPlayer()
        if not makeCognitoExposed(active, first) then error("No valid cognitohazard subject could be selected.") end

        E.EventTimer(4, function(current)
            local exposedCount = 0
            for ply in pairs(current.CognitoSubjects or {}) do
                if IsValid(ply) and ply:Alive() and ply:GetNWBool("SCPRPEvents_CognitoExposed", false) then
                    exposedCount = exposedCount + 1

                    if math.random(1, 3) == 1 then
                        randomTemporalMessage(ply)
                        ply:EmitSound("ambient/voices/psycho" .. math.random(1, 4) .. ".wav", 55, math.random(92, 108), 0.45)
                    end

                    for _, nearby in ipairs(ents.FindInSphere(ply:GetPos(), 180)) do
                        if IsValid(nearby) and nearby:IsPlayer() and nearby:Alive() and nearby ~= ply then
                            local immuneSCP = not C.IgnoreJobRequirements and E.IsRole(nearby, "SCP")
                            if not immuneSCP and not nearby:GetNWBool("SCPRPEvents_CognitoExposed", false) then
                                local exposure = math.min(100, nearby:GetNWFloat("SCPRPEvents_CognitoExposure", 0) + 10)
                                nearby:SetNWFloat("SCPRPEvents_CognitoExposure", exposure)
                                if exposure >= 100 and exposedCount < current.CognitoRequired + 2 then
                                    if makeCognitoExposed(current, nearby) then exposedCount = exposedCount + 1 end
                                end
                            end
                        end
                    end
                end
            end

            if exposedCount == 0 and (current.CognitoStabilized or 0) < (current.CognitoRequired or 1) then
                makeCognitoExposed(current, E.RandomLivingPlayer())
            end

            for _, ply in ipairs(E.AlivePlayers()) do
                if not ply:GetNWBool("SCPRPEvents_CognitoExposed", false) then
                    ply:SetNWFloat("SCPRPEvents_CognitoExposure", math.max(0, ply:GetNWFloat("SCPRPEvents_CognitoExposure", 0) - 4))
                end
            end
        end, 60)
    end,
    Stop = function()
        clearCognitoExposure()
    end
})

-- A classic SCP-RP testing prompt backed by real randomized anomalous effects.
E.Register("object_testing_request", {
    Title = "SCP OBJECT TESTING REQUEST",
    Description = "Research has been assigned a temporary anomalous object. Bring a test subject nearby and complete controlled trials.",
    EndMessage = "Object testing is complete. Research data has been archived.",
    TimeoutMessage = "The object testing window expired before enough trials were completed.",
    Duration = 210,
    Weight = 3,
    Effect = "resonance",
    Style = "info",
    CanRun = function()
        return hasRoles({ Research = 1, DClass = 1 })
    end,
    Start = function(active)
        active.TestsRequired = math.Clamp(math.ceil(#player.GetHumans() / 9), 3, 5)
        active.TestsCompleted = 0

        local anchor = randomFromRole("Research") or randomFromRole("DClass") or E.RandomLivingPlayer()
        local device = spawnResearchDevice(anchor, 420, active, "ANOMALOUS OBJECT", "HOLD E WITH SUBJECT NEARBY", "object_test")
        if not IsValid(device) then error("No anomalous object could be deployed.") end
        device:SetModel("models/props_lab/jar01b.mdl")
        device.ProgressStep = 5
    end,
    Stop = function()
        for _, ply in ipairs(player.GetAll()) do
            ply:SetNWFloat("SCPRPEvents_TemporalSlow", 0)
            ply:SetNWFloat("SCPRPEvents_CognitoExposure", 0)
        end
    end
})

-- A localized time anomaly that Research must stabilize while reality misbehaves.
E.Register("temporal_research_incident", {
    Title = "TEMPORAL RESEARCH INCIDENT",
    Description = "A temporal rift has formed inside the facility. Research must stabilize nearby anchor devices before the anomaly pulses.",
    EndMessage = "The temporal rift has collapsed safely.",
    TimeoutMessage = "The temporal rift discharged before Research could stabilize it.",
    Duration = 240,
    Weight = 4,
    Effect = "temporal",
    Style = "danger",
    CanRun = function()
        return hasRoles({ Research = 1, Foundation = 2 })
    end,
    Start = function(active)
        active.TemporalRemaining = 0

        local anchor = randomFromRole("Research") or E.RandomLivingPlayer()
        local rift = spawnObjective("scprp_event_temporal_rift", anchor, 520, active)
        if not IsValid(rift) then error("No temporal rift could be deployed.") end
        active.TemporalRift = rift

        local desired = math.Clamp(math.ceil(#player.GetHumans() / 9), 2, 4)
        for _ = 1, desired do
            local device = spawnResearchDevice(rift, 360, active, "TEMPORAL ANCHOR", "RESEARCH: STABILIZE", "temporal_anchor")
            if IsValid(device) then
                device:SetModel("models/props_lab/reciever01d.mdl")
                device.ProgressStep = 4
                active.TemporalRemaining = active.TemporalRemaining + 1
            end
        end

        if active.TemporalRemaining == 0 then error("No temporal anchors could be deployed.") end

        E.EventTimer(5, function(current)
            if not IsValid(current.TemporalRift) then return end

            for _, ply in ipairs(ents.FindInSphere(current.TemporalRift:GetPos(), 520)) do
                if IsValid(ply) and ply:IsPlayer() and ply:Alive() then
                    local roll = math.random(1, 5)
                    if roll == 1 then
                        ply:SetNWFloat("SCPRPEvents_TemporalBoost", CurTime() + 4)
                    elseif roll == 2 then
                        ply:SetNWFloat("SCPRPEvents_TemporalSlow", CurTime() + 4)
                    elseif roll == 3 then
                        ply:SetVelocity(Vector(math.random(-180, 180), math.random(-180, 180), 90))
                    elseif roll == 4 then
                        randomTemporalMessage(ply)
                    else
                        ply:EmitSound("ambient/levels/labs/teleport_mechanism_windup1.wav", 55, math.random(92, 108), 0.28)
                    end
                end
            end
        end, 48)
    end,
    Stop = function()
        for _, ply in ipairs(player.GetAll()) do
            ply:SetNWFloat("SCPRPEvents_TemporalBoost", 0)
            ply:SetNWFloat("SCPRPEvents_TemporalSlow", 0)
        end
    end
})

-- Medical and Research screen D-Class for a low-grade anomalous carrier.
E.Register("dclass_medical_screening", {
    Title = "D-CLASS MEDICAL SCREENING",
    Description = "Medical and Research must screen selected D-Class subjects for abnormal symptoms before the condition spreads.",
    EndMessage = "D-Class screening is complete. Abnormal readings have been contained.",
    TimeoutMessage = "D-Class screening expired. The affected block has been placed under observation.",
    Duration = 220,
    Weight = 3,
    Effect = "medical",
    Style = "info",
    CanRun = function()
        return hasRoles({ DClass = 1, Research = 1 })
    end,
    Start = function(active)
        clearMedicalScreening()
        active.ScreeningSubjects = {}
        active.ScreeningsRequired = math.Clamp(math.ceil(#player.GetHumans() / 8), 2, 5)
        active.ScreeningsComplete = 0

        local candidates = E.RolePlayers("DClass", true)
        if #candidates == 0 or C.IgnoreJobRequirements then candidates = E.AlivePlayers() end
        if #candidates == 0 then error("No valid screening subjects found.") end
        active.ScreeningsRequired = math.min(active.ScreeningsRequired, #candidates)

        local shuffled = table.Copy(candidates)
        for i = #shuffled, 2, -1 do
            local j = math.random(i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
        end

        for i = 1, math.min(active.ScreeningsRequired, #shuffled) do
            local subject = shuffled[i]
            subject:SetNWBool("SCPRPEvents_MedicalScreening", true)
            subject:ChatPrint("You have been selected for emergency medical screening. Report to Medical or Research personnel.")
            active.ScreeningSubjects[subject] = { Carrier = false }
        end

        local carrier = next(active.ScreeningSubjects)
        if IsValid(carrier) then
            active.ScreeningSubjects[carrier].Carrier = true
            carrier:SetNWBool("SCPRPEvents_AnomalousCarrier", true)
        end

        E.EventTimer(8, function(current)
            for subject, data in pairs(current.ScreeningSubjects or {}) do
                if IsValid(subject) and subject:Alive() and subject:GetNWBool("SCPRPEvents_MedicalScreening", false) and data.Carrier then
                    subject:EmitSound("ambient/voices/cough" .. math.random(1, 4) .. ".wav", 55, 95, 0.45)
                    subject:SetNWFloat("SCPRPEvents_TemporalSlow", CurTime() + 3)

                    for _, nearby in ipairs(ents.FindInSphere(subject:GetPos(), 150)) do
                        if IsValid(nearby) and nearby:IsPlayer() and nearby:Alive() and nearby ~= subject then
                            nearby:SetNWFloat("SCPRPEvents_CognitoExposure", math.min(45, nearby:GetNWFloat("SCPRPEvents_CognitoExposure", 0) + 8))
                        end
                    end
                end
            end
        end, 27)
    end,
    Stop = function()
        clearMedicalScreening()
        for _, ply in ipairs(player.GetAll()) do
            ply:SetNWFloat("SCPRPEvents_TemporalSlow", 0)
            ply:SetNWFloat("SCPRPEvents_CognitoExposure", 0)
        end
    end
})

-- Research classifies several redacted anomalous objects scattered through the site.
E.Register("redacted_object_manifest", {
    Title = "REDACTED OBJECT MANIFEST",
    Description = "Several mislabeled anomalous objects have appeared around the site. Research must inspect and secure each object.",
    EndMessage = "The redacted manifest objects have been classified and secured.",
    TimeoutMessage = "Manifest recovery timed out. Unsecured objects have been quarantined.",
    Duration = 260,
    Weight = 4,
    Effect = "resonance",
    Style = "danger",
    CanRun = function()
        return hasRoles({ Research = 1, Foundation = 2 })
    end,
    Start = function(active)
        active.ManifestRemaining = 0
        local desired = math.Clamp(math.ceil(#player.GetHumans() / 7), 3, 6)
        local types = { "harmless", "unstable", "cognitohazard", "energetic", "biological", "spatial" }
        local models = {
            "models/props_lab/jar01b.mdl",
            "models/props_lab/huladoll.mdl",
            "models/props_junk/garbage_glassbottle003a.mdl",
            "models/props_combine/breenlight.mdl"
        }

        for _ = 1, desired do
            local device = spawnResearchDevice(E.RandomLivingPlayer(), 650, active, "REDACTED OBJECT", "RESEARCH: CLASSIFY", "manifest_object")
            if IsValid(device) then
                device:SetModel(models[math.random(#models)])
                device.ManifestType = types[math.random(#types)]
                device.ProgressStep = 5
                active.ManifestRemaining = active.ManifestRemaining + 1
            end
        end

        if active.ManifestRemaining == 0 then error("No manifest objects could be deployed.") end
    end,
    Stop = function()
        for _, ply in ipairs(player.GetAll()) do
            ply:SetNWFloat("SCPRPEvents_TemporalSlow", 0)
            ply:SetNWFloat("SCPRPEvents_CognitoExposure", 0)
        end
    end
})

-- A physical reality distortion zone with anchor stabilization objectives.
E.Register("reality_sinkhole", {
    Title = "REALITY SINKHOLE",
    Description = "A localized reality sinkhole is warping the facility. Research must stabilize anchors while personnel avoid the distortion zone.",
    EndMessage = "The reality sinkhole has collapsed safely.",
    TimeoutMessage = "The sinkhole discharged before stabilization. Reality anchors are being replaced.",
    Duration = 260,
    Weight = 4,
    Effect = "sinkhole",
    Style = "danger",
    CanRun = function()
        return hasRoles({ Research = 1, Foundation = 2 })
    end,
    Start = function(active)
        active.SinkholeRemaining = 0
        local anchor = randomFromRole("Research") or E.RandomLivingPlayer()
        local rift = spawnObjective("scprp_event_temporal_rift", anchor, 560, active)
        if not IsValid(rift) then error("No reality sinkhole could be deployed.") end
        active.Sinkhole = rift

        local desired = math.Clamp(math.ceil(#player.GetHumans() / 9), 3, 5)
        for _ = 1, desired do
            local device = spawnResearchDevice(rift, 430, active, "REALITY ANCHOR", "RESEARCH: STABILIZE", "sinkhole_anchor")
            if IsValid(device) then
                device:SetModel("models/props_combine/combine_mine01.mdl")
                device.ProgressStep = 4
                active.SinkholeRemaining = active.SinkholeRemaining + 1
            end
        end

        if active.SinkholeRemaining == 0 then error("No reality anchors could be deployed.") end

        E.EventTimer(4, function(current)
            if not IsValid(current.Sinkhole) then return end
            local center = current.Sinkhole:GetPos()

            for _, ply in ipairs(ents.FindInSphere(center, 520)) do
                if IsValid(ply) and ply:IsPlayer() and ply:Alive() then
                    local dir = (ply:GetPos() - center)
                    if dir:LengthSqr() < 1 then dir = VectorRand() end
                    ply:SetVelocity(dir:GetNormalized() * math.random(110, 260) + Vector(0, 0, math.random(50, 150)))
                    if math.random(1, 2) == 1 then ply:SetNWFloat("SCPRPEvents_TemporalSlow", CurTime() + 4) end
                    if math.random(1, 4) == 1 then randomTemporalMessage(ply) end
                end
            end
        end, 65)
    end,
    Stop = function()
        for _, ply in ipairs(player.GetAll()) do
            ply:SetNWFloat("SCPRPEvents_TemporalSlow", 0)
        end
    end
})

-- Site 70 power surge that controls the map's real light_all target.
E.Register("power_grid_surge", {
    Title = "POWER GRID SURGE",
    Description = "Site power is overloading. Emergency terminals must be stabilized before the grid fails.",
    EndMessage = "Site power has been restored.",
    TimeoutMessage = "The power surge timed out. Backup generators restored basic lighting.",
    Duration = 240,
    Weight = 4,
    Effect = "power",
    Style = "danger",
    CanRun = function()
        return hasRoles({ Research = 1, Foundation = 2 })
    end,
    Start = function(active)
        active.PowerRemaining = 0
        active.PowerBlackout = true
        flickerSiteLights(active)
        fireNamedTarget("Power_Off_Sound", "PlaySound")

        local desired = math.Clamp(math.ceil(#player.GetHumans() / 8), 3, 5)
        for _ = 1, desired do
            local device = spawnResearchDevice(E.RandomLivingPlayer(), 620, active, "POWER TERMINAL", "STABILIZE GRID", "power_terminal")
            if IsValid(device) then
                device:SetModel("models/props_lab/reciever01b.mdl")
                device.ProgressStep = 4
                active.PowerRemaining = active.PowerRemaining + 1
            end
        end

        if active.PowerRemaining == 0 then
            setSiteLights(true)
            error("No power terminals could be deployed.")
        end

        E.EventTimer(12, function(current)
            if current.PowerBlackout then
                setSiteLights(true)
                timer.Simple(0.35, function()
                    if E.Active == current and current.PowerBlackout then setSiteLights(false) end
                end)
            end

            for _, ply in ipairs(E.AlivePlayers()) do
                if math.random(1, 5) == 1 then ply:EmitSound("ambient/energy/spark" .. math.random(1, 6) .. ".wav", 45, 100, 0.25) end
            end
        end, 20)
    end,
    Stop = function(active)
        active.PowerBlackout = false
        setSiteLights(true)
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
        clear610Exposure()
        active.GrowthsRemaining = 0
        active.InfectedNPCs = {}
        local desired = math.Clamp(math.ceil(#player.GetHumans() / 10), 2, 4)

        for _ = 1, desired do
            local growth = spawnObjective("scprp_event_610growth", E.RandomLivingPlayer(), 600, active)
            if IsValid(growth) then active.GrowthsRemaining = active.GrowthsRemaining + 1 end
        end

        if active.GrowthsRemaining == 0 then error("No SCP-610 growths could be deployed.") end

        active.SpawnHook = "SCPRPEvents_610Spawn_" .. active.Serial
        hook.Add("PlayerSpawn", active.SpawnHook, function(ply)
            ply:SetNWFloat("SCPRPEvents_610Exposure", 0)
            ply:SetNWBool("SCPRPEvents_610Transformed", false)
        end)

        E.EventTimer(2, function(current)
            local growths = {}
            for _, growth in ipairs(ents.FindByClass("scprp_event_610growth")) do
                if growth.SCPRPEventSerial == current.Serial then growths[#growths + 1] = growth end
            end

            for _, ply in ipairs(E.AlivePlayers()) do
                if ply:GetNWBool("SCPRPEvents_610Transformed", false) then continue end

                if not C.IgnoreJobRequirements and E.IsRole(ply, "SCP") then
                    ply:SetNWFloat("SCPRPEvents_610Exposure", 0)
                    continue
                end

                local insideGrowth = false
                for _, growth in ipairs(growths) do
                    if ply:GetPos():DistToSqr(growth:GetPos()) <= 300 * 300 then
                        local trace = util.TraceLine({
                            start = growth:WorldSpaceCenter(),
                            endpos = ply:EyePos(),
                            filter = { growth, ply }
                        })
                        if not trace.Hit then
                            insideGrowth = true
                            break
                        end
                    end
                end

                local exposure = ply:GetNWFloat("SCPRPEvents_610Exposure", 0)
                exposure = insideGrowth and math.min(100, exposure + 10) or math.max(0, exposure - 4)
                ply:SetNWFloat("SCPRPEvents_610Exposure", exposure)

                if exposure >= 100 then
                    transformInto610(ply)
                elseif exposure >= 40 and math.random(1, 3) == 1 then
                    ply:EmitSound("npc/zombie/zombie_pain" .. math.random(1, 6) .. ".wav", 55, 90, 0.35)
                end
            end
        end, 135)

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
    end,
    Stop = function(active)
        if active.SpawnHook then hook.Remove("PlayerSpawn", active.SpawnHook) end
        clear610Exposure()
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

hook.Add("EntityFireBullets", "SCPRPEvents_610BulletFallback", function(attacker, bullet)
    local active = E.Active
    if not active or active.Id ~= "scp610_biomass_bloom" then return end
    if not IsValid(attacker) or not attacker:IsPlayer() then return end

    local start = bullet.Src or attacker:GetShootPos()
    local direction = bullet.Dir or attacker:GetAimVector()
    local distance = bullet.Distance or 8192

    local trace = util.TraceHull({
        start = start,
        endpos = start + direction:GetNormalized() * distance,
        mins = Vector(-8, -8, -8),
        maxs = Vector(8, 8, 8),
        filter = attacker,
        mask = MASK_SHOT
    })

    local target = trace.Entity
    if not IsValid(target) or target:GetClass() ~= "scprp_event_610growth" or target.SCPRPEventSerial ~= active.Serial then return end

    local damage = DamageInfo()
    damage:SetAttacker(attacker)
    damage:SetInflictor(IsValid(attacker:GetActiveWeapon()) and attacker:GetActiveWeapon() or attacker)
    damage:SetDamage(math.max(8, bullet.Damage or 18))
    damage:SetDamageType(DMG_BULLET)
    damage:SetDamagePosition(trace.HitPos)
    damage:SetDamageForce(direction:GetNormalized() * 600)
    target:TakeDamageInfo(damage)
end)

hook.Add("KeyPress", "SCPRPEvents_CognitoInterview", function(ply, key)
    local active = E.Active
    if key ~= IN_USE or not active or active.Id ~= "cognitohazard_interview" then return end
    if not IsValid(ply) or not ply:Alive() then return end
    if not C.IgnoreJobRequirements and not E.IsRole(ply, "Research") then return end
    if (ply.SCPRPNextCognitoInterview or 0) > CurTime() then return end

    local trace = util.TraceHull({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:GetAimVector() * 115,
        mins = Vector(-12, -12, -12),
        maxs = Vector(12, 12, 12),
        filter = ply
    })

    local subject = trace.Entity
    if not IsValid(subject) or not subject:IsPlayer() or not subject:GetNWBool("SCPRPEvents_CognitoExposed", false) then return end

    ply.SCPRPNextCognitoInterview = CurTime() + 5
    subject:SetNWBool("SCPRPEvents_CognitoExposed", false)
    subject:SetNWFloat("SCPRPEvents_CognitoExposure", 0)
    if active.CognitoSubjects then active.CognitoSubjects[subject] = nil end

    active.CognitoStabilized = math.max(0, (active.CognitoStabilized or 0) + 1)
    E.PayPlayer(ply, C.Rewards.CognitohazardStabilized, "Cognitohazard Interview")
    subject:EmitSound("items/suitchargeok1.wav", 60, 100, 0.55)
    subject:ChatPrint("Research stabilized your cognitohazard exposure.")
    ply:ChatPrint("Interview protocol complete. Stabilized " .. active.CognitoStabilized .. "/" .. active.CognitoRequired .. " required subject(s).")
    E.Announce("SUBJECT STABILIZED", active.CognitoStabilized .. "/" .. active.CognitoRequired .. " cognitohazard interview(s) complete.", 5, "success")

    if active.CognitoStabilized >= active.CognitoRequired then
        E.End("objective_complete")
    end
end)

hook.Add("KeyPress", "SCPRPEvents_DClassMedicalScreening", function(ply, key)
    local active = E.Active
    if key ~= IN_USE or not active or active.Id ~= "dclass_medical_screening" then return end
    if not IsValid(ply) or not ply:Alive() then return end
    if not C.IgnoreJobRequirements and not (E.IsRole(ply, "Medical") or E.IsRole(ply, "Research")) then return end
    if (ply.SCPRPNextMedicalScreening or 0) > CurTime() then return end

    local trace = util.TraceHull({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:GetAimVector() * 115,
        mins = Vector(-12, -12, -12),
        maxs = Vector(12, 12, 12),
        filter = ply
    })

    local subject = trace.Entity
    if not IsValid(subject) or not subject:IsPlayer() or not subject:GetNWBool("SCPRPEvents_MedicalScreening", false) then return end

    ply.SCPRPNextMedicalScreening = CurTime() + 5
    local wasCarrier = subject:GetNWBool("SCPRPEvents_AnomalousCarrier", false)
    subject:SetNWBool("SCPRPEvents_MedicalScreening", false)
    subject:SetNWBool("SCPRPEvents_AnomalousCarrier", false)
    subject:SetNWFloat("SCPRPEvents_TemporalSlow", 0)
    if active.ScreeningSubjects then active.ScreeningSubjects[subject] = nil end

    active.ScreeningsComplete = math.max(0, (active.ScreeningsComplete or 0) + 1)
    E.PayPlayer(ply, C.Rewards.MedicalScreening, "Medical Screening")
    if E.IsRole(subject, "DClass") or C.IgnoreJobRequirements then
        E.PayPlayer(subject, C.Rewards.DClassCooperation, "Screening Cooperation")
    end

    subject:EmitSound("items/medshot4.wav", 60, 100, 0.65)
    subject:ChatPrint(wasCarrier and "Screening confirmed abnormal readings. You have been stabilized." or "Screening complete. No abnormal readings detected.")
    E.Announce("SCREENING COMPLETE", active.ScreeningsComplete .. "/" .. active.ScreeningsRequired .. " subject(s) screened.", 5, wasCarrier and "danger" or "success")

    if active.ScreeningsComplete >= active.ScreeningsRequired then
        E.End("objective_complete")
    end
end)

hook.Add("SCPRPEventResearchDeviceCompleted", "SCPRPEvents_ResearchDeviceProgress", function(device, ply)
    local active = E.Active
    if not active or device.SCPRPEventSerial ~= active.Serial then return end

    if active.Id == "object_testing_request" and device.SCPRPDeviceMode == "object_test" then
        local subject = findNearbySubject(device:GetPos(), 170, true, ply)
        if not IsValid(subject) then
            ply:ChatPrint("A test subject must be close to the object before the trial can complete.")
            device.Completed = false
            device:SetProgress(70)
            return
        end

        active.TestsCompleted = math.max(0, (active.TestsCompleted or 0) + 1)
        E.PayPlayer(ply, C.Rewards.ObjectTestCompleted, "Object Testing")

        local effect = math.random(1, 7)
        if effect == 1 then
            subject:SetHealth(math.min(subject:GetMaxHealth(), subject:Health() + 35))
            subject:EmitSound("items/smallmedkit1.wav", 65, 100, 0.75)
        elseif effect == 2 then
            subject:TakeDamage(12, device, device)
            subject:EmitSound("ambient/energy/spark" .. math.random(1, 6) .. ".wav", 65, 100, 0.75)
        elseif effect == 3 then
            subject:SetNWFloat("SCPRPEvents_TemporalSlow", CurTime() + 5)
            subject:EmitSound("npc/roller/mine/rmine_blades_out" .. math.random(1, 3) .. ".wav", 60, 90, 0.55)
        elseif effect == 4 then
            subject:SetNWFloat("SCPRPEvents_999Boost", CurTime() + 6)
            subject:SetArmor(math.min(100, subject:Armor() + 15))
        elseif effect == 5 then
            for _, nearby in ipairs(ents.FindInSphere(device:GetPos(), 260)) do
                if IsValid(nearby) and nearby:IsPlayer() then
                    nearby:EmitSound("ambient/voices/psycho" .. math.random(1, 4) .. ".wav", 55, math.random(90, 110), 0.45)
                    nearby:SetNWFloat("SCPRPEvents_CognitoExposure", math.min(45, nearby:GetNWFloat("SCPRPEvents_CognitoExposure", 0) + 12))
                end
            end
        elseif effect == 6 then
            local prop = ents.Create("prop_physics")
            if IsValid(prop) then
                prop:SetModel("models/props_junk/garbage_glassbottle003a.mdl")
                prop:SetPos(device:GetPos() + Vector(math.random(-70, 70), math.random(-70, 70), 55))
                prop:Spawn()
                prop.SCPRPEventSerial = active.Serial
            end
        else
            subject:SetVelocity(Vector(math.random(-120, 120), math.random(-120, 120), 130))
            randomTemporalMessage(subject)
        end

        E.Announce("TEST RECORDED", active.TestsCompleted .. "/" .. active.TestsRequired .. " anomalous object trial(s) complete.", 5, "success")

        if active.TestsCompleted >= active.TestsRequired then
            E.End("objective_complete")
            return
        end

        device.Completed = false
        device:SetProgress(0)
        device:SetActionLabel("NEXT SUBJECT/TRIAL READY")
        return
    end

    if active.Id == "temporal_research_incident" and device.SCPRPDeviceMode == "temporal_anchor" then
        E.PayPlayer(ply, C.Rewards.TemporalStabilized, "Temporal Stabilization")
        active.TemporalRemaining = math.max(0, (active.TemporalRemaining or 1) - 1)
        E.Announce("ANCHOR STABILIZED", active.TemporalRemaining .. " temporal anchor(s) remain.", 5, "success")
        SafeRemoveEntityDelayed(device, 0.2)

        if active.TemporalRemaining == 0 then
            E.End("objective_complete")
        end
        return
    end

    if active.Id == "redacted_object_manifest" and device.SCPRPDeviceMode == "manifest_object" then
        local classification = applyManifestEffect(device, ply, device.ManifestType)
        E.PayPlayer(ply, C.Rewards.ManifestObjectSecured, "Manifest Classification")
        active.ManifestRemaining = math.max(0, (active.ManifestRemaining or 1) - 1)
        E.Announce("OBJECT CLASSIFIED", classification .. " object secured. " .. active.ManifestRemaining .. " object(s) remain.", 5, "success")
        SafeRemoveEntityDelayed(device, 0.2)

        if active.ManifestRemaining == 0 then
            E.End("objective_complete")
        end
        return
    end

    if active.Id == "reality_sinkhole" and device.SCPRPDeviceMode == "sinkhole_anchor" then
        E.PayPlayer(ply, C.Rewards.RealityAnchorStabilized, "Reality Anchor")
        active.SinkholeRemaining = math.max(0, (active.SinkholeRemaining or 1) - 1)
        E.Announce("REALITY ANCHOR STABLE", active.SinkholeRemaining .. " reality anchor(s) remain.", 5, "success")
        SafeRemoveEntityDelayed(device, 0.2)

        if active.SinkholeRemaining == 0 then
            E.End("objective_complete")
        end
        return
    end

    if active.Id == "power_grid_surge" and device.SCPRPDeviceMode == "power_terminal" then
        E.PayPlayer(ply, C.Rewards.PowerTerminalStabilized, "Power Grid Stabilization")
        active.PowerRemaining = math.max(0, (active.PowerRemaining or 1) - 1)
        E.Announce("TERMINAL STABILIZED", active.PowerRemaining .. " power terminal(s) remain.", 5, "success")
        device:EmitSound("ambient/energy/spark" .. math.random(1, 6) .. ".wav", 70, 105, 0.75)
        SafeRemoveEntityDelayed(device, 0.2)

        setSiteLights(true)
        timer.Simple(0.4, function()
            if E.Active == active and active.PowerBlackout and active.PowerRemaining > 0 then setSiteLights(false) end
        end)

        if active.PowerRemaining == 0 then
            active.PowerBlackout = false
            setSiteLights(true)
            E.End("objective_complete")
        end
        return
    end
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

    if ply:GetNWFloat("SCPRPEvents_TemporalBoost", 0) > CurTime() then
        move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 1.18)
        move:SetMaxSpeed(move:GetMaxSpeed() * 1.18)
    end

    if ply:GetNWFloat("SCPRPEvents_TemporalSlow", 0) > CurTime() then
        move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 0.55)
        move:SetMaxSpeed(move:GetMaxSpeed() * 0.55)
    end
end)

hook.Add("PlayerDeath", "SCPRPEvents_Clear008Transformation", function(ply)
    ply:SetNWFloat("SCPRPEvents_008Exposure", 0)
    ply:SetNWBool("SCPRPEvents_008Infected", false)
    ply:SetNWBool("SCPRPEvents_008Transformed", false)
    ply:SetNWFloat("SCPRPEvents_610Exposure", 0)
    ply:SetNWBool("SCPRPEvents_610Transformed", false)
    ply:SetNWFloat("SCPRPEvents_CognitoExposure", 0)
    ply:SetNWBool("SCPRPEvents_CognitoExposed", false)
    ply:SetNWFloat("SCPRPEvents_TemporalBoost", 0)
    ply:SetNWFloat("SCPRPEvents_TemporalSlow", 0)
end)
