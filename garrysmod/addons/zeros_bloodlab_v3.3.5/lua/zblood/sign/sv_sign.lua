/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.Sign = zbl.Sign or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

////////////////////////////////////////////
///////// Virus Statistics Sign  ///////////
////////////////////////////////////////////

// This system keeps track on how many players / objects got infected by which virus
// and displays it on the info signs

// Here we store how many objects/players are currently infected by which virus
zbl.VirusStatistics = zbl.VirusStatistics or {}

/*
    Stat Types:
        1 = Player
        2 = Object
        3 = VirusNode
        4 = Corpse
*/
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

local function AddStatistic(Virus_ID,_type)
    if zbl.Vaccine.GetData(Virus_ID) == nil then return end

    if zbl.VirusStatistics[Virus_ID] == nil then
        zbl.VirusStatistics[Virus_ID] = {}
    end

    if zbl.VirusStatistics[Virus_ID][_type] == nil then
        zbl.VirusStatistics[Virus_ID][_type] = 0
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

    zbl.VirusStatistics[Virus_ID][_type] = zbl.VirusStatistics[Virus_ID][_type] + 1
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

local function UpdateStatistic()
    zbl.VirusStatistics = {}

    for k, v in pairs(zbl.Vaccine.GetAll()) do
        if zbl.Vaccine.IsVirus(k) then
            zbl.VirusStatistics[k] = {}

            for i = 1, 4 do
                if zbl.VirusStatistics[k][i] == nil then
                    zbl.VirusStatistics[k][i] = 0
                end
            end
        end
    end

    // Players
    for k,v in pairs(zclib.Player.List) do
        if IsValid(v) then
            local vacID = zbl.Vaccine.Get(v)
            if zbl.Vaccine.IsVirus(vacID) then
                AddStatistic(vacID,1)
            end
        end
    end

    // Objects
    for k, v in pairs(zbl.ContaminatedObjects) do
        if IsValid(v) then
            local vacID = zbl.Vaccine.Get(v)
            if zbl.Vaccine.IsVirus(vacID) then
                AddStatistic(vacID, 2)
            end
        end
    end

    for k, v in pairs(zbl.Node.List) do
        if IsValid(v) then
            local vacID = v.Virus_ID

            if zbl.Vaccine.IsVirus(vacID) then
                AddStatistic(vacID, 3)
            end
        end
    end

    for k, v in pairs(zbl.Corpse.List) do
        if IsValid(v) then
            local vacID = zbl.Vaccine.Get(v)

            if zbl.Vaccine.IsVirus(vacID) then
                AddStatistic(vacID, 4)
            end
        end
    end

    // Send players the updated Statistics
    zbl.Sign.UpdateClients()
end

zclib.Timer.Create("zbl_VSS_Update_Timer",zbl.config.Sign.UpdateInterval,0,function() UpdateStatistic() end)


function zbl.Sign.Reset(_type)

    for k, v in pairs(zbl.VirusStatistics) do
        if v and v[_type] and v[_type] > 0 then
            v[_type] = 0
        end
    end

    // Send players the updated Statistics
    zbl.Sign.UpdateClients()
end

zclib.Hook.Add("PostCleanupMap", "a_zbl_VSS_Reset_PostCleanupMap", function()
    zbl.Sign.Reset(2)
    zbl.Sign.Reset(3)
    zbl.Sign.Reset(4)
end)

util.AddNetworkString("zbl_VirusStatistic_Update")
function zbl.Sign.UpdateClients()

    local dataString = util.TableToJSON(zbl.VirusStatistics)
    local dataCompressed = util.Compress(dataString)

    net.Start("zbl_VirusStatistic_Update")
    net.WriteUInt(#dataCompressed, 16)
    net.WriteData(dataCompressed, #dataCompressed)
    net.Broadcast()
end

function zbl.Sign.UpdateClient(ply)
    if not IsValid(ply) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

    local dataString = util.TableToJSON(zbl.VirusStatistics)
    local dataCompressed = util.Compress(dataString)

    net.Start("zbl_VirusStatistic_Update")
    net.WriteUInt(#dataCompressed, 16)
    net.WriteData(dataCompressed, #dataCompressed)
    net.Send(ply)
end




file.CreateDir("zbl")
zclib.STM.Setup("zbl_sign", "zbl/" .. string.lower(game.GetMap()) .. "_sign" .. ".txt", function()
    local data = {}
    for u, j in pairs(ents.FindByClass("zbl_sign")) do
        if IsValid(j) then
            table.insert(data, {
                pos = j:GetPos(),
                ang = j:GetAngles()
            })
        end
    end
    return data
end, function(data)
    for k, v in pairs(data) do
        local ent = ents.Create("zbl_sign")
        ent:SetPos(v.pos)
        ent:SetAngles(v.ang)
        ent:Spawn()
        ent:Activate()

        local phys = ent:GetPhysicsObject()

        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(false)
        end
    end
    zbl.Print("Finished loading Info Sign Entities!")
end, function()
    for k, v in pairs(ents.FindByClass("zbl_sign")) do
        if IsValid(v) then
            v:Remove()
        end
    end
end)

function zbl.Sign.Save(ply)
    zclib.Notify(ply, "Info Signs have been saved for the map " .. string.lower(game.GetMap()) .. "!", 0)
    zclib.STM.Save("zbl_sign")
end

function zbl.Sign.Remove(ply)
    zclib.Notify(ply, "Info Signs have been removed for the map " .. string.lower(game.GetMap()) .. "!", 0)
    zclib.STM.Remove("zbl_sign")
end

concommand.Add( "zbl_sign_save", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        zbl.Sign.Save(ply)
    end
end )

concommand.Add( "zbl_sign_remove", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        zbl.Sign.Remove(ply)
    end
end )
