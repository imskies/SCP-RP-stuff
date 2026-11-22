AddCSLuaFile()

SWEP.PrintName      = "SCP-1048"
SWEP.Author         = "ynot01"
SWEP.Purpose        = "Create some friends"
SWEP.Instructions   = "Left click to take ears, right click to take guns"

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
SWEP.DrawCrosshair = true

local FireDistance = 80
local FireDistanceSqr = FireDistance^2

ySCP1048 = ySCP1048 or {}

function SWEP:SetupDataTables()
    self:NetworkVar("Int",0,"Ears")
    self:NetworkVar("Int",1,"Scraps")
    self:NetworkVar("Float",0,"LastTry")
    self:NetworkVar("Float",1,"LastTakeAttempt")
end

function SWEP:Initialize()
    self:SetEars(0)
    self:SetScraps(0)
    self:SetLastTry(0)
    self:SetLastTakeAttempt(0)
    self:SetHoldType("normal")
end

if CLIENT then
    surface.CreateFont( "ySCP1048Font", {
        font = "Consolas",
        size = ScreenScale(16),
    } )

    local scrw = ScrW() -- lowercase to differentiate from the function
    local scrh = ScrH()

    local EarText = {
        text = "0/"..SCPJobsConfig[1048].MaxEars.." Ears",
        font = "ySCP1048Font",
        pos = {scrw*0.5, scrh*0.85+25},
        xalign = TEXT_ALIGN_CENTER,
        yalign = TEXT_ALIGN_CENTER,
        color = color_white,
    }

    local ScrapText = {
        text = "0/"..SCPJobsConfig[1048].MaxScraps.." Scraps",
        font = "ySCP1048Font",
        pos = {scrw*0.5, scrh*0.915+25},
        xalign = TEXT_ALIGN_CENTER,
        yalign = TEXT_ALIGN_CENTER,
        color = color_white,
    }

    local NoEarText = {
        text = "You have no ears! See a medic!",
        font = "ySCP1048Font",
        pos = {scrw*0.5, scrh*0.9+25},
        xalign = TEXT_ALIGN_CENTER,
        yalign = TEXT_ALIGN_CENTER,
        color = color_white,
    }

    hook.Add("OnScreenSizeChanged", "ySCP1048:UpdateResolution", function(oldW, oldH)
        scrw = ScrW()
        scrh = ScrH()
        EarText.pos = {scrw*0.5, scrh*0.85+25}
        ScrapText.pos = {scrw*0.5, scrh*0.915+25}
        NoEarText.pos = {scrw*0.5, scrh*0.9+25}
    end)

    function SWEP:DrawHUD()

        --------------- Take Cooldown ---------------
        if self:GetLastTakeAttempt() > CurTime() then
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
                Lerp( (self:GetLastTakeAttempt() - CurTime()) / SCPJobsConfig[1048].TakeCooldown, 0, ScrW()*0.2 ), 
                20
            )
        end

        --------------- Ears Count ---------------
        draw.NoTexture()

        surface.SetDrawColor(0,0,0)
        surface.DrawRect(scrw/2-scrw*0.1-6,scrh*0.85-6,scrw*0.2+12,62)

        surface.SetDrawColor(26,26,26)
        surface.DrawRect(scrw/2-scrw*0.1-5,scrh*0.85-5,scrw*0.2+10,60)

        --surface.SetDrawColor(62,62,62)
        --surface.DrawRect(scrw/2-scrw*0.1-1,scrh*0.85-1,scrw*0.2+2,52)

        EarText.text = self:GetEars().."/"..SCPJobsConfig[1048].MaxEars.." Ears"
        draw.Text(EarText)


        --------------- Scraps Count ---------------
        draw.NoTexture()
        
        surface.SetDrawColor(0,0,0)
        surface.DrawRect(scrw/2-scrw*0.1-6,scrh*0.915-6,scrw*0.2+12,62)

        surface.SetDrawColor(26,26,26)
        surface.DrawRect(scrw/2-scrw*0.1-5,scrh*0.915-5,scrw*0.2+10,60)

        ScrapText.text = self:GetScraps().."/"..SCPJobsConfig[1048].MaxScraps.." Scraps"
        draw.Text(ScrapText)
    end

    hook.Add("HUDPaint", "ySCP1048:EarNotif", function()
        if LocalPlayer():GetNWInt("ySCP1048:Ears", 2) == 0 then
            draw.NoTexture()
        
            surface.SetDrawColor(0,0,0)
            surface.DrawRect(scrw/2-scrw*0.19-6,scrh*0.9-6,scrw*0.38+12,62)

            surface.SetDrawColor(26,26,26)
            surface.DrawRect(scrw/2-scrw*0.19-5,scrh*0.9-5,scrw*0.38+10,60)

            draw.Text(NoEarText)
        end
    end)

