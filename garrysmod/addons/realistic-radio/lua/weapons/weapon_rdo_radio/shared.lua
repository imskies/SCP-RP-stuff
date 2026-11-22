/*
    Addon id: 2bab5356-b4ae-4c4d-acb8-e199f204bd54
    Version: v1.3.8 (stable)
*/

AddCSLuaFile()

SWEP.PrintName = "Radio"
SWEP.Author = "Kobralost"
SWEP.Purpose = ""

SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.Category = "Realistic Radio"

SWEP.ViewModel = Model("models/realistic_police/radio/c_radio.mdl")
SWEP.WorldModel = Model("models/realistic_police/radio/w_radio.mdl")
SWEP.ViewModelFOV = 70

SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.DrawAmmo = false

SWEP.BoxAttachment = "top_left_screen"
SWEP.BoxMins = Vector(-2, -2, -2)
SWEP.BoxMaxs = Vector(2, 2, 2)
SWEP.BoxColor = Color(0, 255, 0)

SWEP.HitDistance = 125
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 76561199123350968 */

function SWEP:Deploy()
	self:SetNWBool("rdo_manipulate", false)
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() + 0.5)
end 

function SWEP:PrimaryAttack() 
	if SERVER then 
		self.AntiSpam = self.AntiSpam or CurTime()
		if self.AntiSpam > CurTime() then return end 
		self.AntiSpam = CurTime() + 0.5

		if not self:GetNWBool("rdo_manipulate") then 
			self:SetNWBool("rdo_manipulate", true) 
			self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
			self:SetNextPrimaryFire( CurTime() + self:SequenceDuration())
		else 
			self:SetNWBool("rdo_manipulate", false)
			self:SendWeaponAnim( ACT_VM_IDLE_LOWERED )
			self:SetNextPrimaryFire( CurTime() + self:SequenceDuration())
		end 
	end 
end 

local function PlaySoundRadio()
	if Realistic_Radio.DisableSound then return end
	
    RDOSound = CreateSound(LocalPlayer(), "rdo_sound_radio01.wav" )
    RDOSound:Play()
    RDOSound:ChangeVolume(1, 1)
end 

function SWEP:SecondaryAttack() 
	self.AntiSpam = self.AntiSpam or CurTime()
	if self.AntiSpam > CurTime() then return end 
	self.AntiSpam = CurTime() + 0.5

	if CLIENT then 
		net.Start("RDO:SetFrequencies")
            net.WriteUInt(2, 5)
            net.WriteString("Statut")
        net.SendToServer()

		if Realistic_Radio.MainTable["Statut"] then 
			if timer.Exists("rdo_sound") then timer.Remove("rdo_sound") end 
			if RDOSound then RDOSound:Stop() end 
		elseif not Realistic_Radio.MainTable["CanTalk"] then 
			PlaySoundRadio()
			timer.Create("rdo_sound", SoundDuration( "rdo_sound/rdo_sound_radio01.wav" ), 0, function()
				PlaySoundRadio()
			end ) 
		end 	
	end 
end 

-- Resolve the problem with the position of the attachment 
local function FormatViewModelAttachment(nFOV, vOrigin, bFrom)
	local vEyePos = EyePos()
	local aEyesRot = EyeAngles()
	local vOffset = vOrigin - vEyePos
	local vForward = aEyesRot:Forward()

	local nViewX = math.tan(nFOV * math.pi / 360)

	if (nViewX == 0) then
		vForward:Mul(vForward:Dot(vOffset))
		vEyePos:Add(vForward)
		
		return vEyePos
	end

	local nWorldX = math.tan(LocalPlayer():GetFOV() * math.pi / 360)

	if (nWorldX == 0) then
		vForward:Mul(vForward:Dot(vOffset))
		vEyePos:Add(vForward)
		
		return vEyePos
	end

	local vRight = aEyesRot:Right()
	local vUp = aEyesRot:Up()

	if (bFrom) then
		local nFactor = nWorldX / nViewX
		vRight:Mul(vRight:Dot(vOffset) * nFactor)
		vUp:Mul(vUp:Dot(vOffset) * nFactor)
	else
		local nFactor = nViewX / nWorldX
		vRight:Mul(vRight:Dot(vOffset) * nFactor)
		vUp:Mul(vUp:Dot(vOffset) * nFactor)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 76561199123350945 */

	vForward:Mul(vForward:Dot(vOffset))

	vEyePos:Add(vRight)
	vEyePos:Add(vUp)
	vEyePos:Add(vForward)

	return vEyePos
end

function SWEP:PostDrawViewModel()
	local pOwner = self:GetOwner()
	if (not pOwner:IsValid()) then return end

	local pViewModel = pOwner:GetViewModel()
	if (not pViewModel:IsValid()) then return end

	local uAttachment = pViewModel:LookupAttachment(self.BoxAttachment)
	if (uAttachment < 1) then return end

	local tAttachment = pViewModel:GetAttachment(uAttachment)
	if (tAttachment == nil) then return end

	local nFOV = self.ViewModelFOV
	if (not isnumber(nFOV)) then nFOV = 62 end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350945
	
	local ang = tAttachment.Ang
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1d139e0850450ff0c55cc5ad19568a0794d4d3bdce3fa3d34f714425a4e44079

	local Pos = FormatViewModelAttachment(nFOV, tAttachment.Pos, false) 
	Pos = Pos + ang:Right()*0.16
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 5fa1e6df5fd1b55cf2f6f5dfb9364c1e6615d258fcc9159a1c9ab64208e71c95 */

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Up(), -90 )

	cam.Start3D2D(Pos, ang, 0.005)
		Realistic_Radio.BaseFunction()
    cam.End3D2D()
end
