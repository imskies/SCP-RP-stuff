local plyMeta = FindMetaTable("Player")
local GM = GM or GAMEMODE 
-----------------------------------------------------------
-- Job commands --
-----------------------------------------------------------
local function declareTeamCommands(CTeam)
    local k = 0
    for num, v in ipairs(RPExtraTeams) do
        if v.command == CTeam.command then
            k = num
        end
    end

    local ran = false
    local chatcommandCondition = function(ply)
        ply:ChatPrint("hi")
        local plyTeam = ply:Team()

        if plyTeam == k then return false end
        if CTeam.admin == 1 and not ply:IsAdmin() or CTeam.admin == 2 and not ply:IsSuperAdmin() then return false end
        if isnumber(CTeam.NeedToChangeFrom) and plyTeam ~= CTeam.NeedToChangeFrom then return false end
        if istable(CTeam.NeedToChangeFrom) and not table.HasValue(CTeam.NeedToChangeFrom, plyTeam) then return false end
        if CTeam.customCheck and CTeam.customCheck(ply) == false then return false end
        if ply:isArrested() then return false end
        local numPlayers = team.NumPlayers(k)
        if CTeam.max ~= 0 and ((CTeam.max % 1 == 0 and numPlayers >= CTeam.max) or (CTeam.max % 1 ~= 0 and (numPlayers + 1) / player.GetCount() > CTeam.max)) then return false end
        if ply.LastJob and 10 - (CurTime() - ply.LastJob) >= 0 then return false end
        if ply.LastVoteCop and CurTime() - ply.LastVoteCop < 80 then return false end

        return true
    end

    if CTeam.vote or CTeam.RequiresVote then
        DarkRP.declareChatCommand{
            command = "vote" .. CTeam.command,
            description = "Vote to become " .. CTeam.name .. ".",
            delay = 1.5,
            condition =
                function(ply)
                    if CTeam.RequiresVote and not CTeam.RequiresVote(ply, k) then return false end
                    if CTeam.canStartVote and not CTeam.canStartVote(ply) then return false end

                    return chatcommandCondition(ply)
                end
        }

        DarkRP.declareChatCommand{
            command = CTeam.command,
            description = "Become " .. CTeam.name .. " and skip the vote.",
            delay = 1.5,
            condition =
                function(ply)
                    local requiresVote = CTeam.RequiresVote and CTeam.RequiresVote(ply, k)

                    if requiresVote then return false end
                    if requiresVote ~= false and CTeam.admin == 0 and not ply:IsAdmin() or CTeam.admin == 1 and not ply:IsSuperAdmin() then return false end
                    if CTeam.canStartVote and not CTeam.canStartVote(ply) then return false end

                    return chatcommandCondition(ply)
                end
        }
    else
        DarkRP.declareChatCommand{
            command = CTeam.command,
            description = "Become " .. CTeam.name .. ".",
            delay = 1.5,
            condition = chatcommandCondition
        }
    end
end

