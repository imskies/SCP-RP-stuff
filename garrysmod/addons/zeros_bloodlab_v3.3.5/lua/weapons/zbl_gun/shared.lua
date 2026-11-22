/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

SWEP.PrintName = "Injector"
SWEP.Author = "Zero"
SWEP.Instructions = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.AdminSpawnable = false
SWEP.Spawnable = true
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

SWEP.AutomaticFrameAdvance = true
SWEP.ViewModelFOV = 75
SWEP.ViewModel = "models/zerochain/props_bloodlab/zbl_v_injector01.mdl"
SWEP.WorldModel = "models/zerochain/props_bloodlab/zbl_w_injector01.mdl"
SWEP.UseHands = true
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.HoldType = "pistol"
SWEP.FiresUnderwater = false
SWEP.Weight = 5
SWEP.DrawCrosshair = true
SWEP.Category = "Zeros GenLab"
SWEP.DrawAmmo = false
SWEP.base = "weapon_base"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Recoil = 1
SWEP.Primary.Delay = 0.25

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Recoil = 1
SWEP.Secondary.Delay = 0.25

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("zerochain/zblood/vgui/zbl_gun")
	SWEP.BounceWeaponIcon = false
end


function SWEP:SetupDataTables()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

	// What type of GenType are we having inside the gun
	/*
		0 = Empty
		1 = Sample
		2 = Vaccine
		3 = Cure
	*/

	self:NetworkVar("Int", 3, "SelectedFlask")
	self:NetworkVar("Bool", 0, "Busy")


	self:NetworkVar("Int", 0, "GenType")
	self:NetworkVar("Int", 1, "GenValue")
	self:NetworkVar("String", 0, "GenName")
	self:NetworkVar("Int", 2, "GenPoints")
	self:NetworkVar("String", 1, "GenClass")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

	self:NetworkVar("String", 2, "FlaskSequence")
	self:NetworkVarNotify( "FlaskSequence", self.OnVarChanged )

	/////////

	if SERVER then
		self:SetFlaskSequence("")
		self:SetSelectedFlask(1)
		self:SetBusy(false)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

		self:SetGenType(0)
		self:SetGenValue(0)
		self:SetGenName("")
		self:SetGenPoints(0)
		self:SetGenClass("")
	end



end

function SWEP:OnVarChanged( name, old, new )
	if CLIENT then
		zbl.Injector.FlaskSequenceChanged(self,new)
	end
end
