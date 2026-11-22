/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.DNASystem = zbl.DNASystem or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10


////////////////////////////////////////////
////////// Save/Load DNA Points  ///////////
////////////////////////////////////////////

// This keeps track on how many dna points each user has
zbl.DNAPoints = zbl.DNAPoints or {}

if not file.Exists("zbl", "DATA") then file.CreateDir("zbl") end
if not file.Exists("zbl/data/", "DATA") then file.CreateDir("zbl/data/") end

function zbl.DNASystem.Load(ply)

    local plyID = zclib.Player.GetID(ply)
    local str = string.Replace(plyID,":","_")
    local _points = zbl.config.GenLab.start_points

    if file.Exists("zbl/data/" .. str .. ".txt", "DATA") then
        local data = file.Read("zbl/data/" .. str .. ".txt", "DATA")
        data = util.JSONToTable(data)

        if data and data.Points then
            _points = data.Points
        end
    end

    local steamid = zclib.Player.GetID(ply)
    zbl.DNASystem.Setup(steamid)

    zbl.DNAPoints[steamid].points = _points

    // Update if we should save this users data
    zbl.DNASystem.Changed(ply)
end

function zbl.DNASystem.Setup(steamid)
    if zbl.DNAPoints[steamid] == nil then
        zbl.DNAPoints[steamid] = {}

        if zbl.DNAPoints[steamid].points == nil then
            zbl.DNAPoints[steamid].points = 0
        end

        if zbl.DNAPoints[steamid].save == nil then
            zbl.DNAPoints[steamid].save = false
        end
    end
end

function zbl.DNASystem.AddPoints(ply,points)
    local steamid = zclib.Player.GetID(ply)

    zbl.DNASystem.Setup(steamid)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

    zbl.DNAPoints[steamid].points = zbl.DNAPoints[steamid].points + points

    // Update if we should save this users data
    zbl.DNASystem.Changed(ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

    return zbl.DNAPoints[steamid].points
end

function zbl.DNASystem.RemovePoints(ply,points)
    local steamid = zclib.Player.GetID(ply)

    zbl.DNASystem.Setup(steamid)

    zbl.DNAPoints[steamid].points = math.Clamp(zbl.DNAPoints[steamid].points - points, 0, 999999999)

    // Update if we should save this users data
    zbl.DNASystem.Changed(ply)

    return zbl.DNAPoints[steamid].points
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

function zbl.DNASystem.Changed(ply)
    local steamid = zclib.Player.GetID(ply)
    local _save = true
    if zbl.config.GenLab.Data.Whitelist and table.Count(zbl.config.GenLab.Data.Whitelist) > 0 and zbl.config.GenLab.Data.Whitelist[zclib.Player.GetRank(ply)] == nil then
        _save = false
    end

    zbl.DNASystem.Setup(steamid)

    zbl.DNAPoints[steamid].save = _save

    zbl.DNASystem.Update(ply)

    zclib.Debug(zbl.DNAPoints)
end

// Informs the player what his dna count is atm
util.AddNetworkString("zbl_DNASystem_Update")
function zbl.DNASystem.Update(ply)
    zclib.Debug("zbl.DNASystem.UpdateClients")

    net.Start("zbl_DNASystem_Update")
    net.WriteUInt(zbl.DNASystem.Get(ply),32)
    net.Send(ply)
end

function zbl.DNASystem.PlayerDisconnect(steamid)
    zclib.Debug("zbl.DNASystem.PlayerDisconnect")
    if zbl.DNAPoints[steamid] and zbl.DNAPoints[steamid].save == true then zbl.DNASystem.Save(steamid) end
    zbl.DNAPoints[steamid] = nil
end

function zbl.DNASystem.PlayerChangedJob(steamid)
    zclib.Debug("zbl.DNASystem.PlayerChangedJob")
    if zbl.DNAPoints[steamid] and zbl.DNAPoints[steamid].save == true then zbl.DNASystem.Save(steamid) end
    zbl.DNAPoints[steamid] = nil
end

function zbl.DNASystem.Save(steamid)
    if zbl.config.GenLab.Data.Save == false then return end
    if zbl.DNAPoints[steamid] == nil then return end
    if zbl.DNAPoints[steamid].save == false then return end

    local data = {
        Points = zbl.DNAPoints[steamid].points
    }
    local str = string.Replace(steamid,":","_")
    if data and data.Points and data.Points > 0 then
        file.Write("zbl/data/" .. tostring(str) .. ".txt", util.TableToJSON(data))
    else
        file.Delete("zbl/data/" .. tostring(str) .. ".txt")
    end
    zclib.Debug("zbl.DNASystem.Save")
end

function zbl.DNASystem.SaveAll()
    for k, v in pairs(zbl.DNAPoints) do
        zbl.DNASystem.Save(k)
    end
end

function zbl.DNASystem.AutoSave()
    if zbl.config.GenLab.Data.Save == false then return end
    if zbl.config.GenLab.Data.Save_Interval == -1 then return end
    zclib.Timer.Remove("zbl_DNAPoints_Autosave")
    zclib.Timer.Create("zbl_DNAPoints_Autosave", zbl.config.GenLab.Data.Save_Interval, 1, zbl.DNASystem.SaveAll)
end

zclib.Hook.Add("ShutDown", "zbl_ShutDown", function()
    zbl.DNASystem.SaveAll()
end)


timer.Simple(0,function() zbl.DNASystem.AutoSave() end)
////////////////////////////////////////////
////////////////////////////////////////////
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
