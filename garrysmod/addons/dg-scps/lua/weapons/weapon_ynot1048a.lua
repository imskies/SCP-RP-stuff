AddCSLuaFile()

SWEP.PrintName      = "SCP-1048-A"
SWEP.Author         = "ynot01"
SWEP.Purpose        = ""
SWEP.Instructions   = "Left click to scream"

SWEP.Category       = "ynot01's SWEPs"

SWEP.Slot           = 2
SWEP.SlotPos        = 0

SWEP.Spawnable      = true

SWEP.ViewModel      = Model( "models/weapons/c_arms.mdl" )
SWEP.WorldModel     = ""
SWEP.ViewModelFOV   = 54

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.WepSelectIcon = nil
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

function SWEP:SetupDataTables()
    self:NetworkVar("Float",0,"LastScream")
end

function SWEP:Initialize()
    self:SetLastScream(0)
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

    hook.Add("OnScreenSizeChanged", "ySCP1048A:UpdateResolution", function(oldW, oldH)
        scrw = ScrW()
        scrh = ScrH()
        HPText.pos = {scrw*0.5, scrh*0.85+25}
    end)

    function SWEP:DrawHUD()
        draw.NoTexture()

        --------------- Scream Cooldown ---------------
        if self:GetLastScream() > CurTime() then
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
                Lerp( (self:GetLastScream() - CurTime()) / SCPJobsConfig[1048].ScreamCooldown, 0, ScrW()*0.2 ), 
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

    local HaloCol = Color(0,210,0)

    hook.Add( "PreDrawHalos", "ySCP1048A:ScreamRadiusDraw", function()

        if !IsValid(LocalPlayer():GetActiveWeapon()) then return end
        if LocalPlayer():GetActiveWeapon():GetClass() != "weapon_ynot1048a" then return end

        local NearSphere = ents.FindInSphere(LocalPlayer():GetPos(), SCPJobsConfig[1048].ScreamRadius)

        local applicable = {}

        for k, ply in ipairs( NearSphere ) do
            if ( not( ply.SCPNum ) and ( ply:IsPlayer() ) and ( ply:Alive() ) and not( ply == LocalPlayer() ) and not( ply:HasWeapon("weapon_ynot1048a")) and not( ply:HasWeapon("weapon_ynot1048c")) and not( ply:HasWeapon("weapon_ynot1048")) ) then
                table.insert(applicable, ply)
            end
        end

        halo.Add( applicable, HaloCol, 5, 5, 2 )

    end )


end

function SWEP:PrimaryAttack()
    if CLIENT then return end
    if self:GetLastScream() > CurTime() then return end
    self:SetLastScream(CurTime() + SCPJobsConfig[1048].ScreamCooldown)

    local owner = self:GetOwner()

    owner:EmitSound("1048ascream.wav")

    for i=SCPJobsConfig[1048].ScreamLength*3,1,-1 do
        
        timer.Simple(0.333*i, function()

            if !IsValid(owner) or !owner:Alive() or !IsValid(owner:GetActiveWeapon()) or owner:GetActiveWeapon():GetClass() != "weapon_ynot1048a" then return end
            
            local NearSphere = ents.FindInSphere(owner:GetPos(), SCPJobsConfig[1048].ScreamRadius)

            for k, ply in ipairs( NearSphere ) do
                if ( not( ply.SCPNum ) and ( ply:IsPlayer() ) and ( ply:Alive() ) and not( ply == self:GetOwner() ) and not( ply:HasWeapon("weapon_ynot1048a")) and not( ply:HasWeapon("weapon_ynot1048c")) and not( ply:HasWeapon("weapon_ynot1048")) ) then
                    if not( util.TraceLine({start=owner:GetShootPos(),endpos=ply:GetShootPos(),filter={self:GetOwner(),self,ply}}).Hit) then
                        local Dmg = DamageInfo()
                        Dmg:SetDamage(SCPJobsConfig[1048].ScreamDamage)
                        Dmg:SetAttacker(self:GetOwner())
                        Dmg:SetInflictor(self:GetOwner())
                        Dmg:SetDamageType(DMG_SONIC)
                        ply:TakeDamageInfo(Dmg)
                    end
                end
            end

        end)

    end

end

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
    return true
end

function SWEP:Holster()
    if not IsFirstTimePredicted() then return end
    return true
end

function SWEP:Think()
end