AddCSLuaFile()

SWEP.PrintName = "SCP-053"
SWEP.Author = "ynot01"
SWEP.Purpose = "Don't get hurt"
SWEP.Instructions    = ""

SWEP.Category = "ynot01's SWEPs"

SWEP.Slot = 2
SWEP.SlotPos = 0

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/weapons/c_arms.mdl" )
SWEP.WorldModel = ""
SWEP.ViewModelFOV = 54

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.WepSelectIcon = nil
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

function SWEP:SetupDataTables()
end

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    owner:SetRunSpeed( owner:GetWalkSpeed() )
    owner:SetModelScale(0.8, 0.000001)
end

function SWEP:Think()
    if CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if owner:Alive() then
        owner:SetHealth( math.min( owner:Health() + 5, owner:GetMaxHealth() ) )
    end

end

if CLIENT then

    local fire = false

    hook.Add("Think", "ySCP053:ShootDetect", function()

        fire = false

        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) then return end
        if string.find(wep:GetPrintName(), "SCP") then return end

        local trace = ply:GetEyeTrace()
        local ent = trace.Entity
        if not IsValid(ent) then return end

        if !ent:IsPlayer() then return end
        if !ent:GetActiveWeapon() or !IsValid(ent:GetActiveWeapon()) or ent:GetActiveWeapon():GetClass() != "weapon_ynot053" then return end

        local MeleeChoice = nil
        if ply:GetPos():DistToSqr(ent:GetPos()) <= 5000 then
            for k,v in ipairs(ply:GetWeapons()) do
                if SCPJobsConfig["MeleeWeapons"][v:GetClass()] then
                    MeleeChoice = v
                    break
                end
            end
        end

        if SCPJobsConfig["SafeWeapons"][wep:GetClass()] then
            if MeleeChoice then
                input.SelectWeapon( MeleeChoice )
            end
            return
        end

        if SCPJobsConfig["MeleeWeapons"][wep:GetClass()] and LocalPlayer():GetPos():DistToSqr(ent:GetPos()) > 5000 then return end

        fire = true

    end)

    hook.Add("CreateMove", "ySCP053:ShootAct", function(cmd)

        local buttons = cmd:GetButtons()
        if bit.band(buttons, IN_ATTACK) == 1 then return end

        if fire then cmd:SetButtons(buttons + 1) end

    end)

    local LastHell = 0
    timer.Create("ySCP053:HellTime", 0.1, 0, function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        if ply:GetNWBool("ySCP053:Doomed") then
            util.ScreenShake( vector_origin, math.min( SysTime() - LastHell, 5 ), 10, 0.2, 0 )
        else
            LastHell = SysTime()
        end
    end)

    local scrw, scrh = ScrW(), ScrH()
    hook.Add("HUDPaint", "ySCP053:DoomHUD", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        if ply:GetNWBool("ySCP053:Doomed") then
            surface.SetDrawColor(255, 0, 0, math.min( (SysTime() - LastHell) * 50, 170 ) )
            surface.DrawRect(0,0,scrw,scrh)
            surface.SetDrawColor(0, 0, 0, (math.sin((SysTime() - LastHell) * 5) / 2 + .5) * 255 )
            surface.DrawRect(0,0,scrw,scrh)
        end
    end)

    hook.Add("OnScreenSizeChanged", "ySCP053:ResUpdate", function(oldW, oldH)
        scrw = ScrW()
        scrh = ScrH()
    end)

    timer.Create("ySCP053:HellSound", 0.5, 0, function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        if ply:GetNWBool("ySCP053:Doomed") then
            net.Start("ySCP053:HellSoundNet")
            net.SendToServer()
        end
    end)

end

