local function GmodLanguage(module_name)
	if (SERVER) then return "english" end
	local language_convar = GetConVar("gmod_language")
	local lang = language_convar and language_convar:GetString() or "en"
	if (lang == "en") then return "english" end
	module_name = module_name or "GAS"
	local language_data = GAS.Languages
		and GAS.Languages.LanguageData
		and GAS.Languages.LanguageData[module_name]
	if (not istable(language_data)) then return "english" end
	for lang_name, data in pairs(language_data) do
		if (data.Flag == "flags16/" .. lang .. ".png") then
			return lang_name
		end
	end
	return "english"
end

GAS.Languages = {}

GAS.Languages.DefaultConfig = {
	SelectedLanguages = {},
	ShortDateFormat = false,
	LongDateFormat = false,
}

if (CLIENT) then
	GAS.Languages.Config = GAS:GetLocalConfig("languages", GAS.Languages.DefaultConfig)
else
	GAS.Languages.Config = table.Copy(GAS.Languages.DefaultConfig)
end
GAS.Languages.Config.SelectedLanguages = GAS.Languages.Config.SelectedLanguages or {}

--######## LOAD LANGUAGE DATA ########--

GAS.Languages.LanguageData = {GAS = {}}

function GAS.Languages:LoadLanguageData()
	local languages = file.Find("gmodadminsuite/lang/*.lua", "LUA")
	for _,f in ipairs(languages) do
		local filename = (f:gsub("%.lua$",""))
		GAS.Languages.LanguageData["GAS"][filename] = include("gmodadminsuite/lang/" .. f)
		if (filename == "english" or GAS.Languages.Config.SelectedLanguages.GAS == filename) then
			GAS.Languages.LanguageData["GAS"][filename].Phrases = GAS.Languages.LanguageData["GAS"][filename].Phrases()
		end
	end

	local _,modules = file.Find("gmodadminsuite/modules/*", "LUA")
	for _,module in ipairs(modules) do
		local languages = file.Find("gmodadminsuite/modules/" .. module .. "/lang/*.lua", "LUA")
		if (#languages > 0) then
			GAS.Languages.LanguageData[module] = {}
			for _,f in ipairs(languages) do
				local filename = (f:gsub("%.lua$",""))
				GAS.Languages.LanguageData[module][filename] = include("gmodadminsuite/modules/" .. module .. "/lang/" .. f)
				if (filename == "english" or GAS.Languages.Config.SelectedLanguages[module] == filename) then
					GAS.Languages.LanguageData[module][filename].Phrases = GAS.Languages.LanguageData[module][filename].Phrases()
				end
			end
		end
	end
end
GAS.Languages:LoadLanguageData()

if (GAS.Languages.Config.SelectedLanguages.GAS == nil) then
	GAS.Languages.Config.SelectedLanguages.GAS = GmodLanguage()
end

--######## LANGUAGE FUNCTIONS ########--

function GAS.Languages:LanguageExists(language_name, module_name)
	local language_data = GAS.Languages.LanguageData[module_name or "GAS"]
	return istable(language_data) and language_data[language_name] ~= nil
end

function GAS.Languages:GetSelectedLanguage(module_name)
	if (SERVER) then return "english" end
	if (not module_name) then
		if (GAS.Languages:LanguageExists(GAS.Languages.Config.SelectedLanguages.GAS)) then
			return GAS.Languages.Config.SelectedLanguages.GAS
		else
			return GmodLanguage()
		end
	else
		if (GAS.Languages.Config.SelectedLanguages[module_name] and GAS.Languages:LanguageExists(GAS.Languages.Config.SelectedLanguages[module_name], module_name)) then
			return GAS.Languages.Config.SelectedLanguages[module_name]
		elseif (GAS.Languages:LanguageExists(GAS.Languages.Config.SelectedLanguages.GAS, module_name)) then
			return GAS.Languages.Config.SelectedLanguages.GAS
		else
			return GmodLanguage(module_name)
		end
	end
end

function GAS.Languages:RawPhrase(str, module_name, discriminator)
	local language_data = GAS.Languages.LanguageData[module_name or "GAS"]
	if (not istable(language_data)) then return str end

	local selected_language = GAS.Languages:GetSelectedLanguage(module_name)
	local selected_data = language_data[selected_language] or language_data.english
	if (not istable(selected_data)) then return str end

	local phrase_str
	if (isfunction(selected_data.Phrases)) then
		selected_data.Phrases = selected_data.Phrases()
	end
	if (not istable(selected_data.Phrases)) then return str end

	if (discriminator) then
		local phrases = selected_data.Phrases[discriminator]
		phrase_str = istable(phrases) and phrases[str] or nil
	else
		phrase_str = selected_data.Phrases[str]
	end
	if (phrase_str) then
		return phrase_str
	elseif (selected_language ~= "english") then
		local english_data = language_data.english
		if (not istable(english_data)) then return str end
		if (isfunction(english_data.Phrases)) then
			english_data.Phrases = english_data.Phrases()
		end
		if (not istable(english_data.Phrases)) then return str end

		if (discriminator) then
			if (istable(english_data.Phrases[discriminator])) then
				return english_data.Phrases[discriminator][str] or str
			else
				return str
			end
		else
			return english_data.Phrases[str] or str
		end
	else
		return str
	end
end
function GAS:Phrase(str, module_name, discriminator)
	if (str == "module_name") then
		local friendly_name = GAS.Languages:RawPhrase(str, module_name)
		if (friendly_name == str) then
			return nil
		else
			return friendly_name
		end
	else
		return (GAS.Languages:RawPhrase(str, module_name, discriminator):gsub("\t",""))
	end
end
function GAS:PhraseFormat(str, module_name, ...)
	return GAS:Phrase(str, module_name):format(...)
end

--######## TIMESTAMP LOCALIZATION ########--

function GAS:FormatTimestamp(timestamp)
	if (GAS.Languages.Config.ShortDateFormat ~= false) then
		return os.date(GAS.Languages.Config.ShortDateFormat, timestamp)
	else
		if (CLIENT and (system.GetCountry() == "US" or system.GetCountry() == "CA")) then
			return os.date("%m/%d/%Y %I:%M:%S %p", timestamp)
		else
			return os.date("%d/%m/%Y %I:%M:%S %p", timestamp)
		end
	end
end
function GAS:FormatFullTimestamp(timestamp)
	if (GAS.Languages.Config.LongDateFormat ~= false) then
		return os.date(GAS.Languages.Config.LongDateFormat, timestamp)
	else
		if (CLIENT and (system.GetCountry() == "US" or system.GetCountry() == "CA")) then
			return os.date("%a %m/%d/%Y %I:%M:%S %p", timestamp)
		else
			return os.date("%a %d/%m/%Y %I:%M:%S %p", timestamp)
		end
	end
end
function GAS:SimplifySeconds(seconds)
	if (seconds < 60) then
		local sec = seconds
		local lang_str = "s_seconds"
		if (sec == 1) then lang_str = "s_second" end
		return GAS:PhraseFormat(lang_str, nil, sec)
	elseif (seconds < 3600) then
		local min = math.Round(seconds / 60)
		local lang_str = "s_minutes"
		if (min == 1) then lang_str = "s_minute" end
		return GAS:PhraseFormat(lang_str, nil, min)
	else
		local hour = math.Round(seconds / 60 / 60)
		local lang_str = "s_hours"
		if (hour == 1) then lang_str = "s_hour" end
		return GAS:PhraseFormat(lang_str, nil, hour)
	end
end
function GAS:SimplifyTimestamp(timestamp)
	local difference = os.time() - timestamp
	if (difference == 0) then
		return GAS:Phrase("just_now")
	elseif (difference < 60) then

		local sec = difference
		local lang_str = "seconds_ago"
		if (sec == 1) then lang_str = "second_ago" end
		return GAS:PhraseFormat(lang_str, nil, sec)

	elseif (difference < 3600) then

		local min = math.Round(difference / 60)
		local lang_str = "minutes_ago"
		if (min == 1) then lang_str = "minute_ago" end
		return GAS:PhraseFormat(lang_str, nil, min)

	elseif (difference < 86400) then

		local hour = math.Round(difference / 60 / 60)
		local lang_str = "hours_ago"
		if (hour == 1) then lang_str = "hour_ago" end
		return GAS:PhraseFormat(lang_str, nil, hour)

	else
		return GAS:FormatTimestamp(timestamp)
	end
end

if (SERVER) then
	local languages = file.Find("gmodadminsuite/lang/*.lua", "LUA")
	for _,f in ipairs(languages) do
		AddCSLuaFile("gmodadminsuite/lang/" .. f)
	end

	local _,modules = file.Find("gmodadminsuite/modules/*", "LUA")
	for _,module in ipairs(modules) do
		local languages = file.Find("gmodadminsuite/modules/" .. module .. "/lang/*.lua", "LUA")
		for _,f in ipairs(languages) do
			AddCSLuaFile("gmodadminsuite/modules/" .. module .. "/lang/" .. f)
		end
	end
end
