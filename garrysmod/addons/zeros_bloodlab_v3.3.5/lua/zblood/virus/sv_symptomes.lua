/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.Symptome = zbl.Symptome or {}
zbl.Symptome.List = zbl.Symptome.List or {}

// Scales the players bone
util.AddNetworkString("zbl_scalebone")
local function ScaleBoneTo(ply,boneid,scale,speed)
    if boneid == nil then return end
    net.Start("zbl_scalebone")
    net.WriteEntity(ply)
    net.WriteInt(scale * 10, 16)
    net.WriteInt(boneid,16)
    net.WriteInt(speed,16)
    net.Broadcast()
end

local function GetDamageInflictor(ply)
	if zbl.config.DamageInflictorSelf then
		return ply
	else
		return game.GetWorld()
	end
end

util.AddNetworkString("zbl_scfx_cough")
zbl.Symptome.List["coughing"] = {

    OnStart = function(ply,data)
        if not IsValid(ply) then return end

        local timerid = "zbl_coughing_" .. zclib.Player.GetID(ply)
        zclib.Timer.Remove(timerid)

        zclib.Timer.Create(timerid,data.interval,0,function()
            if not IsValid(ply) or ply:Alive() == false then return end

            if zclib.util.RandomChance(75) == false then
                return
            end

            // Screen Effect
            net.Start("zbl_scfx_cough")
            net.Send(ply)

            // Cough
            zbl.Player.CoughSound(ply)

            // Damage Player
            if data.damage and data.damage > 0 then
                zbl.Player.Damage(ply,DMG_GENERIC,data.damage,GetDamageInflictor(ply))
            end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

            local vac_id = zbl.Vaccine.Get(ply)
            local vac_stage = zbl.Vaccine.GetStage(ply)

            // If the player himself has some protection then we reduce the infection impact on other player too
            local chance , _ = zbl.Player.ProtectionTest(ply, vac_id, vac_stage)
            chance = (1 / 100) * chance
            chance = math.Clamp(1 - chance,0,1)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

            if chance > 0 then
                //Create Effect
                local effect_pos = zclib.Player.GetHeadPos(ply)
                zclib.NetEvent.Create("zbl_infect_cough", {effect_pos})
            end

            local vData = {
                vaccine_id = vac_id,
                vaccine_stage = vac_stage,
                inflictor = ply,
                infect_type = "coughing"
            }

            // Infect new Players in proximity
            zbl.Infect.Proximity(ply:GetPos(),  data.infect_distance,data.infect_chance * chance,vData)
        end)
    end,

    OnEnd = function(ply)

        local timerid = "zbl_coughing_" .. zclib.Player.GetID(ply)
        zclib.Timer.Remove(timerid)
    end,
}

util.AddNetworkString("zbl_scfx_vomit")
zbl.Symptome.List["projectile_vomit"] = {

    OnStart = function(ply,data)
        if not IsValid(ply) then return end

        local timerid = "zbl_projectile_vomit_" .. zclib.Player.GetID(ply)
        zclib.Timer.Remove(timerid)

        zclib.Timer.Create(timerid,data.interval,0,function()
            if not IsValid(ply) or ply:Alive() == false then return end

            if zclib.util.RandomChance(75) == false then
                return
            end

            // Screeneffect
            net.Start("zbl_scfx_vomit")
            net.Send(ply)

            // Vomit sound
            zbl.Player.VomitSound(ply)

            local vac_id = zbl.Vaccine.Get(ply)
            local vac_stage = zbl.Vaccine.GetStage(ply)

            // If the player himself has some protection then we reduce the infection impact on other player too
            local chance , _ = zbl.Player.ProtectionTest(ply, vac_id, vac_stage)
            chance = (1 / 100) * chance
            chance = math.Clamp(1 - chance,0,1)

            if chance > 0 then
                //Create Vomit Projectile
                local vomit_pos = zclib.Player.GetHeadPos(ply) + (ply:EyeAngles():Forward() * 15)
                zbl.Infect.VomitProjectile(vac_id,vac_stage,vomit_pos,ply:EyeAngles():Forward(),0.5,ply)
            end

            // Damage Player
            if data.damage and data.damage > 0 then
                zbl.Player.Damage(ply,DMG_GENERIC,data.damage,GetDamageInflictor(ply))
            end
        end)
    end,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

    OnEnd = function(ply)

        if not IsValid(ply) then return end

        local timerid = "zbl_projectile_vomit_" .. zclib.Player.GetID(ply)
        zclib.Timer.Remove(timerid)
    end,
}

