SWEP.PrintName			= "SCP-035" -- This will be shown in the spawn menu, and in the weapon selection menu

SWEP.Author			= "ynot01" -- These two options will be shown when you have the weapon highlighted in the weapon selection menu

SWEP.Instructions		= "Hold left click to take over whoever you're looking at, provided they're in your range"



SWEP.Range = 86         -- How far away can 035 possess someone?

SWEP.HostHP = 100       -- How much health does 035's host have?

SCP035Team = "scp035"   -- What is the command for 035's job?



SWEP.Category = "ynot01's SWEPs"



SWEP.Spawnable = true

SWEP.AdminOnly = true -- Spawning this as not 035 is a bad idea



SWEP.Primary.ClipSize		= -1

SWEP.Primary.DefaultClip	= -1

SWEP.Primary.Automatic		= true

SWEP.Primary.Ammo		= "none"



SWEP.Secondary.ClipSize		= -1

SWEP.Secondary.DefaultClip	= -1

SWEP.Secondary.Automatic	= false

SWEP.Secondary.Ammo		= "none"



SWEP.Slot			= 2

SWEP.SlotPos			= 1

SWEP.DrawAmmo			= false

SWEP.DrawCrosshair		= true



SWEP.ViewModel			= "models/weapons/v_pistol.mdl"

SWEP.WorldModel			= ""



function SWEP:Equip()



    self.Owner:SetRunSpeed(1)

    self.Owner:SetWalkSpeed(1)

    self.Owner:SetSlowWalkSpeed(1)



end



function SWEP:PrimaryAttack()

	-- Fires automatically

	self:SetNextPrimaryFire( CurTime() + 0.05 )	

	

	if ( CLIENT ) then return end



	if ( self.Owner:IsPlayer() ) then

		self.Owner:LagCompensation( true )

	end



	local tr = util.TraceLine( {

		start = self.Owner:GetShootPos(),

		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.Range,

		filter = self.Owner

	} )



	if ( self.Owner:IsPlayer() ) then

		self.Owner:LagCompensation( false )

	end



	local ent = tr.Entity

	

	if ( IsValid( ent ) && ent:IsPlayer()) then

		

        self:TakeOver(ent)

		

	end



end



-- Externally load the kit because once you strip 035 SWEP it no longer wants to do things for you

local function loadKit(ply, hp, weplist, wepactive, ammotable)



    -- Take away everything 035 has

    ply:StripWeapons()



    -- Give what the victim has to 035

    for k, v in ipairs(weplist) do

        

        ply:Give(v:GetClass())



    end

    ply:SelectWeapon(wepactive:GetClass())



    for k, v in pairs(ammotable) do

        

        ply:GiveAmmo( v, k, true )



    end



    -- Set 035's HP to the config host HP

    ply:SetHealth(hp)

    ply:SetMaxHealth(hp)



end

function DecayOnTakeOver()
    local oef = self:GetOwner()
    if (oef:Health() < 10000 && oef:Health() > 0) then
        oef:SetHealth(oef:Health()-4)
    end
end
-- Begin assimilation

function SWEP:TakeOver(ent)



    local possessPos = ent:GetPos()

    local possessAng = ent:EyeAngles()

    local possessWeps = ent:GetWeapons()

    local possessAmmo = ent:GetAmmo()

    local possessActive = ent:GetActiveWeapon()

    local possessRun = ent:GetRunSpeed()

    local possessWalk = ent:GetWalkSpeed()

    local possessAlt = ent:GetSlowWalkSpeed()



    -- Remove the victim

	ent:KillSilent()



    -- Make 035 the victim

    self.Owner:SetPos(possessPos)

    self.Owner:SetEyeAngles(possessAng)

    self.Owner:SetRunSpeed(possessRun)

    self.Owner:SetWalkSpeed(possessWalk)

    self.Owner:SetSlowWalkSpeed(possessAlt)

    timer.Create("decayt", 1, 2, 88, function() DecayOnTakeOver() end)

    -- Replace 035's loadout with the victim's

    loadKit(self.Owner, self.HostHP, possessWeps, possessActive, possessAmmo)



end



-- Respawn so 035 doesn't go back to spawn when he loses a host

hook.Add( "PlayerDeath", "better035CustomDeath", function(victim, inflictor, attacker)



    if (RPExtraTeams[victim:Team()].command == SCP035Team && (attacker != victim || !IsValid(attacker))) then 



        local deathPos = victim:GetPos()

        timer.Remove("decayt")

        timer.Simple( 1, function()

            local deathAng = victim:EyeAngles()

            victim:Spawn()

            victim:SetPos(deathPos)

            victim:SetEyeAngles(deathAng)

        end)

    

    end



end)



function SWEP:SecondaryAttack()

end