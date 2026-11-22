/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

zpiz = zpiz or {}
zpiz.config = zpiz.config or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3a7bd44c53efd46df183636fbe76c3de2bd5fbbd78a3773db33588e14b60a4d

zpiz.config.Pizza = {}
local function AddPizza(data) return table.insert(zpiz.config.Pizza,data) end

AddPizza({
    // The name of the Pizza
    name = "Magarita",

    // The Ingredients needed.
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 1
    },

     // The Time in seconds the Pizza needs do be Baked
    time = 10,

    // The desciption of the Pizza
    desc = "A basic Pizza!",

    // The price of the Pizza (The ingredient cost gets later added to this value)
    price = 150,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 17dc2f80cf0594471955ed2fce132d0271ce6541c38902a33a4148308c414a4d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ee71cdadb4c1697a1f320cfc75c78c5f0135879a492afb53058e82fcefbc72f0

    // How should the Pizza look when its done
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_magarita.png", "smooth"),
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- fde1005ae952a630057a2cc575fe1335e7c9809985c0483424501baa23d5a1ad

    // How high is the Chance that this Pizza gets choosen by a Customer (1-100)
    chance = 50,

    // How much Health gets the Player if he eats the Pizza
    health = 5,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350945

    // Here you can define the custom health_cap
    health_cap = 100
})

AddPizza({
    name = "Spinat Pizza",
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 1,
        [ZPIZ_ING_SPINAT] = 2,
    },
    time = 15,
    desc = "A really Green Pizza!",
    price = 200,
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_spinat.png", "smooth"),
    chance = 25,
    health = 15,
    health_cap = 100
})

AddPizza({
    name = "Salami Pizza",
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 1,
        [ZPIZ_ING_SALAMI] = 2,
    },
    time = 15,
    desc = "A Donkey Pizza!",
    price = 250,
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_salami.png", "smooth"),
    chance = 10,
    health = 15,
    health_cap = 100
})

AddPizza({
    name = "Olive Pizza",
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 1,
        [ZPIZ_ING_OLIVES] = 3,
    },
    time = 20,
    desc = "A Italiano Pizza!",
    price = 250,
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_olivia.png", "smooth"),
    chance = 10,
    health = 15,
    health_cap = 100
})

AddPizza({
    name = "Grande Pizza",
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 1,
        [ZPIZ_ING_SALAMI] = 1,
        [ZPIZ_ING_OLIVES] = 1,
        [ZPIZ_ING_EGGPLANT] = 1,
        [ZPIZ_ING_SPINAT] = 1,
        [ZPIZ_ING_PICKLE] = 1,
    },
    time = 120,
    desc = "A Big Pizza!",
    price = 1000,
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_grande.png", "smooth"),
    chance = 5,
    health = 60,
    health_cap = 200
})

AddPizza({
    name = "Bacon Pizza",
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 1,
        [ZPIZ_ING_BACON] = 2,
    },
    time = 25,
    desc = "Bacon!",
    price = 250,
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_bacon.png", "smooth"),
    chance = 10,
    health = 15,
    health_cap = 100
})

AddPizza({
    name = "Egg Pizza",
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 1,
        [ZPIZ_ING_EGG] = 1,
        [ZPIZ_ING_CHILLI] = 1,
        [ZPIZ_ING_BACON] = 1,
    },
    time = 25,
    desc = "Eggs and more Eggs.",
    price = 250,
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_egg.png", "smooth"),
    chance = 10,
    health = 15,
    health_cap = 100
})

AddPizza({
    name = "Mushroom Pizza",
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 1,
        [ZPIZ_ING_SPINAT] = 1,
        [ZPIZ_ING_CHILLI] = 1,
        [ZPIZ_ING_MUSHROOM] = 1,
    },
    time = 25,
    desc = "Dont gets you High.",
    price = 250,
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_mushroom.png", "smooth"),
    chance = 10,
    health = 15,
    health_cap = 100
})

AddPizza({
    name = "Hawai Pizza",
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 2,
        [ZPIZ_ING_PINEAPPLE] = 1,
    },
    time = 30,
    desc = "Tropical Taste!",
    price = 250,
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_hawai.png", "smooth"),
    chance = 10,
    health = 15,
    health_cap = 100
})

AddPizza({
    name = "Cheese Pizza",
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 3,
    },
    time = 30,
    desc = "A cheese Pizza!",
    price = 200,
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_cheese.png", "smooth"),
    chance = 10,
    health = 5,
    health_cap = 100
})
