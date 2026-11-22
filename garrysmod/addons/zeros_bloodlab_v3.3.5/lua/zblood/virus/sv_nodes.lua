/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}

////////////////////////////////////////////
//////////////// Virusnode  ////////////////
////////////////////////////////////////////
zbl.Node = zbl.Node or {}
zbl.Node.List = zbl.Node.List or {}

// Performs a sphere trace with a random end point on a halfsphere
function zbl.Node.PerformSpawnTrace(pos,ang,length)
    local tr_ang = Angle(ang.p,ang.y,ang.r)

    // Rotation fix so the ang looks up
    tr_ang:RotateAroundAxis(ang:Right(),-180)

    // Random rotate to the right/left
    tr_ang:RotateAroundAxis(ang:Right(),math.random(-80,80))

    // Random rotate to Forward/backward
    tr_ang:RotateAroundAxis(ang:Forward(),math.random(-80,80))

    local tr_start = pos /*+ (ang:Up() * up)*/
    local tr_end = pos + (tr_ang:Up() * length)

    local tr = util.TraceLine( {
        start = tr_start,
        endpos = tr_end,
        mask = 81931, // Hit only the world + brushes please
    } )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

    if tr.Hit and tr.HitWorld and tr.HitSky == false and tr.StartSolid == false and tr.HitPos and util.IsInWorld( tr.HitPos ) and zbl.Node.AreaFree(tr.HitPos) and zbl.AIZ.NearZone(tr.HitPos) == false then
        //debugoverlay.Sphere(tr.HitPos, 3, 1, Color(0, 255, 0), false)
        //debugoverlay.Line(tr_start, tr.HitPos, 5, Color(0, 255, 0), false)
    else
        //debugoverlay.Line(tr_start, tr_end, 5, Color( 255, 0, 0 ),false )
        tr = false
    end

    return tr
end

// Checks if there are any nodes near the specified position
function zbl.Node.AreaFree(pos)
    local free = true

    local dist = 75 + (15 * zbl.config.VirusNodes.max_scale)

    for k, v in pairs(zbl.Node.List) do
        if IsValid(v) and zclib.util.InDistance(pos, v:GetPos(), dist) then
            free = false
            break
        end
    end

    return free
end

// Removes the node , creates a spore effect and infects player arround it
function zbl.Node.ExplodeNode(node,destroy)
    if not IsValid(node) then return end
    zclib.Debug("zbl.Node.ExplodeNode")

    zclib.NetEvent.Create("zbl_node_explode", {node:GetPos()})

    local dist = 50 * zbl.config.VirusNodes.max_scale
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

    local vData = {
        vaccine_id = node.Virus_ID,
        vaccine_stage = node.Virus_Stage,
        inflictor = node,
        infect_type = "virusnode_explosion"
    }

    zbl.Infect.Proximity(node:GetPos(), dist,90,vData)

    zbl.Contamination.ProximityContaminate(node:GetPos(), dist, node.Virus_ID)

    if destroy then
        // Destroy Virus
        local deltime = FrameTime() * 2
        if not game.SinglePlayer() then deltime = FrameTime() * 6 end
        SafeRemoveEntityDelayed(node,deltime)
    end
end

// Creates a virus node
function zbl.Node.CreateNode(pos, ang, virus_id, virus_stage)
    zclib.Debug("zbl.Node.CreateNode")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

    local ent = ents.Create("zbl_virusnode")
    if not IsValid(ent) then return end
    ent:SetPos(pos)
    ent:SetAngles(ang)
    ent:Spawn()
    ent:Activate()

    zbl.Vaccine.Set(ent, virus_id,1)

    ent.Virus_ID = virus_id
    ent.Virus_Stage = 1

    // Change material according to virus id
    ent:SetMaterial(zbl.Vaccine.GetMaterial(virus_id))

    // Give the node some health
    ent:SetVHealth(zbl.config.VirusHotspots.node_health_default)

    // Add to global node list
    table.insert(zbl.Node.List,ent)

    // Check if this position is valid to be cached
    if zbl.config.VirusHotspots.cache.enabled == true and zbl.Node.CNP_OverlapCheck(pos) == false then
        zbl.Node.CNP_Add(pos,ang)
    end

    zclib.Debug("Virus node created " .. tostring(ent))
    return ent
end

// Creates a virus node on a random space arround the provided pos
function zbl.Node.CreateNodeRandom(pos, ang, virus_id, virus_stage)
    local tr = zbl.Node.PerformSpawnTrace(pos,ang,400)
    if tr == false then return end

    if zbl.AIZ.NearZone(tr.HitPos) then return end

    local node_pos =  tr.HitPos
    local node_ang = tr.HitNormal:Angle()
    node_ang:RotateAroundAxis(node_ang:Right(),-90)

    local node = zbl.Node.CreateNode(node_pos, node_ang, virus_id, virus_stage)

    // This tells the created virus node to remove itself after certain amount of time
    SafeRemoveEntityDelayed(node,zbl.config.VirusNodes.life_time)
end

function zbl.Node.OnRemove(node)
    table.RemoveByValue(zbl.Node.List,node)

    zbl.HotSpot.RemoveNode(node)
end

function zbl.Node.TakeDamage(node,amount,inflictor)
    if not IsValid(node) then return end
    zbl.Node.ChangeHealth(node,math.Clamp(node:GetVHealth() - amount,0,zbl.config.VirusHotspots.node_health_max),inflictor)
end

function zbl.Node.Heal(node,amount)
    if not IsValid(node) then return end
    zbl.Node.ChangeHealth(node,math.Clamp(node:GetVHealth() + amount,0,zbl.config.VirusHotspots.node_health_max))
end

