-- This file must be named aaa_gas_fix.lua to load before gmodadminsuite.lua

-- Patch include() to fix GAS.Languages.LanguageExists right after sh_language.lua loads
local orig_include = include
include = function(path, ...)
	local result = orig_include(path, ...)
	if path and string.find(path, "sh_language") and GAS and GAS.Languages then
		-- Patch LanguageExists immediately after sh_language.lua runs
		function GAS.Languages:LanguageExists(language_name, module_name)
			local moduleData = GAS.Languages.LanguageData[module_name or "GAS"]
			if not moduleData then return false end
			return moduleData[language_name] ~= nil
		end
		function GAS.Languages:RawPhrase(str, module_name, discriminator)
			local selected_language = GAS.Languages:GetSelectedLanguage(module_name)
			local moduleData = GAS.Languages.LanguageData[module_name or "GAS"]
			if not moduleData then return str end
			local langData = moduleData[selected_language]
			if not langData then
				langData = moduleData["english"]
				selected_language = "english"
			end
			if not langData then return str end
			local phrase_str
			if (isfunction(langData.Phrases)) then
				langData.Phrases = langData.Phrases()
			end
			if (discriminator) then
				phrase_str = langData.Phrases[discriminator] and langData.Phrases[discriminator][str]
			else
				phrase_str = langData.Phrases[str]
			end
			if (phrase_str) then
				return phrase_str
			elseif (selected_language ~= "english") then
				local engData = moduleData["english"]
				if not engData then return str end
				if (isfunction(engData.Phrases)) then
					engData.Phrases = engData.Phrases()
				end
				if (discriminator) then
					if (engData.Phrases[discriminator] ~= nil) then
						return engData.Phrases[discriminator][str] or str
					else
						return str
					end
				else
					return engData.Phrases[str] or str
				end
			else
				return str
			end
		end
	end
	return result
end

-- Fix IsBot missing from player metatable
local meta = FindMetaTable("Player")
if meta then
	meta.IsBot = function(self)
		if not IsValid(self) then return false end
		return self:GetUserGroup() == "bot"
	end
end

-- Fix IsOperator and CanAccessMenu
local function ApplyGASFixes()
	if not OpenPermissions or not GAS then return false end
	OpenPermissions.IsOperator = function(self, ply)
		if not IsValid(ply) or not ply.GetUserGroup then return false end
		for _,u in ipairs(OpenPermissions.Operators.Usergroups or {}) do
			if ply:GetUserGroup() == u then return true end
		end
		return false
	end
	local original = GAS.CanAccessMenu
	if original then
		GAS.CanAccessMenu = function(self_or_module, ply_or_module, ply)
			if IsValid(self_or_module) and self_or_module:IsPlayer() then
				return original(ply_or_module, self_or_module)
			end
			return original(self_or_module, ply_or_module, ply)
		end
	end
	return true
end

if not ApplyGASFixes() then
	hook.Add("Think", "GAS_FixRetry", function()
		if ApplyGASFixes() then
			hook.Remove("Think", "GAS_FixRetry")
		end
	end)
end

-- Fix for cl_menu.lua:196 - register default sizes for all modules
local modules = {
	"adminphysgun", "commands", "fpsbooster", "jobwhitelist",
	"playerdatabase", "secondaryusergroups", "adminsits",
}
for _, m in ipairs(modules) do
	hook.Add("gmodadminsuite:ModuleSize:" .. m, "GAS_ModuleSizeFix_" .. m, function()
		return 800, 600
	end)
end
