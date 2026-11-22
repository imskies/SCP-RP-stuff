-------------------------------------
---------------- Cuffs --------------
-------------------------------------
-- Copyright (c) 2015 Nathan Healy --
-------- All rights reserved --------
-------------------------------------
-- weapon_cuff_tactical.lua SHARED --
--                                 --
-- Quick-restraint handcuffs.      --
-------------------------------------

AddCSLuaFile()

SWEP.Base = "weapon_cuff_base"

SWEP.Category = "Handcuffs"
SWEP.Author = "my_hat_stinks"
SWEP.Instructions = "Fast-action but weak restraint."

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.AdminSpawnable = true

SWEP.Slot = 3
SWEP.PrintName = "Tactical Restraint"

//
// Handcuff Vars
SWEP.CuffTime = 0.1 // Seconds to handcuff
SWEP.CuffSound = Sound( "buttons/lever7.wav" )

SWEP.CuffMaterial = "phoenix_storms/bluemetal"
SWEP.CuffRope = "cable/blue"
SWEP.CuffStrength = 5
SWEP.CuffRegen = 0.8
SWEP.RopeLength = 100

SWEP.CuffReusable = true
SWEP.CuffRecharge = 20 // Time before re-use

SWEP.CuffBlindfold = true
SWEP.CuffGag = true

SWEP.CuffStrengthVariance = 0.1 // Randomise strangth
SWEP.CuffRegenVariance = 0.3 // Randomise regen

SWEP.CuffsCanArrest = true // Players in this restraint can be arrested. Has no effect if restrict arrest is disabled.
SWEP.CuffsCanAutoArrest = false // This swep can be used to auto-arrest. Has no effect if auto arrest is disabled.
