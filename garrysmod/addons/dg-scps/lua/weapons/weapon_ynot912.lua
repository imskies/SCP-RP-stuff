AddCSLuaFile()

SWEP.PrintName      = "SCP-912"
SWEP.Author         = "ynot01"
SWEP.Purpose        = ""
SWEP.Instructions   = "Left click to take guns, right click to return them"

SWEP.Category       = "ynot01's SWEPs"

SWEP.Slot           = 2
SWEP.SlotPos        = 30

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

SWEP.LastConfiscate = 0

ySCP912 = ySCP912 or {}

local ServerWeaponStorage = {} -- Server-side only storage that contains everyone's stored guns.
-- The list will be consistent across the entire server (not sent to clients).
-- This way, if a 912 is unavailable or uncooperative, another 912 or a staff member can use the 912 SWEP to return what was taken.

local ClientWeaponStorage = {} -- Client-stored version, only contains player names for the HUD.

local Green912 = Color(128, 255, 0)
local Red912 = Color(255,0,0)
local Grey912 = Color(100,100,100)

if SERVER then
    util.AddNetworkString("ySCP912:StorageUpdate")
    util.AddNetworkString("ySCP912:PrintWeps")
    util.AddNetworkString("ySCP912:ChatPrint")
    util.AddNetworkString("ySCP912:UserNotif")

    function ySCP912.ChatPrint(ply, msg, col)
        net.Start("ySCP912:ChatPrint")
        net.WriteString(msg)
        local col = col or color_white
        net.WriteColor(col)
        net.Send(ply)
    end

    function ySCP912.UserNotif(ply, msg, ico, snd, len)
        net.Start("ySCP912:UserNotif")
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

    function ySCP912.ChatPrint(msg, col)
        chat.AddText(ChatColor, "[SCP-912] ", col, msg)
    end

    net.Receive("ySCP912:ChatPrint", function()
        ySCP912.ChatPrint(net.ReadString(), net.ReadColor())
    end )

    function ySCP912.UserNotif(msg, ico, snd, len)
        notification.AddLegacy(msg, ico, len)
        surface.PlaySound(snd)
    end

    net.Receive("ySCP912:UserNotif", function()
        ySCP912.UserNotif(net.ReadString(), net.ReadUInt(3), net.ReadString(), net.ReadFloat())
    end )

    net.Receive("ySCP912:StorageUpdate", function()
        ClientWeaponStorage = net.ReadTable()
    end )

end