zbl.Symptome.List["explosive_diarrhea"] = {

    OnStart = function(ply,data)
        if not IsValid(ply) or ply:Alive() == false then return end

        local timerid = "zbl_explosive_diarrhea_" .. zclib.Player.GetID(ply)
        zclib.Timer.Remove(timerid)

        zclib.Timer.Create(timerid,data.interval,0,function()

            if not IsValid(ply) or ply:Alive() == false then return end

            if zclib.util.RandomChance(75) == false then
                return
            end

            // Damage Player
            if data.damage and data.damage > 0 then
                zbl.Player.Damage(ply,DMG_GENERIC,data.damage,GetDamageInflictor(ply))
            end

            local vac_id = zbl.Vaccine.Get(ply)
            local vac_stage = zbl.Vaccine.GetStage(ply)

            // If the player himself has some protection then we reduce the infection impact on other player too
            local chance , _ = zbl.Player.ProtectionTest(ply, vac_id, vac_stage)
            chance = (1 / 100) * chance
            chance = math.Clamp(1 - chance,0,1)

            if chance > 0 then
                //Create Diaraia Spot
                zbl.Infect.DiariaSpot(ply)

                // Create Diaria effect and decals
                zclib.NetEvent.Create("zbl_infect_diaria", {ply})
            end

            local vData = {
                vaccine_id = vac_id,
                vaccine_stage = vac_stage,
                inflictor = ply,
                infect_type = "explosive_diarrhea"
            }

            // Infect new Players in proximity
            zbl.Infect.Proximity(ply:GetPos(),  200,50 * chance,vData)
        end)
    end,

    OnEnd = function(ply)

        if not IsValid(ply) then return end

        local timerid = "zbl_explosive_diarrhea_" .. zclib.Player.GetID(ply)
        zclib.Timer.Remove(timerid)
    end,
}

zbl.Symptome.List["head_swelling"] = {

    OnStart = function(ply,data)
        if not IsValid(ply) or ply:Alive() == false then return end

        zbl.Player.HurtSound(ply)

        // Create net msg to increase player head on client
        local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
        ScaleBoneTo(ply,bone,data.scale,1)

        if data.damage and data.damage > 0 then
            zbl.Player.Damage(ply,DMG_GENERIC,data.damage,GetDamageInflictor(ply))
        end
    end,

    OnEnd = function(ply)

        if not IsValid(ply) then return end

        local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
        ScaleBoneTo(ply,bone,1,1)
    end,
}

zbl.Symptome.List["legs_swelling"] = {

    OnStart = function(ply,data)
        if not IsValid(ply) or ply:Alive() == false then return end

        zbl.Player.HurtSound(ply)

        local bone01 = ply:LookupBone("ValveBiped.Bip01_R_Thigh")
        ScaleBoneTo(ply,bone01,data.scale,1)

        local bone02 = ply:LookupBone("ValveBiped.Bip01_L_Thigh")
        ScaleBoneTo(ply,bone02,data.scale,1)


        local bone03 = ply:LookupBone("ValveBiped.Bip01_R_Foot")
        ScaleBoneTo(ply,bone03,data.scale,1)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

        local bone04 = ply:LookupBone("ValveBiped.Bip01_L_Foot")
        ScaleBoneTo(ply,bone04,data.scale,1)


        local bone05 = ply:LookupBone("ValveBiped.Bip01_R_Calf")
        ScaleBoneTo(ply,bone05,data.scale,1)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

        local bone06 = ply:LookupBone("ValveBiped.Bip01_L_Calf")
        ScaleBoneTo(ply,bone06,data.scale,1)


        if data.damage and data.damage > 0 then
            // Damage Player
            zbl.Player.Damage(ply,DMG_GENERIC,data.damage,GetDamageInflictor(ply))
        end
    end,

    OnEnd = function(ply)

        if not IsValid(ply) then return end

        local bone01 = ply:LookupBone("ValveBiped.Bip01_R_Thigh")
        ScaleBoneTo(ply,bone01,1,1)

        local bone02 = ply:LookupBone("ValveBiped.Bip01_L_Thigh")
        ScaleBoneTo(ply,bone02,1,1)

        local bone03 = ply:LookupBone("ValveBiped.Bip01_R_Foot")
        ScaleBoneTo(ply,bone03,1,1)

        local bone04 = ply:LookupBone("ValveBiped.Bip01_L_Foot")
        ScaleBoneTo(ply,bone04,1,1)

        local bone05 = ply:LookupBone("ValveBiped.Bip01_R_Calf")
        ScaleBoneTo(ply,bone05,1,1)

        local bone06 = ply:LookupBone("ValveBiped.Bip01_L_Calf")
        ScaleBoneTo(ply,bone06,1,1)

    end,
}

