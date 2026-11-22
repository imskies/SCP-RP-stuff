AddCSLuaFile()

SWEP.PrintName      = "SCP-666-DG"
SWEP.Author         = "ynot01"
SWEP.Purpose        = ""
SWEP.Instructions   = "Happy Halloween, RMB to Bone Chuck, LMB to Melee"

SWEP.Category       = "ynot01's SWEPs"

SWEP.Slot           = 2
SWEP.SlotPos        = 0

SWEP.Spawnable      = true

SWEP.ViewModel      = Model( "models/weapons/c_arms.mdl" )
SWEP.WorldModel     = ""
SWEP.ViewModelFOV   = 54

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.WepSelectIcon = nil
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.DestroySound = "physics/wood/wood_furniture_break1.wav"
SWEP.DestroyModels = {
    ["models/foundation/doors/lcz_door.mdl"] = true,
    ["models/foundation/doors/hcz_door_01.mdl"] = true,
    ["models/foundation/doors/hcz_door_02.mdl"] = true,
	["models/foundation/containment/door01.mdl"] = true,
    ["models/novux/map/models/ez_cor_door_1.mdl"] = true,
    ["models/novux/map/models/ez_cor_door_2.mdl"] = true,
}

SWEP.RespawnTime = 180

function SWEP:SetupDataTables()
    self:NetworkVar("Float",0,"LastShred")
    self:NetworkVar("Float",1,"LastThrow")
end

function SWEP:Initialize()
    self:SetLastShred(0)
    self:SetLastThrow(0)
    self:SetHoldType("normal")
end

if CLIENT then

    local scrw = ScrW() -- lowercase to differentiate from the function
    local scrh = ScrH()

    local HPText = {
        text = "0",
        font = "ySCP1048Font",
        pos = {scrw*0.5, scrh*0.85+25},
        xalign = TEXT_ALIGN_CENTER,
        yalign = TEXT_ALIGN_CENTER,
        color = color_white,
    }

    hook.Add("OnScreenSizeChanged", "ySCP1048C:UpdateResolution", function(oldW, oldH)
        scrw = ScrW()
        scrh = ScrH()
        HPText.pos = {scrw*0.5, scrh*0.85+25}
    end)

    function SWEP:DrawHUD()
        draw.NoTexture()

        --------------- Shred Cooldown ---------------
        if self:GetLastShred() > CurTime() then
            draw.NoTexture()

            surface.SetDrawColor(0,0,0)
            surface.DrawRect(scrw/2-scrw*0.1-6,scrh*0.81-6,scrw*0.2+12,32)

            surface.SetDrawColor(26,26,26)
            surface.DrawRect(scrw/2-scrw*0.1-5,scrh*0.81-5,scrw*0.2+10,30)

            surface.SetDrawColor(62,62,62)
            surface.DrawRect(scrw/2-scrw*0.1-1,scrh*0.81-1,scrw*0.2+2,22)

            surface.SetDrawColor(0,180,0)
            surface.DrawRect(
                ScrW()/2-ScrW()*0.1, 
                ScrH()*0.81, 
                Lerp( (self:GetLastShred() - CurTime()) / SCPJobsConfig[666].ShredCooldown, 0, ScrW()*0.2 ), 
                20
            )
        end

        --------------- Throw Cooldown ---------------
        if self:GetLastThrow() > CurTime() then
            draw.NoTexture()

            surface.SetDrawColor(0,0,0)
            surface.DrawRect(scrw/2-scrw*0.1-6,scrh*0.81-6,scrw*0.2+12,32)

            surface.SetDrawColor(26,26,26)
            surface.DrawRect(scrw/2-scrw*0.1-5,scrh*0.81-5,scrw*0.2+10,30)

            surface.SetDrawColor(62,62,62)
            surface.DrawRect(scrw/2-scrw*0.1-1,scrh*0.81-1,scrw*0.2+2,22)

            surface.SetDrawColor(0,180,0)
            surface.DrawRect(
                ScrW()/2-ScrW()*0.1, 
                ScrH()*0.81, 
                Lerp( (self:GetLastThrow() - CurTime()) / SCPJobsConfig[666].ThrowCooldown, 0, ScrW()*0.2 ), 
                20
            )
        end

        --------------- HP Bar ---------------
        draw.NoTexture()

        surface.SetDrawColor(0,0,0)
        surface.DrawRect(scrw/2-scrw*0.1-6,scrh*0.85-6,scrw*0.2+12,62)

        surface.SetDrawColor(26,26,26)
        surface.DrawRect(scrw/2-scrw*0.1-5,scrh*0.85-5,scrw*0.2+10,60)

        surface.SetDrawColor(62,62,62)
        surface.DrawRect(scrw/2-scrw*0.1-1,scrh*0.85-1,scrw*0.2+2,52)

        surface.SetDrawColor(210,0,0)
        surface.DrawRect(
            ScrW()/2-ScrW()*0.1, 
            ScrH()*0.85, 
            ScrW()*0.2*(LocalPlayer():Health()/LocalPlayer():GetMaxHealth()), 
            50
        )

        HPText.text = LocalPlayer():Health()
        draw.Text(HPText)

    end

end

