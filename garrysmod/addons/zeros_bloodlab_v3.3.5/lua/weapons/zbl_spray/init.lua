/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
SWEP.Weight = 5
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

function SWEP:Initialize()
	zbl.Spray.Initialize(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

function SWEP:Deploy()
	zbl.Spray.Deploy(self)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

	return true
end

function SWEP:PrimaryAttack()
	zbl.Spray.Primary(self)
end

function SWEP:SecondaryAttack()
	zbl.Spray.Secondary(self)
end

function SWEP:Equip()
	zbl.Spray.Equip(self)
end

function SWEP:Holster(swep)
	zbl.Spray.Holster(self)

	return true
end

function SWEP:ShouldDropOnDie()
	return false
end