end

function SWEP:PrimaryAttack()
    if CLIENT then return end

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
    if Tr.Entity.SCPNum or !Tr.Entity:IsPlayer() or Tr.Entity:HasWeapon("weapon_ynot1048a") or Tr.Entity:HasWeapon("weapon_ynot1048c") then return end
    if owner:GetPos():DistToSqr( Tr.Entity:GetPos() ) > FireDistanceSqr then return end

    local ply = Tr.Entity

    if self:GetLastTakeAttempt() > CurTime() then return end

    if ply:GetNWInt("ySCP1048:Ears", 0) == 0 then 
        ySCP1048.UserNotif(self:GetOwner(), "They have no ears!", 1, "buttons/button10.wav")
        return 
    end

    self:SetLastTakeAttempt(CurTime() + SCPJobsConfig[1048].TakeCooldown)

    local NearPly = ents.FindInSphere( owner:GetShootPos(), 500 )
    local PlyRoll = math.random(0,100) + (SCPJobsConfig["RollBonus"][RPExtraTeams[ply:Team()].category] or 0)
    local ScpRoll = math.random(0,100) + (SCPJobsConfig["RollBonus"][RPExtraTeams[owner:Team()].category] or 0)

    while PlyRoll == ScpRoll do -- No ties!
        PlyRoll = math.random(0,100) +(SCPJobsConfig["RollBonus"][RPExtraTeams[ply:Team()].category] or 0)
        ScpRoll = math.random(0,100) + (SCPJobsConfig["RollBonus"][RPExtraTeams[owner:Team()].category] or 0)
    end

    if ScpRoll < PlyRoll then
        for k, v in ipairs(NearPly) do
            if !v:IsPlayer() then continue end
            ySCP1048.ChatPrint(v, owner:Nick().." rolled "..ScpRoll.."! "..ply:Nick().." rolled "..PlyRoll.."!")
            ySCP1048.ChatPrint(v, owner:Nick().." failed to take "..ply:Nick().."'s ear!", Color(255,0,0))
        end
    else
        for k, v in ipairs(NearPly) do
            if !v:IsPlayer() then continue end
            ySCP1048.ChatPrint(v, owner:Nick().." rolled "..ScpRoll.."! "..ply:Nick().." rolled "..PlyRoll.."!")
            ySCP1048.ChatPrint(v, owner:Nick().." took "..ply:Nick().."'s ear!", Color(0,255,0))
        end
        self:TakeEar(ply)
    end

end