zbl.Symptome.List["explosive_head"] = {

    OnStart = function(ply,data)
        if not IsValid(ply) or ply:Alive() == false then return end

        zbl.Player.HurtSound(ply)

        //Create Effect
        local effect_pos = zclib.Player.GetHeadPos(ply)
        zclib.NetEvent.Create("zbl_explode_head", {effect_pos})

        local vac_id = zbl.Vaccine.Get(ply)
        local vac_stage = zbl.Vaccine.GetStage(ply)

        // If the player himself has some protection then we reduce the infection impact on other player too
        local chance , _ = zbl.Player.ProtectionTest(ply, vac_id, vac_stage)
        chance = (1 / 100) * chance
        chance = math.Clamp(1 - chance,0,1)

        local vData = {
            vaccine_id = vac_id,
            vaccine_stage = 1,
            inflictor = ply,
            infect_type = "explosive_head"
        }

        // Infect new Players in proximity
        zbl.Infect.Proximity(ply:GetPos(), data.infect_distance,data.infect_chance * chance,vData)

        ply:Kill()
    end,

    OnEnd = function(ply)

        if not IsValid(ply) then return end
    end,
}

// Creates the Symptomes of the Vaccine
function zbl.Symptome.OnStart(ply,vaccineID,vaccineStage)

    // Create Symptomes
    local Symptomes = zbl.Vaccine.GetMutationStage_Symptomes(vaccineID,vaccineStage)
    if Symptomes then
        for k,v in pairs(Symptomes) do

            if zbl.Symptome.List[k] then
                zclib.Debug("zbl.Symptome.List[" .. k .. "] Start")

                // Calls the spread symptome
                zbl.Symptome.List[k].OnStart(ply,v)
            end
        end
    end

    // Modify Jump Modifier
    local Effects = zbl.Vaccine.GetMutationStage_Effects(vaccineID,vaccineStage)
    if Effects and Effects["jump_modify"] then
        ply:SetJumpPower(Effects["jump_modify"])
    end
end

// Removes the Symptomes of the Vaccine
function zbl.Symptome.OnEnd(ply)
    if not IsValid(ply) then return end

    local vaccineID = zbl.Vaccine.Get(ply)
    local vaccineStage = zbl.Vaccine.GetStage(ply)

    // Stops the symtomes
    local Symptomes = zbl.Vaccine.GetMutationStage_Symptomes(vaccineID,vaccineStage)
    if Symptomes then
        for k,v in pairs(Symptomes) do
            if zbl.Symptome.List[k] then
                zclib.Debug("zbl.Symptome.List[" .. k .. "] End")
                zbl.Symptome.List[k].OnEnd(ply)
            end
        end
    end

    // Reset Jump Power
    local Effects = zbl.Vaccine.GetMutationStage_Effects(vaccineID,vaccineStage)
    if Effects and Effects["jump_modify"] then
        ply:SetJumpPower(200)
    end
end




zclib.Hook.Add("EntityTakeDamage", "zbl_DamageModifier", function(target, dmginfo)
    if IsValid(target) and target:IsPlayer() and target:Alive() then
        local vaccineID = zbl.Vaccine.Get(target)
        if vaccineID ~= -1 then
            local vaccineStage = zbl.Vaccine.GetStage(target)
            local Effects = zbl.Vaccine.GetMutationStage_Effects(vaccineID,vaccineStage)
            if Effects then

                if Effects["damage_modify"] then
                    dmginfo:ScaleDamage(Effects["damage_modify"])
                elseif Effects["damage_fire_modify"] and dmginfo:GetDamageType() == DMG_BURN then
                    dmginfo:ScaleDamage(Effects["damage_fire_modify"])
                elseif Effects["damage_fall_modify"] and dmginfo:GetDamageType() == DMG_FALL then
                    dmginfo:ScaleDamage(Effects["damage_fall_modify"])
                elseif Effects["damage_bullet_modify"] and dmginfo:GetDamageType() == DMG_BULLET then
                    dmginfo:ScaleDamage(Effects["damage_bullet_modify"])
                end
            end
        end
    end
end)

zclib.Hook.Add("Move", "zbl_MoveModifier", function(ply, mv, usrcmd)
    if zbl.Vaccine.Has(ply) then
        local Effects = zbl.Vaccine.GetMutationStage_Effects(zbl.Vaccine.Get(ply), zbl.Vaccine.GetStage(ply))
        if Effects and Effects["movement_speed"] then
            local speed = mv:GetMaxSpeed() * Effects["movement_speed"]
            mv:SetMaxSpeed(speed)
            mv:SetMaxClientSpeed(speed)
        end
    end
end)