function addTeamCommands(CTeam, max)
    if CLIENT then return end

    local k = 0
    for num, v in ipairs(RPExtraTeams) do
        if v.command == CTeam.command then
            k = num
        end
    end

    if CTeam.vote or CTeam.RequiresVote then
        DarkRP.defineChatCommand("vote" .. CTeam.command, function(ply)
            if CTeam.RequiresVote and not CTeam.RequiresVote(ply, k) then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("job_doesnt_require_vote_currently"))

                return ""
            end

            if CTeam.canStartVote and not CTeam.canStartVote(ply) then
                local reason = isfunction(CTeam.canStartVoteReason) and CTeam.canStartVoteReason(ply, CTeam) or CTeam.canStartVoteReason or ""
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/vote" .. CTeam.command, reason))

                return ""
            end

            if CTeam.admin == 1 and not ply:IsAdmin() then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_admin", "/" .. "vote" .. CTeam.command))

                return ""
            elseif CTeam.admin > 1 and not ply:IsSuperAdmin() then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_sadmin", "/" .. "vote" .. CTeam.command))

                return ""
            end

            if isnumber(CTeam.NeedToChangeFrom) and ply:Team() ~= CTeam.NeedToChangeFrom then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_to_be_before", team.GetName(CTeam.NeedToChangeFrom), CTeam.name))

                return ""
            elseif istable(CTeam.NeedToChangeFrom) and not table.HasValue(CTeam.NeedToChangeFrom, ply:Team()) then
                local teamnames = ""

                for _, b in pairs(CTeam.NeedToChangeFrom) do
                    teamnames = teamnames .. " or " .. team.GetName(b)
                end

                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_to_be_before", string.sub(teamnames, 5), CTeam.name))

                return ""
            end

            if CTeam.customCheck and not CTeam.customCheck(ply) then
                local message = isfunction(CTeam.CustomCheckFailMsg) and CTeam.CustomCheckFailMsg(ply, CTeam) or CTeam.CustomCheckFailMsg or DarkRP.getPhrase("unable", team.GetName(t), "")
                DarkRP.notify(ply, 1, 4, message)

                return ""
            end

            local allowed, time = ply:changeAllowed(k)
            if not allowed then
                local notif = time and DarkRP.getPhrase("have_to_wait", math.ceil(time), "/job, " .. DarkRP.getPhrase("banned_or_demoted")) or DarkRP.getPhrase("unable", team.GetName(k), DarkRP.getPhrase("banned_or_demoted"))
                DarkRP.notify(ply, 1, 4, notif)

                return ""
            end

            if ply:Team() == k then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", CTeam.command, ""))

                return ""
            end

            local numPlayers = team.NumPlayers(k)
            if max ~= 0 and ((max % 1 == 0 and numPlayers >= max) or (max % 1 ~= 0 and (tnumPlayers + 1) / player.GetCount() > max)) then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("team_limit_reached", CTeam.name))

                return ""
            end

            if ply.LastJob and 10 - (CurTime() - ply.LastJob) >= 0 then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(10 - (CurTime() - ply.LastJob)), GAMEMODE.Config.chatCommandPrefix .. CTeam.command))

                return ""
            end

            ply.LastVoteCop = ply.LastVoteCop or -80

            if CurTime() - ply.LastVoteCop < 80 then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), GAMEMODE.Config.chatCommandPrefix .. CTeam.command))

                return ""
            end

            DarkRP.createVote(DarkRP.getPhrase("wants_to_be", ply:Nick(), CTeam.name), "job", ply, 20, function(vote, choice)
                local target = vote.target
                if not IsValid(target) then return end

                if choice >= 0 then
                    target:changeTeam(k)
                else
                    DarkRP.notifyAll(1, 4, DarkRP.getPhrase("has_not_been_made_team", target:Nick(), CTeam.name))
                end
            end, nil, nil, {
                targetTeam = k
            })

            ply.LastVoteCop = CurTime()

            return ""
        end)

        local function onJobCommand(ply, hasPriv)
            if hasPriv then
                ply:changeTeam(k)
                return
            end

            local a = CTeam.admin
            if a > 0 and not ply:IsAdmin()
            or a > 1 and not ply:IsSuperAdmin()
            then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_admin", CTeam.name))
                return
            end

            if not CTeam.RequiresVote and
                (a == 0 and not ply:IsAdmin()
                or a == 1 and not ply:IsSuperAdmin()
                or a == 2)
            or CTeam.RequiresVote and CTeam.RequiresVote(ply, k)
            then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_to_make_vote", CTeam.name))
                return
            end

            ply:changeTeam(k)
        end
        DarkRP.defineChatCommand(CTeam.command, function(ply)
            CAMI.PlayerHasAccess(ply, "DarkRP_GetJob_" .. CTeam.command, fp{onJobCommand, ply})

            return ""
        end)
    else
        DarkRP.defineChatCommand(CTeam.command, function(ply)
            if CTeam.admin == 1 and not ply:IsAdmin() then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_admin", "/" .. CTeam.command))

                return ""
            end

            if CTeam.admin > 1 and not ply:IsSuperAdmin() then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_sadmin", "/" .. CTeam.command))

                return ""
            end

            ply:changeTeam(k)

            return ""
        end)
    end

    concommand.Add("rp_" .. CTeam.command, function(ply, cmd, args)
        if ply:EntIndex() ~= 0 and not ply:IsAdmin() then
            ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_admin", cmd))
            return
        end

        if CTeam.admin > 1 and not ply:IsSuperAdmin() and ply:EntIndex() ~= 0 then
            ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_sadmin", cmd))
            return
        end

        if CTeam.vote then
            if CTeam.admin >= 1 and ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
                ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_sadmin", cmd))
                return
            elseif CTeam.admin > 1 and ply:IsSuperAdmin() and ply:EntIndex() ~= 0 then
                ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_to_make_vote", CTeam.name))
                return
            end
        end

        if not args or not args[1] then
            DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
            return
        end

        local target = DarkRP.findPlayer(args[1])

        if not target then
            DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("could_not_find", tostring(args[1])))
            return
        end

        target:changeTeam(k, true)
        local nick
        if (ply:EntIndex() ~= 0) then
            nick = ply:Nick()
        else
            nick = "Console"
        end
        DarkRP.notify(target, 0, 4, DarkRP.getPhrase("x_made_you_a_y", nick, CTeam.name))
    end)
