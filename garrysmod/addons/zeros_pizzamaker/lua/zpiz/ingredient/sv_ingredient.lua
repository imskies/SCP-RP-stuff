/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

if not SERVER then return end
zpiz = zpiz or {}
zpiz.Ingredient = zpiz.Ingredient or {}
zpiz.Ingredient.List = zpiz.Ingredient.List or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3a7bd44c53efd46df183636fbe76c3de2bd5fbbd78a3773db33588e14b60a4d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3a7bd44c53efd46df183636fbe76c3de2bd5fbbd78a3773db33588e14b60a4d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350945
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350945

function zpiz.Ingredient.Add(Ingredient)
	Ingredient.SpawnTime = CurTime() + zpiz.config.Ingredient.Despawn
	table.insert(zpiz.Ingredient.List, Ingredient)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 17dc2f80cf0594471955ed2fce132d0271ce6541c38902a33a4148308c414a4d

if zpiz.config.Ingredient.Despawn > 0 then
	zclib.Timer.Create("zpiz_ingredientcleanup_timer", zpiz.config.Ingredient.Despawn, 0, function()
		for k, v in pairs(zpiz.Ingredient.List) do
			if IsValid(v) and v.SpawnTime < CurTime() then
				SafeRemoveEntity(v)
			end
		end
	end)
end
