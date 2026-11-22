/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.6 (stable)
*/

zpiz = zpiz or {}
zpiz.config = zpiz.config or {}
/////////////////////////////////////////////////////////////////////////////

// Bought by 76561199123350968
// Version v2.5.6


/////////////////////////// Zeros Pizzamaker /////////////////////////////
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ee71cdadb4c1697a1f320cfc75c78c5f0135879a492afb53058e82fcefbc72f0

// Developed by ZeroChain:
// http://steamcommunity.com/id/zerochain/
// https://www.gmodstore.com/users/view/76561198013322242

/////////////////////////////////////////////////////////////////////////////


///////////////////////// zclib Config //////////////////////////////////////
/*
	This config can be used to overwrite the main config of zeros libary
*/
zclib.config.Debug = false

// The Currency
zclib.config.Currency = "$"
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

// Should the Currency symbol be in front or after the money value?
zclib.config.CurrencyInvert = true

// These Ranks are admins
// If xAdmin, sAdmin or SAM is installed then this table can be ignored
zclib.config.AdminRanks = {
	["superadmin"] = true
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ee71cdadb4c1697a1f320cfc75c78c5f0135879a492afb53058e82fcefbc72f0

//zclib.config.CleanUp.SkipOnTeamChange[TEAM_STAFF] = true
/////////////////////////////////////////////////////////////////////////////


// This automaticly blacklists the entities from the pocket swep
if GM and GM.Config and GM.Config.PocketBlacklist then
	GM.Config.PocketBlacklist["zpiz_fridge"] = true
	GM.Config.PocketBlacklist["zpiz_opensign"] = true
	GM.Config.PocketBlacklist["zpiz_oven"] = true
	GM.Config.PocketBlacklist["zpiz_ingredient"] = true
	GM.Config.PocketBlacklist["zpiz_pizza"] = true
	GM.Config.PocketBlacklist["zpiz_plate"] = true
	GM.Config.PocketBlacklist["zpiz_customertable"] = true
	GM.Config.PocketBlacklist["zpiz_animbase"] = true
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

// This enables fast download
zpiz.config.FastDL = false

// What language do we want? en,de,fr,pl,pt,cn
zpiz.config.SelectedLanguage = "en"

// Do you want to disable physgun of some entities
zpiz.config.DisablePhysgun = true

// Here you can add all the Jobs that are allowed do interact with the Fridge, Oven and OpenSign (Leave empty do disable the JobRestriction)
zpiz.config.Jobs = {}
if TEAM_ZPIZ_CHEF then zpiz.config.Jobs[TEAM_ZPIZ_CHEF] = true end

// This defines how much health a entity has, Set it to -1 to disable it
zpiz.config.Damage = {
	["zpiz_fridge"] = -1,
	["zpiz_oven"] = -1,
	["zpiz_opensign"] = -1
}

// Do we want the Health do stop at the Pizza HealthCap?
zpiz.config.HealthCap = false

// This will remove the Owner checks so everyone can use the Pizza Oven,Fridge and Sign
zpiz.config.EquipmentSharing = true

// This will spawn the Money from the Open Sign as Entity instead of sending it directly too the Owner (Only works in DarkRP at the moment)
zpiz.config.RevenueSpawn = False

// Spawns the money entity
zpiz.config.SpawnMoney = function(pos,amount)
	DarkRP.createMoneyBag(pos,amount)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 17dc2f80cf0594471955ed2fce132d0271ce6541c38902a33a4148308c414a4d

zpiz.config.Oven = {
	// How much time till the Pizza got Burned
	BurnTime = 15
}
