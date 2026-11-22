SCPRPEvents = SCPRPEvents or {}
SCPRPEvents.Config = SCPRPEvents.Config or {}

local C = SCPRPEvents.Config

-- Automatic events are deliberately infrequent so they remain special.
C.AutoEnabled = true
C.MinimumPlayers = 4
C.DelayMin = 12 * 60
C.DelayMax = 22 * 60
C.WarningTime = 15
C.RecentEventMemory = 2

-- Temporary testing mode. This bypasses event and objective job checks.
-- Set this back to false before normal live use.
C.IgnoreJobRequirements = true

-- Set this to false if your gamemode already has its own announcement UI.
C.UseBuiltInHUD = true

-- Deep Gaming role categories, taken from the server's DarkRP job configuration.
-- Events use categories instead of numeric TEAM_ values so job IDs can safely change.
C.RoleCategories = {
    DClass = {
        ["D-Class"] = true
    },
    Security = {
        ["Security"] = true,
        ["Security Specialization"] = true,
        ["Foundation Enforcement"] = true,
        ["Other MTF Units"] = true
    },
    Research = {
        ["Research"] = true
    },
    Medical = {
        ["Research"] = true
    },
    Foundation = {
        ["Security"] = true,
        ["Security Specialization"] = true,
        ["Foundation Enforcement"] = true,
        ["Other MTF Units"] = true,
        ["Research"] = true,
        ["Site Administration"] = true
    },
    Chaos = {
        ["Chaos Insurgency"] = true
    },
    SCP = {
        ["SCPs"] = true
    }
}

-- Job names used by events centered on one specific SCP.
C.SpecialJobs = {
    SCP999 = "SCP-999"
}

-- DarkRP money rewards. Set a value to 0 to disable that payout.
C.Rewards = {
    CalibrationResearcher = 300,
    CalibrationSecurity = 200,
    BiohazardNeutralized = 600,
    BiomassDestroyed = 450
}

-- These exact jobs are treated as trained biohazard responders.
C.MedicalJobs = {
    ["Security Medical Team"] = true,
    ["Emergency Response Unit [VIP]"] = true
}

-- Called before an event starts. Return false to block it.
-- This is a convenient place to disallow events during a breach or round restart.
C.CanStartEvent = function(eventId, eventData)
    return true
end

-- Optional integration hooks:
-- hook.Run("SCPRPEventStarted", id, eventData, endTime)
-- hook.Run("SCPRPEventEnded", id, eventData, reason)
