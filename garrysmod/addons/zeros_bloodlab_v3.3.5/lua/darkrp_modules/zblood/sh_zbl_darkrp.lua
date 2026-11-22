/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

TEAM_Bio_Researcher = DarkRP.createJob("Bio Researcher", {
    color = Color(255, 255, 255, 255),
    model = {"models/cultist/scp_rp/scientists_1.mdl"},
    description = [[You research viruses, ability boosts and cures.]],
    category = "Research",
    weapons = {"weapon_fists", "weapon_rdo_radio", "zbl_gun", "zbl_spray", "bkeycard"},
    command = "biores",
    max = 6,
    salary = 300,
    admin = 0,
    vote = false,
    hasLicense = false,
	PlayerSpawn = function(ply)
		ply:SetMaxHealth(100)
		ply:SetHealth(100)
		ply:SetMaxArmor(100)
		ply:SetArmor(5)
	end
})

DarkRP.createCategory{
    name = "Virus Researcher",
    categorises = "entities",
    startExpanded = true,
    color = Color(65, 65,65, 255),
    canSee = function(ply) return true end,
    sortOrder = 104
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

DarkRP.createEntity("Lab", {
    ent = "zbl_lab",
    model = "models/zerochain/props_bloodlab/zbl_lab.mdl",
    price = 5000,
    max = 1,
    cmd = "buyzbl_lab",
    allowed = {TEAM_Medical_Researcher},
    category = "Virus Researcher",
})

DarkRP.createEntity("Electric Fence", {
    ent = "zbl_fence",
    model = "models/zerochain/props_bloodlab/zbl_gate.mdl",
    price = 10000,
    max = 2,
    cmd = "buyzbl_fence",
    allowed = {TEAM_Medical_Researcher},
    category = "Virus Researcher",
})

DarkRP.createEntity("Respirator", {
    ent = "zbl_gasmask",
    model = "models/zerochain/props_bloodlab/zbl_maskbox.mdl",
    price = 5000,
    max = 1,
    cmd = "buyzbl_gasmask",
})

DarkRP.createShipment("Disinfectant Spray", {
    model = "models/zerochain/props_bloodlab/zbl_w_spray.mdl",
    entity = "zbl_spray",
    price = 5000,
    amount = 3,
    separate = false
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

/*
local function Spawn_Flask(ply,tr,_type,_value)
    local flask = ents.Create("zbl_flask")
    flask:SetPos(tr.HitPos)
    flask:Spawn()
    flask:Activate()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

    flask:SetGenType(_type)
    flask:SetGenValue(_value)
    flask:SetGenName(zbl.config.Vaccines[_value].name)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

    zclib.Player.SetOwner(flask, ply)

    return flask
end

timer.Simple(1,function()
    for k, v in pairs(zbl.config.Vaccines) do
        DarkRP.createEntity(v.name .. "[Cure]", {
            ent = "zbl_flask",
            model = "models/zerochain/props_bloodlab/zbl_flask.mdl",
            price = v.price * 10,
            max = 5,
            cmd = "buy" .. v.name .. "cure",
            //allowed = {TEAM_ZBL_RESEARCHER},
            //category = "Virus Researcher",
            spawn = function(ply, tr, tblEnt) return Spawn_Flask(ply, tr, 3, k) end
        })
    end
end)
*/
