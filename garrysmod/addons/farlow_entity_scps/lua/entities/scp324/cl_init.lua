include("shared.lua")

local flashTime = 2.5 -- flash lasts longer
local mainSound = "scp_1123/use_1123.wav"
local breathingSound = "ambient/creatures/town_scared_breathing1.wav"

local memories = {
"You remember standing in tall grass…",
    "A warm memory of sunlight on fur washes over you…",
    "Hunger. A deep, primal hunger echoes in your mind…",
    "You recall running through a forest at night…",
    "Your heartbeat aligns with something ancient and wild…",
    "The scent of earth and rain floods your senses…",
    "You feel your hands—no, paws—pressing into soft soil…",
    "A distant howl triggers something buried inside you…",
    "You remember watching humans from the tree line…",
    "A flash of bright light—pain—confusion—and instinct…",
    "You remember the vibration of wings against a summer breeze…",
    "Tiny legs scuttle across a leaf; the world smells of sap and sun…",
    "You recall the taste of nectar, sweet and immediate…",
    "A sudden gust lifts you; the sky is a vast, blue ceiling…",
    "You remember burrowing into warm detritus and sleeping through rain…",
    "The hum of a hive pulses in your memory, ordered and urgent…",
    "You feel the tick of antennae against a petal, mapping scent trails…",
    "A flash of iridescence—shell and wing—reminds you of sunlight on water…",
    "You remember the slow, patient drag of a shell across damp earth…",
    "Salt and spray fill your mind; the tide calls you home…",
    "You recall the cold press of deep water and the hush of pressure…",
    "Bioluminescent ghosts drift past; your world is a slow, blue night…",
    "You remember hunting in the dark, jaws snapping with practiced precision…",
    "A memory of coral gardens brushing your fins with color and current…",
    "You feel the scrape of sand as you bury yourself, eyes just above the surface…",
    "You remember the sudden, bright flash of a school scattering at your approach…",
    "The taste of plankton and the slow ache of a long migration linger…",
    "You recall the slow, ancient rhythm of tides guiding your path…",
    "You remember clinging to a rock as waves try to pry you loose…",
    "A memory of the first warm sun after a long winter underground…",
    "You recall the soft, rhythmic chirp of a mate calling in the dusk…",
    "You feel the vibration of a branch as you leap from leaf to leaf…",
    "You remember the metallic tang of blood and the rush of the chase…",
    "A memory of the hive’s strict order, each worker knowing its place…",
    "You recall the taste of sap and the slow, sticky work of building…",
    "You remember the hush of a cave and the echo of dripping stone…",
    "The cold, damp smell of moss and the slow slide of a tongue across prey…",
    "You feel the sun‑warmed rock beneath your belly and the slow patience of ambush…",
    "You remember the flash of feathers as you launch into the air…",
    "Wind under your wings, the world a patchwork of fields and rivers…",
    "You recall the sharp, bright taste of a fish caught mid‑flight…",
    "A memory of nesting high and the fragile weight of eggs beneath you…",
    "You remember the soft, muffled world of night and the keen slit of sight…",
    "You recall the slow, deliberate chew of tough leaves and the warmth of cud…",
    "You feel the rumble of hooves on hard ground and the herd’s steady pull…",
    "You remember the sudden panic of a predator’s cry and the scatter of bodies…",
    "A memory of the wet, heavy smell of newborns and the fierce, protective heat…",
    "You recall the cool, damp world under a log and the slow slide of a belly…",
    "You remember shedding skin and the strange lightness that follows…",
    "The taste of insects and the patient wait beneath a sun‑warmed stone…",
    "You recall the slow, patient blink of an ambush predator’s eye…",
    "You remember the soft, wet press of a riverbank and the tug of current…",
    "A memory of the first leap from a nest and the dizzying rush of falling…",
    "You recall the bright, sharp scent of blood and the sudden clarity of hunger…",
    "You remember the cool, dark burrow and the safe, muffled breathing of kin…",
    "You feel the tickle of whiskers against a mouse’s flank and the thrill of the hunt…",
    "You recall the steady, patient tapping of a beak against wood…",
    "You remember the taste of seeds and the quick, bright chatter of flockmates…",
    "A memory of the slow, wet drag of a tongue across a newborn’s fur…",
    "You recall the metallic clang of a shell and the slow, armored shuffle…",
    "You remember the tiny, precise bite of a predator and the sudden end of a day…",
    "You feel the cool, mineral taste of cave water and the hush of subterranean halls…",
    "You recall the slow, patient sweep of a tail through silt and the flash of gills…",
    "You remember the bright, electric jolt of a defensive strike and the silence after…",
    "A memory of the first warm current that carried you toward open water…",
    "You recall the soft, papery rustle of wings at dusk and the scent of fruit…",
    "You remember the sticky, sweet smear of fruit on your face and the lazy buzz of flies…",
    "You feel the vibration of a tree trunk as you climb, claws finding purchase…",
    "You recall the slow, deliberate chew of tough bark and the strange comfort of sap…",
    "You remember the cold, bright snap of ice underfoot and the hush of snow…",
    "A memory of the long, patient drift of seeds on the wind and the promise of spring…",
    "You recall the bright, sharp taste of a crustacean and the crunch of shell…",
    "You remember the slow, grinding work of a beak cracking open a nut…",
    "You feel the press of a flock’s warmth in winter and the safety of numbers…",
    "You recall the sudden, bright flare of mating colors and the frantic dance that follows…",
    "You remember the slow, patient scrape of tusk against earth and the scent of mud…",
    "A memory of the deep, resonant call that travels for miles through water…",
    "You recall the tiny, precise movements of a tongue catching nectar in a flower…",
    "You remember the soft, wet press of a mother’s nose and the comfort of being small…",
    "You feel the electric hum of a swarm and the dizzying, coordinated flight…",
    "You recall the slow, patient gnaw of a beaver shaping a river’s edge…",
    "You remember the bright, sudden flash of a predator’s teeth and the scramble to hide…",
    "A memory of the long, cold drift of plankton and the slow filter of baleen…",
    "You recall the metallic scrape of barnacles and the slow slide of hulls past you…",
    "You remember the hush of deep water and the slow, patient search for food…",
    "You feel the tick of tiny legs on your shell and the slow, ancient patience of a turtle…",
    "You recall the bright, stinging taste of a jellyfish and the reflex to recoil…",
    "You remember the soft, warm press of a nest and the constant, watchful vigilance of a parent…",
    "A memory of the first cold shock of altitude and the thin, bright air…",
    "You recall the slow, steady beat of a tail propelling you through thick reeds…",
    "You remember the bright, metallic scent of a river after rain and the sudden abundance of prey…",
    "You feel the scrape of sandpaper skin and the slow, efficient glide of a ray…",
    "You recall the tiny, precise strike of a tongue snatching a fly from the air…",
    "You remember the slow, patient hum of a colony and the ritual of feeding young…",
    "A memory of the first warm current that carried you toward the open sea…",
    "You recall the bright, sharp taste of a seed and the quick, greedy pecking of a chick…",
    "You remember the slow, steady thrum of wings in migration and the ache of distance…",
    "You feel the cool, mineral tang of a cave pool and the slow, blind search for food…",
    "You recall the sudden, bright flare of a mating display and the frantic scramble that follows…",
    "You remember the soft, damp press of a marsh and the chorus of frogs at dusk…",
    "A memory of the slow, patient drift of a larva and the strange, sudden change of metamorphosis…",
    "You recall the metallic taste of iron in the water and the slow, patient feeding of bottom dwellers…",
    "You remember the bright, stinging shock of a defensive barb and the sudden silence that follows…",
    "You feel the warm, oily press of blubber and the slow, ponderous roll of a leviathan…",
    "You recall the tiny, precise nibble of a cleaner fish and the relief of parasites gone…",
    "You remember the soft, papery flutter of wings in a cathedral of trees…",
    "A memory of the first warm light after a long, cold night and the urgent search for food…",
    "You recall the slow, patient scrape of a beak against shell and the reward of meat inside…",
    "You remember the bright, bitter tang of sap and the slow, sticky work of feeding young…",
    "You feel the vibration of a branch as a predator passes and the sudden stillness that follows…",
    "You recall the cold, bright flash of a predator’s eye and the instant decision to flee…",
    "You remember the soft, wet press of a river stone and the slow, patient search for shelter…",
    "A memory of the long, patient drift of spores and the quiet colonization of a new place…",
    "You recall the tiny, urgent heartbeat of a hatchling and the fierce, immediate need to protect…",
    "You remember the slow, patient scrape of tusk on bone and the taste of marrow…",
    "You feel the cool, briny press of deep currents and the slow, patient hunt in the dark…",
    "You recall the bright, sudden flash of a lure in the deep and the irresistible pull of curiosity…",
    "You remember the soft, warm press of fur against your cheek and the comfort of kin…",
    "A memory of the first cold wind of autumn and the instinct to gather and store…",
    "You recall the tiny, precise bite of a pollinator and the slow, spreading life of a flower…",
    "You remember the slow, patient drift of a seed pod and the promise of new ground…",
    "You feel the steady, patient thrum of a heart tuned to the rhythm of the wild…",
    "You recall the bright, sharp taste of a small fish and the quick, clean swallow…",
    "You remember the hush of a winter night and the bright, urgent call of a mate in spring…",
    "A memory of the slow, patient scrape of a claw and the scent of territory marked…",
    "You recall the tiny, urgent buzz of wings and the dizzying, precise choreography of a swarm…",
    "You remember the cool, dark press of a burrow and the safe, muffled breathing of family…",
    "You feel the sudden, bright clarity of a predator’s strike and the reflex to vanish…",
    "You recall the slow, patient drift of a jellyfish and the strange, alien grace of its movement…",
    "You remember the bright, metallic taste of salt on your tongue and the endless horizon beyond…",
    "A memory of the first warm current that carried you toward a reef and the riot of color there…",
    "You recall the tiny, precise scrape of a beak cleaning feathers and the comfort of ritual…",
    "You remember the soft, wet press of a paw and the sudden, fierce protectiveness it brings…",
    "You feel the slow, patient ache of migration and the relief of reaching familiar ground…",
    "You recall the bright, sudden flash of a predator’s teeth and the scramble to safety…",
    "You remember the hush of deep water and the slow, patient search for a mate by song…",
    "A memory of the first warm light after a long night and the urgent, hungry scramble of newborns…",
    "You recall the tiny, precise movements of a tongue tasting the world and the joy of discovery…",
    "You remember the slow, patient scrape of a shell across rock and the slow accumulation of years…",
    "You feel the vibration of a tree in storm and the small, fierce hold of roots in the earth…",
    "You recall the bright, sharp scent of a predator and the instant, practiced flight that follows…",
    "You remember the soft, warm press of a nest and the constant, watchful vigilance of a parent…",
    "A memory of the long, patient drift of spores and the quiet colonization of new ground…",
    "You recall the tiny, urgent heartbeat of a hatchling and the fierce, immediate need to protect…",
    "You remember the slow, patient scrape of tusk on bone and the taste of marrow…",
    "You feel the cool, briny press of deep currents and the slow, patient hunt in the dark…",
    "You recall the bright, sudden flash of a lure in the deep and the irresistible pull of curiosity…"
}

net.Receive("SCP324_Interact", function()
    -- Play main interaction sound
    surface.PlaySound(mainSound)

    -- Screen flash timing
    local endTime = CurTime() + flashTime

    hook.Add("RenderScreenspaceEffects", "SCP324_Flash", function()
        local fade = math.Clamp((endTime - CurTime()) / flashTime, 0, 1)

        if fade <= 0 then
            hook.Remove("RenderScreenspaceEffects", "SCP324_Flash")
            return
        end

        DrawColorModify({
            ["$pp_colour_addr"] = fade,
            ["$pp_colour_addg"] = fade,
            ["$pp_colour_addb"] = fade,
            ["$pp_colour_brightness"] = fade * 0.15,
            ["$pp_colour_contrast"] = 1,
            ["$pp_colour_colour"] = 1
        })
    end)

    -- Show random memory text
    chat.AddText(
        Color(200, 50, 50), "[SCP-324] ",
        Color(255, 255, 255), memories[math.random(#memories)]
    )

    -- Delayed breathing sound
    timer.Simple(1, function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        ply:EmitSound(breathingSound, 60, 100, 0.6)
    end)
end)
