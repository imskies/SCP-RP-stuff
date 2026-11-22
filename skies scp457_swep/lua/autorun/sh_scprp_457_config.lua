if SERVER then AddCSLuaFile() end

SCP457 = SCP457 or {}
SCP457.Config = SCP457.Config or {}

local C = SCP457.Config

-- Core aura balance.
C.Radius = 225
C.ScanInterval = 0.35
C.IgniteDuration = 1.25
C.DamagePerTick = 2
C.RequireLineOfSight = true

-- SCP-457 grows as living players gather nearby.
C.EnablePlayerGrowth = true
C.GrowthRadius = 500
C.BaseModelScale = 1
C.ScalePerPlayer = 0.08
C.MaximumModelScale = 1.65
C.GrowthUpdateInterval = 0.5
C.GrowthTransitionTime = 0.45

-- Fire extinguisher integration (Workshop ID 104607228).
-- Two players must actively spray SCP-457 at the same time.
C.ExtinguisherWeaponClass = "weapon_extinguisher"
C.ExtinguishersRequired = 2
C.ExtinguisherMaximumRange = 300
C.ExtinguisherAimTolerance = 0.92
C.ExtinguisherSuccessSound = "ambient/fire/gascan_ignite1.wav"

-- Controls.
C.StartEnabled = true
C.ToggleCooldown = 1

-- Target selection.
C.IgnitePlayers = true
C.IgniteNPCs = false
C.IgnoreDeadPlayers = true

-- DarkRP jobs and categories listed here are immune to SCP-457's aura.
-- Names are case-sensitive and must match the server configuration.
C.ImmuneJobs = {
    ["SCP-457"] = true
}

C.ImmuneCategories = {
    ["SCPs"] = true
}

-- Models listed here are immune regardless of job.
C.ImmuneModels = {
    -- ["models/player/example.mdl"] = true
}

-- Presentation.
C.ToggleOnSound = "ambient/fire/ignite.wav"
C.ToggleOffSound = "ambient/fire/gascan_ignite1.wav"
C.ShowHUD = true