function SWEP:SecondaryAttack()
    if CLIENT then return end

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
    if Tr.Entity.SCPNum or !Tr.Entity:IsPlayer() or Tr.Entity:HasWeapon("weapon_ynot1048a") or Tr.Entity:HasWeapon("weapon_ynot1048c") then return end
    if owner:GetPos():DistToSqr( Tr.Entity:GetPos() ) > FireDistanceSqr then return end

    local ply = Tr.Entity

    if self:GetLastTakeAttempt() > CurTime() then return end

    local HasBadToys = false
    for k,v in ipairs(ply:GetWeapons()) do
        if !SCPJobsConfig["SafeWeapons"][v:GetClass()] && !SCPJobsConfig["MeleeWeapons"][v:GetClass()] then
            HasBadToys = true
            break
        end
    end
    if !HasBadToys then 
        ySCP1048.UserNotif(self:GetOwner(), "They have no guns!", 1, "buttons/button10.wav")
        return 
    end
    
    self:SetLastTakeAttempt(CurTime() + SCPJobsConfig[1048].TakeCooldown)

    local NearPly = ents.FindInSphere( owner:GetShootPos(), 500 )
    local PlyRoll = math.random(0,100) + (SCPJobsConfig["RollBonus"][RPExtraTeams[ply:Team()].category] or 0)
    local ScpRoll = math.random(0,100) + (SCPJobsConfig["RollBonus"][RPExtraTeams[owner:Team()].category] or 0)

    while PlyRoll == ScpRoll do -- No ties!
        PlyRoll = math.random(0,100) +(SCPJobsConfig["RollBonus"][RPExtraTeams[ply:Team()].category] or 0)
        ScpRoll = math.random(0,100) + (SCPJobsConfig["RollBonus"][RPExtraTeams[owner:Team()].category] or 0)
    end

    if ScpRoll < PlyRoll then
        for k, v in ipairs(NearPly) do
            if !v:IsPlayer() then continue end
            ySCP1048.ChatPrint(v, owner:Nick().." rolled "..ScpRoll.."! "..ply:Nick().." rolled "..PlyRoll.."!")
            ySCP1048.ChatPrint(v, owner:Nick().." failed to take "..ply:Nick().."'s guns!", Color(255,0,0))
        end
    else
        for k, v in ipairs(NearPly) do
            if !v:IsPlayer() then continue end
            ySCP1048.ChatPrint(v, owner:Nick().." rolled "..ScpRoll.."! "..ply:Nick().." rolled "..PlyRoll.."!")
            ySCP1048.ChatPrint(v, owner:Nick().." took "..ply:Nick().."'s guns!", Color(0,255,0))
        end
        self:TakeScrap(ply)
    end

end

function SWEP:Deploy()
    local owner = self:GetOwner()
    local speed = SCPJobsConfig[1048].MoveSpeed or 145
    owner:SetRunSpeed( speed )
    owner:SetWalkSpeed( speed )
    return true
end

function SWEP:Holster()
    if not IsFirstTimePredicted() then return end
    return true
end

function SWEP:Think()
end

function SWEP:TakeEar(ply)

    if CLIENT then return end
    if ply.SCPNum then return 1 end
    if !ply:IsPlayer() or !IsValid(ply) then return 2 end

    if ply:GetNWInt("ySCP1048:Ears", 0) > 0 then

        if self:GetEars() >= SCPJobsConfig[1048].MaxEars - 1 then
            self:SetEars(0)
            ply:StripWeapons()
            ply:SetModel( SCPJobsConfig[1048].EarGuyModel )
            ply:SetMaxHealth( SCPJobsConfig[1048].EarGuyHP )
            ply:SetHealth( SCPJobsConfig[1048].EarGuyHP )
            ply:Give( "weapon_ynot1048a" )
        else
            local Slash = DamageInfo()
            Slash:SetDamage( math.random( SCPJobsConfig[1048].StabDamage - 10, SCPJobsConfig[1048].StabDamage + 10 ) )
            Slash:SetAttacker(self:GetOwner())
            Slash:SetInflictor(self)
            Slash:SetDamageForce(vector_origin)
            Slash:SetDamageType(DMG_SLASH)
            ply:TakeDamageInfo(Slash)
    
            self:SetEars( self:GetEars() + 1 ) 

            ply:SetNWInt("ySCP1048:Ears", ply:GetNWInt("ySCP1048:Ears", 2) - 1)

        end
        
    else

        ySCP1048.UserNotif(self:GetOwner(), "They have no ears!", 1, "buttons/button10.wav")

    end

end

