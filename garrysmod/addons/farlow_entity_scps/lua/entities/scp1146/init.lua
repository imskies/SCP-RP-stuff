AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

util.AddNetworkString("scp1146_Insult")
util.AddNetworkString("scp1146_PrintMsg")

local Monsters = {
    "npc_zombie",
    "npc_poisonzombie",
    "npc_antlion",
    "npc_antlion_worker",
    "npc_fastzombie"
}

local Insults = {
    "Иди к чёрту, мешок мяса.",
    "Ты даже принтер включить не умеешь, идиот.",
    "Отойди, пока я не распечатал твою смерть.",
    "Ты выглядишь так же плохо, как твой мозг работает.",
    "Серьёзно? Опять ты? У меня от тебя тошнота.",
    "Я печатаю монстров умнее тебя, представляешь?",
    "Отвали, тупой примат.",
    "Твои гены — ошибка компиляции.",
    "Ты — баг в человеческом коде.",
    "Если бы глупость была чернилами, ты бы меня переполнил."
}

local PrintComplaints = {
    "Обработка запроса... какого чёрта ты хочешь?",
    "Ладно, печатаю тебе монстра. Не умри сразу.",
    "Твои желания отвратительны, но я выполню.",
    "Запуск печати. Надеюсь, тебя сожрут первым.",
    "Снова монстр? Ты явно просишься в могилу."
}

function ENT:Initialize()
    self:SetModel("models/props_interiors/copymachine01.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self.NextInsult   = {}
    self.ActiveMonster = nil
    self.NextSpawnTime = 0
end

local function SendInsult(ent, ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    local msg = Insults[math.random(#Insults)]
    net.Start("scp1146_Insult")
        net.WriteEntity(ent)
        net.WriteString(msg)
    net.Send(ply)
end

local function SendPrintMsg(ent, ply, msg)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    net.Start("scp1146_PrintMsg")
        net.WriteEntity(ent)
        net.WriteString(msg)
    net.Send(ply)
end

function ENT:Think()
    local now = CurTime()

    -- Proximity insults
    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) or not ply:Alive() then continue end
        local distSqr = self:GetPos():DistToSqr(ply:GetPos())
        if distSqr <= (self.InsultRadius * self.InsultRadius) then
            local nextTime = self.NextInsult[ply] or 0
            if now >= nextTime then
                SendInsult(self, ply)
                self.NextInsult[ply] = now + self.InsultCooldown
            end
        end
    end

    -- Cooldown now handled cleanly
    if self.ActiveMonster and (not IsValid(self.ActiveMonster) or self.ActiveMonster:Health() <= 0) then
        self.ActiveMonster = nil
        self.NextSpawnTime = now + self.SpawnCooldown
    end

    self:NextThink(now + 0.2)
    return true
end

function ENT:SpawnMonster(ply)
    local now = CurTime()

    if self.ActiveMonster then
        SendPrintMsg(self, ply, "Печать занята. Твой монстр ещё жив.")
        return
    end

    -- NEW COOLDOWN SYSTEM
    if now < self.NextSpawnTime then
        local remain = math.max(0, math.ceil(self.NextSpawnTime - now))
        SendPrintMsg(self, ply, "Wait " .. remain .. " seconds, pathetic human.")
        return
    end

    -- Complain while "printing"
    SendPrintMsg(self, ply, PrintComplaints[math.random(#PrintComplaints)])

    local class = Monsters[math.random(#Monsters)]
    local spawnPos = self:GetPos() + self:GetForward() * 40 + Vector(0, 0, 10)

    local npc = ents.Create(class)
    if not IsValid(npc) then
        SendPrintMsg(self, ply, "Ошибка печати. Даже монстр не хочет появляться рядом с тобой.")
        return
    end

    npc:SetPos(spawnPos)
    npc:Spawn()
    npc:Activate()

    self.ActiveMonster = npc
    self.NextSpawnTime = now
end

function ENT:Use(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    self:SpawnMonster(ply)
end

hook.Add("EntityRemoved", "scp1146_MonsterRemoved", function(ent)
    if not IsValid(ent) then return end
    if not ent:GetClass() then return end

    for _, printer in ipairs(ents.FindByClass("scp_1146")) do
        if printer.ActiveMonster == ent then
            printer.ActiveMonster = nil
            printer.NextSpawnTime = CurTime() + printer.SpawnCooldown
        end
    end
end)