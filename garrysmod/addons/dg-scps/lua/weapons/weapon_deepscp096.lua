if SERVER then

	AddCSLuaFile()



	SWEP.Weight				= 5

	SWEP.AutoSwitchTo		= false

	SWEP.AutoSwitchFrom		= false

	

else

	SWEP.PrintName			= "SCP-096"

	SWEP.Slot				= 0

	SWEP.SlotPos			= 1

	SWEP.DrawAmmo			= false

	SWEP.DrawCrosshair		= false



	SWEP.ViewModelFOV		= 45

	SWEP.WepSelectIcon 		= nil

	--SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_hands")

	SWEP.BounceWeaponIcon=false

	

	local TargMat=Material("sprites/glow04_noz")

	local oldrage, oldwhine = false, false

	local startrage, startwhine = 0, 0



	function SWEP:DrawHUD()



		if((IsValid(self.Owner))and(self.Owner:Alive())and((self:GetRagin())or(self:GetAwakenin())))then



			if self:GetTarget() then

				local pos = self:GetTarget()

				pos.z = pos.z + 10

				local TPos = pos:ToScreen()

				

				surface.SetMaterial(TargMat)

				local Vary=math.sin(CurTime()*40)/2+.5

				surface.SetDrawColor(255,0,0,255*Vary)

				local Size1,Size2=350,100

				surface.DrawTexturedRect(TPos.x-Size1/2,TPos.y-Size1/2,Size1,Size1)

				surface.SetDrawColor(255,255,255,255*Vary)

				surface.DrawTexturedRect(TPos.x-Size2/2,TPos.y-Size2/2,Size2,Size2)

			end





			if self:GetRagin() && !oldrage then

				oldrage = true

				oldwhine = false

				startrage = SysTime()

			end



			if self:GetAwakenin() && !oldwhine then

				oldrage = false

				oldwhine = true

				startwhine = SysTime()

			end



			if self:GetRagin() then

				surface.SetDrawColor(0,0,0)

				surface.DrawRect(ScrW()/2-ScrW()*0.15-6,ScrH()*0.85-6,ScrW()*0.3+12,62)



				surface.SetDrawColor(26,26,26)

				surface.DrawRect(ScrW()/2-ScrW()*0.15-5,ScrH()*0.85-5,ScrW()*0.3+10,60)



				surface.SetDrawColor(62,62,62)

				surface.DrawRect(ScrW()/2-ScrW()*0.15-1,ScrH()*0.85-1,ScrW()*0.3+2,52)

				

				--[[if (SysTime()-startrage) / SCPJobsConfig[96].EnrageTime > 0.65 then

					surface.SetDrawColor(120+((math.sin(CurTime()*30)/2+.5)*100),0,0) -- Faster flash when bar is low

				else

					surface.SetDrawColor(120+((math.sin(CurTime()*15)/2+.5)*100),0,0)

				end]]

				surface.SetDrawColor(210,0,0)

				

				surface.DrawRect(

					ScrW()/2-ScrW()*0.15, 

					ScrH()*0.85, 

					Lerp( (SysTime() - startrage) / SCPJobsConfig[96].EnrageTime, 

					ScrW()*0.3, 0 ), 

					50

				)

			elseif self:GetAwakenin() then

				surface.SetDrawColor(0,0,0)

				surface.DrawRect(ScrW()/2-ScrW()*0.15-6,ScrH()*0.85-6,ScrW()*0.3+12,62)



				surface.SetDrawColor(26,26,26)

				surface.DrawRect(ScrW()/2-ScrW()*0.15-5,ScrH()*0.85-5,ScrW()*0.3+10,60)

				

				surface.SetDrawColor(62,62,62)

				surface.DrawRect(ScrW()/2-ScrW()*0.15-1,ScrH()*0.85-1,ScrW()*0.3+2,52)

				

				--surface.SetDrawColor(120+((math.sin(CurTime()*5)/2+.5)*100),0,0) -- Flash

				surface.SetDrawColor(210,0,0)

				

				surface.DrawRect(

					ScrW()/2-ScrW()*0.15, 

					ScrH()*0.85, 

					Lerp( (SysTime() - startwhine) / 30.5, 0, ScrW()*0.3 ), 

					50

				)

			else

				oldrage = false

				oldwhine = false

			end



		end

	end



	

end



SWEP.SwayScale=3

SWEP.BobScale=3



