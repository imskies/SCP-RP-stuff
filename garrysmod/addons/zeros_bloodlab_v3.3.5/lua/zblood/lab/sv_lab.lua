/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.Lab = zbl.Lab or {}

// Called when the player joins the server
function zbl.Lab.Initialize(Lab)
    zclib.EntityTracker.Add(Lab)

    Lab.AllowInput = true

    Lab.Samples = {}
    Lab.SampleCooldown = {}
end

function zbl.Lab.Touch(Lab,other)
    if not IsValid(Lab) then return end
    if not IsValid(other) then return end
    if other:GetClass() ~= "zbl_flask" then return end
    if zclib.util.CollisionCooldown(other) then return end
    if Lab.AllowInput == false then return end

    zbl.Lab.AddSample(Lab,other)
end

// Blocks the touch input for a certain amount of time
function zbl.Lab.BlockTouchInput(Lab,time)
    Lab.AllowInput = false
    timer.Simple(time,function()
        if IsValid(Lab) then
            Lab.AllowInput = true
        end
    end)
end

// Tells us if this sample is a duplicate
function zbl.Lab.Sample_IsDuplicate(Lab,gen_val)
    local IsDuplicate = false
    for k,v in pairs(Lab.Samples) do
        if v and v.id == gen_val then
            IsDuplicate = true
            break
        end
    end
    return IsDuplicate
end

// Returns the cooldown this sample id has
function zbl.Lab.Sample_HasCooldown(Lab,gen_val)
    if Lab.SampleCooldown[gen_val] and Lab.SampleCooldown[gen_val] > CurTime() then
        return math.Round(Lab.SampleCooldown[gen_val] - CurTime())
    else
        return false
    end
end

function zbl.Lab.AddSample(Lab,flask)
    if Lab:GetSampleCount() >= 12 then return end
    if flask:GetGenType() ~= 1 then return end
    zclib.Debug("zbl.Lab.AddSample")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

    // This can be a Blood/DNA or Virus sample
    local sample_data = {
        id = flask:GetGenValue(),
        type = flask:GetGenType(),
        name = flask:GetGenName(),
        points = flask:GetGenPoints(),
        class = flask:GetGenClass()
    }
    zbl.Lab.AddSampleData(Lab,sample_data)

    SafeRemoveEntity(flask)
end

function zbl.Lab.AddSampleData(Lab,sample_data)
    zclib.Debug("zbl.Lab.AddSampleData")

    local IsDuplicate = zbl.Lab.Sample_IsDuplicate(Lab,sample_data.id)
    local HasCooldown = zbl.Lab.Sample_HasCooldown(Lab,sample_data.id)

    local labPos = Lab:GetPos()
    for k, v in pairs(zclib.Player.List) do
        if IsValid(v) and v:IsPlayer() and v:Alive() and zclib.util.InDistance(v:GetPos(), labPos, 300) then
            if IsDuplicate then
                zclib.Notify(v, zbl.language.General["DuplicatePenalty"], 1)
            end

            if HasCooldown then
                zclib.Notify(v, zbl.language.General["CooldownPenalty"] .. " " .. zclib.util.FormatTime(HasCooldown), 1)
            end
        end
    end

    table.insert(Lab.Samples,sample_data)

    Lab:SetSampleCount(Lab:GetSampleCount() + 1)

    zbl.Lab.SampleChanged(Lab)

    zbl.Lab.UpdateBodygroup(Lab)
end

function zbl.Lab.RemoveSampleData(Lab,pos)
    table.remove(Lab.Samples,pos)

    Lab:SetSampleCount(Lab:GetSampleCount() - 1)

    zbl.Lab.SampleChanged(Lab)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

    zbl.Lab.UpdateBodygroup(Lab)
end

function zbl.Lab.UpdateBodygroup(Lab)
    zclib.Debug("zbl.Lab.UpdateBodygroup")

    for i = 1, 12 do
        Lab:SetBodygroup(i-1, 0)
    end

    for i = 1, Lab:GetSampleCount() do
        Lab:SetBodygroup(i-1, 1)
    end
end

