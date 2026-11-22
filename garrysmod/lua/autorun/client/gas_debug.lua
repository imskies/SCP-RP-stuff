local _,d = file.Find("gmodadminsuite/modules/*", "LUA")
for _,m in ipairs(d) do
	if not file.Exists("gmodadminsuite/modules/"..m.."/_gas_info.lua", "LUA") then
		print(m, "NO _gas_info.lua")
		continue
	end
	local ok, err = pcall(function()
		local info = include("gmodadminsuite/modules/"..m.."/_gas_info.lua")
		print(m, info and info.Category or "NO INFO RETURNED")
	end)
	if not ok then
		print("ERROR in "..m..": "..tostring(err))
	end
end
