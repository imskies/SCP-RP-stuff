if SERVER then
    AddCSLuaFile()

    -- Server-side net message handler
    util.AddNetworkString("AnarchistTransaction")
end

SWEP.PrintName = "D-Class Black Market"
SWEP.Author = "LastLife"
SWEP.Instructions = "Left-click to open the menu."
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "Renovation Misc. SWeps"
SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

local anarchistSmallArms = {"cw_g4p_mp412_rex", "cw_mac11", "cw_flash_grenade"}
local anarchistMediumArms = {"cw_g4p_mp412_rex", "cw_shorty", "cw_l85a2", "cw_flash_grenade", "weapon_sh_smokegrenade"}
local anarchistHeavyArms = {"cw_g4p_mp412_rex", "cw_famasg2_official", "cw_flash_grenade", "weapon_sh_smokegrenade", "weapon_sh_electricgrenade"}

local function IsDClass(p)
    local jobData = RPExtraTeams[p:Team()]
    return jobData and jobData.category == "D-Class"
end

if SERVER then
	net.Receive("AnarchistTransaction", function(len, ply)
        local cost = net.ReadInt(32)
        local action = net.ReadString()

        if action == "health" then
            if ply:getDarkRPVar("money") >= cost then
                ply:addMoney(-cost)
                for _, p in ipairs(player.GetAll()) do
                    if IsDClass(p) then
                        p:SetHealth(50 + p:GetMaxHealth())
                    end
                end
                ply:ChatPrint("You have purchased medicine for all D-Class!")
            else
                ply:ChatPrint("You do not have enough money to use this item.")
            end

        elseif action == "armor" then
            if ply:getDarkRPVar("money") >= cost then
                ply:addMoney(-cost)
                for _, p in ipairs(player.GetAll()) do
                    if IsDClass(p) then
                        p:SetArmor(100)
                    end
                end
                ply:ChatPrint("You have purchased Kevlar for all D-Class!")
            else
                ply:ChatPrint("You do not have enough money to use this item.")
            end

        elseif action == "smallWeapons" then
            if ply:getDarkRPVar("money") >= cost then
                ply:addMoney(-cost)
                for _, p in ipairs(player.GetAll()) do
                    if IsDClass(p) then
                        for _, weapon in ipairs(anarchistSmallArms) do
                            if not p:HasWeapon(weapon) then
                                p:Give(weapon)
                            end
                        end
                    end
                end
                ply:ChatPrint("You have purchased Small Arms for all D-Class!")
            else
                ply:ChatPrint("You do not have enough money to use this item.")
            end

        elseif action == "medWeapons" then
            if ply:getDarkRPVar("money") >= cost then
                ply:addMoney(-cost)
                for _, p in ipairs(player.GetAll()) do
                    if IsDClass(p) then
                        for _, weapon in ipairs(anarchistMediumArms) do
                            if not p:HasWeapon(weapon) then
                                p:Give(weapon)
                            end
                        end
                    end
                end
                ply:ChatPrint("You have purchased Medium Arms for all D-Class!")
            else
                ply:ChatPrint("You do not have enough money to use this item.")
            end

        elseif action == "heavyWeapons" then
            if ply:getDarkRPVar("money") >= cost then
                ply:addMoney(-cost)
                for _, p in ipairs(player.GetAll()) do
                    if IsDClass(p) then
                        for _, weapon in ipairs(anarchistHeavyArms) do
                            if not p:HasWeapon(weapon) then
                                p:Give(weapon)
                            end
                        end
                    end
                end
                ply:ChatPrint("You have purchased Heavy Arms for all D-Class!")
            else
                ply:ChatPrint("You do not have enough money to use this item.")
            end
        end
    end)
end

local frame

function SWEP:PrimaryAttack()
    if CLIENT then
        if IsValid(frame) then
            return
        end
        self:OpenMenu()
    end
end

function SWEP:SecondaryAttack()
    return false
end

function SWEP:OpenMenu()

    frame = vgui.Create("DFrame")
    frame:SetSize(600, 500)
    frame:SetTitle("Anarchist Black Market")
    frame:Center()
    frame:MakePopup()

    local ply = LocalPlayer()

    local function AnarchistHealth(cost)
        if timer.Exists("AnarchistHPCooldown") then
            ply:ChatPrint("You or somebody else has already used the 'Medicine' item. You must wait " .. math.ceil(timer.TimeLeft("AnarchistHPCooldown")) .. " seconds to use it again.")
            return
        end

        net.Start("AnarchistTransaction")
        net.WriteInt(cost, 32)
        net.WriteString("health")
        net.SendToServer()

        timer.Create("AnarchistHPCooldown", 300, 1, function()
            timer.Remove("AnarchistHPCooldown")
        end)
    end

    local function AnarchistArmor(cost)
        if timer.Exists("AnarchistAPCooldown") then
            ply:ChatPrint("You or somebody else has already used the 'Kevlar' item. You must wait " .. math.ceil(timer.TimeLeft("AnarchistAPCooldown")) .. " seconds to use it again.")
            return
        end

        net.Start("AnarchistTransaction")
        net.WriteInt(cost, 32)
        net.WriteString("armor")
        net.SendToServer()

        timer.Create("AnarchistAPCooldown", 300, 1, function()
            timer.Remove("AnarchistAPCooldown")
        end)
    end

    local function AnarchistWeapons(weaponTable, cost)
        if timer.Exists("AnarchistGunCooldown") then
            ply:ChatPrint("You or somebody else has already used the 'Arms' item. You must wait " .. math.ceil(timer.TimeLeft("AnarchistGunCooldown")) .. " seconds to use it again.")
            return
        end

        net.Start("AnarchistTransaction")
        net.WriteInt(cost, 32)
        if weaponTable == anarchistSmallArms then
            net.WriteString("smallWeapons")
        elseif weaponTable == anarchistMediumArms then
            net.WriteString("medWeapons")
        elseif weaponTable == anarchistHeavyArms then
            net.WriteString("heavyWeapons")
        end
        net.SendToServer()

        timer.Create("AnarchistGunCooldown", 600, 1, function()
            timer.Remove("AnarchistGunCooldown")
        end)
    end

    local buttons = {
        {text = "Medicine [$30,000]", action = function() AnarchistHealth(30000) end},





        {text = "Kevlar [$15,000]", action = function() AnarchistArmor(15000) end},
        {text = "Small Arms [$30,000]", action = function() AnarchistWeapons(anarchistSmallArms, 30000) end},
        {text = "Medium Arms [$50,000]", action = function() AnarchistWeapons(anarchistMediumArms, 50000) end},
        {text = "Heavy Arms [$100,000]", action = function() AnarchistWeapons(anarchistHeavyArms, 100000) end}
    }

    for i, btnData in ipairs(buttons) do
        local button = vgui.Create("DButton", frame)
        button:SetSize(500, 60)
        button:SetPos(50, 80 + (i - 1) * 70)
        button:SetText(btnData.text)
        button.DoClick = function()
            btnData.action()
        end
    end
end