-- init.lua (server)
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local LOOK_TIME_REQUIRED = 5
local TRANSFORM_SCALE = 1.5
local ZOMBIE_MODEL = "models/player/zombie_classic.mdl"
local PAINTING_MODEL = "models/props_interiors/painting_portrait01.mdl"
local GROAN_SOUND = "npc/zombie/zombie_pain1.wav"
local NETMSG = "SCP1226_TransformClient"

local MAX_RANGE = 1000
local FOV_DOT_THRESHOLD = 0.70

util.AddNetworkString(NETMSG)

function ENT:Initialize()
    self:SetModel(PAINTING_MODEL)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self.LookTimers = {}
    self:SetNWBool("SCP1226_Active", true)
    print("[SCP1226] Initialized entity at " .. tostring(self:GetPos()))
end

local function IsPlayerLookingAtEnt(ply, ent)
    if not IsValid(ply) or not ply:Alive() then return false end
    if not IsValid(ent) then return false end

    local eyePos = ply:EyePos()
    local aim = ply:GetAimVector()

    local tr = ply:GetEyeTrace()
    if tr.Hit and IsValid(tr.Entity) and tr.Entity == ent then
        if tr.HitPos:Distance(eyePos) <= MAX_RANGE then
            return true
        end
    end

    local entCenter = ent:LocalToWorld(ent:OBBCenter())
    local dirToEnt = (entCenter - eyePos)
    local dist = dirToEnt:Length()
    if dist > MAX_RANGE then return false end
    dirToEnt:Normalize()
    local dot = aim:Dot(dirToEnt)
    if dot < FOV_DOT_THRESHOLD then return false end

    local trace = util.TraceLine({
        start = eyePos,
        endpos = entCenter,
        filter = ply,
        mask = MASK_SHOT
    })
    if trace.Hit and IsValid(trace.Entity) and trace.Entity ~= ent then
        return false
    end

    return true
end

function ENT:Think()
    if not self:GetNWBool("SCP1226_Active", true) then return end

    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) or not ply:Alive() then
            self.LookTimers[ply] = nil
        else
            if IsPlayerLookingAtEnt(ply, self) then
                self.LookTimers[ply] = (self.LookTimers[ply] or 0) + FrameTime()

                if math.floor(self.LookTimers[ply]) ~= math.floor((self.LookTimers[ply] - FrameTime())) then
                    print(string.format("[SCP1226] %s looking: %.1f s (dist %.0f)", ply:Nick(), self.LookTimers[ply], ply:EyePos():Distance(self:LocalToWorld(self:OBBCenter()))))
                end

                if self.LookTimers[ply] >= LOOK_TIME_REQUIRED then
                    if not ply.SCP1226_Transformed then
                        ply.SCP1226_Transformed = true

                        -- store old movement/health values so we can revert on spawn
                        ply.SCP1226_OldWalkSpeed = ply.GetWalkSpeed and ply:GetWalkSpeed() or nil
                        ply.SCP1226_OldRunSpeed  = ply.GetRunSpeed  and ply:GetRunSpeed()  or nil
                        ply.SCP1226_OldMaxSpeed  = ply.GetMaxSpeed  and ply:GetMaxSpeed()  or nil
                        ply.SCP1226_OldHealth    = ply:Health()

                        -- set health to 50
                        local okh, errh = pcall(function() ply:SetHealth(50) end)
                        if not okh then
                            print("[SCP1226] Failed to set health for " .. ply:Nick() .. " : " .. tostring(errh))
                        else
                            print("[SCP1226] Set health to 50 for " .. ply:Nick())
                        end

                        -- slow movement: set walk/run/max speeds to a low value so player can only walk
                        local walkSpeed = 100
                        local runSpeed  = 100
                        local maxSpeed  = 100
                        local okws, errws = pcall(function()
                            if ply.SetWalkSpeed then ply:SetWalkSpeed(walkSpeed) end
                            if ply.SetRunSpeed  then ply:SetRunSpeed(runSpeed) end
                            if ply.SetMaxSpeed  then ply:SetMaxSpeed(maxSpeed) end
                        end)
                        if not okws then
                            print("[SCP1226] Failed to set speeds for " .. ply:Nick() .. " : " .. tostring(errws))
                        else
                            print(string.format("[SCP1226] Movement slowed for %s (walk/run/max = %d/%d/%d)", ply:Nick(), walkSpeed, runSpeed, maxSpeed))
                        end

                        -- change model
                        local ok, err = pcall(function() ply:SetModel(ZOMBIE_MODEL) end)
                        if not ok then
                            print("[SCP1226] SetModel failed for " .. ply:Nick() .. " : " .. tostring(err))
                        else
                            print("[SCP1226] SetModel applied to " .. ply:Nick())
                        end

                        -- scale player if available
                        if ply.SetModelScale then
                            local ok2, err2 = pcall(function() ply:SetModelScale(TRANSFORM_SCALE, 0) end)
                            if not ok2 then
                                print("[SCP1226] SetModelScale failed for " .. ply:Nick() .. " : " .. tostring(err2))
                            else
                                print("[SCP1226] Scaled " .. ply:Nick() .. " to " .. tostring(TRANSFORM_SCALE))
                            end
                        else
                            print("[SCP1226] SetModelScale not available for " .. ply:Nick())
                        end

                        -- play groan
                        ply:EmitSound(GROAN_SOUND, 75, 100)

                        -- server chat messages
                        ply:ChatPrint("[SCP-1226] Your thoughts slow; memories fray.")
                        ply:ChatPrint("[SCP-1226] Your body contorts and expands. Cognition diminishes.")

                        -- notify client for overlay/sound/effects
                        net.Start(NETMSG)
                            net.WriteEntity(ply)
                        net.Send(ply)

                        print("[SCP1226] Transformation triggered for " .. ply:Nick())
                    end
                    self.LookTimers[ply] = nil
                end
            else
                if self.LookTimers[ply] and self.LookTimers[ply] > 0 then
                    print(string.format("[SCP1226] %s looked away after %.2f s", ply:Nick(), self.LookTimers[ply]))
                end
                self.LookTimers[ply] = nil
            end
        end
    end

    self:NextThink(CurTime() + 0.05)
    return true