function SWEP:TakeScrap(ply)

    if CLIENT then return end
    if ply.SCPNum then return 1 end
    if !ply:IsPlayer() or !IsValid(ply) then return 2 end

    local BadToys = {} -- Dangerous weapons list
    for k,v in ipairs(ply:GetWeapons()) do
        
        if !SCPJobsConfig["SafeWeapons"][v:GetClass()] && !SCPJobsConfig["MeleeWeapons"][v:GetClass()] then
            table.insert(BadToys, (v))
        end

    end

    for k,v in ipairs(BadToys) do
        
        timer.Simple(0.1*k, function()
            if !IsValid(ply) or !IsValid(v) or !IsValid(self) then return end
            local Throw = Vector( 0, 250, 0 )
            Throw:Rotate( AngleRand() )
            ply:DropWeapon( v, nil, Throw )
            timer.Simple(1, function()
                v:Remove()
            end)
        end)

    end

    if #BadToys > 0 then 

        if self:GetScraps() >= SCPJobsConfig[1048].MaxScraps - 1 then
            self:SetScraps(0)
            ply:StripWeapons()
            ply:SetModel( SCPJobsConfig[1048].ScrapGuyModel )
            ply:SetMaxHealth( SCPJobsConfig[1048].ScrapGuyHP )
            ply:SetHealth( SCPJobsConfig[1048].ScrapGuyHP )
            ply:Give( "weapon_ynot1048c" )
        else
            self:SetScraps( self:GetScraps() + 1 ) 
        end
    
    else
        
        ySCP1048.UserNotif(self:GetOwner(), "They have no guns!", 1, "buttons/button10.wav")
    
    end

end

-- Chat & Notif
if SERVER then
    util.AddNetworkString("ySCP1048:ChatPrint")
    util.AddNetworkString("ySCP1048:UserNotif")

    resource.AddFile("sound/1048ascream.wav")

    function ySCP1048.ChatPrint(ply, msg, col)
        net.Start("ySCP1048:ChatPrint")
        net.WriteString(msg)
        local col = col or color_white
        net.WriteColor(col)
        net.Send(ply)
    end

    function ySCP1048.UserNotif(ply, msg, ico, snd, len)
        net.Start("ySCP1048:UserNotif")
        net.WriteString(msg)
        local ico = ico or 0 // https://wiki.facepunch.com/gmod/Enums/NOTIFY
        net.WriteUInt(ico, 3)
        local snd = snd or "buttons/button15.wav"
        net.WriteString(snd)
        local len = len or 3
        net.WriteFloat(len)
        net.Send(ply)
    end
else
    local ChatColor = Color(0,140,255)

    function ySCP1048.ChatPrint(msg, col)
        chat.AddText(ChatColor, "[SCP-1048] ", col, msg)
    end

    net.Receive("ySCP1048:ChatPrint", function()
        ySCP1048.ChatPrint(net.ReadString(), net.ReadColor())
    end )

    function ySCP1048.UserNotif(msg, ico, snd, len)
        notification.AddLegacy(msg, ico, len)
        surface.PlaySound(snd)
    end

    net.Receive("ySCP1048:UserNotif", function()
        ySCP1048.UserNotif(net.ReadString(), net.ReadUInt(3), net.ReadString(), net.ReadFloat())
    end )

end

