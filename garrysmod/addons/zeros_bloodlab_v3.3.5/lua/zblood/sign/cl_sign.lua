/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if SERVER then return end
zbl = zbl or {}
zbl.VirusStatistics = zbl.VirusStatistics or {}

net.Receive("zbl_VirusStatistic_Update", function(len)
	zclib.Debug("zbl_VirusStatistic_Update Len: " .. len)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

	local dataLength = net.ReadUInt(16)
	local d_Decompressed = util.Decompress(net.ReadData(dataLength))
	local stats = util.JSONToTable(d_Decompressed)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

	if stats then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

		// Sort the table by infected objects
		zbl.VirusStatistics = {}
		for k,v in pairs(stats) do
			local count = 0

			if v[1] then
				count = count + v[1]
			end
			if v[2] then
				count = count + v[2]
			end
			if v[3] then
				count = count + v[3]
			end
			if v[4] then
				count = count + v[4]
			end

			table.insert(zbl.VirusStatistics, {
				types = {
					[1] = v[1] or 0,
					[2] = v[2] or 0,
					[3] = v[3] or 0,
					[4] = v[4] or 0
				},
				count = count,
				vac_id = k
			})
		end

		table.sort(zbl.VirusStatistics,function(a,b)
			return a.count > b.count
		end)
	end
end)