if CLIENT then
    surface.CreateFont( "ySCP912Font", {
        font = "Consolas",
        size = ScreenScale(8),
    } )

    local scrw = ScrW() -- lowercase to differentiate from the function
    local scrh = ScrH()

    hook.Add("OnScreenSizeChanged", "ySCP066:UpdateResolution", function(oldW, oldH)
        scrw = ScrW()
        scrh = ScrH()
    end)

    function SWEP:DrawHUD()
        --draw.NoTexture()

        surface.SetDrawColor(0,0,0)
        surface.DrawOutlinedRect(-1,scrh*0.2875,scrw*0.152,5+24*(#ClientWeaponStorage+1))

        surface.SetDrawColor(26,26,26,150)
        surface.DrawRect(0,scrh*0.2875,scrw*0.152,5+24*(#ClientWeaponStorage+1))
        
        draw.SimpleTextOutlined("Confiscations:", "ySCP912Font", scrw*0.15, scrh*0.3, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, color_black)
        for k,v in ipairs(ClientWeaponStorage) do
            draw.SimpleTextOutlined(v, "ySCP912Font", scrw*0.15, scrh*0.3+scrh*0.022*k, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, color_black)
        end
        
    end

end

function SWEP:SetupDataTables()
end

function SWEP:Initialize()
    self:SetHoldType("normal")
end

local FireDistance = 80
local FireDistanceSqr = FireDistance^2

local LastThink = 0
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
    if Tr.Entity.SCPNum or !Tr.Entity:IsPlayer() then return end
    if owner:GetPos():DistToSqr( Tr.Entity:GetPos() ) > FireDistanceSqr then return end

    local ply = Tr.Entity

    if ply:getDarkRPVar("job") == "Staff on Duty" then return end -- bruh moment

    if self.LastConfiscate > CurTime() then ySCP912.UserNotif(owner, "Cooldown: "..math.Round(self.LastConfiscate-CurTime(), 1), 1) return end
    self.LastConfiscate = CurTime() + 5

    local WeaponsList = {}
    local WeaponsListString = {}
    
    for k,v in ipairs(ply:GetWeapons()) do
        if !SCPJobsConfig["SafeWeapons"][v:GetClass()] then
            table.insert(WeaponsList, v:GetClass())
            table.insert(WeaponsListString, v:GetPrintName())
            v:Remove()
        end
    end

    if #WeaponsList == 0 then
        ySCP912.ChatPrint(owner, ply:Nick().." has no weapons to confiscate!", Red912)
        return
    end

    if ServerWeaponStorage[ply] then
        table.Add(ServerWeaponStorage[ply], WeaponsList)
    else
        ServerWeaponStorage[ply] = WeaponsList
    end

    LastThink = 0
    ySCP912.ChatPrint(owner, "Confiscated the following from "..ply:Nick()..":")
    net.Start("ySCP912:PrintWeps")
    net.WriteTable(WeaponsListString)
    net.Send(owner)
    ySCP912.ChatPrint(ply, "Your weapons have been confiscated by "..owner:Nick().."!", Red912)

    owner:EmitSound("physics/metal/weapon_impact_hard"..math.random(1,3)..".wav")

end

if CLIENT then -- messy
    net.Receive("ySCP912:PrintWeps", function(len)
        local weptbl = net.ReadTable()
        local TotalWeps = #weptbl
        local EndStr = ""
        for k,v in ipairs(weptbl) do
            if k == TotalWeps then
                EndStr = EndStr..language.GetPhrase(v)
            else
                EndStr = EndStr..language.GetPhrase(v)..", "
            end
        end
        ySCP912.ChatPrint(EndStr, Grey912)
    end)
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
    if Tr.Entity.SCPNum or !Tr.Entity:IsPlayer() then return end
    if owner:GetPos():DistToSqr( Tr.Entity:GetPos() ) > FireDistanceSqr then return end

    local ply = Tr.Entity

    if ply:getDarkRPVar("job") == "Staff on Duty" then return end -- bruh moment

    if !ServerWeaponStorage[ply] then
        ySCP912.ChatPrint(owner, "You do not have any of "..ply:Nick().."'s weapons!", Red912)
        return
    end

    local WeaponsListString = {}
    for k,v in ipairs(ServerWeaponStorage[ply]) do
        ply:Give(v)
        table.insert(WeaponsListString, ply:GetWeapon(v):GetPrintName())
    end

    ServerWeaponStorage[ply] = nil
    LastThink = 0
    
    ySCP912.ChatPrint(owner, "Returned "..ply:Nick().."'s confiscated weapons:")
    net.Start("ySCP912:PrintWeps")
    net.WriteTable(WeaponsListString)
    net.Send(owner)
    ySCP912.ChatPrint(ply, "Your confiscated weapons have been returned by "..owner:Nick()..".", Green912)

    owner:EmitSound("physics/metal/weapon_impact_soft"..math.random(1,3)..".wav")
    owner:EmitSound("items/ammo_pickup.wav")

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
    if LastThink > CurTime() then return end
    LastThink = CurTime() + 3

    local owner = self:GetOwner()

    local TableSend = {}
    for ply,tbl in pairs(ServerWeaponStorage) do
        if !IsValid(ply) or !IsEntity(ply) or !ply:IsValid() or !ply:IsPlayer() then ServerWeaponStorage[ply] = nil return end
        if table.IsEmpty(tbl) then ServerWeaponStorage[ply] = nil return end
        table.insert(TableSend, ply:Nick())
    end

    net.Start("ySCP912:StorageUpdate")
    net.WriteTable(TableSend)
    net.Send(owner)
end

if SERVER then
    hook.Add("PostPlayerDeath", "ySCP912:DeathRemoval", function(ply)
        ServerWeaponStorage[ply] = nil
        LastThink = 0
    end)
end