end

local function addEntityCommands(tblEnt)
    DarkRP.declareChatCommand{
        command = tblEnt.cmd,
        description = "Purchase a " .. tblEnt.name,
        delay = tblEnt.delay or 2,
        condition =
            function(ply)
                if not tblEnt.allowPurchaseWhileDead and not ply:Alive() then return false end
                if ply:isArrested() then return false end
                if istable(tblEnt.allowed) and not table.HasValue(tblEnt.allowed, ply:Team()) then return false end
                if not ply:canAfford(tblEnt.price) then return false end
                if tblEnt.customCheck and tblEnt.customCheck(ply) == false then return false end

                return true
            end
    }

    if CLIENT then return end

    -- Default spawning function of an entity
    -- used if tblEnt.spawn is not defined
    local function defaultSpawn(ply, tr, tblE)
        local ent = ents.Create(tblE.ent)

        if not ent:IsValid() then error("Entity '" .. tblE.ent .. "' does not exist or is not valid.") end
        if ent.Setowning_ent then ent:Setowning_ent(ply) end

        ent:SetPos(tr.HitPos)
        -- These must be set before :Spawn()
        ent.SID = ply.SID
        ent.allowed = tblE.allowed
        ent.DarkRPItem = tblE
        ent:Spawn()
        ent:Activate()

        DarkRP.placeEntity(ent, tr, ply)

        local phys = ent:GetPhysicsObject()
        if phys:IsValid() then phys:Wake() end

        return ent
    end

    local function buythis(ply, args)
        if ply:isArrested() then return "" end
        if not tblEnt.allowPurchaseWhileDead and not ply:Alive() then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_alive_to_do_x", DarkRP.getPhrase("buy_x", tblEnt.name)))
            return ""
        end
        if istable(tblEnt.allowed) and not table.HasValue(tblEnt.allowed, ply:Team()) then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", tblEnt.name))
            return ""
        end

        if tblEnt.customCheck and not tblEnt.customCheck(ply) then
            local message = isfunction(tblEnt.CustomCheckFailMsg) and tblEnt.CustomCheckFailMsg(ply, tblEnt) or
                tblEnt.CustomCheckFailMsg or
                DarkRP.getPhrase("not_allowed_to_purchase")
            DarkRP.notify(ply, 1, 4, message)
            return ""
        end

        if ply:customEntityLimitReached(tblEnt) then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("limit", tblEnt.name))
            return ""
        end

        local canbuy, suppress, message, price = hook.Call("canBuyCustomEntity", nil, ply, tblEnt)

        local cost = price or tblEnt.getPrice and tblEnt.getPrice(ply, tblEnt.price) or tblEnt.price

        if not ply:canAfford(cost) then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", tblEnt.name))
            return ""
        end

        if canbuy == false then
            if not suppress and message then DarkRP.notify(ply, 1, 4, message) end
            return ""
        end

        ply:addMoney(-cost)

        local trace = {}
        trace.start = ply:EyePos()
        trace.endpos = trace.start + ply:GetAimVector() * 85
        trace.filter = ply

        local tr = util.TraceLine(trace)

        local ent = (tblEnt.spawn or defaultSpawn)(ply, tr, tblEnt)
        ent.onlyremover = not tblEnt.allowTools
        -- Repeat these properties to alleviate work in tblEnt.spawn:
        ent.SID = ply.SID
        ent.allowed = tblEnt.allowed
        ent.DarkRPItem = tblEnt

        hook.Call("playerBoughtCustomEntity", nil, ply, tblEnt, ent, cost)

        if cost == 0 then
            DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_got_yourself", tblEnt.name))
        else
            DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought", tblEnt.name, DarkRP.formatMoney(cost), ""))
        end

        ply:addCustomEntity(tblEnt)
        return ""
    end
    DarkRP.defineChatCommand(tblEnt.cmd, buythis)
