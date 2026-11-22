/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.HotSpot = zbl.HotSpot or {}

////////////////////////////////////////////
//////////// Virus HotSpot  /////////////
////////////////////////////////////////////

// The Hotspot system creates virus hotspots from predefined positions by the admins.
// A Virus Hotspot gets populated by virus nodes overtime if not removed

// Here we store all the predefind positions for a outbreak to occur
zbl.HotSpot.Positions = zbl.HotSpot.Positions or {}


// This will later store our outbreak core
zbl.HotSpot.CoreNodes = zbl.HotSpot.CoreNodes or {}
/*
zbl.HotSpot.CoreNodes = {
    [CoreID] = CoreNode,
    [CoreID] = CoreNode,
    [CoreID] = CoreNode,
}
*/

// This keeps count on all the virus nodes created by the outbreak
zbl.HotSpot.SlaveNodes = zbl.HotSpot.SlaveNodes or {}

/*
zbl.HotSpot.SlaveNodes = {
    [CoreID] = {SlaveNodes},
    [CoreID] = {SlaveNodes},
    [CoreID] = {SlaveNodes},
}
*/

function zbl.HotSpot.AddPos(pos,ang,ply)
    zclib.Debug("zbl.HotSpot.AddPos")

    table.insert(zbl.HotSpot.Positions, {
        pos = pos,
        ang = ang
    })

    zclib.Notify(ply, "Added Virus HotSpot positions", 0)

    timer.Simple(0,function()
        zbl.HotSpot.ShowAll(ply)
    end)
end

// Removes any spawn pos which is near this pos
function zbl.HotSpot.RemovePos(pos,ply)

    local removed_pos = 0
    local old_pos = zbl.HotSpot.Positions
    zbl.HotSpot.Positions = {}

    for k, v in pairs(old_pos) do
        if v and v.pos:Distance(pos) > 50 then
            table.insert(zbl.HotSpot.Positions,v)
        else
            removed_pos = removed_pos + 1
        end
    end

    if removed_pos > 0 then
        timer.Simple(0,function()
            zclib.Notify(ply, "Removed Virus HotSpot positions: " .. removed_pos, 0)
            zbl.HotSpot.ShowAll(ply)
        end)
    end
end