SWEP.Author			= "ItzPabz & ynot01"

SWEP.Contact		= ""

SWEP.Purpose		= "When someone looks at your face, you can kill anyone"

SWEP.Instructions	= "Sprint & Left click when angry"

SWEP.Category 		= "ynot01's SWEPs"



SWEP.Spawnable			= true

SWEP.AdminOnly		= true



SWEP.HoldType = "normal" -- on reuqest from arsenal, though fists fits better



SWEP.ViewModel	= "models/weapons/c_arms_citizen.mdl"

SWEP.WorldModel	= "models/props_junk/cardboard_box004a.mdl"



SWEP.AttackSlowDown=.5



SWEP.Primary.ClipSize		= -1

SWEP.Primary.DefaultClip	= -1

SWEP.Primary.Automatic		= true

SWEP.Primary.Ammo			= "none"



SWEP.Secondary.ClipSize		= -1

SWEP.Secondary.DefaultClip	= -1

SWEP.Secondary.Automatic	= false

SWEP.Secondary.Ammo			= "none"



SWEP.ReachDistance=60



SWEP.NextChaseSong=0

SWEP.NextScream=0

SWEP.NextViewThink=0

SWEP.NextPlyFetch = 0

SWEP.ShitList={}



SWEP.DestroySound = "physics/wood/wood_furniture_break1.wav"

SWEP.DestroyModels = {

    ["models/foundation/doors/lcz_door.mdl"] = true,

    ["models/foundation/doors/hcz_door_01.mdl"] = true,

    ["models/foundation/doors/hcz_door_02.mdl"] = true,

	["models/foundation/containment/door01.mdl"] = true,

    ["models/novux/map/models/ez_cor_door_1.mdl"] = true,

    ["models/novux/map/models/ez_cor_door_2.mdl"] = true,

	["models/scp_asset_remaster/hcz_door_r.mdl"] = true,

	["models/foundation/doors/hcz_door_02.mdl"] = true,

	["models/foundation/doors/hcz_door_01.mdl"] = true,

	["models/vgis/doors/main_door.mdl"] = true,

	["models/scp_asset_remaster/remastered_door.mdl"] = true,
    ["models/scp_asset_remaster/hcz_door_r.mdl"] = true,
    ["models/custom/br_site65/gate_01_0.mdl"] = true,
    ["models/custom/br_site65/gate_01_0.mdl"] = true,

}



SWEP.RespawnTime = 180



function SWEP:SetupDataTables()

	self:NetworkVar("Bool",0,"Ragin")

	self:NetworkVar("Bool",1,"Awakenin")

	self:NetworkVar("String",0,"ShitList")

	self:NetworkVar("Vector",0,"Target")

end



function SWEP:PreDrawViewModel(vm,wep,ply)

	--vm:SetMaterial("engine/occlusionproxy") -- Hide that view model with hacky material

end



function SWEP:Initialize()

	self:SetHoldType(self.HoldType)

	self:SetRagin(false)

	self:SetAwakenin(false)

	self:SetTarget(Vector(0,0,0))

end



function SWEP:Deploy()

	if(SERVER)then

		self.Owner:SetRunSpeed(SCPJobsConfig[96].NonRageSpeed)

		self.Owner:SetWalkSpeed(SCPJobsConfig[96].NonRageSpeed)

	end

	if not(IsFirstTimePredicted())then

		self:DoBFSAnimation("fists_draw")

		self.Owner:GetViewModel():SetPlaybackRate(.1)

		return

	end

	self:SetNextPrimaryFire(CurTime()+.1)

	self:DoBFSAnimation("fists_draw")

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

	--

end



function SWEP:Awaken()

	if(CLIENT)then return end

	if(self:GetAwakenin())then return end

	if(self:GetRagin())then return end

	self:SetAwakenin(true)

	self.Owner:Freeze(true)

	self.Owner:EmitSound("snds_deep_scp/96awaken.mp3",80,100)

	local ply=self.Owner

	timer.Simple(30.5,function()

		if(IsValid(ply))then

			ply:Freeze(false)

		end

		if(IsValid(self))then

			self:SetRagin(true)

			self:SetAwakenin(false)

			timer.Simple(SCPJobsConfig[96].EnrageTime,function()

				if(IsValid(self))then

					self:Chill()

				end

			end)

		end

	end)

end