end

local jobByCmd = {}

function DCONFIG2.getJobsByCommands()
    return jobByCmd
end

DarkRP.getJobByCommand = function(cmd)
    if not jobByCmd[cmd] then return nil, nil end
    return RPExtraTeams[jobByCmd[cmd]], jobByCmd[cmd]
end
plyMeta.getJobTable = function(ply)
    local tbl = RPExtraTeams[ply:Team()]
    -- don't error when the player has not fully joined yet
    if not tbl and (ply.DarkRPInitialised or ply.DarkRPDataRetrievalFailed) then
        DarkRP.error(
            string.format("There is a player with an invalid team!\n\nThe player's name is %s, their team number is \"%s\", which has the name \"%s\"",
                ply:EntIndex() == 0 and "Console" or IsValid(ply) and ply:Nick() or "unknown",
                ply:Team(),
                team.GetName(ply:Team())),
            1,
            {
                "It is the server owner's responsibility to figure out why that player has no valid team.",
                "This error is very likely to be caused by an earlier error. If you don't see any errors in your own console, look at the server console."
            }
        )
    end
    return tbl
end

function DarkRP.createJobDConfig(Name, CustomTeam)
    
    if not CustomTeam.teamKey then
        CustomTeam.teamKey = #RPExtraTeams + 1
    end 
    CustomTeam.name = Name
    CustomTeam.default = DarkRP.DARKRP_LOADING

    -- Disabled job
    if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["jobs"][CustomTeam.command] then return end

    local valid, err, hints = DarkRP.validateJob(CustomTeam)
    if not valid then DarkRP.error(string.format("Corrupt team: %s!\n%s", CustomTeam.name or "", err), 2, hints) end

    CustomTeam.team = CustomTeam.teamKey

    CustomTeam.salary = math.floor(CustomTeam.salary)

    CustomTeam.customCheck           = CustomTeam.customCheck           and fp{DarkRP.simplerrRun, CustomTeam.customCheck}
    CustomTeam.CustomCheckFailMsg = isfunction(CustomTeam.CustomCheckFailMsg) and fp{DarkRP.simplerrRun, CustomTeam.CustomCheckFailMsg} or CustomTeam.CustomCheckFailMsg
    CustomTeam.CanPlayerSuicide      = CustomTeam.CanPlayerSuicide      and fp{DarkRP.simplerrRun, CustomTeam.CanPlayerSuicide}
    CustomTeam.PlayerCanPickupWeapon = CustomTeam.PlayerCanPickupWeapon and fp{DarkRP.simplerrRun, CustomTeam.PlayerCanPickupWeapon}
    CustomTeam.PlayerDeath           = CustomTeam.PlayerDeath           and fp{DarkRP.simplerrRun, CustomTeam.PlayerDeath}
    CustomTeam.PlayerLoadout         = CustomTeam.PlayerLoadout         and fp{DarkRP.simplerrRun, CustomTeam.PlayerLoadout}
    CustomTeam.PlayerSelectSpawn     = CustomTeam.PlayerSelectSpawn     and fp{DarkRP.simplerrRun, CustomTeam.PlayerSelectSpawn}
    CustomTeam.PlayerSetModel        = CustomTeam.PlayerSetModel        and fp{DarkRP.simplerrRun, CustomTeam.PlayerSetModel}
    CustomTeam.PlayerSpawn           = CustomTeam.PlayerSpawn           and fp{DarkRP.simplerrRun, CustomTeam.PlayerSpawn}
    CustomTeam.PlayerSpawnProp       = CustomTeam.PlayerSpawnProp       and fp{DarkRP.simplerrRun, CustomTeam.PlayerSpawnProp}
    CustomTeam.RequiresVote          = CustomTeam.RequiresVote          and fp{DarkRP.simplerrRun, CustomTeam.RequiresVote}
    CustomTeam.ShowSpare1            = CustomTeam.ShowSpare1            and fp{DarkRP.simplerrRun, CustomTeam.ShowSpare1}
    CustomTeam.ShowSpare2            = CustomTeam.ShowSpare2            and fp{DarkRP.simplerrRun, CustomTeam.ShowSpare2}
    CustomTeam.canStartVote          = CustomTeam.canStartVote          and fp{DarkRP.simplerrRun, CustomTeam.canStartVote}

    if not (GM or GAMEMODE):CustomObjFitsMap(CustomTeam) then return end
    
    RPExtraTeams[CustomTeam.teamKey] = CustomTeam
    jobByCmd[CustomTeam.command] = CustomTeam.teamKey
    DarkRP.addToCategory(CustomTeam, "jobs", CustomTeam.category)
    local Team = CustomTeam.teamKey
    team.SetUp(Team, Name, CustomTeam.color)

    timer.Simple(0, function()
        declareTeamCommands(CustomTeam)
        addTeamCommands(CustomTeam, CustomTeam.max)
    end)

    -- Precache model here. Not right before the job change is done
    if istable(CustomTeam.model) then
        for _, v in pairs(CustomTeam.model) do util.PrecacheModel(v) end
    else
        util.PrecacheModel(CustomTeam.model)
    end
    
    return Team
