util.AddNetworkString("OpenDisguiseSettings")
util.AddNetworkString("SaveDisguiseSettings")

DarkRP.defineChatCommand("disguise_settings", function(ply)
	if ply:IsSuperAdmin() == false then return end
	
	local disguises = util.JSONToTable(file.Read("disguise_teams.txt"))
	
	net.Start("OpenDisguiseSettings")
		net.WriteTable(disguises)
	net.Send(ply)
end)

net.Receive("SaveDisguiseSettings", function(len, ply)
	if not ply:IsSuperAdmin() then
		return
	end
	local disguises = net.ReadTable()
	
	file.Write("disguise_teams.txt", util.TableToJSON(disguises))
end)