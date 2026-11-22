/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

zbl = zbl or {}
zbl.Lab = zbl.Lab or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

// Called when the player joins the server
function zbl.Lab.CanInteract(Lab,ply)
    return zclib.Player.IsOwner(ply, Lab) or Lab:GetIsPublicEntity()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

function zbl.Lab.GetTimeModify(ply)
    local t_mod = zbl.config.GenLab.time_modify[zclib.Player.GetRank(ply)]
    if t_mod == nil then t_mod = zbl.config.GenLab.time_modify["default"] end
    return t_mod
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
