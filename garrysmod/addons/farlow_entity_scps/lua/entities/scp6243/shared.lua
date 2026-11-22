-- scp6243_dg/shared.lua
-- Shared definitions for SCP-6243-DG

ENT = ENT or {}

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("init.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "SCP-6243-DG"
ENT.Author = "Custom"
ENT.Category = "Farlow SCP Items"
ENT.Spawnable = true
ENT.AdminOnly = false

-- Model (coin)
ENT.Model = "models/custom/coin.mdl"

ENT.Config = ENT.Config or {}
ENT.Config.cooldown = 2
ENT.Config.effectDuration = 12
ENT.Config.flipUpForce = 220
ENT.Config.flipSpin = Vector(0, 0, 900)

-- Effect pool (IDs must match client)
-- 1  = Prop Spin
-- 2  = Explosion
-- 3  = Ignite (prop on fire)
-- 4  = Teleport Player (random nearby)
-- 5  = Temporary Invisibility
-- 6  = Low Gravity (player)
-- 7  = Spawn Friendly NPC
-- 8  = Give Small Weapon
-- 9  = Rapid Heal
-- 10 = Poison Tick Damage
-- 11 = Shrink Player (down to 50%)
-- 12 = Force Push (prop pushes nearby entities)
ENT.Config.effectCount = 12

ENT.Config.explosion = {
    radius = 200,
    damage = 80,
    effectName = "Explosion"
}

ENT.Config.ignite = {
    duration = 10,
    damagePerSecond = 4
}

ENT.Config.npc = {
    class = "npc_citizen",
    distance = 120
}

ENT.Config.giveWeapon = "weapon_pistol"

ENT.Config.heal = {
    amountPerSecond = 8,
    duration = 8
}

ENT.Config.poison = {
    damagePerSecond = 3,
    duration = 10
}

ENT.Config.shrink = {
    minScale = 0.5,
    duration = 20
}

ENT.Config.effectMessages = {
    [1]  = "The coin spins wildly.",
    [2]  = "The coin erupts violently.",
    [3]  = "The coin bursts into flame.",
    [4]  = "You feel the world shift beneath your feet.",
    [5]  = "You fade from sight for a moment.",
    [6]  = "Your weight feels lighter.",
    [7]  = "Something friendly appears nearby.",
    [8]  = "You receive a small gift.",
    [9]  = "Warmth floods your wounds.",
    [10] = "A sickly pressure gnaws at you.",
    [11] = "You feel yourself compressing.",
    [12] = "A sudden shove ripples out from the coin."
}