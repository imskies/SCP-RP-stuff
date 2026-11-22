/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if SERVER then return end
zbl = zbl or {}
zbl.DNASystem = zbl.DNASystem or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

zbl.DNAPoints = zbl.DNAPoints or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

net.Receive("zbl_DNASystem_Update", function(len)
    local points = net.ReadUInt(32)
    if points == nil then return end

    zbl.DNASystem.Update(points)
end)

function zbl.DNASystem.Update(points)
    local steamid = zclib.Player.GetID(LocalPlayer())

    if zbl.DNAPoints[steamid] == nil then
        zbl.DNAPoints[steamid] = {}
    end

    if zbl.DNAPoints[steamid].points == nil then
        zbl.DNAPoints[steamid].points = 0
    end

    zbl.DNAPoints[steamid].points = points
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
