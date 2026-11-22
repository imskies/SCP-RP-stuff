/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.Fence = zbl.Fence or {}


function zbl.Fence.Initialize(Fence)
    Fence:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    Fence:SetUseType(SIMPLE_USE)
    Fence:SetTrigger(true)
    Fence:DrawShadow(false)
    local phys = Fence:GetPhysicsObject()

    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(true)
    end

    zclib.EntityTracker.Add(Fence)

	if zbl.config.Fence.health > 0 then
		Fence:SetHealth(zbl.config.Fence.health)
		Fence:SetMaxHealth(zbl.config.Fence.health)
	end
end

function zbl.Fence.OnUse(Fence,ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

    if (Fence.LastUse or 0) > CurTime() then return end

    if not zclib.Player.IsAdmin(ply) and not zclib.Player.IsOwner(ply, Fence) and not Fence.IsPublicEntity then
        zclib.Notify(ply, zbl.language.General["Wrong Owner"], 1)
        return
    end

    if zbl.config.Fence.door == true and (Fence:OnDoorButton01(ply) or (not zbl.config.Fence.onesideonly and Fence:OnDoorButton02(ply))) then
        Fence:SetDoor(not Fence:GetDoor())
        zbl.Fence.ToggleDoor(Fence)

        Fence.LastUse = CurTime() + 0.1
    end

    if zbl.config.Fence.unfold == true and (Fence:OnFenceButton01(ply) or (not zbl.config.Fence.onesideonly and Fence:OnFenceButton02(ply))) then

        if zbl.config.Fence.ranks and table.Count(zbl.config.Fence.ranks) > 0 and zbl.config.Fence.ranks[zclib.Player.GetRank(ply)] == nil then
            return
        end

        Fence:SetFence(not Fence:GetFence())
        zbl.Fence.ToggleFence(Fence)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

        Fence.LastUse = CurTime() + 1
    end
end

function zbl.Fence.Trace(Fence,left)
    local tr_start = Fence:GetPos() + Fence:GetUp() * 25
    local tr_end

    if left then
        tr_end = tr_start + Fence:GetRight() * zbl.config.Fence.length
    else
        tr_end = tr_start - Fence:GetRight() * zbl.config.Fence.length
    end

    local tr = util.TraceLine({
        start = tr_start,
        endpos = tr_end,
        filter = Fence,
        //mask = 81931
    })

    if tr.Hit and tr.HitPos then
        debugoverlay.Line(tr_start, tr.HitPos, 5, Color(0, 255, 0), true)

        return Fence:GetPos():Distance(tr.HitPos)
    else
        debugoverlay.Line(tr_start, tr_end, 5, Color(0, 255, 0), true)

        return zbl.config.Fence.length
    end
end

function zbl.Fence.ToggleFence(Fence)

    DropEntityIfHeld( Fence )

    local ang = Fence:GetAngles()
    Fence:SetAngles(Angle(0,ang.y,0))

    Fence:DropToFloor()

    if Fence:GetFence() then

        local phys = Fence:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(false)
        end

        Fence.PhysgunDisabled = true

        ang = Fence:GetAngles()

        local left_pos = (Fence:GetPos() - Fence:GetUp() * 1) + Fence:GetRight() * zbl.Fence.Trace(Fence,true)
        local left_dir =  left_pos - Fence:GetPos()
        local left_look = Angle(ang.p,left_dir:Angle().y,ang.r)
        left_look:RotateAroundAxis(left_look:Up(),-90)
        Fence.PointLeft = zbl.Fence.CreateEndPoint(Fence,left_pos,left_look,true)
        Fence:SetLeftWall(Fence.PointLeft)

        local right_pos = (Fence:GetPos() - Fence:GetUp() * 1) - Fence:GetRight() * zbl.Fence.Trace(Fence,false)
        local right_dir =  right_pos - Fence:GetPos()
        local right_look = Angle(ang.p,right_dir:Angle().y,ang.r)
        right_look:RotateAroundAxis(right_look:Up(),-90)
        Fence.PointRight = zbl.Fence.CreateEndPoint(Fence,right_pos,right_look,false)
        Fence:SetRightWall(Fence.PointRight)
    else

        local phys = Fence:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(true)
        end

        Fence.PhysgunDisabled = false

        if IsValid(Fence.PointRight) then
            SafeRemoveEntity(Fence.PointRight)
        end

        if IsValid(Fence.PointLeft) then
            SafeRemoveEntity(Fence.PointLeft)
        end
    end
end

function zbl.Fence.SetFence(Fence,l_pos,l_ang,r_pos,r_ang)
    Fence.PointLeft = zbl.Fence.CreateEndPoint(Fence,l_pos,l_ang,true)
    Fence:SetLeftWall(Fence.PointLeft)

    Fence.PointRight = zbl.Fence.CreateEndPoint(Fence,r_pos,r_ang,false)
    Fence:SetRightWall(Fence.PointRight)
end

function zbl.Fence.ToggleDoor(Fence)

    //Fence:EmitSound("zbl_fence_stop")

	if Fence:GetDoor() then
		Fence:SetCollisionGroup(COLLISION_GROUP_NONE)
		Fence:SetTrigger(false)
		Fence:EmitSound("npc/roller/code2.wav")
	else
		Fence:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		Fence:SetTrigger(true)
		Fence:EmitSound("npc/roller/mine/rmine_blip1.wav")
	end
end

function zbl.Fence.CreateEndPoint(Fence, pos, ang, isleft)
    local ent = ents.Create("zbl_fence_end")

    ent:SetPos(pos)
    ent:SetAngles(ang)
    ent:SetMain(Fence)
    ent:SetIsLeft(isleft)
    ent:Spawn()
    ent:Activate()
    Fence:DeleteOnRemove(ent)
    ent:SetParent(Fence)
    return ent
end

function zbl.Fence.OnDamage(Fence, dmginfo)
    local damage = dmginfo:GetDamage()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

    if zbl.config.Fence.health > 0 then

		Fence:SetHealth(Fence:Health() - damage)

		Fence:SetColor(zbl.Fence.GetHealthColor(Fence))

        if Fence:Health() <= 0 then

            if IsValid(Fence:GetLeftWall()) then
                zclib.Effect.Generic("HelicopterMegaBomb",Fence:GetLeftWall():GetPos())
            end

            if IsValid(Fence:GetRightWall()) then
                zclib.Effect.Generic("HelicopterMegaBomb",Fence:GetRightWall():GetPos())
            end

            zclib.Effect.Generic("HelicopterMegaBomb",Fence:GetPos())

            SafeRemoveEntity(Fence)
        end
    end
end

function zbl.Fence.OnRemove(Fence)
end


function zbl.Fence.SpamCheck(Fence,other)
    if other.zbl_LastFenceScan and other.zbl_LastFenceScan < CurTime() then
        other.zbl_LastScanCount = 0
    end

    other.zbl_LastScanCount = (other.zbl_LastScanCount or 0) + 1
    other.zbl_LastFenceScan = CurTime() + 10

    // Does the player spamm this machine
    if other.zbl_LastScanCount and other.zbl_LastScanCount >= 6 then

        // Punish
        other.zbl_LastScanCount = 0

        return true
    else
        return false
    end
end

function zbl.Fence.ShockPlayer(Fence,ply)
    local d = DamageInfo()
    d:SetDamage(zbl.config.Fence.dmg_per_touch)
    d:SetAttacker(Fence)
    d:SetDamageForce(ply:GetPos() + ply:GetUp() * 15)
    d:SetDamagePosition(ply:GetPos() + Vector(0,0,50))
    d:SetDamageType(DMG_SHOCK)
    ply:TakeDamageInfo(d)

    zclib.NetEvent.Create("zbl_player_shock", {ply})
end

function zbl.Fence.OnStartTouch(Fence, other)
    if Fence:GetDoor() == true then return end
    if Fence:GetScanResult() ~= -1 then return end
    if not IsValid(other) then return end
    if not other:IsPlayer() then return end
    if not other:Alive() then return end

    if zbl.config.Fence.AntiSpam == true and zbl.Fence.SpamCheck(Fence, other) then
        Fence:EmitSound("zbl_gate_punish")
        Fence:SetScanResult(3)

        timer.Simple(2, function()
            if IsValid(other) and other:Alive() and IsValid(Fence) then
                Fence:EmitSound("zbl_gate_cauterize")

                timer.Simple(1, function()
                    if IsValid(other) and other:Alive() and IsValid(Fence) then
                        zbl.Fence.ShockPlayer(Fence, other)

                        local effectdata = EffectData()
                        effectdata:SetOrigin(Fence:GetPos() + Vector(0, 0, 50))
                        effectdata:SetMagnitude(100)
                        effectdata:SetStart(other:GetPos() + Vector(0, 0, 50))
                        effectdata:SetScale(25)
                        effectdata:SetRadius(100)
                        util.Effect("tooltracer", effectdata)

                        Fence:SetScanResult(-1)
                    elseif IsValid(Fence) then
                        Fence:SetScanResult(-1)
                    end
                end)
            elseif IsValid(Fence) then
                Fence:SetScanResult(-1)
            end
        end)
    else
        if zbl.config.Fence.contaminate == true and zbl.Occopation.IsContaminated(other) then

            zbl.Player.ForceCure(other)
            zclib.NetEvent.Create("zbl_fence_disinfect", {Fence})
            Fence:SetScanResult(2)

            timer.Simple(0.35, function()
                if IsValid(Fence) then
                    Fence:EmitSound("zbl_gate_sterilize")
                end
            end)
        else
            if zbl.Player.IsInfected(other) then
                Fence:EmitSound("zbl_gate_scan_bad")

                timer.Simple(0.35, function()
                    if IsValid(Fence) then
                        Fence:EmitSound("zbl_gate_scan_infection")
                    end
                end)

                Fence:SetScanResult(0)
            else
                Fence:EmitSound("zbl_gate_scan_good")
                Fence:SetScanResult(1)
            end
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

        hook.Run("zbl_OnPlayerFenceScanned", other, Fence)

        timer.Simple(1, function()
            if IsValid(Fence) then
                Fence:SetScanResult(-1)
            end
        end)
    end
end




file.CreateDir("zbl")
zclib.STM.Setup("zbl_fence", "zbl/" .. string.lower(game.GetMap()) .. "_fence" .. ".txt", function()
    local data = {}
    for u, j in pairs(ents.FindByClass("zbl_fence")) do
        if IsValid(j) and j:GetFence() then

            local f_data = {
                pos = j:GetPos(),
                ang = j:GetAngles(),
                open = j:GetDoor()
            }

            local l_wall = j:GetLeftWall()
            if IsValid(l_wall) then
                f_data.l_pos = l_wall:GetPos()
                f_data.l_ang = l_wall:GetAngles()
            end

            local r_wall = j:GetRightWall()
            if IsValid(r_wall) then
                f_data.r_pos = r_wall:GetPos()
                f_data.r_ang = r_wall:GetAngles()
            end

            table.insert(data, f_data)
        end
    end
    return data
end, function(data)
    for k, v in pairs(data) do
        local ent = ents.Create("zbl_fence")
        ent:SetPos(v.pos)
        ent:SetAngles(v.ang)
        ent:Spawn()
        ent:Activate()

        ent:SetFence(true)
        ent:SetDoor(v.open)
        ent.PhysgunDisabled = true

        ent.IsPublicEntity = true

        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(false)
        end

        zbl.Fence.SetFence(ent,v.l_pos,v.l_ang,v.r_pos,v.r_ang)

        //zbl.Fence.ToggleFence(ent)
        zbl.Fence.ToggleDoor(ent)
    end
    zbl.Print("Finished loading Fence Entities!")
end, function()
    for k, v in pairs(ents.FindByClass("zbl_fence")) do
        if IsValid(v) then
            v:Remove()
        end
    end
end)

// Save functions
concommand.Add( "zbl_fence_save", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        zbl.Fence.Save()
    end
end )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

concommand.Add( "zbl_fence_remove", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        zbl.Fence.Remove()
    end
end )

function zbl.Fence.Save(ply)
    zclib.STM.Save("zbl_fence")
    zclib.Notify(ply, "Fence entities have been saved for the map " .. string.lower(game.GetMap()) .. "!", 0)
end

function zbl.Fence.Remove(ply)
    zclib.STM.Remove("zbl_fence")
    zclib.Notify(ply, "Fence entities have been removed for the map " .. string.lower(game.GetMap()) .. "!", 0)
end









//zbl.config.Fence.Police

////////////////////////////////////////////
/////////// Lockpick Feature ///////////////
////////////////////////////////////////////
local function GetPolice()
    local police = {}
    for k, v in pairs(zclib.Player.List) do
        if IsValid(v) and v:IsPlayer() and v:Alive() and zbl.config.Fence.LockPick.Police[zclib.Player.GetJob(v)] then
            table.insert(police,v)
        end
    end
    return police
end
local function HasPolice()
    if table.Count(zbl.config.Fence.LockPick.Police) > 0 then
        return table.Count(GetPolice()) > 0
    else
        return true
    end
end
local function CanLockPick(ent)
    if zbl.config.Fence.LockPick.Enabled == false then return false end
    if ent:GetDoor() == false and ent:GetFence() == false then return false end
    if HasPolice() == false then return false end

    return true
end
hook.Add("canLockpick", "a_zbl_canLockpick", function(ply, ent)
    if IsValid(ent) and ent:GetClass() == "zbl_fence" and IsValid(ply) and ply:IsPlayer() and ply:Alive() then return CanLockPick(ent) end
end)

hook.Add("lockpickTime", "a_zbl_lockpickTime", function(ply, ent)
    if (IsValid(ent) and ent:GetClass() == "zbl_fence" and IsValid(ply) and ply:IsPlayer()) then return zbl.config.Fence.LockPick.Time end
end)

function zbl.Fence.LockPicked(Fence, ply)

    if zbl.config.Fence.LockPick.OnSuccess.Door then
        Fence:SetDoor(false)
        zbl.Fence.ToggleDoor(Fence)
    end

    if zbl.config.Fence.LockPick.OnSuccess.Fence then
        Fence:SetFence(false)
        zbl.Fence.ToggleFence(Fence)
    end

    Fence:EmitSound("zbl_fence_zap")

    zclib.Effect.Generic("ManhackSparks",Fence:GetPos() + Fence:GetUp() * 75)
end

hook.Add("onLockpickCompleted", "a_zbl_onLockpickCompleted", function(ply, success, ent)
    if IsValid(ent) and ent:GetClass() == "zbl_fence" and ply:IsPlayer() and CanLockPick(ent) and success then
        zbl.Fence.LockPicked(ent, ply)

        for k, v in pairs(GetPolice()) do
            if IsValid(v) and v:IsPlayer() and v:Alive() then
                ply:wanted(v, zbl.config.Fence.LockPick.Wanted_Message, zbl.config.Fence.LockPick.Wanted_Time)
            end
        end
    end
end)
////////////////////////////////////////////
////////////////////////////////////////////
