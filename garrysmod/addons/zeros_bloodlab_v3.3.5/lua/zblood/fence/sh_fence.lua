/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

zbl = zbl or {}
zbl.Fence = zbl.Fence or {}

local CachedColors = {}
function zbl.Fence.GetHealthColor(Fence)
	if zbl.config.Fence.health < 0 then return color_white end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

	local health = Fence:Health()
	if CachedColors[health] then return CachedColors[health] end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

	CachedColors[health] = zclib.util.LerpColor((1 / zbl.config.Fence.health) * health, color_black, color_white)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

	return CachedColors[health]
end