function SWEP:Chill()

	if(CLIENT)then return end

	self.ShitList = {}

	self:SetAwakenin(false)

	self:SetRagin(false)

end



function SWEP:AddShitter(shitter)

	if(table.HasValue(self.ShitList,shitter:SteamID()))then return end

	table.insert(self.ShitList,shitter:SteamID())

end



function SWEP:RemoveShitter(shitter)

	if not(table.HasValue(self.ShitList,shitter:SteamID()))then return end

	table.RemoveByValue(self.ShitList,shitter:SteamID())

end



function SWEP:ShouldRage()

	for k,id in pairs(self.ShitList)do

		local ply=player.GetBySteamID(id)

		if((IsValid(ply))and(ply:Alive()))then return true end

	end

	return false

end



function SWEP:OnRemove()

	if(IsValid(self.Owner) && CLIENT && self.Owner:IsPlayer())then

		local vm=self.Owner:GetViewModel()

		if(IsValid(vm)) then vm:SetMaterial("") end

	end

end



local SCPPosAdd = Vector(0,0,20)

local TargPosAdd = Vector(0,0,50)

local playas

function SWEP:Think()

	if(CLIENT)then return end

	if (self.NextPlyFetch <= CurTime()) || !playas then 

		playas = player.GetAll() 

		self.NextPlyFetch = CurTime() + 20

	end

	local Rage,Wake=self:GetRagin(),self:GetAwakenin()

	if(Rage)then

		self.Owner:SetRunSpeed(SCPJobsConfig[96].SprintSpeed)

		if(self.NextScream<CurTime())then

			self.NextScream=CurTime()+9.5

			self.Owner:EmitSound("snds_deep_scp/96scream.mp3",80,100)

		end

		if(self.NextChaseSong<CurTime())then

			self.NextChaseSong=CurTime()+22.5

			for k,id in pairs(self.ShitList)do

				local ply=player.GetBySteamID(id)

				if(IsValid(ply))then ply:EmitSound("snds_deep_scp/96chase.mp3",55,100) end

			end

		end

	else

		self.Owner:SetRunSpeed(SCPJobsConfig[96].NonRageSpeed)

		if(self.NextScream<CurTime())then

			self.NextScream=CurTime()+5

			self.Owner:EmitSound("snds_deep_scp/96idle"..math.random(1,3)..".wav",70,100)

		end

	end

	if(self.NextViewThink>CurTime())then return end

	self.NextViewThink = CurTime()+2

	local scp = self.Owner

	local SCPPos,SCPVec,Seen=scp:GetShootPos()+SCPPosAdd,scp:GetAimVector(),false

	for k,ply in pairs(playas)do

		if((ply!=scp)and(ply:Alive())and not(ply.SCPNum)and not(table.HasValue(self.ShitList,ply:SteamID()))and not(table.HasValue(SCPJobsConfig[96].IgnoredJobs,ply:getDarkRPVar("job"))))then

			local PlyPos,PlyVec=ply:GetShootPos(),ply:GetAimVector()

			if not(util.TraceLine({start=PlyPos,endpos=SCPPos,filter={ply,scp}}).Hit)then

				local TrueVec=SCPPos-PlyPos

				local DotProduct=PlyVec:DotProduct(TrueVec:GetNormalized())

				local ApproachAngle=(-math.deg(math.asin(DotProduct))+90)

				if(ApproachAngle<(ply:GetFOV()/2.5))then

					local DotProduct=PlyVec:DotProduct(SCPVec)

					local ViewDiffAngle=(-math.deg(math.asin(DotProduct))+90)

					if(ViewDiffAngle>135)then self:AddShitter(ply) end

				end

			end

		end

	end

	local Should=self:ShouldRage()

	if(Rage)then

		--if not(Should)then self:Chill() end

	elseif not(Awake)then

		if(Should)then self:Awaken() end

	end

	local Shits,TargPos,Dist,SelfPos="",nil,9e9,self.Owner:GetPos()

	for k,v in pairs(self.ShitList)do

		local ply=player.GetBySteamID(v)

		if((IsValid(ply))and(ply:Alive()))then

			Shits=Shits..ply:Nick().."#!*&"

			local Pos=ply:GetPos()

			local CurDist=Pos:Distance(SelfPos)

			if(CurDist<Dist) and k == 1 then

				Dist=CurDist

				TargPos=Pos+TargPosAdd

			end

		end

	end

	self:SetShitList(Shits)

	if(TargPos)then self:SetTarget(TargPos) else self:SetTarget(Vector(0,0,0)) end