function SWEP:PrimaryAttack()
    if CLIENT then return end
    if self:GetLastShred() > CurTime() then return end
    if self:GetLastThrow() > CurTime() - (0.3) then return end
    self:SetLastShred(CurTime() + SCPJobsConfig[666].ShredCooldown)

    local owner = self:GetOwner()

    if !IsValid(owner) or !owner:Alive() or !IsValid(owner:GetActiveWeapon()) or owner:GetActiveWeapon():GetClass() != "weapon_scp666" then return end

    local NearSphere = ents.FindInSphere(owner:EyePos(), SCPJobsConfig[666].ShredRadius)

    local hit = false

    for k, ply in ipairs( NearSphere ) do
        if IsValid(ply) and (ply:GetClass() == "func_door" or (ply:GetClass() == "prop_dynamic" and self.DestroyModels[ply:GetModel()])) then
            DeepSCP_DestroyDoor(self:GetOwner():GetPos(), self:GetOwner(), self)
        end
        if ( not( ply.SCPNum ) and ( ply:IsPlayer() ) and ( ply:Alive() ) and not( ply == self:GetOwner() ) and not( ply:HasWeapon("weapon_ynot1048a")) and not( ply:HasWeapon("weapon_scp666")) and not( ply:HasWeapon("weapon_ynot1048")) ) then
            if not( util.TraceLine({start=owner:GetShootPos(),endpos=ply:GetShootPos(),filter={self:GetOwner(),self,ply}}).Hit) then
                hit = true
                local Dmg = DamageInfo()
                Dmg:SetDamage(SCPJobsConfig[666].ShredDamage)
                Dmg:SetAttacker(self:GetOwner())
                Dmg:SetInflictor(self:GetOwner())
                Dmg:SetDamageType(DMG_SLASH)
                ply:EmitSound("weapons/thompson/nailgun_quiet.wav")
                ply:TakeDamageInfo(Dmg)
            end
        end
    end

    if !hit then
        owner:EmitSound("weapons/thompson/nailgun_quiet.wav")
    end

end

function SWEP:SecondaryAttack()
    if CLIENT then return end
    if self:GetLastShred() > CurTime() - (0.3) then return end
    if self:GetLastThrow() > CurTime() then return end
    self:SetLastThrow(CurTime() + SCPJobsConfig[666].ThrowCooldown)

    local owner = self:GetOwner()

    if ( not owner:IsValid() ) then return end

    local EntA = ents.Create( "prop_physics" )
    local EntB = ents.Create( "prop_physics" )
    EntA:SetNWBool("ySCP666:Saw", true)
    EntB:SetNWBool("ySCP666:Saw", true)

    for p=1,0,-1 do

        timer.Simple((0.25*p)+0.05, function()
            
            owner:EmitSound( "ambient/halloween/male_scream_19.wav" )

            local ent

            if p == 1 then
                ent = EntA
            else
                ent = EntB
            end

            if ( not ent:IsValid() ) then return end

            ent:SetModel( "models/weapons/monstermash/w_boner.mdl" )

            local AimVec = owner:GetAimVector()
            local pos = AimVec * 1 -- This creates a new vector object
            pos:Add( owner:EyePos() ) -- This translates the local aimvector to world coordinates
            --if !owner:Crouching() then pos.z = pos.z - 30 end
            ent:SetPos( pos )
            local AngEye = owner:EyeAngles()
            if p == 1 then
                AngEye.z = AngEye.z + 90
            end
            ent:SetAngles( AngEye )

            ent:Spawn()

            ent:SetModelScale(0.3, 0.0001)

            timer.Simple(0.05, function()
                if IsValid(ent) then ent:EmitSound("weapons/bone/swing1.wav") end
            end)

            local phys = ent:GetPhysicsObject()
            if ( not phys:IsValid() ) then 
                ent:Remove() 
                return 
            end

            phys:EnableGravity(false)

            AimVec:Mul( 50000 )
            --AimVec:Add( VectorRand( -100, 100 ) ) -- Add a random vector with elements [-10, 10)
            phys:ApplyForceCenter( AimVec )
            phys:AddAngleVelocity( Vector(0,0,-1000) )

            ent:AddCallback("PhysicsCollide", function(orig, data)
                if IsEntity(data.HitEntity) then
                    local targ = data.HitEntity
                    local Dmg = DamageInfo()
                    Dmg:SetDamage(SCPJobsConfig[666].ThrowDamage)
                    Dmg:SetAttacker(self:GetOwner())
                    Dmg:SetInflictor(self:GetOwner())
                    Dmg:SetDamageType(DMG_SLASH)
                    if targ:IsPlayer() then 
                        targ:EmitSound("weapons/bone/boner2.wav") 
                    else
                        orig:EmitSound("weapons/bone/boner2.wav")
                    end
                    targ:TakeDamageInfo(Dmg)
                    ent:Remove()
                end
            end)

            timer.Simple(10, function()
                if IsValid(ent) then
                    ent:Remove()
                end
            end)

        end)

    end


end

-- Collision for saws
hook.Add( "ShouldCollide", "ySCP666:SawCollision", function( ent1, ent2 )

    if !(( ent1:IsPlayer() && ent1:Alive() && IsValid(ent1:GetActiveWeapon()) && ent1:GetActiveWeapon():GetClass() == "weapon_scp666" ) or ( ent2:IsPlayer() && ent2:Alive() && IsValid(ent2:GetActiveWeapon()) && ent2:GetActiveWeapon():GetClass() == "weapon_scp666" )) then return end
    -- ^ Checks if ent1 or ent2 is holding weapon_ynot1048c; if not, then returns nothing

    if ent1:GetNWBool("ySCP666:Saw", false) == true or ent2:GetNWBool("ySCP666:Saw", false) == true then
        return false
    end

end )

function SWEP:Deploy()
    self:GetOwner():SetCustomCollisionCheck(true)
    return true
end

function SWEP:Holster()
    if not IsFirstTimePredicted() then return end
    return true
end