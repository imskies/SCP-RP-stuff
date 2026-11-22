
util.AddNetworkString("dconfig2_increaseStat")
function DCONFIG2.Stats.IncreaseStat(stat, header, amount)
    local statData = DCONFIG2.Stats.Data[stat]
    -- Stat validation check
    if not statData or not header then DCONFIG2.MsgC("Attempting to progress invalid stat: " .. stat .. "|" .. (header or "Unknown Header"), true) return end

    local headerData = statData[header] or 0
    DCONFIG2.Stats.Data[stat][header] = headerData + amount
    DCONFIG2.Stats.ShouldSave[stat] = true

    local dconfigAccess = {}
      -- create table and write configs
    for k,v in ipairs(player.GetAll()) do
        if not DCONFIG2.CanDConfig(v) then continue end
        table.insert(dconfigAccess, v)
    end

    -- Network stats to the players that can view them
    net.Start("dconfig2_increaseStat")
    net.WriteString(stat)
    net.WriteString(header)
    net.WriteUInt(DCONFIG2.Stats.Data[stat][header],32)
    net.Send(dconfigAccess)
end

hook.Add("playerBoughtShipment", "DConfig2TrackShipments", function(ply, shipmentTable, ent, price)
    DCONFIG2.Stats.IncreaseStat("shipments", shipmentTable.entity, 1)
end)

hook.Add("playerBoughtPistol", "DConfig2TrackWeapons", function(ply, weaponTable, ent, price)
    DCONFIG2.Stats.IncreaseStat("weapons", weaponTable.entity, 1)
end)

hook.Add("playerBoughtCustomEntity", "DConfig2TrackEntities", function(ply, entityTable, ent, price)
    DCONFIG2.Stats.IncreaseStat("entities", entityTable.ent, 1)
end)

hook.Add("playerBoughtAmmo", "DConfig2TrackAmmo", function(ply, ammoTable, ent, price)
    DCONFIG2.Stats.IncreaseStat("ammo", ammoTable.ammoType, 1)
end)

function DCONFIG2.SaveAllStats()
    for k,v in pairs(DCONFIG2.Stats.Data) do
        --We only save stats that actually need to be saved.
        if not DCONFIG2.Stats.ShouldSave[k] then continue end
        DCONFIG2.SaveData("stats_"..k)
        DCONFIG2.Stats.ShouldSave[k] = nil
    end 
end 

local jobThinkTime = 60
local nextJobThink = CurTime() + jobThinkTime
local saveThinkTime = DCONFIG2.IngameConfig.stat_save_time
local nextSaveThink = CurTime() + saveThinkTime
hook.Add("Think", "DConfig2TrackJobTime", function()
    local curTime = CurTime()
    if DCONFIG2.IngameConfig.stats_jobs and nextJobThink < curTime then
        local addTime = jobThinkTime / 60
        for k,v in ipairs(player.GetAll()) do
            local jobData = RPExtraTeams[v:Team()]
            if not jobData or not jobData.jobvar then continue end

            DCONFIG2.Stats.IncreaseStat("jobs", jobData.jobvar, addTime)
        end 
        nextJobThink = curTime + jobThinkTime
    end 
    if nextSaveThink < curTime then
        DCONFIG2.SaveAllStats()
        nextSaveThink = curTime + DCONFIG2.IngameConfig.stat_save_time 
    end 
end)