util.AddNetworkString("zbl_hotspot_showall")
function zbl.HotSpot.ShowAll(ply)

    local new_tbl = {}

    for k,v in pairs(zbl.HotSpot.Positions) do
        table.insert(new_tbl,v.pos)
    end

    local dataString = util.TableToJSON(new_tbl)
    local dataCompressed = util.Compress(dataString)

    net.Start("zbl_hotspot_showall")
    net.WriteUInt(#dataCompressed, 16)
    net.WriteData(dataCompressed, #dataCompressed)
    net.Send(ply)
end

function zbl.HotSpot.SetupTimer()
    if zbl.config.VirusHotspots.enabled == false then return end

    zclib.Debug("zbl.HotSpot.SetupTimer")

    local timerid = "zbl_vhs_timer"
    zclib.Timer.Remove(timerid)

    zclib.Timer.Create(timerid,zbl.config.VirusHotspots.growth_interval,0,function()
        // Does the spreading for x amount of hotspots
        for i = 1, math.Clamp(zbl.config.VirusHotspots.core_limit,1,25) do
            zbl.HotSpot.SpreadLogic(i)
        end
    end)
end


file.CreateDir("zbl")
zclib.STM.Setup("zbl_hotspot", "zbl/" .. string.lower(game.GetMap()) .. "_hotspots" .. ".txt", function()
    return zbl.HotSpot.Positions
end, function(data)
    zbl.HotSpot.SetupTimer()
    zbl.HotSpot.Positions = data
    zbl.Print("Finished loading Virus Hotspots!")
end, function()
    zbl.HotSpot.Positions = {}
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

concommand.Add("zbl_hotspot_save", function(ply, cmd, args) if zclib.Player.IsAdmin(ply) then zbl.HotSpot.Save(ply) end end)
concommand.Add("zbl_hotspot_remove", function(ply, cmd, args) if zclib.Player.IsAdmin(ply) then zbl.HotSpot.RemoveAll(ply) end end)

function zbl.HotSpot.Save(ply)
    zclib.STM.Save("zbl_hotspot")
    zclib.Notify(ply, "Virus HotSpots have been saved for the map " .. string.lower(game.GetMap()) .. "!", 0)
end

function zbl.HotSpot.RemoveAll(ply)
    zclib.Notify(ply, "Virus HotSpots have been removed for the map " .. string.lower(game.GetMap()) .. "!", 0)
    zclib.STM.Remove("zbl_hotspot")
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

// Mainlogic
function zbl.HotSpot.SpreadLogic(core_id)

    // If there is no active researcher on the server then stop growing
    if zbl.config.VirusHotspots.GrowOnJobOnly == true and zbl.Player.ActiveResearcher() == false then

        local node = zbl.HotSpot.GetRandomSlaveNode(core_id)
        zclib.Debug("No Researcher on the server, killing random node")
        if not IsValid(node) then return end

        zbl.Node.ExplodeNode(node,true)
        return
    end


    if not IsValid(zbl.HotSpot.CoreNodes[core_id]) then

        if #zbl.HotSpot.Positions <= 0 then return end

        // Get Random pos from zbl.HotSpot.Positions
        local pos_data = zbl.HotSpot.Positions[math.random(#zbl.HotSpot.Positions)]

        // Lets check if this position isnt occupied
        if zbl.Node.AreaFree(pos_data.pos) == false then return end

        // Check if position is near AIZ
        if zbl.AIZ.NearZone(pos_data.pos) then return end

        // Generate a random virus id according to the spawn chance
        local virus_id
        local pool = {}
        for k, v in pairs(zbl.config.VirusHotspots.virus_chance) do
            for i = 1, v do
                table.insert(pool, k)
            end
        end
        pool = zclib.table.randomize(pool)
        virus_id = pool[math.random(#pool)]
        //zclib.Debug(pool)
        //zclib.Debug("Winner ID: " .. virus_id)

        local node = zbl.Node.CreateNode(pos_data.pos, pos_data.ang, virus_id, 1)
        node.CoreID = core_id
        zbl.HotSpot.CoreNodes[core_id] = node
    else

        if zbl.HotSpot.SlaveNodes[core_id] == nil then
            zbl.HotSpot.SlaveNodes[core_id] = {}
        end

        local vn_count = table.Count(zbl.HotSpot.SlaveNodes[core_id])

        if vn_count >= zbl.config.VirusHotspots.node_limit then

            // Get Random node and increase its health
            local node = zbl.HotSpot.GetRandomSlaveNode(core_id)
            if not IsValid(node) then return end

            if zclib.util.RandomChance(99) then
                // Increase Health
                zbl.Node.Heal(node,zbl.config.VirusHotspots.node_health_increment)
            else
                // Kill this node to infect close ents
                zbl.Node.ExplodeNode(node,true)
            end

            return
        end

        local node
        if vn_count > 3 then
            // Get the node which have the least numbers of neighbors in a radius of 200
            node = zbl.HotSpot.GetLeastNeighbor(core_id)
        else
            // Get first position from core node
            node = zbl.HotSpot.CoreNodes[core_id]
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

        if not IsValid(node) then return end

        // Does this node have enough health to spread?
        if node:GetVHealth() < zbl.config.VirusHotspots.node_health_spread then

            // Increase Health
            zbl.Node.Heal(node,zbl.config.VirusHotspots.node_health_increment)
            return
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

        // This keeps count on how often we used this node for finding a new spread position
        // If it got used more then 9 times in the last 10 intervals without any valid position then we kill it
        if node.LastRepeatCheck then

            if (node.LastRepeatCheck + (zbl.config.VirusHotspots.growth_interval * 10)) < CurTime() then

                node.RepeatCount = 0
                node.LastRepeatCheck  = CurTime()
            else
                // If it tried the last 9 intervals allways the same node then we kill the node since the position doesent allow to spread
                if node.RepeatCount >= 9 and node ~= zbl.HotSpot.CoreNodes[core_id] then
                    zbl.Node.ExplodeNode(node,true)
                    return
                end
            end
        else
            node.LastRepeatCheck  = CurTime()
        end

        node.RepeatCount = (node.RepeatCount or 0) + 1


        // Get Position data
        local found, pos,ang = zbl.HotSpot.GetNodePos(node)
        if found == false then
            //zclib.Debug("Could not find valid spawn pos")

            // Increase Health
            zbl.Node.Heal(node,zbl.config.VirusHotspots.node_health_increment)
            return
        end

        // If we found a position then we reset the counter
        node.RepeatCount = 0
        node.LastRepeatCheck  = CurTime()

        local node_pos = pos
        local node_ang = ang
        node_ang:RotateAroundAxis(node_ang:Right(),-90)

        // Create new slave node
        local _node = zbl.Node.CreateNode(node_pos, node_ang, zbl.HotSpot.CoreNodes[core_id].Virus_ID, 1)
        _node.CoreID = core_id
        table.insert(zbl.HotSpot.SlaveNodes[core_id],_node)
    end
end

// Gets a random slave node from the provided core id
function zbl.HotSpot.GetRandomSlaveNode(core_id)
    local slaves = zbl.HotSpot.SlaveNodes[core_id]

    if slaves == nil then return end
    if table.Count(slaves) <= 0 then return end

    local node_index = math.random(table.Count(slaves))
    local node = slaves[node_index]
    if not IsValid(node) then
        zbl.HotSpot.SlaveNodes[core_id][node_index] = nil
        return
    end

    return node
end

// Returns the virus node which has the least neighbors
function zbl.HotSpot.GetLeastNeighbor(core_id)
    local n_count = 999999999
    local least_neighbor = nil


    local dist = 300 + (100 * zbl.config.VirusNodes.max_scale)

    for k,v in pairs(zbl.HotSpot.SlaveNodes[core_id]) do
        if IsValid(v) then

            local _count = 0
            // Lets compare with every node that exists
            for s,w in pairs(zbl.Node.List) do
                if IsValid(w) and zclib.util.InDistance(v:GetPos(), w:GetPos(), dist) then
                    _count = _count + 1
                end
            end

            if _count < n_count then
                n_count = _count
                least_neighbor = v
            end
        end
    end

    return least_neighbor
end

// Returns a random node position traced from the provided node
function zbl.HotSpot.GetNodePos(node)
    if not IsValid(node) then return end
    local found = false
    local pos
    local ang

    local lenght = 200 + (60 * zbl.config.VirusNodes.max_scale)

    // Returns either a list of valid positions or a empty list
    local cachedPos = zbl.Node.CNP_ReturnList(node:GetPos() + node:GetUp() * 50,lenght)

    if zbl.config.VirusHotspots.cache.enabled == true and cachedPos and table.Count(cachedPos) > 0 then

        local c_data = cachedPos[math.random(#cachedPos)]

        if c_data then
            found = true
            pos =  c_data.Pos
            ang = c_data.Ang
            ang:RotateAroundAxis(ang:Right(),90)

        end
        zclib.Debug("Used Cached Position, Found: " .. tostring(found))

    else

        local tr = zbl.Node.PerformSpawnTrace(node:GetPos() + node:GetUp() * 50,node:GetAngles(),lenght)
        if tr then
            found = true
            pos =  tr.HitPos
            ang = tr.HitNormal:Angle()
        end

        zclib.Debug("Traced Position, Found: " .. tostring(found))
    end


    return found, pos,ang
end

function zbl.HotSpot.RemoveNode(ent)
    //zclib.Debug("zbl.HotSpot.RemoveNode")

    if table.HasValue(zbl.HotSpot.CoreNodes,ent) then

        if ent.CoreID == nil then return end
        if zbl.HotSpot.SlaveNodes[ent.CoreID] == nil then return end

        // Explode all the children
        local delay = 0.1
        for k,v in pairs(zbl.HotSpot.SlaveNodes[ent.CoreID]) do
            if IsValid(v) then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

                timer.Simple(delay,function()
                    if IsValid(v) then
                        zbl.Node.ExplodeNode(v,true)
                    end
                end)

                delay = delay + 0.1
            end
        end
    else

        if ent.CoreID == nil then return end
        if zbl.HotSpot.SlaveNodes[ent.CoreID] == nil then return end

        // If this node is a slave node then remove it from the list
        table.RemoveByValue(zbl.HotSpot.SlaveNodes[ent.CoreID],ent)
    end
end
////////////////////////////////////////////
////////////////////////////////////////////
