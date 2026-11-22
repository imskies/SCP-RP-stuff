/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

zbl = zbl or {}

// Here you can specify if the model is male or female, so the script knows what sound to play
// For none specified models it will just play male/female sounds at random
zbl.SoundByModel = {}

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

zbl.SoundByModel["models/player/alyx.mdl"] = "female"
zbl.SoundByModel["models/player/p2_chell.mdl"] = "female"
zbl.SoundByModel["models/player/mossman.mdl"] = "female"

zbl.SoundByModel["models/player/kleiner.mdl"] = "male"
zbl.SoundByModel["models/player/monk.mdl"] = "male"
zbl.SoundByModel["models/player/corpse1.mdl"] = "male"
zbl.SoundByModel["models/player/police.mdl"] = "male"
zbl.SoundByModel["models/player/breen.mdl"] = "male"
zbl.SoundByModel["models/player/barney.mdl"] = "male"
zbl.SoundByModel["models/player/gman_high.mdl"] = "male"
zbl.SoundByModel["models/player/odessa.mdl"] = "male"
zbl.SoundByModel["models/player/eli.mdl"] = "male"
zbl.SoundByModel["models/player/charple.mdl"] = "male"
zbl.SoundByModel["models/player/soldier_stripped.mdl"] = "male"

zbl.SoundByModel["models/player/group02/male_02.mdl"] = "male"
zbl.SoundByModel["models/player/group02/male_04.mdl"] = "male"
zbl.SoundByModel["models/player/group02/male_06.mdl"] = "male"
zbl.SoundByModel["models/player/group02/male_08.mdl"] = "male"


zbl.SoundByModel["models/player/group01/male_01.mdl"] = "male"
zbl.SoundByModel["models/player/group01/male_02.mdl"] = "male"
zbl.SoundByModel["models/player/group01/male_03.mdl"] = "male"
zbl.SoundByModel["models/player/group01/male_04.mdl"] = "male"
zbl.SoundByModel["models/player/group01/male_05.mdl"] = "male"
zbl.SoundByModel["models/player/group01/male_06.mdl"] = "male"
zbl.SoundByModel["models/player/group01/male_07.mdl"] = "male"
zbl.SoundByModel["models/player/group01/male_08.mdl"] = "male"
zbl.SoundByModel["models/player/group01/male_09.mdl"] = "male"


zbl.SoundByModel["models/player/group03/male_01.mdl"] = "male"
zbl.SoundByModel["models/player/group03/male_02.mdl"] = "male"
zbl.SoundByModel["models/player/group03/male_03.mdl"] = "male"
zbl.SoundByModel["models/player/group03/male_04.mdl"] = "male"
zbl.SoundByModel["models/player/group03/male_05.mdl"] = "male"
zbl.SoundByModel["models/player/group03/male_06.mdl"] = "male"
zbl.SoundByModel["models/player/group03/male_07.mdl"] = "male"
zbl.SoundByModel["models/player/group03/male_08.mdl"] = "male"
zbl.SoundByModel["models/player/group03/male_09.mdl"] = "male"

zbl.SoundByModel["models/player/group03/female_01.mdl"] = "female"
zbl.SoundByModel["models/player/group03/female_02.mdl"] = "female"
zbl.SoundByModel["models/player/group03/female_03.mdl"] = "female"
zbl.SoundByModel["models/player/group03/female_04.mdl"] = "female"
zbl.SoundByModel["models/player/group03/female_05.mdl"] = "female"
zbl.SoundByModel["models/player/group03/female_06.mdl"] = "female"


zbl.SoundByModel["models/player/group03m/male_01.mdl"] = "male"
zbl.SoundByModel["models/player/group03m/male_02.mdl"] = "male"
zbl.SoundByModel["models/player/group03m/male_03.mdl"] = "male"
zbl.SoundByModel["models/player/group03m/male_04.mdl"] = "male"
zbl.SoundByModel["models/player/group03m/male_05.mdl"] = "male"
zbl.SoundByModel["models/player/group03m/male_06.mdl"] = "male"
zbl.SoundByModel["models/player/group03m/male_07.mdl"] = "male"
zbl.SoundByModel["models/player/group03m/male_08.mdl"] = "male"
zbl.SoundByModel["models/player/group03m/male_09.mdl"] = "male"

zbl.SoundByModel["models/player/group03m/female_01.mdl"] = "female"
zbl.SoundByModel["models/player/group03m/female_02.mdl"] = "female"
zbl.SoundByModel["models/player/group03m/female_03.mdl"] = "female"
zbl.SoundByModel["models/player/group03m/female_04.mdl"] = "female"
zbl.SoundByModel["models/player/group03m/female_05.mdl"] = "female"
zbl.SoundByModel["models/player/group03m/female_06.mdl"] = "female"

zbl.SoundByModel["models/player/group01/female_01.mdl"] = "female"
zbl.SoundByModel["models/player/group01/female_02.mdl"] = "female"
zbl.SoundByModel["models/player/group01/female_03.mdl"] = "female"
zbl.SoundByModel["models/player/group01/female_04.mdl"] = "female"
zbl.SoundByModel["models/player/group01/female_05.mdl"] = "female"
zbl.SoundByModel["models/player/group01/female_06.mdl"] = "female"

zbl.SoundByModel["models/player/hostage/hostage_01.mdl"] = "male"
zbl.SoundByModel["models/player/hostage/hostage_02.mdl"] = "male"
zbl.SoundByModel["models/player/hostage/hostage_03.mdl"] = "male"
zbl.SoundByModel["models/player/hostage/hostage_04.mdl"] = "male"