end

-- revert transformation on spawn so it doesn't persist across death/respawn
hook.Add("PlayerSpawn", "SCP1226_RevertOnSpawn", function(ply)
    if ply.SCP1226_Transformed then
        ply.SCP1226_Transformed = nil

        timer.Simple(0.1, function()
            if not IsValid(ply) then return end

            -- restore speeds if we stored them
            if ply.SCP1226_OldWalkSpeed and ply.SetWalkSpeed then
                pcall(function() ply:SetWalkSpeed(ply.SCP1226_OldWalkSpeed) end)
            end
            if ply.SCP1226_OldRunSpeed and ply.SetRunSpeed then
                pcall(function() ply:SetRunSpeed(ply.SCP1226_OldRunSpeed) end)
            end
            if ply.SCP1226_OldMaxSpeed and ply.SetMaxSpeed then
                pcall(function() ply:SetMaxSpeed(ply.SCP1226_OldMaxSpeed) end)
            end

            -- restore health to previous value if it was higher than 0 (we don't want to heal dead players)
            if ply.SCP1226_OldHealth and ply.SCP1226_OldHealth > 0 then
                pcall(function() ply:SetHealth(ply.SCP1226_OldHealth) end)
            end

            -- reset model scale if available
            if ply.SetModelScale then
                pcall(function() ply:SetModelScale(1, 0) end)
            end

            print("[SCP1226] Reverted transformation for " .. ply:Nick() .. " on spawn")
        end)
    end
end)

-- Console command to force-transform yourself for testing
concommand.Add("scp1226_force_transform", function(ply)
    if not IsValid(ply) then return end
    ply.SCP1226_Transformed = true

    -- store old values
    ply.SCP1226_OldWalkSpeed = ply.GetWalkSpeed and ply:GetWalkSpeed() or nil
    ply.SCP1226_OldRunSpeed  = ply.GetRunSpeed  and ply:GetRunSpeed()  or nil
    ply.SCP1226_OldMaxSpeed  = ply.GetMaxSpeed  and ply:GetMaxSpeed()  or nil
    ply.SCP1226_OldHealth    = ply:Health()

    pcall(function() ply:SetHealth(50) end)
    if ply.SetWalkSpeed then pcall(function() ply:SetWalkSpeed(100) end) end
    if ply.SetRunSpeed  then pcall(function() ply:SetRunSpeed(100) end) end
    if ply.SetMaxSpeed  then pcall(function() ply:SetMaxSpeed(100) end) end
    pcall(function() ply:SetModel(ZOMBIE_MODEL) end)
    if ply.SetModelScale then pcall(function() ply:SetModelScale(TRANSFORM_SCALE, 0) end) end
    ply:EmitSound(GROAN_SOUND, 75, 100)
    net.Start(NETMSG) net.WriteEntity(ply) net.Send(ply)
    ply:ChatPrint("[SCP-1226] (forced) You feel your mind and body change.")
end)