AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	if (CLIENT) then return end 
	
	local getfromtable = MININGSYSTEM.Ores[self:GetNWString("RockType")] 
	self:SetModel(getfromtable.ResourceModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local color = getfromtable.Color 
	self.Type = getfromtable.Type
	self.Name = getfromtable.Name 
	self.DropChance = getfromtable.DropChance 
	if color and self.Type != "Wood" then 
		self:SetColor( color )
	end 

	if getfromtable.Radioactive then 
		self.IsRadioactive = true 
	end 
end

function ENT:RadioactiveDamage()
	if !self.IsRadioactive then return end 

	local findPlayers = player.GetAll()
	local dist = MININGSYSTEM.RadioationDamageRadius
	dist = dist * dist 
	
	for _, v in pairs(findPlayers) do 
		if v:GetPos():DistToSqr( self:GetPos() ) > ( dist ) then continue end 
		if (not v:Alive()) then continue end 
		if v:GetModel() == MININGSYSTEM.SuitModel then continue end 
		
		v:TakeDamage(1,self,nil)
	end
end 
	
function ENT:AtmosRain()
	if AtmosGlobal.m_Storming then 
		if self:GetModel() == "models/geralts/preda/cr.mdl" or self:GetModel() == "models/geralts/preda/rock.mdl" then 
			self:SetBodygroup(1,1)
		end
	else 
		if self:GetBodygroup(1) != 0 then 
			self:SetBodygroup(1,0)
		end 
	end 
end 

function ENT:StormFoxRain()
	if StormFox.IsRaining() then 
		if self:GetModel() == "models/geralts/preda/cr.mdl" or self:GetModel() == "models/geralts/preda/rock.mdl" then 
			self:SetBodygroup(1,1)
		end
	else 
		if self:GetBodygroup(1) != 0 then 
			self:SetBodygroup(1,0)
		end 
	end 
end 

function ENT:SetRainTexture()
	if MININGSYSTEM.WeatherAddon == "Atmos" then 
		self:AtmosRain()
	elseif MININGSYSTEM.WeatherAddon == "StormFox" then 
		self:StormFoxRain()
	end 
end 

function ENT:Think()
	self:NextThink(CurTime() + 1)
	
	self:RadioactiveDamage()	
	
	if MININGSYSTEM.WeatherAddon != "None" then 
		self:SetRainTexture()
	end 
	return true 
end

function ENT:GiveXP(attacker)
	if attacker:GetNWInt("CMS_MiningLevel") == 0 then attacker:SetNWInt("CMS_MiningLevel", 1) end 
	if attacker:GetNWInt("CMS_LevelProgress") > attacker:GetNWInt("CMS_MiningLevel") * MININGSYSTEM.LevelProgress then 
		attacker:SetNWInt("CMS_LevelProgress", 0)
		attacker:SetNWInt("CMS_MiningLevel", attacker:GetNWInt("CMS_MiningLevel") + 1)
	end 
		
	attacker:SetNWInt("CMS_LevelProgress", attacker:GetNWInt("CMS_LevelProgress") + 100 / self.DropChance)
end 

function ENT:OnTakeDamage(dmg)
	local attacker = dmg:GetAttacker()
	if !attacker:IsValid() and !attacker:IsPlayer() then return end 
	local Weapon = MININGSYSTEM.MiningWeapons[attacker:GetActiveWeapon():GetClass()]
	if !Weapon then return end 

	local bonus = Weapon[1]
	local IsAuto = Weapon[2]
	local chance = 0
	if IsAuto then 
		chance = self.DropChance / MININGSYSTEM.AutomaticWeaponsDebuff
	else 
		chance = self.DropChance
	end 
	
	if math.random(0,100) > chance then return end 
	
	self:GiveXP(attacker)
	if attacker:GetNWInt("CMS_MiningLevel") == 0 then attacker:SetNWInt("CMS_MiningLevel", 1) end 
	
	local orecount = math.random(1, 3) + bonus + (MININGSYSTEM.LevelBonus * attacker:GetNWInt("CMS_MiningLevel"))	
	if MININGSYSTEM.MaxOres and attacker:GetNWInt("CMS_"..self.Name) >= MININGSYSTEM.MaxOres then DarkRP.notify(attacker, 1, 2, "You have reached maximum amount of " .. self.Name ) return end 
	attacker:SetNWInt("CMS_"..self.Name, attacker:GetNWInt("CMS_"..self.Name) + orecount)
	
	DarkRP.notify(attacker, 0, 2, "You have mined " .. orecount .. " " .. self.Name )

end