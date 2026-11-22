/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

if CLIENT then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 17dc2f80cf0594471955ed2fce132d0271ce6541c38902a33a4148308c414a4d

resource.AddWorkshop( "2532060111" ) // Zeros Lua Libary Contentpack
//https://steamcommunity.com/sharedfiles/filedetails/?id=2532060111

if zpiz.config.FastDL then
	zpiz = zpiz or {}
	zpiz.force = zpiz.force or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 02d4e064402d16696deab5b093c9a34ae7a407e6165a08b9f87e1e597f153041

	function zpiz.force.AddDir(path)
		local files, folders = file.Find(path .. "/*", "GAME")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

		for k, v in pairs(files) do
			resource.AddFile(path .. "/" .. v)
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

		for k, v in pairs(folders) do
			zpiz.force.AddDir(path .. "/" .. v)
		end
	end

	zpiz.force.AddDir("particles")
	zpiz.force.AddDir("resource/fonts")
	zpiz.force.AddDir("sound/zpiz")
	zpiz.force.AddDir("models/zerochain/props_pizza")
	zpiz.force.AddDir("materials/zerochain/zpiz/particle")
	zpiz.force.AddDir("materials/zerochain/zpiz/ui")
	zpiz.force.AddDir("materials/zerochain/zpiz/ui/icons")
	zpiz.force.AddDir("materials/zerochain/zpiz/ui/pizzas")
	zpiz.force.AddDir("materials/zerochain/props_pizza")
	zpiz.force.AddDir("materials/zerochain/props_pizza/ingredients")
else
	resource.AddWorkshop("1332778012") -- Zeros PizzaMaker Contentpack
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350945
