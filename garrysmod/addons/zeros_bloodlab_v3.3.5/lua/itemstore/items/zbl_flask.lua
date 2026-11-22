/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

ITEM.Name = "Flask"
ITEM.Description = "A flask used for storing genetic materials."
ITEM.Model = "models/zerochain/props_bloodlab/zbl_flask.mdl"
ITEM.Base = "base_darkrp"
ITEM.Stackable = false
ITEM.DropStack = false

function ITEM:GetName()
	local name = "Undefind"

	local genName = self:GetData("GenName")
	local genValue = self:GetData("GenValue")
	local genType = self:GetData("GenType")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

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
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

	name = name .. " [" .. genName .. "]"

	return self:GetData("Name", name)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

function ITEM:GetDescription()

	local desc = self.Description

	local genType = self:GetData("GenType")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

	if genType then
		desc = "+" .. self:GetData("GenPoints") .. " DNA"
	end

	return self:GetData("Description", desc)
end

function ITEM:CanPickup(pl, ent)
	if ent:GetGenType() > 0 then
		return true
	else
		return false
	end
end

function ITEM:SaveData(ent)
	self:SetData("GenType", ent:GetGenType())
	self:SetData("GenValue", ent:GetGenValue())
	self:SetData("GenName", ent:GetGenName())
	self:SetData("GenPoints", ent:GetGenPoints())
	self:SetData("GenClass", ent:GetGenClass())
end

function ITEM:LoadData(ent)
	ent:SetGenType(self:GetData("GenType"))
	ent:SetGenValue(self:GetData("GenValue"))
	ent:SetGenName(self:GetData("GenName"))
	ent:SetGenPoints(self:GetData("GenPoints"))
	ent:SetGenClass(self:GetData("GenClass"))
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24
