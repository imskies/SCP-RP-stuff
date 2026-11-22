/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

local ITEM = XeninInventory:CreateItemV2()
ITEM:SetMaxStack(1)
ITEM:SetModel("models/zerochain/props_bloodlab/zbl_flask.mdl")
ITEM:SetDescription("A flask used for storing genetic material.")

ITEM:AddDrop(function(self, ply, ent, tbl, tr)
	local data = tbl.data

	ent:SetGenType(data.GenType)
	ent:SetGenValue(data.GenValue)
	ent:SetGenName(data.GenName)
	ent:SetGenPoints(data.GenPoints)
	ent:SetGenClass(data.GenClass)


	zclib.Player.SetOwner(ent, ply)
	ent.FlaskOwner = ply
end)

function ITEM:GetData(ent)
	return {
		GenType = ent:GetGenType(),
		GenValue = ent:GetGenValue(),
		GenName = ent:GetGenName(),
		GenPoints = ent:GetGenPoints(),
		GenClass = ent:GetGenClass(),
	}
end

function ITEM:GetDisplayName(item)
	return self:GetName(item) .. " flask"
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

function ITEM:GetName(item)
	local name = "Undefind"

	local ent = isentity(item)
	local genName = ent and item:GetGenName() or item.data.GenName
	local genValue = ent and item:GetGenValue() or item.data.GenValue
	local genType = ent and item:GetGenType() or item.data.GenType

	if genType == 1 then
		name = "Sample"
	elseif genType == 2 then
		if zbl.Vaccine.IsVirus(genValue) then
			name = "Virus"
		else
			name = "Abillity"
		end
	elseif genType == 3 then
		name = "Cure"
	end

	name = name .. " [" .. genName .. "]"

	return name
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

function ITEM:GetCameraModifiers(tbl)
	return {
		FOV = 40,
		X = 0,
		Y = -22,
		Z = 25,
		Angles = Angle(0, -190, 0),
		Pos = Vector(0, 0, -1)
	}
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

function ITEM:GetClientsideModel(tbl, mdlPanel)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

	local genValue = tbl.data.GenValue
	local genType = tbl.data.GenType
	local genclass = tbl.data.GenClass
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

	if genType ~= 0 then
		mdlPanel.Entity:SetBodygroup(0, 1)
	end

	if genType == 1 then
		// Check if sample is from player and color the liquid red
		if genclass and genclass == "player" then
			mdlPanel.Entity:SetSubMaterial(0, "zerochain/props_bloodlab/flask/zbl_flask_liquid_bloodsample")
		end
	elseif genType == 2 then
		if zbl.Vaccine.IsVirus(genValue) then
			mdlPanel.Entity:SetSubMaterial(0, zbl.Vaccine.GetMaterial(genValue))
		else
			mdlPanel.Entity:SetSubMaterial(0, "zerochain/props_bloodlab/flask/zbl_flask_liquid_abillity_diff")
		end
	elseif genType == 3 then
		mdlPanel.Entity:SetSubMaterial(0, "zerochain/props_bloodlab/flask/zbl_flask_liquid_cure_diff")
	end
end

ITEM:Register("zbl_flask")
