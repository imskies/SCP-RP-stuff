/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

zpiz = zpiz or {}
zpiz.Pizza = zpiz.Pizza or {}

function zpiz.Pizza.GetData(id)
	return zpiz.config.Pizza[id]
end

function zpiz.Pizza.GetName(id)
	local dat = zpiz.Pizza.GetData(id)
	if dat then
		return dat.name
	else
		return "Unkown"
	end
end

function zpiz.Pizza.GetDesc(id)
	local dat = zpiz.Pizza.GetData(id)
	if dat then
		return dat.desc
	else
		return "Unkown"
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3a7bd44c53efd46df183636fbe76c3de2bd5fbbd78a3773db33588e14b60a4d

function zpiz.Pizza.GetBakeTime(id)
	local dat = zpiz.Pizza.GetData(id)
	if dat then
		return dat.time
	else
		return 10
	end
end

function zpiz.Pizza.GetHealth(id)
	local dat = zpiz.Pizza.GetData(id)
	if dat then
		return dat.health
	else
		return 0
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

function zpiz.Pizza.GetHealthCap(id)
	local dat = zpiz.Pizza.GetData(id)
	if dat then
		return dat.health_cap
	else
		return 0
	end
end

function zpiz.Pizza.GetRecipe(id)
	local dat = zpiz.Pizza.GetData(id)
	if dat then
		return dat.recipe
	else
		return {}
	end
end

// Returns a random pizza according to the provided chance var
function zpiz.Pizza.GetRandom()
	local PizzaPool = {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3a7bd44c53efd46df183636fbe76c3de2bd5fbbd78a3773db33588e14b60a4d

	for k, v in pairs(zpiz.config.Pizza) do
		for i = 1, v.chance do
			table.insert(PizzaPool, k)
		end
	end

	local pizza = PizzaPool[math.random(#PizzaPool)]
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- fde1005ae952a630057a2cc575fe1335e7c9809985c0483424501baa23d5a1ad

	return pizza
end

// Returns the price of the pizza + ingredient cost
function zpiz.Pizza.GetPrice(pizzaID)
	local pizzaData = zpiz.config.Pizza[pizzaID]
	if pizzaData == nil then return 0 end

	local pizzaprice = zpiz.Ingredient.GetPrice(ZPIZ_ING_DOUGH) + pizzaData.price
	for ing_id, ing_amount in pairs(zpiz.Pizza.GetRecipe(pizzaID)) do
		if (ing_amount > 0) then
			pizzaprice = pizzaprice + (zpiz.Ingredient.GetPrice(ing_id) * ing_amount)
		end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 17dc2f80cf0594471955ed2fce132d0271ce6541c38902a33a4148308c414a4d

	return pizzaprice
end

function zpiz.Pizza.GetIcon(id)
	local dat = zpiz.Pizza.GetData(id)
	if dat then
		return dat.icon
	else
		return zpiz.materials["zpiz_circle"]
	end
end
