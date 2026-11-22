/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if CLIENT then return end
zbl = zbl or {}
zbl.force = zbl.force or {}

resource.AddWorkshop( "2532060111" ) // Zeros Lua Libary Contentpack
//https://steamcommunity.com/sharedfiles/filedetails/?id=2532060111

if zbl.config.FastDl then

	function zbl.force.AddDir(path)

		local files, folders = file.Find(path .. "/*", "GAME")

		for k, v in pairs(files) do
			resource.AddFile(path .. "/" .. v)
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

		for k, v in pairs(folders) do

			zbl.force.AddDir(path .. "/" .. v)
		end
	end

	zbl.force.AddDir("sound/zbl/")
	zbl.force.AddDir("models/zerochain/props_bloodlab/")
	zbl.force.AddDir("materials/zerochain/props_bloodlab/")
	zbl.force.AddDir("materials/zerochain/zblood/")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

	resource.AddSingleFile("resource/fonts/OpenSans-Bold.ttf")
	resource.AddSingleFile("resource/fonts/OpenSans-Regular.ttf")

	resource.AddSingleFile("materials/entities/zbl_gasmask.png")
	resource.AddSingleFile("materials/entities/zbl_lab.png")
	resource.AddSingleFile("materials/entities/zbl_npc.png")
	resource.AddSingleFile("materials/entities/zbl_fence.png")
	resource.AddSingleFile("materials/entities/zbl_sign.png")
	resource.AddSingleFile("materials/entities/zbl_dna.png")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337


	resource.AddSingleFile("particles/zbl_effects.pcf")

	resource.AddSingleFile("materials/vgui/entities/zbl_gun.vmt")
	resource.AddSingleFile("materials/vgui/entities/zbl_gun.vtf")
	resource.AddSingleFile("materials/vgui/entities/zbl_spray.vmt")
	resource.AddSingleFile("materials/vgui/entities/zbl_spray.vtf")

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

	resource.AddSingleFile("materials/zerochain/zblood/vgui/zbl_gun.vmt")
	resource.AddSingleFile("materials/zerochain/zblood/vgui/zbl_gun.vtf")
	resource.AddSingleFile("materials/zerochain/zblood/vgui/zbl_spray.vmt")
	resource.AddSingleFile("materials/zerochain/zblood/vgui/zbl_spray.vtf")
else
	resource.AddWorkshop( "2034684543" ) // Zeros GenLab
	//https://steamcommunity.com/sharedfiles/filedetails/?id=2034684543
end
