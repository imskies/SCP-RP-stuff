/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

zpiz = zpiz or {}
zpiz.Ingredient = zpiz.Ingredient or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- fde1005ae952a630057a2cc575fe1335e7c9809985c0483424501baa23d5a1ad

function zpiz.Ingredient.GetData(id)
	return zpiz.config.Ingredients[id]
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 17dc2f80cf0594471955ed2fce132d0271ce6541c38902a33a4148308c414a4d

function zpiz.Ingredient.GetName(id)
	local dat = zpiz.Ingredient.GetData(id)
	if dat then
		return dat.name
	else
		return "Unkown"
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 02d4e064402d16696deab5b093c9a34ae7a407e6165a08b9f87e1e597f153041
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- fde1005ae952a630057a2cc575fe1335e7c9809985c0483424501baa23d5a1ad

function zpiz.Ingredient.GetModel(id)
	local dat = zpiz.Ingredient.GetData(id)
	if dat then
		return dat.model
	else
		return "Unkown"
	end
end

function zpiz.Ingredient.GetIcon(id)
	local dat = zpiz.Ingredient.GetData(id)
	if dat then
		return dat.icon
	else
		return zpiz.materials["zpiz_circle"]
	end
end

function zpiz.Ingredient.GetColor(id)
	local dat = zpiz.Ingredient.GetData(id)
	if dat then
		return dat.color
	else
		return color_white
	end
end

function zpiz.Ingredient.GetPrice(id)
	local dat = zpiz.Ingredient.GetData(id)
	if dat then
		return dat.price
	else
		return 0
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 02d4e064402d16696deab5b093c9a34ae7a407e6165a08b9f87e1e597f153041

function zpiz.Ingredient.GetLimit(id)
	local dat = zpiz.Ingredient.GetData(id)
	if dat && isnumber(dat.limit) then
		return dat.limit
	else
		return 5
	end
end
