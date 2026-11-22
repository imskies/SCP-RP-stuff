-- scp2065/init.lua
-- Server side logic for the SCP-style book entity

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("SCP2065_ShowTip")
util.AddNetworkString("SCP2065_ClientFX")

function ENT:Initialize()
    local model = self.Model or "models/props_lab/binderredlabel.mdl"
    self:SetModel(model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self:SetUseType(SIMPLE_USE)
    self.owners = {} -- track players who have used the book and their state
end

local function MakeTimerName(ent, ply)
    return "SCP2065_Timer_" .. tostring(ent:EntIndex()) .. "_" .. ply:SteamID():gsub(":", "_")
end

local function MakeTickTimerName(ent, ply)
    return "SCP2065_Tick_" .. tostring(ent:EntIndex()) .. "_" .. ply:SteamID():gsub(":", "_")
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    local sid = activator:SteamID()
    if self.owners[sid] then
        activator:ChatPrint("The book has already touched you.")
        return
    end

    -- Send a random tip immediately (client will display with [SCP-2065] prefix)
    local tip = table.Random(self.Config.weightLossTips)
    net.Start("SCP2065_ShowTip")
    net.WriteString(tip)
    net.Send(activator)

    -- Delay the faint-presence message by configured seconds
    timer.Simple(self.Config.delayInitialMessage, function()
        if IsValid(activator) and activator:IsPlayer() and activator:Alive() then
            activator:ChatPrint("You feel a faint presence as you touch the book.")
        end
    end)

    -- Initialize owner state
    local state = {
        startTime = CurTime(),
        stage = 0,
        originalWalk = activator:GetWalkSpeed(),
        originalRun = activator:GetRunSpeed(),
        originalScale = (activator.GetModelScale and activator:GetModelScale()) or 1,
        currentScale = (activator.GetModelScale and activator:GetModelScale()) or 1,
        timerName = MakeTimerName(self, activator),
        tickTimerName = MakeTickTimerName(self, activator),
        tickActive = false
    }
    self.owners[sid] = state

    -- Start repeating timer to progress stages
    timer.Create(state.timerName, self.Config.stageInterval, 0, function()
        if not IsValid(self) then
            timer.Remove(state.timerName)
            return
        end

        if not IsValid(activator) or not activator:Alive() then
            -- cleanup for this player
            if IsValid(activator) then
                if activator.SetWalkSpeed and state.originalWalk then activator:SetWalkSpeed(state.originalWalk) end
                if activator.SetRunSpeed and state.originalRun then activator:SetRunSpeed(state.originalRun) end
                if activator.SetModelScale and state.originalScale then activator:SetModelScale(state.originalScale, 0) end
            end
            -- remove tick timer if present
            if timer.Exists(state.tickTimerName) then timer.Remove(state.tickTimerName) end
            timer.Remove(state.timerName)
            self.owners[sid] = nil
            return
        end

        local elapsed = CurTime() - state.startTime
        if elapsed < self.Config.initialTipOnlyDuration then
            return
        end

        -- Progress stage
        state.stage = state.stage + 1
        if state.stage > self.Config.totalStages then
            -- stop timer after final stage
            timer.Remove(state.timerName)
            -- ensure tick timer removed
            if timer.Exists(state.tickTimerName) then timer.Remove(state.tickTimerName) end
            return
        end

        -- 1) HP drain
        local newHP = math.max(1, activator:Health() - self.Config.hpDrainPerStage)
        activator:SetHealth(newHP)

        -- 2) Scale reduction (interpolate down to minScale)
        local fraction = state.stage / self.Config.totalStages
        local targetScale = Lerp(fraction, state.originalScale, self.Config.minScale)
        if activator.SetModelScale then
            activator:SetModelScale(targetScale, 0)
            state.currentScale = targetScale
        end

        -- 3) Movement slowdown
        local newWalk = math.max(self.Config.minSpeedClamp, math.floor(state.originalWalk * (self.Config.speedMultiplierPerStage ^ state.stage)))
        local newRun = math.max(self.Config.minSpeedClamp, math.floor(state.originalRun * (self.Config.speedMultiplierPerStage ^ state.stage)))
        activator:SetWalkSpeed(newWalk)
        activator:SetRunSpeed(newRun)

        -- 4) Send chat message describing sensation (plain message, no [Book] prefix)
        local msg = self.Config.chatMessages[math.min(state.stage, #self.Config.chatMessages)]
        activator:ChatPrint(msg)

        -- 5) Trigger clientside visual effects (client will keep effects for the whole stage)
        net.Start("SCP2065_ClientFX")
        net.WriteInt(state.stage, 8)
        net.WriteInt(self.Config.stageInterval, 16) -- send stage duration so client can persist effects
        net.Send(activator)

        -- 6) Notify nearby players (plain message)
        local pos = activator:GetPos()
        for _, ply in ipairs(player.GetAll()) do
            if ply ~= activator and ply:GetPos():Distance(pos) <= 400 then
                ply:ChatPrint(activator:Nick() .. " looks a little different after touching the book.")
            end
        end

        -- 7) If stage reaches tick damage threshold, start or keep tick damage timer
        if state.stage >= self.Config.tickDamageStartStage and not state.tickActive then
            state.tickActive = true
            timer.Create(state.tickTimerName, self.Config.tickDamageInterval, 0, function()
                if not IsValid(activator) or not activator:Alive() then
                    timer.Remove(state.tickTimerName)
                    state.tickActive = false
                    return
                end

                -- Calculate scaled tick damage based on current stage, clamped to tickDamageMax
                local tickStart = self.Config.tickDamageStartStage
                local totalStages = math.max(1, self.Config.totalStages)
                local base = self.Config.tickDamageBase
                local maxd = self.Config.tickDamageMax

                -- If there are stages to scale across, interpolate linearly from base to maxd
                local dmgAmount
                if totalStages > tickStart then
                    local steps = totalStages - tickStart
                    local stepIndex = math.Clamp(state.stage - tickStart, 0, steps)
                    local perStep = (maxd - base) / math.max(1, steps)
                    dmgAmount = math.ceil(base + perStep * stepIndex)
                else
                    dmgAmount = maxd
                end

                dmgAmount = math.Clamp(dmgAmount, base, maxd)

                local dmg = DamageInfo()
                dmg:SetDamage(dmgAmount)
                dmg:SetAttacker(self) -- entity as attacker
                dmg:SetInflictor(self)
                dmg:SetDamageType(DMG_GENERIC)
                activator:TakeDamageInfo(dmg)
            end)
        end

        -- If reached cap scale, scaling is already capped by Lerp above
    end)

    -- No immediate "faint presence" message here; it's delayed above
