AddCSLuaFile()

SWEP.PrintName      = "SCP-049"
SWEP.Author         = "ynot01"
SWEP.Purpose        = "Your HUD will tell you how many zombies are nearby and how many guns are pointed at you. You will be frozen automatically if there are enough guns pointed at you."
SWEP.Instructions   = "Hold click to cure the pestilence, hold right click to heal your zombies."

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
SWEP.DrawCrosshair = false

SWEP.NextPixelRead = 0
SWEP.InDarkness = 0

local FireDistance = 80
local FireDistanceSqr = FireDistance^2

if CLIENT then
    surface.CreateFont( "ySCP049Font", {
        font = "Consolas",
        size = ScreenScale(16),
    } )

    local scrw = ScrW() -- lowercase to differentiate from the function
    local scrh = ScrH()

    local Greenish = Color(0,180,0)

    local ZombText = {
        text = "0 Zombies",
        font = "ySCP049Font",
        pos = {scrw*0.5, scrh*0.85+25},
        xalign = TEXT_ALIGN_CENTER,
        yalign = TEXT_ALIGN_CENTER,
        color = color_white,
    }

    local GunsText = {
        text = "0 Guns",
        font = "ySCP049Font",
        pos = {scrw*0.5, scrh*0.915+25},
        xalign = TEXT_ALIGN_CENTER,
        yalign = TEXT_ALIGN_CENTER,
        color = color_white,
    }

    hook.Add("OnScreenSizeChanged", "ySCP049:UpdateResolution", function(oldW, oldH)
        scrw = ScrW()
        scrh = ScrH()
        ZombText.pos = {scrw*0.5, scrh*0.85+25}
        GunsText.pos = {scrw*0.5, scrh*0.915+25}
    end)

    function SWEP:DrawHUD()

        --------------- Cure Cooldown ---------------
        if self:GetLastCure() > CurTime() then
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
                Lerp( (self:GetLastCure() - CurTime()) / SCPJobsConfig[49].CureCooldown, 0, ScrW()*0.2 ), 
                20
            )
        end

        if self:GetLastHeal() > CurTime() then
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
                Lerp( (self:GetLastHeal() - CurTime()) / SCPJobsConfig[49].HealCooldown, 0, ScrW()*0.2 ), 
                20
            )
        end

        --------------- Zombies Count ---------------
        draw.NoTexture()

        surface.SetDrawColor(0,0,0)
        surface.DrawRect(scrw/2-scrw*0.1-6,scrh*0.85-6,scrw*0.2+12,62)

        surface.SetDrawColor(26,26,26)
        surface.DrawRect(scrw/2-scrw*0.1-5,scrh*0.85-5,scrw*0.2+10,60)

        --surface.SetDrawColor(62,62,62)
        --surface.DrawRect(scrw/2-scrw*0.1-1,scrh*0.85-1,scrw*0.2+2,52)

        ZombText.text = self:GetZombies().." Zombies"
        draw.Text(ZombText)

        --------------- Guns Count ---------------
        draw.NoTexture()
        
        surface.SetDrawColor(0,0,0)
        surface.DrawRect(scrw/2-scrw*0.1-6,scrh*0.915-6,scrw*0.2+12,62)

        surface.SetDrawColor(26,26,26)
        surface.DrawRect(scrw/2-scrw*0.1-5,scrh*0.915-5,scrw*0.2+10,60)

        local DarkReq = GetGlobalBool("ySCP049:LightsOff") and SCPJobsConfig[49].GunLightsOff or SCPJobsConfig[49].GunLightsOn
        
        if self:GetZombies() > 0 then
            GunsText.text = self:GetFear().."/∞ Guns"
        else
            GunsText.text = self:GetFear().."/"..DarkReq.." Guns"
        end

        if self:GetFear() >= DarkReq and self:GetZombies() == 0 then
            GunsText.color = Greenish
        else
            GunsText.color = color_white
        end

        draw.Text(GunsText)

    end


else
    util.AddNetworkString("ySCP049:DarknessUpdate")
    util.AddNetworkString("ySCP049:LightsUpdate")

end

function SWEP:SetupDataTables()
    self:NetworkVar("Float",0,"LastCure")
    self:NetworkVar("Float",1,"LastHeal")
    self:NetworkVar("Int",0,"Zombies")
    self:NetworkVar("Int",1,"Fear")
end

