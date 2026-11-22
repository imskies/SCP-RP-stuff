
local materialsDir = "dconfig2/hotmaterials/"
file.CreateDir(materialsDir)
 
DCONFIG2.HotMaterials = {} 

function DCONFIG2.loadMaterial(imageData, callback)
  local imgurEnd = imageData.imgurEnd
  local steamURL = imageData.steamURL
  local imageName = imageData.name and DCONFIG2.FormatDirectory(imageData.name)
  local imageID = imgurEnd or imageName
  local imageType = imageData.imgType or ".jpg"
  local imageURL = (not steamURL and "https://i.imgur.com/" .. imageID or steamURL)
  local isPNG = string.find(imageID, ".png") 
  local isJPG = string.find(imageID, ".jpg") 
  --print(isPNG, isJPG)
  local saveFile = (isPNG or isJPG) and imageID or imageID .. ".jpg"
  --print("Sending request to ", imageURL)
  --print((not isPNG and not isPNG))
  --print("Saving or reading file from ", materialsDir .. saveFile)
	if DCONFIG2.HotMaterials[imageID] or file.Exists(materialsDir .. saveFile, "DATA") then
		local mat = not DCONFIG2.HotMaterials and Material("../data/" .. materialsDir .. saveFile, "smooth") or DCONFIG2.HotMaterials[imageID]
		DCONFIG2.HotMaterials[imageID] = mat
		callback(mat, "../data/" .. materialsDir .. saveFile)
		return
	end
    http.Fetch(imageURL, function(body)
        file.Write(materialsDir .. saveFile, body)
        DCONFIG2.HotMaterials[imageID] = Material("../data/" .. materialsDir .. saveFile, "smooth", "noclamp")
        callback(DCONFIG2.HotMaterials[imageID], "../data/" .. materialsDir .. saveFile)
    end, function(err)
        callback()
    end)
end