end

local function removeCustomItem(tbl, category, hookName, reloadF4, i)
    local item = tbl[i]
    tbl[i] = nil
    if category then DarkRP.removeFromCategory(item, category) end
    if istable(item) and (item.command or item.cmd) then DarkRP.removeChatCommand(item.command or item.cmd) end
    hook.Run(hookName, i, item)
    if CLIENT and reloadF4 and IsValid(DarkRP.getF4MenuPanel()) then DarkRP.getF4MenuPanel():Remove() end -- Rebuild entire F4 menu frame
end

function DarkRP.removeJob(i)
    local job = RPExtraTeams[i]
    jobByCmd[job.command] = nil

    DarkRP.removeChatCommand("vote" .. job.command)
    removeCustomItem(RPExtraTeams, "jobs", "onJobRemoved", true, i)
end

local maxTeamDoorID = 0
function DarkRP.createEntityGroup(name, ...)
    if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["doorgroups"][name] then return end
    RPExtraTeamDoors[name] = {...}
    RPExtraTeamDoors[name].name = name

    maxTeamDoorID = maxTeamDoorID + 1
    RPExtraTeamDoorIDs[name] = maxTeamDoorID
end


local shipByName = {}
DCONFIG2.getShipmentByNameBackup = DCONFIG2.getShipmentByNameBackup or DarkRP.getShipmentByName
DarkRP.getShipmentByName = function(name)
    local shipment, shipmentID = DCONFIG2.getShipmentByNameBackup(name)
    if not shipment then
        name = string.lower(name or "")

        if not shipByName[name] then return nil, nil end
        return CustomShipments[shipByName[name]], shipByName[name]
    end 
    return shipment, shipmentID
end