function SWEP:Initialize()
    self:SetLastCure(0)
    self:SetLastHeal(0)
    self:SetZombies(0)
    self:SetFear(0)
    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
    if CLIENT then return end
    if self:GetLastHeal() > CurTime() - (0.3) then return end
    if self:GetLastCure() > CurTime() then return end

    local owner = self:GetOwner()

    local Tr = owner:GetEyeTrace()

    if ( !IsValid( Tr.Entity ) ) then
        Tr = util.TraceHull( {
            start = owner:GetShootPos(),
            endpos = owner:GetShootPos() + owner:GetAimVector() * FireDistance,
            filter = owner,
            mins = Vector( -10, -10, -8 ),
            maxs = Vector( 10, 10, 8 ),
            mask = MASK_SHOT_HULL
        } )
    end

    if Tr.HitWorld or not Tr.Hit then return end
    if Tr.Entity.SCPNum or !Tr.Entity:IsPlayer() or Tr.Entity:HasWeapon("weapon_ynot049")  then return end
    
    if owner:GetPos():DistToSqr( Tr.Entity:GetPos() ) > FireDistanceSqr then return end

    local ply = Tr.Entity

    self:SetLastCure(CurTime() + SCPJobsConfig[49].CureCooldown)

    ply.RDOTable["Mute"] = true -- Radio addon (mutes player's comms)
    ply:SendInformations() -- Radio addon (updates metatable to player)

    ply:SetModel("models/player/zombie_classic.mdl")
    ply:StripWeapons()
    ply:SetMaxHealth( SCPJobsConfig[49].ZombieHealth )
    ply:SetHealth( SCPJobsConfig[49].ZombieHealth )
    ply:Give("weapon_ynot049_2")
    ply:EmitSound("npc/zombie_poison/pz_warn"..math.random(1,2)..".wav")

end

function SWEP:SecondaryAttack()
    if CLIENT then return end
    if self:GetLastCure() > CurTime() - (0.3) then return end
    if self:GetLastHeal() > CurTime() then return end

    local owner = self:GetOwner()

    local Tr = owner:GetEyeTrace()

    if ( !IsValid( Tr.Entity ) ) then
        Tr = util.TraceHull( {
            start = owner:GetShootPos(),
            endpos = owner:GetShootPos() + owner:GetAimVector() * FireDistance,
            filter = owner,
            mins = Vector( -10, -10, -8 ),
            maxs = Vector( 10, 10, 8 ),
            mask = MASK_SHOT_HULL
        } )
    end

    if Tr.HitWorld or not Tr.Hit then return end
    if !Tr.Entity:IsPlayer() or not Tr.Entity:HasWeapon("weapon_ynot049_2") then return end
    if owner:GetPos():DistToSqr( Tr.Entity:GetPos() ) > FireDistanceSqr then return end

    local ply = Tr.Entity

    self:SetLastHeal(CurTime() + SCPJobsConfig[49].HealCooldown)

    if ply:Health() == ply:GetMaxHealth() then
        owner:EmitSound("items/medshotno1.wav")
    else
        owner:EmitSound("items/smallmedkit1.wav")
        ply:SetHealth( math.min( ply:Health() + SCPJobsConfig[49].HealAmount, ply:GetMaxHealth() ) )
    end
    
end

function SWEP:Deploy()
    return true
end

function SWEP:Holster()
    if not IsFirstTimePredicted() then return end
    return true
end

function SWEP:Think()
    if CLIENT then return end
    local ZombCount = 0
    local GunCount = 0
    local owner = self:GetOwner()

    
    for k,v in ipairs(ents.FindInSphere(self:GetPos(), 400)) do

        if !v:IsPlayer() then continue end
        if v == owner then continue end
        if !v:Alive() then continue end
        if !v:GetActiveWeapon() or !IsValid(v:GetActiveWeapon()) then continue end

        if util.TraceLine( {start = owner:GetShootPos(), endpos = v:GetShootPos(), filter = {}, collisiongroup = COLLISION_GROUP_WORLD} ).Hit then continue end

        if v:HasWeapon("weapon_ynot049_2") then
            ZombCount = ZombCount + 1
            continue
        end

        if v:GetAimVector():Dot( ( owner:GetPos() - v:GetPos() ):GetNormal() ) < 0.95 and v:GetEyeTrace().Entity != owner then continue end

        local wep = v:GetActiveWeapon():GetClass()
        if !SCPJobsConfig["SafeWeapons"][wep] and !SCPJobsConfig["MeleeWeapons"][wep] then
            GunCount = GunCount + 1
            continue
        end

    end

    self:SetZombies(ZombCount)
    self:SetFear(GunCount)

end

function ToggleLights() -- Works with Kam's map

    if GetGlobalBool("ySCP049:LightsOff") then
        SetGlobalBool("ySCP049:LightsOff", false)
    else
        SetGlobalBool("ySCP049:LightsOff", true)
    end

end

hook.Add("PostCleanupMap", "ySCP049:ResetLights", function()
    SetGlobalBool("ySCP049:LightsOff", false)
end )

if CLIENT then -- Freeze when sufficient guns are pointed at 049
    hook.Add("CreateMove", "ySCP049:GunFreeze", function(cmd)

        local ply = LocalPlayer()

        if !IsValid(ply:GetActiveWeapon()) or ply:GetActiveWeapon():GetClass() != "weapon_ynot049" then return end

        local wep = ply:GetActiveWeapon()

        if !pcall(function() wep:GetZombies() end) then return end -- CreateMove is called before data tables get set up

        if wep:GetZombies() > 0 then return end

        local DarkReq = GetGlobalBool("ySCP049:LightsOff") and SCPJobsConfig[49].GunLightsOff or SCPJobsConfig[49].GunLightsOn

        if wep:GetFear() >= DarkReq then
            cmd:ClearMovement()

            if cmd:KeyDown(IN_DUCK) then
                cmd:RemoveKey(IN_DUCK)
            end

            if cmd:KeyDown(IN_JUMP) then
                cmd:RemoveKey(IN_JUMP)
            end

            if cmd:KeyDown(IN_ATTACK) then
                cmd:RemoveKey(IN_ATTACK)
            end

            if cmd:KeyDown(IN_ATTACK2) then
                cmd:RemoveKey(IN_ATTACK2)
            end

        end

    end)
end