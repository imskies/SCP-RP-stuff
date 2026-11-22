/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.AIZ = zbl.AIZ or {}

// Anti Infection zones define areas in which player cant get infected and where objects cant be contamined

// Here we store all the predefind positions for the Anti Infection Zone
zbl.AIZ.Positions = zbl.AIZ.Positions or {}

function zbl.AIZ.Add(pos, radius, ply)

    table.insert(zbl.AIZ.Positions, {
        pos = pos,
        radius = radius
    })
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

    zclib.Notify(ply, "Added Anti Infection Zone!", 0)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

    timer.Simple(0, function()
        zbl.AIZ.Show(ply)
    end)
end

// Removes any spawn pos which is near this pos
function zbl.AIZ.Remove(pos,ply,dist)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

    local removed_pos = 0
    local old_pos = zbl.AIZ.Positions
    zbl.AIZ.Positions = {}

    for k, v in pairs(old_pos) do
        if v and v.pos:Distance(pos) > dist then
            table.insert(zbl.AIZ.Positions,v)
        else
            removed_pos = removed_pos + 1
        end
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

    if removed_pos > 0 then
        timer.Simple(0,function()
            zclib.Notify(ply, "Removed Anti Infection Zones: " .. removed_pos, 0)
            zbl.AIZ.Show(ply)
        end)
    end
end

util.AddNetworkString("zbl_aiz_showall")
function zbl.AIZ.Show(ply)

    local dataString = util.TableToJSON(zbl.AIZ.Positions)
    local dataCompressed = util.Compress(dataString)

    net.Start("zbl_aiz_showall")
    net.WriteUInt(#dataCompressed, 16)
    net.WriteData(dataCompressed, #dataCompressed)
    net.Send(ply)
end

util.AddNetworkString("zbl_aiz_hideall")
function zbl.AIZ.Hide(ply)
    net.Start("zbl_aiz_hideall")
    net.Send(ply)
end


// Tells us if the provided pos is near a Anit Infection Zone
function zbl.AIZ.NearZone(pos)
    local NearZone = false
    for k,v in pairs(zbl.AIZ.Positions) do
        if v and zclib.util.InDistance(v.pos, pos, v.radius) then
            NearZone = true
            break
        end
    end
    return NearZone
end

file.CreateDir("zbl")
zclib.STM.Setup("zbl_AIZ", "zbl/" .. string.lower(game.GetMap()) .. "_anti_infection_zones" .. ".txt", function()
    return zbl.AIZ.Positions
end, function(data)
    zbl.AIZ.Positions = data
    zbl.Print("Finished loading Anti Infection Zones!")
end, function()
    zbl.AIZ.Positions = {}
end)

concommand.Add("zbl_aiz_save", function(ply, cmd, args) if zclib.Player.IsAdmin(ply) then zbl.AIZ.Save(ply) end end)
concommand.Add("zbl_aiz_remove", function(ply, cmd, args) if zclib.Player.IsAdmin(ply) then zbl.AIZ.RemoveAll(ply) end end)

function zbl.AIZ.Save(ply)
    zclib.STM.Save("zbl_AIZ")
    zclib.Notify(ply, "Anti Infection Zones have been saved for the map " .. string.lower(game.GetMap()) .. "!", 0)
end

function zbl.AIZ.RemoveAll(ply)
    zclib.Notify(ply, "Anti Infection Zone have been removed for the map " .. string.lower(game.GetMap()) .. "!", 0)
    zclib.STM.Remove("zbl_AIZ")
end