function DarkRP.createShipmentDConfig(customShipment)
    customShipment.shipModel = customShipment.shipModel or "models/Items/item_item_crate.mdl"
    customShipment.weight = 5

    -- The pains of backwards compatibility when dealing with ancient spelling errors...
    if customShipment.separate ~= nil then
        customShipment.seperate = customShipment.separate
    end
    customShipment.separate = customShipment.seperate

    if customShipment.allowed == nil then
        customShipment.allowed = {}
        for k in ipairs(RPExtraTeams) do
            table.insert(customShipment.allowed, k)
        end
    end

    customShipment.default = DarkRP.DARKRP_LOADING

    if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["shipments"][customShipment.name] then return end

    local valid, err, hints = DarkRP.validateShipment(customShipment)
    if not valid then DarkRP.error(string.format("Corrupt shipment: %s!\n%s", name or "", err), 2, hints) end

    customShipment.spawn = customShipment.spawn and fp{DarkRP.simplerrRun, customShipment.spawn}
    customShipment.allowed = isnumber(customShipment.allowed) and {customShipment.allowed} or customShipment.allowed
    customShipment.customCheck = customShipment.customCheck and fp{DarkRP.simplerrRun, customShipment.customCheck}
    customShipment.CustomCheckFailMsg = isfunction(customShipment.CustomCheckFailMsg) and fp{DarkRP.simplerrRun, customShipment.CustomCheckFailMsg} or customShipment.CustomCheckFailMsg

    if not customShipment.noship then DarkRP.addToCategory(customShipment, "shipments", customShipment.category) end
    if customShipment.separate then DarkRP.addToCategory(customShipment, "weapons", customShipment.category) end
	for k,v in ipairs(CustomShipments) do
        if customShipment.name == v.name then
            customShipment.inLuaFile = v.inLuaFile
            customShipment.originalName = v.originalName
			removeCustomItem(CustomShipments, "shipments", "onShipmentRemoved", true, k)
            CustomShipments[k] = customShipment
            shipByName[string.lower(customShipment.name or "")] = k
            return
		end
	end
    shipByName[string.lower(customShipment.name or "")] = table.insert(CustomShipments, customShipment)
    util.PrecacheModel(customShipment.model)
end

function DarkRP.createEntity(name, entity, model, price, max, command, classes, CustomCheck)
    local tableSyntaxUsed = istable(entity)

    local tblEnt = tableSyntaxUsed and entity or
        {ent = entity, model = model, price = price, max = max,
        cmd = command, allowed = classes, customCheck = CustomCheck}
    tblEnt.name = name
    tblEnt.default = DarkRP.DARKRP_LOADING

    if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["entities"][tblEnt.name] then return end

    if isnumber(tblEnt.allowed) then
        tblEnt.allowed = {tblEnt.allowed}
    end

    local valid, err, hints = DarkRP.validateEntity(tblEnt)
    if not valid then DarkRP.error(string.format("Corrupt entity: %s!\n%s", name or "", err), 2, hints) end

    tblEnt.customCheck = tblEnt.customCheck and fp{DarkRP.simplerrRun, tblEnt.customCheck}
    tblEnt.CustomCheckFailMsg = isfunction(tblEnt.CustomCheckFailMsg) and fp{DarkRP.simplerrRun, tblEnt.CustomCheckFailMsg} or tblEnt.CustomCheckFailMsg
    tblEnt.getPrice    = tblEnt.getPrice    and fp{DarkRP.simplerrRun, tblEnt.getPrice}
    tblEnt.getMax      = tblEnt.getMax      and fp{DarkRP.simplerrRun, tblEnt.getMax}
    tblEnt.spawn       = tblEnt.spawn       and fp{DarkRP.simplerrRun, tblEnt.spawn}

    -- if SERVER and FPP then
    --  FPP.AddDefaultBlocked(blockTypes, tblEnt.ent)
    -- end

    table.insert(DarkRPEntities, tblEnt)
    DarkRP.addToCategory(tblEnt, "entities", tblEnt.category)
    timer.Simple(0, function() addEntityCommands(tblEnt) end)
end

