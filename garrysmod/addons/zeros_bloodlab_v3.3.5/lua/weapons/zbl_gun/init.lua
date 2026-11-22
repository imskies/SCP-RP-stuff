/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
SWEP.Weight = 5

function SWEP:Initialize()
	zbl.Injector.Initialize(self)
end

function SWEP:Deploy()
	zbl.Injector.Deploy(self)
	return true
end

function SWEP:PrimaryAttack()
	zbl.Injector.Primary(self)
end

function SWEP:SecondaryAttack()
	zbl.Injector.Secondary(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

function SWEP:Equip()
	zbl.Injector.Equip(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

function SWEP:Reload()
end


function SWEP:Holster(swep)
	zbl.Injector.Holster(self)

	return true
end

function SWEP:ShouldDropOnDie()
	return false
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
