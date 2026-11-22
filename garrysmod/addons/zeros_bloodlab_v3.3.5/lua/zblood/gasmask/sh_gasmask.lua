/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

zbl = zbl or {}
zbl.GasMask = zbl.GasMask or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

// Returns the amount of uses this maskid can be used
function zbl.GasMask.GetMaxUses(maskID)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

    local uses = zbl.config.Respirator.Uses
    if zbl.config.Respirator.styles[maskID] and zbl.config.Respirator.styles[maskID].use then
        uses = zbl.config.Respirator.styles[maskID].use
    end
    return uses
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

function zbl.GasMask.GetUses(ply)
    return ply:GetNWInt("zbl_RespiratorUses", 0)
end

function zbl.GasMask.Has(ply)
    return zbl.GasMask.GetUses(ply) > 0
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c
