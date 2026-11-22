AddCSLuaFile()

SWEP.PrintName = "SCP-066"
SWEP.Author = "ynot01"
SWEP.Purpose = "Make their ears bleed"
SWEP.Instructions	= "Left click for \"Eric\", Reload for notes, Right click to unleash Beethoven's wrath"

SWEP.Category = "ynot01's SWEPs"

SWEP.Slot = 2
SWEP.SlotPos = 0

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/weapons/c_arms.mdl" )
SWEP.WorldModel = ""
SWEP.ViewModelFOV = 54

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

SWEP.NextEric = 0
SWEP.NextEarRape = 0
SWEP.NextMusicStop = 0
SWEP.NextThinkTime = 0
SWEP.NextNote = 0

function SWEP:SetupDataTables()
	self:NetworkVar("Bool",0,"Screamable")
    self:NetworkVar("Int",0,"Nearby")
    self:NetworkVar("Int",1,"Anger")
    self:NetworkVar("Float",0,"LastTry")
end

function SWEP:Initialize()
	self:SetScreamable(false)
    self:SetNearby(0)
    self:SetAnger(0)
    self:SetLastTry(0)
    self:SetHoldType("normal")
end

ySCP066 = ySCP066 or {}

if SERVER then
    util.AddNetworkString("ySCP066:ChatPrint")
    util.AddNetworkString("ySCP066:UserNotif")

    function ySCP066.ChatPrint(ply, msg, col)
        net.Start("ySCP066:ChatPrint")
        net.WriteString(msg)
        local col = col or color_white
        net.WriteColor(col)
        net.Send(ply)
    end

    function ySCP066.UserNotif(ply, msg, ico, snd, len)
        net.Start("ySCP066:UserNotif")
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

    function ySCP066.ChatPrint(msg, col)
        chat.AddText(ChatColor, "[SCP-066] ", col, msg)
    end

    net.Receive("ySCP066:ChatPrint", function()
        ySCP066.ChatPrint(net.ReadString(), net.ReadColor())
    end )

    function ySCP066.UserNotif(msg, ico, snd, len)
        notification.AddLegacy(msg, ico, len)
        surface.PlaySound(snd)
    end

    net.Receive("ySCP066:UserNotif", function()
        ySCP066.UserNotif(net.ReadString(), net.ReadUInt(3), net.ReadString(), net.ReadFloat())
    end )

end

if CLIENT then
    surface.CreateFont( "ySCP066Font", {
        font = "Consolas",
        size = ScreenScale(16),
    } )

    local scrw = ScrW() -- lowercase to differentiate from the function
    local scrh = ScrH()

    local Green066 = Color(128, 255, 0)
    local SizeText = {
        text = "0",
        font = "ySCP066Font",
        pos = {scrw*0.5, scrh*0.85+25},
        xalign = TEXT_ALIGN_CENTER,
        yalign = TEXT_ALIGN_CENTER,
        color = color_white,
    }

    hook.Add("OnScreenSizeChanged", "ySCP066:UpdateResolution", function(oldW, oldH)
        scrw = ScrW()
        scrh = ScrH()
        SizeText.pos = {scrw*0.5, scrh*0.85+25}
    end)

    function SWEP:DrawHUD()
        draw.NoTexture()

        surface.SetDrawColor(0,0,0)
        surface.DrawRect(scrw/2-scrw*0.1-6,scrh*0.85-6,scrw*0.2+12,62)

        surface.SetDrawColor(26,26,26)
        surface.DrawRect(scrw/2-scrw*0.1-5,scrh*0.85-5,scrw*0.2+10,60)

        --surface.SetDrawColor(62,62,62)
        --surface.DrawRect(scrw/2-scrw*0.1-1,scrh*0.85-1,scrw*0.2+2,52)
        
        if self:GetScreamable() && (self:GetAnger() > 0 || self:GetNearby() >= SCPJobsConfig[66].NearbyRage) then
            SizeText.color = Green066
        else
            SizeText.color = color_white
        end

        if self:GetAnger() > 0 then
            SizeText.text = "Angry"
            for i=self:GetAnger(),1,-1 do
                SizeText.text = SizeText.text.."!"
            end
        else
            if self:GetNearby() == 1 then
                SizeText.text = self:GetNearby()
            else
                SizeText.text = self:GetNearby()
            end
        end
        draw.Text(SizeText)
    end

end