// This recalculates the SampleVariability, Reward and SampleSequence for all of the samples currently in the Lab
// Returns a value which defines how many diffrent samples there are currently in the lab and inflicts penalty on duplicates samples or samples with a cooldown
// This also generates the SampleSequence String
function zbl.Lab.SampleChanged(Lab)
    //zclib.Debug("zbl.Lab.SampleChanged")
    local Variability = 0
    local uniq_samples = {}
    local reward = 0

    // Creates a string sequence which tells us
    // Which sample is worth how many dna points
    local sequence = ""

    for k,v in pairs(Lab.Samples) do

        local b_var = 1
        local _points = 0

        // Is this exact sample allready in the lab?
        if uniq_samples[v.id] == nil then

            // Did this sample allready got used in the last 15 minutes or so
            if Lab.SampleCooldown[v.id] and Lab.SampleCooldown[v.id] > CurTime() then

                Variability = Variability + (b_var * zbl.config.GenLab.cooldown_penalty)
                _points = math.Round(v.points * zbl.config.GenLab.cooldown_penalty)
            else
                Variability = Variability + b_var
                _points = v.points
            end

            uniq_samples[v.id] = true
        else

            Variability = Variability + (b_var * zbl.config.GenLab.duplicate_penalty)
            _points = math.Round(v.points * zbl.config.GenLab.duplicate_penalty)
        end

        reward = reward + _points

        sequence = sequence .. _points

        if k < #Lab.Samples then
            sequence = sequence .. "_"
        end
    end

    // New Sample Sequence
    Lab:SetSampleSequence(sequence)

    // New Reward
    Lab:SetReward(reward)

    // New Variability
    Lab:SetSampleVariability(math.Round(Variability))

    local timerid = "zbl_SampleUpdate_Delay" .. Lab:EntIndex()
    zclib.Timer.Remove(timerid)
    zclib.Timer.Create(timerid,0.25,1,function()
        if IsValid(Lab) then
            zbl.Lab.SampleUpdate(Lab)
        end
    end)
end

function zbl.Lab.OnRemove(Lab)
    zclib.Debug("zbl.Lab.OnRemove")
    local entIndex = Lab:EntIndex()
    zclib.Timer.Remove("zbl_CreateCure_" .. entIndex)
    zclib.Timer.Remove("zbl_CreateVaccine_" .. entIndex)
    zclib.Timer.Remove("zbl_AnalyzeSample_" .. entIndex)
    zclib.Timer.Remove("zbl_SampleUpdate_Delay" .. entIndex)
end

// Informs the owner that the sample count got updated
util.AddNetworkString("zbl_Lab_Sample_Update")
function zbl.Lab.SampleUpdate(Lab)
    zclib.Debug("zbl.Lab.SampleUpdate")

    local ply = zclib.Player.GetOwner(Lab)
    if IsValid(ply) then
        net.Start("zbl_Lab_Sample_Update")
        net.WriteEntity(Lab)
        net.Send(ply)
    else
        // This could mean its a public entity so lets inform every single player
        net.Start("zbl_Lab_Sample_Update")
        net.WriteEntity(Lab)
        net.Broadcast()
    end
end

local function NetCheck(ent,ply)
    if not IsValid(ply) then return end
    if zclib.Player.Timeout(nil,ply) then return end
    if not IsValid(ent) then return end
    if ent:GetClass() ~= "zbl_lab" then return end
    if zclib.util.InDistance(ply:GetPos(), ent:GetPos(), 600) == false then return end
    if zbl.Lab.CanInteract(ent,ply) == false then return end
    if zbl.Player.IsResearcher(ply) == false then return end
    if ent:GetActionState() ~= 0 then return end

    return true
end

