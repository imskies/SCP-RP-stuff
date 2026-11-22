/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.Quest = zbl.Quest or {}

// Called when the quest starts
function zbl.Quest.OnStart(ply,quest_id)
	zclib.Debug('zbl.Quest.OnStart')
	local swep = ply:GetWeapon('zbl_gun')
	if not IsValid(swep) then return end

	local quest_config = zbl.config.NPC.quests[quest_id]
	if quest_config == nil then return end

	local quest_data = zbl.Quests[quest_config.q_type]
	if quest_data == nil then return end

	// If the player doesent have enough space in his gun then we dont allow him to take this quest
	if #swep.Flasks < quest_config.count then
		return
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

	ply.zbl_Quest.accepted = true
	ply.zbl_Quest.start_time = CurTime()


	// Run any code that might be needed
	quest_data.OnStart(ply,quest_config)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

	local timerID = 'zbl_quest_timer_' .. zclib.Player.GetID(ply)
	zclib.Timer.Remove(timerID)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

	zclib.Timer.Create(timerID,quest_config.time,1,function()
		zclib.Timer.Remove(timerID)

		if IsValid(ply) then
			zbl.Quest.OnFailed(ply)
		end
	end)
end

//Called to stop the quest instantly
function zbl.Quest.Stop(steamid,ply)
	zclib.Debug('zbl.Quest.Stop')

	local timerID = 'zbl_quest_timer_' .. steamid
	zclib.Timer.Remove(timerID)

	if IsValid(ply) then
		ply.zbl_Quest = {
			id = -1,
			request_time = CurTime(),
			start_time = -1,
			accepted = false,
			npc = nil
		}
	end
end


util.AddNetworkString('zbl_OnQuestFailed')
util.AddNetworkString('zbl_OnQuestCompleted')
// Called when the quest timer runs out
function zbl.Quest.OnFailed(ply)
	zclib.Debug('zbl.Quest.OnFailed')

	zclib.Notify(ply, zbl.language.NPC['Quest_FailedNotify'], 1)

	// If the client has the interface open while this happens then we update it
	net.Start('zbl_OnQuestFailed')
	net.Send(ply)

	ply.zbl_Quest = {
		id = -1,
		request_time = CurTime(),
		start_time = -1,
		accepted = false,
		npc = nil
	}
end

// Checks if we reached our goal for the quest
function zbl.Quest.CheckProgress(ply)
	local result = false
	if ply.zbl_Quest and ply.zbl_Quest.id ~= -1 and ply.zbl_Quest.accepted then
		local quest_config = zbl.config.NPC.quests[ply.zbl_Quest.id]

		result = zbl.Quests[quest_config.q_type].OnProgressCheck(ply,quest_config)
	end

	if result == true then
		zclib.Debug('zbl.Quest.CheckProgress: Quest Completed!')
	else
		zclib.Debug('zbl.Quest.CheckProgress: Quest not done yet')
	end

	return result
end

// Called when the player completed the quest
function zbl.Quest.OnCompleted(ply)
	zclib.Debug('zbl.Quest.OnCompleted')

	local quest_config = zbl.config.NPC.quests[ply.zbl_Quest.id]
	zbl.Quests[quest_config.q_type].OnCompleted(ply, quest_config)

	// Give player the money
	if quest_config.money_reward then
		zclib.Money.Give(ply, quest_config.money_reward)
		ply:EmitSound('zbl_cash')
		zclib.Notify(ply, string.Replace(zbl.language.General['ReceivedMoney'],'$Money',zclib.Money.Display(quest_config.money_reward)), 4)
	end

	// Give the Player DNA Points
	if quest_config.dna_reward then
		zbl.DNASystem.AddPoints(ply, quest_config.dna_reward)
		zclib.Notify(ply, string.Replace(zbl.language.General['ReceivedDNAPoints'], '$Points', quest_config.dna_reward), 4)
	end

	zbl.Quest.Stop(zclib.Player.GetID(ply), ply)

	local swep = ply:GetWeapon('zbl_gun')
	if not IsValid(swep) then return end

	local reduced_tbl = {}
	for k,v in pairs(swep.Flasks) do
		local name = v.GenName
		reduced_tbl[k] = {
			gt = v.GenType,
			gv = v.GenValue,
			gn = name,
		}
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

	timer.Simple(0,function()
		if IsValid(ply) and reduced_tbl then

			// If the client has the interface open while this happens then we update it
			local dataString = util.TableToJSON(reduced_tbl)
			local dataCompressed = util.Compress(dataString)
			net.Start('zbl_OnQuestCompleted')
			net.WriteUInt(#dataCompressed, 16)
			net.WriteData(dataCompressed, #dataCompressed)
			net.Send(ply)
		end
	end)
end
