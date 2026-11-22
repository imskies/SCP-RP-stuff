/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

zbl = zbl or {}
zbl.Sound = zbl.Sound or {}

local function GetValidFloat(cnvar)
	if GetConVar(cnvar) then
		return GetConVar(cnvar):GetFloat()
	else
		return 1
	end
end

function zbl.Sound.GetSymptomeVolume()
	return math.Clamp(GetValidFloat("zbl_cl_symptome_volume"), 0, 1)
end

function zbl.Sound.GetVolume()
	return math.Clamp(GetValidFloat("zbl_cl_sfx_volume"), 0, 1)
end

function zbl.Sound.EmitFromPosition(pos,id)
	local soundData = zbl.Sound.Catch(id)
	sound.Play(soundData.sound, pos, soundData.lvl, soundData.pitch, soundData.volume)
end


// This packs the requested sound Data
function zbl.Sound.Catch(id)
	local soundData = {}
	local soundTable = zbl.CustomSounds[id]
	soundData.sound = soundTable.paths[math.random(#soundTable.paths)]
	soundData.lvl = soundTable.lvl
	soundData.pitch = math.Rand(soundTable.pitchMin, soundTable.pitchMax)
	soundData.volume = soundTable.volume * zbl.Sound.GetVolume()

	return soundData
end

zbl.CustomSounds = zbl.CustomSounds or {}
zbl.CustomSounds["zbl_fence_zap"] = {
	paths = {
		Sound("ambient/energy/zap1.wav"),
		Sound("ambient/energy/zap2.wav"),
		Sound("ambient/energy/zap3.wav"),
		Sound("ambient/energy/zap5.wav"),
		Sound("ambient/energy/zap6.wav"),
		Sound("ambient/energy/zap7.wav"),
		Sound("ambient/energy/zap8.wav"),
		Sound("ambient/energy/zap9.wav")
	},
	lvl = 65,
	pitchMin = 100,
	pitchMax = 100,
	volume = 0.8
}
zbl.CustomSounds["spore_explo"] = {
	paths = {Sound("zbl/zbl_spore_explosion.wav")},
	lvl = 75,
	pitchMin = 100,
	pitchMax = 100,
	volume = 1
}
zbl.CustomSounds["VomitExplosion"] = {
	paths = {Sound("physics/flesh/flesh_squishy_impact_hard1.wav")},
	lvl = 75,
	pitchMin = 100,
	pitchMax = 100,
	volume = 1
}
zbl.CustomSounds["JarBreak"] = {
	paths = {Sound("physics/glass/glass_bottle_break1.wav"),Sound("physics/glass/glass_bottle_break2.wav")},
	lvl = 75,
	pitchMin = 100,
	pitchMax = 100,
	volume = 1
}


sound.Add({
	name = "zbl_fence_zap",
	channel = CHAN_STATIC,
	volume = 0.8 * zbl.Sound.GetVolume(),
	level = 65,
	pitch = {100, 100},
	sound = {"ambient/energy/zap1.wav", "ambient/energy/zap2.wav", "ambient/energy/zap3.wav", "ambient/energy/zap5.wav", "ambient/energy/zap6.wav", "ambient/energy/zap7.wav", "ambient/energy/zap8.wav", "ambient/energy/zap9.wav"}
})

sound.Add({
	name = "zbl_lab_scan",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"npc/scanner/combat_scan_loop6.wav"}
})

sound.Add({
	name = "zbl_lab_move",
	channel = CHAN_STATIC,
	volume = 0.2 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"doors/door_metal_thin_move1.wav"}
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

sound.Add({
	name = "zbl_lab_stop",
	channel = CHAN_STATIC,
	volume = 0.2 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"doors/door_metal_thin_open1.wav"}
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9250d48d68f6eeb1d7b32c6981d6d96b7f992dc3c1277887cb56faa87c747a24

sound.Add({
	name = "zbl_scan_action",
	channel = CHAN_STATIC,
	volume = 0.5 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"npc/scanner/combat_scan1.wav", "npc/scanner/combat_scan2.wav", "npc/scanner/combat_scan3.wav", "npc/scanner/combat_scan4.wav", "npc/scanner/combat_scan5.wav"}
})

sound.Add({
	name = "zbl_vomit_explode",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetSymptomeVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"zbl/vomit_male/male_boomer_disruptvomit_01.wav", "zbl/vomit_male/male_boomer_disruptvomit_03.wav", "zbl/vomit_male/male_boomer_disruptvomit_05.wav", "zbl/vomit_male/male_boomer_disruptvomit_06.wav", "zbl/vomit_male/male_boomer_disruptvomit_07.wav", "zbl/vomit_male/male_boomer_disruptvomit_09.wav"}
})

sound.Add({
	name = "zbl_mask_off",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"zbl/zbl_mask_off.wav"}
})

