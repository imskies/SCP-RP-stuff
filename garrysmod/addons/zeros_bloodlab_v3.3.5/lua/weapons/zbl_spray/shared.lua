/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

SWEP.PrintName = "Disinfectant Spray"
SWEP.Author = "Zero"
SWEP.Instructions = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.AdminSpawnable = false
SWEP.Spawnable = true
SWEP.AutomaticFrameAdvance = true
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/zerochain/props_bloodlab/zbl_v_spray.mdl"
SWEP.WorldModel = "models/zerochain/props_bloodlab/zbl_w_spray.mdl"
SWEP.UseHands = true
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.HoldType = "knife"
SWEP.FiresUnderwater = false
SWEP.Weight = 5
SWEP.DrawCrosshair = true
SWEP.Category = "Zeros GenLab"
SWEP.DrawAmmo = false
SWEP.base = "weapon_base"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Recoil = 1
SWEP.Primary.Delay = 0.1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Recoil = 1
SWEP.Secondary.Delay = 0.25
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("zerochain/zblood/vgui/zbl_spray")
	SWEP.BounceWeaponIcon = false
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "SprayAmount")
	self:NetworkVar("Bool", 0, "Busy")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

	if SERVER then
		self:SetSprayAmount(zbl.config.DisinfectantSpray.Amount)
		self:SetBusy(false)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10
