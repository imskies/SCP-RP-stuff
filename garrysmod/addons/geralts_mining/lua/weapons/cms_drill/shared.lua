if CLIENT then
	SWEP.PrintName = "JackHammer" -- For english translate this to Pickaxe
	SWEP.Slot = 1
	SWEP.SlotPos = 5
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

-- sound.Add( {
	-- name = "cms_drilling",
	-- channel = CHAN_AUTO,
	-- volume = 0.3,
	-- level = 75,
	-- pitch = 100,
	-- sound = "physics/metal/metal_box_scrape_rough_loop2.wav"
-- } )

SWEP.Author = "\nCODE: Geralt Of Rivia\nMODEL: Preda"
SWEP.Instructions = "Left Click: Mine Ore" -- For english translate this to Left click to destroy rocks
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel 	= Model( "models/geralts/preda/v_bur.mdl" )
SWEP.WorldModel = Model( "models/geralts/preda/w_bur.mdl" )

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "Mining System"

SWEP.UseHands = true
SWEP.AttackSound = "miningsystem/jackhammer.wav"

SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = true;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.Damage = 1;
SWEP.Primary.Delay = 0.1;
SWEP.Primary.Ammo = "";

SWEP.Secondary.Automatic = true
SWEP.Secondary.Delay = 0.2;

function SWEP:Initialize()
	self:SetHoldType("crossbow")
	self:SendWeaponAnim(ACT_VM_DRAW);
	self.AttackSoundLooped = CreateSound(self, self.AttackSound)
	self.OverHeatRate = MININGSYSTEM.DrillOverheatRate or 1
end

function SWEP:Deploy()
	if MININGSYSTEM.FunMode then self:EmitSound("miningsystem/fun_mode/lube_it_up.mp3") end
end 

function SWEP:DoHitEffects()
	local trace = self.Owner:GetEyeTraceNoCursor();
		
	if (((trace.Hit or trace.HitWorld) and self.Owner:GetShootPos():Distance(trace.HitPos) <= 80)) then
		local effectdata = EffectData()
		effectdata:SetOrigin( trace.HitPos	)
		util.Effect( "ManhackSparks", effectdata )
	end;
end;

local OverHeating = 0 

function SWEP:OverHeat(orgasm, chance)
	self:SendWeaponAnim( ACT_VM_RELOAD )
	
	if CurTime() < OverHeating then return end 
	if CLIENT then 
		if self.AttackSoundLooped:IsPlaying() == true then  
			self.AttackSoundLooped:Stop()
		end 	
		self.Attacking = false
	end 
	
	if SERVER then 
		DarkRP.notify(self.Owner, 1, 5, "Your drill overheated!")
		timer.Simple(0.1, function()
			if MININGSYSTEM.FunMode then 
				if chance < 40 then 
					self:EmitSound( "miningsystem/fun_mode/Orgasm"..orgasm..".mp3", 75, 100, 0.8, CHAN_AUTO )
				else 
					self:EmitSound( "weapons/crossbow/reload1.wav", 75, 100, 1, CHAN_AUTO )
				end 
			else 
				self:EmitSound( "weapons/crossbow/reload1.wav", 75, 100, 1, CHAN_AUTO )
			end 
		end)			
	end 
	OverHeating = CurTime() + 1

end 

function SWEP:PrimaryAttack()
	if CLIENT then 
		self.Attacking = true 
	end 
	if self:GetNWFloat("Overheat") > 90 then self:SetNextPrimaryFire(CurTime() + 5) self:StopSound("drilling") return self:OverHeat(math.random(1,6), math.random(0,100)) end 
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
	self:DoHitEffects()
	if CLIENT then 
		if self.Attacking == true and self.AttackSoundLooped:IsPlaying() == false then 
			self.AttackSoundLooped:Play()
		end 
	end 	
	if (SERVER) then
		if (self.Owner.LagCompensation) then
			self.Owner:LagCompensation(true);
		end;
		
		local trace = self.Owner:GetEyeTraceNoCursor();
		
		if (self.Owner:GetShootPos():Distance(trace.HitPos) <= 80) then
			if (IsValid(trace.Entity)) then
				self.Owner:FireBullets({
					Spread = Vector(0, 0, 0),
					Damage = 1,
					Tracer = 0,
					Force = 1,
					Num = 1,
					Src = self.Owner:GetShootPos(),
					Dir = self.Owner:GetAimVector()
				});
			end;
		end;
		
		if (self.Owner.LagCompensation) then
			self.Owner:LagCompensation(false);
		end;
	end;
	self.Owner:SetAnimation(PLAYER_ATTACK1);
	self:SetNWFloat("Overheat", math.Clamp(self:GetNWFloat("Overheat") + self.OverHeatRate, 0, 100))

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

end

function SWEP:SecondaryAttack()
end 


if CLIENT then 
local smooth = 0
local BarLerp = 0
local velocity = 3
function SWEP:DrawHUD()
	local OverheatCol = math.Clamp(self:GetNWFloat("Overheat"), 0, 100)
	
	BarLerp = Lerp(FrameTime() * velocity, BarLerp, OverheatCol)
	smooth = math.Approach(smooth, OverheatCol, 50*FrameTime())
	
	local DrawOverheat = math.Clamp( math.Min(BarLerp / 100, 1), 0, 100)
	local red = (smooth/210)^(1/2) * 255
	local grn = (1 - smooth/100)^(1/2) * 255
	local blu = 10
	
	local col = Color(red, grn, blu) 
	draw.SimpleTextOutlined("Overheat: " .. math.Round(self:GetNWFloat("Overheat")) .. "%", "CMS_ItemNameFont", ScrW() * 0.31, ScrH() * 0.97, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0))

end 

hook.Add("PostDrawViewModel", "cms_drill_hands", function( vm, ply, weapon )

	if ( weapon.UseHands || !weapon:IsScripted() ) then

		local hands = LocalPlayer():GetHands()
		if ( IsValid( hands ) ) then hands:DrawModel() end

	end

end)
end 

function SWEP:Think()	
	if CLIENT then 
		if not input.IsMouseDown(MOUSE_LEFT) then 
			self:SendWeaponAnim( ACT_VM_RELOAD )
			self.Attacking = false
		end 	

		if self.Attacking == false and self.AttackSoundLooped:IsPlaying() == true then  
			self.AttackSoundLooped:Stop()
		end 
	end 
	
		self:SetNWFloat("Overheat", math.Clamp(self:GetNWFloat("Overheat") - 0.1, 0, 100))
	self:NextThink(CurTime() + 0.5)
		
end