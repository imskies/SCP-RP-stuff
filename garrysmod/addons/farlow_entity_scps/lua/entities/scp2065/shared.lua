-- scp2065/shared.lua
-- Shared definitions and configuration for the SCP-style book entity

ENT = ENT or {}

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("init.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "SCP-2065"
ENT.Author = "Custom"
ENT.Category = "Farlow SCP Items"
ENT.Spawnable = true
ENT.AdminOnly = false

-- Model (shared reference)
ENT.Model = "models/props_lab/binderredlabel.mdl"

-- Configuration (shared so server and client can reference)
ENT.Config = ENT.Config or {}
ENT.Config.initialTipOnlyDuration = 30 -- seconds before negative effects begin
ENT.Config.delayInitialMessage = 5 -- seconds after use before the "faint presence" message
ENT.Config.totalStages = 5 -- number of staged decreases until cap reached
ENT.Config.stageInterval = 20 -- seconds between stages
ENT.Config.hpDrainPerStage = 8 -- HP lost per stage
ENT.Config.minScale = 0.5 -- minimum scale relative to original
ENT.Config.speedMultiplierPerStage = 0.85 -- multiply walk/run speed each stage
ENT.Config.minSpeedClamp = 50 -- minimum walk/run speed clamp

-- Tick damage settings (applies once stage >= tickDamageStartStage)
ENT.Config.tickDamageStartStage = 4 -- stage at which tick damage begins
ENT.Config.tickDamageBase = 2 -- base damage per tick
ENT.Config.tickDamageMax = 6 -- maximum damage per tick (will scale up to this)
ENT.Config.tickDamageInterval = 1 -- seconds between tick damage applications

ENT.Config.chatMessages = {
    "You feel oddly lighter, like something is slipping away.",
    "Your limbs feel less solid; moving takes more effort.",
    "Your clothes hang looser; your steps are slower.",
    "You feel hollow and weak; breath comes easier but strength fades.",
    "You are noticeably smaller and weaker now."
}

ENT.Config.weightLossTips = {
    "Tip: Small, consistent changes beat dramatic short bursts.",
    "Tip: Hydration helps appetite control and energy.",
    "Tip: Protein-rich snacks can reduce overeating later.",
    "Tip: Short daily walks add up over time.",
    "Tip: Sleep quality affects hunger and recovery."
}