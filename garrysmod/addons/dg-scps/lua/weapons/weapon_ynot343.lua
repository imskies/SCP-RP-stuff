AddCSLuaFile()

SWEP.PrintName      = "SCP-343"
SWEP.Author         = "ynot01"
SWEP.Purpose        = "Blessings have a "..SCPJobsConfig[343].BlessCD.." second cooldown."
SWEP.Instructions   = "Primary attack to bless all of those around you"

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

local CurrentlyBoosting = {} -- Serverside list of all currently boosted by this SWEP

function SWEP:SetupDataTables()
    self:NetworkVar("Float",0,"LastBlessing")
end

function SWEP:Initialize()
    self:SetLastBlessing(0)
    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
    if CLIENT then return end
    if self:GetLastBlessing() > CurTime() then return end

    self:SetLastBlessing(CurTime()+SCPJobsConfig[343].BlessCD)

    local owner = self:GetOwner()

    owner:EmitSound("npc/attack_helicopter/aheli_charge_up.wav")

    for k,v in ipairs(ents.FindInSphere(owner:GetPos(), SCPJobsConfig[343].BlessRadius)) do
        if !v:IsPlayer() then continue end
        if v.SCPNum then continue end
        if v == owner then continue end
        CurrentlyBoosting[v] = true
        v:SetHealth(v:Health() + SCPJobsConfig[343].BlessHealth)
        v:SetArmor(v:Armor() + SCPJobsConfig[343].BlessArmor)
        v:SetWalkSpeed(v:GetWalkSpeed() * SCPJobsConfig[343].BlessSpeed)
        v:SetRunSpeed(v:GetRunSpeed() * SCPJobsConfig[343].BlessSpeed)
        v:SetSlowWalkSpeed(v:GetSlowWalkSpeed() * SCPJobsConfig[343].BlessSpeed)
        v:SetNWBool("y343Bless", true)
    end

    RemoveBlessings()

end

function RemoveBlessings()
    timer.Simple(SCPJobsConfig[343].BlessLength, function() 

        for ply,v in pairs(CurrentlyBoosting) do
            if IsValid(ply) and IsEntity(ply) and ply:IsPlayer() then
                ply:SetHealth(math.max(ply:Health() - SCPJobsConfig[343].BlessHealth, 1))
                ply:SetArmor(math.max(ply:Armor() - SCPJobsConfig[343].BlessArmor, 0))
                ply:SetWalkSpeed(ply:GetWalkSpeed() / SCPJobsConfig[343].BlessSpeed)
                ply:SetRunSpeed(ply:GetRunSpeed() / SCPJobsConfig[343].BlessSpeed)
                ply:SetSlowWalkSpeed(ply:GetSlowWalkSpeed() / SCPJobsConfig[343].BlessSpeed)
                ply:SetNWBool("y343Bless", false)
            end
            CurrentlyBoosting[ply] = nil
        end

    end)
end

hook.Add("PostPlayerDeath", "ySCP343:RemoveDead", function(ply)
    if CurrentlyBoosting[ply] then
        ply:SetNWBool("y343Bless", false)
        CurrentlyBoosting[ply] = nil
    end
end)

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

if CLIENT then

    local scrw = ScrW() -- lowercase to differentiate from the function
    local scrh = ScrH()

    hook.Add("OnScreenSizeChanged", "ySCP343:UpdateResolution", function(oldW, oldH)
        scrw = ScrW()
        scrh = ScrH()
    end)

    function SWEP:DrawHUD()

        --------------- Cure Cooldown ---------------
        if self:GetLastBlessing() > CurTime() then
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
                Lerp( (self:GetLastBlessing() - CurTime()) / SCPJobsConfig[343].BlessCD, 0, ScrW()*0.2 ), 
                20
            )
        end

    end

    hook.Add( "PostDrawTranslucentRenderables", "SCP343:AoERender", function()
        if IsValid(LocalPlayer():GetActiveWeapon()) then
            if LocalPlayer():GetActiveWeapon():GetClass() == "weapon_ynot343" and LocalPlayer():GetActiveWeapon():GetLastBlessing() <= CurTime() then
                local pos = LocalPlayer():GetPos()
                pos.z = pos.z + 3
                cam.Start3D2D(pos, Angle(0,90,0), 1)
                    surface.SetDrawColor(0,100,0,30)
                    draw.Circle( 0, 0, SCPJobsConfig[343].BlessRadius, 36 )
                cam.End3D2D()
            end
        end
    end)

    hook.Add( "HUDPaintBackground", "SCP343:BoostOverlay", function()
        if LocalPlayer():GetNWBool("y343Bless") then
            DrawMotionBlur( 0.4, 0.8, 0.01 )
            surface.SetDrawColor(0,180,0,10)
            surface.DrawRect(0,0,scrw,scrh)
        end
    end)

    function draw.Circle( x, y, radius, seg )
        local cir = {}
    
        table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
        for i = 0, seg do
            local a = math.rad( ( i / seg ) * -360 )
            table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
        end
    
        local a = math.rad( 0 ) -- This is needed for non absolute segment counts
        table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    
        surface.DrawPoly( cir )
    end

end