// Gets called from the client and tells the lab which sample to remove
util.AddNetworkString("zbl_Lab_Sample_Remove")
net.Receive("zbl_Lab_Sample_Remove", function(len, ply)
    local ent = net.ReadEntity()
    local index = net.ReadInt(6)
    if not NetCheck(ent,ply) then return end
    if index == nil then return end
    if ent:GetSampleCount() <= 0 then return end

    zbl.Lab.SampleRemove(ent,ply,index)
end)
function zbl.Lab.SampleRemove(Lab,ply,index)

    local s_data = Lab.Samples[index]

    if s_data == nil then return end

    if zbl.Flask.DropLimitReached(ply) then
        return
    end


    local pos = Lab:GetPos() + Lab:GetForward() * 55 + Lab:GetUp() * 15 + Lab:GetRight() * 5
    local flask = zbl.Flask.Spawn(ply,pos,s_data.type,s_data.id,s_data.name,s_data.points,s_data.class)
    zbl.Flask.Add(ply,flask)

    zbl.Lab.RemoveSampleData(Lab,index)
end


// Gets called from the client to try to collect a sample from the lab in to his injector gun
util.AddNetworkString("zbl_Lab_Sample_Collect")
net.Receive("zbl_Lab_Sample_Collect", function(len, ply)
    local ent = net.ReadEntity()
    local index = net.ReadInt(6)
    if not NetCheck(ent,ply) then return end
    if index == nil then return end
    if ent:GetSampleCount() <= 0 then return end

    zbl.Lab.SampleCollect(ent,ply,index)
end)
function zbl.Lab.SampleCollect(Lab,ply,index)

    local s_data = Lab.Samples[index]
    if s_data == nil then return end

    local swep = ply:GetActiveWeapon()
    if not IsValid(swep) then return end
    if swep:GetClass() ~= "zbl_gun" then return end

    local empty_flask = zbl.Injector.GetEmptyFlask(swep)
    if empty_flask == nil then
        zclib.Notify(ply, zbl.language.Gun["GunIsFull"], 1)
        return
    end

    zbl.Injector.AddLiquid(swep,empty_flask,s_data.type,s_data.id,s_data.name,s_data.points,s_data.class)
    swep:GetOwner():EmitSound("zbl_gun_fill")
    zbl.Injector.PlayShootAnim(swep)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

    zbl.Lab.RemoveSampleData(Lab,index)
end

util.AddNetworkString("zbl_Lab_AnalyzeSample_Request")
net.Receive("zbl_Lab_AnalyzeSample_Request", function(len, ply)
    local ent = net.ReadEntity()
    if not NetCheck(ent,ply) then return end
    if ent:GetSampleCount() <= 0 then return end

    zbl.Lab.AnalyzeSample(ent,ply)
end)
function zbl.Lab.AnalyzeSample(Lab,ply)
    zclib.Debug("zbl.Lab.AnalyzeSample")

    Lab:SetActionState(1)

    Lab.AllowInput = false

    // Adds a cooldown for all the sample Ids which get now used
    for k,v in pairs(Lab.Samples) do
        Lab.SampleCooldown[v.id] = CurTime() + zbl.config.GenLab.sample_cooldown
    end


    local duration = zbl.config.GenLab.time_per_sample * Lab:GetSampleCount()
    duration = duration * zbl.Lab.GetTimeModify(ply)

    Lab:SetProgressEnd(CurTime() + duration)
    Lab:SetProgressDuration(duration)

    // Start Analyze Timer
    local timerid = "zbl_AnalyzeSample_" .. Lab:EntIndex()
    zclib.Timer.Remove(timerid)
    zclib.Timer.Create(timerid,duration,1,function()

        zclib.Timer.Remove(timerid)

        local _reward = Lab:GetReward()

        if IsValid(ply) then
            zclib.Notify(ply, "+ " .. _reward .. " " .. zbl.language.General["DNA"], 4)
            zbl.DNASystem.AddPoints(ply,_reward)
        end

        Lab.Samples = {}
        Lab:SetSampleCount(0)
        Lab:SetReward(0)

        zbl.Lab.SampleChanged(Lab)
        zbl.Lab.UpdateBodygroup(Lab)

        Lab.AllowInput = true

        Lab:SetActionState(0)
    end)
end