sound.Add({
	name = "zbl_mask_on",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"zbl/zbl_mask_on.wav"}
})

sound.Add({
	name = "zbl_spray",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"zbl/zbl_spray01.wav", "zbl/zbl_spray02.wav", "zbl/zbl_spray03.wav", "zbl/zbl_spray04.wav", "zbl/zbl_spray05.wav"}
})

sound.Add({
	name = "zbl_cash",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"zbl/zbl_cash01.wav"}
})

// Generic
sound.Add({
	name = "zbl_ui_click",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetVolume(),
	level = 60,
	pitch = {100, 100},
	sound = {"UI/buttonclick.wav"}
})

sound.Add({
	name = "zbl_error",
	channel = CHAN_STATIC,
	volume = 0.25 * zbl.Sound.GetVolume(),
	level = 60,
	pitch = {100, 100},
	sound = {"common/warning.wav"}
})

sound.Add({
	name = "zbl_succees",
	channel = CHAN_STATIC,
	volume = 0.25 * zbl.Sound.GetVolume(),
	level = 60,
	pitch = {100, 100},
	sound = {"common/bugreporter_succeeded.wav"}
})

sound.Add({
	name = "zbl_ouch_male",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetSymptomeVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"vo/npc/Barney/ba_pain01.wav", "vo/npc/Barney/ba_pain02.wav", "vo/npc/Barney/ba_pain03.wav", "vo/npc/Barney/ba_pain04.wav", "vo/npc/Barney/ba_pain05.wav", "vo/npc/Barney/ba_pain06.wav", "vo/npc/Barney/ba_pain07.wav", "vo/npc/Barney/ba_pain08.wav", "vo/npc/Barney/ba_pain09.wav", "vo/npc/Barney/ba_pain10.wav", "vo/npc/male01/ow01.wav", "vo/npc/male01/ow02.wav", "vo/npc/male01/pain01.wav", "vo/npc/male01/pain02.wav", "vo/npc/male01/pain03.wav", "vo/npc/male01/pain04.wav", "vo/npc/male01/pain05.wav", "vo/npc/male01/pain06.wav", "vo/npc/male01/pain07.wav", "vo/npc/male01/pain08.wav", "vo/npc/male01/pain09.wav"}
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

sound.Add({
	name = "zbl_ouch_female",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetSymptomeVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"vo/npc/female01/ow01.wav", "vo/npc/female01/ow02.wav", "vo/npc/female01/pain01.wav", "vo/npc/female01/pain02.wav", "vo/npc/female01/pain03.wav", "vo/npc/female01/pain04.wav", "vo/npc/female01/pain05.wav", "vo/npc/female01/pain06.wav", "vo/npc/female01/pain07.wav", "vo/npc/female01/pain08.wav", "vo/npc/female01/pain09.wav"}
})

sound.Add({
	name = "zbl_gun_inject",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"zbl/adrenaline_needle_in.wav"}
})

sound.Add({
	name = "zbl_gun_fill",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"zbl/adrenaline_needle_open.wav"}
})

sound.Add({
	name = "zbl_gun_extract",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"items/ammocrate_open.wav"}
})

sound.Add({
	name = "zbl_cough_male",
	channel = CHAN_STATIC,
	volume = 0.4 * zbl.Sound.GetSymptomeVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"zbl/cough_male/cough01.wav", "zbl/cough_male/cough02.wav", "zbl/cough_male/cough03.wav", "zbl/cough_male/cough04.wav", "zbl/cough_male/cough05.wav", "zbl/cough_male/cough06.wav", "zbl/cough_male/cough07.wav", "zbl/cough_male/cough08.wav"}
})

