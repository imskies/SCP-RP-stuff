/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

include("shared.lua")
SWEP.PrintName = "Injector"
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

function SWEP:Initialize()
	zbl.Injector.Initialize(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

function SWEP:SecondaryAttack()
	zbl.Injector.Secondary(self)
end

function SWEP:PrimaryAttack()
	zbl.Injector.Primary(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

function SWEP:Deploy()
	zbl.Injector.Deploy(self)
end

function SWEP:Holster(swep)
	zbl.Injector.Holster(self)
end

function SWEP:Reload()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

function SWEP:DrawHUD()
	zbl.Injector.DrawHUD(self)
end

function SWEP:Think()
	zbl.Injector.Think(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c
