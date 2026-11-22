if SERVER then 
	hook.Add("postLoadCustomDarkRPItems", "DConfig2LoadDataServer", function()
		DCONFIG2.LoadData("dconfig")
		DCONFIG2.MsgC("Formatting hardcoded jobs.")
		DCONFIG2.FormatHardcodedJobs("darkrp_customthings/jobs.lua")
		DCONFIG2.FormatHardcodedJobs(engine.ActiveGamemode() .. "/gamemode/config/jobrelated.lua")
		hook.Run("DConfigPreDataLoaded")
        DCONFIG2.LoadDarkRPData()
        DCONFIG2.LoadStats()
		hook.Run("DConfigDataLoaded")
	end)
end

if CLIENT then 
	hook.Add("postLoadCustomDarkRPItems", "DConfig2LoadDataClient", function()
		hook.Run("DConfigPreDataLoaded")
		hook.Run("DConfigDataLoaded")
		
	end)
end