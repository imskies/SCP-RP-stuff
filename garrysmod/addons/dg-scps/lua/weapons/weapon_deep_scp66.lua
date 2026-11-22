if SERVER then
	AddCSLuaFile()

	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
	
else
	SWEP.PrintName			= "SCP-066"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 1
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= false

	SWEP.ViewModelFOV		= 90
	SWEP.WepSelectIcon=nil
	SWEP.BounceWeaponIcon=false

	function SWEP:DrawHUD()
		--
	end
end

SWEP.SwayScale=3
SWEP.BobScale=3

SWEP.Author			= "ItzPabz"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Left click for \"Eric\", Reload for notes, Right click to unleash Beethoven's wrath"
SWEP.Category 		= "Pabz's Deepgaming Sweps"

SWEP.Spawnable			= false
SWEP.AdminOnly		= true

SWEP.HoldType = "normal"

SWEP.ViewModel	= "models/props_docks/dock01_cleat01a.mdl"
SWEP.WorldModel	= "models/props_docks/dock01_cleat01a.mdl"

SWEP.AttackSlowDown=.5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.NextEric=0
SWEP.NextEarRape=0
SWEP.NextMusicStop=0
SWEP.NextThinkTime=0
SWEP.NextNote=0

function SWEP:SetupDataTables()
	--
end

function SWEP:PreDrawViewModel(vm,wep,ply)
	--
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
	self:SetNextPrimaryFire(CurTime()+.1)
	return true
end

function SWEP:Holster()
	self:OnRemove()
	return true
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:SecondaryAttack()
	if(CLIENT)then return end
	if(self.NextEarRape<CurTime())then
		self.NextEarRape=CurTime()+SCPJobsConfig[66].EarRapeCooldown
		self.NextMusicStop=CurTime()+19
		net.Start("SCPJobs_EmitSound")
		net.WriteEntity(self.Owner)
		net.WriteString("snds_deep_scp/66music.mp3")
		net.Broadcast()
	end
end

function SWEP:OnRemove()
	if(IsValid(self.Owner) && CLIENT && self.Owner:IsPlayer())then
		local vm=self.Owner:GetViewModel()
		if(IsValid(vm)) then vm:SetMaterial("") end
	end
end

function SWEP:Think()
	if(CLIENT)then return end
	local Time=CurTime()
	if(self.NextThinkTime>Time)then return end
	self.NextThinkTime=Time+1
	local SelfPos=self.Owner:GetShootPos()
	if(self.NextMusicStop>Time)then
		for k,ply in pairs(ents.FindInSphere(SelfPos,SCPJobsConfig[66].EarRapeDamageRadius))do
			if((ply:IsPlayer())and(ply:Alive())and not(ply==self.Owner))then
				if not(util.TraceLine({start=SelfPos,endpos=ply:GetShootPos(),filter={self.Owner,self,ply}}).Hit)then
					local Dmg=DamageInfo()
					Dmg:SetDamage(SCPJobsConfig[66].EarRapeDamage)
					Dmg:SetAttacker(self.Owner)
					Dmg:SetInflictor(self.Owner)
					Dmg:SetDamageType(DMG_SONIC) -- ROLLIN AROUND AT THE SPEED OF SOUND GOT NO PLACE TO GO GOTTA FOLLOW MY RAINBOW
					ply:TakeDamageInfo(Dmg)
				end
			end
		end
	end
end

function SWEP:PrimaryAttack()
	if(CLIENT)then return end
	if(self.NextEric<CurTime())then
		self.NextEric=CurTime()+SCPJobsConfig[66].EricCooldown
		self.Owner:EmitSound("snds_deep_scp/66eric.wav",65,100)
	end
end

function SWEP:Reload()
	if(CLIENT)then return end
	if(self.NextNote<CurTime())then
		self.NextNote=CurTime()+SCPJobsConfig[66].NoteCooldown
		self.Owner:EmitSound("snds_deep_scp/66note"..math.random(1,3)..".wav",65,100)
	end
end

function SWEP:DrawWorldModel()
	-- no, do nothing
end

function SWEP:DoBFSAnimation(anim)
	local vm=self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
end

if(CLIENT)then
	function SWEP:GetViewModelPosition(pos,ang)
		pos=pos-ang:Up()*30+ang:Right()*10
		return pos,ang
	end
end