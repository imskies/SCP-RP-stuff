local JobModule = GAS.Logging:MODULE()
JobModule.Category = "DConfig 2"
JobModule.Name = "Jobs"
JobModule.Colour = Color(38, 125, 194)

JobModule:Setup(function()
	JobModule:Hook("DConfig2EditSuccess", "jobSave", function(ply, editorType, saveData)
        if editorType != "jobs" then return end
        local teamIndex = saveData.teamkey or saveData.team or _G[saveData.jobvar]
        JobModule:Log("{1} updated job {2}", GAS.Logging:FormatPlayer(ply), GAS.Logging:FormatTeam(teamIndex))
	end)
end)

GAS.Logging:AddModule(JobModule)

local ShipmentModule = GAS.Logging:MODULE()
ShipmentModule.Category = "DConfig 2"
ShipmentModule.Name = "Shipments"
ShipmentModule.Colour = Color(38, 125, 194)

ShipmentModule:Setup(function()
	ShipmentModule:Hook("DConfig2EditSuccess", "shipmentSave", function(ply, editorType, saveData)
        if editorType != "shipments" then return end
        local shipmentName = saveData.name
        ShipmentModule:Log("{1} updated shipment {2}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(shipmentName))
	end)
end)

GAS.Logging:AddModule(ShipmentModule)

local EntityModule = GAS.Logging:MODULE()
EntityModule.Category = "DConfig 2"
EntityModule.Name = "Entities"
EntityModule.Colour = Color(38, 125, 194)

EntityModule:Setup(function()
	EntityModule:Hook("DConfig2EditSuccess", "entitySave", function(ply, editorType, saveData)
        if editorType != "entities" then return end
        local name = saveData.name
        EntityModule:Log("{1} updated entity {2}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(name))
	end)
end)

GAS.Logging:AddModule(EntityModule)

local AmmoModule = GAS.Logging:MODULE()
AmmoModule.Category = "DConfig 2"
AmmoModule.Name = "Ammo"
AmmoModule.Colour = Color(38, 125, 194)

AmmoModule:Setup(function()
	AmmoModule:Hook("DConfig2EditSuccess", "ammoSave", function(ply, editorType, saveData)
        if editorType != "ammo" then return end
        local name = saveData.name
        AmmoModule:Log("{1} updated ammo {2}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(name))
	end)
end)

GAS.Logging:AddModule(AmmoModule)

local CategoryModule = GAS.Logging:MODULE()
CategoryModule.Category = "DConfig 2"
CategoryModule.Name = "Categories"
CategoryModule.Colour = Color(38, 125, 194)

CategoryModule:Setup(function()
	CategoryModule:Hook("DConfig2EditSuccess", "categorySave", function(ply, editorType, saveData)
        if editorType != "categories" then return end
        local name = saveData.name
        CategoryModule:Log("{1} updated category {2}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(name))
	end)
end)

GAS.Logging:AddModule(CategoryModule)

local DoorgroupModule = GAS.Logging:MODULE()
DoorgroupModule.Category = "DConfig 2"
DoorgroupModule.Name = "Door Groups"
DoorgroupModule.Colour = Color(38, 125, 194)

DoorgroupModule:Setup(function()
	DoorgroupModule:Hook("DConfig2EditSuccess", "categorySave", function(ply, editorType, saveData)
        if editorType != "doorgroups" then return end
        local name = saveData.name
        DoorgroupModule:Log("{1} updated doorgroup {2}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(name))
	end)
end)

GAS.Logging:AddModule(DoorgroupModule)

local BackupModule = GAS.Logging:MODULE()
BackupModule.Category = "DConfig 2"
BackupModule.Name = "Data Backups"
BackupModule.Colour = Color(38, 125, 194)

BackupModule:Setup(function()
	BackupModule:Hook("DConfig2BackupCreated", "backupCreate", function(ply, directory)
        BackupModule:Log("{1} created a new backup {2}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(directory))
	end)
	BackupModule:Hook("DConfig2BackupDeleted", "backupDelete", function(ply, directory)
        BackupModule:Log("{1} deleted the backup {2}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(directory))
	end)
	BackupModule:Hook("DConfig2BackupRestored", "backupDelete", function(ply, directory)
        BackupModule:Log("{1} restored the backup {2}", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(directory))
	end)
end)

GAS.Logging:AddModule(BackupModule)