zbl.SoundByModel["models/zerochain/props_bloodlab/zbl_hazmat.mdl"] = "male"


                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

// This defines a offsets for diffrent models so the gasmask allways fits perfect
zbl.ModelOffsets = {}
/*
zbl.ModelOffsets["Path/To/The/Model.mdl"] = {
    pos = Offset Position from ValveBiped.Bip01_Head1,
    ang = Offset Angle from ValveBiped.Bip01_Head1,
    scale = Size of the Respirator Model (can be removed if not needed)
}

Those console commands can help adding new ModelOffsets
    zbl_debug_SetPlayermodel model/path
    zbl_debug_GetPlayermodel
    zbl_debug_GasMask_EquiptID RespiratorID
*/
zbl.ModelOffsets["Default"] = {pos = Vector(2.9, 0, 0.6),ang = Angle(-5, 0, 0)}
zbl.ModelOffsets["models/player/kleiner.mdl"] = {pos = Vector(3.1, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/monk.mdl"] = {pos = Vector(3.6, 0, 0.85),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/corpse1.mdl"] = {pos = Vector(3.6, 0, 0),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/police.mdl"] = {pos = Vector(6, 0, 0),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/breen.mdl"] = {pos = Vector(3.3, 0, 0),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/alyx.mdl"] = {pos = Vector(2.6, 0, 0.6),ang = Angle(-5, 0, 0)}
zbl.ModelOffsets["models/player/p2_chell.mdl"] = {pos = Vector(2.8, 0, 0.8),ang = Angle(-5, 0, 0)}
zbl.ModelOffsets["models/player/barney.mdl"] = {pos = Vector(3.6, 0, 0.9),ang = Angle(-5, 0, 0)}
zbl.ModelOffsets["models/player/gman_high.mdl"] = {pos = Vector(3, 0, 1.9),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/odessa.mdl"] = {pos = Vector(3.7, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/mossman.mdl"] = {pos = Vector(3, 0.1, 0.7),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/eli.mdl"] = {pos = Vector(3, 0.1, 0.7),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/charple.mdl"] = {pos = Vector(1, 0, 0),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/soldier_stripped.mdl"] = {pos = Vector(2, 0, 0),ang = Angle(0, 0, 0)}


zbl.ModelOffsets["models/player/group02/male_02.mdl"] = {pos = Vector(3.5, 0, 0.6),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group02/male_04.mdl"] = {pos = Vector(3.5, 0, 1),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group02/male_06.mdl"] = {pos = Vector(4, 0, 0.9),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group02/male_08.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c


zbl.ModelOffsets["models/player/group01/male_01.mdl"] = {pos = Vector(3.9, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group01/male_02.mdl"] = {pos = Vector(3.5, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group01/male_03.mdl"] = {pos = Vector(3.7, 0, 0.7),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/group01/male_04.mdl"] = {pos = Vector(3.2, 0, 1),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group01/male_05.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/group01/male_06.mdl"] = {pos = Vector(4, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group01/male_07.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group01/male_08.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group01/male_09.mdl"] = {pos = Vector(3.7, 0, 0.7),ang = Angle(10, 0, 0)}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c


zbl.ModelOffsets["models/player/group03/male_01.mdl"] = {pos = Vector(3.9, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03/male_02.mdl"] = {pos = Vector(3.5, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03/male_03.mdl"] = {pos = Vector(3.7, 0, 0.7),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/group03/male_04.mdl"] = {pos = Vector(3.2, 0, 1),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group03/male_05.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/group03/male_06.mdl"] = {pos = Vector(4, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03/male_07.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group03/male_08.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group03/male_09.mdl"] = {pos = Vector(3.7, 0, 0.7),ang = Angle(10, 0, 0)}

zbl.ModelOffsets["models/player/group03/female_01.mdl"] = {pos = Vector(3, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03/female_02.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03/female_03.mdl"] = {pos = Vector(3.1, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03/female_04.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03/female_05.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03/female_06.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}


zbl.ModelOffsets["models/player/group03m/male_01.mdl"] = {pos = Vector(3.9, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03m/male_02.mdl"] = {pos = Vector(3.5, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03m/male_03.mdl"] = {pos = Vector(3.7, 0, 0.7),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/group03m/male_04.mdl"] = {pos = Vector(3.2, 0, 1),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group03m/male_05.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/group03m/male_06.mdl"] = {pos = Vector(4, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03m/male_07.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group03m/male_08.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group03m/male_09.mdl"] = {pos = Vector(3.7, 0, 0.7),ang = Angle(10, 0, 0)}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

zbl.ModelOffsets["models/player/group03m/female_01.mdl"] = {pos = Vector(3, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03m/female_02.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03m/female_03.mdl"] = {pos = Vector(3.1, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03m/female_04.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03m/female_05.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03m/female_06.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}


zbl.ModelOffsets["models/player/group01/female_01.mdl"] = {pos = Vector(3, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group01/female_02.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group01/female_03.mdl"] = {pos = Vector(3.1, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group01/female_04.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group01/female_05.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group01/female_06.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}


zbl.ModelOffsets["models/player/hostage/hostage_01.mdl"] = {pos = Vector(3, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/hostage/hostage_02.mdl"] = {pos = Vector(3.9, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/hostage/hostage_03.mdl"] = {pos = Vector(3, 0, 0.2),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/hostage/hostage_04.mdl"] = {pos = Vector(3, 0, 1),ang = Angle(0, 0, 0)}
