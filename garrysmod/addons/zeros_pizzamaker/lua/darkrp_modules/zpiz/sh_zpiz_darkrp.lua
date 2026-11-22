/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

TEAM_ZPIZ_CHEF = DarkRP.createJob("D-Class Pizza Chef", {
    color = Color(255, 93, 0, 255), 
    model = { 
        [1] = "models/player/repti/class_d_6.mdl", 
    },
    description = [[You are baking Pizzas!]],
    weapons = { 
        [1] = "weapon_fists",
        [2] = "weapon_physcannon",
        [3] = "weapon_physgun"
       },
    command = "zpiz_pizzachef01",
    max = 4,
    salary = 15,
    admin = 0,
    vote = false,
    category = "D-Class",
    hasLicense = false
})

DarkRP.createCategory{
    name = "PizzaChef",
    categorises = "entities",
    startExpanded = true,
    color = Color(255, 107, 0, 255),
    canSee = function(ply) return true end,
    sortOrder = 104
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 17dc2f80cf0594471955ed2fce132d0271ce6541c38902a33a4148308c414a4d

DarkRP.createEntity("PizzaOven", {
    ent = "zpiz_oven",
    model = "models/zerochain/props_pizza/zpizmak_oven.mdl",
    price = 250,
    max = 3,
    cmd = "buyzpiz_PizzaOven",
    allowed = TEAM_ZPIZ_CHEF,
    category = "PizzaChef"
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3a7bd44c53efd46df183636fbe76c3de2bd5fbbd78a3773db33588e14b60a4d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3a7bd44c53efd46df183636fbe76c3de2bd5fbbd78a3773db33588e14b60a4d

DarkRP.createEntity("Fridge", {
    ent = "zpiz_fridge",
    model = "models/props_c17/FurnitureFridge001a.mdl",
    price = 100,
    max = 1,
    cmd = "buyzpiz_fridge",
    allowed = TEAM_ZPIZ_CHEF,
    category = "PizzaChef"
})

DarkRP.createEntity("CustomerTable", {
    ent = "zpiz_customertable",
    model = "models/props_c17/FurnitureTable001a.mdl",
    price = 200,
    max = 3,
    cmd = "buyzpiz_customertable",
    allowed = TEAM_ZPIZ_CHEF,
    category = "PizzaChef"
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- fde1005ae952a630057a2cc575fe1335e7c9809985c0483424501baa23d5a1ad
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- fde1005ae952a630057a2cc575fe1335e7c9809985c0483424501baa23d5a1ad

DarkRP.createEntity("OpenSign", {
    ent = "zpiz_opensign",
    model = "models/props_trainstation/TrackSign02.mdl",
    price = 50,
    max = 1,
    cmd = "buyzpiz_opensign",
    allowed = TEAM_ZPIZ_CHEF,
    category = "PizzaChef"
})
