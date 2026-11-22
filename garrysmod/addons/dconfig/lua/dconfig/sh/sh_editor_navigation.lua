
DCONFIG2.Editor.Navigation = DCONFIG2.Editor.Navigation or {}

function DCONFIG2.Editor.Navigation.Add(type, data)
	DCONFIG2.Editor.Navigation[type] = data
end

local function PrepareNavigation()

	DCONFIG2.Editor.Navigation.Add("shipments", {
		contents = function()
			local shipments = {}
			local shouldLoadEntry = DCONFIG2.Data.FileManager.shipments.shouldLoadEntry
			for k,v in pairs(CustomShipments) do
				if shouldLoadEntry and not shouldLoadEntry(v) then continue end

				if not DCONFIG2.IngameConfig.load_hardcoded and v.inLuaFile then continue end
				
				table.insert(shipments, v)
			end
			return shipments
		end,
		getTitle = function(data)
			return data.name
		end,
		getSubTitle = function(data)
			local title = "(x" .. data.amount .. ") " .. DarkRP.formatMoney(data.price) .. " - (x1) " .. DarkRP.formatMoney(data.pricesep)
			if data.noship then
				title = DarkRP.formatMoney(data.price)
			end
			return title
		end,
	})

	
	DCONFIG2.Editor.Navigation.Add("jobs", {
		contents = function()
			local jobs = {}
			local shouldLoadEntry = DCONFIG2.Data.FileManager.jobs.shouldLoadEntry
			for k,v in pairs(RPExtraTeams) do
				if shouldLoadEntry and not shouldLoadEntry(v) then continue end

				if not DCONFIG2.IngameConfig.load_hardcoded and v.inLuaFile or not v.jobvar then continue end

				table.insert(jobs, v)
			end
			return jobs
		end,
		getTitle = function(data)
			return data.name
		end,
		getSubTitle = function(data)
			return data.category  .. " - " .. DarkRP.formatMoney(data.salary)
		end,
	})

	DCONFIG2.Editor.Navigation.Add("entities", {
		contents = function() 
			local entities = {}
			local shouldLoadEntry = DCONFIG2.Data.FileManager.entities.shouldLoadEntry	
			for k,v in pairs(DarkRPEntities) do
				if shouldLoadEntry and not shouldLoadEntry(v) then continue end

				if not DCONFIG2.IngameConfig.load_hardcoded and v.inLuaFile then continue end

				table.insert(entities, v)
			end
			return entities
		end,
		getTitle = function(data)
			return data.name
		end,
		getSubTitle = function(data)
			return DarkRP.formatMoney(data.price) .. " - " .. data.category
		end,
	})

	local ammoTypes = (GM or GAMEMODE).AmmoTypes
	DCONFIG2.Editor.Navigation.Add("ammo", {
		contents = function() 
			local ammo = {}
			// Using pairs as the data being loaded in is not always going to be sequential. Sorry :-(
			local shouldLoadEntry = DCONFIG2.Data.FileManager.ammo.shouldLoadEntry	
			for k,v in pairs(ammoTypes) do
				if shouldLoadEntry and not shouldLoadEntry(v) then continue end

				if not DCONFIG2.IngameConfig.load_hardcoded and v.inLuaFile then continue end

				table.insert(ammo, v)
			end
			return ammo
		end,
		getTitle = function(data)
			return data.name
		end,
		getSubTitle = function(data)
			return DarkRP.formatMoney(data.price) .. " - " .. data.category
		end,
	})

	DCONFIG2.Editor.Navigation.Add("doorgroups", {
		contents = function() 			
			local doors = {}
			local shouldLoadEntry = DCONFIG2.Data.FileManager.doorgroups.shouldLoadEntry	
			for k,v in pairs(RPExtraTeamDoors) do
				if shouldLoadEntry and not shouldLoadEntry(v) then continue end

				if not DCONFIG2.IngameConfig.load_hardcoded and v.inLuaFile then continue end

				table.insert(doors, v)
			end
			return doors
		end,
		getTitle = function(data)
			return data.name
		end,
		getSubTitle = function(data)
            local count = 0
            for k,v in pairs(data) do
                if type(v) == "number" then
                    count = count + 1
                end
            end     
			return count ..  " Job" .. (count > 1 and "s." or ".")
		end,
		getModel = function(data)
			return "models/props_c17/door01_left.mdl"
		end,
	})

	local imageLookup = {
		shipments = "dconfig/shipment.png",
		jobs = "dconfig/job.png",
		entities = "dconfig/entity.png",
		ammo = "dconfig/ammo.png",
	}

	DCONFIG2.Editor.Navigation.Add("categories", {
		contents = function()
			local categoryData = {}

			local loopTables = {
				DarkRP.getCategories()["jobs"],
				DarkRP.getCategories()["shipments"],
				DarkRP.getCategories()["ammo"],
				DarkRP.getCategories()["entities"],
			}
			local shouldLoadEntry = DCONFIG2.Data.FileManager.categories.shouldLoadEntry
			for _,catTbl in ipairs(loopTables) do
				for k,v in pairs(catTbl) do
					if shouldLoadEntry and not shouldLoadEntry(v) then continue end

					if not DCONFIG2.IngameConfig.load_hardcoded and v.inLuaFile then continue end

					categoryData[#categoryData + 1 or 1] = v
				end
			end

			table.sort(categoryData, function(a,b)
				return a.categorises < b.categorises
			end)
			return categoryData
		end,
		getTitle = function(data)
			return data.name
		end,
		getSubTitle = function(data)
			return data.categorises
		end,
		getImage = function(data)
			return { material = (Material(imageLookup[data.categorises]) or Material("dconfig/category.png")) }
		end,
	})

end 

hook.Add("DConfigDataLoaded", "PrepareNavigation", function()

	PrepareNavigation()

end)

hook.Add("DConfigVaultLoaded", "SetupVaultEditorNav", function()
	DCONFIG2.Editor.Navigation.Add("vault", {
		contents = function() 
			local contentPacks = {}
			for k,catObj in pairs(DCONFIG2.Vault) do
				for k,contentPack in pairs(catObj) do
					table.insert(contentPacks, contentPack)
				end
			end
			return contentPacks
		end,
		getTitle = function(data)
			return data.name
		end,
		getSubTitle = function(data)
			return data.category
		end,
		getRemoteImage = function(data)
			return {imgurEnd = data.img, steamURL = data.steamImg, name = data.name}
		end,
	}) 
end)