// Changes the Health of a Virus Node
function zbl.Node.ChangeHealth(node,new_health,inflictor)
    //zclib.Debug("zbl.Node.ChangeHealth")

    if node.GotKilled == true then return end

    local old_Health = node:GetVHealth()

    if new_health > old_Health then
        debugoverlay.Sphere(node:GetPos(), 50, 1, Color(0, 255, 255), true)
    elseif new_health < old_Health then
        debugoverlay.Sphere(node:GetPos(), 50, 1, Color(255, 0, 255), true)
    end

    node:SetVHealth(new_health)

    if new_health <= 0 then

        node.GotKilled = true

        hook.Run("zbl_OnVirusNodeDeath" ,inflictor,node.Virus_ID)

        // Destroy Virus
        local deltime = FrameTime() * 2
        if not game.SinglePlayer() then deltime = FrameTime() * 6 end
        SafeRemoveEntityDelayed(node,deltime)

    elseif new_health >= zbl.config.VirusHotspots.node_health_spread then
        node:SetBodygroup(0,1)
    else
        node:SetBodygroup(0,0)
    end
end
////////////////////////////////////////////
////////////////////////////////////////////


                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10




////////////////////////////////////////////
/////////// Cached Node Postions  //////////
////////////////////////////////////////////
zbl.Node.CachedPositions = zbl.Node.CachedPositions or {}

// Returns a list of positions which are near the provided start position
function zbl.Node.CNP_ReturnList(start_pos,dist)
    local valid_pos = {}

    for k,data in pairs(zbl.Node.CachedPositions) do
        if data and data.Pos and zclib.util.InDistance(data.Pos, start_pos, dist) and zbl.Node.AreaFree(data.Pos) and zbl.AIZ.NearZone(data.Pos) == false then
            table.insert(valid_pos,data)
        end
    end
    return valid_pos
end

// Checks if the provided position doesent overlap
function zbl.Node.CNP_OverlapCheck(start_pos)
    local overlap = false
    local dist = 75 + (15 * zbl.config.VirusNodes.max_scale)

    for k,data in pairs(zbl.Node.CachedPositions) do
        if data and data.Pos and zclib.util.InDistance(data.Pos, start_pos, dist) then
            overlap = true
            break
        end
    end
    return overlap
end

function zbl.Node.CNP_Add(_pos,_ang)
    zclib.Debug("Cached Position: " .. tostring(_pos))

    if zbl.Node.CachedPositions and table.Count(zbl.Node.CachedPositions) >= zbl.config.VirusHotspots.cache.limit then return end

    table.insert(zbl.Node.CachedPositions, {
        Pos = _pos,
        Ang = _ang
    })
end

// Removes any spawn pos which is near this pos
function zbl.Node.CNP_RemovePos(pos,ply)
    zclib.Debug("zbl.Node.CNP_RemovePos")

    local removed_pos = 0
    local old_pos = zbl.Node.CachedPositions
    zbl.Node.CachedPositions = {}

    for k, v in pairs(old_pos) do
        if v and v.Pos:Distance(pos) > 50 then
            table.insert(zbl.Node.CachedPositions,v)
        else
            removed_pos = removed_pos + 1
        end
    end

    if removed_pos > 0 then
        timer.Simple(0,function()
            zclib.Notify(ply, "Removed cached positions: " .. removed_pos, 0)
            zbl.Node.CNP_Show(ply)
        end)
    end
end



////////////////////////////////////////////

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

concommand.Add("zbl_CNP_show", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        zbl.Node.CNP_Show(ply)
    end
end)

util.AddNetworkString("zbl_CachedNodePositions_Show")
function zbl.Node.CNP_Show(ply)
    if zbl.Node.CachedPositions == nil or table.Count(zbl.Node.CachedPositions) <= 0 then return end

    local new_tbl = {}

    for k,v in pairs(zbl.Node.CachedPositions) do
        table.insert(new_tbl,v.Pos)
    end

    // Send position table to client
    local dataString = util.TableToJSON(new_tbl)
    local dataCompressed = util.Compress(dataString)

    net.Start("zbl_CachedNodePositions_Show")
    net.WriteUInt(#dataCompressed, 16)
    net.WriteData(dataCompressed, #dataCompressed)
    net.Send(ply)
end


////////////////////////////////////////////


concommand.Add("zbl_CNP_save", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        zbl.Node.CNP_Save(ply)
    end
end)

concommand.Add("zbl_CNP_remove", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        zbl.Node.CNP_Delete(ply)
    end
end)

zclib.Hook.Add("ShutDown", "zbl_CNP_SavePositions_ShutDown", function()
    if zbl.config.VirusHotspots.cache.enabled == true then
        zbl.Node.CNP_Save()
    end
end)



file.CreateDir("zbl")
zclib.STM.Setup("zbl_CNP", "zbl/" .. string.lower(game.GetMap()) .. "_cnp" .. ".txt", function()
    return zbl.Node.CachedPositions
end, function(data)
    zbl.Node.CachedPositions = data
    zbl.Print("Finished loading cached node positions!")
end, function()
    zbl.Node.CachedPositions = {}
end)

// Save the cache for the map
function zbl.Node.CNP_Save(ply)
    zclib.STM.Save("zbl_CNP")
    if IsValid(ply) then zclib.Notify(ply, "Cached Node Positions have been saved for the map " .. string.lower(game.GetMap()) .. "!", 0) end
end

// Remove the cache and savefile
function zbl.Node.CNP_Delete(ply)
    zclib.STM.Remove("zbl_CNP")
    if IsValid(ply) then zclib.Notify(ply, "Cached Node Positions have been removed for the map " .. string.lower(game.GetMap()) .. "!", 0) end
end