if SERVER then

    util.AddNetworkString("ySCP053:HellSoundNet")

    hook.Add("InitPostEntity", "ySCP053:PrecacheSnd", function()
        game.GetWorld():EmitSound("physics/flesh/flesh_bloody_break.wav", 20, 100, 0) -- Precaches the sound silently
    end)

    -- The real stuff, if you hurt SCP-053, you're going to die very quickly, SCP or not
    hook.Add("EntityTakeDamage", "ySCP053:ModifyDamage", function(victim, dmg)

        if !victim:IsPlayer() then return end

        if !dmg:GetAttacker():IsPlayer() or dmg:GetAttacker():HasGodMode() then -- You can't kill these guys anyways.
            dmg:GetAttacker():SetNWBool("ySCP053:Doomed", false)
            return
        end

        if victim:GetNWBool("ySCP053:Doomed") and dmg:GetInflictor():GetClass() != "weapon_ynot053" then -- Doomed players take 10x damage from outer sources
            dmg:SetDamage(dmg:GetDamage() * 10)
            return
        end

        if !IsValid(victim:GetActiveWeapon()) or !IsValid(victim:GetActiveWeapon()) or victim:GetActiveWeapon():GetClass() != "weapon_ynot053" then return end

        local doomed = dmg:GetAttacker() -- The doomed

        if !IsEntity(doomed) then return end

        if doomed:GetNWBool("ySCP053:Doomed") or !doomed:IsPlayer() then -- If they are dumb enough to shoot her twice, then just kill them immediately
            local KillingBlow = DamageInfo()
            doomed:SetHealth(1)
            KillingBlow:SetDamage(2147483647)
            KillingBlow:SetAttacker(victim)
            KillingBlow:SetInflictor(victim:GetActiveWeapon())
            KillingBlow:SetDamageForce(vector_origin)
            KillingBlow:SetDamageType(DMG_SLASH)
            doomed:TakeDamageInfo(KillingBlow)
            doomed:SetNWBool("ySCP053:Doomed", false)
            return
        end

        if !SCPJobsConfig["MeleeWeapons"][doomed:GetActiveWeapon():GetClass()] and !doomed.SCPNum and !string.find(doomed:GetActiveWeapon():GetPrintName(), "SCP") then
            local Throw = Vector( 0, 250, 0 )
            doomed:DropWeapon( nil, nil, Throw )
        end

        timer.Simple(0, function() doomed:SetNWBool("ySCP053:Doomed", true) end)

        timer.Simple(10.5, function() doomed:SetNWBool("ySCP053:Doomed", false) end) -- Fallback, they will be dead after 10 seconds anyways

        local HellIterations = 0
        local InitHell = SysTime()
        timer.Create("ySCP053:Hell" .. doomed:UserID(), 0.05, 0, function() -- Good luck

            HellIterations = HellIterations + 1

            if HellIterations > 200 then -- If they have survived for more than 10 seconds, kill them outright
                doomed:Kill()
                timer.Remove("ySCP053:Hell" .. doomed:UserID())
                doomed:SetNWBool("ySCP053:Doomed", false)
                return
            end

            local DmgCalc = 2^(SysTime() - InitHell)

            if !IsValid(doomed) or !doomed:Alive() or doomed:HasGodMode() or DmgCalc > 2147483647 then
                timer.Remove("ySCP053:Hell" .. doomed:UserID())
                doomed:SetNWBool("ySCP053:Doomed", false)
                return
            end

            doomed:SetArmor( math.max( doomed:Armor() - math.random(2, 4), 0 ) )

            local Decay = DamageInfo()
            Decay:SetDamage(math.random(0, DmgCalc))
            Decay:SetAttacker(victim)
            Decay:SetInflictor(victim:GetActiveWeapon())
            Decay:SetDamageForce(vector_origin)
            Decay:SetDamageType(DMG_SLASH)
            doomed:TakeDamageInfo(Decay)

        end)

    end)

    hook.Add("PlayerCanPickupWeapon", "ySCP053:DenyWeapon", function(ply, weapon)
        if ply:GetNWBool("ySCP053:Doomed") then
            return false
        end
    end)

    net.Receive("ySCP053:HellSoundNet", function(len, ply)
        if ply:GetNWBool("ySCP053:Doomed") then
            if !ply:Alive() or ply:HasGodMode() then ply:SetNWBool("ySCP053:Doomed", false) end
            EmitSound("physics/flesh/flesh_bloody_break.wav", ply:GetPos(), ply:EntIndex())
        end
    end)

end