/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

zpiz = zpiz or {}
zpiz.config = zpiz.config or {}

zpiz.config.Ingredient = {
    // How many ingredients can each player spawn
    Limit = 50,

    // How long until the ingredient despawn, -1 disables this function
    Despawn = 60
}

// This Sets up our Fridge Shop and also the available Ingredients for Pizza
zpiz.config.Ingredients = {}
local function AddIngredient(data) return table.insert(zpiz.config.Ingredients,data) end

ZPIZ_ING_DOUGH = AddIngredient({
    name = "Dough",
    model = "models/zerochain/props_pizza/zpiz_pizzadough.mdl",
    icon = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_dough.png", "smooth"),
    desc = "The Dough",
    limit = 7,
    price = 15
})

ZPIZ_ING_TOMATO = AddIngredient({
    name = "Tomato Sauce",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_tomato.mdl",
    icon = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_tomato.png", "smooth"),
    desc = "The Base Sauce",
    price = 10,
    limit = 5,
    color = Color(200, 0, 0)
})

ZPIZ_ING_CHEESE = AddIngredient({
    name = "Cheese",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_cheese.mdl",
    icon = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_cheese.png", "smooth"),
    desc = "Some smelly Cheese",
    price = 15,
    limit = 5,
    color = Color(252, 223, 118)
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 02d4e064402d16696deab5b093c9a34ae7a407e6165a08b9f87e1e597f153041
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ee71cdadb4c1697a1f320cfc75c78c5f0135879a492afb53058e82fcefbc72f0

ZPIZ_ING_SPINAT = AddIngredient({
    name = "Spinat",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_spinat.mdl",
    icon = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_spinat.png", "smooth"),
    desc = "Could be spinach, idk",
    price = 15,
    limit = 5,
    color = Color(139, 164, 60)
})

ZPIZ_ING_SALAMI = AddIngredient({
    name = "Salami",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_salami.mdl",
    icon = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_salami.png", "smooth"),
    desc = "Lets say its Salami, mkay",
    price = 75,
    limit = 5,
    color = Color(131, 23, 29)
})

ZPIZ_ING_OLIVES = AddIngredient({
    name = "Olives",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_olives.mdl",
    icon = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_olive.png", "smooth"),
    desc = "Some fresh Olives!",
    price = 10,
    limit = 5,
    color = Color(156, 155, 34)
})

ZPIZ_ING_EGGPLANT = AddIngredient({
    name = "Eggplant",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_eggplant.mdl",
    icon = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_eggplant.png", "smooth"),
    desc = "Dont really looks like an Egg",
    price = 80,
    limit = 5,
    color = Color(90, 14, 94)
})

ZPIZ_ING_CHILLI = AddIngredient({
    name = "Chilli",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_chilli.mdl",
    icon = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_chilli.png", "smooth"),
    desc = "So Hot!",
    price = 75,
    limit = 5,
    color = Color(255, 57, 57)
})

ZPIZ_ING_PICKLE = AddIngredient({
    name = "Pickle",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_pickle.mdl",
    icon = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_pickle.png", "smooth"),
    desc = "Its a Pickle!",
    price = 25,
    limit = 5,
    color = Color(25, 31, 19)
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ee71cdadb4c1697a1f320cfc75c78c5f0135879a492afb53058e82fcefbc72f0
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

ZPIZ_ING_MUSHROOM = AddIngredient({
    name = "Mushroom",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_mushroom.mdl",
    icon = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_mushroom.png", "smooth"),
    desc = "Dat Fungus",
    price = 15,
    limit = 5,
    color = Color(249, 220, 178)
})

ZPIZ_ING_PINEAPPLE = AddIngredient({
    name = "Pineapple",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_pineapple.mdl",
    icon = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_pineapple.png", "smooth"),
    desc = "Gay",
    price = 80,
    limit = 5,
    color = Color(238, 175, 74)
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

ZPIZ_ING_EGG = AddIngredient({
    name = "Egg",
    model = "models/props_phx/misc/egg.mdl",
    icon = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_egg.png", "smooth"),
    desc = "A Egg",
    price = 50,
    limit = 5,
    color = Color(229, 229, 229)
})

ZPIZ_ING_BACON = AddIngredient({
    name = "Bacon",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_bacon.mdl",
    icon = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_bacon.png", "smooth"),
    desc = "Bacon! Bacon! Bacon!",
    price = 75,
    limit = 5,
    color = Color(118, 29, 33)
})