util.AddNetworkString("zbl_Lab_RemoveSamples")
net.Receive("zbl_Lab_RemoveSamples", function(len, ply)
    local ent = net.ReadEntity()
    if not NetCheck(ent,ply) then return end
    if ent:GetSampleCount() <= 0 then return end

    zbl.Lab.RemoveSamples(ent,ply)

    // Lets make sure we wont allow any touch input for the next second
    zbl.Lab.BlockTouchInput(ent,1)
end)
function zbl.Lab.RemoveSamples(Lab,ply)
    zclib.Debug("zbl.Lab.RemoveSamples")

    if zbl.Flask.DropLimitReached(ply) then
        return
    end

    local start_pos = Lab:GetPos() + Lab:GetForward() * 55 + Lab:GetUp() * 15 + Lab:GetRight() * 5
    local pos = start_pos
    local x,y = 0,0
    local count = 0

    local Loss = 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

    for k,v in pairs(Lab.Samples) do
        if v then
            pos = start_pos
            if count >= 4 then
                x = 0
                y = y + 15
                count = 0
            end

            pos = pos - Lab:GetRight() * x
            pos = pos + Lab:GetForward() * y
            x = x + 15
            count = count + 1

            if zbl.Flask.DropLimitReached(ply,true) then
                Loss = Loss + 1
            else
                local flask = zbl.Flask.Spawn(ply,pos,v.type,v.id,v.name,v.points,v.class)
                zbl.Flask.Add(ply,flask)
            end
        end
    end

    if Loss > 0 then
        zclib.Notify(ply,string.Replace(zbl.language.General["FlaskLoss"],"$AMOUNT",Loss), 1)
    end

    Lab.Samples = {}
    Lab:SetSampleCount(0)

    zbl.Lab.SampleChanged(Lab)
    zbl.Lab.UpdateBodygroup(Lab)
end



util.AddNetworkString("zbl_Lab_CreateVaccine")
net.Receive("zbl_Lab_CreateVaccine", function(len, ply)
    local ent = net.ReadEntity()
    local vaccID = net.ReadInt(16)
    if not NetCheck(ent,ply) then return end
    if vaccID == nil then return end
    zbl.Lab.CreateVaccine(ent, vaccID, ply)
end)
function zbl.Lab.CreateVaccine(Lab,VaccineID,ply)
    zclib.Debug("zbl.Lab.CreateVaccine")

    if zbl.Vaccine.CanResearch(ply,VaccineID,false) == false then return end

    if zbl.DNASystem.Get(ply) < zbl.Vaccine.GetResearch_VaccinePoints(VaccineID) then
        return
    end

    Lab:SetActionState(2)

    Lab.AllowInput = false

    // lets remove any sample which are in the lab
    zbl.Lab.RemoveSamples(Lab,ply)

    Lab:SetSelectedVaccine(VaccineID)


    local duration = zbl.Vaccine.GetResearch_VaccineTime(VaccineID)
    duration = duration * zbl.Lab.GetTimeModify(ply)

    Lab:SetProgressEnd(CurTime() + duration)
    Lab:SetProgressDuration(duration)


    Lab:SetSampleCount(1)
    zbl.Lab.UpdateBodygroup(Lab)

    // Start Analyze Timer
    local timerid = "zbl_CreateVaccine_" .. Lab:EntIndex()
    zclib.Timer.Remove(timerid)
    zclib.Timer.Create(timerid,duration,1,function()

        zclib.Timer.Remove(timerid)
        if not IsValid(Lab) then return end

        if IsValid(ply) then
            zbl.DNASystem.RemovePoints(ply,zbl.Vaccine.GetResearch_VaccinePoints(VaccineID))
        end

        Lab:SetSampleCount(0)

        zbl.Lab.UpdateBodygroup(Lab)

        Lab.AllowInput = true

        Lab:SetActionState(0)

        timer.Simple(0.5,function()
            if IsValid(ply) and IsValid(Lab) and VaccineID then
                zbl.Flask.Spawn(ply,Lab:GetPos() + Lab:GetForward() * 55 + Lab:GetUp() * 25,2,VaccineID,zbl.Vaccine.GetName(VaccineID),0,"")
            end
        end)
    end)
end

