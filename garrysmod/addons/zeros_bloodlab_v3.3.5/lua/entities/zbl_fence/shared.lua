/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_bloodlab/zbl_gate.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Electric Fence"
ENT.Category = "Zeros GenLab"
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Fence")
    self:NetworkVar("Bool", 1, "Door")
    self:NetworkVar("Entity", 0, "LeftWall")
    self:NetworkVar("Entity", 1, "RightWall")
    self:NetworkVar("Int", 1, "ScanResult")

    if (SERVER) then
        self:SetDoor(false)

        self:SetRightWall(NULL)
        self:SetLeftWall(NULL)

        self:SetFence(false)
        self:SetScanResult(-1)
    end
end

function ENT:OnDoorButton01(ply)
    local trace = ply:GetEyeTrace()

    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > -6 and lp.x < -2 and lp.y < -23 and lp.y > -29 and lp.z > 34 and lp.z < 40 then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

function ENT:OnFenceButton01(ply)
    local trace = ply:GetEyeTrace()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > -6 and lp.x < -2 and lp.y < 28 and lp.y > 23 and lp.z > 34 and lp.z < 40 then
        return true
    else
        return false
    end
end


function ENT:OnDoorButton02(ply)
    local trace = ply:GetEyeTrace()

    local lp = self:WorldToLocal(trace.HitPos)
    if lp.x < 6 and lp.x > 2 and lp.y < -23 and lp.y > -29 and lp.z > 34 and lp.z < 40 then
        return true
    else
        return false
    end
end

function ENT:OnFenceButton02(ply)
    local trace = ply:GetEyeTrace()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

    local lp = self:WorldToLocal(trace.HitPos)
    if lp.x < 6 and lp.x > 2 and lp.y < 28 and lp.y > 23 and lp.z > 34 and lp.z < 40 then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c
