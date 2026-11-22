/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.NPC = zbl.NPC or {}

/*
    The player can sell Virus/Cures to the NPC

    You can also request a job from the NPC like
        getting a specific players blood sample (time limit)
        infecting a player with a virus you need to make (time limit)
        healing atleast 5 people in the next 60 minutes or so
        getting a sample from a virus node which exists somewhere

*/


function zbl.NPC.OnUse(npc,ply)

    if zbl.Player.IsResearcher(ply) == false then
        zclib.Notify(ply, zbl.language.General["Wrong Job"], 1)
        return
    end

    // Open NPC Interface
    zbl.NPC.OpenMenu(npc,ply)
end

// Open NPC Interface
util.AddNetworkString("zbl_NPC_OpenMenu")
function zbl.NPC.OpenMenu(npc,ply)
    zclib.Debug("zbl.NPC.OpenMenu")

    local swep = ply:GetWeapon( "zbl_gun" )

    if not IsValid(swep) then
        zclib.Notify(ply, zbl.language.General["nogun"], 1)
        return
    end

    // Lets generate a random quest for the player
    if ply.zbl_Quest == nil or (ply.zbl_Quest.start_time == -1 and (ply.zbl_Quest.request_time + zbl.config.NPC.quest_cooldown) < CurTime()) then
        local rnd_id = math.random(#zbl.config.NPC.quests)

        ply.zbl_Quest = {
            id = rnd_id,
            request_time = CurTime(),
            start_time = -1,
            accepted = false,
            npc = npc
        }

        zclib.Debug("New Quest ID: " .. rnd_id)
    end

    // Makes the flask table a bit smaller for networking
    local reduced_tbl = {}
    for k,v in pairs(swep.Flasks) do
        local name = v.GenName
        reduced_tbl[k] = {
            gt = v.GenType,
            gv = v.GenValue,
            gn = name,
        }
    end

    timer.Simple(0,function()
        if IsValid(ply) then


            local dataString = util.TableToJSON(reduced_tbl)
            local dataCompressed = util.Compress(dataString)
            net.Start("zbl_NPC_OpenMenu")
            net.WriteUInt(#dataCompressed, 16)
            net.WriteData(dataCompressed, #dataCompressed)
            net.WriteEntity(npc)
            net.WriteInt(ply.zbl_Quest.id,16)
            net.WriteInt(ply.zbl_Quest.start_time,16)
            net.Send(ply)
        end
    end)
end

// Forces the interface to be closed
util.AddNetworkString("zbl_NPC_CloseMenu")
function zbl.NPC.ForceCloseMenu(ply)
    zclib.Debug("zbl.NPC.ForceCloseMenu")

    net.Start("zbl_NPC_CloseMenu")
    net.Send(ply)
end

local function NetCheck(ply,npc)
    if not IsValid(ply) then return end
    if zclib.Player.Timeout(nil,ply) then return end
    if not IsValid(npc) then return end
    if npc:GetClass() ~= "zbl_npc" then return end
    if zclib.util.InDistance(ply:GetPos(), npc:GetPos(), 600) == false then return end
    return true
end

util.AddNetworkString("zbl_NPC_Sell")
net.Receive("zbl_NPC_Sell", function(len, ply)
    zclib.Debug("zbl_NPC_Sell len: " .. len)
    local npc = net.ReadEntity()
    local id = net.ReadInt(16)
    if id == nil then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

    if not NetCheck(ply,npc) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

    zbl.NPC.Sell(npc,ply,id)
end)
function zbl.NPC.Sell(npc,ply,flask_id)
    zclib.Debug("zbl.NPC.Sell")

    local swep = ply:GetWeapon("zbl_gun")

    if not IsValid(swep) then return end
    if swep.Flasks == nil then return end

    local flask_data = swep.Flasks[flask_id]
    if flask_data == nil then return end

    if flask_data.GenType ~= 2 and flask_data.GenType ~= 3 then return end

    local money = 0

    // Vaccine/Virus
    if flask_data.GenType == 2 then

        money = zbl.Vaccine.GetPrice(flask_data.GenValue)

    // Cure
    elseif flask_data.GenType == 3 then

        money = zbl.Vaccine.GetCure_Price(flask_data.GenValue)
    end

    // Remove Flask from player swep
    zbl.Injector.EmptyLiquid(swep,flask_id)

    // Give player the money
    zclib.Money.Give(ply, money)

    zclib.Notify(ply, string.Replace(zbl.language.General["ReceivedMoney"],"$Money",zclib.Money.Display(money)), 4)
    ply:EmitSound("zbl_cash")
end

util.AddNetworkString("zbl_NPC_AcceptQuest")
net.Receive("zbl_NPC_AcceptQuest", function(len, ply)
    zclib.Debug("zbl_NPC_AcceptQuest len: " .. len)

    local npc = net.ReadEntity()

    if not NetCheck(ply,npc) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

    zbl.NPC.AcceptQuest(npc,ply)
end)
function zbl.NPC.AcceptQuest(npc,ply)
    zclib.Debug("zbl.NPC.AcceptQuest")
    zbl.Quest.OnStart(ply,ply.zbl_Quest.id)
end

util.AddNetworkString("zbl_NPC_DeclineQuest")
net.Receive("zbl_NPC_DeclineQuest", function(len, ply)
    zclib.Debug("zbl_NPC_DeclineQuest len: " .. len)

    local npc = net.ReadEntity()
    if not NetCheck(ply,npc) then return end

    zbl.NPC.DeclineQuest(npc,ply)
end)
function zbl.NPC.DeclineQuest(npc,ply)
    zclib.Debug("zbl.NPC.CancelQuest")
    zbl.Quest.Stop(zclib.Player.GetID(ply),ply)
end

util.AddNetworkString("zbl_NPC_CancelQuest")
net.Receive("zbl_NPC_CancelQuest", function(len, ply)
    zclib.Debug("zbl_NPC_CancelQuest len: " .. len)

    local npc = net.ReadEntity()
    if not NetCheck(ply,npc) then return end

    zbl.NPC.CancelQuest(npc,ply)
end)
function zbl.NPC.CancelQuest(npc,ply)
    zclib.Debug("zbl.NPC.CancelQuest")
    zbl.Quest.Stop(zclib.Player.GetID(ply),ply)
end

util.AddNetworkString("zbl_NPC_FinishQuest")
util.AddNetworkString("zbl_NPC_NotFinishYet")
net.Receive("zbl_NPC_FinishQuest", function(len, ply)
    zclib.Debug("zbl_NPC_FinishQuest len: " .. len)

    local npc = net.ReadEntity()
    if not NetCheck(ply,npc) then return end

    zbl.NPC.FinishQuest(npc,ply)
end)
function zbl.NPC.FinishQuest(npc,ply)
    zclib.Debug("zbl.NPC.CancelQuest")

    local completed = false
    if ply.zbl_Quest and ply.zbl_Quest.id ~= -1 and ply.zbl_Quest.accepted == true then
        completed = zbl.Quest.CheckProgress(ply)
        if completed then
            zbl.Quest.OnCompleted(ply)
        else
            // Send player back the result
            net.Start("zbl_NPC_NotFinishYet")
            net.Send(ply)
        end
    end
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c





file.CreateDir("zbl")
zclib.STM.Setup("zbl_npc", "zbl/" .. string.lower(game.GetMap()) .. "_npc" .. ".txt", function()
    local data = {}
    for u, j in pairs(ents.FindByClass("zbl_npc")) do
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
        local ent = ents.Create("zbl_npc")
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
    zbl.Print("Finished loading NPC Entities!")
end, function()
    for k, v in pairs(ents.FindByClass("zbl_npc")) do
        if IsValid(v) then
            v:Remove()
        end
    end
end)

concommand.Add("zbl_save_npc", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        zbl.NPC.Save(ply)
    end
end)

concommand.Add("zbl_remove_npc", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        zbl.NPC.Remove(ply)
    end
end)

function zbl.NPC.Save(ply)
    zclib.STM.Save("zbl_npc")
    zclib.Notify(ply, "NPC entities have been saved for the map " .. string.lower(game.GetMap()) .. "!", 0)
end

function zbl.NPC.Remove(ply)
    zclib.STM.Remove("zbl_npc")
    zclib.Notify(ply, "NPC entities have been removed for the map " .. string.lower(game.GetMap()) .. "!", 0)
end