if SERVER then

    local FireDistance = 80

    local FireDistanceSqr = FireDistance^2

    -- Disables SCP-066's ability to use buttons
    hook.Add( "PlayerUse", "ySCP066:Fail066Use", function( ply, key )
        if IsValid(ply:GetActiveWeapon()) && ply:GetActiveWeapon():GetClass() == "weapon_ynot066" then
            return false
        end
    end)

    -- Picking up SCP-066
    hook.Add( "KeyPress", "ySCP066:Pickup066Try", function( ply, key )
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
        if not IsValid(Tr.Entity:GetActiveWeapon()) or Tr.Entity:GetActiveWeapon():GetClass() != "weapon_ynot066" then return end
        if ply:GetPos():DistToSqr( Tr.Entity:GetPos() ) > FireDistanceSqr then return end
        
        if Tr.Entity:GetActiveWeapon():GetLastTry() > CurTime() then 
            ySCP066.UserNotif(ply, "Please wait "..math.Round(Tr.Entity:GetActiveWeapon():GetLastTry()-CurTime(), 1).." more seconds to try a pickup again!", 1, "buttons/button10.wav")
            return 
        end

        Tr.Entity:GetActiveWeapon():SetLastTry(CurTime() + 2)
        
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
                ySCP066.ChatPrint(v, ply:Nick().." rolled "..PlyRoll.."! "..Tr.Entity:Nick().." rolled "..ScpRoll.."!")
                ySCP066.ChatPrint(v, ply:Nick().." failed to pick up "..Tr.Entity:Nick().."!", Color(255,0,0))
            end
            Tr.Entity:GetActiveWeapon():SetAnger(5)
        else
            for k, v in ipairs(NearPly) do
                if !v:IsPlayer() then continue end
                ySCP066.ChatPrint(v, ply:Nick().." rolled "..PlyRoll.."! "..Tr.Entity:Nick().." rolled "..ScpRoll.."!")
                ySCP066.ChatPrint(v, ply:Nick().." picked up "..Tr.Entity:Nick().."!", Color(0,255,0))
            end
        end

    end )

    -- Enrage SCP-066 when taking damage from another player
    hook.Add("EntityTakeDamage", "ySCP066:Rage066Trigger", function(ent, dmginfo)
        if ent:IsPlayer() and IsValid(ent:GetActiveWeapon()) and ent:GetActiveWeapon():GetClass() == "weapon_ynot066" and dmginfo:GetAttacker() != ent and dmginfo:GetAttacker():IsPlayer() then
            ent:GetActiveWeapon():SetAnger(5)
        end
    end)
end

-- Earrape
function SWEP:SecondaryAttack()
	if CLIENT then return end
	if self.NextEarRape >= CurTime() then return end
    if !self:GetScreamable() then 
        ySCP066.UserNotif(self:GetOwner(), "You cannot scream unless you are agitated!", 1, "buttons/button18.wav") 
        self.NextEarRape = CurTime() + 0.5
        return 
    end
    self.NextEarRape = CurTime() + SCPJobsConfig[66].EarRapeCooldown
    self.NextMusicStop = CurTime() + 19
    self:GetOwner():EmitSound("snds_deep_scp/66music.mp3", 100, 100, 1, CHAN_WEAPON)
end

-- Earrape function
function SWEP:Think()
	if CLIENT then return end

    if self:GetNearby() >= SCPJobsConfig[66].NearbyRage || self:GetAnger() > 0 then
        self:SetScreamable(true)
    else
        self:SetScreamable(false)
    end

    local Time = CurTime()
	if self.NextThinkTime > Time then return end
	self.NextThinkTime = Time + 0.5
    self:SetAnger( math.max( self:GetAnger() - 1, 0 ) )
    
    local SelfPos = self:GetOwner():GetShootPos()

    local NearSphere = ents.FindInSphere( SelfPos, SCPJobsConfig[66].EarRapeDamageRadius )
	
    local LocNearby = 0
    for k, ply in ipairs(NearSphere) do
        if ( ( ply:IsPlayer() ) and ( ply:Alive() ) and not( ply == self:GetOwner() ) ) then
            if not( util.TraceLine({start=SelfPos,endpos=ply:GetShootPos(),filter={self:GetOwner(),self,ply}}).Hit) then
                if ply.SCPNum then continue end
                LocNearby = LocNearby + 1
            end
        end
    end
    self:SetNearby(LocNearby)

	if self.NextMusicStop > Time then
		for k, ply in ipairs( NearSphere ) do
			if ( ( ply:IsPlayer() ) and ( ply:Alive() ) and not( ply == self:GetOwner() ) ) then
				if not( util.TraceLine({start=SelfPos,endpos=ply:GetShootPos(),filter={self:GetOwner(),self,ply}}).Hit) then
					local Dmg = DamageInfo()
					Dmg:SetDamage(SCPJobsConfig[66].EarRapeDamage)
					Dmg:SetAttacker(self:GetOwner())
					Dmg:SetInflictor(self:GetOwner())
					Dmg:SetDamageType(DMG_SONIC)
					ply:TakeDamageInfo(Dmg)
				end
			end
		end
	end
end

-- Eric
function SWEP:PrimaryAttack()
	if CLIENT then return end
	if self.NextEric < CurTime() then
		self.NextEric = CurTime() + SCPJobsConfig[66].EricCooldown
		self:GetOwner():EmitSound("snds_deep_scp/66eric.wav", 65, 100)
	end
end

-- Note
function SWEP:Reload()
	if CLIENT then return end
	if self.NextNote < CurTime() then
		self.NextNote = CurTime() + SCPJobsConfig[66].NoteCooldown
		self:GetOwner():EmitSound("snds_deep_scp/66note"..math.random(1,3)..".wav", 65, 100)
	end
end