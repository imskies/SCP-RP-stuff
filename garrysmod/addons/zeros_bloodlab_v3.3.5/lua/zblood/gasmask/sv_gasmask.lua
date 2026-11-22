/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.GasMask = zbl.GasMask or {}

// Shows/Hides the gasmask for the specified player
util.AddNetworkString("zbl_Gasmask_Equipt")
function zbl.GasMask.Equipt(ply, show)

    local maskID = 0
    if show == true then

        if zbl.config.Respirator.random_style then
            maskID = math.random(#zbl.config.Respirator.styles)
        else
            maskID = zbl.config.Respirator.style
        end

        zbl.GasMask.Give(ply, maskID)
    else
        zbl.GasMask.Remove(ply)
    end

    zclib.Debug("zbl_Gasmask_Equipt: " .. tostring(ply) .. " " .. tostring(show) .. " MaskID: " .. maskID .. " Uses: " .. zbl.GasMask.GetUses(ply))
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

    net.Start("zbl_Gasmask_Equipt")
    net.WriteEntity(ply)
    net.WriteBool(show)
    net.WriteInt(maskID,6)
    net.Broadcast()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

function zbl.GasMask.SetUses(ply, val)
    ply:SetNWInt("zbl_RespiratorUses",val)
end


function zbl.GasMask.Give(ply, maskID)
    ply.zbl_MaskID = maskID
    zbl.GasMask.SetUses(ply, zbl.GasMask.GetMaxUses(maskID))
end

function zbl.GasMask.Remove(ply)
    ply.zbl_MaskID = 0
    zbl.GasMask.SetUses(ply, 0)
end

function zbl.GasMask.Use(ply)
    local rsp_use = zbl.GasMask.GetUses(ply)

    rsp_use = math.Clamp(rsp_use - 1, 0, zbl.GasMask.GetMaxUses(ply.zbl_MaskID))
    zclib.Debug("GasMask_Use: " .. rsp_use)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

    if rsp_use <= 0 then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

        zclib.Notify(ply, zbl.language.General["RespiratorUsedUp"], 3)

        zbl.GasMask.Equipt(ply, false)
    else
        zbl.GasMask.SetUses(ply, rsp_use)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10
