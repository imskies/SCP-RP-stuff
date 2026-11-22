/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.Player = zbl.Player or {}

zclib.Hook.Add("zclib_PlayerJoined", "zbl_PlayerJoined", function(ply)
    timer.Simple(0.5, function()
        if not IsValid(ply) then return end

        zbl.Vaccine.Set(ply, -1,-1)

        // Setup up dna data stuff if later used
        zbl.DNASystem.Load(ply)

        // Sends the current Infection report to the player
        zbl.Sign.UpdateClient(ply)
    end)
end)

function zbl.Player.Damage(ply,DamageType,Damage,Attacker)
    if not IsValid(ply) or ply:Alive() == false then return end

    local d = DamageInfo()
    d:SetDamage( Damage )
    d:SetAttacker( Attacker )
    d:SetInflictor( Attacker )
    d:SetDamageType( DamageType )
    ply:TakeDamageInfo( d )
end

////////////////////////////////////////////
//////////////// Appearance ////////////////
////////////////////////////////////////////
// Changes the Visual Appearance of the Player
function zbl.Player.ChangeAppearance(ply, vacID, vacStage)
    zclib.Debug("zbl.Player.ChangeAppearance")

    local mutation_stage = zbl.Vaccine.GetMutationStage_Data(vacID,vacStage)
    if mutation_stage == nil then return end

    if mutation_stage.appearance then
        local appearanceData = zbl.config.AppearanceEffects[mutation_stage.appearance]
        if appearanceData then
            // Apply Wound material
            if appearanceData.MaterialOverlay then
                ply:SetMaterial( appearanceData.MaterialOverlay, true )
            end

            // Apply Wound Color
            if appearanceData.ColorOverlay then
                ply:SetColor( appearanceData.ColorOverlay, true )
            end

            if appearanceData.PlayerModel then
                ply.zbl_OldPlayerModel = ply:GetModel()
                ply:SetModel( appearanceData.PlayerModel )
            end
        end
    end
end

// Resets the Visual Appearance of the Player
function zbl.Player.ResetAppearance(ply)
    ply:SetMaterial( "", true )
    ply:SetColor(color_white)

    if ply.zbl_OldPlayerModel then
        ply:SetModel(ply.zbl_OldPlayerModel)
        ply.zbl_OldPlayerModel = nil
    end
end


zclib.Player.CleanUp_Add("zbl_flask")
zclib.Player.CleanUp_Add("zbl_lab")
zclib.Player.CleanUp_Add("zbl_fence")
zclib.Player.CleanUp_Add("zbl_gasmask")

zclib.Gamemode.AssignOwnerOnBuy("zbl_lab")
zclib.Gamemode.AssignOwnerOnBuy("zbl_gasmask")
zclib.Gamemode.AssignOwnerOnBuy("zbl_fence")

function zbl.Player.Disconnect(steamid)

    // Remove any Vaccine/Symptome timer that exists from this player
    local timerid_vac = "zbl_vaccinetimer_" .. steamid
    zclib.Timer.Remove(timerid_vac)

    local vaccine_id, vaccine_stage = zbl.Player.GetActiveVaccine(steamid)
    if vaccine_id and vaccine_stage then

        local Symptomes = zbl.Vaccine.GetMutationStage_Symptomes(vaccine_id,vaccine_stage)
        if Symptomes then
            for k, v in pairs(Symptomes) do
                if zbl.Symptome.List[k] then
                    local sympt_timerid = "zbl_" .. k .. "_" .. steamid
                    zclib.Timer.Remove(sympt_timerid)
                end
            end
        end

        // Removes the activevaccine id from the list
        zbl.Player.RemoveActiveVaccine(steamid)
    end

    // Remove the occopation timer if it exists
    local timerid_ov = "zbl_vaccine_occopation_timer_" .. steamid
    zclib.Timer.Remove(timerid_ov)

    // Removes player from occopation list if he is on it
    zbl.Occopation.RemovePlayer(steamid)

    // Saves the player DNA Points if he got any
    zbl.DNASystem.PlayerDisconnect(steamid)

    // Stop any quest timer that might exist
    zbl.Quest.Stop(steamid,nil)
end

zclib.Hook.Add("zclib_PlayerDisconnect", "zbl_PlayerDisconnect", function(steamid) zbl.Player.Disconnect(steamid) end)

