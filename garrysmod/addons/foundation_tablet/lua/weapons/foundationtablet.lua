--[[ Credit goes to alydus' fortification tablet for the base of this SWEP]]
AddCSLuaFile()

local FOUNDATION_TABLET_LOGO
local FOUNDATION_BACK_ICON
local FOUNDATION_NEXT_ICON
local FOUNDATION_DELETE_ICON
local FOUNDATION_REQUEST_TYPES = {"PATROL ASSIST", "DISTURBANCE", "ARMED RESPONSE", "L.E.O RESPONSE", "ESCORT DETAIL", "RIOT CONTROL"} -- Different request types
local FOUNDATION_PRIORITY_LEVELS = {"LOW", "MEDIUM", "HIGH", "CRITICAL"}
local FOUNDATION_ZONE_OPTIONS = {"SURFACE", "ENTRANCE", "LCZ", "HCZ", "CHECKPOINT", "GATE A", "GATE B"} -- Zones for the requests feature
local FOUNDATION_UNIT_OPTIONS = {"Hostage Rescue", "F.E.", "Escort Detail", "I.A.", "F.E. Command"} -- Different response units
local FOUNDATION_THREAT_LEVELS = {"COMPLIANT", "SUSPICIOUS", "HOSTILE", "ARMED", "MULTIPLE HOSTILES"}
local FOUNDATION_BULLETIN_PRIORITIES = {"R&D", "SEC", "FE", "MTF", "SITE"} -- Different types of bulletin categories
local FOUNDATION_BULLETIN_FILTERS = {"ALL", "R&D", "SEC", "FE", "MTF", "SITE"} -- Different filters for the bulletin
local FOUNDATION_BREACH_SUBJECTS = {
	"SCP-173",
	"SCP-049",
	"SCP-610",
	"SCP-076-2",
	"SCP-999",
	"SCP-035",
	"SCP-106",
	"SCP-682",
	"SCP-096",
	"SCP-912",
	"SCP-066",
	"SCP-343",
	"SCP-966",
	"SCP-939",
	"SCP-131-A",
	"SCP-131-B",
	"SCP-457",
	"SCP-1048",
	"SCP-1048-A",
	"SCP-372",
	"SCP-079",
	"SCP-280",
	"SCP-053"
}
local FOUNDATION_BREACH_STATES = {
	{id = "CONTAINED", color = Color(130, 220, 170, 240), response = "Containment is stable. Routine watch and chamber checks remain in effect."},
	{id = "INVESTIGATING", color = Color(255, 205, 120, 240), response = "Security is reviewing irregular behavior and awaiting a full containment update."},
	{id = "BREACHED", color = Color(255, 95, 95, 240), response = "Confirmed breach in progress. Containment and response teams are actively deployed."}
}
local FOUNDATION_TABLET_CLICK_SOUND = "other/oakman/deadspace/ui/hud_save_confirm.wav"
local FOUNDATION_TABLET_HOVER_SOUND = "other/oakman/deadspace/ui/tic.wav"
local FOUNDATION_TABLET_RAISE_SOUND = "other/oakman/deadspace/ui/obj_complete.wav"
local FOUNDATION_TABLET_BOOT_DURATION = 1.35 -- Duration of the bootup animation
local FOUNDATION_TABLET_CHAT_TAG_COLOR = Color(200,100,100) -- Color for chat prefix for certain notifications 
local FOUNDATION_REQUEST_PING_DURATION = 180 -- How long FE request pings stay visible after a report is submitted
local FOUNDATION_TABLET_ROSTER_REFRESH_INTERVAL = 0.5
local FOUNDATION_TABLET_TEAM_GROUP_ORDER = { -- What order should team groups be in the roster?
	["SEC"] = 1,
	["FE"] = 2,
	["MTF"] = 3,
	["R&D"] = 4,
	["SITE"] = 5,
	["OTHER"] = 6
}

local function FoundationTabletResolveTeamIndex(teamOrPlayer)
	if IsEntity(teamOrPlayer) and teamOrPlayer.Team then
		return teamOrPlayer:Team()
	end

	return tonumber(teamOrPlayer)
end

local function FoundationTabletGetTeamGroup(teamOrPlayer)
	local teamIndex = FoundationTabletResolveTeamIndex(teamOrPlayer)
	if not teamIndex then return "OTHER" end

	if IsSecurityTeam and IsSecurityTeam(teamIndex) then return "SEC" end
	if IsFETeam and IsFETeam(teamIndex) then return "FE" end
	if IsMTFTeam and IsMTFTeam(teamIndex) then return "MTF" end
	if IsResearchTeam and IsResearchTeam(teamIndex) then return "R&D" end

	local job = RPExtraTeams and RPExtraTeams[teamIndex]
	local searchValues = {
		string.lower(tostring(job and job.category or "")),
		string.lower(tostring(job and job.name or "")),
		string.lower(team.GetName(teamIndex) or "")
	}

	for _, value in ipairs(searchValues) do
		if string.find(value, "security", 1, true) then
			return "SEC"
		elseif string.find(value, "foundation enforcement", 1, true) or string.find(value, "f.e.", 1, true) then
			return "FE"
		elseif string.find(value, "mobile task force", 1, true) or string.find(value, "mtf", 1, true) then
			return "MTF"
		elseif string.find(value, "research", 1, true) or string.find(value, "scientist", 1, true) then
			return "R&D"
		elseif string.find(value, "site administration", 1, true) or string.find(value, "administration", 1, true) or string.find(value, "site", 1, true) then
			return "SITE"
		end
	end

	return "OTHER"
end

local function FoundationTabletIsFETeam(teamOrPlayer)
	return FoundationTabletGetTeamGroup(teamOrPlayer) == "FE"
end

local function FoundationTabletHasActiveTablet(ply)
	local wep = IsValid(ply) and ply:GetActiveWeapon() or nil
	return IsValid(wep) and wep.GetClass and string.find(string.lower(wep:GetClass()), "foundationtablet", 1, true) ~= nil
end

local function FoundationTabletGetRequestPriorityColor(priority)
	priority = string.upper(tostring(priority or "LOW"))

	if priority == "CRITICAL" then
		return Color(255, 95, 95, 240)
	elseif priority == "HIGH" then
		return Color(255, 170, 120, 240)
	elseif priority == "MEDIUM" then
		return Color(255, 215, 130, 240)
	end

	return Color(120, 185, 255, 240)
end

local FOUNDATION_TABLET_PERSIST_DIR = "deepgaming"
local FOUNDATION_TABLET_PERSIST_FILE = FOUNDATION_TABLET_PERSIST_DIR .. "/foundation_tablet_records.json"
local FOUNDATION_TABLET_PERSISTED_STATE = FOUNDATION_TABLET_PERSISTED_STATE or {
	ResearchArchive = nil,
	LawEnforcement = nil
}
local FOUNDATION_TABLET_PERSISTED_CLIENT_STATE = FOUNDATION_TABLET_PERSISTED_CLIENT_STATE or {
	ResearchArchive = nil,
	LawEnforcement = nil
}

local function FoundationTabletNormalizeResearchDocumentData(entry)
	if not istable(entry) then return nil end

	entry.fileId = tostring(entry.fileId or "RD-000")
	entry.title = tostring(entry.title or "Untitled Research File")
	entry.author = tostring(entry.author or "Research Division")
	entry.created = tostring(entry.created or os.date("%m/%d %H:%M"))
	entry.updated = tostring(entry.updated or os.date("%H:%M"))
	entry.pages = istable(entry.pages) and entry.pages or {}
	entry.clicks = nil
	entry.views = nil

	if #entry.pages == 0 then
		local fallbackText = string.Trim(tostring(entry.body or ""))
		table.insert(entry.pages, fallbackText ~= "" and fallbackText or "No notes have been entered yet.")
	end

	for pageIndex, pageText in ipairs(entry.pages) do
		local cleanedText = string.Trim(tostring(pageText or ""))
		entry.pages[pageIndex] = cleanedText ~= "" and cleanedText or "This page is blank."
	end

	entry.page = math.Clamp(tonumber(entry.page) or 1, 1, #entry.pages)
	entry.body = entry.pages[entry.page] or entry.pages[1] or "No notes have been entered yet."
	return entry
end

local function FoundationTabletBuildDefaultResearchArchive(authorName)
	return {
		ActiveIndex = 1,
		SearchQuery = "",
		StatusNote = "RESEARCH DOCUMENTS READY",
		Entries = {
			{
				fileId = "RD-001",
				title = "Untitled Research File",
				pages = {
					"No notes have been entered yet."
				},
				page = 1,
				author = tostring(authorName or "Research Division"),
				created = os.date("%m/%d %H:%M"),
				updated = os.date("%H:%M")
			}
		},
		ActivityLog = {
			{type = "BOOT", text = "Research archive linked to local tablet.", user = "SYSTEM", posted = os.date("%H:%M:%S")}
		}
	}
end

local function FoundationTabletSanitizeResearchArchiveData(board, authorName)
	local fallback = FoundationTabletBuildDefaultResearchArchive(authorName)
	local sanitized = istable(board) and table.Copy(board) or table.Copy(fallback)

	sanitized.SearchQuery = tostring(sanitized.SearchQuery or "")
	sanitized.StatusNote = tostring(sanitized.StatusNote or fallback.StatusNote)
	sanitized.Entries = istable(sanitized.Entries) and sanitized.Entries or table.Copy(fallback.Entries)
	sanitized.ActivityLog = istable(sanitized.ActivityLog) and sanitized.ActivityLog or table.Copy(fallback.ActivityLog)

	for _, entry in ipairs(sanitized.Entries) do
		FoundationTabletNormalizeResearchDocumentData(entry)
	end

	for _, activity in ipairs(sanitized.ActivityLog) do
		if istable(activity) then
			activity.type = string.upper(tostring(activity.type or "LOG"))
			activity.text = tostring(activity.text or "NO DETAILS PROVIDED")
			activity.fileId = tostring(activity.fileId or "")
			activity.user = tostring(activity.user or "SYSTEM")
			activity.posted = tostring(activity.posted or os.date("%H:%M:%S"))
		end
	end

	sanitized.ActiveIndex = math.Clamp(tonumber(sanitized.ActiveIndex) or 1, 1, math.max(#sanitized.Entries, 1))
	return sanitized
end

local function FoundationTabletSanitizeLawEnforcementData(board)
	local sanitized = istable(board) and table.Copy(board) or {}
	local validTabs = {requests = true, fines = true, bols = true, arrests = true}

	sanitized.SelectedSubject = tostring(sanitized.SelectedSubject or "UNASSIGNED")
	sanitized.StatusNote = tostring(sanitized.StatusNote or "LAW ENFORCEMENT CONSOLE ONLINE")
	sanitized.ActiveTab = validTabs[tostring(sanitized.ActiveTab or "")] and tostring(sanitized.ActiveTab) or "requests"
	sanitized.Fines = istable(sanitized.Fines) and sanitized.Fines or {}
	sanitized.BOLs = istable(sanitized.BOLs) and sanitized.BOLs or {}
	sanitized.ArrestLogs = istable(sanitized.ArrestLogs) and sanitized.ArrestLogs or {}
	sanitized.ActionLog = istable(sanitized.ActionLog) and sanitized.ActionLog or {}
	sanitized.Tickets = {}
	sanitized.SelectedTicket = 1
	sanitized.SubjectOptions = {}
	sanitized.SubjectMenuOpen = false

	for _, collection in ipairs({sanitized.Fines, sanitized.BOLs, sanitized.ArrestLogs, sanitized.ActionLog}) do
		for _, entry in ipairs(collection) do
			if istable(entry) then
				entry.type = string.upper(tostring(entry.type or "LOG"))
				entry.subject = tostring(entry.subject or "UNKNOWN")
				entry.details = tostring(entry.details or "NO DETAILS PROVIDED")
				entry.timer = tostring(entry.timer or "")
				entry.posted = tostring(entry.posted or os.date("%H:%M:%S"))
				entry.entryId = tostring(entry.entryId or (entry.type .. "|" .. entry.subject .. "|" .. entry.details .. "|" .. entry.timer .. "|" .. entry.posted))
			end
		end
	end

	return sanitized
end

local function FoundationTabletBuildPersistentSnapshot(researchArchive, lawEnforcement)
	return {
		ResearchArchive = FoundationTabletSanitizeResearchArchiveData(researchArchive),
		LawEnforcement = FoundationTabletSanitizeLawEnforcementData(lawEnforcement)
	}
end

local function FoundationTabletWriteCompressedNetTable(payload)
	local json = util.TableToJSON(payload or {}) or "{}"
	local compressed = util.Compress(json) or ""
	net.WriteUInt(#compressed, 32)
	if #compressed > 0 then
		net.WriteData(compressed, #compressed)
	end
end

local function FoundationTabletReadCompressedNetTable()
	local byteCount = net.ReadUInt(32)
	if byteCount <= 0 then return {} end

	local compressed = net.ReadData(byteCount)
	local json = util.Decompress(compressed or "")
	local payload = util.JSONToTable(json or "")
	return istable(payload) and payload or {}
end

local function FoundationTabletApplyClientPersistentState(payload)
	if not CLIENT then return end

	local snapshot = FoundationTabletBuildPersistentSnapshot(
		istable(payload) and payload.ResearchArchive or nil,
		istable(payload) and payload.LawEnforcement or nil
	)

	FOUNDATION_TABLET_PERSISTED_CLIENT_STATE.ResearchArchive = snapshot.ResearchArchive
	FOUNDATION_TABLET_PERSISTED_CLIENT_STATE.LawEnforcement = snapshot.LawEnforcement

	local localPly = LocalPlayer()
	if not IsValid(localPly) then return end

	for _, wep in ipairs(localPly:GetWeapons()) do
		if IsValid(wep) and wep.GetClass and string.find(string.lower(wep:GetClass()), "foundationtablet", 1, true) ~= nil then
			local existingRequestHistory = wep.RequestHistory or {}
			local existingTickets = wep.LawEnforcementBoard and wep.LawEnforcementBoard.Tickets or existingRequestHistory
			local existingTicketIndex = wep.LawEnforcementBoard and wep.LawEnforcementBoard.SelectedTicket or 1

			wep.ResearchArchive = table.Copy(snapshot.ResearchArchive)
			wep.LawEnforcementBoard = table.Copy(snapshot.LawEnforcement)
			wep.LawEnforcementBoard.Tickets = existingTickets
			wep.LawEnforcementBoard.SelectedTicket = existingTicketIndex

			if wep.RefreshLawEnforcementSubjects then
				wep:RefreshLawEnforcementSubjects()
			end
		end
	end
end

local function FoundationTabletPushPersistentState(researchArchive, lawEnforcement)
	if not CLIENT then return end

	local snapshot = FoundationTabletBuildPersistentSnapshot(researchArchive, lawEnforcement)
	FOUNDATION_TABLET_PERSISTED_CLIENT_STATE.ResearchArchive = snapshot.ResearchArchive
	FOUNDATION_TABLET_PERSISTED_CLIENT_STATE.LawEnforcement = snapshot.LawEnforcement

	net.Start("DeepGaming.FoundationTablet.PersistentSave")
	FoundationTabletWriteCompressedNetTable(snapshot)
	net.SendToServer()
end

if SERVER then
	util.AddNetworkString("DeepGaming.FoundationTablet.Toggle")
	util.AddNetworkString("DeepGaming.FoundationTablet.RequestDispatch")
	util.AddNetworkString("DeepGaming.FoundationTablet.RequestResolve")
	util.AddNetworkString("DeepGaming.FoundationTablet.BulletinDispatch")
	util.AddNetworkString("DeepGaming.FoundationTablet.PersistentSync")
	util.AddNetworkString("DeepGaming.FoundationTablet.PersistentSave")

	local function FoundationTabletLoadPersistentState()
		if not file.Exists(FOUNDATION_TABLET_PERSIST_FILE, "DATA") then
			FOUNDATION_TABLET_PERSISTED_STATE = FoundationTabletBuildPersistentSnapshot(nil, nil)
			return
		end

		local rawData = file.Read(FOUNDATION_TABLET_PERSIST_FILE, "DATA") or ""
		local decoded = util.JSONToTable(rawData or "") or {}
		FOUNDATION_TABLET_PERSISTED_STATE = FoundationTabletBuildPersistentSnapshot(decoded.ResearchArchive, decoded.LawEnforcement)
	end

	local function FoundationTabletSavePersistentState()
		FOUNDATION_TABLET_PERSISTED_STATE = FoundationTabletBuildPersistentSnapshot(FOUNDATION_TABLET_PERSISTED_STATE.ResearchArchive, FOUNDATION_TABLET_PERSISTED_STATE.LawEnforcement)
		file.CreateDir(FOUNDATION_TABLET_PERSIST_DIR)
		file.Write(FOUNDATION_TABLET_PERSIST_FILE, util.TableToJSON(FOUNDATION_TABLET_PERSISTED_STATE, true) or "{}")
	end

	local function FoundationTabletBroadcastPersistentState(targetPly)
		local snapshot = FoundationTabletBuildPersistentSnapshot(FOUNDATION_TABLET_PERSISTED_STATE.ResearchArchive, FOUNDATION_TABLET_PERSISTED_STATE.LawEnforcement)
		net.Start("DeepGaming.FoundationTablet.PersistentSync")
		FoundationTabletWriteCompressedNetTable(snapshot)
		if IsValid(targetPly) then
			net.Send(targetPly)
		else
			net.Broadcast()
		end
	end

	FoundationTabletLoadPersistentState()

	hook.Add("PlayerInitialSpawn", "DeepGaming.FoundationTablet.PersistentSync", function(ply)
		timer.Simple(1, function()
			if IsValid(ply) then
				FoundationTabletBroadcastPersistentState(ply)
			end
		end)
	end)

	net.Receive("DeepGaming.FoundationTablet.PersistentSave", function(_, ply)
		if not IsValid(ply) or not FoundationTabletHasActiveTablet(ply) then return end

		local payload = FoundationTabletReadCompressedNetTable()
		FOUNDATION_TABLET_PERSISTED_STATE = FoundationTabletBuildPersistentSnapshot(payload.ResearchArchive, payload.LawEnforcement)
		FoundationTabletSavePersistentState()
		FoundationTabletBroadcastPersistentState()
	end)
end

if CLIENT then
	SWEP.PrintName = "Foundation Tablet"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false

	surface.CreateFont("DeepGaming.FoundationTablet.Title", {font = "Roboto Condensed", size = 50})
	surface.CreateFont("DeepGaming.FoundationTablet.Subtitle", {font = "Roboto Condensed", size = 35})
	surface.CreateFont("DeepGaming.FoundationTablet.TitleVM", {font = "Roboto Condensed", size = 60})
	surface.CreateFont("DeepGaming.FoundationTablet.SubtitleVM", {font = "Roboto Condensed", size = 52})
	surface.CreateFont("DeepGaming.FoundationTablet.HealthSubtitle", {font = "Roboto Condensed", size = 30})
	surface.CreateFont("DeepGaming.FoundationTablet.HealthEmbeddedTitle", {font = "Roboto Condensed", size = 25})
	surface.CreateFont("DeepGaming.FoundationTablet.CodeMarquee", {font = "Roboto Condensed", size = 86, weight = 1000})

	FOUNDATION_TABLET_LOGO = Material("scp_logo_light.png", "smooth")
	FOUNDATION_BACK_ICON = Material("alydus/icons/last.png", "smooth")
	FOUNDATION_NEXT_ICON = Material("alydus/icons/next.png", "smooth")
	FOUNDATION_DELETE_ICON = Material("brickscrafting/icons/error.png", "smooth")

	local FOUNDATION_TABLET_ACTIVE_REQUEST_PINGS = FOUNDATION_TABLET_ACTIVE_REQUEST_PINGS or {}

	local function FoundationTabletClearRequestPing(requestId, reporterEnt, reporterName)
		local normalizedId = string.Trim(tostring(requestId or ""))
		local normalizedName = string.lower(string.Trim(tostring(reporterName or "")))

		for activeId, activePing in pairs(FOUNDATION_TABLET_ACTIVE_REQUEST_PINGS) do
			local sameId = normalizedId ~= "" and tostring(activeId) == normalizedId
			local sameReporter = false

			if IsValid(reporterEnt) and IsValid(activePing.entity) then
				sameReporter = activePing.entity == reporterEnt
			elseif normalizedName ~= "" then
				sameReporter = string.lower(string.Trim(tostring(activePing.reporter or ""))) == normalizedName
			end

			if sameId or sameReporter then
				FOUNDATION_TABLET_ACTIVE_REQUEST_PINGS[activeId] = nil
			end
		end
	end

	local function FoundationTabletSyncRequestToWeapons(requestData)
		local localPly = LocalPlayer()
		if not IsValid(localPly) or not FoundationTabletIsFETeam(localPly) then return end

		for _, wep in ipairs(localPly:GetWeapons()) do
			if IsValid(wep) and wep.GetClass and string.find(string.lower(wep:GetClass()), "foundationtablet", 1, true) ~= nil then
				if wep.EnsureRequestHistory then
					wep:EnsureRequestHistory()
				end

				local requestHistory = wep.RequestHistory or {}
				wep.RequestHistory = requestHistory

				local existingEntry = nil
				for _, entry in ipairs(requestHistory) do
					if entry.id == requestData.id then
						existingEntry = entry
						break
					end
				end

				if existingEntry then
					existingEntry.subject = requestData.reporter or existingEntry.subject
					existingEntry.status = "OPEN"
					existingEntry.action = tostring(requestData.requestType or "REQUEST") .. " // " .. tostring(requestData.zone or "UNKNOWN")
					existingEntry.unit = requestData.unit or existingEntry.unit
					existingEntry.priority = requestData.priority or existingEntry.priority
					existingEntry.zone = requestData.zone or existingEntry.zone
					existingEntry.threat = requestData.threat or existingEntry.threat
					existingEntry.updated = os.date("%H:%M:%S")
					existingEntry.notes = tostring(requestData.requestType or "REQUEST") .. " // " .. tostring(requestData.threat or "COMPLIANT") .. " // " .. tostring(requestData.unit or "F.E.")
				else
					table.insert(requestHistory, 1, {
						id = requestData.id or ("LE-" .. tostring(math.random(1000, 9999))),
						subject = requestData.reporter or "UNKNOWN EMPLOYEE",
						status = "OPEN",
						action = tostring(requestData.requestType or "REQUEST") .. " // " .. tostring(requestData.zone or "UNKNOWN"),
						unit = requestData.unit or "F.E.",
						priority = requestData.priority or "LOW",
						zone = requestData.zone or "UNKNOWN",
						threat = requestData.threat or "COMPLIANT",
						updated = os.date("%H:%M:%S"),
						notes = tostring(requestData.requestType or "REQUEST") .. " // " .. tostring(requestData.threat or "COMPLIANT") .. " // " .. tostring(requestData.unit or "F.E.")
					})
					if #requestHistory > 12 then
						table.remove(requestHistory, #requestHistory)
					end
				end

				if wep.EnsureLawEnforcementBoard then
					wep:EnsureLawEnforcementBoard()
					wep.LawEnforcementBoard.Tickets = requestHistory
					wep.LawEnforcementBoard.SelectedTicket = 1
					wep.LawEnforcementBoard.StatusNote = "NEW REQUEST " .. tostring(requestData.id or "LE-0000") .. " // " .. tostring(requestData.priority or "LOW") .. " PRIORITY"
					if wep.RefreshLawEnforcementSubjects then
						wep:RefreshLawEnforcementSubjects()
					end
				end
			end
		end
	end

	local function FoundationTabletStoreRequestPing(reporterEnt, reporterName, requestId, requestType, zone, priority, threat, unit, worldPos)
		local key = tostring(requestId or ("REQ-" .. tostring(math.random(1000, 9999))))
		FoundationTabletClearRequestPing(key, reporterEnt, reporterName)
		local pingData = {
			id = key,
			reporter = tostring(reporterName or "UNKNOWN"),
			requestType = tostring(requestType or "REQUEST"),
			zone = tostring(zone or "UNKNOWN"),
			priority = tostring(priority or "LOW"),
			threat = tostring(threat or "COMPLIANT"),
			unit = tostring(unit or "F.E."),
			entity = reporterEnt,
			position = isvector(worldPos) and worldPos or (IsValid(reporterEnt) and reporterEnt:GetPos() or nil),
			receivedAt = CurTime(),
			expiresAt = CurTime() + FOUNDATION_REQUEST_PING_DURATION
		}

		FOUNDATION_TABLET_ACTIVE_REQUEST_PINGS[key] = pingData
		FoundationTabletSyncRequestToWeapons(pingData)
	end

	hook.Add("PreDrawHalos", "DeepGaming.FoundationTablet.RequestPingHalos", function()
		local localPly = LocalPlayer()
		if not IsValid(localPly) or not localPly:Alive() or not FoundationTabletIsFETeam(localPly) then return end

		for requestId, ping in pairs(FOUNDATION_TABLET_ACTIVE_REQUEST_PINGS) do
			if (ping.expiresAt or 0) <= CurTime() then
				FOUNDATION_TABLET_ACTIVE_REQUEST_PINGS[requestId] = nil
			elseif IsValid(ping.entity) then
				halo.Add({ping.entity}, FoundationTabletGetRequestPriorityColor(ping.priority), 1, 1, 2, true, true)
			end
		end
	end)

	hook.Add("HUDPaint", "DeepGaming.FoundationTablet.RequestPingHUD", function()
		local localPly = LocalPlayer()
		if not IsValid(localPly) or not localPly:Alive() or not FoundationTabletIsFETeam(localPly) then return end

		for requestId, ping in pairs(FOUNDATION_TABLET_ACTIVE_REQUEST_PINGS) do
			if (ping.expiresAt or 0) <= CurTime() then
				FOUNDATION_TABLET_ACTIVE_REQUEST_PINGS[requestId] = nil
			else
				local basePos = ping.position
				local targetPos = nil

				if IsValid(ping.entity) then
					basePos = ping.entity:GetPos()
					ping.position = basePos
					targetPos = ping.entity:LocalToWorld(Vector(0, 0, 82))
				elseif isvector(basePos) then
					targetPos = basePos + Vector(0, 0, 82)
				end

				if targetPos then
					local screenPos = targetPos:ToScreen()
					if screenPos.visible then
						local accentColor = FoundationTabletGetRequestPriorityColor(ping.priority)
						local distanceMeters = math.max(0, math.Round(localPly:GetPos():Distance(basePos or targetPos) * 0.01905))
						if distanceMeters <= 1000 then
							local header = tostring(ping.reporter or "UNKNOWN") .. " // " .. tostring(ping.id or "REQUEST")
							local details = tostring(ping.requestType or "REQUEST") .. " // " .. tostring(ping.zone or "UNKNOWN") .. " // " .. tostring(ping.unit or "F.E.")
							local footer = tostring(distanceMeters) .. "M // " .. tostring(ping.priority or "LOW") .. " PRIORITY"
							local distanceScale = math.Clamp(1 - (distanceMeters / 2200), 0.55, 1)

							surface.SetFont("DeepGaming.FoundationTablet.HealthEmbeddedTitle")
							local headerW = select(1, surface.GetTextSize(header))
							local detailsW = select(1, surface.GetTextSize(details))
							local footerW = select(1, surface.GetTextSize(footer))
							local boxW = (math.max(headerW, detailsW, footerW) + 24) * distanceScale
							local boxH = 72 * distanceScale
							local screenMargin = 18
							local boxX = math.Clamp(screenPos.x - (boxW * 0.5), screenMargin, ScrW() - boxW - screenMargin)
							local boxY = math.Clamp(screenPos.y - boxH - (14 * distanceScale), screenMargin, ScrH() - boxH - 20)
							local textInsetX = 10 * distanceScale
							local headerY = boxY + (7 * distanceScale)
							local detailsY = boxY + (27 * distanceScale)
							local footerY = boxY + (47 * distanceScale)
							local scaledFont = distanceScale < 0.72 and "DermaDefaultBold" or "DeepGaming.FoundationTablet.HealthEmbeddedTitle"

							draw.RoundedBox(0, boxX, boxY, boxW, boxH, Color(0, 0, 0, 210))
							surface.SetDrawColor(accentColor.r, accentColor.g, accentColor.b, 220)
							surface.DrawOutlinedRect(boxX, boxY, boxW, boxH, 2)
							surface.DrawRect(boxX + 2, boxY + 2, math.max(2, boxW - 4), math.max(2, 3 * distanceScale))
							draw.SimpleText(header, scaledFont, boxX + textInsetX, headerY, Color(255, 255, 255, 245), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
							draw.SimpleText(details, scaledFont, boxX + textInsetX, detailsY, accentColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
							draw.SimpleText(footer, scaledFont, boxX + textInsetX, footerY, Color(235, 235, 235, 240), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
						end
					end
				end
			end
		end
	end)

	net.Receive("DeepGaming.FoundationTablet.RequestDispatch", function()
		local reporterEnt = net.ReadEntity()
		local posterName = tostring(net.ReadString() or "UNKNOWN")
		local requestId = tostring(net.ReadString() or "LE-0000")
		local requestType = tostring(net.ReadString() or "REQUEST")
		local zone = tostring(net.ReadString() or "UNKNOWN")
		local priority = tostring(net.ReadString() or "LOW")
		local threat = tostring(net.ReadString() or "COMPLIANT")
		local unit = tostring(net.ReadString() or "F.E.")
		local worldPos = net.ReadVector()

		FoundationTabletStoreRequestPing(reporterEnt, posterName, requestId, requestType, zone, priority, threat, unit, worldPos)
		chat.AddText(FOUNDATION_TABLET_CHAT_TAG_COLOR, "[Foundation Tablet] ", Color(235, 235, 235), "New request submitted by " .. posterName .. " // " .. requestId .. " // " .. priority .. " // " .. zone)
	end)

	net.Receive("DeepGaming.FoundationTablet.RequestResolve", function()
		local requestId = tostring(net.ReadString() or "")
		if requestId == "" then return end

		FoundationTabletClearRequestPing(requestId)
	end)

	net.Receive("DeepGaming.FoundationTablet.BulletinDispatch", function()
		local posterName = tostring(net.ReadString() or "UNKNOWN")
		chat.AddText(FOUNDATION_TABLET_CHAT_TAG_COLOR, "[Foundation Tablet] ", Color(235, 235, 235), "New bulletin posted by " .. posterName)
	end)

	net.Receive("DeepGaming.FoundationTablet.PersistentSync", function()
		local payload = FoundationTabletReadCompressedNetTable()
		FoundationTabletApplyClientPersistentState(payload)
	end)
end

cleanup.Register("fortifications")

SWEP.Author = "Deep Gaming"
SWEP.Instructions = "Right click to raise or lower the tablet interface."
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "Deep Gaming"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 3.5

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 3.5

SWEP.HoldType = "slam"
SWEP.ViewModelFOV = 65
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.WorldModel = "models/nirrti/tablet/tablet_sfm.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.ViewModelBoneMods = {
	["ValveBiped.Grenade_body"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.IronSightsPos = Vector(12.72, 0, 0.36)
SWEP.IronSightsAng = Vector(0, 0, 0)

-- Simplified tablet behaviour; old fortification-building logic has been removed.

if CLIENT then
	function SWEP:RegisterTabletApplication(id, data)
		self.TabletApplications = self.TabletApplications or {}
		self.TabletApplications[id] = data
	end

	function SWEP:GetTabletTeamIndex(ply)
		if IsValid(ply) and ply.Team then
			return ply:Team()
		end

		if IsValid(LocalPlayer()) and LocalPlayer().Team then
			return LocalPlayer():Team()
		end

		return nil
	end

	function SWEP:IsFoundationEnforcementTeam(ply)
		return FoundationTabletIsFETeam(ply)
	end

	function SWEP:GetTabletTeamGroupLabel(ply)
		return FoundationTabletGetTeamGroup(ply)
	end

	function SWEP:CanAccessLawEnforcementApp(ply)
		return self:IsFoundationEnforcementTeam(ply)
	end

	function SWEP:IsResearchTeam(ply)
		return self:GetTabletTeamGroupLabel(ply) == "R&D"
	end

	function SWEP:CanAccessResearchArchiveApp(ply)
		return true
	end

	function SWEP:CanAccessBreachStatusApp(ply)
		local teamGroup = self:GetTabletTeamGroupLabel(ply)
		return ({SEC = true, FE = true, MTF = true, ["R&D"] = true, SITE = true})[teamGroup] == true
	end

	function SWEP:CanAccessBulletinsApp(ply)
		return true
	end

	function SWEP:CanPostBulletinsApp(ply)
		local teamIndex = self:GetTabletTeamIndex(ply)
		if not teamIndex then return false end

		local allowedTeams = {
			[TEAM_CHIEF or -1] = true,
			[TEAM_DEPCHIEF or -2] = true,
			[TEAM_FEGM or -3] = true,
			[TEAM_FECO or -4] = true,
			[TEAM_SECCPT or -5] = true
		}

		return allowedTeams[teamIndex] == true
	end

	function SWEP:CanAccessTabletApplication(appData, ply)
		if not appData then return false end
		if isfunction(appData.canAccess) then
			return appData.canAccess(self, ply) ~= false
		end

		return true
	end

	function SWEP:EnsureTabletApplications()
		self.TabletView = self.TabletView or "home"
		self.TabletClickableRegions = self.TabletClickableRegions or {}
		self.TabletApplications = self.TabletApplications or {}

		local hasAllApps = self.TabletApplicationsInitialized
			and self.TabletApplications["team_players"]
			and self.TabletApplications["requests"]
			and self.TabletApplications["law_enforcement"]
			and self.TabletApplications["research_archive"]
			and self.TabletApplications["breach_monitor"]
			and self.TabletApplications["bulletins"]

		if hasAllApps then return end

		self.TabletApplications = {}

		self:RegisterTabletApplication("team_players", {
			title = "DOSSIER",
			icon = FOUNDATION_TABLET_LOGO,
			onClick = function(wep)
				wep.TabletView = "team_players"
			end
		})

		self:RegisterTabletApplication("requests", {
			title = "REQUEST",
			icon = FOUNDATION_TABLET_LOGO,
			onClick = function(wep)
				wep.TabletView = "requests"
				wep.RequestsScroll = 0
				wep.RequestsScrollLerp = 0
			end
		})

		self:RegisterTabletApplication("law_enforcement", {
			title = "L.E.S.S",
			icon = FOUNDATION_TABLET_LOGO,
			deniedText = "FE ONLY",
			canAccess = function(wep, ply)
				return wep:CanAccessLawEnforcementApp(ply or LocalPlayer())
			end,
			onClick = function(wep)
				if not wep:CanAccessLawEnforcementApp(LocalPlayer()) then return end
				wep.TabletView = "law_enforcement"
			end
		})

		self:RegisterTabletApplication("research_archive", {
			title = "R&D",
			icon = FOUNDATION_TABLET_LOGO,
			canAccess = function(wep, ply)
				return wep:CanAccessResearchArchiveApp(ply or LocalPlayer())
			end,
			onClick = function(wep)
				if not wep:CanAccessResearchArchiveApp(LocalPlayer()) then return end
				wep.TabletView = "research_archive"
			end
		})

		self:RegisterTabletApplication("breach_monitor", {
			title = "C.B.S",
			icon = FOUNDATION_TABLET_LOGO,
			canAccess = function(wep, ply)
				return wep:CanAccessBreachStatusApp(ply or LocalPlayer())
			end,
			onClick = function(wep)
				if not wep:CanAccessBreachStatusApp(LocalPlayer()) then return end
				wep.TabletView = "breach_monitor"
			end
		})

		self:RegisterTabletApplication("bulletins", {
			title = "BULLETIN",
			icon = FOUNDATION_TABLET_LOGO,
			onClick = function(wep)
				wep.TabletView = "bulletins"
			end
		})

		self.TabletApplicationsInitialized = true
	end

	function SWEP:EnsureRequestsDraft()
		self.RequestDraft = self.RequestDraft or {
			TicketID = "LE-" .. tostring(math.random(1000, 9999)),
			TypeIndex = 1,
			PriorityIndex = 2,
			ZoneIndex = 1,
			UnitIndex = 1,
			ThreatIndex = 2,
			Status = "DRAFT",
			LastUpdated = os.date("%H:%M:%S"),
			AutoResetAt = nil
		}
	end

	function SWEP:AdvanceRequestField(fieldName, maxValue)
		self:EnsureRequestsDraft()
		local draft = self.RequestDraft
		draft[fieldName] = (draft[fieldName] % maxValue) + 1
		draft.Status = "DRAFT"
		draft.LastUpdated = os.date("%H:%M:%S")
		draft.AutoResetAt = nil
	end

	function SWEP:EnsureRequestHistory()
		self.RequestHistory = self.RequestHistory or {}
	end

	function SWEP:BuildRequestHistoryEntry(draft)
		draft = draft or {}
		local typeIndex = draft.TypeIndex or 1
		local priorityIndex = draft.PriorityIndex or 1
		local zoneIndex = draft.ZoneIndex or 1
		local unitIndex = draft.UnitIndex or 1
		local threatIndex = draft.ThreatIndex or 1

		return {
			id = draft.TicketID or ("LE-" .. tostring(math.random(1000, 9999))),
			subject = FOUNDATION_REQUEST_TYPES[typeIndex] or "REQUEST",
			status = draft.Status or "SUBMITTED",
			action = (FOUNDATION_PRIORITY_LEVELS[priorityIndex] or "LOW") .. " // " .. (FOUNDATION_ZONE_OPTIONS[zoneIndex] or "UNKNOWN"),
			unit = FOUNDATION_UNIT_OPTIONS[unitIndex] or "F.E.",
			priority = FOUNDATION_PRIORITY_LEVELS[priorityIndex] or "LOW",
			zone = FOUNDATION_ZONE_OPTIONS[zoneIndex] or "UNKNOWN",
			threat = FOUNDATION_THREAT_LEVELS[threatIndex] or "COMPLIANT",
			updated = draft.LastUpdated or os.date("%H:%M:%S"),
			notes = (FOUNDATION_UNIT_OPTIONS[unitIndex] or "F.E.") .. " requested for " .. (FOUNDATION_REQUEST_TYPES[typeIndex] or "REQUEST")
		}
	end

	function SWEP:SubmitRequestDraft()
		self:EnsureRequestsDraft()
		self:EnsureRequestHistory()

		self.RequestDraft.Status = "SUBMITTED"
		self.RequestDraft.LastUpdated = os.date("%H:%M:%S")
		self.RequestDraft.AutoResetAt = CurTime() + 3

		local historyEntry = self:BuildRequestHistoryEntry(self.RequestDraft)
		table.insert(self.RequestHistory, 1, historyEntry)
		if #self.RequestHistory > 12 then
			table.remove(self.RequestHistory, #self.RequestHistory)
		end

		self:EnsureLawEnforcementBoard()
		self.LawEnforcementBoard.Tickets = self.RequestHistory
		self.LawEnforcementBoard.SelectedTicket = 1
		self.LawEnforcementBoard.StatusNote = "NEW REQUEST " .. historyEntry.id .. " // " .. historyEntry.priority .. " PRIORITY"

		net.Start("DeepGaming.FoundationTablet.RequestDispatch")
		net.WriteString(tostring(historyEntry.id or "LE-0000"))
		net.WriteString(tostring(historyEntry.subject or "REQUEST"))
		net.WriteString(tostring(historyEntry.zone or "UNKNOWN"))
		net.WriteString(tostring(historyEntry.priority or "LOW"))
		net.WriteString(tostring(historyEntry.threat or "COMPLIANT"))
		net.WriteString(tostring(historyEntry.unit or "F.E."))
		net.SendToServer()
	end

	function SWEP:ResetRequestDraft()
		self.RequestDraft = {
			TicketID = "LE-" .. tostring(math.random(1000, 9999)),
			TypeIndex = 1,
			PriorityIndex = 2,
			ZoneIndex = 1,
			UnitIndex = 1,
			ThreatIndex = 2,
			Status = "DRAFT",
			LastUpdated = os.date("%H:%M:%S"),
			AutoResetAt = nil
		}
	end

	function SWEP:RefreshLawEnforcementSubjects()
		self.LawEnforcementBoard = self.LawEnforcementBoard or {}
		local board = self.LawEnforcementBoard
		local subjectOptions = {}
		local seen = {}

		local function addSubject(name)
			name = string.Trim(tostring(name or ""))
			if name == "" then return end

			local key = string.lower(name)
			if seen[key] then return end

			seen[key] = true
			table.insert(subjectOptions, name)
		end

		for _, ply in ipairs(player.GetAll()) do
			if IsValid(ply) then
				addSubject(ply:Nick())
			end
		end

		if #subjectOptions == 0 then
			for _, ticket in ipairs(self.RequestHistory or {}) do
				addSubject(ticket.subject)
			end
		end

		addSubject(board.SelectedSubject)

		if #subjectOptions == 0 then
			addSubject("UNASSIGNED")
		end

		table.sort(subjectOptions, function(a, b)
			return string.lower(a) < string.lower(b)
		end)

		board.SubjectOptions = subjectOptions
		if not board.SelectedSubject or not seen[string.lower(tostring(board.SelectedSubject))] then
			board.SelectedSubject = subjectOptions[1] or "UNASSIGNED"
		end
	end

	function SWEP:EnsureLawEnforcementBoard()
		self:EnsureRequestHistory()
		local persistedBoard = FOUNDATION_TABLET_PERSISTED_CLIENT_STATE.LawEnforcement
		self.LawEnforcementBoard = self.LawEnforcementBoard or FoundationTabletSanitizeLawEnforcementData(persistedBoard)
		self.LawEnforcementBoard = FoundationTabletSanitizeLawEnforcementData(self.LawEnforcementBoard)

		local board = self.LawEnforcementBoard

		if #self.RequestHistory > 0 then
			board.Tickets = self.RequestHistory
		elseif not board.Tickets or #board.Tickets == 0 then
			board.Tickets = {
				{id = "LE-QUEUE", subject = "NO ACTIVE REQUESTS", status = "STANDBY", action = "SUBMIT FROM REQUESTS TAB", unit = "F.E.", priority = "LOW", zone = "N/A", threat = "N/A", updated = os.date("%H:%M:%S"), notes = "Awaiting law enforcement requests."}
			}
		end

		board.SelectedTicket = math.Clamp(board.SelectedTicket or 1, 1, math.max(#board.Tickets, 1))
		self:RefreshLawEnforcementSubjects()
	end

	function SWEP:GetSelectedLawEnforcementTicket()
		self:EnsureLawEnforcementBoard()
		local board = self.LawEnforcementBoard
		return board.Tickets[board.SelectedTicket] or board.Tickets[1]
	end

	function SWEP:GetLawEnforcementSelectedSubject()
		self:EnsureLawEnforcementBoard()
		return tostring(self.LawEnforcementBoard.SelectedSubject or "UNASSIGNED")
	end

	function SWEP:SetLawEnforcementTab(tabId)
		self:EnsureLawEnforcementBoard()
		if not ({requests = true, fines = true, bols = true, arrests = true})[tabId] then return end

		self.LawEnforcementBoard.ActiveTab = tabId
		self.LawEnforcementBoard.SubjectMenuOpen = false
		self.AppScroll = 0
		self.AppScrollLerp = 0
		self.LawEntryScroll = 0
		self.LawEntryScrollLerp = 0
		self.LawEntryScrollMax = 0
		self.LawEntryScrollRegion = nil
		self.LawSubjectMenuScroll = 0
		self.LawSubjectMenuScrollLerp = 0
		self.LawSubjectMenuScrollMax = 0
		self.LawSubjectMenuRegion = nil
		self.LawRequestSubjectScroll = 0
		self.LawRequestSubjectScrollLerp = 0
		self.LawRequestSubjectScrollMax = 0
		self.LawRequestSubjectRegion = nil
		self:SetLawEnforcementStatus("FOUNDATION ENFORCEMENT // " .. string.upper(tabId))
	end

	function SWEP:CloseLawEnforcementSubjectMenu()
		self:EnsureLawEnforcementBoard()
		self.LawEnforcementBoard.SubjectMenuOpen = false
		self.LawSubjectMenuScroll = 0
		self.LawSubjectMenuScrollLerp = 0
		self.LawSubjectMenuScrollMax = 0
		self.LawSubjectMenuRegion = nil
	end

	function SWEP:OpenLawEnforcementSubjectMenu()
		self:EnsureLawEnforcementBoard()
		self:RefreshLawEnforcementSubjects()

		local board = self.LawEnforcementBoard
		board.SubjectMenuOpen = not board.SubjectMenuOpen
		self.LawSubjectMenuScroll = 0
		self.LawSubjectMenuScrollLerp = 0
		self.LawSubjectMenuScrollMax = 0
		self.LawSubjectMenuRegion = nil
		self:SetLawEnforcementStatus(board.SubjectMenuOpen and "SELECT EMPLOYEE FROM ACTIVE PLAYERS" or ("SUBJECT SELECTED // " .. string.upper(self:GetLawEnforcementSelectedSubject())))
	end

	function SWEP:OpenTabletQueryPrompt(config)
		if not istable(config) or not isfunction(config.onConfirm) or not vgui or not vgui.Create then return end

		if IsValid(self.ActiveTabletQueryFrame) then
			self.ActiveTabletQueryFrame:Remove()
		end

		local isMultiline = config.multiline == true
		local frameW = isMultiline and 560 or 500
		local frameH = isMultiline and 340 or 230
		local titleText = string.upper(tostring(config.title or "QUERY"))
		local promptText = tostring(config.promptText or "")
		local defaultText = tostring(config.defaultText or "")
		local acceptText = string.upper(tostring(config.acceptText or "SAVE"))
		local cancelText = string.upper(tostring(config.cancelText or "CANCEL"))
		local accentColor = config.accentColor or Color(120, 185, 255, 240)

		local frame = vgui.Create("DFrame")
		frame:SetSize(frameW, frameH)
		frame:Center()
		frame:SetTitle("")
		frame:ShowCloseButton(false)
		frame:SetSizable(false)
		frame:MakePopup()
		if frame.DoModal then
			frame:DoModal()
		end
		frame.OnRemove = function()
			if self.ActiveTabletQueryFrame == frame then
				self.ActiveTabletQueryFrame = nil
			end
		end
		self.ActiveTabletQueryFrame = frame

		local input = vgui.Create("DTextEntry", frame)
		input:SetFont("DeepGaming.FoundationTablet.HealthEmbeddedTitle")
		input:SetText(defaultText)
		input:SetUpdateOnType(true)
		if input.SetTextInset then
			input:SetTextInset(10, 8)
		end
		if isMultiline then
			input:SetMultiline(true)
			if input.SetEnterAllowed then
				input:SetEnterAllowed(true)
			end
		end

		local closeButton = vgui.Create("DButton", frame)
		closeButton:SetText("")

		local cancelButton = vgui.Create("DButton", frame)
		cancelButton:SetText("")
		cancelButton.Label = cancelText
		cancelButton.Accent = Color(220, 200, 160, 240)

		local confirmButton = vgui.Create("DButton", frame)
		confirmButton:SetText("")
		confirmButton.Label = acceptText
		confirmButton.Accent = accentColor

		local function closePrompt(runCancel)
			if runCancel and isfunction(config.onCancel) then
				config.onCancel()
			end

			if IsValid(frame) then
				frame:Remove()
			end
		end

		local function submitPrompt()
			local value = string.Trim(tostring(input:GetValue() or ""))
			config.onConfirm(value ~= "" and value or defaultText)
			closePrompt(false)
		end

		frame.Paint = function(panel, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(6, 8, 10, 245))
			draw.RoundedBox(0, 8, 8, w - 16, h - 16, Color(0, 0, 0, 215))
			surface.SetDrawColor(255, 255, 255, 38)
			surface.DrawOutlinedRect(0, 0, w, h, 2)
			surface.SetDrawColor(accentColor.r, accentColor.g, accentColor.b, 200)
			surface.DrawRect(12, 62, w - 24, 2)

			if FOUNDATION_TABLET_LOGO then
				local logoSize = math.min(w, h) * 0.42
				surface.SetMaterial(FOUNDATION_TABLET_LOGO)
				surface.SetDrawColor(255, 255, 255, 10)
				surface.DrawTexturedRect((w - logoSize) * 0.5, (h - logoSize) * 0.5, logoSize, logoSize)
			end

			draw.SimpleText(titleText, "DeepGaming.FoundationTablet.HealthSubtitle", 14, 12, Color(255, 255, 255, 245), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText("FOUNDATION TERMINAL", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 14, 40, accentColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			self:DrawWrappedTabletText(promptText, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 14, 76, Color(190, 200, 210, 230), TEXT_ALIGN_LEFT, w - 28)
		end

		input.Paint = function(textEntry, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(8, 12, 16, 240))
			surface.SetDrawColor(255, 255, 255, textEntry:HasFocus() and 220 or 140)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
			textEntry:DrawTextEntryText(Color(235, 235, 235, 245), accentColor, Color(255, 255, 255, 210))
		end

		closeButton.Paint = function(button, w, h)
			local hovered = button:IsHovered()
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, hovered and 235 or 210))
			surface.SetDrawColor(255, 255, 255, hovered and 180 or 90)
			draw.SimpleText("×", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", w * 0.5, h * 0.5, hovered and Color(255, 140, 140, 245) or Color(230, 230, 230, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local function paintActionButton(button, w, h)
			local hovered = button:IsHovered()
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, hovered and 236 or 220))
			surface.SetDrawColor(button.Accent.r, button.Accent.g, button.Accent.b, hovered and 220 or 145)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
			draw.SimpleText(button.Label or "ACTION", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", w * 0.5, h * 0.5, hovered and Color(255, 255, 255, 245) or button.Accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		cancelButton.Paint = paintActionButton
		confirmButton.Paint = paintActionButton

		closeButton.DoClick = function()
			closePrompt(true)
		end

		cancelButton.DoClick = function()
			closePrompt(true)
		end

		confirmButton.DoClick = submitPrompt
		if not isMultiline then
			input.OnEnter = submitPrompt
		end

		frame.PerformLayout = function(panel, w, h)
			local _, _, _, promptTextH = self:GetWrappedTextMetrics(promptText, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", w - 28)
			local inputY = 94 + promptTextH
			local inputH = isMultiline and math.max(120, h - inputY - 56) or 32
			input:SetPos(14, inputY)
			input:SetSize(w - 28, inputH)
			closeButton:SetPos(w - 38, 12)
			closeButton:SetSize(24, 22)
			cancelButton:SetPos(w - 218, h - 40)
			cancelButton:SetSize(96, 28)
			confirmButton:SetPos(w - 114, h - 40)
			confirmButton:SetSize(100, 28)
		end

		input:RequestFocus()
	end

	function SWEP:PromptLawEnforcementTextEntry(title, promptText, defaultText, onConfirm)
		if not isfunction(onConfirm) then return end

		self:OpenTabletQueryPrompt({
			title = title,
			promptText = promptText,
			defaultText = defaultText or "",
			acceptText = "SAVE",
			cancelText = "CANCEL",
			onConfirm = function(text)
				onConfirm(text ~= "" and text or (defaultText or "NO DETAILS PROVIDED"))
			end
		})
	end

	function SWEP:UpdateSelectedLawEnforcementTicket(subject, newStatus, newAction, newNotes)
		local selectedTicket = self:GetSelectedLawEnforcementTicket() or {}
		local selectedSubject = string.lower(string.Trim(tostring(subject or "")))
		if selectedSubject == "" then return end

		if selectedTicket.id and selectedTicket.id ~= "LE-QUEUE" and string.lower(tostring(selectedTicket.subject or "")) == selectedSubject then
			selectedTicket.status = newStatus or selectedTicket.status
			selectedTicket.action = newAction or selectedTicket.action
			selectedTicket.updated = os.date("%H:%M:%S")
			selectedTicket.notes = newNotes or selectedTicket.notes
		end
	end

	function SWEP:ResolveLawEnforcementRequest()
		self:EnsureRequestHistory()
		self:EnsureLawEnforcementBoard()

		local board = self.LawEnforcementBoard
		local selectedTicket = self:GetSelectedLawEnforcementTicket() or {}
		if not selectedTicket.id or selectedTicket.id == "LE-QUEUE" then
			self:SetLawEnforcementStatus("NO ACTIVE REQUEST TO RESOLVE")
			return
		end

		for index = #self.RequestHistory, 1, -1 do
			if self.RequestHistory[index] and self.RequestHistory[index].id == selectedTicket.id then
				table.remove(self.RequestHistory, index)
				break
			end
		end

		net.Start("DeepGaming.FoundationTablet.RequestResolve")
		net.WriteString(tostring(selectedTicket.id or "LE-0000"))
		net.SendToServer()

		if #self.RequestHistory > 0 then
			board.Tickets = self.RequestHistory
			board.SelectedTicket = math.Clamp(board.SelectedTicket, 1, #board.Tickets)
		else
			board.Tickets = {
				{id = "LE-QUEUE", subject = "NO ACTIVE REQUESTS", status = "STANDBY", action = "SUBMIT FROM REQUESTS TAB", unit = "F.E.", priority = "LOW", zone = "N/A", threat = "N/A", updated = os.date("%H:%M:%S"), notes = "Awaiting law enforcement requests."}
			}
			board.SelectedTicket = 1
		end

		self:SetLawEnforcementStatus("REQUEST RESOLVED // " .. tostring(selectedTicket.id))
		self:RefreshLawEnforcementSubjects()
		self.AppScroll = 0
		self.AppScrollLerp = 0
	end

	function SWEP:AddLawEnforcementAction(entryType, subject, details, timerText)
		self:EnsureLawEnforcementBoard()
		local board = self.LawEnforcementBoard
		local entry = {
			entryId = "LELOG-" .. tostring(os.time()) .. "-" .. tostring(math.random(1000, 9999)),
			type = entryType or "LOG",
			subject = subject or "UNKNOWN",
			details = details or "NO DETAILS PROVIDED",
			timer = timerText or "",
			posted = os.date("%H:%M:%S")
		}

		table.insert(board.ActionLog, 1, entry)
		if #board.ActionLog > 10 then
			table.remove(board.ActionLog, #board.ActionLog)
		end

		local targetList = entry.type == "FINE" and board.Fines or (entry.type == "BOL" and board.BOLs or board.ArrestLogs)
		table.insert(targetList, 1, entry)
		if #targetList > 10 then
			table.remove(targetList, #targetList)
		end

		board.SelectedSubject = subject or board.SelectedSubject
		self:RefreshLawEnforcementSubjects()
		FoundationTabletPushPersistentState(self.ResearchArchive, board)
	end

	function SWEP:DeleteLawEnforcementEntry(entryType, entryToDelete)
		self:EnsureLawEnforcementBoard()
		if not istable(entryToDelete) then return end

		local board = self.LawEnforcementBoard
		local deleteEntryId = tostring(entryToDelete.entryId or "")
		local deleteType = string.upper(tostring(entryToDelete.type or entryType or "LOG"))
		local deleteSubject = tostring(entryToDelete.subject or "UNKNOWN")
		local deleteDetails = tostring(entryToDelete.details or "")
		local deleteTimer = tostring(entryToDelete.timer or "")
		local deletePosted = tostring(entryToDelete.posted or "")

		for _, collection in ipairs({board.Fines or {}, board.BOLs or {}, board.ArrestLogs or {}, board.ActionLog or {}}) do
			for index = #collection, 1, -1 do
				local candidate = collection[index]
				local matchesEntryId = istable(candidate) and deleteEntryId ~= "" and tostring(candidate.entryId or "") == deleteEntryId
				local matchesFallback = istable(candidate)
					and string.upper(tostring(candidate.type or "")) == deleteType
					and tostring(candidate.subject or "") == deleteSubject
					and tostring(candidate.details or "") == deleteDetails
					and tostring(candidate.timer or "") == deleteTimer
					and tostring(candidate.posted or "") == deletePosted

				if candidate == entryToDelete or matchesEntryId or matchesFallback then
					table.remove(collection, index)
					break
				end
			end
		end

		self:SetLawEnforcementStatus(string.upper(entryType or "LOG") .. " ENTRY REMOVED // " .. tostring(entryToDelete.subject or "UNKNOWN"))
		self:RefreshLawEnforcementSubjects()
		FoundationTabletPushPersistentState(self.ResearchArchive, board)
	end

	function SWEP:IssueLawEnforcementFine()
		local selectedSubject = self:GetLawEnforcementSelectedSubject()
		local defaultText = selectedSubject .. " | 250C | POLICY VIOLATION"

		self:PromptLawEnforcementTextEntry("Issue Fine", "Enter subject, amount, and fine reason.", defaultText, function(text)
			local fineParts = string.Explode("|", text, false)
			local subject = string.Trim(fineParts[1] or selectedSubject or "SUBJECT")
			self:AddLawEnforcementAction("FINE", subject, text)
			self:UpdateSelectedLawEnforcementTicket(subject, "FINED", "FINE ISSUED", text)
			self:SetLawEnforcementStatus("FINE ISSUED // " .. string.upper(subject))
		end)
	end

	function SWEP:PlaceLawEnforcementBOL()
		local selectedSubject = self:GetLawEnforcementSelectedSubject()
		local defaultText = selectedSubject .. " | LAST SEEN AT CHECKPOINT | WATCHLIST ENTRY"

		self:PromptLawEnforcementTextEntry("Place BOL", "Enter the custom BOL notice.", defaultText, function(text)
			local bolParts = string.Explode("|", text, false)
			local subject = string.Trim(bolParts[1] or selectedSubject or "SUBJECT")
			self:AddLawEnforcementAction("BOL", subject, text)
			self:UpdateSelectedLawEnforcementTicket(subject, "FLAGGED", "BOL ACTIVE", text)
			self:SetLawEnforcementStatus("BOL PLACED // " .. string.upper(subject))
		end)
	end

	function SWEP:LogLawEnforcementArrest()
		local selectedSubject = self:GetLawEnforcementSelectedSubject()
		local defaultText = selectedSubject .. " | DETAINED FOR REVIEW"

		self:PromptLawEnforcementTextEntry("Arrest Log", "Enter the arrest note and subject.", defaultText, function(text)
			self:PromptLawEnforcementTextEntry("Arrest Timer", "Enter arrest timer in minutes.", "10", function(timerText)
				local minutes = tonumber(string.match(timerText, "%d+")) or 10
				local timerLabel = tostring(minutes) .. " MIN"
				local arrestParts = string.Explode("|", text, false)
				local subject = string.Trim(arrestParts[1] or selectedSubject or "SUBJECT")
				self:AddLawEnforcementAction("ARREST", subject, text, timerLabel)
				self:UpdateSelectedLawEnforcementTicket(subject, "ARRESTED", timerLabel .. " HOLD", text)
				self:SetLawEnforcementStatus("ARREST LOGGED // " .. string.upper(subject) .. " // " .. timerLabel)
			end)
		end)
	end

	function SWEP:CycleLawEnforcementTicket()
		self:EnsureLawEnforcementBoard()
		local board = self.LawEnforcementBoard
		if not board.Tickets or #board.Tickets == 0 then return end

		board.SelectedTicket = (board.SelectedTicket % #board.Tickets) + 1
		local selectedTicket = board.Tickets[board.SelectedTicket] or {}
		if selectedTicket.subject and selectedTicket.subject ~= "NO ACTIVE REQUESTS" then
			board.SelectedSubject = selectedTicket.subject
		end
		board.StatusNote = "VIEWING " .. tostring(selectedTicket.id or "REQUEST") .. " // " .. tostring(selectedTicket.status or "OPEN")
		self:RefreshLawEnforcementSubjects()
	end

	function SWEP:SetLawEnforcementStatus(text)
		self:EnsureLawEnforcementBoard()
		self.LawEnforcementBoard.StatusNote = text
	end

	function SWEP:EnsureBreachStatusBoard()
		local legacyNotes = {
			["Containment chamber is operating within expected parameters."] = true,
			["Security staff are reviewing unusual behavior and requesting an updated chamber report."] = true,
			["Containment access is sealed while command verifies the current threat posture."] = true,
			["Rapid response teams are actively engaged in containment recovery procedures."] = true,
			["Area returned to normal operations."] = true,
			["Security units are verifying a possible containment irregularity."] = true,
			["Blast doors sealed. Clearance is restricted until command review is complete."] = true,
			["Confirmed breach in progress. Response teams are actively containing the threat."] = true
		}

		local function buildDefaultEntries()
			local entries = {}
			for _, scpName in ipairs(FOUNDATION_BREACH_SUBJECTS) do
				table.insert(entries, {
					zone = scpName,
					status = "STABLE",
					updated = "--:--",
					note = ""
				})
			end

			return entries
		end

		self.BreachStatusBoard = self.BreachStatusBoard or {
			ActiveIndex = 1,
			SearchQuery = "",
			StatusNote = "SELECT AN SCP FILE",
			Entries = buildDefaultEntries()
		}

		local board = self.BreachStatusBoard
		board.Entries = board.Entries or {}
		board.SearchQuery = string.Trim(tostring(board.SearchQuery or ""))

		local knownSubjects = {}
		for _, scpName in ipairs(FOUNDATION_BREACH_SUBJECTS) do
			knownSubjects[string.upper(scpName)] = true
		end

		if #board.Entries == 0 or not knownSubjects[string.upper(tostring(board.Entries[1].zone or ""))] then
			board.Entries = buildDefaultEntries()
		end

		for index, entry in ipairs(board.Entries) do
			entry.zone = tostring(entry.zone or FOUNDATION_BREACH_SUBJECTS[index] or ("FILE " .. tostring(index)))
			entry.status = string.upper(tostring(entry.status or "STABLE"))
			entry.updated = string.Trim(tostring(entry.updated or "--:--"))
			if entry.updated == "" then
				entry.updated = "--:--"
			end

			local normalizedNote = string.Trim(tostring(entry.note or ""))
			if legacyNotes[normalizedNote] then
				entry.status = "STABLE"
				entry.updated = "--:--"
				normalizedNote = ""
			end
			entry.note = normalizedNote
		end

		board.ActiveIndex = math.Clamp(board.ActiveIndex or 1, 1, math.max(#board.Entries, 1))
		board.StatusNote = tostring(board.StatusNote or "SELECT A FILE")
	end

	function SWEP:GetFilteredBreachEntries()
		self:EnsureBreachStatusBoard()
		local board = self.BreachStatusBoard
		local query = string.Trim(string.lower(tostring(board.SearchQuery or "")))
		local filteredEntries = {}

		for index, entry in ipairs(board.Entries or {}) do
			local searchBlob = string.lower(table.concat({
				tostring(entry.zone or ""),
				tostring(entry.status or ""),
				tostring(entry.note or "")
			}, " "))

			if query == "" or string.find(searchBlob, query, 1, true) then
				table.insert(filteredEntries, {
					entry = entry,
					index = index
				})
			end
		end

		if #filteredEntries > 0 then
			local activeVisible = false
			for _, data in ipairs(filteredEntries) do
				if data.index == board.ActiveIndex then
					activeVisible = true
					break
				end
			end

			if not activeVisible then
				board.ActiveIndex = filteredEntries[1].index
			end
		end

		return filteredEntries, query
	end

	function SWEP:PromptBreachSearch()
		self:EnsureBreachStatusBoard()

		local currentQuery = tostring(self.BreachStatusBoard.SearchQuery or "")
		self:OpenTabletQueryPrompt({
			title = "SCP Search",
			promptText = "Enter an SCP name, status, or note fragment to look up.",
			defaultText = currentQuery,
			acceptText = "APPLY",
			cancelText = "CANCEL",
			onConfirm = function(text)
				local query = string.Trim(tostring(text or ""))
				local board = self.BreachStatusBoard
				board.SearchQuery = query
				local filteredEntries = select(1, self:GetFilteredBreachEntries())
				if filteredEntries[1] then
					board.ActiveIndex = filteredEntries[1].index
				end

				self.BreachListScroll = 0
				self.BreachListScrollLerp = 0
				self.BreachListScrollMax = 0
				self:ResetBreachDetailScroll()

				if query ~= "" then
					self:SetBreachMonitorStatus("SEARCH // " .. string.upper(query) .. " // " .. tostring(#filteredEntries) .. " MATCH" .. (#filteredEntries == 1 and "" or "ES"))
				else
					self:SetBreachMonitorStatus("SEARCH CLEARED // ALL SCP FILES")
				end
			end
		})
	end

	function SWEP:ClearBreachSearch()
		self:EnsureBreachStatusBoard()
		self.BreachStatusBoard.SearchQuery = ""
		self.BreachStatusBoard.ActiveIndex = 1
		self.BreachListScroll = 0
		self.BreachListScrollLerp = 0
		self.BreachListScrollMax = 0
		self:ResetBreachDetailScroll()
		self:SetBreachMonitorStatus("SEARCH CLEARED // ALL SCP FILES")
	end

	function SWEP:GetBreachStatusColor(status)
		status = string.upper(tostring(status or "STABLE"))
		for _, stateData in ipairs(FOUNDATION_BREACH_STATES) do
			if stateData.id == status then
				return stateData.color, stateData.response
			end
		end

		return Color(170, 180, 190, 220), "Monitor for further updates."
	end

	function SWEP:SetBreachMonitorStatus(text)
		self:EnsureBreachStatusBoard()
		self.BreachStatusBoard.StatusNote = tostring(text or "CONTAINMENT STATUS // STABLE")
	end

	function SWEP:ResetBreachDetailScroll()
		self.BreachNoteScroll = 0
		self.BreachNoteScrollLerp = 0
		self.BreachNoteScrollMax = 0
		self.BreachNoteScrollRegion = nil
		self.BreachDirectiveScroll = 0
		self.BreachDirectiveScrollLerp = 0
		self.BreachDirectiveScrollMax = 0
		self.BreachDirectiveScrollRegion = nil
	end

	function SWEP:GetActiveBreachEntry()
		self:EnsureBreachStatusBoard()
		local filteredEntries = select(1, self:GetFilteredBreachEntries())
		local board = self.BreachStatusBoard

		for _, data in ipairs(filteredEntries) do
			if data.index == board.ActiveIndex then
				return data.entry, data.index
			end
		end

		if filteredEntries[1] then
			board.ActiveIndex = filteredEntries[1].index
			return filteredEntries[1].entry, filteredEntries[1].index
		end

		return nil, nil
	end

	function SWEP:CycleBreachEntry()
		self:EnsureBreachStatusBoard()
		local board = self.BreachStatusBoard
		local filteredEntries = select(1, self:GetFilteredBreachEntries())
		if #filteredEntries == 0 then
			self:SetBreachMonitorStatus("NO SCP FILES MATCH CURRENT SEARCH")
			return
		end

		local currentPosition = 1
		for index, data in ipairs(filteredEntries) do
			if data.index == board.ActiveIndex then
				currentPosition = index
				break
			end
		end

		local nextData = filteredEntries[(currentPosition % #filteredEntries) + 1]
		board.ActiveIndex = nextData.index
		self:ResetBreachDetailScroll()
		local entry = nextData.entry or {}
		self:SetBreachMonitorStatus("SCP SELECTED // " .. tostring(entry.zone or "SCP FILE") .. " // " .. tostring(entry.status or "STABLE"))
	end

	function SWEP:SetActiveBreachStatus(statusId)
		local entry = self:GetActiveBreachEntry()
		if not entry then
			self:SetBreachMonitorStatus("NO SCP SELECTED")
			return
		end

		entry.status = string.upper(tostring(statusId or "STABLE"))
		entry.updated = os.date("%H:%M")
		self.BreachDirectiveScroll = 0
		self.BreachDirectiveScrollLerp = 0
		self.BreachDirectiveScrollMax = 0
		self.BreachDirectiveScrollRegion = nil
		self:SetBreachMonitorStatus(tostring(entry.zone or "SCP FILE") .. " // " .. entry.status)
	end

	function SWEP:AdvanceActiveBreachStatus()
		local entry = self:GetActiveBreachEntry()
		if not entry then
			self:SetBreachMonitorStatus("NO SCP SELECTED")
			return
		end

		local statusOrder = {}
		for index, stateData in ipairs(FOUNDATION_BREACH_STATES) do
			statusOrder[index] = stateData.id
		end

		local activeStatusIndex = 1
		for index, stageId in ipairs(statusOrder) do
			if stageId == entry.status then
				activeStatusIndex = index
				break
			end
		end

		activeStatusIndex = (activeStatusIndex % #statusOrder) + 1
		self:SetActiveBreachStatus(statusOrder[activeStatusIndex])
	end

	function SWEP:PromptBreachStatusNote()
		local entry = self:GetActiveBreachEntry()
		if not entry then
			self:SetBreachMonitorStatus("NO SCP SELECTED")
			return
		end

		self:OpenTabletQueryPrompt({
			title = "Containment Note",
			promptText = "Update the incident note for " .. tostring(entry.zone or "the selected SCP") .. ".",
			defaultText = tostring(entry.note or ""),
			acceptText = "SAVE",
			cancelText = "CANCEL",
			multiline = true,
			accentColor = self:GetBreachStatusColor(entry.status),
			onConfirm = function(text)
				entry.note = string.Trim(tostring(text or ""))
				entry.updated = os.date("%H:%M")
				self:SetBreachMonitorStatus((entry.note ~= "" and "CONTAINMENT NOTE UPDATED // " or "CONTAINMENT NOTE CLEARED // ") .. tostring(entry.zone or "SCP FILE"))
			end
		})
	end

	function SWEP:EnsureBulletinsBoard()
		self.BulletinsBoard = self.BulletinsBoard or {
			ActiveIndex = 1,
			FilterIndex = 1,
			DraftPriorityIndex = 1,
			StatusNote = "NO ACTIVE POSTS",
			Entries = {}
		}

		local board = self.BulletinsBoard
		board.Entries = board.Entries or {}
		board.StatusNote = board.StatusNote or ((#board.Entries > 0) and "SITE-WIDE UPDATES READY" or "NO ACTIVE POSTS")
		board.FilterIndex = math.Clamp(board.FilterIndex or 1, 1, #FOUNDATION_BULLETIN_FILTERS)
		board.DraftPriorityIndex = math.Clamp(board.DraftPriorityIndex or 2, 1, #FOUNDATION_BULLETIN_PRIORITIES)
		board.ActiveIndex = math.Clamp(board.ActiveIndex or 1, 1, math.max(#board.Entries, 1))
	end

	function SWEP:GetBulletinPriorityColor(priority)
		priority = string.upper(tostring(priority or "SITE"))
		if priority == "MTF" or priority == "CRITICAL" then
			return Color(255, 110, 110, 240)
		elseif priority == "SEC" or priority == "HIGH" then
			return Color(255, 175, 120, 240)
		elseif priority == "FE" then
			return Color(130, 220, 170, 240)
		elseif priority == "R&D" then
			return Color(160, 190, 255, 240)
		elseif priority == "SITE" or priority == "ROUTINE" then
			return Color(170, 180, 190, 220)
		end

		return Color(120, 185, 255, 240)
	end

	function SWEP:GetFilteredBulletinEntries()
		self:EnsureBulletinsBoard()
		local board = self.BulletinsBoard
		local activeFilter = FOUNDATION_BULLETIN_FILTERS[board.FilterIndex or 1] or "ALL"
		local filteredEntries = {}

		for index, entry in ipairs(board.Entries or {}) do
			local entryPriority = string.upper(tostring(entry.priority or "STANDARD"))
			if activeFilter == "ALL" or entryPriority == activeFilter then
				table.insert(filteredEntries, {
					entry = entry,
					index = index
				})
			end
		end

		if #filteredEntries > 0 then
			local activeVisible = false
			for _, data in ipairs(filteredEntries) do
				if data.index == board.ActiveIndex then
					activeVisible = true
					break
				end
			end

			if not activeVisible then
				board.ActiveIndex = filteredEntries[1].index
			end
		end

		return filteredEntries, activeFilter
	end

	function SWEP:GetActiveBulletinEntry()
		self:EnsureBulletinsBoard()
		local filteredEntries = select(1, self:GetFilteredBulletinEntries())
		local board = self.BulletinsBoard

		for _, data in ipairs(filteredEntries) do
			if data.index == board.ActiveIndex then
				return data.entry, data.index
			end
		end

		if filteredEntries[1] then
			board.ActiveIndex = filteredEntries[1].index
			return filteredEntries[1].entry, filteredEntries[1].index
		end

		return nil, nil
	end

	function SWEP:SetBulletinStatus(text)
		self:EnsureBulletinsBoard()
		self.BulletinsBoard.StatusNote = text
	end

	function SWEP:ResetBulletinDetailScroll()
		self.BulletinDetailScroll = 0
		self.BulletinDetailScrollLerp = 0
		self.BulletinDetailScrollMax = 0
		self.BulletinDetailScrollRegion = nil
	end

	function SWEP:CycleBulletin()
		self:EnsureBulletinsBoard()
		local board = self.BulletinsBoard
		local filteredEntries, activeFilter = self:GetFilteredBulletinEntries()
		if #filteredEntries == 0 then
			self:SetBulletinStatus("NO POSTS MATCH FILTER // " .. activeFilter)
			return
		end

		local visibleIndex = 1
		for index, data in ipairs(filteredEntries) do
			if data.index == board.ActiveIndex then
				visibleIndex = index
				break
			end
		end

		visibleIndex = (visibleIndex % #filteredEntries) + 1
		board.ActiveIndex = filteredEntries[visibleIndex].index
		self:ResetBulletinDetailScroll()
		self:SetBulletinStatus("VIEWING BULLETIN // " .. string.upper(tostring(filteredEntries[visibleIndex].entry.title or "POST")))
	end

	function SWEP:CycleBulletinFilter()
		self:EnsureBulletinsBoard()
		local board = self.BulletinsBoard
		board.FilterIndex = (board.FilterIndex % #FOUNDATION_BULLETIN_FILTERS) + 1
		local filteredEntries, activeFilter = self:GetFilteredBulletinEntries()
		self:ResetBulletinDetailScroll()
		self:SetBulletinStatus("FILTER // " .. activeFilter .. " // " .. tostring(#filteredEntries) .. " POSTS")
		if filteredEntries[1] then
			board.ActiveIndex = filteredEntries[1].index
		end
	end

	function SWEP:CycleBulletinPriority()
		if not self:CanPostBulletinsApp(LocalPlayer()) then
			self:SetBulletinStatus("POST ACCESS DENIED")
			return
		end

		self:EnsureBulletinsBoard()
		local board = self.BulletinsBoard
		board.DraftPriorityIndex = (board.DraftPriorityIndex % #FOUNDATION_BULLETIN_PRIORITIES) + 1
		local draftPriority = FOUNDATION_BULLETIN_PRIORITIES[board.DraftPriorityIndex] or "SITE"
		self:SetBulletinStatus("BULLETIN TYPE // " .. draftPriority)
	end

	function SWEP:CreateBulletinEntry()
		if not self:CanPostBulletinsApp(LocalPlayer()) then
			self:SetBulletinStatus("POST ACCESS DENIED")
			return
		end

		self:EnsureBulletinsBoard()

		local board = self.BulletinsBoard
		local draftPriority = FOUNDATION_BULLETIN_PRIORITIES[board.DraftPriorityIndex or 1] or "SITE"
		self:OpenTabletQueryPrompt({
			title = "Bulletin Title",
			promptText = "Enter the bulletin title.",
			defaultText = "SITE NOTICE",
			acceptText = "CONTINUE",
			cancelText = "CANCEL",
			onConfirm = function(titleText)
				titleText = string.Trim(tostring(titleText or ""))
				self:OpenTabletQueryPrompt({
					title = "Bulletin Details",
					promptText = "Enter the site-wide bulletin body.",
					defaultText = "",
					acceptText = "POST",
					cancelText = "CANCEL",
					multiline = true,
					onConfirm = function(bodyText)
						bodyText = string.Trim(tostring(bodyText or ""))
						local newEntry = {
							title = string.upper(titleText ~= "" and titleText or "SITE NOTICE"),
							priority = draftPriority,
							posted = os.date("%H:%M"),
							author = IsValid(LocalPlayer()) and LocalPlayer():Nick() or "LOCAL USER",
							acknowledged = false,
							body = bodyText ~= "" and bodyText or "NO DETAILS PROVIDED."
						}

						table.insert(board.Entries, 1, newEntry)
						board.ActiveIndex = 1
						board.FilterIndex = 1
						self:ResetBulletinDetailScroll()
						self:SetBulletinStatus("BULLETIN POSTED // " .. draftPriority .. " // " .. newEntry.title)

						net.Start("DeepGaming.FoundationTablet.BulletinDispatch")
						net.WriteString(tostring(newEntry.title or "SITE NOTICE"))
						net.WriteString(tostring(newEntry.priority or "SITE"))
						net.SendToServer()
					end
				})
			end
		})
	end

	function SWEP:ToggleBulletinAcknowledged()
		self:EnsureBulletinsBoard()
		local entry = self:GetActiveBulletinEntry()
		if not entry then
			self:SetBulletinStatus("NO BULLETIN SELECTED")
			return
		end

		entry.acknowledged = not entry.acknowledged
		entry.acknowledgedAt = entry.acknowledged and os.date("%H:%M:%S") or nil
		self:SetBulletinStatus((entry.acknowledged and "READ // " or "MARKED UNREAD // ") .. string.upper(tostring(entry.title or "BULLETIN")))
	end

	function SWEP:DeleteActiveBulletin()
		if not self:CanPostBulletinsApp(LocalPlayer()) then
			self:SetBulletinStatus("POST ACCESS DENIED")
			return
		end

		self:EnsureBulletinsBoard()
		local board = self.BulletinsBoard
		local entry, entryIndex = self:GetActiveBulletinEntry()
		if not entry or not entryIndex then
			self:SetBulletinStatus("NO BULLETIN SELECTED")
			return
		end

		local removedTitle = tostring(entry.title or "BULLETIN")
		table.remove(board.Entries, entryIndex)
		board.ActiveIndex = math.Clamp(board.ActiveIndex or 1, 1, math.max(#board.Entries, 1))
		self:ResetBulletinDetailScroll()
		self:SetBulletinStatus(#board.Entries > 0 and ("BULLETIN REMOVED // " .. string.upper(removedTitle)) or "NO ACTIVE POSTS")
	end

	function SWEP:EnsureResearchArchive()
		local defaultAuthor = IsValid(LocalPlayer()) and LocalPlayer():Nick() or "Research Division"
		local persistedArchive = FOUNDATION_TABLET_PERSISTED_CLIENT_STATE.ResearchArchive
		self.ResearchArchive = self.ResearchArchive or FoundationTabletSanitizeResearchArchiveData(persistedArchive, defaultAuthor)
		self.ResearchArchive = FoundationTabletSanitizeResearchArchiveData(self.ResearchArchive, defaultAuthor)

		local board = self.ResearchArchive
		board.Entries = board.Entries or {}
		board.ActivityLog = board.ActivityLog or {}
		board.SearchQuery = tostring(board.SearchQuery or "")
		board.StatusNote = board.StatusNote or "RESEARCH DOCUMENTS READY"

		for _, entry in ipairs(board.Entries) do
			self:NormalizeResearchDocument(entry)
		end

		board.ActiveIndex = math.Clamp(board.ActiveIndex or 1, 1, math.max(#board.Entries, 1))
	end

	function SWEP:NormalizeResearchDocument(entry)
		return FoundationTabletNormalizeResearchDocumentData(entry)
	end

	function SWEP:GetResearchDocumentPageText(entry)
		entry = self:NormalizeResearchDocument(entry)
		if not entry then
			return "No notes have been entered yet.", 1, 1
		end

		local pageIndex = math.Clamp(tonumber(entry.page) or 1, 1, #entry.pages)
		return tostring(entry.pages[pageIndex] or "No notes have been entered yet."), pageIndex, #entry.pages
	end

	function SWEP:ChangeResearchDocumentPage(direction)
		local entry = self:GetActiveResearchDocument()
		if not entry then
			self:SetResearchArchiveStatus("NO FILE SELECTED")
			return
		end

		self:NormalizeResearchDocument(entry)
		local pageCount = #entry.pages
		if pageCount <= 1 then return end

		local nextPage = math.Clamp((entry.page or 1) + (tonumber(direction) or 0), 1, pageCount)
		if nextPage == entry.page then return end

		entry.page = nextPage
		entry.body = entry.pages[nextPage] or entry.body
		entry.lastViewed = os.date("%H:%M:%S")
		self:SetResearchArchiveStatus("PAGE " .. tostring(nextPage) .. " / " .. tostring(pageCount) .. " // " .. string.upper(tostring(entry.title or "UNTITLED")))
		self:ResetResearchArchiveViewerScroll()
	end

	function SWEP:DeleteResearchDocument(entryIndex)
		self:EnsureResearchArchive()
		local board = self.ResearchArchive
		local entry = board.Entries[entryIndex]
		if not entry then
			self:SetResearchArchiveStatus("NO FILE SELECTED")
			return
		end

		local removedTitle = tostring(entry.title or entry.fileId or "DOCUMENT")
		local removedId = tostring(entry.fileId or "RD-000")
		table.remove(board.Entries, entryIndex)

		if #board.Entries > 0 then
			board.ActiveIndex = math.Clamp(entryIndex, 1, #board.Entries)
			local nextEntry = board.Entries[board.ActiveIndex]
			if nextEntry then
				self:NormalizeResearchDocument(nextEntry)
			end
			self:SetResearchArchiveStatus("FILE REMOVED // " .. string.upper(removedTitle))
		else
			board.ActiveIndex = 1
			self:SetResearchArchiveStatus("NO RESEARCH FILES")
		end

		self:LogResearchArchiveEvent("DELETE", "Removed " .. removedTitle, removedId)
		FoundationTabletPushPersistentState(board, self.LawEnforcementBoard)
		self:ResetResearchArchiveViewerScroll()
	end

	function SWEP:SetResearchArchiveStatus(text)
		self:EnsureResearchArchive()
		self.ResearchArchive.StatusNote = tostring(text or "RESEARCH DOCUMENTS READY")
	end

	function SWEP:ResetResearchArchiveViewerScroll()
		self.ResearchViewerScroll = 0
		self.ResearchViewerScrollLerp = 0
		self.ResearchViewerScrollMax = 0
		self.ResearchViewerScrollRegion = nil
	end

	function SWEP:LogResearchArchiveEvent(eventType, message, fileId)
		self:EnsureResearchArchive()
		local board = self.ResearchArchive

		table.insert(board.ActivityLog, 1, {
			type = string.upper(tostring(eventType or "LOG")),
			text = tostring(message or "NO DETAILS PROVIDED"),
			fileId = tostring(fileId or ""),
			user = IsValid(LocalPlayer()) and LocalPlayer():Nick() or "LOCAL USER",
			posted = os.date("%H:%M:%S")
		})

		if #board.ActivityLog > 10 then
			table.remove(board.ActivityLog, #board.ActivityLog)
		end
	end

	function SWEP:GetFilteredResearchDocuments()
		self:EnsureResearchArchive()
		local board = self.ResearchArchive
		local query = string.Trim(string.lower(tostring(board.SearchQuery or "")))
		local filteredEntries = {}

		for index, entry in ipairs(board.Entries or {}) do
			self:NormalizeResearchDocument(entry)
			local pageText = table.concat(entry.pages or {}, " ")
			local searchBlob = string.lower(table.concat({
				tostring(entry.fileId or ""),
				tostring(entry.title or ""),
				tostring(pageText or "")
			}, " "))

			if query == "" or string.find(searchBlob, query, 1, true) then
				table.insert(filteredEntries, {
					entry = entry,
					index = index
				})
			end
		end

		if #filteredEntries > 0 then
			local activeVisible = false
			for _, data in ipairs(filteredEntries) do
				if data.index == board.ActiveIndex then
					activeVisible = true
					break
				end
			end

			if not activeVisible then
				board.ActiveIndex = filteredEntries[1].index
			end
		end

		return filteredEntries, query
	end

	function SWEP:GetActiveResearchDocument()
		self:EnsureResearchArchive()
		local filteredEntries = select(1, self:GetFilteredResearchDocuments())
		local board = self.ResearchArchive

		for _, data in ipairs(filteredEntries) do
			if data.index == board.ActiveIndex then
				self:NormalizeResearchDocument(data.entry)
				return data.entry, data.index
			end
		end

		if filteredEntries[1] then
			board.ActiveIndex = filteredEntries[1].index
			self:NormalizeResearchDocument(filteredEntries[1].entry)
			return filteredEntries[1].entry, filteredEntries[1].index
		end

		return nil, nil
	end

	function SWEP:SelectResearchDocument(entryIndex, suppressAudit)
		self:EnsureResearchArchive()
		local board = self.ResearchArchive
		local entry = board.Entries[entryIndex]
		if not entry then return end

		self:NormalizeResearchDocument(entry)
		board.ActiveIndex = entryIndex
		entry.lastViewed = os.date("%H:%M:%S")

		if not suppressAudit then
			self:LogResearchArchiveEvent("VIEW", "Opened " .. tostring(entry.title or entry.fileId or "FILE"), entry.fileId)
		end

		local _, pageIndex, pageCount = self:GetResearchDocumentPageText(entry)
		self:SetResearchArchiveStatus("VIEWING FILE // " .. tostring(entry.fileId or "RD-000") .. " // PAGE " .. tostring(pageIndex) .. " / " .. tostring(pageCount))
		self:ResetResearchArchiveViewerScroll()
	end

	function SWEP:PromptResearchSearch()
		self:EnsureResearchArchive()

		local currentQuery = tostring(self.ResearchArchive.SearchQuery or "")
		self:OpenTabletQueryPrompt({
			title = "Research Search",
			promptText = "Enter a file name, ID, or text fragment to look up.",
			defaultText = currentQuery,
			acceptText = "APPLY",
			cancelText = "CANCEL",
			onConfirm = function(text)
				local query = string.Trim(tostring(text or ""))
				local board = self.ResearchArchive
				board.SearchQuery = query
				local filteredEntries = select(1, self:GetFilteredResearchDocuments())
				if filteredEntries[1] then
					board.ActiveIndex = filteredEntries[1].index
				end

				self:SetResearchArchiveStatus(query ~= "" and ("SEARCH // " .. string.upper(query) .. " // " .. tostring(#filteredEntries) .. " MATCHES") or "SEARCH CLEARED // ALL FILES")
				self:LogResearchArchiveEvent("LOOKUP", query ~= "" and ("Searched for " .. query) or "Cleared file search")
				self:ResetResearchArchiveViewerScroll()
			end
		})
	end

	function SWEP:ClearResearchSearch()
		self:EnsureResearchArchive()
		self.ResearchArchive.SearchQuery = ""
		self.ResearchArchive.ActiveIndex = 1
		self:SetResearchArchiveStatus("SEARCH CLEARED // ALL FILES")
		self:LogResearchArchiveEvent("LOOKUP", "Cleared file search")
		self:ResetResearchArchiveViewerScroll()
	end

	function SWEP:OpenResearchDocumentEditor(entryIndex, addPage)
		self:EnsureResearchArchive()
		if not vgui or not vgui.Create then return end

		local board = self.ResearchArchive
		local entry = entryIndex and board.Entries[entryIndex] or nil
		if addPage and not entry then
			self:SetResearchArchiveStatus("NO FILE SELECTED")
			return
		end

		if IsValid(self.ResearchEditorFrame) then
			self.ResearchEditorFrame:Remove()
		end

		if entry then
			self:NormalizeResearchDocument(entry)
		end

		local currentPageText, currentPageIndex, currentPageCount = "", 1, 1
		if entry then
			currentPageText, currentPageIndex, currentPageCount = self:GetResearchDocumentPageText(entry)
		end

		local accentColor = Color(120, 185, 255, 240)
		local frameTitle = string.upper(addPage and "Add Research Page" or (entry and "Edit Research Document" or "Create Research Document"))
		local frame = vgui.Create("DFrame")
		frame:SetSize(560, 470)
		frame:Center()
		frame:SetTitle("")
		frame:SetSizable(false)
		frame:MakePopup()
		if frame.DoModal then
			frame:DoModal()
		end
		frame:ShowCloseButton(false)
		frame.OnRemove = function()
			if self.ResearchEditorFrame == frame then
				self.ResearchEditorFrame = nil
			end
		end
		self.ResearchEditorFrame = frame

		local titleLabel = vgui.Create("DLabel", frame)
		titleLabel:SetText("DOCUMENT TITLE")
		titleLabel:SetFont("DeepGaming.FoundationTablet.HealthEmbeddedTitle")
		titleLabel:SetTextColor(Color(230, 230, 230))

		local titleEntry = vgui.Create("DTextEntry", frame)
		titleEntry:SetFont("DeepGaming.FoundationTablet.HealthEmbeddedTitle")
		titleEntry:SetText(entry and tostring(entry.title or "") or "")
		titleEntry:SetUpdateOnType(true)
		if titleEntry.SetTextInset then
			titleEntry:SetTextInset(10, 8)
		end

		local bodyLabel = vgui.Create("DLabel", frame)
		bodyLabel:SetText(string.upper(addPage and ("Page " .. tostring((currentPageCount or 0) + 1) .. " Text") or ("Text")))
		bodyLabel:SetFont("DeepGaming.FoundationTablet.HealthEmbeddedTitle")
		bodyLabel:SetTextColor(Color(230, 230, 230))

		local bodyEntry = vgui.Create("DTextEntry", frame)
		bodyEntry:SetFont("DeepGaming.FoundationTablet.HealthEmbeddedTitle")
		bodyEntry:SetMultiline(true)
		bodyEntry:SetText(addPage and "" or tostring(currentPageText or ""))
		bodyEntry:SetUpdateOnType(true)
		if bodyEntry.SetTextInset then
			bodyEntry:SetTextInset(10, 8)
		end
		if bodyEntry.SetEnterAllowed then
			bodyEntry:SetEnterAllowed(true)
		end

		local closeButton = vgui.Create("DButton", frame)
		closeButton:SetText("")

		local cancelButton = vgui.Create("DButton", frame)
		cancelButton:SetText("")
		cancelButton.Label = "CANCEL"
		cancelButton.Accent = Color(220, 200, 160, 240)
		cancelButton.DoClick = function()
			if IsValid(frame) then
				frame:Remove()
			end
		end

		local saveButton = vgui.Create("DButton", frame)
		saveButton:SetText("")
		saveButton.Label = string.upper(addPage and "Add Page" or (entry and "Save Page" or "Create"))
		saveButton.Accent = accentColor

		if addPage then
			titleEntry:SetEnabled(false)
		end

		frame.Paint = function(panel, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(6, 8, 10, 245))
			draw.RoundedBox(0, 8, 8, w - 16, h - 16, Color(0, 0, 0, 215))
			surface.SetDrawColor(255, 255, 255, 38)
			surface.DrawOutlinedRect(0, 0, w, h, 2)
			surface.SetDrawColor(accentColor.r, accentColor.g, accentColor.b, 200)
			surface.DrawRect(12, 62, w - 24, 2)

			if FOUNDATION_TABLET_LOGO then
				local logoSize = math.min(w, h) * 0.42
				surface.SetMaterial(FOUNDATION_TABLET_LOGO)
				surface.SetDrawColor(255, 255, 255, 10)
				surface.DrawTexturedRect((w - logoSize) * 0.5, (h - logoSize) * 0.5, logoSize, logoSize)
			end

			draw.SimpleText(frameTitle, "DeepGaming.FoundationTablet.HealthSubtitle", 14, 12, Color(255, 255, 255, 245), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText("FOUNDATION TERMINAL", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 14, 40, accentColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end

		titleEntry.Paint = function(textEntry, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(8, 12, 16, 240))
			surface.SetDrawColor(255, 255, 255, textEntry:HasFocus() and 220 or 140)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
			textEntry:DrawTextEntryText(Color(235, 235, 235, 245), accentColor, Color(255, 255, 255, 210))
		end

		bodyEntry.Paint = function(textEntry, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(8, 12, 16, 240))
			surface.SetDrawColor(255, 255, 255, textEntry:HasFocus() and 220 or 140)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
			textEntry:DrawTextEntryText(Color(235, 235, 235, 245), accentColor, Color(255, 255, 255, 210))
		end

		closeButton.Paint = function(button, w, h)
			local hovered = button:IsHovered()
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, hovered and 235 or 210))
			surface.SetDrawColor(255, 255, 255, hovered and 180 or 90)
			draw.SimpleText("×", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", w * 0.5, h * 0.5, hovered and Color(255, 140, 140, 245) or Color(230, 230, 230, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local function paintEditorButton(button, w, h)
			local hovered = button:IsHovered()
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, hovered and 236 or 220))
			surface.SetDrawColor(button.Accent.r, button.Accent.g, button.Accent.b, hovered and 220 or 145)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
			draw.SimpleText(button.Label or "ACTION", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", w * 0.5, h * 0.5, hovered and Color(255, 255, 255, 245) or button.Accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		cancelButton.Paint = paintEditorButton
		saveButton.Paint = paintEditorButton

		closeButton.DoClick = function()
			if IsValid(frame) then
				frame:Remove()
			end
		end

		frame.PerformLayout = function(panel, w, h)
			titleLabel:SetPos(12, 74)
			titleLabel:SizeToContents()
			titleEntry:SetPos(12, 96)
			titleEntry:SetSize(w - 24, 30)
			bodyLabel:SetPos(12, 136)
			bodyLabel:SizeToContents()
			bodyEntry:SetPos(12, 158)
			bodyEntry:SetSize(w - 24, h - 214)
			closeButton:SetPos(w - 38, 12)
			closeButton:SetSize(24, 22)
			cancelButton:SetPos(w - 218, h - 40)
			cancelButton:SetSize(96, 28)
			saveButton:SetPos(w - 114, h - 40)
			saveButton:SetSize(100, 28)
		end

		saveButton.DoClick = function()
			local newTitle = string.Trim(tostring(titleEntry:GetValue() or ""))
			local newText = string.Trim(tostring(bodyEntry:GetValue() or ""))
			local authorName = IsValid(LocalPlayer()) and LocalPlayer():Nick() or "LOCAL USER"
			if newTitle == "" then
				newTitle = "Untitled Research File"
			end

			if addPage and entry then
				if newText == "" then
					newText = "This page is blank."
				end

				self:NormalizeResearchDocument(entry)
				entry.title = newTitle
				table.insert(entry.pages, newText)
				entry.page = #entry.pages
				entry.body = newText
				entry.updated = os.date("%H:%M")
				self:SetResearchArchiveStatus("PAGE ADDED // " .. string.upper(newTitle))
				self:LogResearchArchiveEvent("PAGE", "Added page " .. tostring(entry.page) .. " to " .. newTitle, entry.fileId)
			elseif entry then
				self:NormalizeResearchDocument(entry)
				local pageIndex = math.Clamp(tonumber(entry.page) or 1, 1, #entry.pages)
				entry.title = newTitle
				entry.pages[pageIndex] = newText ~= "" and newText or "No notes have been entered yet."
				entry.body = entry.pages[pageIndex]
				entry.updated = os.date("%H:%M")
				self:SetResearchArchiveStatus("PAGE SAVED // " .. string.upper(newTitle) .. " // " .. tostring(pageIndex))
				self:LogResearchArchiveEvent("EDIT", "Updated page " .. tostring(pageIndex) .. " of " .. newTitle, entry.fileId)
			else
				local newEntry = {
					fileId = string.format("RD-%03d", #board.Entries + 1),
					title = newTitle,
					pages = {newText ~= "" and newText or "No notes have been entered yet."},
					page = 1,
					author = authorName,
					created = os.date("%m/%d %H:%M"),
					updated = os.date("%H:%M")
				}
				board.SearchQuery = ""
				table.insert(board.Entries, 1, newEntry)
				board.ActiveIndex = 1
				self:SetResearchArchiveStatus("NEW FILE CREATED // " .. newEntry.fileId)
				self:LogResearchArchiveEvent("CREATE", "Created " .. newTitle, newEntry.fileId)
			end

			self:ResetResearchArchiveViewerScroll()
			FoundationTabletPushPersistentState(board, self.LawEnforcementBoard)
			if IsValid(frame) then
				frame:Remove()
			end
		end

		if addPage then
			bodyEntry:RequestFocus()
		else
			titleEntry:RequestFocus()
		end
	end

	function SWEP:CreateResearchDocument()
		self:OpenResearchDocumentEditor(nil, false)
	end

	function SWEP:EditActiveResearchDocument()
		local _, entryIndex = self:GetActiveResearchDocument()
		if not entryIndex then
			self:SetResearchArchiveStatus("NO FILE SELECTED")
			return
		end

		self:OpenResearchDocumentEditor(entryIndex, false)
	end

	function SWEP:AddResearchPage()
		local _, entryIndex = self:GetActiveResearchDocument()
		if not entryIndex then
			self:SetResearchArchiveStatus("NO FILE SELECTED")
			return
		end

		self:OpenResearchDocumentEditor(entryIndex, true)
	end

	function SWEP:AddResearchParagraph()
		self:AddResearchPage()
	end

	function SWEP:WrapTabletText(text, font, maxWidth)
		text = tostring(text or "")
		surface.SetFont(font)

		local function splitLongWord(word)
			local chunks = {}
			local working = tostring(word or "")
			while working ~= "" do
				local slice = ""
				for i = 1, #working do
					local candidate = string.sub(working, 1, i)
					local candidateW = surface.GetTextSize(candidate)
					if candidateW > maxWidth and slice ~= "" then
						break
					end
					slice = candidate
				end

				if slice == "" then
					slice = string.sub(working, 1, 1)
				end

				table.insert(chunks, slice)
				working = string.sub(working, #slice + 1)
			end
			return chunks
		end

		local wrappedLines = {}
		for _, rawLine in ipairs(string.Explode("\n", text, false)) do
			local currentLine = ""
			for word in string.gmatch(rawLine, "%S+") do
				local wordsToProcess = {word}
				if surface.GetTextSize(word) > maxWidth then
					wordsToProcess = splitLongWord(word)
				end

				for _, part in ipairs(wordsToProcess) do
					local candidate = currentLine == "" and part or (currentLine .. " " .. part)
					local candidateW = surface.GetTextSize(candidate)
					if currentLine == "" or candidateW <= maxWidth then
						currentLine = candidate
					else
						table.insert(wrappedLines, currentLine)
						currentLine = part
					end
				end
			end

			if currentLine == "" then
				table.insert(wrappedLines, rawLine == "" and "" or currentLine)
			else
				table.insert(wrappedLines, currentLine)
			end
		end

		if #wrappedLines == 0 then
			table.insert(wrappedLines, "")
		end

		return table.concat(wrappedLines, "\n")
	end

	function SWEP:GetWrappedTextMetrics(text, font, maxWidth)
		local wrappedText = self:WrapTabletText(text, font, maxWidth)
		surface.SetFont(font)
		local _, lineH = surface.GetTextSize("TEXT")
		local lineCount = select(2, string.gsub(wrappedText, "\n", "\n")) + 1
		local textH = lineCount * lineH
		return wrappedText, lineCount, lineH, textH
	end

	function SWEP:DrawWrappedTabletText(text, font, x, y, color, align, maxWidth)
		local wrappedText = self:WrapTabletText(text, font, maxWidth)
		draw.DrawText(wrappedText, font, x, y, color, align or TEXT_ALIGN_LEFT)
		surface.SetFont(font)
		local _, lineH = surface.GetTextSize("TEXT")
		local lineCount = select(2, string.gsub(wrappedText, "\n", "\n")) + 1
		return lineCount * lineH, wrappedText
	end

	function SWEP:GetRequestFieldHeight(w, minH, value, font)
		local targetFont = font or "DeepGaming.FoundationTablet.HealthEmbeddedTitle"
		local wrappedValue, _, lineH = self:GetWrappedTextMetrics(value, targetFont, math.max(32, w - 24))
		local lineCount = select(2, string.gsub(wrappedValue, "\n", "\n")) + 1
		local boxH = math.max(minH or 0, 34 + (lineCount * lineH) + 10)
		return boxH, wrappedValue
	end

	function SWEP:ResetTabletViewScroll()
		self.RequestsScroll = 0
		self.RequestsScrollLerp = 0
		self.AppScroll = 0
		self.AppScrollLerp = 0
		self.LawEntryScroll = 0
		self.LawEntryScrollLerp = 0
		self.LawEntryScrollMax = 0
		self.LawEntryScrollRegion = nil
		self.LawSubjectMenuScroll = 0
		self.LawSubjectMenuScrollLerp = 0
		self.LawSubjectMenuScrollMax = 0
		self.LawSubjectMenuRegion = nil
		self.LawRequestSubjectScroll = 0
		self.LawRequestSubjectScrollLerp = 0
		self.LawRequestSubjectScrollMax = 0
		self.LawRequestSubjectRegion = nil
		self.BulletinDetailScroll = 0
		self.BulletinDetailScrollLerp = 0
		self.BulletinDetailScrollMax = 0
		self.BulletinDetailScrollRegion = nil
		self.ResearchViewerScroll = 0
		self.ResearchViewerScrollLerp = 0
		self.ResearchViewerScrollMax = 0
		self.ResearchViewerScrollRegion = nil
		self.ActiveTabletScrollMax = 0
	end

	function SWEP:GetTabletCursorLocal(screenW, screenH)
		local mx, my = gui.MousePos()
		if mx <= 0 and my <= 0 then
			mx, my = ScrW() * 0.5, ScrH() * 0.5
		end

		local cursorSensitivityX = 1.55
		local cursorSensitivityY = 1.7
		local cursorRangeX = (screenW * 0.5) * 0.96
		local cursorRangeY = (screenH * 0.5) * 0.90
		local cursorX = math.Clamp((((mx / ScrW()) - 0.5) * cursorRangeX * 2) * cursorSensitivityX, -cursorRangeX, cursorRangeX)
		local cursorY = math.Clamp((((my / ScrH()) - 0.5) * cursorRangeY * 2) * cursorSensitivityY, -cursorRangeY, cursorRangeY)

		self.TabletCursorX = cursorX
		self.TabletCursorY = cursorY

		return cursorX, cursorY
	end

	function SWEP:DrawApplicationCard(x, y, w, h, appData)
		local canAccess = self:CanAccessTabletApplication(appData, LocalPlayer())
		local hovered = canAccess and self.TabletCursorX and self.TabletCursorY
			and self.TabletCursorX >= x and self.TabletCursorX <= (x + w)
			and self.TabletCursorY >= y and self.TabletCursorY <= (y + h)

		local centerX = x + (w * 0.5)
		local isSquare = math.abs(w - h) <= 12 or w < (h * 1.5)
		local titleColor = canAccess and Color(255, 255, 255, 245) or Color(190, 195, 205, 190)
		local detailColor = canAccess and Color(170, 180, 190, 220) or Color(255, 170, 120, 220)

		draw.RoundedBox(0, x, y, w, h, Color(0, 0, 0, canAccess and 245 or 230))
		surface.SetDrawColor(255, 255, 255, canAccess and (hovered and 210 or 140) or 75)
		surface.DrawOutlinedRect(x, y, w, h, 2)
		surface.DrawOutlinedRect(x + 1, y + 1, w - 2, h - 2, 1)

		if isSquare then
			local iconOnly = appData.iconOnly == true
			local markSize = math.min(w, h) * (iconOnly and 0.58 or 0.72)
			local markX = centerX - (markSize * 0.5)
			local markY = y + ((h - markSize) * 0.5) - (iconOnly and 0 or 8)
			if appData.icon then
				surface.SetMaterial(appData.icon)
				surface.SetDrawColor(255, 255, 255, canAccess and (hovered and (iconOnly and 235 or 26) or (iconOnly and 190 or 14)) or (iconOnly and 95 or 10))
				surface.DrawTexturedRect(markX, markY, markSize, markSize)
			elseif FOUNDATION_TABLET_LOGO and not iconOnly then
				surface.SetMaterial(FOUNDATION_TABLET_LOGO)
				surface.SetDrawColor(255, 255, 255, canAccess and (hovered and 26 or 14) or 8)
				surface.DrawTexturedRect(markX, markY, markSize, markSize)
			end

			if not iconOnly then
				local titleRaw = string.upper(appData.title or "APPLICATION")
				local subtitleRaw = string.upper((not canAccess and (appData.deniedText or "LOCKED")) or (appData.text or ""))
				local titleFont = (#titleRaw > 12 or string.find(titleRaw, "\n", 1, true)) and "DeepGaming.FoundationTablet.HealthEmbeddedTitle" or "DeepGaming.FoundationTablet.HealthSubtitle"
				local wrappedTitleText, _, _, titleTextH = self:GetWrappedTextMetrics(titleRaw, titleFont, math.max(40, w - 14))
				local titleY = y + h - (subtitleRaw ~= "" and 30 or 16) - titleTextH
				draw.DrawText(wrappedTitleText, titleFont, centerX, titleY, titleColor, TEXT_ALIGN_CENTER)
				if subtitleRaw ~= "" then
					local wrappedSubtitleText, _, _, subtitleTextH = self:GetWrappedTextMetrics(subtitleRaw, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", math.max(40, w - 14))
					draw.DrawText(wrappedSubtitleText, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", centerX, y + h - 8 - subtitleTextH, Color(255,100,100), TEXT_ALIGN_CENTER)
				end
			end
		else
			if appData.icon then
				surface.SetMaterial(appData.icon)
				surface.SetDrawColor(255, 255, 255, canAccess and (hovered and 220 or 185) or 95)
				surface.DrawTexturedRect(x + 16, y + 18, 26, 26)
			elseif FOUNDATION_TABLET_LOGO then
				surface.SetMaterial(FOUNDATION_TABLET_LOGO)
				surface.SetDrawColor(255, 255, 255, canAccess and (hovered and 20 or 10) or 6)
				surface.DrawTexturedRect(x + 16, y + 14, 34, 34)
			end

			self:DrawWrappedTabletText(appData.title or "APPLICATION", "DeepGaming.FoundationTablet.HealthSubtitle", x + 58, y + 14, titleColor, TEXT_ALIGN_LEFT, math.max(40, w - 72))
			local detailText = (not canAccess and (appData.deniedText or "LOCKED")) or appData.text
			if detailText and detailText ~= "" then
				self:DrawWrappedTabletText(detailText, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", x + 58, y + 44, Color(255,100,100), TEXT_ALIGN_LEFT, math.max(40, w - 72))
			end
		end

		if appData.onClick and canAccess then
			table.insert(self.TabletClickableRegions, {
				x = x,
				y = y,
				w = w,
				h = h,
				onClick = appData.onClick
			})
		end
	end

	function SWEP:DrawRequestField(x, y, w, h, label, value, onClick, accentColor)
		local boxH, wrappedValue = self:GetRequestFieldHeight(w, h, value)
		local hovered = self.TabletCursorX and self.TabletCursorY
			and self.TabletCursorX >= x and self.TabletCursorX <= (x + w)
			and self.TabletCursorY >= y and self.TabletCursorY <= (y + boxH)

		draw.RoundedBox(0, x, y, w, boxH, Color(0, 0, 0, 232))
		surface.SetDrawColor(255, 255, 255, hovered and 205 or 135)
		surface.DrawOutlinedRect(x, y, w, boxH, 2)
		surface.DrawOutlinedRect(x + 1, y + 1, w - 2, boxH - 2, 1)

		draw.SimpleText(label, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", x + 12, y + 9, Color(165, 180, 195, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.DrawText(wrappedValue, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", x + 12, y + 28, accentColor or Color(255, 255, 255, 240), TEXT_ALIGN_LEFT)

		if onClick then
			table.insert(self.TabletClickableRegions, {
				x = x,
				y = y,
				w = w,
				h = boxH,
				onClick = onClick
			})
		end

		return boxH
	end

	function SWEP:DrawTabletTabButton(x, y, w, h, label, isActive, onClick, accentColor)
		local hovered = self.TabletCursorX and self.TabletCursorY
			and self.TabletCursorX >= x and self.TabletCursorX <= (x + w)
			and self.TabletCursorY >= y and self.TabletCursorY <= (y + h)

		local hasAccent = IsColor(accentColor)
		local backgroundColor = isActive and Color(18, 30, 42, 240) or Color(0, 0, 0, 230)
		local outlineColor = Color(255, 255, 255, isActive and 155 or (hovered and 115 or 70))
		local innerOutlineColor = Color(255, 255, 255, isActive and 90 or (hovered and 65 or 35))
		local textColor = isActive and Color(120, 185, 255, 245) or Color(235, 235, 235, hovered and 245 or 220)

		if hasAccent then
			backgroundColor = isActive
				and Color(math.Clamp(math.floor(accentColor.r * 0.22), 0, 255), math.Clamp(math.floor(accentColor.g * 0.22), 0, 255), math.Clamp(math.floor(accentColor.b * 0.22), 0, 255), 245)
				or Color(math.Clamp(math.floor(accentColor.r * 0.1), 0, 255), math.Clamp(math.floor(accentColor.g * 0.1), 0, 255), math.Clamp(math.floor(accentColor.b * 0.1), 0, 255), hovered and 228 or 214)
			outlineColor = Color(accentColor.r, accentColor.g, accentColor.b, isActive and 220 or (hovered and 170 or 120))
			innerOutlineColor = Color(accentColor.r, accentColor.g, accentColor.b, isActive and 130 or (hovered and 90 or 55))
			textColor = Color(accentColor.r, accentColor.g, accentColor.b, isActive and 255 or (hovered and 245 or 225))
		end

		draw.RoundedBox(0, x, y, w, h, backgroundColor)
		surface.SetDrawColor(outlineColor.r, outlineColor.g, outlineColor.b, outlineColor.a)
		surface.DrawOutlinedRect(x, y, w, h, 2)
		if w > 4 and h > 4 then
			surface.SetDrawColor(innerOutlineColor.r, innerOutlineColor.g, innerOutlineColor.b, innerOutlineColor.a)
			surface.DrawOutlinedRect(x + 1, y + 1, w - 2, h - 2, 1)
		end
		draw.SimpleText(label, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", x + (w * 0.5), y + (h * 0.5), textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		if onClick then
			table.insert(self.TabletClickableRegions, {
				x = x,
				y = y,
				w = w,
				h = h,
				onClick = onClick
			})
		end
	end

	function SWEP:DrawTabletInnerScrollBar(x, y, w, h, scrollValue, scrollMax)
		scrollMax = math.max(0, scrollMax or 0)
		if scrollMax <= 0 or h <= 0 then return end

		local thumbH = math.Clamp(h * (h / (h + scrollMax)), 24, h)
		local thumbY = y + ((h - thumbH) * math.Clamp((scrollValue or 0) / scrollMax, 0, 1))

		draw.RoundedBox(0, x, y, w, h, Color(255, 255, 255, 14))
		draw.RoundedBox(0, x + 1, thumbY, math.max(2, w - 2), thumbH, Color(120, 185, 255, 185))
	end

	function SWEP:StartTabletBootSequence()
		self.TabletBootStart = CurTime()
		self.TabletBootEnd = self.TabletBootStart + FOUNDATION_TABLET_BOOT_DURATION
		self.TabletBootSoundPlayed = false
		self.TabletClickableRegions = {}
	end

	function SWEP:ClearTabletBootSequence()
		self.TabletBootStart = nil
		self.TabletBootEnd = nil
		self.TabletBootSoundPlayed = nil
	end

	function SWEP:IsTabletBooting()
		return (self.TabletBootEnd or 0) > CurTime()
	end

	function SWEP:DrawTabletBootScreen(left, top, screenW, screenH)
		local progress = math.Clamp((CurTime() - (self.TabletBootStart or CurTime())) / FOUNDATION_TABLET_BOOT_DURATION, 0, 1)
		local panelX = left + 48
		local panelY = top + 132
		local panelW = screenW - 96
		local panelH = 230
		local barX = panelX + 34
		local barY = panelY + 152
		local barW = panelW - 68
		local barH = 18
		local statusText = "AUTHENTICATING USER"

		if progress >= 0.34 and progress < 0.67 then
			statusText = "SYNCING FOUNDATION NETWORK"
		elseif progress >= 0.67 then
			statusText = "INITIALIZING TABLET MODULES"
		end

		draw.RoundedBox(0, panelX, panelY, panelW, panelH, Color(0, 0, 0, 236))
		surface.SetDrawColor(255, 255, 255, 120)
		surface.DrawOutlinedRect(panelX, panelY, panelW, panelH, 2)

		if FOUNDATION_TABLET_LOGO then
			surface.SetMaterial(FOUNDATION_TABLET_LOGO)
			surface.SetDrawColor(255, 255, 255, 28)
			surface.DrawTexturedRect(panelX + (panelW * 0.5) - 54, panelY + 18, 108, 108)
		end

		draw.SimpleText("FOUNDATION TABLET LINK", "DeepGaming.FoundationTablet.HealthSubtitle", panelX + (panelW * 0.5), panelY + 26, Color(255, 255, 255, 240), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("// " .. statusText .. " //", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", panelX + (panelW * 0.5), panelY + 64, Color(120, 185, 255, 235), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(string.format("LOADING %03d%%", math.floor(progress * 100)), "DeepGaming.FoundationTablet.HealthEmbeddedTitle", barX, barY - 24, Color(170, 180, 190, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

		draw.RoundedBox(0, barX, barY, barW, barH, Color(255, 255, 255, 12))
		draw.RoundedBox(0, barX + 2, barY + 2, math.max(0, (barW - 4) * progress), barH - 4, Color(120, 185, 255, 210))
		surface.SetDrawColor(255, 255, 255, 80)
		surface.DrawOutlinedRect(barX, barY, barW, barH, 1)
		draw.SimpleText("C.A.S.S.I.E SECURE BOOT SEQUENCE", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", panelX + (panelW * 0.5), panelY + 186, Color(170, 180, 190, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	function SWEP:GetTabletSiteCodeData()
		local codeText = "UNKNOWN"
		local codeColor = Color(235, 235, 235, 240)

		if DeepCodes then
			local activeCode = tostring(DeepCodes.code or DeepCodes.CurrentCode or "UNKNOWN")
			if string.Trim(activeCode) ~= "" then
				codeText = string.upper(activeCode)
			end

			local lookupTable = istable(DeepCodes.Codes) and DeepCodes.Codes or nil
			local lookupColor = lookupTable and lookupTable[string.lower(activeCode)] or nil
			if IsColor(lookupColor) then
				codeColor = lookupColor
			end
		end

		return codeText, codeColor
	end

	function SWEP:DrawTabletLoweredCodeModal(left, top, screenW, screenH)
		local codeText, codeColor = self:GetTabletSiteCodeData()
		local marqueeText = string.format("// CODE %s //", codeText)
		local panelW = screenW - 48
		local panelH = 170
		local panelX = left + ((screenW - panelW) * 0.5)
		local panelY = top + ((screenH - panelH) * 0.5)
		local clipX = left + 24
		local clipY = panelY + 16
		local clipW = screenW - 48
		local clipH = panelH - 32
		local pulse = (math.sin(CurTime() * 3.8) + 1) * 0.5
		local speed = 280
		local pulseMul = 0.82 + (pulse * 0.35)
		local pulseColor = Color(
			math.Clamp(math.floor(codeColor.r * pulseMul), 0, 255),
			math.Clamp(math.floor(codeColor.g * pulseMul), 0, 255),
			math.Clamp(math.floor(codeColor.b * pulseMul), 0, 255),
			245
		)

		surface.SetFont("DeepGaming.FoundationTablet.CodeMarquee")
		local textW, textH = surface.GetTextSize(marqueeText)
		local spacing = 110
		local travel = clipW + textW + spacing
		local offset = (CurTime() * speed) % travel
		local textX = clipX + clipW + spacing - offset
		local textY = panelY + math.max(0, (panelH - textH) * 0.5) - 2

		draw.RoundedBox(0, panelX, panelY, panelW, panelH, Color(0, 0, 0, 170))
		draw.RoundedBox(0, left + 18, panelY + 6, screenW - 36, 6, Color(pulseColor.r, pulseColor.g, pulseColor.b, 210))
		draw.RoundedBox(0, left + 18, panelY + panelH - 12, screenW - 36, 6, Color(pulseColor.r, pulseColor.g, pulseColor.b, 210))

		self:BeginTabletClip(clipX, clipY, clipW, clipH)
		draw.SimpleTextOutlined(marqueeText, "DeepGaming.FoundationTablet.CodeMarquee", textX, textY, pulseColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 235))
		self:EndTabletClip()
	end

	function SWEP:DrawLawEnforcementSubjectDropdown(x, y, w, maxHeight, openUpward)
		self:EnsureLawEnforcementBoard()
		self:RefreshLawEnforcementSubjects()

		local board = self.LawEnforcementBoard
		if not board.SubjectMenuOpen then
			self.LawSubjectMenuRegion = nil
			self.LawSubjectMenuScrollMax = 0
			return
		end

		local options = board.SubjectOptions or {}
		local rowH = 28
		local spacing = 4
		local padding = 6
		local optionLayout = {}
		local contentH = 0
		for _, subjectName in ipairs(options) do
			local wrappedSubject, _, _, wrappedSubjectH = self:GetWrappedTextMetrics(subjectName, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", math.max(32, w - 32))
			local optionH = math.max(rowH, wrappedSubjectH + 12)
			table.insert(optionLayout, {
				subjectName = subjectName,
				wrappedSubject = wrappedSubject,
				textH = wrappedSubjectH,
				height = optionH
			})
			contentH = contentH + optionH + spacing
		end
		contentH = math.max(rowH, contentH > 0 and (contentH - spacing) or rowH)
		local panelH = math.min(maxHeight or 160, contentH + (padding * 2))
		local panelY = openUpward and (y - panelH - 6) or (y + 54)
		local panelX = x
		local visibleX = panelX + 6
		local visibleY = panelY + 6
		local visibleW = w - 16
		local visibleH = panelH - 12
		local selectedSubject = string.lower(self:GetLawEnforcementSelectedSubject())

		self.LawSubjectMenuScrollMax = math.max(0, contentH - visibleH)
		self.LawSubjectMenuScroll = math.Clamp(self.LawSubjectMenuScroll or 0, 0, self.LawSubjectMenuScrollMax)
		local menuScroll = math.max(0, self.LawSubjectMenuScrollLerp or self.LawSubjectMenuScroll or 0)
		self.LawSubjectMenuRegion = {
			x = panelX,
			y = panelY,
			w = w,
			h = panelH
		}

		draw.RoundedBox(0, panelX, panelY, w, panelH, Color(0, 0, 0, 245))
		surface.SetDrawColor(255, 255, 255, 110)
		surface.DrawOutlinedRect(panelX, panelY, w, panelH, 1)

		self:BeginTabletClip(visibleX, visibleY, visibleW, visibleH)
		local optionY = visibleY - menuScroll
		for _, optionData in ipairs(optionLayout) do
			local subjectName = optionData.subjectName
			local optionH = optionData.height
			local isSelected = string.lower(subjectName) == selectedSubject
			if optionY < (visibleY + visibleH) and (optionY + optionH) > visibleY then
				local hovered = self.TabletCursorX and self.TabletCursorY
					and self.TabletCursorX >= visibleX and self.TabletCursorX <= (visibleX + visibleW)
					and self.TabletCursorY >= optionY and self.TabletCursorY <= (optionY + optionH)

				draw.RoundedBox(0, visibleX, optionY, visibleW, optionH, isSelected and Color(18, 30, 42, 240) or (hovered and Color(14, 18, 24, 240) or Color(10, 10, 10, 230)))
				surface.SetDrawColor(255, 255, 255, isSelected and 115 or (hovered and 85 or 45))
				surface.DrawOutlinedRect(visibleX, optionY, visibleW, optionH, 1)
				draw.DrawText(optionData.wrappedSubject, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", visibleX + 10, optionY + math.max(6, (optionH - optionData.textH) * 0.5), isSelected and Color(120, 185, 255, 245) or Color(235, 235, 235, 230), TEXT_ALIGN_LEFT)

				table.insert(self.TabletClickableRegions, {
					x = visibleX,
					y = math.max(optionY, visibleY),
					w = visibleW,
					h = math.min(optionH, (visibleY + visibleH) - optionY),
					onClick = function(wep)
						wep:EnsureLawEnforcementBoard()
						wep.LawEnforcementBoard.SelectedSubject = subjectName
						wep:SetLawEnforcementStatus("SUBJECT SELECTED // " .. string.upper(subjectName))
						wep:CloseLawEnforcementSubjectMenu()
					end
				})
			end

			optionY = optionY + optionH + spacing
		end
		self:EndTabletClip()
		self:DrawTabletInnerScrollBar(panelX + w - 8, visibleY, 4, visibleH, menuScroll, self.LawSubjectMenuScrollMax)
	end

	function SWEP:BeginTabletClip(x, y, w, h)
		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilWriteMask(1)
		render.SetStencilTestMask(1)
		render.SetStencilReferenceValue(1)
		render.SetStencilCompareFunction(STENCIL_NEVER)
		render.SetStencilFailOperation(STENCIL_REPLACE)
		render.SetStencilPassOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)
		render.SetBlend(0)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect(x, y, w, h)
		render.SetBlend(1)
		render.SetStencilCompareFunction(STENCIL_EQUAL)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilPassOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)
	end

	function SWEP:EndTabletClip()
		render.SetStencilEnable(false)
	end

	function SWEP:DrawTabletScrollChrome(left, top, screenW, screenH, headerBottom, footerTop, scrollValue, scrollMax)
		local innerLeft = left + 8
		local innerTop = top + 8
		local innerWidth = screenW - 16
		local innerBottom = top + screenH - 8

		if headerBottom and headerBottom > innerTop then
			draw.RoundedBox(0, innerLeft, innerTop, innerWidth, headerBottom - innerTop, Color(0, 0, 0, 255))
			surface.SetDrawColor(255, 255, 255, 26)
			surface.DrawRect(left + 18, headerBottom, screenW - 36, 2)
		end

		if footerTop and footerTop < innerBottom then
			draw.RoundedBox(0, innerLeft, footerTop, innerWidth, innerBottom - footerTop, Color(0, 0, 0, 255))
			surface.SetDrawColor(255, 255, 255, 18)
			surface.DrawRect(left + 18, footerTop - 2, screenW - 36, 2)
		end

		scrollMax = math.max(0, scrollMax or self.ActiveTabletScrollMax or 0)
		if scrollMax <= 0 then return end

		local visibleTop = math.max((headerBottom or innerTop) + 10, innerTop + 8)
		local visibleBottom = math.min((footerTop or innerBottom) - 10, innerBottom - 8)
		local trackHeight = visibleBottom - visibleTop
		if trackHeight <= 0 then return end

		local visibleHeight = math.max(1, (footerTop or innerBottom) - (headerBottom or innerTop))
		local trackX = left + screenW - 24
		local thumbHeight = math.Clamp(trackHeight * (visibleHeight / (visibleHeight + scrollMax)), 34, trackHeight)
		local scrollFrac = math.Clamp((scrollValue or 0) / scrollMax, 0, 1)
		local thumbY = visibleTop + ((trackHeight - thumbHeight) * scrollFrac)

		draw.RoundedBox(0, trackX, visibleTop, 8, trackHeight, Color(255, 255, 255, 18))
		draw.RoundedBox(0, trackX + 1, thumbY, 6, thumbHeight, Color(120, 185, 255, 190))
		surface.SetDrawColor(255, 255, 255, 40)
		surface.DrawOutlinedRect(trackX, visibleTop, 8, trackHeight, 1)
	end

	function SWEP:GetCachedTeamRosterLayout(maxNameWidth, maxTeamWidth)
		local now = CurTime()
		local cache = self.TeamRosterLayoutCache
		local shouldRebuild = not istable(cache)
			or (cache.nextRefresh or 0) <= now
			or cache.maxNameWidth ~= maxNameWidth
			or cache.maxTeamWidth ~= maxTeamWidth

		if shouldRebuild then
			local localPly = LocalPlayer()
			local rosterPlayers = {}
			for _, ply in ipairs(player.GetAll()) do
				if IsValid(ply) then
					table.insert(rosterPlayers, ply)
				end
			end

			table.sort(rosterPlayers, function(a, b)
				local aGroup = self:GetTabletTeamGroupLabel(a)
				local bGroup = self:GetTabletTeamGroupLabel(b)
				local aOrder = FOUNDATION_TABLET_TEAM_GROUP_ORDER[aGroup] or 999
				local bOrder = FOUNDATION_TABLET_TEAM_GROUP_ORDER[bGroup] or 999
				if aOrder == bOrder then
					local aTeamName = string.lower(team.GetName(a:Team()) or ("TEAM " .. tostring(a:Team())))
					local bTeamName = string.lower(team.GetName(b:Team()) or ("TEAM " .. tostring(b:Team())))
					if aTeamName == bTeamName then
						return string.lower(a:Nick()) < string.lower(b:Nick())
					end
					return aTeamName < bTeamName
				end
				return aOrder < bOrder
			end)

			local rows = {}
			local contentHeight = 0
			local lastGroupLabel = nil

			for _, ply in ipairs(rosterPlayers) do
				local baseTeamLabel = team.GetName(ply:Team()) or ("TEAM " .. tostring(ply:Team()))
				local groupLabel = self:GetTabletTeamGroupLabel(ply)

				if groupLabel ~= lastGroupLabel then
					table.insert(rows, {
						kind = "header",
						text = "GROUP // " .. string.upper(groupLabel),
						height = 30
					})
					contentHeight = contentHeight + 30
					lastGroupLabel = groupLabel
				end

				local teamLabel = groupLabel .. " // " .. baseTeamLabel
				if ply == localPly then
					teamLabel = teamLabel .. " // YOU"
				end

				local wrappedName, _, _, nameTextH = self:GetWrappedTextMetrics(ply:Nick(), "DeepGaming.FoundationTablet.HealthEmbeddedTitle", maxNameWidth)
				local wrappedTeamLabel, _, _, teamTextH = self:GetWrappedTextMetrics(teamLabel, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", maxTeamWidth)
				local rowH = math.max(54, 18 + nameTextH + teamTextH + 8)

				table.insert(rows, {
					kind = "player",
					player = ply,
					wrappedName = wrappedName,
					nameTextH = nameTextH,
					wrappedTeamLabel = wrappedTeamLabel,
					rowHeight = rowH
				})

				contentHeight = contentHeight + rowH + 8
			end

			cache = {
				rows = rows,
				contentHeight = contentHeight,
				count = #rosterPlayers,
				maxNameWidth = maxNameWidth,
				maxTeamWidth = maxTeamWidth,
				nextRefresh = now + FOUNDATION_TABLET_ROSTER_REFRESH_INTERVAL
			}
			self.TeamRosterLayoutCache = cache
		end

		return cache
	end

	function SWEP:DrawFoundationTabletUI()
		self:EnsureTabletApplications()

		local raiseFrac = self.TabletRaiseLerp or 0
		local screenW, screenH = 800, 580
		local halfW, halfH = screenW * 0.5, screenH * 0.5
		local left, top = -halfW, -halfH

		self.TabletClickableRegions = {}
		self.ActiveTabletScrollMax = 0

		draw.RoundedBox(0, left, top, screenW, screenH, Color(6, 8, 10, 235))
		draw.RoundedBox(0, left + 8, top + 8, screenW - 16, screenH - 16, Color(0, 0, 0, 180))

		if FOUNDATION_TABLET_LOGO then
			local logoSize = math.min(screenW, screenH) * 0.82
			local logoX = left + ((screenW - logoSize) * 0.5)
			local logoY = top + ((screenH - logoSize) * 0.5) + 10
			surface.SetMaterial(FOUNDATION_TABLET_LOGO)
			surface.SetDrawColor(255, 255, 255, 6)
			surface.DrawTexturedRect(logoX, logoY, logoSize, logoSize)
		end

		surface.SetDrawColor(255, 255, 255, 34)
		surface.DrawOutlinedRect(left, top, screenW, screenH, 2)
		surface.SetDrawColor(255, 255, 255, 18)
		surface.DrawOutlinedRect(left + 1, top + 1, screenW - 2, screenH - 2, 1)

		if self.TabletView == "law_enforcement" and not self:CanAccessLawEnforcementApp(LocalPlayer()) then
			self.TabletView = "home"
		end

		if self.TabletView == "breach_monitor" and not self:CanAccessBreachStatusApp(LocalPlayer()) then
			self.TabletView = "home"
		end

		if raiseFrac <= 0.2 then
			self:DrawTabletLoweredCodeModal(left, top, screenW, screenH)
			return
		end

		if (self.TabletView or "home") == "home" then
			self:DrawWrappedTabletText("FOUNDATION TABLET", "DeepGaming.FoundationTablet.HealthSubtitle", 0, top + 48, Color(140, 205, 255, 245), TEXT_ALIGN_CENTER, 620)
			self:DrawWrappedTabletText("SECURE. CONTAIN. PROTECT.", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 0, top + 80, Color(120, 185, 255, 245), TEXT_ALIGN_CENTER, 620)
		end
		self:DrawWrappedTabletText("// C.A.S.S.I.E ONLINE //", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 18, top + screenH - 36, Color(255, 255, 255, 110), TEXT_ALIGN_LEFT, 300)
		draw.SimpleText(os.date("%H:%M:%S"), "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + screenW - 18, top + screenH - 24, Color(255, 255, 255, 110), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

		if raiseFrac > 0.2 then
			self:GetTabletCursorLocal(screenW, screenH)

			if self:IsTabletBooting() then
				self:DrawTabletBootScreen(left, top, screenW, screenH)
			elseif self.TabletView == "team_players" then
				local rosterLayout = self:GetCachedTeamRosterLayout(screenW - 180, screenW - 84)
				local rosterRows = rosterLayout and rosterLayout.rows or {}
				local teamScroll = math.max(0, self.AppScrollLerp or self.AppScroll or 0)
				local headerBottom = top + 102
				local footerTop = top + 506
				local bodyTop = headerBottom + 8
				local bodyBottom = footerTop - 10
				if #rosterRows == 0 then
					self:DrawWrappedTabletText("NO PLAYERS CONNECTED", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 0, bodyTop + 34, Color(170, 180, 190, 220), TEXT_ALIGN_CENTER, 620)
					self.ActiveTabletScrollMax = 0
				else
					local rowY = bodyTop + 8 - teamScroll
					self:BeginTabletClip(left + 24, bodyTop, screenW - 48, bodyBottom - bodyTop)
					for _, rowData in ipairs(rosterRows) do
						if rowData.kind == "header" then
							local headerH = rowData.height or 30
							if rowY < bodyBottom and (rowY + headerH) > bodyTop then
								draw.SimpleText(rowData.text or "GROUP", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 32, rowY + 4, Color(120, 185, 255, 235), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
								surface.SetDrawColor(255, 255, 255, 40)
								surface.DrawRect(left + 32, rowY + 24, screenW - 64, 1)
							end
							rowY = rowY + headerH
						elseif rowData.kind == "player" then
							local ply = rowData.player
							local rowH = rowData.rowHeight or 54

							if rowY < bodyBottom and (rowY + rowH) > bodyTop then
								draw.RoundedBox(0, left + 24, rowY, screenW - 48, rowH, Color(0, 0, 0, 230))
								surface.SetDrawColor(255, 255, 255, 55)
								surface.DrawOutlinedRect(left + 24, rowY, screenW - 48, rowH, 1)

								draw.DrawText(rowData.wrappedName or "UNKNOWN", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 42, rowY + 10, Color(255, 255, 255, 235), TEXT_ALIGN_LEFT)
								draw.SimpleText("HP " .. math.max(IsValid(ply) and ply:Health() or 0, 0), "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + screenW - 42, rowY + 12, Color(120, 185, 255, 235), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
								draw.DrawText(rowData.wrappedTeamLabel or "UNKNOWN", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 42, rowY + 14 + (rowData.nameTextH or 0), Color(170, 180, 190, 220), TEXT_ALIGN_LEFT)
							end

							rowY = rowY + rowH + 8
						end
					end
					self:EndTabletClip()
					local contentHeight = rosterLayout and rosterLayout.contentHeight or 0
					self.ActiveTabletScrollMax = math.max(0, contentHeight - ((bodyBottom - bodyTop) - 14))
				end

				self:DrawTabletScrollChrome(left, top, screenW, screenH, headerBottom, footerTop, teamScroll, self.ActiveTabletScrollMax)
				self:DrawApplicationCard(left + 24, top + 26, 52, 52, {
					icon = FOUNDATION_BACK_ICON,
					iconOnly = true,
					onClick = function(wep)
						wep.TabletView = "home"
					end
				})
				self:DrawWrappedTabletText("PERSONNEL DOSSIER", "DeepGaming.FoundationTablet.Subtitle", 0, top + 34, Color(255, 255, 255, 245), TEXT_ALIGN_CENTER, 620)
				self:DrawWrappedTabletText("ALL CONNECTED PERSONNEL", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 0, top + 66, Color(120, 185, 255, 235), TEXT_ALIGN_CENTER, 620)
			elseif self.TabletView == "requests" then
				self:EnsureRequestsDraft()

				local draft = self.RequestDraft
				local requestTypes = FOUNDATION_REQUEST_TYPES
				local priorityLevels = FOUNDATION_PRIORITY_LEVELS
				local zoneOptions = FOUNDATION_ZONE_OPTIONS
				local unitOptions = FOUNDATION_UNIT_OPTIONS
				local threatLevels = FOUNDATION_THREAT_LEVELS
				local requestScroll = math.max(0, self.RequestsScrollLerp or self.RequestsScroll or 0)
				local headerBottom = top + 102
				local footerTop = top + 506
				local bodyTop = headerBottom + 8
				local bodyBottom = footerTop - 10
				local summaryText = "TICKET " .. draft.TicketID .. " // " .. draft.Status .. "\n"
					.. unitOptions[draft.UnitIndex] .. " requested for " .. requestTypes[draft.TypeIndex] .. " in " .. zoneOptions[draft.ZoneIndex] .. ".\n"
					.. "Threat level: " .. threatLevels[draft.ThreatIndex] .. " // Priority: " .. priorityLevels[draft.PriorityIndex]
				local wrappedSummaryText = self:WrapTabletText(summaryText, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 516)
				surface.SetFont("DeepGaming.FoundationTablet.HealthEmbeddedTitle")
				local _, summaryLineH = surface.GetTextSize("REQUEST")
				local summaryLineCount = select(2, string.gsub(wrappedSummaryText, "\n", "\n")) + 1
				local summaryY = top + 418 - requestScroll
				local summaryH = math.max(118, 48 + (summaryLineCount * summaryLineH))
				local actionY = summaryY + summaryH + 14
				self.ActiveTabletScrollMax = math.max(0, (actionY + requestScroll + 72) - bodyBottom)
				local function drawBodyItem(y, h, drawFn)
					if y < bodyBottom and (y + h) > bodyTop then
						drawFn()
					end
				end

				drawBodyItem(top + 202 - requestScroll, 62, function()
					self:DrawRequestField(left + 24, top + 202 - requestScroll, 256, 62, "INCIDENT TYPE", requestTypes[draft.TypeIndex], function(wep)
						wep:AdvanceRequestField("TypeIndex", #requestTypes)
					end)
					self:DrawRequestField(left + 296, top + 202 - requestScroll, 280, 62, "PRIORITY", priorityLevels[draft.PriorityIndex], function(wep)
						wep:AdvanceRequestField("PriorityIndex", #priorityLevels)
					end, draft.PriorityIndex >= 3 and Color(255, 170, 120, 240) or Color(120, 185, 255, 240))
				end)

				drawBodyItem(top + 276 - requestScroll, 62, function()
					self:DrawRequestField(left + 24, top + 276 - requestScroll, 256, 62, "REPORTED ZONE", zoneOptions[draft.ZoneIndex], function(wep)
						wep:AdvanceRequestField("ZoneIndex", #zoneOptions)
					end)
					self:DrawRequestField(left + 296, top + 276 - requestScroll, 280, 62, "REQUESTED UNIT", unitOptions[draft.UnitIndex], function(wep)
						wep:AdvanceRequestField("UnitIndex", #unitOptions)
					end)
				end)

				drawBodyItem(top + 350 - requestScroll, 58, function()
					self:DrawRequestField(left + 24, top + 350 - requestScroll, 552, 58, "THREAT / SUBJECT STATUS", threatLevels[draft.ThreatIndex], function(wep)
						wep:AdvanceRequestField("ThreatIndex", #threatLevels)
					end, draft.ThreatIndex >= 4 and Color(255, 140, 140, 240) or Color(255, 255, 255, 240))
				end)

				drawBodyItem(summaryY, summaryH, function()
					draw.RoundedBox(0, left + 24, summaryY, 552, summaryH, Color(0, 0, 0, 232))
					surface.SetDrawColor(255, 255, 255, 135)
					surface.DrawOutlinedRect(left + 24, summaryY, 552, summaryH, 2)
					surface.DrawOutlinedRect(left + 25, summaryY + 1, 550, summaryH - 2, 1)
					draw.SimpleText("DISPATCH SUMMARY", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 36, summaryY + 12, Color(165, 180, 195, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
					draw.DrawText(wrappedSummaryText, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 36, summaryY + 34, Color(235, 235, 235, 240), TEXT_ALIGN_LEFT)
				end)

				drawBodyItem(actionY, 56, function()
					self:DrawRequestField(left + 24, actionY, 270, 56, "ACTION", draft.Status == "SUBMITTED" and "SUBMITTED" or "SUBMIT REQUEST", function(wep)
						wep:SubmitRequestDraft()
					end, draft.Status == "SUBMITTED" and Color(130, 220, 170, 240) or Color(120, 185, 255, 240))
					self:DrawRequestField(left + 306, actionY, 270, 56, "FORM", "RESET REQUEST", function(wep)
						wep:ResetRequestDraft()
					end, Color(220, 200, 160, 240))
				end)

				self:DrawTabletScrollChrome(left, top, screenW, screenH, headerBottom, footerTop, requestScroll, self.ActiveTabletScrollMax)

				self:DrawApplicationCard(left + 24, top + 26, 52, 52, {
					icon = FOUNDATION_BACK_ICON,
					iconOnly = true,
					onClick = function(wep)
						wep.TabletView = "home"
						wep.RequestsScroll = 0
						wep.RequestsScrollLerp = 0
					end
				})


				self:DrawWrappedTabletText("LAW ENFORCEMENT REQUEST", "DeepGaming.FoundationTablet.Subtitle", 30, top + 34, Color(255, 255, 255, 245), TEXT_ALIGN_CENTER, 620)
			elseif self.TabletView == "law_enforcement" then
				self:EnsureLawEnforcementBoard()

				local board = self.LawEnforcementBoard
				local leScroll = math.max(0, self.AppScrollLerp or self.AppScroll or 0)
				local leTop = top - leScroll
				local headerBottom = top + 134
				local footerTop = top + 506
				local bodyTop = headerBottom + 8
				local bodyBottom = footerTop - 10
				local activeTab = board.ActiveTab or "requests"
				local selectedTicket = self:GetSelectedLawEnforcementTicket() or {}
				local selectedSubject = self:GetLawEnforcementSelectedSubject()
				local tabDefinitions = {
					{id = "requests", label = "REQUESTS"},
					{id = "fines", label = "FINES"},
					{id = "bols", label = "BOLS"},
					{id = "arrests", label = "ARRESTS"}
				}

				self.LawEntryScrollRegion = nil
				self.LawEntryScrollMax = 0
				self.LawSubjectMenuRegion = nil
				self.LawSubjectMenuScrollMax = 0
				self.LawRequestSubjectRegion = nil
				self.LawRequestSubjectScrollMax = 0

				if activeTab == "requests" then
					local requestsPanelY = leTop + 150
					local requestsPanelH = 236
					local requestListBottom = requestsPanelY + requestsPanelH - 12
					local summaryText = "TICKET " .. tostring(selectedTicket.id or "N/A") .. " // " .. tostring(selectedTicket.subject or "NO ACTIVE REQUESTS") .. "\n"
						.. "STATUS: " .. tostring(selectedTicket.status or "OPEN") .. " // PRIORITY: " .. tostring(selectedTicket.priority or "LOW") .. "\n"
						.. "ZONE: " .. tostring(selectedTicket.zone or "UNKNOWN") .. " // UNIT: " .. tostring(selectedTicket.unit or "F.E.") .. "\n"
						.. "UPDATED: " .. tostring(selectedTicket.updated or "--:--")
					local wrappedSummaryText, _, _, summaryTextH = self:GetWrappedTextMetrics(summaryText, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 248)
					local controlsY = requestsPanelY + requestsPanelH + 12
					self.ActiveTabletScrollMax = math.max(0, (controlsY + leScroll + 70) - bodyBottom)

					draw.RoundedBox(0, left + 24, requestsPanelY, 252, requestsPanelH, Color(0, 0, 0, 232))
					draw.RoundedBox(0, left + 292, requestsPanelY, 284, requestsPanelH, Color(0, 0, 0, 232))
					surface.SetDrawColor(255, 255, 255, 135)
					surface.DrawOutlinedRect(left + 24, requestsPanelY, 252, requestsPanelH, 2)
					surface.DrawOutlinedRect(left + 292, requestsPanelY, 284, requestsPanelH, 2)
					draw.SimpleText("PLACED REQUESTS", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 36, requestsPanelY + 12, Color(165, 180, 195, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
					draw.SimpleText("REQUEST DETAILS", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 304, requestsPanelY + 12, Color(165, 180, 195, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

					local ticketY = requestsPanelY + 44
					self:BeginTabletClip(left + 36, requestsPanelY + 36, 228, requestsPanelH - 48)
					for i, ticket in ipairs(board.Tickets or {}) do
						local isSelected = i == board.SelectedTicket
						local ticketTitle = tostring(ticket.id or "LE-CASE") .. " // " .. tostring(ticket.subject or "REQUEST")
						local ticketStatus = tostring(ticket.status or "OPEN") .. " // " .. tostring(ticket.zone or ticket.action or "UNKNOWN")
						local wrappedTicketTitle, _, _, ticketTitleH = self:GetWrappedTextMetrics(ticketTitle, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 204)
						local wrappedTicketStatus, _, _, ticketStatusH = self:GetWrappedTextMetrics(ticketStatus, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 204)
						local ticketH = math.max(62, 16 + ticketTitleH + ticketStatusH + 12)

						if ticketY < requestListBottom and (ticketY + ticketH) > (requestsPanelY + 36) then
							draw.RoundedBox(0, left + 36, ticketY, 228, ticketH, isSelected and Color(20, 30, 40, 235) or Color(12, 12, 12, 225))
							surface.SetDrawColor(255, 255, 255, isSelected and 145 or 60)
							surface.DrawOutlinedRect(left + 36, ticketY, 228, ticketH, 1)
							draw.DrawText(wrappedTicketTitle, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 48, ticketY + 10, Color(255, 255, 255, 235), TEXT_ALIGN_LEFT)
							draw.DrawText(wrappedTicketStatus, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 48, ticketY + 12 + ticketTitleH, isSelected and Color(120, 185, 255, 235) or Color(170, 180, 190, 220), TEXT_ALIGN_LEFT)
							table.insert(self.TabletClickableRegions, {
								x = left + 36,
								y = math.max(ticketY, requestsPanelY + 36),
								w = 228,
								h = math.min(ticketH, requestListBottom - ticketY),
								onClick = function(wep)
									wep:EnsureLawEnforcementBoard()
									wep.LawEnforcementBoard.SelectedTicket = i
									if ticket.subject and ticket.subject ~= "NO ACTIVE REQUESTS" then
										wep.LawEnforcementBoard.SelectedSubject = ticket.subject
									end
									wep:SetLawEnforcementStatus("VIEWING " .. tostring(ticket.id or "REQUEST") .. " // " .. tostring(ticket.status or "OPEN"))
								end
							})
						end

						ticketY = ticketY + ticketH + 8
						if ticketY > requestListBottom then break end
					end
					self:EndTabletClip()

					local detailAreaX = left + 304
					local detailAreaY = requestsPanelY + 42
					local detailAreaW = 248
					local detailAreaH = requestsPanelH - 54
					local detailInnerW = detailAreaW - 8
					local wrappedSelectedSubject, _, _, selectedSubjectH = self:GetWrappedTextMetrics("SUBJECT // " .. selectedSubject, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", detailInnerW - 16)
					local subjectCardH = math.max(34, selectedSubjectH + 12)
					local detailContentH = summaryTextH + 8 + subjectCardH
					self.LawRequestSubjectScrollMax = math.max(0, detailContentH - detailAreaH)
					self.LawRequestSubjectScroll = math.Clamp(self.LawRequestSubjectScroll or 0, 0, self.LawRequestSubjectScrollMax)
					local detailScroll = math.max(0, self.LawRequestSubjectScrollLerp or self.LawRequestSubjectScroll or 0)
					self.LawRequestSubjectRegion = {
						x = left + 292,
						y = requestsPanelY,
						w = 284,
						h = requestsPanelH
					}
					self:BeginTabletClip(detailAreaX, detailAreaY, detailInnerW, detailAreaH)
					local detailContentY = detailAreaY - detailScroll
					draw.DrawText(wrappedSummaryText, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", detailAreaX, detailContentY, Color(235, 235, 235, 240), TEXT_ALIGN_LEFT)
					local subjectCardY = detailContentY + summaryTextH + 8
					draw.RoundedBox(0, detailAreaX, subjectCardY, detailInnerW, subjectCardH, Color(8, 16, 24, 235))
					draw.DrawText(wrappedSelectedSubject, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", detailAreaX + 8, subjectCardY + 6, Color(120, 185, 255, 230), TEXT_ALIGN_LEFT)
					self:EndTabletClip()
					self:DrawTabletInnerScrollBar(detailAreaX + detailAreaW - 4, detailAreaY, 4, detailAreaH, detailScroll, self.LawRequestSubjectScrollMax)

					self:DrawRequestField(left + 24, controlsY, 176, 48, "SUBJECT", selectedSubject, function(wep)
						wep:OpenLawEnforcementSubjectMenu()
					end, Color(120, 185, 255, 240))
					self:DrawRequestField(left + 212, controlsY, 176, 48, "REQUEST", "NEXT", function(wep)
						wep:CycleLawEnforcementTicket()
					end, Color(120, 185, 255, 240))
					self:DrawRequestField(left + 400, controlsY, 176, 48, "STATUS", "RESOLVE", function(wep)
						wep:ResolveLawEnforcementRequest()
					end, Color(130, 220, 170, 240))
					self:DrawLawEnforcementSubjectDropdown(left + 24, controlsY, 176, 156, true)
				else
					local selectorY = leTop + 150
					local selectorFieldH = select(1, self:GetRequestFieldHeight(552, 56, selectedSubject))
					local logPanelY = selectorY + selectorFieldH + 12
					local logPanelH = 198
					local logPanelBottom = logPanelY + logPanelH - 10
					local entryVisibleTop = logPanelY + 42
					local entryVisibleBottom = logPanelBottom
					local entryVisibleHeight = math.max(1, entryVisibleBottom - entryVisibleTop)
					local entryScroll = math.max(0, self.LawEntryScrollLerp or self.LawEntryScroll or 0)
					local panelTitle = "RECENT FINES"
					local buttonLabel = "ISSUE CUSTOM FINE"
					local buttonAccent = Color(255, 205, 120, 240)
					local entries = board.Fines or {}
					local actionCallback = function(wep)
						wep:IssueLawEnforcementFine()
					end

					if activeTab == "bols" then
						panelTitle = "ACTIVE BOLS"
						buttonLabel = "PLACE CUSTOM BOL"
						buttonAccent = Color(255, 160, 140, 240)
						entries = board.BOLs or {}
						actionCallback = function(wep)
							wep:PlaceLawEnforcementBOL()
						end
					elseif activeTab == "arrests" then
						panelTitle = "ARREST LOGS"
						buttonLabel = "LOG ARREST + TIMER"
						buttonAccent = Color(130, 220, 170, 240)
						entries = board.ArrestLogs or {}
						actionCallback = function(wep)
							wep:LogLawEnforcementArrest()
						end
					end

					local latestEntry = entries[1]
					local linkedRequest = (selectedTicket.id and selectedTicket.id ~= "LE-QUEUE") and (tostring(selectedTicket.id) .. " // " .. tostring(selectedTicket.status or "OPEN")) or "NO REQUEST REQUIRED"
					local summaryText = "SUBJECT: " .. selectedSubject .. "\n"
						.. "REQUEST: " .. linkedRequest .. "\n"
						.. (latestEntry and ("LAST ENTRY // " .. tostring(latestEntry.posted or "--:--")) or "NO LOGS RECORDED YET.")
					local wrappedSummaryText, _, _, summaryTextH = self:GetWrappedTextMetrics(summaryText, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 180)
					local summaryPanelH = math.max(120, 28 + summaryTextH + 12)
					local actionButtonY = logPanelY + summaryPanelH + 12
					self.ActiveTabletScrollMax = 0
					self.LawEntryScrollRegion = {
						x = left + 36,
						y = entryVisibleTop,
						w = 308,
						h = entryVisibleHeight
					}

					self:DrawRequestField(left + 24, selectorY, 552, 56, "SUBJECT SELECTOR", selectedSubject, function(wep)
						wep:OpenLawEnforcementSubjectMenu()
					end, Color(120, 185, 255, 240))

					draw.RoundedBox(0, left + 24, logPanelY, 332, logPanelH, Color(0, 0, 0, 232))
					draw.RoundedBox(0, left + 372, logPanelY, 204, summaryPanelH, Color(0, 0, 0, 232))
					surface.SetDrawColor(255, 255, 255, 135)
					surface.DrawOutlinedRect(left + 24, logPanelY, 332, logPanelH, 2)
					surface.DrawOutlinedRect(left + 372, logPanelY, 204, summaryPanelH, 2)
					draw.SimpleText(panelTitle, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 36, logPanelY + 12, Color(165, 180, 195, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
					draw.SimpleText("ACTION SUMMARY", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 384, logPanelY + 12, Color(165, 180, 195, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

					local entryY = entryVisibleTop - entryScroll
					self:BeginTabletClip(left + 36, entryVisibleTop, 308, entryVisibleHeight)
					if #entries == 0 then
						self.LawEntryScrollMax = 0
						self:DrawWrappedTabletText("NO ENTRIES YET. USE THE SUBJECT DROPDOWN AND ACTION BUTTON TO CREATE ONE.", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 36, entryVisibleTop, Color(170, 180, 190, 220), TEXT_ALIGN_LEFT, 300)
					else
						local contentBottom = entryVisibleTop
						for _, entry in ipairs(entries) do
							local entryHeader = tostring(entry.subject or "UNKNOWN") .. " // " .. tostring(entry.type or "LOG")
							local entryMeta = ((entry.timer and entry.timer ~= "") and (tostring(entry.timer) .. " // ") or "") .. "LOGGED " .. tostring(entry.posted or "--:--")
							local entryBody = tostring(entry.details or "NO DETAILS PROVIDED")
							local wrappedEntryHeader, _, _, entryHeaderH = self:GetWrappedTextMetrics(entryHeader, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 284)
							local wrappedEntryMeta, _, _, entryMetaH = self:GetWrappedTextMetrics(entryMeta, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 284)
							local wrappedEntryBody, _, _, entryBodyH = self:GetWrappedTextMetrics(entryBody, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 284)
							local entryH = math.max(68, 12 + entryHeaderH + entryMetaH + entryBodyH + 14)

							if entryY < entryVisibleBottom and (entryY + entryH) > entryVisibleTop then
								local entryCardX = left + 36
								local entryCardY = entryY
								local entryCardW = 308
								local deleteSize = 18
								local deleteX = entryCardX + entryCardW - deleteSize - 8
								local deleteY = entryCardY + 8

								draw.RoundedBox(0, entryCardX, entryCardY, entryCardW, entryH, Color(12, 12, 12, 225))
								surface.SetDrawColor(255, 255, 255, 60)
								surface.DrawOutlinedRect(entryCardX, entryCardY, entryCardW, entryH, 1)
								draw.DrawText(wrappedEntryHeader, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 48, entryY + 10, Color(255, 255, 255, 235), TEXT_ALIGN_LEFT)
								draw.DrawText(wrappedEntryMeta, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 48, entryY + 12 + entryHeaderH, Color(120, 185, 255, 230), TEXT_ALIGN_LEFT)
								draw.DrawText(wrappedEntryBody, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 48, entryY + 14 + entryHeaderH + entryMetaH, Color(170, 180, 190, 220), TEXT_ALIGN_LEFT)

								if FOUNDATION_DELETE_ICON then
									surface.SetMaterial(FOUNDATION_DELETE_ICON)
									surface.SetDrawColor(220, 70, 70, 245)
									surface.DrawTexturedRect(deleteX, deleteY, deleteSize, deleteSize)
								end

								if deleteY >= entryVisibleTop and (deleteY + deleteSize) <= entryVisibleBottom then
									table.insert(self.TabletClickableRegions, {
										x = deleteX,
										y = deleteY,
										w = deleteSize,
										h = deleteSize,
										onClick = function(wep)
											wep:DeleteLawEnforcementEntry(entry.type, entry)
										end
									})
								end
							end

							entryY = entryY + entryH + 8
							contentBottom = entryY + entryScroll
						end

						self.LawEntryScrollMax = math.max(0, contentBottom - entryVisibleBottom)
					end
					self:EndTabletClip()

					draw.RoundedBox(0, left + 24, logPanelY, 332, entryVisibleTop - logPanelY, Color(0, 0, 0, 232))
					draw.RoundedBox(0, left + 24, entryVisibleBottom, 332, math.max(0, bodyBottom - entryVisibleBottom), Color(6, 8, 10, 235))
					surface.SetDrawColor(255, 255, 255, 135)
					surface.DrawOutlinedRect(left + 24, logPanelY, 332, logPanelH, 2)
					draw.SimpleText(panelTitle, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 36, logPanelY + 12, Color(165, 180, 195, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
					self:DrawTabletInnerScrollBar(left + 346, entryVisibleTop, 6, entryVisibleHeight, entryScroll, self.LawEntryScrollMax)

					self:DrawWrappedTabletText(wrappedSummaryText, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 384, logPanelY + 42, Color(235, 235, 235, 240), TEXT_ALIGN_LEFT, 180)
					self:DrawRequestField(left + 372, actionButtonY, 204, 56, string.upper(activeTab), buttonLabel, function(wep)
						actionCallback(wep)
					end, buttonAccent)
					self:DrawLawEnforcementSubjectDropdown(left + 24, selectorY, 552, 172, false)
				end

				self:DrawTabletScrollChrome(left, top, screenW, screenH, headerBottom, footerTop, leScroll, self.ActiveTabletScrollMax)
				self:DrawApplicationCard(left + 24, top + 26, 52, 52, {
					icon = FOUNDATION_BACK_ICON,
					iconOnly = true,
					onClick = function(wep)
						wep.TabletView = "home"
					end
				})
				self:DrawWrappedTabletText("LAW ENFORCEMENT", "DeepGaming.FoundationTablet.Subtitle", 0, top + 34, Color(255, 255, 255, 245), TEXT_ALIGN_CENTER, 620)
				self:DrawWrappedTabletText(board.StatusNote or "LAW ENFORCEMENT CONSOLE ONLINE", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 0, top + 66, Color(120, 185, 255, 235), TEXT_ALIGN_CENTER, 620)
				for index, tab in ipairs(tabDefinitions) do
					self:DrawTabletTabButton(left + 24 + ((index - 1) * 136), top + 96, 128, 28, tab.label, activeTab == tab.id, function(wep)
						wep:SetLawEnforcementTab(tab.id)
					end)
				end
			elseif self.TabletView == "breach_monitor" then
				self:EnsureBreachStatusBoard()

				local board = self.BreachStatusBoard
				local breachScroll = math.max(0, self.AppScrollLerp or self.AppScroll or 0)
				local breachTop = top - breachScroll
				local headerBottom = top + 102
				local footerTop = top + 506
				local entry = self:GetActiveBreachEntry() or {
					zone = "NO ACTIVE SCP",
					status = "STABLE",
					updated = os.date("%H:%M"),
					note = "No containment data is currently available."
				}
				local statusColor, statusResponse = self:GetBreachStatusColor(entry.status)

				local listPanelX = left + 24
				local listPanelY = breachTop + 118
				local listPanelW = 252
				local listPanelH = footerTop - listPanelY
				local searchButtonY = listPanelY + 40
				local searchButtonH = 28
				local listVisibleTop = searchButtonY + searchButtonH + 10
				local listVisibleBottom = listPanelY + listPanelH - 12
				local listVisibleH = math.max(1, listVisibleBottom - listVisibleTop)
				local listScroll = math.max(0, self.BreachListScrollLerp or self.BreachListScroll or 0)
				local filteredBreachEntries, activeBreachQuery = self:GetFilteredBreachEntries()
				local searchQuery = string.Trim(tostring(activeBreachQuery or ""))
				local searchButtonText = "SEARCH SCPS"
				if searchQuery ~= "" then
					searchButtonText = string.upper(#searchQuery > 18 and (string.sub(searchQuery, 1, 18) .. "...") or searchQuery)
				end

				local detailPanelX = listPanelX + listPanelW + 16
				local detailPanelY = breachTop + 118
				local detailPanelW = 476
				local detailPanelH = footerTop - detailPanelY

				self.BreachListScrollRegion = {
					x = listPanelX + 8,
					y = listVisibleTop,
					w = listPanelW - 16,
					h = listVisibleH
				}

				draw.RoundedBox(0, listPanelX, listPanelY, listPanelW, listPanelH, Color(0, 0, 0, 232))
				draw.RoundedBox(0, detailPanelX, detailPanelY, detailPanelW, detailPanelH, Color(0, 0, 0, 232))
				surface.SetDrawColor(255, 255, 255, 135)
				surface.DrawOutlinedRect(listPanelX, listPanelY, listPanelW, listPanelH, 2)
				surface.DrawOutlinedRect(detailPanelX, detailPanelY, detailPanelW, detailPanelH, 2)
				local listTitle = searchQuery ~= ""
					and ("ON-SITE SCPs // " .. tostring(#filteredBreachEntries) .. " MATCHES")
					or ("ON-SITE SCPs // " .. tostring(#(board.Entries or {})))
				draw.SimpleText(listTitle, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", listPanelX + 12, listPanelY + 12, Color(165, 180, 195, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				local breachClearButtonW = searchQuery ~= "" and 54 or 0
				local breachSearchButtonW = listPanelW - 16 - (breachClearButtonW > 0 and (breachClearButtonW + 6) or 0)
				self:DrawTabletTabButton(listPanelX + 8, searchButtonY, breachSearchButtonW, searchButtonH, searchButtonText, searchQuery ~= "", function(wep)
					wep:PromptBreachSearch()
				end, Color(120, 185, 255, 235))
				if searchQuery ~= "" then
					self:DrawTabletTabButton(listPanelX + 8 + breachSearchButtonW + 6, searchButtonY, breachClearButtonW, searchButtonH, "CLEAR", false, function(wep)
						wep:ClearBreachSearch()
					end, Color(220, 190, 140, 235))
				end

				self:BeginTabletClip(listPanelX + 8, listVisibleTop, listPanelW - 16, listVisibleH)
				local zoneY = listVisibleTop - listScroll
				local contentBottom = listVisibleTop
				if #filteredBreachEntries == 0 then
					self:DrawWrappedTabletText("NO SCP FILES MATCH THE CURRENT SEARCH.", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", listPanelX + 12, listVisibleTop + 6, Color(170, 180, 190, 220), TEXT_ALIGN_LEFT, listPanelW - 24)
				else
					for _, zoneData in ipairs(filteredBreachEntries) do
						local zoneEntry = zoneData.entry or {}
						local sourceIndex = zoneData.index
						local zoneSelected = sourceIndex == (board.ActiveIndex or 1)
						local zoneColor = self:GetBreachStatusColor(zoneEntry.status)
						local rowH = 48

						if zoneY < listVisibleBottom and (zoneY + rowH) > listVisibleTop then
							local scpAccent = Color(zoneColor.r, zoneColor.g, zoneColor.b, zoneSelected and 230 or 150)
							local scpBackground = zoneSelected
								and Color(math.Clamp(math.floor(zoneColor.r * 0.16), 0, 255), math.Clamp(math.floor(zoneColor.g * 0.16), 0, 255), math.Clamp(math.floor(zoneColor.b * 0.16), 0, 255), 242)
								or Color(math.Clamp(math.floor(zoneColor.r * 0.07), 0, 255), math.Clamp(math.floor(zoneColor.g * 0.07), 0, 255), math.Clamp(math.floor(zoneColor.b * 0.07), 0, 255), 228)
							draw.RoundedBox(0, listPanelX + 8, zoneY, listPanelW - 16, rowH, scpBackground)
							surface.SetDrawColor(scpAccent.r, scpAccent.g, scpAccent.b, scpAccent.a)
							surface.DrawOutlinedRect(listPanelX + 8, zoneY, listPanelW - 16, rowH, 2)
							surface.SetDrawColor(scpAccent.r, scpAccent.g, scpAccent.b, zoneSelected and 95 or 55)
							surface.DrawOutlinedRect(listPanelX + 9, zoneY + 1, listPanelW - 18, rowH - 2, 1)
							draw.SimpleText(tostring(zoneEntry.zone or "SCP FILE"), "DeepGaming.FoundationTablet.HealthEmbeddedTitle", listPanelX + 18, zoneY + 7, Color(235, 245, 255, 235), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
							draw.SimpleText(tostring(zoneEntry.status or "STABLE") .. " // " .. tostring(zoneEntry.updated or "--:--"), "DeepGaming.FoundationTablet.HealthEmbeddedTitle", listPanelX + 18, zoneY + 25, zoneColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
							table.insert(self.TabletClickableRegions, {
								x = listPanelX + 8,
								y = math.max(zoneY, listVisibleTop),
								w = listPanelW - 16,
								h = math.min(rowH, listVisibleBottom - zoneY),
								onClick = function(wep)
									wep:EnsureBreachStatusBoard()
									wep.BreachStatusBoard.ActiveIndex = sourceIndex
									wep:ResetBreachDetailScroll()
									wep:SetBreachMonitorStatus("SCP SELECTED // " .. tostring(zoneEntry.zone or "SCP FILE") .. " // " .. tostring(zoneEntry.status or "STABLE"))
								end
							})
						end

						zoneY = zoneY + rowH + 10
						contentBottom = zoneY + listScroll
					end
				end
				self:EndTabletClip()
				self.BreachListScrollMax = math.max(0, contentBottom - listVisibleBottom)
				self:DrawTabletInnerScrollBar(listPanelX + listPanelW - 8, listVisibleTop, 4, listVisibleH, listScroll, self.BreachListScrollMax)

				local wrappedZoneTitle, _, _, zoneTitleH = self:GetWrappedTextMetrics(tostring(entry.zone or "NO ACTIVE SCP"), "DeepGaming.FoundationTablet.HealthSubtitle", detailPanelW - 24)
				local detailMeta = "STATUS // " .. tostring(entry.status or "STABLE") .. " // UPDATED " .. tostring(entry.updated or "--:--")
				local wrappedDetailMeta, _, _, detailMetaH = self:GetWrappedTextMetrics(detailMeta, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", detailPanelW - 24)
				draw.DrawText(wrappedZoneTitle, "DeepGaming.FoundationTablet.HealthSubtitle", detailPanelX + 12, detailPanelY + 16, Color(255, 255, 255, 245), TEXT_ALIGN_LEFT)
				draw.DrawText(wrappedDetailMeta, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", detailPanelX + 12, detailPanelY + 22 + zoneTitleH, statusColor, TEXT_ALIGN_LEFT)

				local controlsY = detailPanelY + 18 + zoneTitleH + detailMetaH + 8
				local buttonGap = 8
				local wideButtonW = math.floor((detailPanelW - 24 - buttonGap) * 0.5)
				self:DrawTabletTabButton(detailPanelX + 12, controlsY, wideButtonW, 28, "NEXT SCP", false, function(wep)
					wep:CycleBreachEntry()
				end, statusColor)
				self:DrawTabletTabButton(detailPanelX + 12 + wideButtonW + buttonGap, controlsY, wideButtonW, 28, "EDIT NOTE", false, function(wep)
					wep:PromptBreachStatusNote()
				end)

				local notePanelW = detailPanelW - 24
				local statusLabelY = controlsY + 40
				draw.SimpleText("SET STATUS", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", detailPanelX + 12, statusLabelY, Color(165, 180, 195, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

				local statusButtonW = math.floor((notePanelW - 8) * 0.5)
				local statusButtonH = 24
				local statusButtonsTop = statusLabelY + 20
				local statusRowsH = ((statusButtonH + 6) * 2) - 6
				for stageIndex, stageData in ipairs(FOUNDATION_BREACH_STATES) do
					local chipX = detailPanelX + 12 + (((stageIndex - 1) % 2) * (statusButtonW + 8))
					local chipY = statusButtonsTop + (math.floor((stageIndex - 1) / 2) * (statusButtonH + 6))
					self:DrawTabletTabButton(chipX, chipY, statusButtonW, statusButtonH, stageData.id, tostring(entry.status or "STABLE") == stageData.id, function(wep)
						wep:SetActiveBreachStatus(stageData.id)
					end, stageData.color)
				end

				local notePanelY = statusButtonsTop + statusRowsH + 12
				local notePanelH = 72
				local noteText = string.Trim(tostring(entry.note or ""))
				if noteText == "" then
					noteText = "NO INCIDENT NOTES LOGGED."
				end
				local wrappedNoteText, _, _, noteTextH = self:GetWrappedTextMetrics(noteText, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", notePanelW - 30)
				local noteScroll = math.max(0, self.BreachNoteScrollLerp or self.BreachNoteScroll or 0)
				local noteClipY = notePanelY + 30
				local noteClipH = notePanelH - 38
				self.BreachNoteScrollRegion = {
					x = detailPanelX + 22,
					y = noteClipY,
					w = notePanelW - 28,
					h = noteClipH
				}
				self.BreachNoteScrollMax = math.max(0, noteTextH - noteClipH)
				draw.RoundedBox(0, detailPanelX + 12, notePanelY, notePanelW, notePanelH, Color(8, 12, 16, 235))
				surface.SetDrawColor(255, 255, 255, 60)
				surface.DrawOutlinedRect(detailPanelX + 12, notePanelY, notePanelW, notePanelH, 1)
				draw.SimpleText("INCIDENT SUMMARY", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", detailPanelX + 22, notePanelY + 10, Color(165, 180, 195, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				self:BeginTabletClip(detailPanelX + 22, noteClipY, notePanelW - 28, noteClipH)
				draw.DrawText(wrappedNoteText, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", detailPanelX + 22, noteClipY - noteScroll, Color(235, 235, 235, 240), TEXT_ALIGN_LEFT)
				self:EndTabletClip()
				self:DrawTabletInnerScrollBar(detailPanelX + notePanelW - 2, noteClipY, 4, noteClipH, noteScroll, self.BreachNoteScrollMax)

				local wrappedDirective, _, _, directiveTextH = self:GetWrappedTextMetrics(statusResponse, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", notePanelW - 30)
				local detailBottomY = detailPanelY + detailPanelH - 12
				local directiveY = notePanelY + notePanelH + 8
				local directiveH = math.max(56, detailBottomY - directiveY)
				local directiveScroll = math.max(0, self.BreachDirectiveScrollLerp or self.BreachDirectiveScroll or 0)
				local directiveClipY = directiveY + 30
				local directiveClipH = directiveH - 38
				self.BreachDirectiveScrollRegion = {
					x = detailPanelX + 22,
					y = directiveClipY,
					w = notePanelW - 28,
					h = directiveClipH
				}
				self.BreachDirectiveScrollMax = math.max(0, directiveTextH - directiveClipH)
				draw.RoundedBox(0, detailPanelX + 12, directiveY, notePanelW, directiveH, Color(8, 12, 16, 235))
				surface.SetDrawColor(255, 255, 255, 60)
				surface.DrawOutlinedRect(detailPanelX + 12, directiveY, notePanelW, directiveH, 1)
				draw.SimpleText("RESPONSE DIRECTIVE", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", detailPanelX + 22, directiveY + 10, Color(165, 180, 195, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				self:BeginTabletClip(detailPanelX + 22, directiveClipY, notePanelW - 28, directiveClipH)
				draw.DrawText(wrappedDirective, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", detailPanelX + 22, directiveClipY - directiveScroll, statusColor, TEXT_ALIGN_LEFT)
				self:EndTabletClip()
				self:DrawTabletInnerScrollBar(detailPanelX + notePanelW - 2, directiveClipY, 4, directiveClipH, directiveScroll, self.BreachDirectiveScrollMax)

				self.ActiveTabletScrollMax = math.max(0, ((directiveY + directiveH + 12) - footerTop))
				self:DrawTabletScrollChrome(left, top, screenW, screenH, headerBottom, footerTop, breachScroll, self.ActiveTabletScrollMax)
				self:DrawApplicationCard(left + 24, top + 26, 52, 52, {
					icon = FOUNDATION_BACK_ICON,
					iconOnly = true,
					onClick = function(wep)
						wep.TabletView = "home"
					end
				})
				self:DrawWrappedTabletText("BREACH STATUS", "DeepGaming.FoundationTablet.Subtitle", 0, top + 34, Color(255, 255, 255, 245), TEXT_ALIGN_CENTER, 620)
				self:DrawWrappedTabletText(board.StatusNote or "CONTAINMENT STATUS // STABLE", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 0, top + 66, statusColor, TEXT_ALIGN_CENTER, 620)
			elseif self.TabletView == "research_archive" then
				self:EnsureResearchArchive()

				local board = self.ResearchArchive
				local researchScroll = math.max(0, self.AppScrollLerp or self.AppScroll or 0)
				local researchTop = top - researchScroll
				local headerBottom = top + 102
				local footerTop = top + 506
				local bodyBottom = footerTop - 10
				local filteredDocuments, activeQuery = self:GetFilteredResearchDocuments()
				local entry = self:GetActiveResearchDocument()
				local searchQuery = string.Trim(tostring(activeQuery or ""))
				local searchButtonText = "SEARCH"
				if searchQuery ~= "" then
					searchButtonText = string.upper(#searchQuery > 18 and (string.sub(searchQuery, 1, 18) .. "...") or searchQuery)
				end

				local filePanelX = left + 24
				local filePanelY = researchTop + 118
				local filePanelW = 220
				local filePanelH = 362
				local searchButtonY = filePanelY + 40
				local searchButtonH = 28
				local fileVisibleTop = searchButtonY + searchButtonH + 10
				local fileVisibleBottom = filePanelY + filePanelH - 12

				local viewerPanelX = left + 260
				local viewerPanelY = researchTop + 118
				local viewerPanelW = 508
				local viewerPanelH = 362

				local pageText, pageIndex, pageCount = "", 0, 0
				if entry then
					pageText, pageIndex, pageCount = self:GetResearchDocumentPageText(entry)
				end

				local viewerTitle = entry and tostring(entry.title or "Untitled Research File") or "No Matching File"
				local viewerMeta = entry
					and (tostring(entry.fileId or "RD-000") .. " // " .. tostring(entry.author or "Research Division") .. " // " .. tostring(pageCount) .. " PAGE" .. (pageCount == 1 and "" or "S") .. " // UPDATED " .. tostring(entry.updated or "--:--"))
					or "Select a file or create a new one."
				local viewerBody = entry and tostring(pageText or "No notes have been entered yet.") or "No file is currently selected. Use the + button on the left to create a new research document, or search for an existing one."
				local wrappedViewerTitle, _, _, viewerTitleH = self:GetWrappedTextMetrics(viewerTitle, "DeepGaming.FoundationTablet.HealthSubtitle", viewerPanelW - 24)
				local wrappedViewerMeta, _, _, viewerMetaH = self:GetWrappedTextMetrics(viewerMeta, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", viewerPanelW - 24)
				local actionRowY = viewerPanelY + 18 + viewerTitleH + viewerMetaH + 10
				local actionButtonGap = 8
				local actionButtonW = math.floor((viewerPanelW - 24 - actionButtonGap) * 0.5)
				local actionButtonH = 28
				local viewerBodyY = actionRowY + actionButtonH + 12
				local viewerBodyH = math.max(80, (viewerPanelY + viewerPanelH - 46) - viewerBodyY)
				local wrappedViewerBody, _, _, viewerBodyTextH = self:GetWrappedTextMetrics(viewerBody, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", viewerPanelW - 28)
				local viewerBodyScroll = math.max(0, self.ResearchViewerScrollLerp or self.ResearchViewerScroll or 0)

				self.ResearchViewerScrollRegion = viewerBodyH > 0 and {
					x = viewerPanelX + 12,
					y = viewerBodyY,
					w = viewerPanelW - 24,
					h = viewerBodyH
				} or nil
				self.ResearchViewerScrollMax = math.max(0, viewerBodyTextH - viewerBodyH)

				draw.RoundedBox(0, filePanelX, filePanelY, filePanelW, filePanelH, Color(0, 0, 0, 232))
				draw.RoundedBox(0, viewerPanelX, viewerPanelY, viewerPanelW, viewerPanelH, Color(0, 0, 0, 232))
				surface.SetDrawColor(255, 255, 255, 135)
				surface.DrawOutlinedRect(filePanelX, filePanelY, filePanelW, filePanelH, 2)
				surface.DrawOutlinedRect(viewerPanelX, viewerPanelY, viewerPanelW, viewerPanelH, 2)
				draw.SimpleText("FILES // " .. tostring(#filteredDocuments), "DeepGaming.FoundationTablet.HealthEmbeddedTitle", filePanelX + 12, filePanelY + 12, Color(165, 180, 195, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

				local addButtonX = filePanelX + filePanelW - 38
				local clearButtonW = searchQuery ~= "" and 52 or 0
				local searchButtonW = addButtonX - (filePanelX + 8) - 8 - (clearButtonW > 0 and (clearButtonW + 6) or 0)
				self:DrawTabletTabButton(filePanelX + 8, searchButtonY, searchButtonW, searchButtonH, searchButtonText, false, function(wep)
					wep:PromptResearchSearch()
				end)
				if searchQuery ~= "" then
					self:DrawTabletTabButton(addButtonX - clearButtonW - 6, searchButtonY, clearButtonW, searchButtonH, "CLEAR", false, function(wep)
						wep:ClearResearchSearch()
					end, Color(220, 190, 140, 235))
				end
				self:DrawTabletTabButton(addButtonX, searchButtonY, 28, 28, "+", false, function(wep)
					wep:CreateResearchDocument()
				end)

				self:BeginTabletClip(filePanelX + 8, fileVisibleTop, filePanelW - 16, fileVisibleBottom - fileVisibleTop)
				local fileY = fileVisibleTop
				if #filteredDocuments == 0 then
					self:DrawWrappedTabletText("NO FILES MATCH THE CURRENT SEARCH.", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", filePanelX + 12, fileVisibleTop + 4, Color(170, 180, 190, 220), TEXT_ALIGN_LEFT, filePanelW - 24)
				else
					for _, documentData in ipairs(filteredDocuments) do
						local document = documentData.entry or {}
						local sourceIndex = documentData.index
						self:NormalizeResearchDocument(document)
						local isSelected = sourceIndex == board.ActiveIndex
						local documentPageCount = #(document.pages or {})
						local rowTitle = tostring(document.fileId or "RD-000") .. " // " .. tostring(document.title or "Untitled")
						local rowMeta = tostring(documentPageCount) .. " PAGE" .. (documentPageCount == 1 and "" or "S") .. " // " .. tostring(document.updated or "--:--")
						local wrappedRowTitle, _, _, rowTitleH = self:GetWrappedTextMetrics(rowTitle, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", filePanelW - 56)
						local wrappedRowMeta, _, _, rowMetaH = self:GetWrappedTextMetrics(rowMeta, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", filePanelW - 56)
						local rowH = math.max(52, 12 + rowTitleH + rowMetaH + 10)

						if fileY < fileVisibleBottom and (fileY + rowH) > fileVisibleTop then
							local rowCardX = filePanelX + 8
							local rowCardW = filePanelW - 16
							local deleteSize = 16
							local deleteX = rowCardX + rowCardW - deleteSize - 8
							local deleteY = fileY + 8

							draw.RoundedBox(0, rowCardX, fileY, rowCardW, rowH, isSelected and Color(18, 30, 42, 240) or Color(12, 12, 12, 225))
							surface.SetDrawColor(255, 255, 255, isSelected and 145 or 60)
							surface.DrawOutlinedRect(rowCardX, fileY, rowCardW, rowH, 1)
							draw.DrawText(wrappedRowTitle, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", filePanelX + 18, fileY + 8, Color(255, 255, 255, 235), TEXT_ALIGN_LEFT)
							draw.DrawText(wrappedRowMeta, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", filePanelX + 18, fileY + 10 + rowTitleH, isSelected and Color(120, 185, 255, 235) or Color(170, 180, 190, 220), TEXT_ALIGN_LEFT)

							if FOUNDATION_DELETE_ICON then
								surface.SetMaterial(FOUNDATION_DELETE_ICON)
								surface.SetDrawColor(220, 70, 70, 245)
								surface.DrawTexturedRect(deleteX, deleteY, deleteSize, deleteSize)
								table.insert(self.TabletClickableRegions, {
									x = deleteX,
									y = deleteY,
									w = deleteSize,
									h = deleteSize,
									onClick = function(wep)
										wep:DeleteResearchDocument(sourceIndex)
									end
								})
							end

							table.insert(self.TabletClickableRegions, {
								x = rowCardX,
								y = math.max(fileY, fileVisibleTop),
								w = rowCardW - 28,
								h = math.min(rowH, fileVisibleBottom - fileY),
								onClick = function(wep)
									wep:SelectResearchDocument(sourceIndex)
								end
							})
						end

						fileY = fileY + rowH + 8
					end
				end
				self:EndTabletClip()
				self.ActiveTabletScrollMax = math.max(0, (math.max(fileY, viewerPanelY + viewerPanelH) + researchScroll + 8) - bodyBottom)

				draw.DrawText(wrappedViewerTitle, "DeepGaming.FoundationTablet.HealthSubtitle", viewerPanelX + 12, viewerPanelY + 18, Color(255, 255, 255, 245), TEXT_ALIGN_LEFT)
				draw.DrawText(wrappedViewerMeta, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", viewerPanelX + 12, viewerPanelY + 24 + viewerTitleH, Color(120, 185, 255, 235), TEXT_ALIGN_LEFT)
				if entry then
					self:DrawTabletTabButton(viewerPanelX + 12, actionRowY, actionButtonW, actionButtonH, "EDIT FILE", false, function(wep)
						wep:EditActiveResearchDocument()
					end)
					self:DrawTabletTabButton(viewerPanelX + 12 + actionButtonW + actionButtonGap, actionRowY, actionButtonW, actionButtonH, "ADD PAGE", false, function(wep)
						wep:AddResearchPage()
					end)
				else
					self:DrawTabletTabButton(viewerPanelX + 12, actionRowY, viewerPanelW - 24, actionButtonH, "NEW FILE", false, function(wep)
						wep:CreateResearchDocument()
					end)
				end

				self:BeginTabletClip(viewerPanelX + 12, viewerBodyY, viewerPanelW - 24, viewerBodyH)
				draw.DrawText(wrappedViewerBody, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", viewerPanelX + 12, viewerBodyY - viewerBodyScroll, Color(235, 235, 235, 240), TEXT_ALIGN_LEFT)
				self:EndTabletClip()
				self:DrawTabletInnerScrollBar(viewerPanelX + viewerPanelW - 8, viewerBodyY, 4, viewerBodyH, viewerBodyScroll, self.ResearchViewerScrollMax)

				local pageCounterText = pageCount > 0 and ("PAGE " .. tostring(pageIndex) .. " / " .. tostring(pageCount)) or "NO PAGE"
				local pageCounterY = viewerPanelY + viewerPanelH - 20
				local pageButtonY = viewerPanelY + viewerPanelH - 32
				local pageButtonSize = 24
				local pageCenterX = viewerPanelX + (viewerPanelW * 0.5)
				self:DrawApplicationCard(pageCenterX - 86, pageButtonY, pageButtonSize, pageButtonSize, {
					icon = FOUNDATION_BACK_ICON,
					iconOnly = true,
					canAccess = function()
						return entry ~= nil and pageIndex > 1
					end,
					onClick = function(wep)
						wep:ChangeResearchDocumentPage(-1)
					end
				})
				draw.SimpleText(pageCounterText, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", pageCenterX, pageCounterY, Color(170, 180, 190, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				self:DrawApplicationCard(pageCenterX + 62, pageButtonY, pageButtonSize, pageButtonSize, {
					icon = FOUNDATION_NEXT_ICON,
					iconOnly = true,
					canAccess = function()
						return entry ~= nil and pageIndex < pageCount
					end,
					onClick = function(wep)
						wep:ChangeResearchDocumentPage(1)
					end
				})

				self:DrawTabletScrollChrome(left, top, screenW, screenH, headerBottom, footerTop, researchScroll, self.ActiveTabletScrollMax)
				self:DrawApplicationCard(left + 24, top + 26, 52, 52, {
					icon = FOUNDATION_BACK_ICON,
					iconOnly = true,
					onClick = function(wep)
						wep.TabletView = "home"
					end
				})
				self:DrawWrappedTabletText("RESEARCH ARCHIVE", "DeepGaming.FoundationTablet.Subtitle", 0, top + 34, Color(255, 255, 255, 245), TEXT_ALIGN_CENTER, 620)
				self:DrawWrappedTabletText(board.StatusNote or "RESEARCH DOCUMENTS READY", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 0, top + 66, Color(120, 185, 255, 235), TEXT_ALIGN_CENTER, 620)
			elseif self.TabletView == "bulletins" then
				self:EnsureBulletinsBoard()

				local board = self.BulletinsBoard
				local bulletinScroll = math.max(0, self.AppScrollLerp or self.AppScroll or 0)
				local bulletinTop = top - bulletinScroll
				local filteredEntries, activeFilter = self:GetFilteredBulletinEntries()
				local entry = self:GetActiveBulletinEntry() or {
					title = "NO MATCHING BULLETINS",
					priority = activeFilter,
					posted = os.date("%H:%M"),
					author = "SYSTEM",
					acknowledged = true,
					body = "No bulletins match the current filter. Cycle the filter or post a new update."
				}
				local priorityColor = self:GetBulletinPriorityColor(entry.priority)
				local draftPriority = FOUNDATION_BULLETIN_PRIORITIES[board.DraftPriorityIndex or 2] or "STANDARD"
				local entryTitle = tostring(entry.title or "NO BULLETIN SELECTED")
				local entryMeta = tostring(entry.priority or "STANDARD") .. " PRIORITY // POSTED " .. tostring(entry.posted or "--:--") .. " // " .. tostring(entry.author or "SITE OPS")
				local entryStatus = "STATUS // " .. (entry.acknowledged and "READ" or "UNREAD")
				local wrappedEntryTitle, _, _, entryTitleH = self:GetWrappedTextMetrics(entryTitle, "DeepGaming.FoundationTablet.HealthSubtitle", 298)
				local wrappedEntryMeta, _, _, entryMetaH = self:GetWrappedTextMetrics(entryMeta, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 298)
				local wrappedEntryStatus, _, _, entryStatusH = self:GetWrappedTextMetrics(entryStatus, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 298)
				local wrappedEntryBody, _, _, entryBodyTextH = self:GetWrappedTextMetrics(tostring(entry.body or "NO DETAILS PROVIDED."), "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 298)
				local bulletinDetailScroll = math.max(0, self.BulletinDetailScrollLerp or self.BulletinDetailScroll or 0)
				local bulletinPanelY = bulletinTop + 118
				local bulletinPanelH = 252
				local bulletinPanelBottom = bulletinPanelY + bulletinPanelH
				local listVisibleTop = bulletinPanelY + 42
				local listVisibleBottom = bulletinPanelBottom - 12
				local detailBodyY = bulletinPanelY + 56 + entryTitleH + entryMetaH + entryStatusH
				local detailBodyH = math.max(24, (bulletinPanelBottom - 16) - detailBodyY)
				local buttonColumnX = left + 592
				local buttonColumnY = bulletinPanelY
				local buttonColumnW = 176
				local buttonGap = 14
				local buttonStartY = buttonColumnY + 40
				local draftButtonH = select(1, self:GetRequestFieldHeight(buttonColumnW, 52, draftPriority))
				local entryButtonH = select(1, self:GetRequestFieldHeight(buttonColumnW, 52, "TOGGLE READ"))
				local postButtonH = select(1, self:GetRequestFieldHeight(buttonColumnW, 52, "NEW UPDATE"))
				local buttonColumnH = (buttonStartY - buttonColumnY) + draftButtonH + entryButtonH + postButtonH + (buttonGap * 2) + 10
				local lowerControlsY = bulletinPanelBottom + 14
				local lowerControlsX = left + 24
				local lowerControlsW = 552
				local lowerControlGap = 12
				local lowerButtonW = math.floor((lowerControlsW - lowerControlGap) * 0.5)
				local boardButtonH = select(1, self:GetRequestFieldHeight(lowerButtonW, 52, "NEXT POST"))
				local filterButtonH = select(1, self:GetRequestFieldHeight(lowerButtonW, 52, activeFilter))
				local lowerControlsH = 36 + math.max(boardButtonH, filterButtonH) + 10
				local canPostBulletins = self:CanPostBulletinsApp(LocalPlayer())
				local deleteSize = 18
				local deleteX = left + 548
				local deleteY = bulletinPanelY + 12

				draw.RoundedBox(0, left + 24, bulletinPanelY, 202, bulletinPanelH, Color(0, 0, 0, 232))
				draw.RoundedBox(0, left + 242, bulletinPanelY, 334, bulletinPanelH, Color(0, 0, 0, 232))
				surface.SetDrawColor(255, 255, 255, 135)
				surface.DrawOutlinedRect(left + 24, bulletinPanelY, 202, bulletinPanelH, 2)
				surface.DrawOutlinedRect(left + 242, bulletinPanelY, 334, bulletinPanelH, 2)
				draw.SimpleText("POSTS // " .. activeFilter, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 36, bulletinPanelY + 12, Color(165, 180, 195, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				draw.DrawText(wrappedEntryTitle, "DeepGaming.FoundationTablet.HealthSubtitle", left + 258, bulletinPanelY + 16, Color(255, 255, 255, 245), TEXT_ALIGN_LEFT)
				draw.DrawText(wrappedEntryMeta, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 258, bulletinPanelY + 28 + entryTitleH, priorityColor, TEXT_ALIGN_LEFT)
				draw.DrawText(wrappedEntryStatus, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 258, bulletinPanelY + 40 + entryTitleH + entryMetaH, entry.acknowledged and Color(130, 220, 170, 235) or Color(255, 205, 120, 240), TEXT_ALIGN_LEFT)

				self.BulletinDetailScrollRegion = detailBodyH > 0 and {
					x = left + 258,
					y = detailBodyY,
					w = 298,
					h = detailBodyH
				} or nil
				self.BulletinDetailScrollMax = math.max(0, entryBodyTextH - detailBodyH)
				self:BeginTabletClip(left + 258, detailBodyY, 298, detailBodyH)
				draw.DrawText(wrappedEntryBody, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 258, detailBodyY - bulletinDetailScroll, Color(235, 235, 235, 240), TEXT_ALIGN_LEFT)
				self:EndTabletClip()
				self:DrawTabletInnerScrollBar(left + 564, detailBodyY, 6, detailBodyH, bulletinDetailScroll, self.BulletinDetailScrollMax)

				draw.RoundedBox(0, buttonColumnX, buttonColumnY, buttonColumnW, buttonColumnH, Color(0, 0, 0, 232))
				surface.SetDrawColor(255, 255, 255, 135)
				surface.DrawOutlinedRect(buttonColumnX, buttonColumnY, buttonColumnW, buttonColumnH, 2)
				draw.SimpleText("CONTROLS", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", buttonColumnX + 12, buttonColumnY + 10, Color(165, 180, 195, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

				if FOUNDATION_DELETE_ICON and canPostBulletins then
					surface.SetMaterial(FOUNDATION_DELETE_ICON)
					surface.SetDrawColor(220, 70, 70, 245)
					surface.DrawTexturedRect(deleteX, deleteY, deleteSize, deleteSize)
					table.insert(self.TabletClickableRegions, {
						x = deleteX,
						y = deleteY,
						w = deleteSize,
						h = deleteSize,
						onClick = function(wep)
							wep:DeleteActiveBulletin()
						end
					})
				end

				local bulletinY = bulletinTop + 164
				self:BeginTabletClip(left + 36, listVisibleTop, 178, listVisibleBottom - listVisibleTop)
				if #filteredEntries == 0 then
					self:DrawWrappedTabletText("NO POSTS MATCH THIS FILTER.", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 40, listVisibleTop + 4, Color(170, 180, 190, 220), TEXT_ALIGN_LEFT, 166)
				else
					for _, bulletinData in ipairs(filteredEntries) do
						local bulletin = bulletinData.entry or {}
						local sourceIndex = bulletinData.index
						local selected = sourceIndex == board.ActiveIndex
						local wrappedBulletinTitle, _, _, bulletinTitleH = self:GetWrappedTextMetrics(tostring(bulletin.title or "POST"), "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 158)
						local bulletinMeta = tostring(bulletin.priority or "STANDARD") .. (bulletin.acknowledged and " // READ" or " // NEW")
						local wrappedBulletinPriority, _, _, bulletinPriorityH = self:GetWrappedTextMetrics(bulletinMeta, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 158)
						local bulletinH = math.max(72, 16 + bulletinTitleH + bulletinPriorityH + 12)

						if bulletinY < listVisibleBottom and (bulletinY + bulletinH) > listVisibleTop then
							draw.RoundedBox(0, left + 36, bulletinY, 178, bulletinH, selected and Color(20, 30, 40, 235) or Color(12, 12, 12, 225))
							surface.SetDrawColor(255, 255, 255, selected and 145 or 60)
							surface.DrawOutlinedRect(left + 36, bulletinY, 178, bulletinH, 1)
							draw.DrawText(wrappedBulletinTitle, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 46, bulletinY + 10, Color(255, 255, 255, 235), TEXT_ALIGN_LEFT)
							draw.DrawText(wrappedBulletinPriority, "DeepGaming.FoundationTablet.HealthEmbeddedTitle", left + 46, bulletinY + 12 + bulletinTitleH, self:GetBulletinPriorityColor(bulletin.priority), TEXT_ALIGN_LEFT)

							table.insert(self.TabletClickableRegions, {
								x = left + 36,
								y = math.max(bulletinY, listVisibleTop),
								w = 178,
								h = math.min(bulletinH, listVisibleBottom - bulletinY),
								onClick = function(wep)
									wep:EnsureBulletinsBoard()
									wep.BulletinsBoard.ActiveIndex = sourceIndex
									wep:ResetBulletinDetailScroll()
									wep:SetBulletinStatus("VIEWING BULLETIN // " .. string.upper(tostring(bulletin.title or "POST")))
								end
							})
						end

						bulletinY = bulletinY + bulletinH + 10
					end
				end
				self:EndTabletClip()

				self.ActiveTabletScrollMax = math.max(0, (math.max(buttonColumnY + buttonColumnH, lowerControlsY + lowerControlsH) + bulletinScroll + 12) - (top + 500))
				local buttonY = buttonStartY
				local draftBoxH = self:DrawRequestField(buttonColumnX, buttonY, buttonColumnW, 52, "BULLETIN TYPE", canPostBulletins and draftPriority or "COMMAND ONLY", canPostBulletins and function(wep)
					wep:CycleBulletinPriority()
				end or nil, canPostBulletins and self:GetBulletinPriorityColor(draftPriority) or Color(255, 170, 120, 240))
				buttonY = buttonY + draftBoxH + buttonGap
				local entryBoxH = self:DrawRequestField(buttonColumnX, buttonY, buttonColumnW, 52, "ENTRY", "TOGGLE READ", function(wep)
					wep:ToggleBulletinAcknowledged()
				end, entry.acknowledged and Color(130, 220, 170, 240) or Color(255, 205, 120, 240))
				buttonY = buttonY + entryBoxH + buttonGap
				self:DrawRequestField(buttonColumnX, buttonY, buttonColumnW, 52, "POST", canPostBulletins and "NEW UPDATE" or "POSTING LOCKED", canPostBulletins and function(wep)
					wep:CreateBulletinEntry()
				end or nil, canPostBulletins and Color(130, 220, 170, 240) or Color(255, 170, 120, 240))

				draw.RoundedBox(0, lowerControlsX, lowerControlsY, lowerControlsW, lowerControlsH, Color(0, 0, 0, 232))
				surface.SetDrawColor(255, 255, 255, 135)
				surface.DrawOutlinedRect(lowerControlsX, lowerControlsY, lowerControlsW, lowerControlsH, 2)
				draw.SimpleText("BOARD CONTROLS", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", lowerControlsX + 12, lowerControlsY + 10, Color(165, 180, 195, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				local lowerButtonY = lowerControlsY + 36
				self:DrawRequestField(lowerControlsX + 8, lowerButtonY, lowerButtonW - 8, 52, "BOARD", "NEXT POST", function(wep)
					wep:CycleBulletin()
				end, Color(120, 185, 255, 240))
				self:DrawRequestField(lowerControlsX + lowerButtonW + lowerControlGap, lowerButtonY, lowerButtonW - 8, 52, "FILTER", activeFilter, function(wep)
					wep:CycleBulletinFilter()
				end, Color(220, 200, 160, 240))

				self:DrawTabletScrollChrome(left, top, screenW, screenH, top + 102, top + 506, bulletinScroll, self.ActiveTabletScrollMax)
				self:DrawApplicationCard(left + 24, top + 26, 52, 52, {
					icon = FOUNDATION_BACK_ICON,
					iconOnly = true,
					onClick = function(wep)
						wep.TabletView = "home"
					end
				})
				self:DrawWrappedTabletText("BULLETINS", "DeepGaming.FoundationTablet.Subtitle", 0, top + 34, Color(255, 255, 255, 245), TEXT_ALIGN_CENTER, 620)
				self:DrawWrappedTabletText(board.StatusNote or "SITE-WIDE UPDATES READY", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 0, top + 66, Color(120, 185, 255, 235), TEXT_ALIGN_CENTER, 620)
			else
				self:DrawWrappedTabletText("APPLICATIONS", "DeepGaming.FoundationTablet.HealthSubtitle", 0, top + 148, Color(255, 255, 255, 245), TEXT_ALIGN_CENTER, 620)

				local orderedApplications = {}
				for appId, appData in pairs(self.TabletApplications or {}) do
					orderedApplications[#orderedApplications + 1] = {
						id = appId,
						data = appData
					}
				end

				table.sort(orderedApplications, function(a, b)
					return (a.data.title or a.id) < (b.data.title or b.id)
				end)

				local appCount = math.min(#orderedApplications, 16)
				local rows = math.max(1, math.ceil(appCount / 4))
				local gap = 16
				local gridAreaTop = top + 205
				local gridAreaHeight = 250
				local gridAreaWidth = screenW - 80
				local widestRowCount = math.min(4, math.max(1, appCount))
				local cardSize = math.floor(math.min(
					(gridAreaWidth - (gap * math.max(widestRowCount - 1, 0))) / widestRowCount,
					(gridAreaHeight - (gap * math.max(rows - 1, 0))) / rows,
					120
				))
				local totalHeight = (rows * cardSize) + (gap * math.max(rows - 1, 0))
				local startY = gridAreaTop + ((gridAreaHeight - totalHeight) * 0.5)

				for row = 0, rows - 1 do
					local rowStartIndex = (row * 4) + 1
					local rowEndIndex = math.min(rowStartIndex + 3, appCount)
					local rowCount = rowEndIndex - rowStartIndex + 1
					local rowWidth = (rowCount * cardSize) + (gap * math.max(rowCount - 1, 0))
					local rowStartX = left + ((screenW - rowWidth) * 0.5)

					for index = rowStartIndex, rowEndIndex do
						local col = index - rowStartIndex
						local app = orderedApplications[index]
						self:DrawApplicationCard(rowStartX + (col * (cardSize + gap)), startY + (row * (cardSize + gap)), cardSize, cardSize, app.data)
					end
				end

				self:DrawWrappedTabletText("SELECT AN APPLICATION", "DeepGaming.FoundationTablet.HealthEmbeddedTitle", 0, math.min(top + 480, startY + totalHeight + 22), Color(170, 180, 190, 220), TEXT_ALIGN_CENTER, 620)

			end

			if not (IsValid(self.ActiveTabletQueryFrame) or IsValid(self.ResearchEditorFrame)) then
				surface.SetDrawColor(255, 255, 255, 245)
				surface.DrawRect((self.TabletCursorX or 0) - 1, (self.TabletCursorY or 0) - 9, 2, 18)
				surface.DrawRect((self.TabletCursorX or 0) - 9, (self.TabletCursorY or 0) - 1, 18, 2)
			end
		end
	end
end

-- Define SWEP render elements
SWEP.VElements = {
	["tablet"] = { type = "Model", model = "models/nirrti/tablet/tablet_sfm.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.714, 6.714, -3.636), angle = Angle(29, 100, -127.403), size = Vector(0.95, 0.95, 0.95), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 1, bodygroup = {} },
	["screen"] = { type = "Quad", bone = "ValveBiped.Bip01_R_Hand", rel = "tablet", pos = Vector(-0.2, -0.04, 1.9), angle = Angle(0,0,0), size = 0.0108, draw_func = function(wep) if wep.DrawFoundationTabletUI then wep:DrawFoundationTabletUI() end end }
}

SWEP.WElements = {
	["tablet"] = { type = "Model", model = "models/nirrti/tablet/tablet_sfm.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6.513, 5.714, -2.597), angle = Angle(26.882, 113.376, -127.403), size = Vector(0.82, 0.82, 0.82), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 1, bodygroup = {} },
	["light"] = { type = "Sprite", sprite = "sprites/blueglow1", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.675, 1, -2.398), size = { x = 1.729, y = 1.729 }, color = Color(255, 255, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false}
}

-- Setup networking for SWEP
function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "TabletRaised")
end

if SERVER then
	net.Receive("DeepGaming.FoundationTablet.Toggle", function(_, ply)
		local wep = IsValid(ply) and ply:GetActiveWeapon() or nil
		if not IsValid(wep) or not wep.SetTabletRaised or not wep.GetTabletRaised then return end
		if wep:GetNextSecondaryFire() > CurTime() then return end

		wep:SetTabletRaised(not wep:GetTabletRaised())
		wep:SetNextSecondaryFire(CurTime() + 0.25)
	end)

	net.Receive("DeepGaming.FoundationTablet.RequestDispatch", function(_, ply)
		if not IsValid(ply) or not FoundationTabletHasActiveTablet(ply) then return end

		local requestId = tostring(net.ReadString() or "LE-0000")
		local requestType = tostring(net.ReadString() or "REQUEST")
		local zone = tostring(net.ReadString() or "UNKNOWN")
		local priority = tostring(net.ReadString() or "LOW")
		local threat = tostring(net.ReadString() or "COMPLIANT")
		local unit = tostring(net.ReadString() or "F.E.")
		local requestPosition = ply:GetPos()

		for _, recipient in ipairs(player.GetAll()) do
			if IsValid(recipient) and FoundationTabletIsFETeam(recipient) then
				net.Start("DeepGaming.FoundationTablet.RequestDispatch")
				net.WriteEntity(ply)
				net.WriteString(ply:Nick())
				net.WriteString(requestId)
				net.WriteString(requestType)
				net.WriteString(zone)
				net.WriteString(priority)
				net.WriteString(threat)
				net.WriteString(unit)
				net.WriteVector(requestPosition)
				net.Send(recipient)
			end
		end
	end)

	net.Receive("DeepGaming.FoundationTablet.RequestResolve", function(_, ply)
		if not IsValid(ply) or not FoundationTabletHasActiveTablet(ply) or not FoundationTabletIsFETeam(ply) then return end

		local requestId = tostring(net.ReadString() or "")
		if requestId == "" then return end

		for _, recipient in ipairs(player.GetAll()) do
			if IsValid(recipient) and FoundationTabletIsFETeam(recipient) then
				net.Start("DeepGaming.FoundationTablet.RequestResolve")
				net.WriteString(requestId)
				net.Send(recipient)
			end
		end
	end)

	net.Receive("DeepGaming.FoundationTablet.BulletinDispatch", function(_, ply)
		if not IsValid(ply) or not FoundationTabletHasActiveTablet(ply) then return end

		net.ReadString()
		net.ReadString()

		for _, recipient in ipairs(player.GetAll()) do
			if IsValid(recipient) then
				net.Start("DeepGaming.FoundationTablet.BulletinDispatch")
				net.WriteString(ply:Nick())
				net.Send(recipient)
			end
		end
	end)
end

function SWEP:Deploy()
	if SERVER then
		self:SetTabletRaised(false)
	end

	if CLIENT then
		self.TabletView = "home"
		self.TabletClickableRegions = {}
		self.TeamRosterLayoutCache = nil
		self.RequestsScroll = 0
		self.RequestsScrollLerp = 0
		self.AppScroll = 0
		self.AppScrollLerp = 0
		self.LawEntryScroll = 0
		self.LawEntryScrollLerp = 0
		self.LawEntryScrollMax = 0
		self.LawEntryScrollRegion = nil
		self.LawSubjectMenuScroll = 0
		self.LawSubjectMenuScrollLerp = 0
		self.LawSubjectMenuScrollMax = 0
		self.LawSubjectMenuRegion = nil
		self.LawRequestSubjectScroll = 0
		self.LawRequestSubjectScrollLerp = 0
		self.LawRequestSubjectScrollMax = 0
		self.LawRequestSubjectRegion = nil
		self.BulletinDetailScroll = 0
		self.BulletinDetailScrollLerp = 0
		self.BulletinDetailScrollMax = 0
		self.BulletinDetailScrollRegion = nil
		self.ResearchViewerScroll = 0
		self.ResearchViewerScrollLerp = 0
		self.ResearchViewerScrollMax = 0
		self.ResearchViewerScrollRegion = nil
		self.ActiveTabletScrollMax = 0
		if self.EnsureTabletApplications then
			self:EnsureTabletApplications()
		end
	end

	return true
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.15)
end

function SWEP:SecondaryAttack()
	local ply = self:GetOwner()
	local nextState = not self:GetTabletRaised()

	self:SetNextSecondaryFire(CurTime() + 0.25)

	if not IsValid(ply) then return end

	if SERVER then
		self:SetTabletRaised(nextState)
	end

end

function SWEP:Reload()
	self:SetNextPrimaryFire(CurTime() + 0.15)
end

function SWEP:Think()
	if CLIENT then
		local owner = self:GetOwner()
		local raised = self:GetTabletRaised()
		local ownerAlive = IsValid(owner) and owner:Alive()

		self.TabletRaiseLerp = Lerp(FrameTime() * 10, self.TabletRaiseLerp or 0, raised and 1 or 0)

		if self.LastTabletView ~= self.TabletView then
			if self.ResetTabletViewScroll then
				self:ResetTabletViewScroll()
			end
			self.LastTabletView = self.TabletView
		end

		if self.LastOwnerAlive ~= ownerAlive then
			if ownerAlive then
				self.TabletBootCompletedLife = false
			end
			self:ClearTabletBootSequence()
			self.LastOwnerAlive = ownerAlive
		end

		if self.LastTabletRaised ~= raised then
			if raised then
				if not self.TabletBootCompletedLife then
					self:StartTabletBootSequence()
				end
			else
				self:ClearTabletBootSequence()
				self.HoveredTabletRegionKey = nil
			end
			self.LastTabletRaised = raised
		end

		local shouldEnableClicker = IsValid(owner) and owner == LocalPlayer() and owner:GetActiveWeapon() == self and raised
		local hasModalOpen = IsValid(self.ActiveTabletQueryFrame) or IsValid(self.ResearchEditorFrame)
		if self.ScreenClickerEnabled ~= shouldEnableClicker then
			gui.EnableScreenClicker(shouldEnableClicker)
			self.ScreenClickerEnabled = shouldEnableClicker

			local worldPanel = vgui.GetWorldPanel()
			if IsValid(worldPanel) then
				worldPanel:SetCursor(shouldEnableClicker and (hasModalOpen and "arrow" or "blank") or "arrow")
			end

			if shouldEnableClicker then
				self.NextScreenClickerToggle = CurTime() + 0.3
			end
		end

		if shouldEnableClicker then
			local worldPanel = vgui.GetWorldPanel()
			if IsValid(worldPanel) then
				worldPanel:SetCursor(hasModalOpen and "arrow" or "blank")
			end
		end

		local activeScrollMax = math.max(0, self.ActiveTabletScrollMax or 0)
		local lawEntryScrollMax = math.max(0, self.LawEntryScrollMax or 0)
		local lawSubjectMenuScrollMax = math.max(0, self.LawSubjectMenuScrollMax or 0)
		local lawRequestSubjectScrollMax = math.max(0, self.LawRequestSubjectScrollMax or 0)
		local bulletinDetailScrollMax = math.max(0, self.BulletinDetailScrollMax or 0)
		local researchViewerScrollMax = math.max(0, self.ResearchViewerScrollMax or 0)
		local breachListScrollMax = math.max(0, self.BreachListScrollMax or 0)
		local breachNoteScrollMax = math.max(0, self.BreachNoteScrollMax or 0)
		local breachDirectiveScrollMax = math.max(0, self.BreachDirectiveScrollMax or 0)
		local lawEntryRegion = self.LawEntryScrollRegion
		local lawSubjectMenuRegion = self.LawSubjectMenuRegion
		local lawRequestSubjectRegion = self.LawRequestSubjectRegion
		local bulletinDetailRegion = self.BulletinDetailScrollRegion
		local researchViewerRegion = self.ResearchViewerScrollRegion
		local breachListRegion = self.BreachListScrollRegion
		local breachNoteRegion = self.BreachNoteScrollRegion
		local breachDirectiveRegion = self.BreachDirectiveScrollRegion
		local hoveringLawEntryRegion = shouldEnableClicker and self.TabletView == "law_enforcement"
			and self.LawEnforcementBoard and self.LawEnforcementBoard.ActiveTab ~= "requests"
			and lawEntryRegion
			and (self.TabletCursorX or 0) >= lawEntryRegion.x and (self.TabletCursorX or 0) <= (lawEntryRegion.x + lawEntryRegion.w)
			and (self.TabletCursorY or 0) >= lawEntryRegion.y and (self.TabletCursorY or 0) <= (lawEntryRegion.y + lawEntryRegion.h)
		local hoveringLawSubjectMenuRegion = shouldEnableClicker and self.TabletView == "law_enforcement"
			and self.LawEnforcementBoard and self.LawEnforcementBoard.SubjectMenuOpen
			and lawSubjectMenuRegion
			and (self.TabletCursorX or 0) >= lawSubjectMenuRegion.x and (self.TabletCursorX or 0) <= (lawSubjectMenuRegion.x + lawSubjectMenuRegion.w)
			and (self.TabletCursorY or 0) >= lawSubjectMenuRegion.y and (self.TabletCursorY or 0) <= (lawSubjectMenuRegion.y + lawSubjectMenuRegion.h)
		local hoveringLawRequestSubjectRegion = shouldEnableClicker and self.TabletView == "law_enforcement"
			and self.LawEnforcementBoard and self.LawEnforcementBoard.ActiveTab == "requests"
			and lawRequestSubjectRegion
			and (self.TabletCursorX or 0) >= lawRequestSubjectRegion.x and (self.TabletCursorX or 0) <= (lawRequestSubjectRegion.x + lawRequestSubjectRegion.w)
			and (self.TabletCursorY or 0) >= lawRequestSubjectRegion.y and (self.TabletCursorY or 0) <= (lawRequestSubjectRegion.y + lawRequestSubjectRegion.h)
		local hoveringBulletinDetailRegion = shouldEnableClicker and self.TabletView == "bulletins"
			and bulletinDetailRegion
			and (self.TabletCursorX or 0) >= bulletinDetailRegion.x and (self.TabletCursorX or 0) <= (bulletinDetailRegion.x + bulletinDetailRegion.w)
			and (self.TabletCursorY or 0) >= bulletinDetailRegion.y and (self.TabletCursorY or 0) <= (bulletinDetailRegion.y + bulletinDetailRegion.h)
		local hoveringResearchViewerRegion = shouldEnableClicker and self.TabletView == "research_archive"
			and researchViewerRegion
			and (self.TabletCursorX or 0) >= researchViewerRegion.x and (self.TabletCursorX or 0) <= (researchViewerRegion.x + researchViewerRegion.w)
			and (self.TabletCursorY or 0) >= researchViewerRegion.y and (self.TabletCursorY or 0) <= (researchViewerRegion.y + researchViewerRegion.h)
		local hoveringBreachListRegion = shouldEnableClicker and self.TabletView == "breach_monitor"
			and breachListRegion
			and (self.TabletCursorX or 0) >= breachListRegion.x and (self.TabletCursorX or 0) <= (breachListRegion.x + breachListRegion.w)
			and (self.TabletCursorY or 0) >= breachListRegion.y and (self.TabletCursorY or 0) <= (breachListRegion.y + breachListRegion.h)
		local hoveringBreachNoteRegion = shouldEnableClicker and self.TabletView == "breach_monitor"
			and breachNoteRegion
			and (self.TabletCursorX or 0) >= breachNoteRegion.x and (self.TabletCursorX or 0) <= (breachNoteRegion.x + breachNoteRegion.w)
			and (self.TabletCursorY or 0) >= breachNoteRegion.y and (self.TabletCursorY or 0) <= (breachNoteRegion.y + breachNoteRegion.h)
		local hoveringBreachDirectiveRegion = shouldEnableClicker and self.TabletView == "breach_monitor"
			and breachDirectiveRegion
			and (self.TabletCursorX or 0) >= breachDirectiveRegion.x and (self.TabletCursorX or 0) <= (breachDirectiveRegion.x + breachDirectiveRegion.w)
			and (self.TabletCursorY or 0) >= breachDirectiveRegion.y and (self.TabletCursorY or 0) <= (breachDirectiveRegion.y + breachDirectiveRegion.h)
		local isBooting = self.IsTabletBooting and self:IsTabletBooting() or false

		if shouldEnableClicker and self.TabletBootEnd and not self.TabletBootSoundPlayed and CurTime() >= self.TabletBootEnd then
			self.TabletBootSoundPlayed = true
			self.TabletBootCompletedLife = true
			surface.PlaySound(FOUNDATION_TABLET_RAISE_SOUND)
		end

		if shouldEnableClicker and not hasModalOpen and not isBooting and self.TabletView and self.TabletView ~= "home" then
			if self.TabletView == "requests" then
				self.RequestsScroll = math.Clamp(self.RequestsScroll or 0, 0, activeScrollMax)
				if activeScrollMax > 0 then
					if input.WasMousePressed(MOUSE_WHEEL_DOWN) then
						self.RequestsScroll = math.min((self.RequestsScroll or 0) + 36, activeScrollMax)
					elseif input.WasMousePressed(MOUSE_WHEEL_UP) then
						self.RequestsScroll = math.max((self.RequestsScroll or 0) - 36, 0)
					end
				end
			else
				self.AppScroll = math.Clamp(self.AppScroll or 0, 0, activeScrollMax)
				self.LawEntryScroll = math.Clamp(self.LawEntryScroll or 0, 0, lawEntryScrollMax)
				self.LawSubjectMenuScroll = math.Clamp(self.LawSubjectMenuScroll or 0, 0, lawSubjectMenuScrollMax)
				self.LawRequestSubjectScroll = math.Clamp(self.LawRequestSubjectScroll or 0, 0, lawRequestSubjectScrollMax)
				self.BulletinDetailScroll = math.Clamp(self.BulletinDetailScroll or 0, 0, bulletinDetailScrollMax)
				self.ResearchViewerScroll = math.Clamp(self.ResearchViewerScroll or 0, 0, researchViewerScrollMax)
				self.BreachListScroll = math.Clamp(self.BreachListScroll or 0, 0, breachListScrollMax)
				self.BreachNoteScroll = math.Clamp(self.BreachNoteScroll or 0, 0, breachNoteScrollMax)
				self.BreachDirectiveScroll = math.Clamp(self.BreachDirectiveScroll or 0, 0, breachDirectiveScrollMax)
				if input.WasMousePressed(MOUSE_WHEEL_DOWN) then
					if hoveringBreachNoteRegion and breachNoteScrollMax > 0 then
						self.BreachNoteScroll = math.min((self.BreachNoteScroll or 0) + 24, breachNoteScrollMax)
					elseif hoveringBreachDirectiveRegion and breachDirectiveScrollMax > 0 then
						self.BreachDirectiveScroll = math.min((self.BreachDirectiveScroll or 0) + 24, breachDirectiveScrollMax)
					elseif hoveringBreachListRegion and breachListScrollMax > 0 then
						self.BreachListScroll = math.min((self.BreachListScroll or 0) + 28, breachListScrollMax)
					elseif hoveringResearchViewerRegion and researchViewerScrollMax > 0 then
						self.ResearchViewerScroll = math.min((self.ResearchViewerScroll or 0) + 32, researchViewerScrollMax)
					elseif hoveringBulletinDetailRegion and bulletinDetailScrollMax > 0 then
						self.BulletinDetailScroll = math.min((self.BulletinDetailScroll or 0) + 32, bulletinDetailScrollMax)
					elseif hoveringLawRequestSubjectRegion and lawRequestSubjectScrollMax > 0 then
						self.LawRequestSubjectScroll = math.min((self.LawRequestSubjectScroll or 0) + 28, lawRequestSubjectScrollMax)
					elseif hoveringLawSubjectMenuRegion and lawSubjectMenuScrollMax > 0 then
						self.LawSubjectMenuScroll = math.min((self.LawSubjectMenuScroll or 0) + 28, lawSubjectMenuScrollMax)
					elseif hoveringLawEntryRegion and lawEntryScrollMax > 0 then
						self.LawEntryScroll = math.min((self.LawEntryScroll or 0) + 32, lawEntryScrollMax)
					elseif activeScrollMax > 0 then
						self.AppScroll = math.min((self.AppScroll or 0) + 36, activeScrollMax)
					end
				elseif input.WasMousePressed(MOUSE_WHEEL_UP) then
					if hoveringBreachNoteRegion and breachNoteScrollMax > 0 then
						self.BreachNoteScroll = math.max((self.BreachNoteScroll or 0) - 24, 0)
					elseif hoveringBreachDirectiveRegion and breachDirectiveScrollMax > 0 then
						self.BreachDirectiveScroll = math.max((self.BreachDirectiveScroll or 0) - 24, 0)
					elseif hoveringBreachListRegion and breachListScrollMax > 0 then
						self.BreachListScroll = math.max((self.BreachListScroll or 0) - 28, 0)
					elseif hoveringResearchViewerRegion and researchViewerScrollMax > 0 then
						self.ResearchViewerScroll = math.max((self.ResearchViewerScroll or 0) - 32, 0)
					elseif hoveringBulletinDetailRegion and bulletinDetailScrollMax > 0 then
						self.BulletinDetailScroll = math.max((self.BulletinDetailScroll or 0) - 32, 0)
					elseif hoveringLawRequestSubjectRegion and lawRequestSubjectScrollMax > 0 then
						self.LawRequestSubjectScroll = math.max((self.LawRequestSubjectScroll or 0) - 28, 0)
					elseif hoveringLawSubjectMenuRegion and lawSubjectMenuScrollMax > 0 then
						self.LawSubjectMenuScroll = math.max((self.LawSubjectMenuScroll or 0) - 28, 0)
					elseif hoveringLawEntryRegion and lawEntryScrollMax > 0 then
						self.LawEntryScroll = math.max((self.LawEntryScroll or 0) - 32, 0)
					elseif activeScrollMax > 0 then
						self.AppScroll = math.max((self.AppScroll or 0) - 36, 0)
					end
				end
			end
		else
			self.RequestsScroll = self.RequestsScroll or 0
			self.AppScroll = self.AppScroll or 0
			self.LawEntryScroll = self.LawEntryScroll or 0
			self.LawSubjectMenuScroll = self.LawSubjectMenuScroll or 0
			self.LawRequestSubjectScroll = self.LawRequestSubjectScroll or 0
			self.BulletinDetailScroll = self.BulletinDetailScroll or 0
			self.ResearchViewerScroll = self.ResearchViewerScroll or 0
			self.BreachListScroll = self.BreachListScroll or 0
			self.BreachNoteScroll = self.BreachNoteScroll or 0
			self.BreachDirectiveScroll = self.BreachDirectiveScroll or 0
		end

		self.RequestsScrollLerp = Lerp(FrameTime() * 12, self.RequestsScrollLerp or self.RequestsScroll or 0, self.RequestsScroll or 0)
		self.AppScrollLerp = Lerp(FrameTime() * 12, self.AppScrollLerp or self.AppScroll or 0, self.AppScroll or 0)
		self.LawEntryScrollLerp = Lerp(FrameTime() * 12, self.LawEntryScrollLerp or self.LawEntryScroll or 0, self.LawEntryScroll or 0)
		self.LawSubjectMenuScrollLerp = Lerp(FrameTime() * 12, self.LawSubjectMenuScrollLerp or self.LawSubjectMenuScroll or 0, self.LawSubjectMenuScroll or 0)
		self.LawRequestSubjectScrollLerp = Lerp(FrameTime() * 12, self.LawRequestSubjectScrollLerp or self.LawRequestSubjectScroll or 0, self.LawRequestSubjectScroll or 0)
		self.BulletinDetailScrollLerp = Lerp(FrameTime() * 12, self.BulletinDetailScrollLerp or self.BulletinDetailScroll or 0, self.BulletinDetailScroll or 0)
		self.ResearchViewerScrollLerp = Lerp(FrameTime() * 12, self.ResearchViewerScrollLerp or self.ResearchViewerScroll or 0, self.ResearchViewerScroll or 0)
		self.BreachListScrollLerp = Lerp(FrameTime() * 12, self.BreachListScrollLerp or self.BreachListScroll or 0, self.BreachListScroll or 0)
		self.BreachNoteScrollLerp = Lerp(FrameTime() * 12, self.BreachNoteScrollLerp or self.BreachNoteScroll or 0, self.BreachNoteScroll or 0)
		self.BreachDirectiveScrollLerp = Lerp(FrameTime() * 12, self.BreachDirectiveScrollLerp or self.BreachDirectiveScroll or 0, self.BreachDirectiveScroll or 0)

		if self.RequestDraft and self.RequestDraft.Status == "SUBMITTED" and self.RequestDraft.AutoResetAt and CurTime() >= self.RequestDraft.AutoResetAt then
			self:ResetRequestDraft()
		end

		if shouldEnableClicker and not hasModalOpen and not isBooting then
			local hoveredRegionKey = nil
			for _, region in ipairs(self.TabletClickableRegions or {}) do
				if (self.TabletCursorX or 0) >= region.x and (self.TabletCursorX or 0) <= (region.x + region.w)
				and (self.TabletCursorY or 0) >= region.y and (self.TabletCursorY or 0) <= (region.y + region.h) then
					hoveredRegionKey = tostring(region.hoverKey or (math.floor(region.x + 0.5) .. ":" .. math.floor(region.y + 0.5) .. ":" .. math.floor(region.w + 0.5) .. ":" .. math.floor(region.h + 0.5)))
					break
				end
			end

			if hoveredRegionKey and hoveredRegionKey ~= self.HoveredTabletRegionKey and (self.NextTabletHoverSoundAt or 0) <= CurTime() then
				surface.PlaySound(FOUNDATION_TABLET_HOVER_SOUND)
				self.NextTabletHoverSoundAt = CurTime() + 0.05
			end

			self.HoveredTabletRegionKey = hoveredRegionKey
		else
			self.HoveredTabletRegionKey = nil
		end

		if shouldEnableClicker and not hasModalOpen and not isBooting and input.WasMousePressed(MOUSE_LEFT) and (self.NextTabletLeftClick or 0) <= CurTime() then
			self.NextTabletLeftClick = CurTime() + 0.2

			for _, region in ipairs(self.TabletClickableRegions or {}) do
				if (self.TabletCursorX or 0) >= region.x and (self.TabletCursorX or 0) <= (region.x + region.w)
				and (self.TabletCursorY or 0) >= region.y and (self.TabletCursorY or 0) <= (region.y + region.h) then
					if isfunction(region.onClick) then
						region.onClick(self)
						surface.PlaySound(FOUNDATION_TABLET_CLICK_SOUND)
					end
					break
				end
			end
		end

		if shouldEnableClicker and not hasModalOpen and not isBooting and input.WasMousePressed(MOUSE_RIGHT) and (self.NextScreenClickerToggle or 0) <= CurTime() then
			self.NextScreenClickerToggle = CurTime() + 0.25
			net.Start("DeepGaming.FoundationTablet.Toggle")
			net.SendToServer()
		end
	end
end

if CLIENT then
	function SWEP:PostDrawViewModel(vm, wep, ply)
		-- Screen UI is rendered by the tablet-attached quad in `SWEP.VElements.screen`.
	end
end

function SWEP:GetViewModelPosition(pos, ang)
	self.SwayScale = 0
	self.BobScale = 0.1

	local raiseFrac = self.TabletRaiseLerp or (self:GetTabletRaised() and 1 or 0)
	if raiseFrac <= 0.001 then
		return pos, ang
	end

	pos = pos + ang:Forward() * (-10.4 * raiseFrac)
	pos = pos + ang:Up() * (4.5 * raiseFrac)


	return pos, ang
end

function SWEP:Initialize()
	self:SetHoldType("slam")

	if SERVER then
		self:SetTabletRaised(false)
	end

	if CLIENT then
		self.TabletRaiseLerp = 0
		self.ScreenClickerEnabled = false
		self.TabletView = "home"
		self.TabletApplicationsInitialized = false
		self.TabletClickableRegions = {}
		self.TeamRosterLayoutCache = nil
		self.RequestsScroll = 0
		self.RequestsScrollLerp = 0
		self.AppScroll = 0
		self.AppScrollLerp = 0
		self.LawEntryScroll = 0
		self.LawEntryScrollLerp = 0
		self.LawEntryScrollMax = 0
		self.LawEntryScrollRegion = nil
		self.LawSubjectMenuScroll = 0
		self.LawSubjectMenuScrollLerp = 0
		self.LawSubjectMenuScrollMax = 0
		self.LawSubjectMenuRegion = nil
		self.LawRequestSubjectScroll = 0
		self.LawRequestSubjectScrollLerp = 0
		self.LawRequestSubjectScrollMax = 0
		self.LawRequestSubjectRegion = nil
		self.BulletinDetailScroll = 0
		self.BulletinDetailScrollLerp = 0
		self.BulletinDetailScrollMax = 0
		self.BulletinDetailScrollRegion = nil
		self.ResearchViewerScroll = 0
		self.ResearchViewerScrollLerp = 0
		self.ResearchViewerScrollMax = 0
		self.ResearchViewerScrollRegion = nil
		self.BreachListScroll = 0
		self.BreachListScrollLerp = 0
		self.BreachListScrollMax = 0
		self.BreachListScrollRegion = nil
		self.BreachNoteScroll = 0
		self.BreachNoteScrollLerp = 0
		self.BreachNoteScrollMax = 0
		self.BreachNoteScrollRegion = nil
		self.BreachDirectiveScroll = 0
		self.BreachDirectiveScrollLerp = 0
		self.BreachDirectiveScrollMax = 0
		self.BreachDirectiveScrollRegion = nil
		self.ActiveTabletScrollMax = 0
		self.TabletBootCompletedLife = false
		self.TabletBootStart = nil
		self.TabletBootEnd = nil
		self.TabletBootSoundPlayed = nil
		self.LastOwnerAlive = nil
		self.LastTabletRaised = false
		self.VElements = table.FullCopy(self.VElements)
		self.WElements = table.FullCopy(self.WElements)
		self.ViewModelBoneMods = table.FullCopy(self.ViewModelBoneMods)

		self:CreateModels(self.VElements)
		self:CreateModels(self.WElements)
		
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					vm:SetColor(Color(255,255,255,1))
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
	end
end

function SWEP:Holster()
	if SERVER then
		self:SetTabletRaised(false)
	end

	if CLIENT then
		if IsValid(self.ResearchEditorFrame) then
			self.ResearchEditorFrame:Remove()
		end

		if IsValid(self.ActiveTabletQueryFrame) then
			self.ActiveTabletQueryFrame:Remove()
		end

		if self.ScreenClickerEnabled then
			gui.EnableScreenClicker(false)
			self.ScreenClickerEnabled = false
		end

		local worldPanel = vgui.GetWorldPanel()
		if IsValid(worldPanel) then
			worldPanel:SetCursor("arrow")
		end

		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
			end
		end
	end
	
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then
	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
		end

		for k, name in ipairs(self.vRenderOrder) do
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation(self.VElements, v, vm)
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix("RenderMultiply", matrix)
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial(v.material)
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
			elseif (v.type == "Sprite" and sprite) then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z

				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z

				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func(self)
				cam.End3D2D()
			end
		end
	end

	SWEP.wRenderOrder = nil

	function SWEP:DrawWorldModel()
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then
			self.wRenderOrder = {}

			for k, v in pairs(self.WElements) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs(self.wRenderOrder) do
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent)
			else
				pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand")
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix("RenderMultiply", matrix)
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial(v.material)
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func(self)
				cam.End3D2D()
			end
		end
	end

	function SWEP:GetBoneOrientation(basetab, tab, ent, bone_override)
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation(basetab, v, ent)
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels(tab)
		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs(tab) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = {"nocull", "additive", "vertexalpha", "vertexcolor", "ignorez"}
				for i, j in pairs(tocheck) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name, "UnlitGeneric", params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			
			for k, v in pairs(loopthrough) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale(bone, s)
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles(bone, v.angle)
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition(bone, p)
				end
			end
		else
			self:ResetBonePositions(vm)
		end
	end
	 
	function SWEP:ResetBonePositions(vm)
		if (!vm:GetBoneCount()) then return end

		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale(i, Vector(1, 1, 1))
			vm:ManipulateBoneAngles(i, Angle(0, 0, 0))
			vm:ManipulateBonePosition(i, Vector(0, 0, 0))
		end
	end

	function table.FullCopy( tab )
		if (!tab) then return nil end
		
		local res = {}

		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v)
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
	end
end

