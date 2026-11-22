if SCB_LOADED then return end

local util = util
local net = net
local file = file

local type = type

local scb = scb

do
	util.AddNetworkString("SCB.SendMessage")
	util.AddNetworkString("SCB.IsTyping")

	local cool_downs = {}

	local can_say = function(ply)
		local current_time = SysTime()
		local cool_down = cool_downs[ply]
		if not cool_down or current_time > cool_down then
			cool_downs[ply] = current_time + 0.66 -- https://github.com/ValveSoftware/source-sdk-2013/blob/0d8dceea4310fde5706b3ce1c70609d72a38efdf/sp/src/game/server/client.cpp#L747
			return true
		end
		return false
	end

	net.Receive("SCB.SendMessage", function(_, ply)
		if not can_say(ply) then return end

		local team = net.ReadBool()
		local text = net.ReadString():sub(1, scb.config.max_message_size or 126)

		text = hook.Run("PlayerSay", ply, text, team)
		if type(text) ~= "string" then
			text = ""
		end

		if text == "" then return end

		if game.IsDedicated() then
			ServerLog(ply:Nick() .. ": " .. text .. "\n")
		end

		local omit = {}
		local omit_n = 0

		for _, target in player.Iterator() do
			if target ~= ply then
				local can_see = hook.Run("PlayerCanSeePlayersChat", text, team, target, ply)
				if not can_see then
					omit_n = omit_n + 1
					omit[omit_n] = target
				end
			end
		end

		net.Start("SCB.SendMessage")
			net.WriteBool(team)
			net.WriteEntity(ply)
			net.WriteData(text, #text)
		net.SendOmit(omit)
	end)

	net.Receive("SCB.IsTyping", function(_, ply)
		ply:SetNWBool("SCB.IsTyping", net.ReadBool())
	end)
end

local emojis, tags

do
	util.AddNetworkString("SCB.SendEmojis")
	util.AddNetworkString("SCB.AddEmoji")
	util.AddNetworkString("SCB.RemoveEmoji")

	local emoji_file = "scb/custom_emojis_3.txt"
	local old_emoji_file = "scb/custom_emojis_2.txt"

	if not file.Exists(emoji_file, "DATA") then
		local migrated = {}
		local old_data = file.Read(old_emoji_file, "DATA")
		if old_data and old_data ~= "" then
			local success, old_emojis = pcall(scb.sfs_old.decode, old_data)
			if success then
				migrated = old_emojis
			end
		end
		file.Write(emoji_file, scb.sfs.encode(migrated))
	end

	emojis = scb.sfs.decode(file.Read(emoji_file, "DATA"))

	local save = function()
		file.Write(emoji_file, scb.sfs.encode(emojis))
	end

	do -- old emojis
		if scb.istable(select(2, next(emojis))) then
			for k, v in pairs(emojis) do
				emojis[k] = v.url
			end
		end
		save()
	end

	net.Receive("SCB.AddEmoji", function(len, ply)
		if not scb.has_permission(ply, "menu") then return end

		local emoji = net.ReadString()
		local url = net.ReadString()
		emojis[emoji] = url

		local old = net.ReadString()
		if old ~= "" then
			emojis[old] = nil
		end

		net.Start("SCB.AddEmoji")
			net.WriteString(emoji)
			net.WriteString(url)
			net.WriteString(old)
		net.Broadcast()

		save()
	end)

	net.Receive("SCB.RemoveEmoji", function(len, ply)
		if not scb.has_permission(ply, "menu") then return end

		local name = net.ReadString()

		emojis[name] = nil

		net.Start("SCB.RemoveEmoji")
			net.WriteString(name)
		net.Broadcast()

		save()
	end)
end

do
	util.AddNetworkString("SCB.SendTags")
	util.AddNetworkString("SCB.AddTag")
	util.AddNetworkString("SCB.RemoveTag")

	local default_tags = {
		superadmin = ":crown: {#d4af37 Owner} :crown:",
		admin = "[{blue Admin}]",
		moderator = "[{green Moderator}]"
	}

	local tags_file = "scb/tags_3.txt"
	local old_tags_file = "scb/tags_2.txt"

	if not file.Exists(tags_file, "DATA") then
		local migrated = default_tags
		local old_data = file.Read(old_tags_file, "DATA")
		if old_data and old_data ~= "" then
			local success, old_tags = pcall(scb.sfs_old.decode, old_data)
			if success then
				migrated = old_tags
			end
		end
		file.Write(tags_file, scb.sfs.encode(migrated))
	end

	tags = scb.sfs.decode(file.Read(tags_file, "DATA"))

	local save = function()
		file.Write(tags_file, scb.sfs.encode(tags))
	end

	local add_tag = function(rank, tag, old)
		old = old or ""

		tags[rank] = tag

		if old ~= "" then
			tags[old] = nil
		end

		net.Start("SCB.AddTag")
			net.WriteString(rank)
			net.WriteString(tag)
			net.WriteString(old)
		net.Broadcast()

		save()
	end

	concommand.Add("scb_addtag", function(ply, _, args)
		if IsValid(ply) then return end

		local rank = args[1]
		if not rank then return end

		local tag = args[2]
		if not tag then return end

		add_tag(rank, tag)
	end)

	net.Receive("SCB.AddTag", function(len, ply)
		if not scb.has_permission(ply, "menu") then return end

		add_tag(net.ReadString(), net.ReadString(), net.ReadString())
	end)

	net.Receive("SCB.RemoveTag", function(len, ply)
		if not scb.has_permission(ply, "menu") then return end

		local name = net.ReadString()

		tags[name] = nil

		net.Start("SCB.RemoveTag")
			net.WriteString(name)
		net.Broadcast()

		save()
	end)
end

hook.Add("SCB.PlayerNetReady", "SCB.SendEmojis", function(ent)
	if not ent:IsPlayer() or not ent:IsValid() then return end

	do
		local emojis_data = scb.sfs.encode(emojis)
		emojis_data = util.Compress(emojis_data)
		local length = #emojis_data

		net.Start("SCB.SendEmojis")
			net.WriteUInt(length, 17)
			net.WriteData(emojis_data, length)
		net.Send(ent)
	end

	do
		local tags_data = scb.sfs.encode(tags)
		tags_data = util.Compress(tags_data)
		local length = #tags_data

		net.Start("SCB.SendTags")
			net.WriteUInt(length, 17)
			net.WriteData(tags_data, length)
		net.Send(ent)
	end
end)

do
	util.AddNetworkString("SCB.TTTRadio")

	hook.Add("TTTPlayerRadioCommand", "SCB.TTTPlayerRadioCommand", function(ply, msg_name, msg_target)
		if ply.LastRadioCommand and ply.LastRadioCommand > (CurTime() - 0.5) then return true end

		local name, rag_name = "", nil

		if IsEntity(msg_target) then
			if msg_target:IsPlayer() then
				name = msg_target:Nick()
			elseif msg_target:GetClass() == "prop_ragdoll" then
				name = LANG.NameParam("quick_corpse_id")
				rag_name = CORPSE.GetPlayerNick(msg_target, "A Terrorist")
			end
		else
			name = LANG.NameParam(msg_target)
		end

		net.Start("SCB.TTTRadio")
		net.WritePlayer(ply)
		net.WriteString(msg_name)
		net.WriteString(name)
		if rag_name then
			net.WriteString(rag_name)
		end
		net.Broadcast()

		ply.LastRadioCommand = CurTime()

		return true
	end, HOOK_LOW)
end

hook.Add("PlayerInitialSpawn", "SCB.ReliableSendNetMessages", function(ply)
	local ply_hook = "SCB.ReliableSendNetMessages." .. ply:SteamID()
	hook.Add("SetupMove", ply_hook, function(ply_to_check, _, cmd)
		if ply_to_check == ply and not cmd:IsForced() then
			hook.Remove("SetupMove", ply_hook)
			hook.Call("SCB.PlayerNetReady", nil, ply)
		end
	end)
end)

--

local function send_heartbeat()
	HTTP({
		url = "https://app.goobie.me/api/server_heartbeat",
		method = "post",
		body = util.TableToJSON({
			addr = game.GetIPAddress(),
			addon_name = "scb",
			addon_version = "39",
			steamid64 = "76561199010643983",
			secret = "76561199010650913",
		}),
		type = "application/json",
		headers = {},
		success = function() end,
		failed = function() end
	})
end

local timer_name = "scb_goobie_heartbeat" .. SysTime() .. math.random()
timer.Create(timer_name, 0, 0, function()
	if game.GetIPAddress():StartsWith("0.0.0.0") then return end

	send_heartbeat()
	timer.Remove(timer_name)
end)
timer.Create(timer_name .. "_daily", 24 * 60 * 60, 0, send_heartbeat)


-- -- https://github.com/iamcal/emoji-data
-- local function make_table(t)
-- 	local str = ""
-- 	for key, value in pairs(t) do
-- 		if (isnumber(key) or isbool(key)) then
-- 			key = "[" .. tostring(key) .. "]" .. "="
-- 		elseif isstring(key) then
-- 			key = "[\"" .. key .. "\"]" .. "="
-- 		end
-- 		if istable(value) then
-- 			str = str .. key .. '{' .. make_table(value)
-- 			str = str .. "},"
-- 		else
-- 			str = str .. key .. ('"' .. tostring(value) .. '"') .. ","
-- 		end
-- 	end
-- 	return str
-- end

-- local generate_emojis = function()
-- 	local pack = scb.mp.pack
-- 	local file = file

-- 	file.CreateDir("scb-generated-data")
-- 	file.CreateDir("scb-generated-data/emojis")

-- 	local categories = {
-- 		["Smileys & Emotion"] = "1",
-- 		["People & Body"] = "1",
-- 		["Animals & Nature"] = "2",
-- 		["Food & Drink"] = "3",
-- 		["Activities"] = "4",
-- 		["Travel & Places"] = "5",
-- 		["Objects"] = "6",
-- 		["Symbols"] = "7",
-- 		["Flags"] = "8",
-- 	}

-- 	local names_replacements = {
-- 		["+1"] = "thumbsup",
-- 		["-1"] = "thumbsdown",
-- 	}

-- 	local base_categories = util.JSONToTable(file.Read("scb-generated-data/base_categories.json"))
-- 	local smileys_category_n = #base_categories["Smileys & Emotion"]

-- 	local base_data = util.JSONToTable(file.Read("scb-generated-data/base_emojis.json"))
-- 	local new_data = {}
-- 	for k, v in ipairs(base_data) do
-- 		local image = v.image
-- 		if not image or image == "" then continue end
-- 		if not v.has_img_twitter then continue end
-- 		local short_name = v.short_name
-- 		if not short_name or short_name == "" then continue end
-- 		local category = categories[v.category]
-- 		if not category then continue end
-- 		short_name = names_replacements[short_name] or short_name:gsub("-", "_")
-- 		if v.category == "Flags" and not short_name:find("flag") then
-- 			short_name = "flag_" .. short_name
-- 		end
-- 		if v.id_number == "794977501" then continue end
-- 		local sort_order = v.sort_order
-- 		if v.category == "People & Body" then
-- 			sort_order = sort_order + smileys_category_n
-- 		end
-- 		new_data[short_name] = category .. sort_order
-- 		file.Write("scb-generated-data/emojis/" .. short_name .. ".png" , file.Read("img-twitter-64/" .. image))
-- 	end

-- 	file.Write("scb-generated-data/cl_emojis_data.txt", "return {" .. make_table(new_data) .. "}")
-- end
-- generate_emojis()
