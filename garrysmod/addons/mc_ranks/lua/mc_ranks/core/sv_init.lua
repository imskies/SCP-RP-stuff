-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║╚═╝║╚══╗──By MacTavish <3──────
-- ║║║║║║╔╗╔╩══╗║───────────────────────
-- ║║║║║║║║╚╣╚═╝║───────────────────────
-- ╚╝╚╝╚╩╝╚═╩═══╝───────────────────────
MRS.ServerKey = "240d07e9b5a8e9790abb3939d5d36b1cecac436922e76ea91bec7d85b8c8b0f4"

function MRS.ChangeTeam(ply, tm)
	if DarkRP then
		ply:changeTeam(tm, true)

		return
	end

	ply:SetTeam(tm)
end

function MRS.UpdateTimeProgression(ply)
	local group = MRS.GetNWdata(ply, "Group")
	local rank_id = MRS.GetNWdata(ply, "Rank")
	if not group or not rank_id or not MRS.Ranks[group] then return end
	local rank = MRS.Ranks[group].ranks[rank_id]
	if not rank or not rank.autoprom or not isnumber(rank.autoprom) or rank.autoprom < 1 then return end
	if not MRS.Ranks[group].ranks[rank_id + 1] then return end

	if not MRS.GetSelfNWdata(ply, "progress") then
		MRS.SetSelfNWdata(ply, "progress", 0)
	end

	MRS.SetSelfNWdata(ply, "progress", MRS.GetSelfNWdata(ply, "progress") + 1)

	if MRS.GetSelfNWdata(ply, "progress") >= rank.autoprom then
		MRS.SetPlayerRank(ply, group, rank_id + 1)
		hook.Call("MRS.OnAutoPromotion", nil, ply, group, rank_id, rank_id + 1, MRS.Ranks[group].ranks[rank_id + 1].name)

		return
	end

	MRS.SetNWStoredData(ply, group, {
		rank = rank_id,
		time = MRS.GetSelfNWdata(ply, "progress")
	})
end