end



function SWEP:PrimaryAttack()

	if not(self:GetRagin())then return end

	local side="fists_left"

	if(math.random(1,2)==1)then side="fists_right" end

	if not(IsFirstTimePredicted())then

		self:DoBFSAnimation(side)

		self.Owner:GetViewModel():SetPlaybackRate(3)

		return

	end

	self.Owner:ViewPunch(Angle(0,0,math.random(-2,2)))

	self:DoBFSAnimation(side)

	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self.Owner:GetViewModel():SetPlaybackRate(3)

	if(SERVER)then

		sound.Play("weapons/slam/throw.wav",self:GetPos(),65,math.random(90,110))

		self.Owner:ViewPunch(Angle(0,0,math.random(-2,2)))

		timer.Simple(.025,function()

			if(IsValid(self))then

				self:AttackFront()

			end

		end)

	end

	self:SetNextPrimaryFire(CurTime()+.15)

	self:SetNextSecondaryFire(CurTime()+.15)

end



function SWEP:WhomILookinAt(ply)

	local Tr = util.TraceLine( {

		start = ply:GetShootPos(),

		endpos = ply:GetShootPos() + ply:GetAimVector() * 80,

		filter = ply,

		mask = MASK_SHOT_HULL

	} )



	if ( !IsValid( Tr.Entity ) ) then

		Tr = util.TraceHull( {

			start = ply:GetShootPos(),

			endpos = ply:GetShootPos() + ply:GetAimVector() * 80,

			filter = ply,

			mins = Vector( -10, -10, -8 ),

			maxs = Vector( 10, 10, 8 ),

			mask = MASK_SHOT_HULL

		} )

	end

	if(Tr.Hit)then return Tr.Entity,Tr.HitPos end

end



function SWEP:IsDoor(ent)

	return IsValid(ent) and (ent:GetClass() == "func_door" or (ent:GetClass() == "prop_dynamic" and self.DestroyModels[ent:GetModel()]))

end



function SWEP:AttackFront()

	if(CLIENT)then return end

	self.Owner:LagCompensation(true)

	local Ent,HitPos=self:WhomILookinAt(self.Owner,.3,55)

	local AimVec=self.Owner:GetAimVector()

	if((IsValid(Ent))or((Ent)and(Ent.IsWorld)and(Ent:IsWorld())))then

		local SelfForce,Mul=125,1

		if(self:IsEntSoft(Ent))then

			SelfForce=25

			sound.Play("Flesh.ImpactHard",HitPos,65,math.random(90,110))

		else

			sound.Play("Flesh.ImpactSoft",HitPos,65,math.random(90,110))

		end

		local DamageAmt=SCPJobsConfig[96].StrikeDamage

		local Dam=DamageInfo()

		Dam:SetAttacker(self.Owner)

		Dam:SetInflictor(self.Weapon)

		Dam:SetDamage(DamageAmt*Mul)

		Dam:SetDamageForce(AimVec*Mul^3)

		Dam:SetDamageType(DMG_CLUB)

		Dam:SetDamagePosition(HitPos)

		Ent:TakeDamageInfo(Dam)

		local Phys=Ent:GetPhysicsObject()

		if(IsValid(Phys))then

			if(Ent:IsPlayer())then Ent:SetVelocity(AimVec*SelfForce*1.5) end

			Phys:ApplyForceOffset(AimVec*50000*Mul,HitPos)

		end

		if(self:IsDoor(Ent))then

			if(math.Rand(0,1)<SCPJobsConfig[96].DoorPunchChance)then DeepSCP_DestroyDoor(self:GetOwner():GetPos(), self:GetOwner(), self) end

		end

	end

	self.Owner:LagCompensation(false)

end



function SWEP:Reload()

	--

end



function SWEP:DrawWorldModel()

	-- no, do nothing

end



function SWEP:DoBFSAnimation(anim)

	local vm=self.Owner:GetViewModel()

	vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))

end



function SWEP:IsEntSoft(ent)

	return ((ent:IsNPC())or(ent:IsPlayer()))

end



if(CLIENT)then

	function SWEP:GetViewModelPosition(pos,ang)

		if not(self:GetRagin())then pos=pos-ang:Up()*20 end

		return pos,ang

	end

end