sound.Add({
	name = "zbl_cough_female",
	channel = CHAN_STATIC,
	volume = 0.4 * zbl.Sound.GetSymptomeVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"zbl/cough_female/cough01.wav", "zbl/cough_female/cough02.wav", "zbl/cough_female/cough03.wav", "zbl/cough_female/cough04.wav", "zbl/cough_female/cough05.wav", "zbl/cough_female/cough06.wav", "zbl/cough_female/cough07.wav"}
})

sound.Add({
	name = "zbl_vomit_female",
	channel = CHAN_STATIC,
	volume = 0.4 * zbl.Sound.GetSymptomeVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"zbl/vomit_female/female_boomer_disruptvomit_01.wav", "zbl/vomit_female/female_boomer_disruptvomit_03.wav", "zbl/vomit_female/female_boomer_disruptvomit_05.wav", "zbl/vomit_female/female_boomer_disruptvomit_06.wav", "zbl/vomit_female/female_boomer_disruptvomit_07.wav", "zbl/vomit_female/female_boomer_disruptvomit_09.wav"}
})

sound.Add({
	name = "zbl_vomit_male",
	channel = CHAN_STATIC,
	volume = 0.4 * zbl.Sound.GetSymptomeVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"zbl/vomit_male/male_boomer_disruptvomit_01.wav", "zbl/vomit_male/male_boomer_disruptvomit_03.wav", "zbl/vomit_male/male_boomer_disruptvomit_05.wav", "zbl/vomit_male/male_boomer_disruptvomit_06.wav", "zbl/vomit_male/male_boomer_disruptvomit_07.wav", "zbl/vomit_male/male_boomer_disruptvomit_09.wav"}
})

sound.Add({
	name = "zbl_fart",
	channel = CHAN_STATIC,
	volume = 0.4 * zbl.Sound.GetSymptomeVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"zbl/fart/zbl_fart01.wav", "zbl/fart/zbl_fart02.wav"}
})

sound.Add({
	name = "zbl_npc_staph",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"npc/combine_soldier/pain1.wav", "npc/combine_soldier/pain2.wav", "npc/combine_soldier/pain3.wav"}
})

sound.Add({
	name = "zbl_vo_inject",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"npc/metropolice/vo/inject.wav"}
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

sound.Add({
	name = "zbl_fence_remove",
	channel = CHAN_STATIC,
	volume = 0.5 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"doors/door_metal_thin_open1.wav"}
})

sound.Add({
	name = "zbl_fence_stop",
	channel = CHAN_STATIC,
	volume = 0.5 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"doors/garage_stop1.wav"}
})

sound.Add({
	name = "zbl_fence_move",
	channel = CHAN_STATIC,
	volume = 0.5 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"doors/garage_move1.wav"}
})

sound.Add({
	name = "zbl_gate_scan_bad",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"ambient/alarms/klaxon1.wav"}
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

sound.Add({
	name = "zbl_gate_scan_infection",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"npc/overwatch/radiovoice/infection.wav"}
})

sound.Add({
	name = "zbl_gate_scan_docu",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"npc/overwatch/radiovoice/document.wav", "npc/overwatch/radiovoice/examine.wav"}
})

sound.Add({
	name = "zbl_gate_punish",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"npc/overwatch/radiovoice/illegalinoperation63s.wav"}
})

sound.Add({
	name = "zbl_gate_sterilize",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"npc/overwatch/radiovoice/sterilize.wav"}
})

sound.Add({
	name = "zbl_gate_cauterize",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"npc/overwatch/radiovoice/cauterize.wav"}
})

sound.Add({
	name = "zbl_gate_scan_good",
	channel = CHAN_STATIC,
	volume = 1 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = {"npc/roller/remote_yes.wav"}
})


sound.Add({
	name = "zbl_scan_smu",
	channel = CHAN_STATIC,
	volume = 0.1 * zbl.Sound.GetVolume(),
	level = 75,
	pitch = {100, 100},
	sound = { "npc/scanner/combat_scan5.wav"}
})
