/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

if not SERVER then return end

// Here are some Hooks you can use for Custom Code
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ee71cdadb4c1697a1f320cfc75c78c5f0135879a492afb53058e82fcefbc72f0
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ee71cdadb4c1697a1f320cfc75c78c5f0135879a492afb53058e82fcefbc72f0

// Called when the player sells a Pizza
hook.Add("zpiz_OnPizzaSold", "zpiz_OnPizzaSold_Test", function(ply, earning, pizzaID, isburned)
    /*
    if IsValid(ply) then
        print("-----------")
        print(ply)
        print(earning)
        print(pizzaID)
        print(isburned)
        print("-----------")
    end
    */
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- fde1005ae952a630057a2cc575fe1335e7c9809985c0483424501baa23d5a1ad

// Called when a pizza got finished baking in the oven
hook.Add("zpiz_OnPizzaReady", "zpiz_OnPizzaReady_Test", function(pizza, pizzaowner, pizzaID, oven)
    /*
    print("-----------")
    print(pizza)
    print(pizzaowner)
    print(pizzaID)
    print(oven)
    print("-----------")
    */
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

// Called when a pizza gets burned
hook.Add("zpiz_OnPizzaBurned", "zpiz_OnPizzaBurned_Test", function(pizza, pizzaowner, pizzaID)
    /*
    print("-----------")
    print(pizza)
    print(pizzaowner)
    print(pizzaID)
    print("-----------")
    */
end)



// Called when a player eats a Oizza
hook.Add("zpiz_OnPizzaEaten", "zpiz_OnPizzaEaten_Test", function(ply, pizzaID)
    /*
    print("-----------")
    print(ply)
    print(pizzaID)
    print("-----------")
    */
end)