function MRS.SetupRankStats(ply, rid, group, tm)
	local rank = MRS.Ranks[group].ranks[rid]
	if not rank then return end

	if rank.force_team and rank.force_team ~= tm and MRS.Ranks[group].job[team.GetName(rank.force_team)] then
		MRS.ChangeTeam(ply, rank.force_team)

		return
	end

	if rank.models and #rank.models > 0 then
		local pid = tonumber(ply:GetInfo("mrs_playermodel"))
		local data = rank.models[pid]

		if not data then
			local rand = math.random(1, #rank.models)
			data = rank.models[rand]
		end

		ply:SetModel(data.model)
		ply:SetSkin(data.skin)

		for k = 0, ply:GetNumBodyGroups() - 1 do
			ply:SetBodygroup(k, data.bgrs[k] or 0)
		end
	end

	for k, v in pairs(rank.stats) do
		if not MRS.PlayerStats[v.id] or not MRS.PlayerStats[v.id].apply then continue end
		if MRS.PlayerStats[v.id].check and MRS.PlayerStats[v.id].check() then continue end
		MRS.PlayerStats[v.id].apply(ply, v.data)
	end

	if DarkRP and MRS.Config.ChangeJobName then
		local prefix = MRS.Ranks[group].show_sn and rank.srt_name or rank.name

		if MRS.Config.SetAsPrefix then
			prefix = "[" .. prefix .. "] " .. team.GetName(ply:Team())
		end

		ply:updateJob(prefix)
	end
end

function MRS.SetupRankData(ply, tm)
	local grp = MRS.GetPlayerGroup(tm)

	if not grp then
		MRS.SetNWdata(ply, "Rank", nil)
		MRS.SetNWdata(ply, "Group", nil)
		MRS.SetSelfNWdata(ply, "progress", nil)

		return
	end

	local rank, time = MRS.GetPlyRank(ply, grp)
	MRS.SetNWdata(ply, "Rank", rank)
	MRS.SetNWdata(ply, "Group", grp)
	MRS.SetSelfNWdata(ply, "progress", time)
	MRS.RemoveRanksStats(ply)

	timer.Simple(0, function()
		MRS.SetupRankStats(ply, rank, grp, tm)
	end)
end

hook.Add("playerCanChangeTeam", "MRS.playerCanChangeTeam", function(ply, tm, force)
	if force then return end
	local grp, wlisted

	for k, v in pairs(MRS.Ranks) do
		if v.job[team.GetName(tm)] then
			grp = k
			wlisted = v.job[team.GetName(tm)]
			break
		end
	end

	if not grp or not wlisted or not tonumber(wlisted) then return end
	if not MRS.Ranks[grp].ranks[wlisted] then return end
	local prank = MRS.GetPlyRank(ply, grp)

	if prank < wlisted then
		MRS.SmallNotify(MSD.GetPhrase("mrs_job_smallrank", MRS.Ranks[grp].ranks[wlisted].name, team.GetName(tm)), ply, 1)

		return false
	end
end)

hook.Add("canDropWeapon", "MRS.DarkRP.canDropWeapon", function(ply, weapon)
	if weapon.MRS_weapon then return false end
end)

-- Hellix suppirt
hook.Add("CanPlayerJoinClass", "MRS.playerCanChangeTeam", function(ply, class, info)
	local grp, wlisted

	for k, v in pairs(MRS.Ranks) do
		if v.job[team.GetName(info.faction)] then
			grp = k
			wlisted = v.job[team.GetName(info.faction)]
			break
		end
	end

	if not grp or not wlisted or not tonumber(wlisted) then return end
	if not MRS.Ranks[grp].ranks[wlisted] then return end
	local prank = MRS.GetPlyRank(ply, grp)

	if prank < wlisted then
		MRS.SmallNotify(MSD.GetPhrase("mrs_job_smallrank", MRS.Ranks[grp].ranks[wlisted].name, team.GetName(info.faction)), ply, 1)

		return false
	end
end)

hook.Add("PlayerChangedTeam", "MRS.PlayerChangedTeam", function(ply, oldteam, newteam)
	MRS.SetupRankData(ply, newteam)
end)

hook.Add("PlayerSpawn", "MRS.PlayerSpawn", function(ply)
	MRS.SetupRankData(ply, ply:Team())
end)

hook.Add("canChangeJob", "MRS.canChangeJob", function(ply, job)
	if MRS.Config.ChangeJobName then
		local grp = MRS.GetPlayerGroup(ply:Team())
		if grp then return false, "You can't change your job name right now" end
	end
end)

hook.Add("PlayerSay", "MRS.PlayerSay", function(ply, text)
	local command = string.lower(text)

	if command == MRS.Config.CommanOpen then
		net.Start("MRS.OpenEditor")
		net.Send(ply)

		return ""
	end

	if command == MRS.Config.CommanPromote then
		local tr = ply:GetEyeTrace()

		if tr and IsValid(tr.Entity) and tr.Entity:IsPlayer() then
			MRS.PromotePlayer(ply, tr.Entity)
		end

		return ""
	end

	if command == MRS.Config.CommanDemote then
		local tr = ply:GetEyeTrace()

		if tr and IsValid(tr.Entity) and tr.Entity:IsPlayer() then
			MRS.DemotePlayer(ply, tr.Entity)
		end

		return ""
	end
end)

timer.Create("MRS.CheckProgression", 60, 0, function()
	for k, v in ipairs(player.GetAll()) do
		if not IsValid(v) then continue end
		MRS.UpdateTimeProgression(v)
	end
end)

concommand.Add("mrs_setrank", function(ply, cmd, args)
	if not args[1] or not args[2] or not args[3] then return end
	local found
	local group = args[2]
	local rank = tonumber(args[3])

	if args[1] == "self" then
		found = pl
	else
		found = MRS.FindPlayer(args[1])

		if not found and IsValid(ply) then
			MRS.SmallNotify("Can't find player", ply, 1)

			return
		end
	end

	MRS.ChangePlayerRank(ply, found, group, rank)
end)