function DarkRP.createEntityDConfig(name, entity, model, price, max, command, classes, CustomCheck)
    local tableSyntaxUsed = istable(entity)

    local tblEnt = tableSyntaxUsed and entity or
        {ent = entity, model = model, price = price, max = max,
        cmd = command, allowed = classes, customCheck = CustomCheck}
    tblEnt.name = name
    tblEnt.default = DarkRP.DARKRP_LOADING

    if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["entities"][tblEnt.name] then return end

    if isnumber(tblEnt.allowed) then
        tblEnt.allowed = {tblEnt.allowed}
    end

    local valid, err, hints = DarkRP.validateEntity(tblEnt)
    if not valid then DarkRP.error(string.format("Corrupt entity: %s!\n%s", name or "", err), 2, hints) end

    tblEnt.customCheck = tblEnt.customCheck and fp{DarkRP.simplerrRun, tblEnt.customCheck}
    tblEnt.CustomCheckFailMsg = isfunction(tblEnt.CustomCheckFailMsg) and fp{DarkRP.simplerrRun, tblEnt.CustomCheckFailMsg} or tblEnt.CustomCheckFailMsg
    tblEnt.getPrice    = tblEnt.getPrice    and fp{DarkRP.simplerrRun, tblEnt.getPrice}
    tblEnt.getMax      = tblEnt.getMax      and fp{DarkRP.simplerrRun, tblEnt.getMax}
    tblEnt.spawn       = tblEnt.spawn       and fp{DarkRP.simplerrRun, tblEnt.spawn}

    -- if SERVER and FPP then
    --  FPP.AddDefaultBlocked(blockTypes, tblEnt.ent)
    -- end

    if tblEnt.id then
        DarkRPEntities[tblEnt.id] = tblEnt
    else
        tblEnt.id = table.insert(DarkRPEntities, tblEnt)
    end
    
    DarkRP.addToCategory(tblEnt, "entities", tblEnt.category)
    timer.Simple(0, function() addEntityCommands(tblEnt) end)
end


function DarkRP.createAmmoTypeDConfig(ammoType, name, model, price, amountGiven, customCheck)
    local gm = GM or GAMEMODE
    gm.AmmoTypes = gm.AmmoTypes or {}
    local ammo = istable(name) and name or {
        name = name,
        model = model,
        price = price,
        amountGiven = amountGiven,
        customCheck = customCheck,
    }
    ammo.ammoType = ammoType
    ammo.default = DarkRP.DARKRP_LOADING

    if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["ammo"][ammo.name] then return end

    ammo.customCheck = ammo.customCheck and fp{DarkRP.simplerrRun, ammo.customCheck}
    ammo.CustomCheckFailMsg = isfunction(ammo.CustomCheckFailMsg) and fp{DarkRP.simplerrRun, ammo.CustomCheckFailMsg} or ammo.CustomCheckFailMsg
    if ammo.id then
        gm.AmmoTypes[ammo.id] = ammo
    else
        ammo.id = table.insert(gm.AmmoTypes, ammo)
    end

    DarkRP.addToCategory(ammo, "ammo", ammo.category)
end

function DarkRP.createAmmoType(ammoType, name, model, price, amountGiven, customCheck)
    local gm = GM or GAMEMODE
    gm.AmmoTypes = gm.AmmoTypes or {}
    local ammo = istable(name) and name or {
        name = name,
        model = model,
        price = price,
        amountGiven = amountGiven,
        customCheck = customCheck
    }
    ammo.ammoType = ammoType
    ammo.default = DarkRP.DARKRP_LOADING

    if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["ammo"][ammo.name] then return end

    ammo.customCheck = ammo.customCheck and fp{DarkRP.simplerrRun, ammo.customCheck}
    ammo.CustomCheckFailMsg = isfunction(ammo.CustomCheckFailMsg) and fp{DarkRP.simplerrRun, ammo.CustomCheckFailMsg} or ammo.CustomCheckFailMsg
    ammo.id = table.insert(gm.AmmoTypes, ammo)

    DarkRP.addToCategory(ammo, "ammo", ammo.category)
end
GM.AddAmmoType = function(_, ...) DarkRP.createAmmoType(...) end

DarkRP.removeAmmoType = function(index) 
    local GM = GM or GAMEMODE
    removeCustomItem(GM.AmmoTypes, "ammo", "onAmmoTypeRemoved", true, index) 
end 

DarkRP.removeEntity = fp{removeCustomItem, DarkRPEntities, "entities", "onEntityRemoved", true}