-- Hooks and functionalities
if SERVER then

    -- Picking up SCP-1048
    hook.Add( "KeyPress", "ySCP1048:Pickup1048Try", function( ply, key )
        if key != IN_USE || !ply:Crouching() then return end
        
        local Tr = ply:GetEyeTrace()

        if ( !IsValid( Tr.Entity ) ) then
            Tr = util.TraceHull( {
                start = ply:GetShootPos(),
                endpos = ply:GetShootPos() + ply:GetAimVector() * FireDistance,
                filter = ply,
                mins = Vector( -10, -10, -8 ),
                maxs = Vector( 10, 10, 8 ),
                mask = MASK_SHOT_HULL
            } )
        end

        if Tr.HitWorld or not Tr.Hit then return end
        if not IsValid(Tr.Entity:GetActiveWeapon()) or Tr.Entity:GetActiveWeapon():GetClass() != "weapon_ynot1048" then return end
        if ply:GetPos():DistToSqr( Tr.Entity:GetPos() ) > FireDistanceSqr then return end
        
        if Tr.Entity:GetActiveWeapon():GetLastTry() > CurTime() then 
            ySCP1048.UserNotif(ply, "Please wait "..math.Round(Tr.Entity:GetActiveWeapon():GetLastTry()-CurTime(), 1).." more seconds to try a pickup again!", 1, "buttons/button10.wav")
            return 
        end

        Tr.Entity:GetActiveWeapon():SetLastTry(CurTime() + SCPJobsConfig[1048].PickupCooldown)

        local NearPly = ents.FindInSphere( Tr.Entity:GetShootPos(), SCPJobsConfig[66].EarRapeDamageRadius )
        local PlyRoll = math.random(0,100) + (SCPJobsConfig["RollBonusJob"][ply:getDarkRPVar("job")] or SCPJobsConfig["RollBonus"][RPExtraTeams[ply:Team()].category] or 0)
        local ScpRoll = math.random(0,100) + (SCPJobsConfig["RollBonusJob"][Tr.Entity:getDarkRPVar("job")] or SCPJobsConfig["RollBonus"][RPExtraTeams[Tr.Entity:Team()].category] or 0)

        while PlyRoll == ScpRoll do -- No ties!
            local PlyRoll = math.random(0,100) + (SCPJobsConfig["RollBonusJob"][ply:getDarkRPVar("job")] or SCPJobsConfig["RollBonus"][RPExtraTeams[ply:Team()].category] or 0)
            local ScpRoll = math.random(0,100) + (SCPJobsConfig["RollBonusJob"][Tr.Entity:getDarkRPVar("job")] or SCPJobsConfig["RollBonus"][RPExtraTeams[Tr.Entity:Team()].category] or 0)
        end

        if PlyRoll < ScpRoll then
            for k, v in ipairs(NearPly) do
                if !v:IsPlayer() then continue end
                ySCP1048.ChatPrint(v, ply:Nick().." rolled "..PlyRoll.."! "..Tr.Entity:Nick().." rolled "..ScpRoll.."!")
                ySCP1048.ChatPrint(v, ply:Nick().." failed to pick up "..Tr.Entity:Nick().."!", Color(255,0,0))
            end
            if math.random(0,1) == 1 then
                Tr.Entity:GetActiveWeapon():TakeEar(ply)
            else
                Tr.Entity:GetActiveWeapon():TakeScrap(ply)
            end
        else
            for k, v in ipairs(NearPly) do
                if !v:IsPlayer() then continue end
                ySCP1048.ChatPrint(v, ply:Nick().." rolled "..PlyRoll.."! "..Tr.Entity:Nick().." rolled "..ScpRoll.."!")
                ySCP1048.ChatPrint(v, ply:Nick().." picked up "..Tr.Entity:Nick().."!", Color(0,255,0))
            end
            Tr.Entity:GetActiveWeapon():SetEars(0)
            Tr.Entity:GetActiveWeapon():SetScraps(0)
        end

    end )

    -- Refresh ears when players are full hp
    local NextHPCheck = 0
    local NextPoll = 0
    local PlyList = {}
    hook.Add("Tick", "ySCP1048:RefreshEars", function() 
        if NextHPCheck > CurTime() then return end
        NextHPCheck = CurTime() + 1

        for key,ply in ipairs(PlyList) do

            if !IsValid(ply) then continue end

            if ply:Health() >= ply:GetMaxHealth() then
                ply:SetNWInt("ySCP1048:Ears", 2)
            end

        end

        if NextPoll > CurTime() then return end
        NextPoll = CurTime() + 30
        PlyList = player.GetAll() -- Called every 30 seconds

    end)


    

else -- CLIENT
    
    -- Mute client (effectively) when you have no ears
    hook.Add("Think", "ySCP1048:Mute", function()
        if LocalPlayer():GetNWInt("ySCP1048:Ears", 2) == 0 then
            LocalPlayer():ConCommand("stopsound")
        end
    end)

end