end

function ENT:OnRemove()
    for sid, st in pairs(self.owners) do
        if st and st.timerName then
            timer.Remove(st.timerName)
        end
        if st and st.tickTimerName then
            timer.Remove(st.tickTimerName)
        end
    end
    self.owners = {}
end

-- Reset effects on death
hook.Add("PlayerDeath", "SCP2065_ResetOnDeath", function(ply)
    local entList = ents.FindByClass("scp2065")
    for _, ent in ipairs(entList) do
        if ent.owners then
            local sid = ply:SteamID()
            local st = ent.owners[sid]
            if st then
                if st.timerName then timer.Remove(st.timerName) end
                if st.tickTimerName then timer.Remove(st.tickTimerName) end
                if st.originalWalk and st.originalRun then
                    ply:SetWalkSpeed(st.originalWalk)
                    ply:SetRunSpeed(st.originalRun)
                end
                if ply.SetModelScale and st.originalScale then
                    ply:SetModelScale(st.originalScale, 0)
                end
                ent.owners[sid] = nil
            end
        end
    end
end)

-- Cleanup on disconnect
hook.Add("PlayerDisconnected", "SCP2065_ResetOnDisconnect", function(ply)
    local entList = ents.FindByClass("scp2065")
    for _, ent in ipairs(entList) do
        if ent.owners then
            local sid = ply:SteamID()
            local st = ent.owners[sid]
            if st then
                if st.timerName then timer.Remove(st.timerName) end
                if st.tickTimerName then timer.Remove(st.tickTimerName) end
                ent.owners[sid] = nil
            end
        end
    end
end)