util.AddNetworkString("zbl_Lab_CreateCure")
net.Receive("zbl_Lab_CreateCure", function(len, ply)
    local ent = net.ReadEntity()
    local vaccID = net.ReadInt(16)
    if not NetCheck(ent, ply) then return end
    if vaccID == nil then return end
    zbl.Lab.CreateCure(ent, vaccID, ply)
end)
function zbl.Lab.CreateCure(Lab,VaccineID,ply)
    zclib.Debug("zbl.Lab.CreateCure")

    if zbl.Vaccine.GetResearch_CurePoints(VaccineID) <= -1 then return end

    if zbl.Vaccine.CanResearch(ply,VaccineID,true) == false then return end

    if zbl.DNASystem.Get(ply) < zbl.Vaccine.GetResearch_CurePoints(VaccineID) then
        return
    end

    Lab:SetActionState(3)

    Lab.AllowInput = false

    // lets remove any sample which are in the lab
    zbl.Lab.RemoveSamples(Lab,ply)

    Lab:SetSelectedVaccine(VaccineID)

    local duration = zbl.Vaccine.GetResearch_CureTime(VaccineID)
    duration = duration * zbl.Lab.GetTimeModify(ply)

    Lab:SetProgressEnd(CurTime() + duration)
    Lab:SetProgressDuration(duration)


    Lab:SetSampleCount(1)
    zbl.Lab.UpdateBodygroup(Lab)

    // Start Cure Timer
    local timerid = "zbl_CreateCure_" .. Lab:EntIndex()
    zclib.Timer.Remove(timerid)
    zclib.Timer.Create(timerid,duration,1,function()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

        zclib.Timer.Remove(timerid)

        if not IsValid(Lab) then return end

        if IsValid(ply) then
            zbl.DNASystem.RemovePoints(ply,zbl.Vaccine.GetResearch_CurePoints(VaccineID))
        end

        Lab:SetSampleCount(0)

        zbl.Lab.UpdateBodygroup(Lab)

        Lab.AllowInput = true

        Lab:SetActionState(0)


        // Create Vaccine Cure Entity
        timer.Simple(0.5,function()
            if IsValid(ply) and IsValid(Lab) and VaccineID then
                zbl.Flask.Spawn(ply,Lab:GetPos() + Lab:GetForward() * 55 + Lab:GetUp() * 25,3,VaccineID,zbl.Vaccine.GetName(VaccineID),0,"")
            end
        end)
    end)
end


////////////////////////////////////////////
////////// Save/Load LAB  //////////////////
////////////////////////////////////////////

file.CreateDir("zbl")
zclib.STM.Setup("zbl_lab", "zbl/" .. string.lower(game.GetMap()) .. "_lab" .. ".txt", function()
    local data = {}
    for u, j in pairs(ents.FindByClass("zbl_lab")) do
        if IsValid(j) then

            local f_data = {
                pos = j:GetPos(),
                ang = j:GetAngles(),
            }
            table.insert(data, f_data)
        end
    end
    return data
end, function(data)
    for k, v in pairs(data) do
        local ent = ents.Create("zbl_lab")
        ent:SetPos(v.pos)
        ent:SetAngles(v.ang)
        ent:Spawn()
        ent:Activate()

        ent:SetIsPublicEntity(true)

        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(false)
        end
    end
    zbl.Print("Finished loading Lab Entities!")
end, function()
    for k, v in pairs(ents.FindByClass("zbl_lab")) do
        if IsValid(v) then
            v:Remove()
        end
    end
end)

concommand.Add( "zbl_lab_save", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        zbl.Lab.Save(ply)
    end
end )

concommand.Add( "zbl_lab_remove", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        zbl.Lab.Remove(ply)
    end
end )

function zbl.Lab.Save(ply)
    zclib.STM.Save("zbl_lab")
    zclib.Notify(ply, "Lab entities have been saved for the map " .. string.lower(game.GetMap()) .. "!", 0)
end

function zbl.Lab.Remove(ply)
    zclib.STM.Remove("zbl_lab")
    zclib.Notify(ply, "Lab entities have been removed for the map " .. string.lower(game.GetMap()) .. "!", 0)
end