zclib.Hook.Add("PlayerDeath", "zbl_PlayerDeath", function(victim, inflictor, attacker)

    if zbl.Vaccine.Has(victim) then
        zclib.Debug("zbl.Player.Death")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

        local vac_id = zbl.Vaccine.Get(victim)
        local vac_stage = zbl.Vaccine.GetStage(victim)

        // Create corpse
        if zbl.config.Corpse.enabled then
            local rag = victim:GetRagdollEntity()
            if IsValid(rag) then
                rag:Remove()
            end
            zbl.Corpse.Spawn(victim,vac_id,vac_stage)
        end

        if zbl.Vaccine.GetCure_OnDeath(vac_id) then
            timer.Simple(1,function()
                if IsValid(victim) then
                    zbl.Player.ForceCure(victim)
                end
            end)
        end
    end

    // If the player had a gasmask then he lost it now
    zbl.GasMask.Equipt(victim, false)

    zbl.NPC.ForceCloseMenu(victim)
end)

zclib.Hook.Add("OnPlayerChangedTeam", "zbl_OnPlayerChangedTeam", function(ply, before, after)
    if zbl.config.Jobs[before] == true then
        // Stop any quest timer that might exist
        zbl.Quest.Stop(zclib.Player.GetID(ply),ply)

        zbl.DNASystem.PlayerChangedJob(zclib.Player.GetID(ply))
    end

    // If the player is infected then lets call the Appearance update again, if the mutation stage changes his appearance then we need to update it
    // Because changing job also changes the player model
    timer.Simple(0,function()

        if IsValid(ply) then

            local vaccine_id = zbl.Vaccine.Get(ply)

            if vaccine_id ~= -1 then
                zbl.Player.ChangeAppearance(ply, vaccine_id, zbl.Vaccine.GetStage(ply))
            end

            // If the player had a gasmask before job change and how his chance is higher or equals 100 then this means he has some other protection now and we remove his mask
            if zbl.Player.GetProtectionChance(ply, nil, nil) >= 100 and zbl.GasMask.Has(ply) then
                zbl.GasMask.Equipt(ply, false)
            end
        end
    end)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360


// Used by the Player to tell him his Candy Score / Points
zclib.Hook.Add("PlayerSay", "zbl_PlayerSay", function(ply, text)
    if string.sub(string.lower(text), 1, 9) == "!zbl_save" and zclib.Player.IsAdmin(ply) then

        zbl.NPC.Save(ply)
        zbl.Fence.Save(ply)
        zbl.Sign.Save(ply)
        zbl.Lab.Save(ply)
        zbl.HotSpot.Save(ply)
        zbl.AIZ.Save(ply)

    elseif string.sub(string.lower(text), 1, 9) == "!dropmask" then
        if zbl.GasMask.GetUses(ply) > 0 then
            zbl.GasMask.Equipt(ply, false)
        end
    elseif string.sub(string.lower(text), 1, 4) == "!dna" then
        zclib.Notify(ply, string.Replace(zbl.language.General["dna_tell"],"$AMOUNT",zbl.DNASystem.Get(ply)), 0)
    elseif string.sub(string.lower(text), 1, 8) == "!dropdna" then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

        local dna = string.sub(string.lower(text), 10, string.len(text))
        dna = tonumber(dna,10)

        if isnumber(dna) and dna > 0 then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

            if zbl.DNASystem.Get(ply) >= dna then

        		local tr = ply:GetEyeTrace()
        		if tr.Hit and zclib.util.InDistance(tr.HitPos, ply:GetPos(), 300) then

                    zbl.DNASystem.RemovePoints(ply,dna)

                    local ent = ents.Create("zbl_dna")
                	ent:SetPos(tr.HitPos + Vector(0,0,25))
                	ent:Spawn()
                	ent:Activate()
                    ent:SetDNAPoints(dna)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

                    zclib.Notify(ply,string.Replace(zbl.language.General["dna_drop"],"$AMOUNT",dna), 0)
                    SafeRemoveEntityDelayed(ent,300)
                else
                    zclib.Notify(ply, zbl.language.General["invalid_pos"], 1)
                end
            else
                zclib.Notify(ply, zbl.language.General["NotEnoughDNA"], 1)
            end
        end
    end
end)
////////////////////////////////////////////
////////////////////////////////////////////
